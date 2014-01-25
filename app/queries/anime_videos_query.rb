class AnimeVideosQuery
  PER_PAGE = 40

  def initialize params
    @search = params[:search]
    @page = [params[:page].to_i, 1].max
  end

  def fetch
    @animes ||= AnimeVideoPreviewDecorator
      .decorate_collection Anime.where(id: fetch_ids.map(&:anime_id))
  end

  def fetch_ids
    @anime_ids ||= if @search.blank?
      AnimeVideo
        .select('distinct anime_id')
        .paginate page: @page, per_page: PER_PAGE
    else
      AnimeVideo
        .select('distinct anime_id')
        .joins(:anime)
        .where('name like ? or russian like ?', "%#{@search}%", "%#{@search}%")
        .paginate page: @page, per_page: PER_PAGE
    end
  end
end
