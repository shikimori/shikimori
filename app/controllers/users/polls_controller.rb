class Users::PollsController < ProfilesController
  load_and_authorize_resource

  before_action do
    @back_url = profile_url @user
    page_title i18n_i('Poll', :other)

    if params[:action] != 'index'
      breadcrumb i18n_i('Poll', :other), profile_polls_url(@user)
    end
  end

  UPDATE_PARAMS = %i[name] + [{
    variants_attributes: %i[text]
  }]
  CREATE_PARAMS = %i[user_id] + UPDATE_PARAMS

  def index
    @collection = @user.polls
  end

  def show
    redirect_to edit_profile_poll_url(@user, @resource) if @resource.pending?
    page_title @resource.name
  end

  def new
    page_title i18n_t('new')
    render :form
  end

  def create
    @resource.save!
    redirect_to edit_profile_poll_url(@user, @resource)
  end

  def edit
    page_title @resource.name
    render :form
  end

  def update
    Poll.transaction do
      @resource.variants.delete_all
      @resource.update! update_params
    end

    redirect_to edit_profile_poll_url(@user, @resource)
  end

  def destroy
    @resource.destroy
    redirect_to profile_polls_url(@user)
  end

  def start
    @resource.start!
    redirect_to profile_poll_url(@user, @resource)
  end

  def stop
    @resource.stop!
    redirect_to profile_poll_url(@user, @resource)
  end

private

  def create_params
    params
      .require(:poll)
      .permit(*CREATE_PARAMS)
      .tap { |hash| fix_variants hash }
  end
  alias new_params create_params

  def update_params
    params
      .require(:poll)
      .permit(*UPDATE_PARAMS)
      .tap { |hash| fix_variants hash }
  end

  def fix_variants params_hash
    return unless params_hash[:variants_attributes]

    params_hash[:variants_attributes] =
      params_hash[:variants_attributes]
        .select { |poll_variant| poll_variant[:text]&.strip.present? }
        .uniq { |poll_variant| poll_variant[:text].strip }
  end
end
