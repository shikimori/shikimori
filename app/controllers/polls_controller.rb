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
  end

  def start
  end

  def stop
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
end
