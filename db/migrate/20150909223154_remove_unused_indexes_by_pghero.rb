class RemoveUnusedIndexesByPghero < ActiveRecord::Migration
  def up
    remove_index :versions, name: "index_versions_on_moderator_id"
    remove_index :screenshots, name: "index_screenshots_on_status"
    remove_index :characters, name: "index_characters_on_japanese"
    remove_index :cosplay_images, name: "index_cosplay_images_on_url"
    remove_index :manga_pages, name: "index_manga_pages_on_manga_chapter_id"
    remove_index :bans, name: "index_bans_on_comment_id"
    remove_index :bans, name: "index_bans_on_abuse_request_id"
    remove_index :bans, name: "index_bans_on_moderator_id"
    remove_index :contests, name: "index_contests_on_updated_at"
    remove_index :group_bans, name: "index_group_bans_on_group_id"
    remove_index :taggings, name: "index_taggings_on_taggable_id_and_taggable_type_and_context"
  end
end
