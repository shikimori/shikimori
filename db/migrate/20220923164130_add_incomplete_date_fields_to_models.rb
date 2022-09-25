class AddIncompleteDateFieldsToModels < ActiveRecord::Migration[6.1]
  MODELS = {
    Anime => %i[aired_on released_on digital_released_on russia_released_on],
    Manga => %i[aired_on released_on], 
    Person => %i[birth_on deceased_on]
  }

  def change
    MODELS.each do |klass, fields|
      fields.each do |field|
        add_column klass.table_name, :"#{field}_v2", :jsonb,
          null: false,
          default: {}
      end
    end
  end
end
