class NewForum < ActiveRecord::Migration
  def self.up
    add_column :forums, :visible, :boolean, :default => true
    Forum.where(:id.not_eq => 2).update_all(:visible => false)
    forum = Forum.create(:position => 1, :name => 'Обсуждение')
    Section.find(1).update_attributes(:forum_id => forum.id, :position => 1)
    Section.find(6).update_attributes(:forum_id => forum.id, :position => 2)
    Section.create(:position => 3, :name => 'Персонажи', :position => 3, :forum_id => forum.id, :description => 'Обсуждение персонажей аниме и манги')
    Character.find_each(:batch_size => 5000) do |char|
      char.create_comment_entry
    end
  end

  def self.down
    remove_column :forums, :visible
    Section.find(1).update_attributes(:forum_id => 1)
    Section.find(6).update_attributes(:forum_id => 4)
    Section.where(:name => 'Персонажи').destroy
  end
end
