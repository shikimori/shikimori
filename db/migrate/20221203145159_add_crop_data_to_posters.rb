class AddCropDataToPosters < ActiveRecord::Migration[6.1]
  def change
    add_column :posters, :crop_data, :jsonb, null: false, default: {}
  end
end
