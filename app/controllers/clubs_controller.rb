class ClubsController < ShikimoriController
  load_and_authorize_resource :club, class: Group

  before_action :fetch_resource, if: :resource_id
  before_action :resource_redirect, if: :resource_id
  before_action :set_breadcrumbs, if: :resource_id

  page_title 'Клубы'
  breadcrumb 'Клубы', :clubs_url

  def index
    noindex
    @page = [params[:page].to_i, 1].max
    @limit = [[params[:limit].to_i, 48].max, 96].min
    @collection, @add_postloader = ClubsQuery.new.postload @page, @limit
  end

  def show
    noindex
  end

  def new
    page_title 'Новый клуб'
    @resource = @resource.decorate
  end

  def create
    @resource = @resource.decorate

    if @resource.save
      redirect_to edit_club_url(@resource), notice: 'Клуб создан'
    else
      new
      render :new
    end
  end

  def edit
    page_title 'Изменение клуба'
  end

  def update
    (params[:kick_ids] || []).each do |user_id|
      @resource.leave User.find(user_id)
    end

    if update_club(@resource, update_params)
      redirect_to edit_club_url(@resource), notice: 'Изменения сохранены'
    else
      flash[:alert] = 'Изменения не сохранены!'
      edit
      render :edit
    end
  end

  def members
    noindex
    page_title 'Участники клуба'
  end

  # TODO: удалить после 05.2015
  def comments
    noindex
    redirect_to UrlGenerator.instance.topic_url(@resource.thread), status: 301
  end

  def animes
    noindex
    redirect_to club_url(@resource) if @resource.animes.none?
    page_title 'Аниме клуба'
  end

  def mangas
    noindex
    redirect_to club_url(@resource) if @resource.mangas.none?
    page_title 'Манга клуба'
  end

  def characters
    noindex
    redirect_to club_url(@resource) if @resource.characters.none?
    page_title 'Персонажи клуба'
  end

  def images
    noindex
    page_title 'Картинки клуба'
  end

  def upload
    image = Image.create!(
      owner: @resource,
      uploader: current_user,
      image: params[:image]
    )

    if request.xhr?
      render json: {
        html: render_to_string(partial: 'images/image', object: image, locals: { rel: 'club' }, formats: :html)
      }
    else
      redirect_to club_url(@resource), notice: 'Изображение загружено'
    end
  end

private
  def resource_klass
    Group
  end

  def set_breadcrumbs
    breadcrumb @resource.name, club_url(@resource) if params[:action] != 'show'
  end

  def update_params
    resource_params.except(:owner_id)
  end

  def resource_params
    params
      .require(:club)
      .permit(:owner_id, :name, :join_policy, :description, :upload_policy, :display_images,
        :comment_policy, :logo,
        anime_ids: [], manga_ids: [], character_ids: [], admin_ids: [], banned_user_ids: [])
  end

  def update_club resource, update_params
    Retryable.retryable tries: 2, on: [PG::UniqueViolation], sleep: 1 do
      Group.transaction do
        resource.animes = []
        resource.mangas = []
        resource.characters = []
        resource.banned_users = []

        resource.member_roles.where(role: 'admin').destroy_all
        resource.member_roles.where(user_id: params[:club][:admin_ids]).destroy_all

        resource.update update_params
      end
    end
  end
end
