class AddIncompleteDateComputedFieldsToAnimesAndMangas < ActiveRecord::Migration[6.1]
  def change
    %i[animes mangas].each do |table_name|
      add_column table_name, :aired_on_computed, :date
      reversible do |dir|
        dir.up do
          execute %Q[
            update #{table_name}
              set aired_on_computed = make_date(
                (case when aired_on->>'year' is null then '1901' else aired_on->>'year' end)::int,
                (case when aired_on->>'month' is null then '1' else aired_on->>'month' end)::int,
                (case when aired_on->>'day' is null then '1' else aired_on->>'day' end)::int
              )
              where aired_on != '{}'
          ]
        end
      end
    end
  end
end
