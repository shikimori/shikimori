class Api::V1::TopicsController < Api::V1::ApiController
  respond_to :json

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, '/topics', 'List topics'
  def index
    @limit = [[params[:limit].to_i, 1].max, 30].min
    @page = [params[:page].to_i, 1].max

    @forum = Forum.find_by_permalink params[:forum]
    @topics = TopicsQuery.fetch(current_user)
      .by_forum(@forum, current_user, censored_forbidden?)
      .includes(:forum, :user)
      .offset(@limit * (@page-1))
      .limit(@limit + 1)
      .as_views(true, false)

    respond_with @topics, each_serializer: TopicSerializer
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, '/topics/:id', 'Show a topic'
  def show
    @topic = Topics::TopicViewFactory.new(false, false).find params[:id]
    respond_with @topic, serializer: TopicSerializer
  end
end
