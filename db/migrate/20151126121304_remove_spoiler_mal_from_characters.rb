class RemoveSpoilerMalFromCharacters < ActiveRecord::Migration
  def change
    remove_column :characters, :spoiler_mal, :text
  end
end
