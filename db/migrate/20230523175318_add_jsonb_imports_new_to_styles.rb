class AddJsonbImportsNewToStyles < ActiveRecord::Migration[6.1]
  def change
    add_column :styles, :imports_new, :jsonb
    reversible do |dir|
      dir.up do
        puts "Styles: #{Style.count}, max_id: #{Style.order(:id).last&.id}"
        Style.find_each do |style|
          puts style.id
          style.update_column :imports_new, style.imports&.index_with { |_v| 1 }
        end
      end
    end
    remove_column :styles, :imports
    rename_column :styles, :imports_new, :imports
  end
end
