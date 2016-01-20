class CreateNameMatches < ActiveRecord::Migration
  def change
    create_table :name_matches do |t|
      t.string :phrase, null: false
      t.string :group, null: false
      t.references :target, index: true, polymorphic: true, null: false
    end
  end
end
