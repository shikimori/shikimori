class AnimeVideosQuery
  PER_PAGE = 40

  def initialize params={}
    @search = params[:search]
    @page = [params[:page].to_i, 1].max
    @query = AnimeVideo.select('distinct anime_id')
    @query_entries = Anime.includes(:anime_videos)
  end

  def search
    unless @search.blank?
      @query = @query
        .joins(:anime)
        .where('name like ? or russian like ?', "%#{@search}%", "%#{@search}%")
    end
    self
  end

  def fetch_ids
    @query
  end

  def fetch_entries
    @query_entries
      .includes(:anime_videos)
      .where(id: @query.map(&:anime_id))
  end

  def order
    @query = @query.order('anime_videos.created_at desc')
    @query_entries = @query_entries.order('anime_videos.created_at desc')
    self
  end

  def page per_page=PER_PAGE
    @query = @query.paginate page: @page, per_page: per_page
    self
  end

  def all
    @query.all
    self
  end
end
