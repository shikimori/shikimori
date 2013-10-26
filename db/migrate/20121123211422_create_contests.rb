class CreateContests < ActiveRecord::Migration
  def self.up
    create_table :contests do |t|
      t.string :title
      t.text :description
      t.integer :user_id
      t.string :state, default: 'created'
      t.date :started_on
      t.integer :votes_per_round
      t.integer :vote_duration
      t.integer :vote_interval
      t.integer :wave_days

      t.timestamps
    end
  end

  def self.down
    drop_table :contests
  end
end
