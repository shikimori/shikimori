class MigrateBlogPostsToTopis < ActiveRecord::Migration
  def up
    Entry.where(type: 'BlogPost').update_all type: Topic.name
  end
end
