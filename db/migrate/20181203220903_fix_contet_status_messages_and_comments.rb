class FixContetStatusMessagesAndComments < ActiveRecord::Migration[5.2]
  def up
    Comment
      .where(user_id: 4261)
      .each do |v|
        v.body = v.body
          .gsub(/\[(contest_status=\d+)\]/, '[\1 finished]')
          .gsub(/\[(contest_round_status=\d+)\]/, '[\1 finished]')
        v.save if v.changed?
      end
  end

  def down
    Comment
      .where(user_id: 4261)
      .each do |v|
        v.body = v.body
          .gsub(/\[(contest_status=\d+) (?:started|finished)\]/, '[\1]')
          .gsub(/\[(contest_roundustatus=\d+) (?:started|finished)\]/, '[\1]')
        v.save if v.changed?
      end
  end
end
