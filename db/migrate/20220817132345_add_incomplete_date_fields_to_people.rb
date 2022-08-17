class AddIncompleteDateFieldsToPeople < ActiveRecord::Migration[6.1]
  def change
    add_column :people, :birth_on_v2, :jsonb, null: false, default: {}
  end
end
