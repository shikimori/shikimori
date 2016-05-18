class Api::V2::UserRatesController < Api::V1::UserRatesController
  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, '/v2/user_rates/:id', 'Show an user rate'
  def show
    respond_with @resource
  end

  api :POST, '/v2/user_rates', 'Create an user rate'
  param :user_rate, Hash do
    param :user_id, :number, required: true
    param :target_id, :number, required: true
    param :target_type, %w(Anime Manga), required: true
    param :status, %w(planned watching rewatching completed on_hold dropped), required: true
    param :score, :undef, required: false
    param :chapters, :number, required: false
    param :episodes, :number, required: false
    param :volumes, :number, required: false
    param :rewatches, :number, required: false
    param :text, String, required: false
  end
  def create
    present_rate = UserRate.find_by(
      user_id: @resource.user_id,
      target_id: @resource.target_id,
      target_type: @resource.target_type,
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
    param :status, %w(planned watching rewatching completed on_hold dropped), required: false
    param :score, :undef, required: false
    param :chapters, :number, required: false
    param :episodes, :number, required: false
    param :volumes, :number, required: false
    param :rewatches, :number, required: false
    param :text, String, required: false
  end
  def update
    update_rate @resource
    respond_with @resource, location: nil
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :POST, '/v2/user_rates/:id/increment'
  def increment
    @resource.update increment_params
    respond_with @resource, location: nil
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :DELETE, '/v2/user_rates/:id', 'Destroy an user rate'
  def destroy
    @resource.destroy!
    head 204
  end
end
