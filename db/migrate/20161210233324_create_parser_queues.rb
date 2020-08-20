class CreateParserQueues < ActiveRecord::Migration[5.2]
  def change
    create_table :parser_queues do |t|
      t.string :url, null: false
      t.string :kind, null: false

      t.datetime :attempted_at, null: true
      t.datetime :created_at, null: false
    end
  end
end
