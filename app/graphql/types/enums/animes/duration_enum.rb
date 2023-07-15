class Types::Enums::Animes::DurationEnum < GraphQL::Schema::Enum
  I18n.t('animes_collection.menu.anime.duration', locale: :en).each do |key, description|
    value key.to_s, description
    value "NOT_#{key}", "Exclude \"#{description}\""
  end
end
