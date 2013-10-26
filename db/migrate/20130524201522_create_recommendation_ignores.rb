class CreateRecommendationIgnores < ActiveRecord::Migration
  def change
    create_table :recommendation_ignores do |t|
      t.references :user
      t.references :target, polymorphic: true
    end
    add_index :recommendation_ignores, :user_id
    add_index :recommendation_ignores, [:target_id, :target_type]
    add_index :recommendation_ignores, [:user_id, :target_id, :target_type], unique: true, name: 'index_recommendation_ignores_on_entry'
  end
end
