class Api::V1::TopicsController < Api::V1::ApiController
  respond_to :json, :xml

  def index
    @limit = [[params[:limit].to_i, 1].max, 30].min
    @page = [params[:page].to_i, 1].max
    @section = Section.find_by_permalink params[:section]
    @topics = TopicsQuery
      .new(@section, current_user)
      .fetch(@page, @limit)
      .includes(:section, :user)

    respond_with @topics, each_serializer: TopicSerializer
  end
end
