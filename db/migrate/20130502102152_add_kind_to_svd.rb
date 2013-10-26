class AddKindToSvd < ActiveRecord::Migration
  def change
    add_column :svds, :kind, :string
  end
end
