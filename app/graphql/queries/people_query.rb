class Queries::PeopleQuery < Queries::BaseQuery
  type [Types::PersonType], null: false

  argument :page, Integer, required: false, default_value: 1
  argument :limit, Integer, required: false, default_value: 2
  argument :ids, [ID], required: false
  argument :search, String, required: false
  argument :is_seyu, Boolean, required: false
  argument :is_producer, Boolean, required: false
  argument :is_mangaka, Boolean, required: false

  LIMIT = 50

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
      .fetch(is_producer: is_producer, is_mangaka: is_mangaka, is_seyu: is_seyu)
      .lazy_preload(:poster)
      .search(search, is_producer: is_producer, is_mangaka: is_mangaka, is_seyu: is_seyu)
      .by_id(ids)
      .paginate(page, limit.to_i.clamp(1, LIMIT))
  end
end
