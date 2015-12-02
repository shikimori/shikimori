class MigrateTextDiffVersions < ActiveRecord::Migration
  def up
    Versions::DescriptionVersion.find_each do |version|
      next if version.item_diff['description_ru']
      version.item_diff = version.item_diff.clone
      version.item_diff['description_ru'] ||= version.item_diff['description']
      version.item_diff.delete 'description'
      version.save
      puts version.id
    end
  end

  def down
    Versions::DescriptionVersion.find_each do |version|
      next if version.item_diff['description_ru']
      version.item_diff = version.item_diff.clone
      version.item_diff['description'] ||= version.item_diff['description_ru']
      version.item_diff.delete 'description_ru'
      version.save
      puts version.id
    end
  end
end
