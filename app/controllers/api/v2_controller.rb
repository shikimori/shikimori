class Api::V2Controller < Api::V1Controller
  resource_description do
    api_version '2.0'
  end

  # do not touch it on api access
  def touch_last_online
  end
end
