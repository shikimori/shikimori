class CleanupTags < ActiveRecord::Migration[5.2]
  def change
    if defined? ActsAsTaggableOn::Tag
      ActsAsTaggableOn::Tag.destroy_all
    end
  end
end
