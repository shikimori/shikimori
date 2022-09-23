require Rails.root.join('db/migrate/20220923164130_add_incomplete_date_fields_to_models')

class MigrateIncompleteDatesInModels < ActiveRecord::Migration[6.1]
  MODELS = AddIncompleteDateFieldsToModels::MODELS

  def up
    MODELS.each do |klass, fields|
      puts "migrating #{klass.name}"

      klass.find_each do |model|
        puts "#{klass.name} #{model.id}" if Rails.env.development?

        fields.each do |field|
          value = model.send field
          next if value.nil?

          model.send :"#{field}_v2=", IncompleteDate.new(
            year: (value.year unless value.year == 1901),
            month: value.month,
            day: value.day
          )
        end

        model.save!
      end
    end
  end

  def down
    MODELS.each do |klass, fields|
      puts "rolling back #{klass.name}"

      klass.find_each do |model|
        puts "#{klass.name} #{model.id}" if Rails.env.development?

        fields.each do |field|
          value = model.send :"#{field}_v2"
          next if value.nil?

          model.send :"#{field}=", Date.new(value.year || 1901, value.month, value.day)
        end

        model.save!
      end
    end
  end
end
