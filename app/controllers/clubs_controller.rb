class ClubsController < ShikimoriController
  load_and_authorize_resource :club, class: Group

  before_action :fetch_resource, if: :resource_id
  before_action :resource_redirect, if: :resource_id
  before_action :set_breadcrumbs, if: :resource_id

  page_title 'Клубы'
  breadcrumb 'Клубы', :clubs_url

  def index
    @page = [params[:page].to_i, 1].max
    @limit = [[params[:limit].to_i, 48].max, 96].min
    @collection, @add_postloader = ClubsQuery.new.postload @page, @limit
  end

  def show
  end

  def new
    page_title 'Новый клуб'

    @resource = @resource.decorate
    @resource.owner = current_user
  end

  def create
    @resource = @resource.decorate

    if @resource.save
      redirect_to edit_club_url(@resource), notice: 'Клуб создан'
    else
      new and render :new
    end
  end

  def edit
    page_title 'Изменение клуба'
  end

  def update
    (params[:kick_ids] || []).each do |user_id|
      @resource.leave User.find(user_id)
    end

    if @resource.update update_params
      @resource.animes = []
      @resource.mangas = []
      @resource.characters = []
      @resource.admins = []
      @resource.banned_users = []
      @resource.update update_params

      redirect_to edit_club_url(@resource), notice: 'Изменения сохранены'
    else
      edit and render :edit
    end
  end

  def members
    page_title 'Участники клуба'
  end

  def comments
    redirect_to club_url(@resource) if @resource.main_thread.comments_count.zero?
    page_title 'Обсуждение клуба'
  end

  def animes
    redirect_to club_url(@resource) if @resource.animes.none?
    page_title 'Аниме клуба'
  end

  def mangas
    redirect_to club_url(@resource) if @resource.mangas.none?
    page_title 'Манга клуба'
  end

  def characters
    redirect_to club_url(@resource) if @resource.characters.none?
    page_title 'Персонажи клуба'
  end

  def images
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
    create_params.except(:owner_id)
  end

  def create_params
    params
      .require(:club)
      .permit(:owner_id, :name, :join_policy, :description, :upload_policy, :display_images,
        :comment_policy, :logo,
        anime_ids: [], manga_ids: [], character_ids: [], admin_ids: [], banned_user_ids: [])
  end
end
