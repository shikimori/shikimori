class RenameReviewTopicsType < ActiveRecord::Migration[5.2]
  def up
    Topic
      .where(type: 'Topics::EntryTopics::ReviewTopic')
      .update_all type: 'Topics::EntryTopics::CritiqueTopic'
  end

  def down
    Topic
      .where(type: 'Topics::EntryTopics::CritiqueTopic')
      .update_all type: 'Topics::EntryTopics::ReviewTopic'
  end
end
