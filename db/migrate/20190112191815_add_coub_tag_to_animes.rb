class AddCoubTagToAnimes < ActiveRecord::Migration[5.2]
  def change
    add_column :animes, :coub_tag, :string
  end
end
