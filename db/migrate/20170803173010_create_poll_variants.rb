class CreatePollVariants < ActiveRecord::Migration[5.1]
  def change
    create_table :poll_variants do |t|
      t.references :poll, null: false, index: true
      t.text :text
    end
  end
end
