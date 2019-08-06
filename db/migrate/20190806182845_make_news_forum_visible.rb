class MakeNewsForumVisible < ActiveRecord::Migration[5.2]
  def change
    Forum.find_by(permalink: 'News')&.update is_visible: true
  end
end
