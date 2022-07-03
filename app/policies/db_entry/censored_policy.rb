class DbEntry::CensoredPolicy
  static_facade :censored?, :entry

  ADULT_RATING = Types::Anime::Rating[:rx]
  SUB_ADULT_RATING = Types::Anime::Rating[:r_plus]

  def censored?
    @entry.rating == ADULT_RATING ||
      @entry.genres.any?(&:censored?)
  end

  def self.zzz? entry
    entry.rating_rx? || entry.genres.any?(&:censored?)
  end
end
