class Queries::ContestsQuery < Queries::BaseQuery
  type [Types::ContestType], null: false

  LIMIT = 10

  argument :page, Integer, required: false, default_value: 1
  argument :limit, Integer,
    required: false,
    default_value: 2,
    description: "Maximum #{LIMIT}"
  argument :ids, [ID], required: false
  complexity ->(_ctx, args, child_complexity) {
    args[:limit] * child_complexity
  }

  def resolve(
    page:,
    limit:,
    ids: nil
  )
    Contests::Query
      .fetch
      .lazy_preload(rounds: { matches: %i[left right] })
      .by_id(ids)
      .paginate(page, limit.to_i.clamp(1, LIMIT))
  end
end
