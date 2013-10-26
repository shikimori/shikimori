class MoveFirstTopicCommentToText < ActiveRecord::Migration
  def self.up
    Entry.where(:type => 'Topic').all.each do |topic|
      topic.update_attributes(text: topic.comment_threads.last.body)
      topic.comment_threads.last.destroy
    end
  end

  def self.down
    raise ActiveRecord::IrreversibleMigration
  end
end
