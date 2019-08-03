class FillTagsInNewsTopics < ActiveRecord::Migration[5.2]
  def change
    Topics::NewsTopic.where(linked_type: 'Anime').update_all tags: %w[аниме]
    Topics::NewsTopic.where(linked_type: 'Manga').update_all tags: %w[манга]
    Topics::NewsTopic.where(linked_type: 'Ranobe').update_all tags: %w[ранобэ]
  end
end
