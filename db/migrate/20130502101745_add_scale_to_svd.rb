class AddScaleToSvd < ActiveRecord::Migration
  def change
    add_column :svds, :scale, :string, default: Svd::Full
  end
end
