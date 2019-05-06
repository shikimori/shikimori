class RenameCloverworks < ActiveRecord::Migration[5.2]
  def change
    Club.find_by(name: 'CLOVERWORKS')&.update name: 'CloverWorks'
  end
end
