class MergeWorldArtWithAnimes < ActiveRecord::Migration
  def self.up
    WorldArtParser.new.merge_with_database
  end

  def self.down
  end
end
