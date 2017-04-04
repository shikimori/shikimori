class RemoveContentLayoutInClubPages < ActiveRecord::Migration[5.0]
  def up
    ClubPage.where(layout: 'content').update_all layout: 'menu'
  end
end
