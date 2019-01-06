class CreateCoubTags < ActiveRecord::Migration[5.2]
  def change
    create_table :coub_tags do |t|
      t.string :name, null: false
      t.timestamps
    end
  end
end
