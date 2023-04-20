class AddIsActiveToGenres < ActiveRecord::Migration[6.1]
  def change
    add_column :genres, :is_active, :boolean

    reversible do |dir|
      dir.up do
        execute %q[update genres set is_active = true]
        change_column :genres, :is_active, :boolean, null: false
      end
    end
  end
end
