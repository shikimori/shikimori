class AddUserToClubPages < ActiveRecord::Migration[6.1]
  def change
    add_reference :club_pages, :user, index: true, null: true
  end
end
