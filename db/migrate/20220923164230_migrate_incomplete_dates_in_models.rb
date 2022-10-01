require Rails.root.join('db/migrate/20220923164130_add_incomplete_date_fields_to_models')

class MigrateIncompleteDatesInModels < ActiveRecord::Migration[6.1]
  MODELS = AddIncompleteDateFieldsToModels::MODELS
  NO_YEAR = 1901 # IncompleteDate::NO_YEAR

  def change
    MODELS.each do |klass, fields|
      puts "migrating #{klass.name}"

      fields.each do |field|
        reversible do |dir|
          dir.up do
                  # 'year', case when date_part('year', #{field}) = #{NO_YEAR} then null else date_part('year', #{field}) end,
            execute %Q[
              update #{klass.table_name}
                set #{field}_v2 = jsonb_build_object(
                  'year', date_part('year', #{field}),
                  'month', date_part('month', #{field}),
                  'day', date_part('day', #{field})
                )
                where #{field} is not null
            ]
          end

          dir.down do
                  # (case when #{field}_v2->>'year' is null then '#{NO_YEAR}' else #{field}_v2->>'year' end)::int,
            execute %Q[
              update #{klass.table_name}
                set #{field} = make_date(
                  (#{field}_v2->>'year')::int,
                  (#{field}_v2->>'month')::int,
                  (#{field}_v2->>'day')::int
                )
                where #{field}_v2 is not null
            ]
          end
        end
      end
    end
  end
end
