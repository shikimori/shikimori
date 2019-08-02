class CleanupTags < ActiveRecord::Migration[5.2]
  def change
    ActsAsTaggableOn::Tag.destroy_all
  end
end
