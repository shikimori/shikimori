class Moderations::AnimeVideoAuthorsController < ModerationsController
  load_and_authorize_resource

  def index
    @anime = Anime.find_by id: params[:anime_id] if params[:anime_id]

    @collection = Rails.cache.fetch cache_key do
      scope =
        if @anime
          AnimeVideoAuthor.where(id: filter_authors(@anime))
        else
          AnimeVideoAuthor.all
        end

      scope.order(:name, :id).to_a
    end
  end

  def edit
    page_title "Редактирование автора ##{@resource.id}"
    @back_url = moderations_anime_video_authors_url
    breadcrumb i18n_t('page_title'), @back_url
  end

  def update
    AnimeVideoAuthor::Rename.call @resource, update_params[:name]
    redirect_to moderations_anime_video_authors_url
  end

private

  def update_params
    params.require(:anime_video_author).permit(:name)
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
