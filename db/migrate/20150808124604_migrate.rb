class Migrate < ActiveRecord::Migration
  def up
    UserChange
      .where(column: 'russian')
      .each do |user_change|
        
      end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
