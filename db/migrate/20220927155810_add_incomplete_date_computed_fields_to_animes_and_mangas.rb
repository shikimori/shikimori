class AddIncompleteDateComputedFieldsToAnimesAndMangas < ActiveRecord::Migration[6.1]
  def change
    %i[animes mangas].each do |table_name|
      %i[aired_on released_on].each do |field|
        add_column table_name, :"#{field}_computed", :date
        reversible do |dir|
          dir.up do
            execute %Q[
              update #{table_name}
                set #{field}_computed = make_date(
                  (case when #{field}->>'year' is null then '1901' else #{field}->>'year' end)::int,
                  (case when #{field}->>'month' is null then '1' else #{field}->>'month' end)::int,
                  (case when #{field}->>'day' is null then '1' else #{field}->>'day' end)::int
                )
                where #{field} != '{}'
            ]
          end
        end
      end
    end
  end
end
