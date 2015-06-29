class ChangeDiffToJsonInVersions < ActiveRecord::Migration
  def up
    add_column :versions, :fields, :json

    Version.all.each do |version|
      puts version.id
      version.update fields: JSON.parse(version.item_diff.gsub(/:(\w+)=>/, '"\1":').gsub(/\bnil\b/, 'null'))
    end

    remove_column :versions, :item_diff
    rename_column :versions, :fields, :item_diff
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
