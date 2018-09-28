class CreateUserRatesLogs < ActiveRecord::Migration[5.2]
  def change
    create_table :user_rates_logs do |t|
      t.references :user, null: false, index: true
      t.references :target, null: true, polymorphic: true
      t.jsonb :diff

      t.references :oauth_application
      t.string :user_agent, null: false
      t.inet :ip, null: false

      t.datetime :created_at
    end
  end
end
