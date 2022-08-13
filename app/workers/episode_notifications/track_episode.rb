class EpisodeNotifications::TrackEpisode
  include Sidekiq::Worker
  sidekiq_options queue: :episode_notifications

  BOT_ID = 1680
  VIDEO_MODERATION_TOPIC_ID = 272_335

  def perform episode_notification_id
    episode_notification = find episode_notification_id
    return unless episode_notification

    EpisodeNotification::TrackEpisode.call episode_notification
  rescue MissingEpisodeError => e
    broadcast_to_moderators e.anime_id, e.episode
  rescue ActiveRecord::RecordNotSaved => e
    if e.message.starts_with? EpisodeNotification::Track::ERROR_MESSAGE_PREFIX
      NamedLogger.missing_episodes.info e.message
    else
      raise
    end
  end

private

  def find episode_notification_id
    EpisodeNotification.find_by id: episode_notification_id
  end

  def broadcast_to_moderators anime_id, episode
    comment = Comment::Create.call(
      params: {
        body: generate_report(anime_id, episode),
        commentable_id: VIDEO_MODERATION_TOPIC_ID,
        commentable_type: Topic.name,
        user: reporter
      },
      faye: faye,
      locale: 'ru'
    )
    Comment::Broadcast.call comment

    comment
  end

  def generate_report anime_id, episode
    anime = Anime.find anime_id

    <<~BBCODE.squish
      Episode ##{episode} is tracked
      for anime [anime=#{anime_id}] while in this anime
      there #{anime.episodes == 1 ? 'is' : 'are'} only
      #{anime.episodes} #{'episode'.pluralize anime.episodes}.
    BBCODE
  end

  def reporter
    @reporter ||= User.find BOT_ID
  end

  def faye
    FayeService.new reporter, nil
  end
end
