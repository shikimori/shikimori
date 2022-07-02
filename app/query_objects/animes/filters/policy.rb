class Animes::Filters::Policy
  class << self
    FALSY = [false, 'false', 0, '0']
    TRULY = [true, 'true', 1, '1']
    ADULT_RATING_REGEXP =
      /(?:\A|,)(?:#{Types::Anime::Rating[:rx]}|#{Types::Anime::Rating[:r_plus]})\b/
    MUSIC_REGEXP = /(?:\A|,)#{Types::Anime::Kind[:music]}\b/
    DOUJIN_REGEXP = /(?:\A|,)#{Types::Manga::Kind[:doujin]}\b/

    HENTAI_GENRES_IDS = Genre::CENSORED_IDS + Genre::DOUJINSHI_IDS
    HENTAI_GENRES_REGEXP = /(?:\A|,)(?:#{HENTAI_GENRES_IDS.join '|'})\b/

    def exclude_hentai? params
      return false if forbid_filtering? params

      !adult_rating?(params[:rating]) &&
        !hentai_genre?(params[:genre]) &&
        !doujin_kind?(params[:kind])
    end

    def exclude_music? params
      !music_kind?(params[:kind]) && !forbid_filtering?(params)
    end

  private

    def adult_rating? rating
      rating == Types::Anime::Rating[:rx] ||
        rating == Types::Anime::Rating[:r_plus] ||
        (rating.is_a?(String) && rating.match?(ADULT_RATING_REGEXP))
    end

    def hentai_genre? genre
      genre.is_a?(String) && genre.match?(HENTAI_GENRES_REGEXP)
    end

    def music_kind? kind
      kind == Types::Anime::Kind[:music] ||
        (kind.is_a?(String) && kind.match?(MUSIC_REGEXP))
    end

    def doujin_kind? kind
      kind == Types::Manga::Kind[:doujin] ||
        (kind.is_a?(String) && kind.match?(DOUJIN_REGEXP))
    end

    def forbid_filtering? params # rubocop:disable all
      return false if TRULY.include?(params[:censored])

      FALSY.include?(params[:censored]) ||
        params[:achievement].present? ||
        params[:ids].present? ||
        present_and_not_all_negatives?(params[:franchise]) ||
        present_and_not_all_negatives?(params[:mylist]) ||
        present_and_not_all_negatives?(params[:publisher]) ||
        present_and_not_all_negatives?(params[:studio]) ||
        params[:search].present? ||
        params[:q].present? ||
        params[:phrase].present?
    end

    def present_and_not_all_negatives? value
      value.present? && value.count('!') != (value.count(',') + 1)
    end
  end
end
