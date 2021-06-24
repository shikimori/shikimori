class Api::V1::SummariesController < Api::V1Controller
  load_and_authorize_resource
  # load_and_authorize_resource except: %i[show index]
  before_action :authenticate_user!, only: %i[create update destroy]

  before_action only: %i[create update destroy] do
    doorkeeper_authorize! :comments if doorkeeper_token.present?
  end

  def create
    @resource = Summary::Create.call create_params

    if @resource.persisted? && frontent_request?
      render :summary
    else
      respond_with @resource
    end
  end

  def update
    if Summary::Update.call(@resource, update_params) && frontent_request?
      render :comment
    else
      respond_with @resource
    end
  end

  def destroy
    @resource.destroy

    render json: { notice: i18n_t('comment.removed') }
  end

private

  def summary_params
    params
      .require(:summary)
      .permit(:body, :anime_id, :tone)
  end

  def create_params
    summary_params.merge(user: current_user)
  end
end
