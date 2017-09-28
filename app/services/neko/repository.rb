class Neko::Repository
  include Singleton
  include Enumerable

  CONFIG_FILE = "#{Rails.root}/config/app/neko_data.yml"

  def each
    data.each { |rule| yield rule }
  end

  def find neko_id, level
    neko_id = Types::Achievement::NekoId[neko_id]
    level = level.to_i

    super() { |rule| rule.neko_id == neko_id && rule.level == level }
  end

private

  def data
    @data ||= read_config.map do |raw_rule|
      Neko::Rule.new raw_rule
    end
  end

  def read_config
    YAML.load_file CONFIG_FILE
  end
end
