class Api::V2::EpisodeNotificationsController < Api::V2Controller
  skip_before_action :verify_authenticity_token

  api :POST, '/v2/episode_notifications', 'Create an episode notification'
  param :episode_notification, Hash do
    param :anime_id, :number, required: true
    param :episode, :number, required: true
    param :aired_at, DateTime, required: true
    param :is_fandub, :boolean, required: false
    param :is_raw, :boolean, required: false
    param :is_subtitles, :boolean, required: false
  end
  param :token, String
  def create
    raise CanCan::AccessDenied unless access_granted?

    @resource = EpisodeNotification::Track.call convert_params(episode_notification_params)

    render json: {
      id: @resource.id,
      anime_id: @resource.anime_id,
      episode: @resource.episode,
      is_raw: @resource.is_raw,
      is_subtitles: @resource.is_subtitles,
      is_fandub: @resource.is_fandub,
      topic_id: topic_id(@resource)
    }
  rescue ActiveRecord::RecordNotSaved => e
    render json: e.record.errors.full_messages, status: :unprocessable_entity
  end

private

  def convert_params params
    {
      anime_id: params[:anime_id],
      episode: params[:episode],
      aired_at: params[:aired_at],
      is_raw: ActiveRecord::Type::Boolean.new.cast(params[:is_raw]),
      is_subtitles: ActiveRecord::Type::Boolean.new.cast(params[:is_subtitles]),
      is_fandub: ActiveRecord::Type::Boolean.new.cast(params[:is_fandub])
    }
  end

  def episode_notification_params
    params
      .require(:episode_notification)
      .permit(:anime_id, :episode, :aired_at, :is_raw, :is_subtitles, :is_fandub)
  end

  def access_granted?
    params[:token] == Rails.application.secrets[:api][:anime_videos][:token]
  end

  def topic_id episode_notification
    episode_notification
      .anime
      .all_topics
      .where(
        action: Types::Topic::NewsTopic::Action[:episode],
        value: episode_notification.episode,
        locale: locale_from_host
      )
      .first
      &.id
  end
end
