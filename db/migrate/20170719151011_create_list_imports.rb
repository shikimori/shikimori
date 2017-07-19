class CreateListImports < ActiveRecord::Migration[5.1]
  def change
    create_table :list_imports do |t|
      t.references :user, null: false, index: true
      t.attachment :list, null: false

      t.timestamps
    end
  end
end
