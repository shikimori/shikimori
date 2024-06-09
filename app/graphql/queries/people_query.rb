class Queries::PeopleQuery < Queries::BaseQuery
  type [Types::PersonType], null: false

  LIMIT = 50
  PRELOADS = %i[
    poster
    topic
  ]

  argument :page, Types::Scalars::PositiveInt, required: false, default_value: 1
  argument :limit, Types::Scalars::PositiveInt,
    required: false,
    default_value: 2,
    description: "Maximum #{LIMIT}"
  argument :ids, [ID], required: false
  argument :search, String, required: false
  argument :is_seyu, Boolean, required: false
  argument :is_producer, Boolean, required: false
  argument :is_mangaka, Boolean, required: false

  def resolve( # rubocop:disable Metrics/ParameterLists
    page:,
    limit:,
    ids: nil,
    search: nil,
    is_seyu: nil,
    is_producer: nil,
    is_mangaka: nil
  )
    People::Query
      .fetch(is_producer:, is_mangaka:, is_seyu:)
      .lazy_preload(*PRELOADS)
      .search(search, is_producer:, is_mangaka:, is_seyu:)
      .by_id(ids)
      .paginate(page, limit.to_i.clamp(1, LIMIT))
  end
end
