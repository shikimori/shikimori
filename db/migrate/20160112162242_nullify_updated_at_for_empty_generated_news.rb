class NullifyUpdatedAtForEmptyGeneratedNews < ActiveRecord::Migration
  def change
    Entry
      .where(generated: true, comments_count: 0, type: Topics::NewsTopic.name)
      .update_all(updated_at: nil)
  end
end
