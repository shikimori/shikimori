# TODO: remove `unless params[:user_id]` after 01-09-2017
class Api::V2::AbuseRequestsController < Api::V2Controller
  before_action :authenticate_user!, only: %i[offtopic summary spoiler abuse]
  before_action :fetch_entries

  api :POST, '/v2/abuse_requests/offtopic', 'Mark comment as offtopic'
  param :comment_id, :number, required: true
  description 'Request will be sent to moderators.'
  def offtopic
    ids = AbuseRequestsService
      .new(comment: @comment, reporter: current_user)
      .offtopic(faye_token)

    respond_with result(@comment, ids)
  rescue ActiveRecord::RecordNotSaved => e
    render json: e.record.errors.full_messages, status: :unprocessable_entity
  end

  # api :POST, '/v2/abuse_requests/review', 'Convert comment to review'
  # param :comment_id, :number, required: false
  # param :review_id, :number, required: false
  # description 'Request will be sent to moderators.'
  # def review
  #   ids = AbuseRequestsService
  #     .new(comment: @comment, review: @review, reporter: current_user)
  #     .review(faye_token)
  #
  #   respond_with result(@comment, ids)
  # rescue ActiveRecord::RecordNotSaved => e
  #   render json: e.record.errors.full_messages, status: :unprocessable_entity
  # end

  api :POST, '/v2/abuse_requests/abuse', 'Create abuse about violation of site rules'
  param :comment_id, :number, required: false
  param :topic_id, :number, required: false
  param :review_id, :number, required: false
  param :reason, String, required: false
  description 'Request will be sent to moderators.'
  def abuse
    AbuseRequestsService
      .new(comment: @comment, review: @review, topic: @topic, reporter: current_user)
      .abuse(params[:reason])

    head :ok
  rescue ActiveRecord::RecordNotSaved => e
    render json: e.record.errors.full_messages, status: :unprocessable_entity
  end

  api :POST, '/v2/abuse_requests/spoiler', 'Create abuse about spoiler in content'
  param :comment_id, :number, required: false
  param :topic_id, :number, required: false
  param :review_id, :number, required: false
  param :reason, String, required: false
  description 'Request will be sent to moderators.'
  def spoiler
    AbuseRequestsService
      .new(comment: @comment, review: @review, topic: @topic, reporter: current_user)
      .spoiler(params[:reason])

    head :ok
  rescue ActiveRecord::RecordNotSaved => e
    render json: e.record.errors.full_messages, status: :unprocessable_entity
  end

private

  def fetch_entries
    @comment = Comment.find params[:comment_id] if params[:comment_id].present?
    @review = Review.find params[:review_id] if params[:review_id].present?
    @topic = Topic.find params[:topic_id] if params[:topic_id].present?
  end

  def result model, ids
    {
      kind: params[:action],
      value: model.try(:"#{params[:action]}?") || false,
      affected_ids: ids
    }
  end
end
