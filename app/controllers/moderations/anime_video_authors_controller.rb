class Moderations::AnimeVideoAuthorsController < ModerationsController
  load_and_authorize_resource

  # rubocop:disable MethodLength
  # rubocop:disable AbcSize
  def index
    @anime = Anime.find_by id: params[:anime_id] if params[:anime_id]

    @collection = postload_paginate(params[:page], 100) do
      scope =
        if @anime
          AnimeVideoAuthor.where(id: filter_authors(@anime))
        else
          AnimeVideoAuthor.all
        end

      if params[:is_verified]
        scope.where! is_verified: params[:is_verified] == 'true'
      end

      if params[:search].present?
        scope.where! 'name ilike ?', '%' + params[:search] + '%'
      end

      scope.order(:name, :id)
    end
  end
  # rubocop:enable AbcSize
  # rubocop:enable MethodLength

  def show
    page_title @resource.name
    @back_url = moderations_anime_video_authors_url
    breadcrumb i18n_t('page_title'), @back_url

    @scope = @resource.anime_videos
      .order(:episode, :kind, :id)
      .includes(:anime)
  end

  def none
    page_title 'Видео без авторов'
    @back_url = moderations_anime_video_authors_url
    breadcrumb i18n_t('page_title'), @back_url

    @scope = AnimeVideo
      .where(anime_video_author_id: nil)
      .order(:anime_id, :episode, :kind, :id)
      .includes(:anime)
      .limit(1000)
  end

  # rubocop:disable AbcSize
  def edit
    page_title "Редактирование автора ##{@resource.id}"
    page_title @resource.name

    breadcrumb i18n_t('page_title'), moderations_anime_video_authors_url
    breadcrumb @resource.name, moderations_anime_video_author_url(@resource)

    @back_url = moderations_anime_video_author_url(@resource)

    if @resource.anime_videos.count < 100
      @scope = @resource.anime_videos
        .order(:episode, :kind, :id)
        .includes(:anime)
    end
  end

  # rubocop:disable MethodLength
  def update
    @resource.update is_verified: update_params[:is_verified]

    if update_params.key? :name
      if update_params[:anime_id]
        AnimeVideoAuthor::SplitRename.call(
          model: @resource,
          new_name: update_params[:name],
          anime_id: update_params[:anime_id]
        )
      else
        AnimeVideoAuthor::Rename.call @resource, update_params[:name]
      end

      redirect_to moderations_anime_video_authors_url
    else
      redirect_back fallback_location: moderations_anime_video_authors_url
    end
  end
  # rubocop:enable AbcSize

private

  def update_params
    params.require(:anime_video_author).permit(:name, :is_verified, :anime_id)
  end

  def filter_authors anime
    anime.anime_videos
      .except(:order)
      .distinct
      .pluck(:anime_video_author_id)
      .compact
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
