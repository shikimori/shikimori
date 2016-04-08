class AddScheduleToAnimes < ActiveRecord::Migration
  def change
    add_column :animes, :schedule, :string
  end
end
