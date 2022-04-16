# TODO: remove `unless params[:user_id]` after 01-09-2017
class Api::V2::AbuseRequestsController < Api::V2Controller
  before_action :authenticate_user!, only: %i[offtopic review spoiler abuse]
  before_action :fetch_entries

  api :POST, '/v2/abuse_requests/offtopic', 'Mark comment as offtopic'
  param :comment_id, :number, required: true
  description 'Request will be sent to moderators.'
  def offtopic
    ids = Moderations::AbuseRequestsService
      .new(comment: @comment, reporter: current_user)
      .offtopic(faye_token)

    respond_with result(@comment, ids)
  rescue ActiveRecord::RecordNotSaved => e
    render json: e.record.errors.full_messages, status: :unprocessable_entity
  end

  api :POST, '/v2/abuse_requests/review', 'Convert comment to review'
  param :comment_id, :number,
    required: false,
    allow_blank: true
  param :topic_id, :number,
    required: false,
    allow_blank: true
  description 'Request will be sent to moderators.'
  def convert_review
    Moderations::AbuseRequestsService
      .new(comment: @comment, topic: @topic, reporter: current_user)
      .convert_review(faye_token)

    render json: {}
  rescue ActiveRecord::RecordNotSaved => e
    render json: e.record.errors.full_messages, status: :unprocessable_entity
  end

  api :POST, '/v2/abuse_requests/abuse', 'Create abuse about violation of site rules'
  param :comment_id, :number,
    required: false,
    allow_blank: true
  param :topic_id, :number,
    required: false,
    allow_blank: true
  param :reason, String,
    required: false,
    allow_blank: true
  description 'Request will be sent to moderators.'
  def abuse
    Moderations::AbuseRequestsService
      .new(comment: @comment, topic: @topic, reporter: current_user)
      .abuse(params[:reason])

    render json: {}
  rescue ActiveRecord::RecordNotSaved => e
    render json: e.record.errors.full_messages, status: :unprocessable_entity
  end

  api :POST, '/v2/abuse_requests/spoiler', 'Create abuse about spoiler in content'
  param :comment_id, :number,
    required: false,
    allow_blank: true
  param :topic_id, :number,
    required: false,
    allow_blank: true
  param :reason, String,
    required: false,
    allow_blank: true
  description 'Request will be sent to moderators.'
  def spoiler
    Moderations::AbuseRequestsService
      .new(comment: @comment, topic: @topic, reporter: current_user)
      .spoiler(params[:reason])

    render json: {}
  rescue ActiveRecord::RecordNotSaved => e
    render json: e.record.errors.full_messages, status: :unprocessable_entity
  end

private

  def fetch_entries
    @comment = Comment.find params[:comment_id] if params[:comment_id].present?
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
