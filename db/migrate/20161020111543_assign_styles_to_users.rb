class AssignStylesToUsers < ActiveRecord::Migration[5.2]
  def up
    User.includes(:styles).find_each do |user|
      puts "processing user #{user.id}"
      user.update_column :style_id, user.styles.first.id if user.styles.any?
    end
  end

  def down
    User.update_all style_id: nil
  end
end
