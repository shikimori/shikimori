class AddPositionToClubPages < ActiveRecord::Migration
  def change
    add_column :club_pages, :position, :integer
  end
end
