class AddIsApprovedToPosters < ActiveRecord::Migration[6.1]
  def change
    add_column :posters, :is_approved, :boolean,
      null: false,
      default: true,
      index: true
  end
end
