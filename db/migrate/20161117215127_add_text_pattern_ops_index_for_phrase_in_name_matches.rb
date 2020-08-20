class AddTextPatternOpsIndexForPhraseInNameMatches < ActiveRecord::Migration[5.2]
  def up
    ApplicationRecord.connection.execute <<-SQL.strip
      create index target_type_phrase_search_index on name_matches (
        target_type,
        phrase varchar_pattern_ops
      )
    SQL
  end

  def down
    ApplicationRecord.connection.execute <<-SQL.strip
      drop index target_type_phrase_search_index
    SQL
  end
end
