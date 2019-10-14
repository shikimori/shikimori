class MakeClubPagesPositionNotNullable < ActiveRecord::Migration[5.2]
  def change
    change_column :club_pages, :position, :integer, null: false
  end
end
