class MoveAllNewsToNewsForum < ActiveRecord::Migration[5.2]
  def change
    Topics::NewsTopic.update_all forum_id: Forum::NEWS_ID
  end
end
