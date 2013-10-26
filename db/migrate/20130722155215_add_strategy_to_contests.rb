class AddStrategyToContests < ActiveRecord::Migration
  def change
    add_column :contests, :strategy_type, :string, null: false, default: Contest::DoubleEliminationStrategy.name
  end
end
