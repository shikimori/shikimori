class GenerateHiddenTopicsForAllUnpublishedCollections < ActiveRecord::Migration[5.2]
  def up
    Collection.where(state: :unpublished).each do |model|
      model.generate_topics model.locale, forum_id: Forum::HIDDEN_ID
    end
  end

  def down
    Collection.where(state: :unpublished).each do |model|
      model.topics.destroy_all
    end
  end
end
