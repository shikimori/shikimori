class Api::V1::Profile::MessagesController < Api::V1::ApiController
  before_filter :authenticate_user!

  api :GET, "/profile/messages", "List messages. Types: inbox, sent, news, notifications"
  def index
    @limit = [[params[:limit].to_i, 1].max, 100].min
    @page = [params[:page].to_i, 1].max

    @resources = MessagesQuery.new(current_user, params[:type] || '').fetch @page, @limit
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/profile/messages/unread"
  def unread
    @resource = current_user
  end
end
