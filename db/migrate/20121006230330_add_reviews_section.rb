
class AddReviewsSection < ActiveRecord::Migration
  def self.up
    Section.create! position: 10, name: 'Обзоры', description: 'Обзоры аниме и манги', permalink: 'r', meta_title: "Обзоры аниме и манги", meta_keywords: "Обзоры", meta_description: "Обсуждение обзоров аниме и манги."
  end

  def self.down
  end
end
