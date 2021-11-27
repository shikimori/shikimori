class FixUpdatedAtInBrokenTopics < ActiveRecord::Migration[5.2]
  def up
    Topic.where(comments_count: 1, updated_at: nil).includes(:comments).each do |topic|
      topic.update! updated_at: topic.comments.first.created_at
    end
  end

  def down
  end
end
