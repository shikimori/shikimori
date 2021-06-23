class Api::V1::SummariesController < Api::V1Controller
  load_and_authorize_resource
  before_action :authenticate_user!, only: %i[create update destroy]
  # load_and_authorize_resource except: %i[show index]

  def create
    @resource = Summary::Create.call create_params

    if @resource.persisted? && frontent_request?
      render :summary
    else
      respond_with @resource
    end
  end
end
