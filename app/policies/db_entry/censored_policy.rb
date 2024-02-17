class DbEntry::CensoredPolicy
  static_facade :censored?, :entry

  ADULT_RATING = Types::Anime::Rating[:rx]
  SUB_ADULT_RATING = Types::Anime::Rating[:r_plus]

  def censored?
    @entry.rating == ADULT_RATING ||
      @entry.genres_v2.any? { |genre| genre.censored? || genre.banned? || genre.ai? }
  end
end
