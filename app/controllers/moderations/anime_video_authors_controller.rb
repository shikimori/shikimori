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
          AnimeVideoAuthor.where(
            id: AnimeVideo.available.select('distinct(anime_video_author_id)')
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
  end
  # rubocop:enable AbcSize
  # rubocop:enable MethodLength

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

  # rubocop:disable MethodLength
  # rubocop:disable AbcSize
  def edit
    page_title "Редактирование автора ##{@resource.id}"
    page_title @resource.name
    @back_url = moderations_anime_video_authors_url
    breadcrumb i18n_t('page_title'), @back_url

    @scope = @resource.anime_videos
      .order(:episode, :kind, :id)
      .includes(:anime)

    if params[:anime_id].present?
      @anime = Anime.find params[:anime_id]
      @scope.where! anime_id: params[:anime_id]

      if params[:kind].present?
        @scope.where! kind: params[:kind]
      end
    end
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
  # rubocop:enable AbcSize
  # rubocop:enable MethodLength

private

  def rename_author
    if params[:anime_id].present?
      AnimeVideoAuthor::SplitRename.call(
        model: @resource,
        new_name: update_params[:name],
        anime_id: params[:anime_id],
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
    anime.anime_videos
      .available
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
