class AddReasonToVersions < ActiveRecord::Migration
  def change
    add_column :versions, :reason, :string
  end
end
