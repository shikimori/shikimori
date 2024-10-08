class Queries::CharactersQuery < Queries::BaseQuery
  type [Types::CharacterType], null: false

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

  def resolve(
    page:,
    limit:,
    ids: nil,
    search: nil
  )
    Characters::Query
      .fetch
      .lazy_preload(*PRELOADS)
      .search(search)
      .by_id(ids)
      .paginate(page, limit.to_i.clamp(1, LIMIT))
  end
end
