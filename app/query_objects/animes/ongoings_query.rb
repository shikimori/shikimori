class Animes::OngoingsQuery
  pattr_initialize :is_adult

  def fetch limit
    Anime
      .where(status: :ongoing, kind: :tv)
      .where.not(rating: :g)
      .where.not(id: Anime::EXCLUDED_ONGOINGS)
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
