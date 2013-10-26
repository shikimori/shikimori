class ChangeViewsIndexes < ActiveRecord::Migration
  def self.up
    [:entry, :comment, :review].each do |kind|
      klass = "#{kind.capitalize}View".constantize
      klass.connection
           .execute("select max(#{kind}_id), max(user_id) from #{kind}_views group by user_id, #{kind}_id having count(*) > 1")
           .each do |v|
             klass.connection.execute("delete from #{kind}_views where #{kind}_id=#{v[0]} and user_id=#{v[1]} limit 1")
           end
      remove_index "#{kind}_views", [:user_id, "#{kind}_id"]
      add_index "#{kind}_views", [:user_id, "#{kind}_id"], :unique => true
    end
  end

  def self.down
  end
end
