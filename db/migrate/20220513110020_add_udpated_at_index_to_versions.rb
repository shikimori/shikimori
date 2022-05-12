class AddUdpatedAtIndexToVersions < ActiveRecord::Migration[6.1]
  def change
    add_index :versions, :updated_at, order: { updated_at: :desc }
  end
end
