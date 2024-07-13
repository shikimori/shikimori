class AddNewIndexes < ActiveRecord::Migration[7.0]
  def change
    add_index :club_links, %i[linked_id linked_type club_id]

    add_index :abuse_requests, [:kind]
    add_index :animes, [:aired_on_computed]
    add_index :mangas, [:aired_on_computed]
    add_index :user_nickname_changes, [:value]
  end
end
