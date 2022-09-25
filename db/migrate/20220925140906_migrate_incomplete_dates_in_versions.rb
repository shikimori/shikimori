require Rails.root.join('db/migrate/20220923164130_add_incomplete_date_fields_to_models')

class MigrateIncompleteDatesInVersions < ActiveRecord::Migration[6.1]
  MODELS = AddIncompleteDateFieldsToModels::MODELS

  def change
    MODELS.each do |klass, fields|
      fields.each do |field|
        puts "migrating #{klass.name} #{field} versions"

        scope = Version.where(item_type: klass.name).where('(item_diff->>:field) is not null', field: field)
        reversible do |dir|
          dir.up do
            scope.each do |version|
              version.update_column :item_diff, {
                field => version.item_diff[field.to_s].map { |date| IncompleteDate.parse(date).to_h }
              }
            end
          end
          dir.down do
            scope.each do |version|
              version.update_column :item_diff, {
                field => version.item_diff[field.to_s].map { |date| IncompleteDate.parse(date).date.to_s }
              }
            end
          end
        end
      end
    end
  end
end
