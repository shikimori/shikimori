class Users::PollsController < ProfilesController
  load_and_authorize_resource

  before_action do
    @back_url = profile_url @user
    og page_title: i18n_i('Poll', :other)

    if params[:action] != 'index'
      breadcrumb i18n_i('Poll', :other), profile_polls_url(@user)
    end
  end

  UPDATE_PARAMS = %i[name text width] + [{
    variants_attributes: %i[label]
  }]
  CREATE_PARAMS = %i[user_id] + UPDATE_PARAMS

  def index
    @collection = @user.polls
  end

  def show
    redirect_to edit_profile_poll_url(@user, @resource) if @resource.pending?
    og page_title: @resource.name
  end

  def new
    og page_title: i18n_t('new')
    render :form
  end

  def create
    if @resource.save
      redirect_to edit_profile_poll_url(@user, @resource)
    else
      new
    end
  end

  def edit
    og page_title: @resource.name
    render :form
  end

  def update
    if @resource.started?
      update_started_poll
    else
      update_pending_poll
    end
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

  def update_started_poll
    is_updated = @resource.update(
      name: update_params[:name],
      width: update_params[:width],
      text: update_params[:text]
    )

    if is_updated
      redirect_to profile_poll_url(@user, @resource)
    else
      edit
    end
  end

  def update_pending_poll
    is_updated =
      Poll.transaction do
        @resource.variants.delete_all
        @resource.update! update_params
        true
      rescue ActiveRecord::RecordInvalid
        false
      end

    if is_updated
      redirect_to edit_profile_poll_url(@user, @resource)
    else
      edit
    end
  end

  def fix_variants params_hash
    return unless params_hash[:variants_attributes]

    params_hash[:variants_attributes] =
      params_hash[:variants_attributes]
        .select { |poll_variant| poll_variant[:label]&.strip.present? }
        .uniq { |poll_variant| poll_variant[:label].strip }
  end
end
