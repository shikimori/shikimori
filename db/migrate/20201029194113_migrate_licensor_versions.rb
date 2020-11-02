class MigrateLicensorVersions < ActiveRecord::Migration[5.2]
  def change
    Version
      .where('(item_diff->>:field) is not null', field: 'licensor')
      .find_each do |version|
        old_item_diff = version.item_diff
        version.item_diff = {
          "licensors" => [
            old_item_diff['licensor'][0].blank? ? [] : [old_item_diff['licensor'][0]],
            old_item_diff['licensor'][1].blank? ? [] : [old_item_diff['licensor'][1]],
          ]
        }
        version.save!
      end
  end
end
