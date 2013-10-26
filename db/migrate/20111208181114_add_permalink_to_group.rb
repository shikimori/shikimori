class AddPermalinkToGroup < ActiveRecord::Migration
  def self.up
    add_column :groups, :permalink, :string

    Group.all.each do |group|
      group.update_attribute(:permalink, Russian.translit(group.name.gsub(/[^A-zА-я0-9]/, '-').gsub(/-+/, '-').sub(/-$|^-/, '')))
    end
  end

  def self.down
    remove_column :groups, :permalink
  end
end
