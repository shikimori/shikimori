class Moderation::MissingScreenshotsQuery
  prepend ActiveCacher.instance

  LIMIT = 200
  ORDER_SQL = <<~SQL.squish
    (case when #{Anime.table_name}.status='ongoing' then 1 else 2 end),
    #{Anime.table_name}.ranked
  SQL

  def fetch
    Anime
      .joins("left join #{Screenshot.table_name}
        on #{Screenshot.table_name}.anime_id = #{Anime.table_name}.id")
      .group('animes.id')
      .where(screenshots: { id: nil })
      .where(Moderation::MissingVideosQuery::ANIME_CONDITION)
      .having('count(*) = 1')
      .order(Arel.sql(ORDER_SQL))
      .limit(LIMIT)
      .to_a
  end
end
