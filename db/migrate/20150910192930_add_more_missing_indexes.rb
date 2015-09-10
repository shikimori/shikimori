class AddMoreMissingIndexes < ActiveRecord::Migration
  def change
    remove_index :related_animes, column: :source_id
    add_index :related_mangas, [:source_id, :anime_id]
    add_index :related_mangas, [:source_id, :manga_id]
    add_index :abuse_requests, [:state, :kind]
    add_index :contests, [:state, :started_on, :finished_on]
    add_index :entries, [:linked_id, :linked_type, :comments_count, :generated], name: :entries_total_select
    add_index :comments, [:commentable_id, :commentable_type]
  end
end
