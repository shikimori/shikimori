class RenamePollVariantsTextToLabel < ActiveRecord::Migration[5.1]
  def change
    rename_column :poll_variants, :text, :label
  end
end
