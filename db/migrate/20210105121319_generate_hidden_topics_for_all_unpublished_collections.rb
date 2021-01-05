class GenerateHiddenTopicsForAllUnpublishedCollections < ActiveRecord::Migration[5.2]
  def up
    Collection.where(state: :unpublished).each do |collection|
      collection.generate_topics collection.locale, forum_id: Forum::HIDDEN_ID
    end
  end

  def down
    Collection.where(state: :unpublished).each do |collection|
      collection.topics.destroy_all
    end
  end
end
