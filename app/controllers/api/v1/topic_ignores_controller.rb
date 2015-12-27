class Api::V1::TopicIgnoresController < Api::V1::ApiController
  load_and_authorize_resource

  def create
    @resource.save!

    render json: success_response(@resource)

  rescue PG::UniqueViolation, ActiveRecord::RecordNotUnique
    present_ignore = TopicIgnore.find_by(
      topic: @resource.topic,
      user: @resource.user
    )
    render json: success_response(present_ignore)
  end

  def destroy
    @resource.destroy
    render json: {
      url: api_topic_ignores_url(topic_ignore: {
        topic_id: @resource.topic_id,
        user_id: @resource.user_id
      }),
      method: 'POST',
      # notice: i18n_t('not_ignored')
    }
  end

private

  def create_params
    params.require(:topic_ignore).permit [:user_id, :topic_id]
  end

  def success_response topic_ignore
    {
      id: topic_ignore.id,
      url: api_topic_ignore_url(topic_ignore),
      method: 'DELETE',
      # notice: i18n_t('ignored')
    }
  end
end
