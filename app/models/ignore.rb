class Ignore < ActiveRecord::Base
  belongs_to :user
  belongs_to :target, class_name: User.name, foreign_key: 'target_id'

  #before_create :mark_all_user_messages_as_read

  #def mark_all_user_messages_as_read
    #self.user.messages.where(src: self.target).update_all(read: true)
  #end
end
