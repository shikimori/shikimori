class CleanupCollectionTags < ActiveRecord::Migration[6.1]
  def up
    Collection.find_each do |collection|
      next if collection.tags.blank?

      tags_before = collection.tags
      collection.tags = tags_before
      collection.tags = collection.tags.uniq
      tags_after = collection.tags

      if tags_before != tags_after
        puts "#{tags_before.join ','} => #{tags_after.join ','}"
        collection.save!
      end
    end
  end
end
