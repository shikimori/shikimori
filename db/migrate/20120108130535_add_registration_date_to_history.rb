class AddRegistrationDateToHistory < ActiveRecord::Migration
  def self.up
    UserHistory.record_timestamps = false
    User.all.each do |user|
      UserHistory.create!({
        :user => user,
        :action => UserHistoryAction::Registration,
        :created_at => user.created_at,
        :updated_at => user.created_at
      })
    end
    UserHistory.record_timestamps = true
  end

  def self.down
    UserHistory.where(:action => UserHistoryAction::Registration).delete_all
  end
end
