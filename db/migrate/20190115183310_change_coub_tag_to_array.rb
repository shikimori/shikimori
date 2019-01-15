class ChangeCoubTagToArray < ActiveRecord::Migration[5.2]
  def change
    remove_column :animes, :coub_tag, :string
    add_column :animes, :coub_tags, :text, array: true, default: [], null: false
  end
end
