class MigrateThematicValues < ActiveRecord::Migration[6.1]
  def change
    change_column_default :clubs, :is_non_thematic, from: true, to: false
    execute %q[
      update clubs set is_non_thematic = not is_non_thematic
    ]
  end
end
