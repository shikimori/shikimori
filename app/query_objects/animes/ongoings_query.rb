class Animes::OngoingsQuery
  pattr_initialize :is_adult

  EXCLUDED_ONGOING_IDS = %w[
    18941 1960 2406 4459 1199 32353 6149 966 8687 8336 10506
  ]

  def fetch limit
    Anime
      .where(status: :ongoing, kind: :tv)
      .where.not(rating: :g)
      .where.not(id: EXCLUDED_ONGOING_IDS)
      .where('score < 9.9')
      .where(adult_condition)
      .order(
        Animes::Filters::OrderBy.arel_sql(
          term: :ranked,
          scope: Anime
        )
      )
      .limit(limit)
  end

private

  def adult_condition
    if is_adult
      AnimeVideo::XPLAY_CONDITION
    else
      { is_censored: false }
    end
  end
end
