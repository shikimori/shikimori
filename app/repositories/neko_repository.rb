class NekoRepository
  include Singleton
  include Enumerable

  CONFIG_FILE = Rails.root.join('config/app/neko_data.yml')

  def each
    collection.each { |rule| yield rule }
  end

  def find neko_id, level
    return Neko::Rule::NO_RULE if neko_id.blank?

    neko_id = neko_id.to_sym
    level = level.to_i

    super() { |rule| rule.neko_id == neko_id && rule.level == level } ||
      Neko::Rule::NO_RULE
  end

  def reset
    @collection = nil
    true
  end

  def cache_key *args
    [
      Digest::MD5.hexdigest(config.to_json),
      Time.zone.today,
      :v4
    ] + args
  end

  def statistics_cache_key *args
    cache_key +
      %i[statistics] +
      PgCacheData.where(key: Achievements::Statistics::CACHE_KEY).pluck(:updated_at) +
      args
  end

private

  def collection
    @collection ||= config
      .map { |raw_rule| Neko::Rule.new raw_rule.to_h }
      .sort_by(&:sort_criteria)
  end

  def config
    @config ||= YAML.load_file CONFIG_FILE, aliases: true
  end
end
