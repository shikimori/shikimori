class NekoRepository
  include Singleton
  include Enumerable

  CONFIG_FILE = "#{Rails.root}/config/app/neko_data.yml"

  def each
    collection.each { |rule| yield rule }
  end

  def find neko_id, level
    return nil if neko_id.blank?

    neko_id = neko_id.to_sym
    level = level.to_i

    super() { |rule| rule.neko_id == neko_id && rule.level == level } ||
      Neko::Rule::NO_RULE
  end

  def reset
    @collection = nil
    true
  end

  def cache_key
    [Digest::MD5.hexdigest(raw_config), Time.zone.today, :v4]
  end

private

  def collection
    @collection ||= YAML.load(raw_config) # rubocop:disable Security/YAMLLoad
      .map { |raw_rule| Neko::Rule.new raw_rule }
      .sort_by(&:sort_criteria)
  end

  def raw_config
    @raw_config ||= open(CONFIG_FILE).read # rubocop:disable Security/Open
  end
end
