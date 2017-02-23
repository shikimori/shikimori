class Clubs::ClubPagesController < ClubsController
  load_and_authorize_resource :club
  load_and_authorize_resource

  CREATE_PARAMS = [:club_id, :parent_page_id, :name, :layout, :text]
  UPDATE_PARAMS = CREATE_PARAMS - [:club_id]

  before_action :prepare_form, except: [:show]

  def show
    page_title @resource.name
    breadcrumb @club.name, @club.url

    @resource.parents.each do |club_page|
      breadcrumb club_page.name, club_club_page_path(@club, club_page)
    end
  end

  def new
    page_title i18n_t('new.title')
    render 'form'
  end

  def create
    if @resource.save
      redirect_to(
        edit_club_club_page_path(@resource.club, @resource),
        notice: t('changes_saved')
      )
    else
      page_title @resource.name
      flash[:alert] = t('changes_not_saved')
      render 'form'
    end
  end

  def edit
    page_title @resource.name
    render 'form'
  end

  def update
    if @resource.update update_params
      redirect_to(
        edit_club_club_page_path(@resource.club, @resource),
        notice: t('changes_saved')
      )
    else
      page_title @resource.name
      flash[:alert] = t('changes_not_saved')
      render 'form'
    end
  end

  def destroy
    @resource.destroy!
    redirect_to @back_url, notice: i18n_t('destroy.success')
  end

  def up
    @resource.move_higher
    redirect_to_back_or_to edit_club_club_page_path(@resource.club, @resource)
  end

  def down
    @resource.move_lower
    redirect_to_back_or_to edit_club_club_page_path(@resource.club, @resource)
  end

private

  def prepare_form
    @page = 'pages'
    @back_url = edit_club_url @club, page: @page
    breadcrumb i18n_i('Page', :other), @back_url
  end

  def create_params
    params.require(:club_page).permit(*CREATE_PARAMS)
  end
  alias new_params create_params

  def update_params
    params.require(:club_page).permit(*UPDATE_PARAMS)
  end
end
