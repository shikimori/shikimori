class Animes::Filters::Policy
  class << self
    FALSY = [false, 'false', 0, '0']
    ADULT_RATING_REGEXP =
      /(?:\A|,)(?:#{Types::Anime::Rating[:rx]}|#{Types::Anime::Rating[:r_plus]})\b/
    MUSIC_REGEXP = /(?:\A|,)#{Types::Anime::Kind[:music]}\b/

    def exclude_hentai? params
      return false if forbid_filtering? params

      !adult_rating?(params[:rating])
    end

    def exclude_music? params
      !music_kind?(params[:kind]) && !forbid_filtering?(params)
    end

  private

    def adult_rating? rating
      rating == Types::Anime::Rating[:rx] ||
        rating == Types::Anime::Rating[:r_plus] ||
        rating.is_a?(String) && rating.match?(ADULT_RATING_REGEXP)
    end

    def music_kind? kind
      kind == Types::Anime::Kind[:music] ||
        kind.is_a?(String) && kind.match?(MUSIC_REGEXP)
    end

    def forbid_filtering? params # rubocop:disable all
      FALSY.include?(params[:censored]) ||
        params[:achievement].present? ||
        params[:franchise].present? ||
        params[:ids].present? ||
        params[:mylist].present? ||
        params[:publisher].present? ||
        params[:studio].present?
    end
  end
end

  # def censored!
  #   if @genre
  #     genres = bang_split(@genre.split(','), true).each { |_k, v| v.flatten! }
  #   end
  #   ratings = bang_split @rating.split(',') if @rating
  #
  #   rx = ratings && ratings[:include].include?(Anime::ADULT_RATING)
  #   hentai = genres && (genres[:include] & Genre::HENTAI_IDS).any?
  #   yaoi = genres && (genres[:include] & Genre::YAOI_IDS).any?
  #   yuri = genres && (genres[:include] & Genre::YURI_IDS).any?
  #
  #   return if do_not_censore?
  #   return if rx || hentai || yaoi || yuri
