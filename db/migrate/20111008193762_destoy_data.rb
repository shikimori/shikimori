class DestoyData < ActiveRecord::Migration
  def self.up
    Anime.destroy_all
    Character.destroy_all
    Person.destroy_all
  end

  def self.down
    Anime.destroy_all
    Character.destroy_all
    Person.destroy_all
  end
end
