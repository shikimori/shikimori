class AnimeVideosQuery
  PER_PAGE = 40

  def initialize adult, params={}
    @search = params[:search]
    @page = [params[:page].to_i, 1].max
    @query = (adult ? AnimeVideo.allowed_xplay : AnimeVideo.allowed_play)
      .select('distinct anime_id, anime_videos.created_at')
    @query_entries = Anime
      .includes(:anime_videos)
  end

  def search
    unless @search.blank?
      @query = @query
        .where('name ilike ? or russian ilike ?', "%#{@search}%", "%#{@search}%")
    end
    self
  end

  def fetch_ids
    @query
  end

  def fetch_entries
    @query_entries
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
    @query.to_a
    self
  end
end
