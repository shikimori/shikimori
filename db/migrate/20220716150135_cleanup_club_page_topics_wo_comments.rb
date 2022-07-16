class CleanupClubPageTopicsWoComments < ActiveRecord::Migration[6.1]
  def change
    Topics::EntryTopics::ClubPageTopic.where(comments_count: 0).destroy_all
  end
end
