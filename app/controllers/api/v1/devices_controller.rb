class Api::V1::DevicesController < Api::V1::ApiController
  load_and_authorize_resource
  respond_to :json

  resource_description do
    description 'Mobile devices for push notifications'
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/devices", "List devices"
  def index
    respond_with @devices
  end

  def test
    gcm = GCM.new(Rails.env.production? ? 'AIzaSyC81xkpbxSs8G-gHFJD0JWEAw4oC9VeRTE' : 'AIzaSyB_9gYngdl16dHtTyqywxwjSZOtdYVC6Yk')
    respond_with gcm.send_notification([@device.token], data: JSON.parse(params[:data]))
  end

  api :POST, "/devices", "Create a device"
  param :device, Hash do
    param :platform, ['ios', 'android'], required: true
    param :token, String, desc: 'ID of mobile device', required: true
    param :user_id, :undef, required: true
    param :name, String
  end
  def create
    @device.save
    respond_with @device, location: nil
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :DELETE, "/devices/:id", "Destroy a device"
  def destroy
    @device.destroy
    respond_with @device, location: nil
  end

private
  def device_params
    params.require(:device).permit :user_id, :platform, :token, :name
  end
end
