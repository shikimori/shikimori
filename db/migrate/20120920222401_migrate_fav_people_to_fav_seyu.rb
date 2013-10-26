class MigrateFavPeopleToFavSeyu < ActiveRecord::Migration
  def self.up
    Favourite.where(linked_type: Person.name).update_all(kind: Favourite::Seyu)
  end

  def self.down
  end
end
