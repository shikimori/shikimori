class GenerateTopicsForClubPages < ActiveRecord::Migration[5.0]
  def up
    ClubPage.find_each do |club_page|
      Topics::Generate::Topic.call(
        club_page,
        club_page.club.topic_user,
        club_page.club.locale
      )
    end
  end
end
