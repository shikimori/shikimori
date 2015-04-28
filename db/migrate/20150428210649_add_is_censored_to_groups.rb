class AddIsCensoredToGroups < ActiveRecord::Migration
  def change
    add_column :groups, :is_censored, :boolean, default: false, null: false
  end
end
