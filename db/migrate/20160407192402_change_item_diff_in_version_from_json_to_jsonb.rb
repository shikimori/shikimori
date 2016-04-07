class ChangeItemDiffInVersionFromJsonToJsonb < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up { change_column :versions, :item_diff, 'jsonb USING CAST(item_diff AS jsonb)' }
      dir.down { change_column :versions, :item_diff, 'json USING CAST(item_diff AS json)' }
    end
  end
end
