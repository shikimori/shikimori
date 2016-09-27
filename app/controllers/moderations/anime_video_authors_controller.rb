class Moderations::AnimeVideoAuthorsController < ModerationsController
  load_and_authorize_resource
  before_action :set_title

  def index
    @collection = Rails.cache.fetch cache_key do
      AnimeVideoAuthor.order(:name, :id).to_a
    end
  end

  def edit
  end

  def update
    if @resource.update update_params
      redirect_to moderations_anime_video_authors_url
    else
      render :edit
    end
  end

private

  def update_params
    params.require(:anime_video_author).permit(:name)
  end

  def cache_key
    [
      :anime_video_authors,
      AnimeVideoAuthor.order(:updated_at).last.updated_at,
      AnimeVideoAuthor.last.id,
      AnimeVideoAuthor.count
    ]
  end

  def set_title
    if params[:action] != 'index'
      page_title "Редактирование автора ##{@resource.id}"
      @back_url = moderations_anime_video_authors_url
      breadcrumb i18n_t('page_title'), @back_url
    else
    end
  end
end
