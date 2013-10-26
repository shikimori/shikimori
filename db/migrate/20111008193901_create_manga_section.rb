class CreateMangaSection < ActiveRecord::Migration
  def self.up
    Forum.find(1).update_attribute(:position, 1)
    Forum.find(2).update_attribute(:position, 3)
    Forum.find(3).update_attribute(:position, 4)
    Forum.find_or_create_by_id(4, :position => 2, :name => 'Все о манге')
    Section.find_or_create_by_id(6, :name => 'Манга', :description => "Обсуждение аниме и всего, что с этим связано", :forum_id => 4)
  end

  def self.down
  end
end
