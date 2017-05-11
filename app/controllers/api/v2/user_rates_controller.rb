class Api::V2::UserRatesController < Api::V2Controller
  load_and_authorize_resource

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/v2/user_rates/:id', 'Show an user rate'
  def show
    respond_with @resource
  end

  param :user_id, :number, required: true
  def index
    user = User.find(params[:user_id])
    @collection = Rails.cache.fetch [user, :rates] do
      UserRate.where(user_id: params[:user_id]).to_a
    end

    respond_with @collection
  end

  api :POST, '/v2/user_rates', 'Create an user rate'
  param :user_rate, Hash do
    param :user_id, :number, required: true
    param :target_id, :number, required: true
    param :target_type, %w(Anime Manga), required: true
    param :status, :undef, required: false
    # param :status, UserRate.statuses.keys, required: true
    param :score, :undef, required: false
    param :chapters, :undef, required: false
    param :episodes, :undef, required: false
    param :volumes, :undef, required: false
    param :rewatches, :undef, required: false
    param :text, String, required: false
  end
  def create
    present_rate = UserRate.find_by(
      user_id: @resource.user_id,
      target_id: @resource.target_id,
      target_type: @resource.target_type
    )

    if present_rate
      update_rate present_rate
    else
      create_rate @resource
    end

    respond_with @resource
  end

  api :PATCH, '/v2/user_rates/:id', 'Update an user rate'
  api :PUT, '/v2/user_rates/:id', 'Update an user rate'
  param :user_rate, Hash do
    param :status, :undef, required: false
    # param :status, UserRate.statuses.keys, required: false
    param :score, :undef, required: false
    param :chapters, :undef, required: false
    param :episodes, :undef, required: false
    param :volumes, :undef, required: false
    param :rewatches, :undef, required: false
    param :text, String, required: false
  end
  def update
    update_rate @resource
    respond_with @resource, location: nil
  end

  api :POST, '/v2/user_rates/:id/increment', 'Increment episodes/chapters by 1'
  def increment
    @resource.update increment_params
    respond_with @resource, location: nil
  end

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :DELETE, '/v2/user_rates/:id', 'Destroy an user rate'
  def destroy
    @resource.destroy!
    head 204
  end

private

  def create_params
    params
      .require(:user_rate)
      .permit(*Api::V1::UserRatesController::CREATE_PARAMS)
  end

  def update_params
    params
      .require(:user_rate)
      .permit(*Api::V1::UserRatesController::UPDATE_PARAMS)
  end

  def increment_params
    if @resource.anime?
      { episodes: (params[:episodes] || @resource.episodes) + 1 }
    else
      { chapters: (params[:chapters] || @resource.chapters) + 1 }
    end
  end

  def create_rate user_rate
    @resource = user_rate
    raise NotSaved unless @resource.save

  rescue *Api::V1::UserRatesController::ALLOWED_EXCEPTIONS
    nil
  end

  def update_rate user_rate
    @resource = user_rate
    raise NotSaved unless @resource.update update_params

  rescue *Api::V1::UserRatesController::ALLOWED_EXCEPTIONS
    nil
  end
end
