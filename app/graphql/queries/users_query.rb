class Queries::UsersQuery < Queries::BaseQuery
  type [Types::UserType], null: false

  LIMIT = 50

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
    Users::Query.fetch
      .id(ids)
      .search(search)
      .paginate(page, limit.to_i.clamp(1, LIMIT))
  end
end
