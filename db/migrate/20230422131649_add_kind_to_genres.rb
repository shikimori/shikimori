class AddKindToGenres < ActiveRecord::Migration[6.1]
  def change
    add_column :genres, :kind, :string

    reversible do |dir|
      dir.up do
        execute %q[update genres set kind = 'genre']
        change_column :genres, :kind, :string, null: false
      end
    end
  end
end
