class AddKindToGenres < ActiveRecord::Migration
  def up
    add_column :genres, :kind, :string
    Genre.update_all kind: 'anime'
    change_column :genres, :kind, :string, null: false
  end

  def down
    remove_column :genres, :kind
  end
end
