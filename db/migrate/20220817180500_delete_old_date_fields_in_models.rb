require Rails.root.join('db/migrate/20220817132345_add_incomplete_date_fields_to_models')

class DeleteOldDateFieldsInModels < ActiveRecord::Migration[6.1]
  MODELS = AddIncompleteDateFieldsToModels::MODELS

  def change
    MODELS.each do |klass, fields|
      fields.each do |field|
        remove_column klass.table_name, field, :date
      end
    end
  end
end
