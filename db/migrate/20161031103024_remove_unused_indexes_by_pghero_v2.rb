class RemoveUnusedIndexesByPgheroV2 < ActiveRecord::Migration[5.2]
  def up
    remove_index :contest_user_votes, name: 'index_contest_user_votes_on_contest_vote_id'
    remove_index :friend_links, name: 'index_friend_links_on_src_id'
    remove_index :recommendation_ignores, name: 'index_recommendation_ignores_on_user_id'
    remove_index :related_mangas, name: 'index_related_mangas_on_source_id'
    remove_index :screenshots, name: 'index_screenshots_on_anime_id'
    remove_index :topic_ignores, name: 'index_topic_ignores_on_user_id'
    remove_index :user_nickname_changes, name: 'index_user_nickname_changes_on_user_id'
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
