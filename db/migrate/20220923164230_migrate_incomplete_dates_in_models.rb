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
            execute %Q[
              update people
                set #{field}_v2 = jsonb_build_object(
                  'year', case when date_part('year', birth_on) = #{NO_YEAR} then null else date_part('year', birth_on) end,
                  'month', date_part('month', birth_on),
                  'day', date_part('day', birth_on)
                )
                where #{field} is not null
            ]
          end

          dir.down do
            execute %Q[
              update people
                set #{field} = make_date(
                  (case when #{field}_v2->>'year' is null then '#{NO_YEAR}' else #{field}_v2->>'year' end)::int,
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
