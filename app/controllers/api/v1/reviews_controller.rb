class Api::V1::ReviewsController < Api::V1Controller
  load_and_authorize_resource
  # load_and_authorize_resource except: %i[show index]
  before_action :authenticate_user!, only: %i[create update destroy]

  before_action only: %i[create update destroy] do
    doorkeeper_authorize! :comments if doorkeeper_token.present?
  end

  CREATE_PARAMS = %i[body anime_id manga_id opinion]
  UPDATE_PARAMS = %i[body is_written_before_release opinion]

  api :POST, '/reviews', 'Create a review'
  param :frontend, :bool, 'Used by shikimori frontend code. Ignore it.'
  param :review, Hash, required: true do
    param :anime_id, :number, required: true
    param :body, String, required: true
    param :opinion, Types::Review::Opinion.values.map(&:to_s), required: true
  end
  error code: 422
  def create
    @resource = Review::Create.call create_params

    if @resource.persisted? && frontent_request?
      render :review
    else
      respond_with @resource
    end
  end

  api :PATCH, '/reviews/:id', 'Update a review'
  api :PUT, '/reviews/:id', 'Update a review'
  param :frontend, :bool, 'Used by shikimori frontend code. Ignore it.'
  param :review, Hash, required: true do
    param :body, String, required: false
    param :opinion, Types::Review::Opinion.values.map(&:to_s), required: false
  end
  error code: 422
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

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :DELETE, '/reviews/:id', 'Destroy a review'
  def destroy
    Review::Destroy.call @resource, faye

    render json: { notice: i18n_t('review.removed') }
  end

private

  def create_params
    params
      .require(:review)
      .permit(*CREATE_PARAMS)
      .merge(user: current_user)
  end

  def update_params
    params
      .require(:review)
      .permit(*UPDATE_PARAMS)
  end

  def faye
    FayeService.new current_user, faye_token
  end
end
