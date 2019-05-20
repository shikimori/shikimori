class Moderation::MissingScreenshotsQuery
  prepend ActiveCacher.instance

  LIMIT = 200
  ORDER_SQL = <<~SQL.squish
    (case when #{Anime.table_name}.status='ongoing' then 1 else 2 end),
    #{Anime.table_name}.ranked
  SQL

  ANIME_CONDITION = <<-SQL.squish
    animes.id in (
      select
        animes.id
      from
        animes
      inner join user_rates
        on user_rates.target_id = animes.id
          and user_rates.target_type = 'Anime'
      where
        animes.score > 6.5
        and animes.rating != 'g'
        and animes.rating != 'rx'
        and (
          animes.status = 'ongoing'
          or animes.status = 'released'
        )
        and animes.ranked != 0
      group by
        animes.id
      having
        count(*) > #{Rails.env.test? ? 0 : (User.count / 1000.0).to_i}
    )
  SQL

  def fetch
    Anime
      .joins("left join #{Screenshot.table_name}
        on #{Screenshot.table_name}.anime_id = #{Anime.table_name}.id")
      .group('animes.id')
      .where(screenshots: { id: nil })
      .where(ANIME_CONDITION)
      .having('count(*) = 1')
      .order(Arel.sql(ORDER_SQL))
      .limit(LIMIT)
      .to_a
  end
end
