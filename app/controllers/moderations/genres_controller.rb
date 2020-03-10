class Moderations::GenresController < ModerationsController
  skip_before_action :authenticate_user!, only: %i[tooltip]
  load_and_authorize_resource
  before_action :set_breadcrumbs, except: %i[tooltip]

  def index
    @collection = @collection.order(:kind, :position, :name)
  end

  def edit
  end

  def update
    version = Versioneers::FieldsVersioneer
      .new(@resource)
      .postmoderate(
        genre_params.is_a?(Hash) ? genre_params : genre_params.to_unsafe_h,
        current_user,
        ''
      )

    if version.persisted?
      redirect_to moderations_genres_url
    else
      redirect_back(
        fallback_location: moderations_genre_url(@resource),
        alert: @version.errors[:base]&.dig(0) || i18n_t('no_changes')
      )
    end
  end

  def tooltip
    og noindex: true, nofollow: true
  end

private

  def genre_params
    if current_user.admin?
      params.require(:genre).permit(:name, :russian, :position, :seo, :description)
    else
      params.require(:genre).permit(:description)
    end
  end

  def set_breadcrumbs
    og page_title: t('.genres')
    og page_title: "#{@resource.name} / #{@resource.russian}" if @resource

    breadcrumb t('.genres'), moderations_genres_url if @resource
  end
end
