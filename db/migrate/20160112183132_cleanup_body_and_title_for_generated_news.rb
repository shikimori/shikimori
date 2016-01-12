class CleanupBodyAndTitleForGeneratedNews < ActiveRecord::Migration
  def change
    Topics::NewsTopic
      .where(generated: true)
      .update_all(title: nil, body: nil)
  end
end
