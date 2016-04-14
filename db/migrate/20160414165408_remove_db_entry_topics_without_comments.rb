class RemoveDbEntryTopicsWithoutComments < ActiveRecord::Migration
  def change
    Topics::EntryTopics::AnimeTopic.where(comments_count: 0).delete_all
    Topics::EntryTopics::MangaTopic.where(comments_count: 0).delete_all
    Topics::EntryTopics::CharacterTopic.where(comments_count: 0).delete_all
    Topics::EntryTopics::PersonTopic.where(comments_count: 0).delete_all
  end
end
