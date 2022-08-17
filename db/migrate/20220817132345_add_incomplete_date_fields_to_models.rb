class AddIncompleteDateFieldsToModels < ActiveRecord::Migration[6.1]
  MODELS = {
    Person => %i[birth_on deceased_on]
  }

  def change
    MODELS.each do |klass, fields|
      fields.each do |field|
        add_column klass.table_name, :"#{field}_v2", :jsonb, null: true
      end
    end
  end
end
