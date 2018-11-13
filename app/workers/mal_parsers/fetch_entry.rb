class MalParsers::FetchEntry
  include Sidekiq::Worker
  sidekiq_options queue: :mal_parsers

  DATA = :data
  PARSERS = {
    anime: {
      DATA => MalParser::Entry::Anime,
      characters: MalParser::Entry::Characters,
      recommendations: MalParser::Entry::Recommendations
    },
    manga: {
      DATA => MalParser::Entry::Manga,
      characters: MalParser::Entry::Characters,
      recommendations: MalParser::Entry::Recommendations
    },
    character: { DATA => MalParser::Entry::Character },
    person: { DATA => MalParser::Entry::Person }
  }
  IMPORTS = {
    anime: DbImport::Anime,
    manga: DbImport::Manga,
    character: DbImport::Character,
    person: DbImport::Person
  }

  TYPES = Types::Coercible::String.enum('anime', 'manga', 'character', 'person')

  def perform id, type
    IMPORTS[type.to_sym].call import_data(id, type)
  rescue InvalidIdError
    entry = TYPES[type].classify.constantize.find_by id: id

    if entry
      entry.update mal_id: nil, imported_at: Time.zone.now
    else
      raise
    end
  rescue *Network::FaradayGet::NET_ERRORS
    self.class.perform_in 5.minutes, id, type
  end

private

  def import_data id, type
    parsers(type).each_with_object({}) do |(parser_kind, parser_klass), memo|
      if parser_kind == DATA
        memo.merge! parser_klass.call(id)
      else
        memo[parser_kind] = parser_klass.call(id, type)
      end
    end
  end

  def parsers type
    PARSERS[TYPES[type].to_sym]
  end
end
