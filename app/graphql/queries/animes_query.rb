class Queries::AnimesQuery < Queries::BaseQuery
  type [Types::AnimeType], null: false

  argument :page, Integer, required: false
  argument :limit, Integer, required: false

  LIMIT = 50

  def resolve(
    page: 1,
    limit: LIMIT
  )
    AnimesCollection::PageQuery
      .call(
        klass: Anime,
        filters: {
          page: page
        },
        user: current_user,
        limit: limit.to_i.clamp(1, LIMIT)
      )
      .collection
  end
end
