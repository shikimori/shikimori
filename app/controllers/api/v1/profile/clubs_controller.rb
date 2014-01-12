# TODO: выпилить посе 25.01.2014
class Api::V1::Profile::ClubsController < Api::V1::ApiController
  before_filter :authenticate_user!
  respond_to :json, :xml

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/profile/clubs", "List clubs"
  def index
    respond_with current_user.groups
  end
end
