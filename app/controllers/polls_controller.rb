class PollsController < ShikimoriController
  load_and_authorize_resource

  before_action { page_title i18n_i('Poll', :other) }
  before_action :set_breadcrumbs, except: :index

  UPDATE_PARAMS = [{
    poll_variants_attributes: %i[text]
  }]
  CREATE_PARAMS = %i[user_id] + UPDATE_PARAMS

  def index
    @collection = @collection.order(id: :desc)
  end

  def show
    redirect_to edit_poll_url(@resource) if @resource.pending?
  end

  def new
    page_title i18n_t('new')
    render :form
  end

  def create
    @resource.save!
    redirect_to edit_poll_url(@resource)
  end

  def edit
    page_title @resource.name
    render :form
  end

  def update
    Poll.transaction do
      @resource.poll_variants.delete_all
      @resource.update! update_params
    end

    redirect_to edit_poll_url(@resource)
  end

  def destroy
    @resource.destroy
    redirect_to polls_url
  end

  def start
    @resource.start!
    redirect_to poll_url(@resource)
  end

  def stop
    @resource.stop!
    redirect_to poll_url(@resource)
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
    return unless params_hash[:poll_variants_attributes]

    params_hash[:poll_variants_attributes] =
      params_hash[:poll_variants_attributes]
        .select { |poll_variant| poll_variant[:text]&.strip.present? }
        .uniq { |poll_variant| poll_variant[:text].strip }
  end

  def set_breadcrumbs
    breadcrumb i18n_i('Poll', :other), polls_url

    if %w[edit update].include? params[:action]
      breadcrumb @resource.name, poll_url(@resource)
    end
  end
end
