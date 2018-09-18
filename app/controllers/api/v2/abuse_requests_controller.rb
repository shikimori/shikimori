# TODO: remove `unless params[:user_id]` after 01-09-2017
class Api::V2::AbuseRequestsController < Api::V2Controller
  before_action :authenticate_user!, only: %i[offtopic summary spoiler abuse]

  api :POST, '/v2/abuse_requests/offtopic', 'Mark comment as offtopic'
  param :comment_id, :number, required: true
  description 'Request will be sent to moderators.'
  def offtopic
    comment = Comment.find params[:comment_id]
    ids = AbuseRequestsService.new(comment, current_user).offtopic(faye_token)

    respond_with result(comment, ids)
  end

  api :POST, '/v2/abuse_requests/summary', 'Mark comment as summary'
  param :comment_id, :number, required: true
  description 'Request will be sent to moderators.'
  def summary
    comment = Comment.find params[:comment_id]
    ids = AbuseRequestsService.new(comment, current_user).summary(faye_token)

    respond_with result(comment, ids)
  end

  api :POST, '/v2/abuse_requests/abuse', 'Create abuse about violation of site rules'
  param :comment_id, :number, required: true
  param :reason, String, required: false
  description 'Request will be sent to moderators.'
  def abuse
    comment = Comment.find params[:comment_id]
    ids = AbuseRequestsService.new(comment, current_user).abuse params[:reason]

    respond_with result(comment, ids)
  end

  api :POST, '/v2/abuse_requests/spoiler', 'Create abuse spoiler content in comment'
  param :comment_id, :number, required: true
  param :reason, String, required: false
  description 'Request will be sent to moderators.'
  def spoiler
    comment = Comment.find params[:comment_id]
    ids = AbuseRequestsService.new(comment, current_user).spoiler params[:reason]

    respond_with result(comment, ids)
  end

private

  def result comment, ids
    {
      kind: params[:action],
      value: comment.try(:"#{params[:action]}?") || false,
      affected_ids: ids
    }
  end
end
