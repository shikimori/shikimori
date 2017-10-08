class Neko::Repository
  include Singleton
  include Enumerable

  CONFIG_FILE = "#{Rails.root}/config/app/neko_data.yml"

  def each
    data.each { |rule| yield rule }
  end

  def find neko_id, level
    neko_id = neko_id.to_sym
    level = level.to_i

    super() { |rule| rule.neko_id == neko_id && rule.level == level } ||
      Neko::Rule::NO_RULE
  end

private

  def data
    @data ||= read_config
      .map { |raw_rule| Neko::Rule.new raw_rule }
      .sort_by(&:sort_criteria)
  end

  def read_config
    YAML.load_file CONFIG_FILE
  end
end
