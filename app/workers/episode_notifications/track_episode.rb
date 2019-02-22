class EpisodeNotifications::TrackEpisode
  include Sidekiq::Worker
  sidekiq_options queue: :episode_notifications

  VIDEO_MODERATION_TOPIC_ID = 272_335

  def perform episode_notification_id
    episode_notification = find episode_notification_id
    return unless episode_notification

    EpisodeNotification::TrackEpisode.call episode_notification
  rescue MissingEpisodeError => e
    broadcast_to_moderators e.anime_id, e.episode
  end

private

  def find episode_notification_id
    EpisodeNotification.find_by id: episode_notification_id
  end

  def broadcast_to_moderators anime_id, episode
    comment = Comment::Create.call(
      faye,
      {
        body: generate_report(anime_id, episode),
        commentable_id: VIDEO_MODERATION_TOPIC_ID,
        commentable_type: Topic.name,
        user: reporter
      },
      'ru'
    )
    Comment::Broadcast.call comment

    comment
  end

  def generate_report anime_id, episode
    anime = Anime.find anime_id
    episode_url = UrlGenerator.instance.play_video_online_index_url(
      anime,
      episode,
      domain: AnimeOnlineDomain::HOST,
      subdomain: false
    )

    <<~BBCODE.squish
      [url=#{episode_url}]Episode ##{episode}[/url] is uploaded
      for anime [anime=#{anime_id}] while in this anime
      there #{anime.episodes == 1 ? 'is' : 'are'} only
      #{anime.episodes} #{'episode'.pluralize anime.episodes}.
    BBCODE
  end

  def reporter
    @reporter ||= User.find User::MORR_ID
  end

  def faye
    FayeService.new reporter, nil
  end
end
