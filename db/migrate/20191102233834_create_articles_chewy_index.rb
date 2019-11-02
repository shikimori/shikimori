class CreateArticlesChewyIndex < ActiveRecord::Migration[5.2]
  def change
    ArticlesIndex.reset!
  end
end
