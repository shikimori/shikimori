class Api::V1::Profile::ClubsController < Api::V1::ApiController
  before_filter :authenticate_user!

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/profile/clubs", "List clubs"
  def index
    @resources = current_user.groups
  end
end
