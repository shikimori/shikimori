class Api::V1::Profile::FriendsController < Api::V1::ApiController
  before_filter :authenticate_user!

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/profile/friends", "List friends"
  def index
    @resources = current_user.friends
  end
end
