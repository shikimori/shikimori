class Queries::MangasQuery < Queries::BaseQuery
  type [Types::MangaType], null: false
  extras [:lookahead]

  LIMIT = 50
  BASIC_PRELOADS = [
    :poster,
    :all_external_links,
    :stats,
    :topic,
    person_roles: {
      character: :poster,
      person: :poster
    }
  ]
  PRELOADS = BASIC_PRELOADS + [{
    related: {
      anime: Queries::AnimesQuery::BASIC_PRELOADS + %i[related],
      manga: BASIC_PRELOADS + %i[related]
    }
  }]

  argument :page, Types::Scalars::PositiveInt, required: false, default_value: 1
  argument :limit, Types::Scalars::PositiveInt,
    required: false,
    default_value: 2,
    description: "Maximum #{LIMIT}"
  argument :order, Types::Enums::OrderEnum, required: false, default_value: 'ranked'
  argument :kind, Types::Scalars::Manga::KindString, required: false
  argument :status, Types::Scalars::Manga::StatusString, required: false
  argument :season, Types::Scalars::SeasonString, required: false
  argument :score, Integer,
    required: false,
    description: 'Minimal manga score'
  argument :genre, String,
    required: false,
    description: 'List of comma separated genre ids'
  argument :publisher, String,
    required: false,
    description: 'List of comma separated publisher ids'
  argument :franchise, String,
    required: false,
    description: 'List of comma separated franchises'
  argument :censored, Boolean,
    required: false,
    description: 'Set to `false` to allow hentai, yaoi and yuri'
  argument :mylist, Types::Scalars::MylistString, required: false
  argument :ids, String,
    required: false,
    description: 'List of comma separated ids'
  argument :exclude_ids, String,
    required: false,
    description: 'List of comma separated ids'
  argument :search, String, required: false

  def resolve( # rubocop:disable Metrics/ParameterLists, Metrics/MethodLength
    page:,
    limit:,
    order:,
    lookahead:,
    kind: nil,
    status: nil,
    season: nil,
    score: nil,
    genre: nil,
    publisher: nil,
    franchise: nil,
    censored: nil,
    mylist: nil,
    ids: nil,
    exclude_ids: nil,
    search: nil
  )
    collection = Animes::Query
      .fetch(
        scope: Manga.lazy_preload(*PRELOADS),
        params: {
          page:,
          order:,
          score:,
          kind:,
          status:,
          season:,
          genre:,
          publisher:,
          franchise:,
          censored: to_filter_boolean(censored),
          mylist:,
          ids:,
          exclude_ids:,
          search:
        },
        user: current_user,
        is_mangas_ranobe: true
      )
      .paginate(page, limit.to_i.clamp(1, LIMIT))
      .to_a

    fetch_user_rates collection if lookahead.selects?(:user_rate) && current_user

    collection
  end

private

  def fetch_user_rates collection
    context[:manga_user_rates] = UserRate
      .where(user: current_user)
      .where(target_type: Manga.name)
      .where(target_id: collection.map(&:id))
      .index_by(&:target_id)
  end

  def to_filter_boolean value
    if value == true
      Animes::Filters::Policy::TRUE_STRICT
    elsif value == false
      Animes::Filters::Policy::FALSE_STRICT
    end
  end
end
