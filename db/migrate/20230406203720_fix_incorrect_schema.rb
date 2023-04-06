class FixIncorrectSchema < ActiveRecord::Migration[6.1]
  def up
    if Critique.column_names.include? 'comment_id' # fixing incorrect schema
      remove_column :critiques, :comment_id, :bigint
    end

    if ActiveRecord::Base.connection.data_sources.include? 'summary_viewings'
      drop_table :summary_viewings
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
