class AddDeletedAtToPosters < ActiveRecord::Migration[6.1]
  def change
    add_column :posters, :deleted_at, :datetime, null: true
  end
end
