# frozen_string_literal: true

class ClubsController < ShikimoriController
  load_and_authorize_resource :club, except: :index

  before_action { page_title i18n_i('Club', :other) }

  before_action { page_title i18n_i('Club', :other) }

  before_action :fetch_resource, if: :resource_id
  before_action :resource_redirect, if: :resource_id
  before_action :restrict_domain, except: [:index, :create, :new]

  before_action :set_breadcrumbs

  def index
    noindex
    @page = [params[:page].to_i, 1].max
    @limit = [[params[:limit].to_i, 48].max, 96].min

    clubs_query = ClubsQuery.new(locale_from_domain)

    @favourite = clubs_query.favourite if @page == 1
    @collection, @add_postloader = clubs_query.postload @page, @limit
  end

  def show
    noindex
  end

  def new
    page_title i18n_t('new_club')
    @resource = @resource.decorate
  end

  def create
    @resource = Club::Create.call resource_params, locale_from_domain

    if @resource.errors.blank?
      redirect_to edit_club_url(@resource), notice: i18n_t('club_created')
    else
      new
      render :new
    end
  end

  def edit
    page_title i18n_t('edit_club')
  end

  def update
    Club::Update.call @resource, params[:kick_ids], update_params

    if @resource.errors.blank?
      redirect_to edit_club_url(@resource), notice: t('changes_saved')
    else
      flash[:alert] = t 'changes_not_saved'
      edit
      render :edit
    end
  end

  def members
    noindex
    page_title i18n_t('club_members')
  end

  def animes
    noindex
    redirect_to club_url(@resource) if @resource.animes.none?
    page_title i18n_t('club_anime')
  end

  def mangas
    noindex
    redirect_to club_url(@resource) if @resource.mangas.none?
    page_title i18n_t('club_manga')
  end

  def characters
    noindex
    redirect_to club_url(@resource) if @resource.characters.none?
    page_title i18n_t('club_characters')
  end

  def images
    noindex
    page_title i18n_t('club_images')
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
      redirect_to club_url(@resource), notice: t('image_uploaded')
    end
  end

private

  def restrict_domain
    raise ActiveRecord::RecordNotFound if @resource.locale != locale_from_domain
  end

  def resource_klass
    Club
  end

  def set_breadcrumbs
    breadcrumb i18n_i('Club', :other), clubs_url

    if resource_id.present? && params[:action] != 'show'
      breadcrumb @resource.name, club_url(@resource)
    end
  end

  def resource_params
    params
      .require(:club)
      .permit(
        :owner_id,
        :name,
        :join_policy,
        :description,
        :upload_policy,
        :display_images,
        :comment_policy,
        :logo,
        :is_censored,
        anime_ids: [],
        manga_ids: [],
        character_ids: [],
        admin_ids: [],
        banned_user_ids: []
      )
  end

  def update_params
    resource_params.except(:owner_id)
  end
end
