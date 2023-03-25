class ConvertPrimaryKeysToBigint < ActiveRecord::Migration[6.1]
  TABLES = %i[
    abuse_requests
    achievements
    anime_calendars
    anime_links
    anime_video_authors
    anime_video_reports
    anime_videos
    animes
    articles
    bans
    characters
    club_bans
    club_images
    club_invites
    club_links
    club_pages
    club_roles
    clubs
    collection_links
    collection_roles
    collections
    comment_viewings
    comments
    contest_links
    contest_matches
    contest_rounds
    contest_suggestions
    contest_winners
    contests
    cosplay_galleries
    cosplay_gallery_links
    cosplay_images
    cosplayers
    coub_tags
    critiques
    danbooru_tags
    episode_notifications
    external_links
    favourites
    forums
    friend_links
    genres
    ignores
    list_imports
    mangas
    name_matches
    oauth_access_grants
    oauth_access_tokens
    oauth_applications
    people
    person_roles
    poll_variants
    polls
    posters
    proxies
    publishers
    recommendation_ignores
    related_animes
    related_mangas
    reviews
    screenshots
    similar_animes
    similar_mangas
    studios
    styles
    svds
    topic_ignores
    topic_viewings
    topics
    user_histories
    user_images
    user_nickname_changes
    user_preferences
    user_rate_logs
    user_rates
    user_tokens
    users
    versions
    videos
    votes
    webm_videos
  ]

  def up
    TABLES.each do |table|
      change_column table, :id, :bigint
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
