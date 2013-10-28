class Api::V1::SessionsController < Devise::SessionsController
  resource_description do
    api_version '1'
  end

  respond_to :json, :xml

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :POST, "/sessions", "Create a session"
  param :user, Hash do
    param :nickname, :undef
    param :password, :undef
  end
  def create
    self.resource = warden.authenticate!(auth_options)
    sign_in(resource_name, resource)
    respond_with resource
  end
end
