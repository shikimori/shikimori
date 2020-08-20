class AddLayoutToClubPages < ActiveRecord::Migration[5.2]
  def change
    add_column :club_pages, :layout, :string,
      default: Types::ClubPage::Layout[:menu],
      null: false
  end
end
