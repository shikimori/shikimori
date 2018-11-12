class Api::V1::DevicesController < Api::V1Controller
  load_and_authorize_resource

  resource_description do
    description 'Mobile devices for push notifications'
  end

  LIMIT = 50

  api :GET, '/devices', 'List devices'
  param :page, :pagination, required: false
  param :limit, :pagination, required: false, desc: "#{LIMIT} maximum"
  def index
    @limit = [[params[:limit].to_i, 1].max, LIMIT].min

    @collection = QueryObjectBase.new(@devices).paginate(@page, @limit)

    respond_with @collection.to_a
  end

  def test
    gcm = GCM.new Rails.application.secrets.gcm[:token]

    respond_with gcm.send_notification(
      [@device.token],
      data: JSON.parse(params[:data])
    )
  end

  api :POST, '/devices', 'Create a device'
  param :device, Hash do
    param :platform, %w[ios android], required: true
    param :token, String, desc: 'ID of mobile device', required: true
    param :user_id, :undef, required: true
    param :name, String, required: false
  end
  def create
    @device.save
    respond_with @device, location: nil
  end

  api :PATCH, '/devices/:id', 'Update a device'
  api :PUT, '/devices/:id', 'Update a device'
  param :device, Hash do
    param :token, String, required: false
    param :name, String, required: false
  end
  def update
    @device.update update_params
    respond_with @device, location: nil
  end

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :DELETE, '/devices/:id', 'Destroy a device'
  def destroy
    @device.destroy
    respond_with @device, location: nil
  end

private

  def device_params
    params.require(:device).permit :user_id, :platform, :token, :name
  end

  def update_params
    params.require(:device).permit :token, :name
  end
end
