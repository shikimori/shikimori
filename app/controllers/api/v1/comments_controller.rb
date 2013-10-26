class Api::V1::CommentsController < Api::V1::ApiController
  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/comments/:id", "Show a comment"
  def show
    @resource = Comment.find params[:id]
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/comments", "List comments"
  def index
    @limit = [[params[:limit].to_i, 1].max, 100].min
    @page = params[:page].to_i
    @desc = params[:desc].nil? || params[:desc] == '1'

    @resources = CommentsQuery
      .new(params[:commentable_type], params[:commentable_id])
      .fetch(@page, @limit, @desc)
  end
end
