class PollsController < ShikimoriController
  load_and_authorize_resource

  UPDATE_PARAMS = [{
    poll_variants_attributes: %i[text]
  }]
  CREATE_PARAMS = %i[user_id] + UPDATE_PARAMS

  def show
  end

  def new
    page_title i18n_t('new_poll')
    render :form
  end

  def create
    if @resource.save
      redirect_to edit_poll_url(@resource)
    else
      new
    end
  end

  def edit
    page_title @resource.name
    render :form
  end

  def update
  end

  def destroy
  end

  def start
  end

  def stop
  end

private

  def create_params
    params.require(:poll).permit(*CREATE_PARAMS)
  end
  alias new_params create_params

  def update_params
    params.require(:poll).permit(*UPDATE_PARAMS)
  end
end
