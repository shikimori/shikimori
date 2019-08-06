class FillTagsInNewsTopicsV2 < ActiveRecord::Migration[5.2]
  def change
    Topics::NewsTopic.where(forum_id: 16).update_all tags: %w[игры]
    Topics::NewsTopic.where(forum_id: 17).update_all tags: %w[визуальные_новеллы]
    Topics::NewsTopic.where(forum_id: 4).update_all tags: %w[сайт]
  end
end
