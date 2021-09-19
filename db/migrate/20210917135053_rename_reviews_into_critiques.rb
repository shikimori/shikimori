class RenameCritiquesIntoCritiques < ActiveRecord::Migration[5.2]
  def change
    rename_table :critiques, :critiques
  end
end
