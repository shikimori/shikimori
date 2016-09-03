class RenameEntryLinkedTypeInMessages < ActiveRecord::Migration
  def up
    Message.where(linked_type: 'Entry').update_all(linked_type: 'Topic')
  end

  def down
    Message.where(linked_type: 'Topic').update_all(linked_type: 'Entry')
  end
end
