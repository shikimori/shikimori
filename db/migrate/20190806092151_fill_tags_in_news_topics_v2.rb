class FillTagsInNewsTopicsV2 < ActiveRecord::Migration[5.2]
  def change
    Topics::NewsTopic.where(generated: false, linked_type: 'Anime').update_all tags: %w[аниме]
    Topics::NewsTopic.where(generated: false, linked_type: 'Manga').update_all tags: %w[манга]
    Topics::NewsTopic.where(generated: false, linked_type: 'Ranobe').update_all tags: %w[ранобэ]

    Topics::NewsTopic.wo_timestamp do
      Topics::NewsTopic.where(generated: false, forum_id: 16).each do |topic|
        topic.tags << 'игры'
        topic.save!
      end
      Topics::NewsTopic.where(generated: false, forum_id: 17).each do |topic|
        topic.tags << 'визуальные_новеллы'
        topic.save!
      end
    end
    Topics::NewsTopic.where(generated: false, forum_id: Forum::SITE_ID).update_all tags: %w[сайт]
  end
end
