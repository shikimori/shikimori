class FixNewsForumPermalink < ActiveRecord::Migration[5.2]
  def change
    Forum.find_by(permalink: 'News')&.update permalink: 'news'
  end
end
