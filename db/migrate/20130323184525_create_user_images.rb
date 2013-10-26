class CreateUserImages < ActiveRecord::Migration
  def change
    create_table :user_images do |t|
      t.references :user
      t.references :linked, polymorphic: true

      t.timestamps
    end
    add_index :user_images, :user_id
    add_index :user_images, [:linked_id, :linked_type]
  end
end
