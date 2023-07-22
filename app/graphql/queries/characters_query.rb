class Queries::CharactersQuery < Queries::BaseQuery
  type [Types::CharacterType], null: false

  argument :page, Integer, required: false, default_value: 1
  argument :limit, Integer, required: false, default_value: 2
  argument :ids, [ID], required: false
  argument :search, String, required: false

  LIMIT = 50

  def resolve(
    page:,
    limit:,
    ids: nil,
    search: nil
  )
    Characters::Query
      .fetch
      .search(search)
      .by_id(ids)
      .paginate(page, limit.to_i.clamp(1, LIMIT))
  end
end
