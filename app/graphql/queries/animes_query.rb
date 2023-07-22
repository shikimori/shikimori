class Queries::AnimesQuery < Queries::BaseQuery
  type [Types::AnimeType], null: false

  argument :page, Integer, required: false, default_value: 1
  argument :limit, Integer, required: false, default_value: 2
  argument :order, Types::Enums::OrderEnum, required: false, default_value: 'ranked'
  argument :kind, Types::Scalars::KindString, required: false
  argument :status, Types::Scalars::StatusString, required: false
  argument :season, Types::Scalars::SeasonString, required: false
  argument :score, Integer,
    required: false,
    description: 'Minimal anime score'
  argument :duration, Types::Scalars::DurationString, required: false
  argument :rating, Types::Scalars::RatingString, required: false
  argument :genre, String,
    required: false,
    description: 'List of comma separated genre ids'
  argument :studio, String,
    required: false,
    description: 'List of comma separated studio ids'
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

  LIMIT = 50

  def resolve( # rubocop:disable Metrics/ParameterLists, Metrics/MethodLength
    page:,
    limit:,
    order:,
    kind: nil,
    status: nil,
    season: nil,
    score: nil,
    duration: nil,
    rating: nil,
    genre: nil,
    studio: nil,
    franchise: nil,
    censored: nil,
    mylist: nil,
    ids: nil,
    exclude_ids: nil,
    search: nil
  )
    AnimesCollection::PageQuery
      .call(
        klass: Anime,
        filters: {
          page: page,
          order: order,
          score: score,
          kind: kind,
          status: status,
          season: season,
          duration: duration,
          rating: rating,
          genre: genre,
          studio: studio,
          franchise: franchise,
          censored: censored,
          mylist: mylist,
          ids: ids,
          exclude_ids: exclude_ids,
          search: search
        },
        user: current_user,
        limit: limit.to_i.clamp(1, LIMIT)
      )
      .collection
  end
end
