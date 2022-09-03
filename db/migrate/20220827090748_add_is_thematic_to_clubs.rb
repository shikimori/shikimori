class AddIsThematicToClubs < ActiveRecord::Migration[6.1]
  def change
    add_column :clubs, :is_thematic, :boolean, null: false, default: true
  end
end
