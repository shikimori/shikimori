class AddPositionToClubPages < ActiveRecord::Migration[5.2]
  def change
    add_column :club_pages, :position, :integer
  end
end
