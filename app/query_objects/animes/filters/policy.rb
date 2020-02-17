class Animes::Filters::Policy
  def self.exclude_hentai? params
    true
  end

  def self.exclude_music? params
    is_music = params[:kind].is_a?(String) && params[:kind].match?(/(\A|,)music/) ||
      params[:kind] == Types::Anime::Kind[:music]

    !is_music
    #   unless @kind.match?(/music/) || do_not_censore?
    #     @query = @query.where("#{table_name}.kind != ?", :music)
    #   end
  end
end

  # def do_not_censore?
  #   [false, 'false'].include?(@params[:censored]) ||
  #     mylist? || userlist? ||
  #     @franchise.present? ||
  #     @achievement.present? ||
  #     @studio.present? ||
  #     @ids.present?
  # end
  #
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
  #   return if @publisher || @studio
  #

