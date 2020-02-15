class RemoveUnusedIndexesV4 < ActiveRecord::Migration[5.2]
  def up
    remove_index :anime_video_reports,
      name: "index_anime_video_reports_on_anime_video_id_and_kind_and_state"
    remove_index :topics, name: "index_topics_on_tags"
  end
end
