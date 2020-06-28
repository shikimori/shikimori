class FixBrokenVersions < ActiveRecord::Migration[5.2]
  def up
    Version.where('(item_diff->>:field) is not null', field: 'description').each do |version|
      version.item_diff['description_ru'] = version.item_diff['description']
      version.item_diff.delete 'description'
      version.save!
    end
  end
end
