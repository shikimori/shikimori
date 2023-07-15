class Queries::AnimesQuery < Queries::BaseQuery
  type [Types::AnimeType], null: false

  def resolve
    Animes::Query.fetch(
      scope: Anime.all,
      params: {},
      user: @user
    ).to_a
  end
end
