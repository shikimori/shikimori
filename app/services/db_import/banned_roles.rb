class DbImport::BannedRoles
  include Singleton

  CONFIG_FILE = Rails.root.join('config/app/banned_mal_roles.yml')

  def banned? anime_id: nil, manga_id: nil, character_id: nil, person_id: nil
    config.include?({
      'anime_id' => anime_id,
      'manga_id' => manga_id,
      'character_id' => character_id,
      'person_id' => person_id
    }.compact)
  end

  def config
    @config ||= YAML.load_file CONFIG_FILE
  end
end
