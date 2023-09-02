# базовых класс для всяких парсеров
class SiteParserWithCache
  # кеш по конкретному парсеру
  attr_accessor :cache
  # путь к кешу
  attr_accessor :cache_path

  # конструктор
  def initialize
    @mutex = Mutex.new

    @cache_name = self.class.name.to_underscore
    @cache_path = '%s/.%s.yml' % [ENV['HOME'], @cache_name]
    @cache_tmp_path = '/tmp/.%s.yml.tmp' % @cache_name
    @proxy_log = false
    @no_proxy = false

    load_cache
  end

  # загрузка кеша
  def load_cache
    @cache = self.class.load_cache(@cache_name, @cache_path)
  end

  # загрузка кеша из определённого файла
  def self.load_cache(cache_name, cache_path)
    cache = nil
    begin
      %x(cp #{cache_path} /tmp/.#{cache_name}.#{DateTime.now.to_s}) if File.exist?(cache_path)
      File.open(cache_path, "rb") { |f| cache = YAML.unsafe_load(f.read) } if File.exist?(cache_path)
    rescue StandardError => e
      print "%s\n%s\n" % [e.message, e.backtrace.join("\n")]
    ensure
      cache = {} unless cache
    end
    cache
  end

  # сохранение кеша
  def save_cache
    begin
      @mutex.synchronize do
        data = YAML.dump(@cache)
        File.open(@cache_tmp_path, "wb") { |f| f.write(data) }
        %x(cp #{@cache_tmp_path} #{@cache_path})
      end
    rescue StandardError => e
      print "%s\n%s\n" % [e.message, e.backtrace.join("\n")]
      @mutex.synchronize do
        data = YAML.dump(@cache)
        File.open(@cache_tmp_path, "wb") {|f| f.write(data) }
        %x(cp #{@cache_tmp_path} #{@cache_path})
      end
      if e.class == Interrupt
        exit
      end
      raise e
    end
    print "cache saved\n" if Rails.env != 'test'
  end

  # вырезание всяких мусорных символов, чтобы легче было матчить
  def self.fix_name name
    name = name.force_encoding('utf-8') if name && name.encoding.name == "ASCII-8BIT"
    name ? name.downcase.gsub(/[-:,.~"]/, '').gsub(/`/, '\'').gsub(/  +|　/, ' ').strip : nil
  end

  def fix_name name
    self.class.fix_name(name)
  end

private

  # загрузка страницы через прокси
  def get url, required_text = @required_text
    Proxy.get(
      url,
      timeout: 30,
      required_text: required_text,
      no_proxy: Rails.env.test? ? true : @no_proxy,
      log: @proxy_log
    )
  end
end
