class Api::V2::Topics::IgnoresController < Api::V2Controller
  before_action :authenticate_user!

  before_action do
    doorkeeper_authorize! :topics if doorkeeper_token.present?
  end

  resource_description do
    resource_id 'Topic Ignore'
  end

  api :POST, '/v2/topics/:topic_id/ignore', 'Ignore a topic'
  description 'Requires `topics` oauth scope'
  def create
    TopicIgnore.find_or_create_by(
      topic_id: params[:topic_id],
      user_id: current_user.id
    )
  rescue PG::UniqueViolation, ActiveRecord::RecordNotUnique
  ensure
    render json: { topic_id: params[:topic_id], is_ignored: true }
  end

  api :DELETE, '/v2/topics/:topic_id/ignore', 'Unignore a topic'
  description 'Requires `topics` oauth scope'
  def destroy
    TopicIgnore
      .where(topic_id: params[:topic_id])
      .where(user_id: current_user.id)
      .destroy_all

    render json: { topic_id: params[:topic_id], is_ignored: false }
  end
end
