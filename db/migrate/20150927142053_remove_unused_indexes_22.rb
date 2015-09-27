class RemoveUnusedIndexes22 < ActiveRecord::Migration
  def change
    remove_index :entries, name: "i_entries_type_comments_count_updated_at"
    remove_index :danbooru_tags, name: "index_danbooru_tags_on_name_and_kind"
    remove_index :danbooru_tags, name: "index_danbooru_tags_on_name"
    remove_index :recommendation_ignores, name: "index_recommendation_ignores_on_target_id_and_target_type"
    remove_index :versions, name: "index_versions_on_created_at"
    remove_index :user_changes, name: "i_user_changes"
    remove_index :user_images, name: "index_user_images_on_user_id"
    remove_index :mangas, name: "index_mangas_on_score"
    remove_index :user_changes, name: "index_user_changes_on_status"
    remove_index :contest_suggestions, name: "index_contest_suggestions_on_item_id"
    remove_index :videos, name: "index_videos_on_state"
    remove_index :related_mangas, name: "index_related_mangas_on_source_id_and_anime_id"
    remove_index :related_mangas, name: "index_related_mangas_on_source_id"
    remove_index :manga_chapters, name: "index_manga_chapters_on_manga_id"
    remove_index :taggings, name: "index_taggings_on_tag_id"
  end
end
