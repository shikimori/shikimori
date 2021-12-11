class Api::V1::ReviewsController < Api::V1Controller
  load_and_authorize_resource
  # load_and_authorize_resource except: %i[show index]
  before_action :authenticate_user!, only: %i[create update destroy]

  before_action only: %i[create update destroy] do
    doorkeeper_authorize! :comments if doorkeeper_token.present?
  end

  def create
    @resource = Review::Create.call create_params

    if @resource.persisted? && frontent_request?
      render :review
    else
      respond_with @resource
    end
  end

  def update
    is_updated = Review::Update.call(
      review: @resource,
      params: update_params,
      faye: faye
    )

    if is_updated && frontent_request?
      render :review
    else
      respond_with @resource
    end
  end

  def destroy
    Review::Destroy.call @resource, faye

    render json: { notice: i18n_t('review.removed') }
  end

private

  def create_params
    params
      .require(:review)
      .permit(:body, :anime_id, :manga_id, :opinion)
      .merge(user: current_user)
  end

  def update_params
    params
      .require(:review)
      .permit(:body, :is_written_before_release, :opinion)
  end

  def faye
    FayeService.new current_user, faye_token
  end
end
