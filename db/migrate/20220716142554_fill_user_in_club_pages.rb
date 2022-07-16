class FillUserInClubPages < ActiveRecord::Migration[6.1]
  def change
    ClubPage.find_each do |club_page|
      club_page.update_column :user_id, club_page.all_topics.first.user.id
    end
  end
end
