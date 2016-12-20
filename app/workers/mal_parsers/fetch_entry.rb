class MalParsers::FetchEntry
  include Sidekiq::Worker
  sidekiq_options(
    unique: :until_executed,
    queue: :mal_parsers
  )

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
    character: { DATA => MalParser::Entry::Anime },
    person: { DATA => MalParser::Entry::Person }
  }
  IMPORTS = {
    anime: Import::Anime,
    manga: Import::Manga,
    character: Import::Character,
    person: Import::Person
  }

  def perform id, type
    import_data = PARSERS[type.to_sym]
      .each_with_object({}) do |(parser_kind, parser_klass), memo|
        memo[parser_kind] =
          if parser_kind == DATA
            parser_klass.call id
          else
            parser_klass.call id, type
         end
      end

    IMPORTS[type.to_sym].call import_data
  end
end
