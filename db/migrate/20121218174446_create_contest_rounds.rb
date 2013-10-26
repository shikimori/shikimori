class CreateContestRounds < ActiveRecord::Migration
  def self.up
    create_table :contest_rounds do |t|
      t.integer :contest_id
      t.string :state, default: 'created'
      t.integer :number
      t.boolean :additional

      t.timestamps
    end

    add_index :contest_rounds, :contest_id
  end

  def self.down
    drop_table :contest_rounds
  end
end
