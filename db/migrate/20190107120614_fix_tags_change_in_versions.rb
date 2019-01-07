class FixTagsChangeInVersions < ActiveRecord::Migration[5.2]
  def up
    Version.where("(item_diff->>'tags') is not null").each do |version|
      version.update item_diff: { 'imageboard_tag' => version.item_diff['tags'] }
    end
  end

  def down
    Version.where("(item_diff->>'imageboard_tag') is not null").each do |version|
      version.update item_diff: { 'tags' => version.item_diff['imageboard_tag'] }
    end
  end
end
