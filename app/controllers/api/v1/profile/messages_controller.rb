class Api::V1::Profile::MessagesController < Api::V1::ApiController
  before_filter :authenticate_user!

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/profile/messages/unread"
  def unread
    @resource = current_user
  end
end
