class ResetIndexesAfterLocalesRemoval < ActiveRecord::Migration[6.1]
  def change
    ArticlesIndex.reset!
    ClubsIndex.reset!
    CollectionsIndex.reset!
    TopicsIndex.reset!
  end
end
