class Animes::OngoingsQuery
  pattr_initialize :is_adult

  def fetch limit
    Anime
      .where(status: :ongoing, kind: :tv)
      .where.not(rating: :g, id: Anime::EXCLUDED_ONGOINGS)
      .where('score < 9.9')
      .where(adult_condition)
      .order(AniMangaQuery.order_sql('ranked', Anime))
      .limit(limit)
  end

private

  def adult_condition
    if is_adult
      AnimeVideo::XPLAY_CONDITION
    else
      { censored: false }
    end
  end
end
