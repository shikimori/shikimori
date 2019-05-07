class Moderations::AnimeVideoAuthorsController < ModerationsController # rubocop:disable ClassLength
  load_and_authorize_resource

  def index
    @anime = Anime.find params[:anime_id] if params[:anime_id].present?
    @limit = (params[:limit] || 100).to_i

    @collection = QueryObjectBase.new(authors_scope).paginate(@page, @limit)
  end

  def none # rubocop:disable AbcSize
    og page_title: 'Видео без авторов'
    @back_url = moderations_anime_video_authors_url
    breadcrumb i18n_t('page_title'), @back_url

    if params[:anime_id]
      @anime = Anime.find params[:anime_id]

      @scope = AnimeVideo
        .where(anime_video_author_id: nil)
        .where(anime_id: params[:anime_id])
        .order(:episode, :kind, :id)

      @scope.where! kind: params[:kind] if params[:kind].present?
    end
  end

  def edit # rubocop:disable AbcSize
    og page_title: "Редактирование автора ##{@resource.id}"
    og page_title: @resource.name
    @back_url = moderations_anime_video_authors_url
    breadcrumb i18n_t('page_title'), @back_url

    @scope = @resource.anime_videos
      .order(:episode, :kind, :id)
      .includes(:anime)

    if params[:anime_id].present?
      @anime = Anime.find params[:anime_id]
      @scope.where! anime_id: params[:anime_id]
    end

    @scope.where! kind: params[:kind] if params[:kind].present?
  end

  def update
    if update_params.key? :is_verified
      @resource.update is_verified: update_params[:is_verified]
    end

    if update_params.key? :name
      rename_author

      if @resource.persisted?
        redirect_to edit_moderations_anime_video_author_url(@resource)
      else
        redirect_to moderations_anime_video_authors_url
      end
    else
      redirect_back fallback_location: moderations_anime_video_authors_url
    end
  end

private

  def authors_scope
    scope =
      if @anime
        AnimeVideoAuthor.where(id: filter_authors(@anime))
      else
        AnimeVideoAuthor.where(
          id: videos_scope.select('distinct(anime_video_author_id)')
        )
      end

    if params[:is_verified]
      scope.where! is_verified: params[:is_verified] == 'true'
    end

    if params[:search].present?
      scope.where! 'name ilike ?', '%' + params[:search] + '%'
    end

    scope.order(:name, :id)
  end

  def rename_author # rubocop:disable AbcSize
    if params[:anime_id].present? || params[:kind].present?
      AnimeVideoAuthor::SplitRename.call(
        model: @resource,
        new_name: update_params[:name],
        anime_id: (params[:anime_id] if params[:anime_id].present?),
        kind: (params[:kind] if params[:kind].present?)
      )
    else
      AnimeVideoAuthor::Rename.call @resource, update_params[:name]
    end
  end

  def update_params
    params.require(:anime_video_author).permit(:name, :is_verified, :anime_id)
  end

  def filter_authors anime
    scope = anime.anime_videos
    scope = scope.available if params[:broken_videos] == 'false'

    scope
      .except(:order)
      .distinct
      .pluck(:anime_video_author_id)
      .compact
  end

  def videos_scope
    if params[:broken_videos] == 'false'
      AnimeVideo.available
    else
      AnimeVideo.all
    end
  end

  def cache_key
    [
      :anime_video_authors,
      AnimeVideoAuthor.order(:updated_at).last.updated_at,
      AnimeVideoAuthor.last.id,
      AnimeVideoAuthor.count,
      params[:anime_id]
    ]
  end
end
