class RemoveColumnDefaultFromPollsText < ActiveRecord::Migration[5.1]
  def up
    change_column_default :polls, :text, nil
  end

  def down
    change_column_default :polls, :text, ''
  end
end
