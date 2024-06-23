class AddRelationKindToAnimesAndMangas < ActiveRecord::Migration[7.0]
  def change
    [RelatedAnime, RelatedManga].each do |klass|
      add_column klass.table_name, :relation_kind, :string

      reversible do |dir|
        dir.up do
          execute(
            <<~SQL
              UPDATE #{klass.table_name}
                SET relation_kind = lower(replace(replace(relation, ' ', '_'), '-', '_'))
            SQL
          )
        end
        change_column klass.table_name, :relation_kind, :string, null: false
      end
    end
  end
end
