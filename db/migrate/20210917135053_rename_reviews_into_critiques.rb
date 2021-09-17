class RenameCritiquesIntoCritiques < ActiveRecord::Migration[5.2]
  def change
    rename_table :reviews, :critiques
  end
end
