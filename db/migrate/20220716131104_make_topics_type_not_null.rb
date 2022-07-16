class MakeTopicsTypeNotNull < ActiveRecord::Migration[6.1]
  def change
    change_column_null :topics, :type, false
  end
end
