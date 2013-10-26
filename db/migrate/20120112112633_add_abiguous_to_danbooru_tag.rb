class AddAbiguousToDanbooruTag < ActiveRecord::Migration
  def self.up
    add_column :danbooru_tags, :ambiguous, :boolean

    DanbooruTag.delete_all
    DanbooruTag.import_from_danbooru 999999
  end

  def self.down
    remove_column :danbooru_tags, :ambiguous
  end
end
