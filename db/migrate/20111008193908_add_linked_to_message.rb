class AddLinkedToMessage < ActiveRecord::Migration
  def self.up
    rename_column :messages, :anime_history_id, :linked_id
    add_column :messages, :linked_type, :string

    ActiveRecord::Base.connection.
      execute("
               update
                 messages m
                   inner join entries e
                     on e.id = m.linked_id
                 set m.linked_type = e.type
              ")

  end

  def self.down
    remove_column :messages, :linked_type
    rename_column :messages, :linked_id, :anime_history_id
  end
end
