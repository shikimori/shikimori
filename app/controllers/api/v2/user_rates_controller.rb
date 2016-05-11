class Api::V2::UserRatesController < Api::V1::UserRatesController
  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :POST, '/v2/user_rates', 'Create an user rate'
  param :user_rate, Hash do
    param :chapters, :undef
    param :episodes, :undef
    param :rewatches, :undef
    param :score, :undef
    param :status, :undef
    param :target_id, :number
    param :target_type, :undef
    param :text, :undef
    param :user_id, :number
    param :volumes, :undef
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

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :PATCH, '/v2/user_rates/:id', 'Update an user rate'
  api :PUT, '/v2/user_rates/:id', 'Update an user rate'
  param :user_rate, Hash do
    param :chapters, :undef
    param :episodes, :undef
    param :rewatches, :undef
    param :score, :undef
    param :status, :undef
    param :text, :undef
    param :volumes, :undef
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
