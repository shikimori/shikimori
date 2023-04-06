class ConvertForeignKeysToBigint < ActiveRecord::Migration[6.1]
  TABLES = {
    abuse_requests: %i[user_id comment_id approver_id topic_id],
    achievements: :user_id,
    anime_calendars: :anime_id,
    anime_links: :anime_id,
    anime_video_reports: %i[anime_video_id user_id approver_id],
    anime_videos: %i[anime_id anime_video_author_id],
    articles: %i[user_id approver_id],
    bans: %i[user_id comment_id abuse_request_id moderator_id topic_id],
    club_bans: %i[club_id user_id],
    club_images: %i[club_id user_id],
    club_invites: %i[club_id src_id dst_id message_id],
    club_links: %i[club_id linked_id],
    club_pages: %i[club_id parent_page_id user_id],
    club_roles: %i[user_id club_id],
    clubs: %i[owner_id style_id],
    collection_links: %i[collection_id linked_id],
    collection_roles: %i[collection_id user_id],
    collections: %i[user_id],
    comment_viewings: %i[user_id viewed_id],
    comments: %i[commentable_id user_id],
    contest_links: %i[contest_id linked_id],
    contest_matches: %i[round_id left_id right_id],
    contest_rounds: %i[contest_id],
    contest_suggestions: %i[contest_id user_id item_id],
    contest_winners: %i[contest_id item_id],
    contests: %i[user_id],
    cosplay_galleries: %i[user_id],
    cosplay_gallery_links: %i[linked_id cosplay_gallery_id],
    cosplay_images: %i[cosplay_gallery_id],
    critiques: %i[target_id user_id comment_id approver_id],
    episode_notifications: %i[anime_id],
    external_links: %i[entry_id],
    favourites: %i[linked_id user_id],
    friend_links: %i[src_id dst_id],
    ignores: %i[user_id target_id],
    messages: %i[from_id to_id linked_id],
    name_matches: %i[target_id],
    oauth_access_grants: %i[resource_owner_id],
    oauth_access_tokens: %i[resource_owner_id],
    person_roles: %i[anime_id character_id person_id manga_id],
    recommendation_ignores: %i[user_id target_id],
    related_animes: %i[source_id anime_id],
    related_mangas: %i[source_id anime_id manga_id],
    screenshots: %i[anime_id],
    similar_animes: %i[src_id dst_id],
    similar_mangas: %i[src_id dst_id],
    styles: %i[owner_id],
    topic_ignores: %i[user_id topic_id],
    topic_viewings: %i[user_id viewed_id],
    topics: %i[user_id forum_id],
    user_histories: %i[user_id],
    user_images: %i[user_id linked_id],
    user_nickname_changes: %i[user_id],
    user_preferences: %i[user_id],
    user_rates: %i[user_id target_id],
    user_tokens: %i[user_id],
    versions: %i[item_id user_id moderator_id associated_id],
    videos: %i[uploader_id anime_id]
  }

  def up
    TABLES.each do |table, fields|
      Array(fields).each do |field|
        change_column table, field, :bigint
      end
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
