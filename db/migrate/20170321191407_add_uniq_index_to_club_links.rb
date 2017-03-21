class AddUniqIndexToClubLinks < ActiveRecord::Migration[5.0]
  def up
    remove_index :club_links, %i(club_id linked_id linked_type)
    add_index :club_links, %i(club_id linked_id linked_type), unique: true
  end

  def down
    remove_index :club_links, %i(club_id linked_id linked_type)
    add_index :club_links, %i(club_id linked_id linked_type)
  end
end
