class MakeTopicsTypeNotNull < ActiveRecord::Migration[6.1]
  def change
    reversible do |dir|
      dir.up do
        execute %q[update topics set type='Topic' where type is null]
      end
    end

    change_column_null :topics, :type, false
  end
end
