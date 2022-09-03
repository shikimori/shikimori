class AddIsShadowbannedToClubs < ActiveRecord::Migration[6.1]
  def change
    add_column :clubs, :is_shadowbanned, :boolean, null: false, default: false
  end
end
