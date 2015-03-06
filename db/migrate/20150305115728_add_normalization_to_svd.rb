class AddNormalizationToSvd < ActiveRecord::Migration
  def change
    add_column :svds, :normalization, :string
  end
end
