class CreateStylesForClubs < ActiveRecord::Migration[5.2]
  def up
    Club.order(:id).each do |club|
      puts club.id
      club.send :assign_style
    end
  end

  def down
    Style.where(owner_type: Club.name).destroy_all
  end
end
