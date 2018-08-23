class DbImport::BannedIds
  include Singleton

  CONFIG_FILE = Rails.root.join('config/app/banned_mal_ids.yml')

  def banned? id, type
    config[type.to_sym].include? id.to_i
  end

  def config
    @config ||= YAML.load_file CONFIG_FILE
  end
end
