class AddMalUrlToPosters < ActiveRecord::Migration[6.1]
  def change
    add_column :posters, :mal_url, :string
  end
end
