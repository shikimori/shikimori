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
    404 \s Not \s Found |
    socks \s error |
    Failed \s to \s connect \s to \s proxy
  /mix
  USER_AGENT = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_15_7) AppleWebKit/537.36 ' \
    '(KHTML, like Gecko) Chrome/102.0.0.0 Safari/537.36'
  URL_REGEXP = %r{://|:}

  enumerize :protocol,
    in: Types::Proxy::Protocol.values,
    predicates: true

  scope :alive, -> { where dead: 0 }

  cattr_accessor :use_proxy, :show_log

  @@proxies = nil
  @@proxies_initial_size = 0
  @@show_log = false
  @@use_proxy = true

  class << self
    def from_url url
      parts = url.split(URL_REGEXP)
      Proxy.new ip: parts[1], port: parts[2].to_i, protocol: parts[0]
    end

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
      Proxy.alive.shuffle.each { |v| queue.push v }

      @@proxies_initial_size = queue.size
      @@proxies = queue
    end

    def get url, options = {}
      if options[:no_proxy] || !@@use_proxy
        no_proxy_get url, options
      else
        do_request url, options
      end

      # content = content.fix_encoding(options[:encoding]) if content && !url.match?(/\.(jpe?g|gif|png)/i)
      # content
    end

    def do_request url, options
      if (options[:proxy].nil? && @@proxies.nil?) ||
          (@@proxies && @@proxies.size < @@proxies_initial_size / 7)
        preload
      end

      content = nil
      proxy = options[:proxy] # прокси может быть передана в параметрах, тогда использоваться будет лишь она

      max_attempts = options[:attempts] || 8
      options[:timeout] ||= 15

      attempts = 0 # число попыток
      freeze_count = 50 # число переборов проксей

      until content ||
          attempts == max_attempts ||
          freeze_count <= 0 ||
          (attempts.positive? && options[:proxy])
        freeze_count -= 1

        begin
          proxy ||= @@proxies.pop(true) # кидает "ThreadError: queue empty" при пустой очереди
          log "#{url}#{options[:data] ? ' ' + options[:data].map { |k, v| "#{k}=#{v}" }.join('&') : ''} via #{proxy}", options

          # timeout does not with shell exec
          # Timeout.timeout(options[:timeout]) do
            content = get_via_proxy url, proxy, options[:timeout]
          # end
          # raise "#{proxy} banned" if content.nil?

          # do not check for .blank? since may download a binary data
          raise "#{proxy} banned or broken" if content&.size&.zero?

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
            unless requires.all? { |v| stripped_content.include?(v.gsub(/[ \n\r]+/, '').downcase) }
              raise "#{proxy} banned or broken"
            end
          end

          # проверка на забаненны тексты
          options[:ban_texts]&.each do |text|
            if text.is_a?(Regexp) ? content.match(text) : content.include?(text)
              raise "#{proxy} banned"
            end
          end

          # и надо не забыть вернуть проксю назад
          @@proxies.push(proxy) unless options[:proxy]

          attempts += 1
        rescue ThreadError => e
          raise NoProxies, url
        rescue StandardError => e
          raise if defined?(VCR) && e.is_a?(VCR::Errors::UnhandledHTTPRequestError)

          if /404 Not Found/.match? e.message
            @@proxies.push(proxy) unless options[:proxy]
            raise
          end

          if SAFE_ERRORS.match? e.message
            log e.message.to_s, options
          else
            raise
          end

          proxy = nil
          content = nil

          exit if e.instance_of? Interrupt # rubocop:disable Rails/Exit
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
        raise
      end

      exit if e.instance_of? Interrupt # rubocop:disable Rails/Exit
      nil
    end

    def get_via_proxy url, proxy, timeout
      curl_command = %W[
        curl
        --insecure
        -H "User-Agent: #{user_agent(url)}"
        -x "#{proxy}"
        --connect-timeout 5
        --max-time #{timeout}
        #{Shellwords.escape(url)}
      ].join(' ')
      # puts "#{curl_command} START"
      Open3.popen3(curl_command) do |_stdin, stdout, _stderr|
        stdout.read
      end
      # puts "#{curl_command} END" 

      # if proxy.http?
      #   get_open_uri(url, proxy: proxy.to_s, read_timeout: timeout).read
      # else
      #   get_httpx(url, proxy, timeout).read
      # end
    end

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
        OpenURI.open_image url, open_uri_proxy_params(url, params)
      else
        OpenURI.open_uri url, open_uri_proxy_params(url, params)
      end
    end

    def open_uri_proxy_params url, params
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

  def to_s
    "#{protocol}://#{ip}:#{port}"
  end
end
