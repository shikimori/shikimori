class DropTags < ActiveRecord::Migration[5.2]
  def change
    drop_table 'tags', id: :serial, force: :cascade do |t|
      t.string 'name', limit: 255
    end
  end
end
