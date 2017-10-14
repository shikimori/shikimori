class AddStudioIdsToAnimes < ActiveRecord::Migration[5.1]
  def change
    add_column :animes, :studio_ids, :integer,
      array: true,
      null: false,
      default: []
  end
end
