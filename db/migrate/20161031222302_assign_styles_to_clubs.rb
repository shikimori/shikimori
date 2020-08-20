class AssignStylesToClubs < ActiveRecord::Migration[5.2]
  def up
    Club.includes(:styles).find_each do |club|
      puts "processing club #{club.id}"
      club.update_column :style_id, club.styles.first.id if club.styles.any?
    end
  end

  def down
    Club.update_all style_id: nil
  end
end
