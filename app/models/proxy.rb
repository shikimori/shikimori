# TODO: refactor
# sudo apt-get install libjpeg-progs
class Proxy < ApplicationRecord
  SAFE_ERRORS = /
    queue \s empty |
    execution \s expired |
    banned |
    connection \s refused |
    connection \s reset \s by \s peer |
    no \s route \s to \s host |
    end \s of \s file \s reached |
    404 \s Not \s Found
  /mix
  USER_AGENT = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/102.0.0.0 Safari/537.36'

  enumerize :protocol,
    in: Types::Proxy::Protocol.values

  cattr_accessor :use_proxy, :use_cache, :show_log

  @@proxies = nil
  @@proxies_initial_size = 0
  @@use_cache = false # Rails.env == 'test'
  @@show_log = false
  @@use_proxy = true

  class << self
    # https://proxy6.net/user/proxy
    def prepaid_proxy
      @prepaid_proxy ||=
        if Rails.application.secrets.proxy[:url]
          {
            proxy_http_basic_authentication: [
              Rails.application.secrets.proxy[:url],
              Rails.application.secrets.proxy[:login],
              Rails.application.secrets.proxy[:password]
            ]
          }
        else
          {}
        end
    end

    def preload
      queue = Queue.new
      Proxy.all.shuffle.each { |v| queue.push v }

      @@proxies_initial_size = queue.size
      @@proxies = queue
    end

    def get url, options = {}
      process url, options, :get
    end

    def post url, options = {}
      process url, options, :post
    end

    # выполнение запроса через прокси или из кеша
    def process url, options, method
      if @@use_cache && File.exist?(cache_path(url, options)) && (1.month.ago < File.ctime(cache_path(url, options)))
        NamedLogger.proxy.info "CACHE #{url} (#{cache_path(url, options)})"
        return File.open(cache_path(url, options), 'r', &:read)
      end

      # получаем контент
      content =
        if options[:no_proxy] || @@use_cache || !@@use_proxy
          if method == :get
            no_proxy_get url, options
          else
            no_proxy_post url, options
          end
        else
          do_request url, options.merge(method: method)
        end

      # фиксим кодировки
      content = content.fix_encoding(options[:encoding]) if content && url !~ /\.(jpg|gif|png|jpeg)/i

      # кешируем
      if content&.present? && (options[:test] || @@use_cache)
        File.open(cache_path(url, options), 'w') { |h| h.write(content) }
      end

      content
    end

    # выполнение запроса
    def do_request url, options
      preload if (options[:proxy].nil? && @@proxies.nil?) || (@@proxies && @@proxies.size < @@proxies_initial_size / 7)
      # raise NoProxies, url if options[:proxy].nil? && @@proxies.empty?

      content = nil
      proxy = options[:proxy] # прокси может быть передана в параметрах, тогда использоваться будет лишь она

      max_attempts = options[:attempts] || 8
      options[:timeout] ||= 15

      attempts = 0 # число попыток
      freeze_count = 50 # число переборов проксей

      until content || attempts == max_attempts || freeze_count <= 0
        freeze_count -= 1

        begin
          proxy ||= @@proxies.pop(true) # кидает "ThreadError: queue empty" при пустой очереди
          log "#{options[:method].to_s.upcase} #{url}#{options[:data] ? ' ' + options[:data].map { |k, v| "#{k}=#{v}" }.join('&') : ''} via #{proxy}", options

          Timeout.timeout(options[:timeout]) do
            content =
              if options[:method] == :get
                # Net::HTTP::Proxy(proxy.ip, proxy.port).get(uri) # Net::HTTP не следует редиректам, в топку его
                get_open_uri(url, proxy: proxy.to_s(true)).read
              else
                Net::HTTP::Proxy(proxy.ip, proxy.port).post_form(URI.parse(url), options[:data]).body
              end
          end
          raise "#{proxy} banned" if content.nil?

          # фикс кодировок перед проверкой текста
          content = content.fix_encoding(options[:encoding]) if content && url !~ /\.(jpg|gif|png|jpeg)/i
          raise "#{proxy} banned" if content.blank?

          # проверка валидности jpg
          if options[:validate_jpg]
            tmpfile = Tempfile.new 'jpg'
            File.open(tmpfile.path, 'wb') { |f| f.write content }
            tmpfile.instance_variable_set :@original_filename, url.split('/').last
            def tmpfile.original_filename
              @original_filename
            end

            unless ImageChecker.valid? tmpfile.path
              content = nil
              # тут можно бы обнулять tmpfile, но если мы 8 раз не смогли загрузить файл, то наверное его и правда нет, падать не будем
              log 'bad image', options
            end
          end

          # проверка на наличие запрошенного текста
          if options[:required_text]
            requires =
              if options[:required_text].is_a?(Array)
                options[:required_text]
              else
                [options[:required_text]]
              end

            stripped_content = content.gsub(/[ \n\r]+/, '').downcase
            raise "#{proxy} banned" unless requires.all? { |text| stripped_content.include?(text.gsub(/[ \n\r]+/, '').downcase) }
          end

          # проверка на забаненны тексты
          options[:ban_texts]&.each do |text|
            raise "#{proxy} banned" if text.is_a?(Regexp) ? content.match(text) : content.include?(text)
          end

          # и надо не забыть вернуть проксю назад
          @@proxies.push(proxy) unless options[:proxy]

          attempts += 1
        rescue ThreadError => e
          raise NoProxies, url
        rescue StandardError => e
          raise if defined?(VCR) && e.is_a?(VCR::Errors::UnhandledHTTPRequestError)

          if /404 Not Found/.match?(e.message)
            @@proxies.push(proxy) unless options[:proxy]
            raise
          end

          if SAFE_ERRORS.match?(e.message)
            log e.message.to_s, options
          else
            log "#{e.message}\n#{e.backtrace.join("\n")}", options
          end

          proxy = nil
          content = nil

          exit if e.class == Interrupt
          break if options[:proxy] # при указании прокси делаем лишь одну попытку
        end
      end

      log "can't get page #{url}", options if content.nil?

      if options[:return_file]
        tmpfile
      else
        content
      end
    end

    # выполнение get запроса без прокси
    def no_proxy_get url, options
      NamedLogger.proxy.info "GET #{url}"

      resp = get_open_uri URI.encode(url)
      file =
        if resp.meta['content-encoding'] == 'gzip'
          Zlib::GzipReader.new(StringIO.new(resp.read))
        else
          resp
        end

      options[:return_file] ? file : file.read
    rescue StandardError => e
      raise if defined?(VCR) && e.is_a?(VCR::Errors::UnhandledHTTPRequestError)

      if SAFE_ERRORS.match?(e.message)
        log "#{e.class.name} #{e.message}", options
      else
        log "#{e.class.name} #{e.message}\n#{e.backtrace.join("\n")}", options
      end

      exit if e.class == Interrupt
      nil
    end

    # выполнение post запроса без прокси
    def no_proxy_post url, options
      uri = URI.parse(url)
      http = Net::HTTP.new(uri.host, uri.port)
      path = uri.path
      # cookie = resp.response['set-cookie']

      # POST request -> getting data
      data = options[:data].map { |k, v| "#{k}=#{v}" }.join('&')
      headers = {
        # 'Cookie' => cookie,
        'Referer' => url,
        'Content-Type' => 'application/x-www-form-urlencoded'
      }

      NamedLogger.proxy.info "POST #{url} #{data}"
      resp = http.post(path, data, headers)
      resp.body
    rescue StandardError => e
      raise if defined?(VCR) && e.is_a?(VCR::Errors::UnhandledHTTPRequestError)

      if SAFE_ERRORS.match?(e.message)
        log "#{e.class.name} #{e.message}", options
      else
        log "#{e.class.name} #{e.message}\n#{e.backtrace.join("\n")}", options
      end

      exit if e.is_a?(Interrupt) # rubocop:disable Rails/Exit
      nil
    end

    # адрес страницы в кеше
    def cache_path url, options
      Dir.mkdir('tmp/cache/pages') unless Rails.env.test? || File.exist?('tmp/cache/pages')
      (Rails.env.test? ? 'spec/pages/%s' : 'tmp/cache/pages/%s') % Digest::MD5.hexdigest(options[:data] ? "#{url}_data:#{options[:data].map { |k, v| "#{k}=#{v}" }.join('&')}" : url)
    end

    # логирование
    def log message, options
      print "[Proxy]: #{message}\n" if options[:log] || @@show_log
    end

    def off!
      @@use_proxy = false
    end

    def on!
      @@use_proxy = true
    end

    def get_open_uri url, params = {}
      if /\.(jpe?g|png)$/.match?(url)
        OpenURI.open_image url, open_params(url, params)
      else
        OpenURI.open_uri url, open_params(url, params)
      end
    end

    def open_params url, params
      if params[:proxy]
        params.merge(
          'User-Agent' => user_agent(url),
          ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE,
          allow_redirections: :all
        )
      else
        params.merge(
          'User-Agent' => user_agent(url),
          ssl_verify_mode: OpenSSL::SSL::VERIFY_NONE,
          allow_redirections: :all,
          **Proxy.prepaid_proxy
        )
      end
    end

    def user_agent _url
      USER_AGENT
    end
  end

  def to_s with_http = false
    with_http ? "http://#{ip}:#{port}" : "#{ip}:#{port}"
  end
end
