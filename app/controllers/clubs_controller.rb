class ClubsController < ShikimoriController
  load_and_authorize_resource :group, only: [:new, :edit, :create, :update]

  #before_action :authenticate_user!, only: [:new, :create, :update]

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
    @resource ||= Group.new.decorate
  end

  def create
    if @resource.save
      redirect_to edit_club_url(@resource)
    else
      new and render :new
    end
  end

  def edit
    page_title 'Редактирование клуба'
  end

  def update
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

private
  def resource_klass
    Group
  end

  def set_breadcrumbs
    breadcrumb @resource.name, club_url(@resource) if params[:action] != 'show'
  end
end
