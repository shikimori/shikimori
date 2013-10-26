require 'active_record/fixtures'

class LoadMalGenres < ActiveRecord::Migration
  def self.up
    #down
    #directory = File.join(File.dirname(__FILE__), 'dev_data')
    #Fixtures.create_fixtures(directory, "genres")
  end

  def self.down
    #Genre.delete_all
  end
end
