class FixContetStatusMessagesAndComments < ActiveRecord::Migration[5.2]
  def up
    Comment
      .where(user_id: 4261)
      .each do |v|
        v.body = v.body
          .gsub('[contest_status', '[contest_finished]')
          .gsub('[contest_round_status', '[contest_round_finished]');
        v.save if v.changed?
      end
  end

  def down
    Comment
      .where(user_id: 4261)
      .each do |v|
        v.body = v.body
          .gsub('[contest_finished', '[contest_status]')
          .gsub('[contest_round_finished', '[contest_round_status]');
        v.save if v.changed?
      end
  end
end
