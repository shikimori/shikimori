class GenerateTopicsForClubPages < ActiveRecord::Migration[5.0]
  def up
    ClubPage.find_each do |club_page|
      Topics::Generate::Topic.call(
        model: club_page,
        user: club_page.club.topic_user,
        locale: club_page.club.locale
      )
    end
  end
end
