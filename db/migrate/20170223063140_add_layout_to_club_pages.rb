class AddLayoutToClubPages < ActiveRecord::Migration
  def change
    add_column :club_pages, :layout, :string,
      default: Types::ClubPage::Layout[:menu],
      null: false
  end
end
