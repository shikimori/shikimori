class RenameEntryLinkedTypeInMessages < ActiveRecord::Migration
  def up
    Message
      .where(linked_type: 'Entry')
      .where('created_at > ?', 1.week.ago)
      .update_all(linked_type: 'Topic')
  end

  def down
    Message
      .where(linked_type: 'Topic')
      .where('created_at > ?', 1.week.ago)
      .update_all(linked_type: 'Entry')
  end
end
