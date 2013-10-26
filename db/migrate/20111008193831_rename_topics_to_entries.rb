class RenameTopicsToEntries < ActiveRecord::Migration
  def self.up
    ActiveRecord::Base.transaction do
      rename_table :topics, :entries
      rename_table :topic_views, :entry_views
      rename_column :entry_views, :topic_id, :entry_id

      add_column :entries, :type, :string

      rename_column :entries, :subject, :title
      add_column :entries, :text, :text

      add_column :entries, :in_forum, :boolean, :default => true

      add_column :entries, :linked_id, :integer
      add_column :entries, :linked_type, :string
      add_column :entries, :processed, :boolean, :default => false
      add_column :entries, :action, :string
      add_column :entries, :value, :string

      ActiveRecord::Base.connection.execute("update entries set type='Topic',in_forum=1");
      ActiveRecord::Base.connection.execute("update comments set commentable_type='Entry' where commentable_type='Topic'");

      #add_index :entries, :type
      #add_index :entries, :in_forum
      #add_index :entries, [:in_forum, :type]


      #create_table :news do |t|
        #t.integer :user_id
        #t.string :type

        #t.string :permalink

        #t.string :title
        #t.text :text

        #t.integer :page_views_counter, :default => 0

        #t.boolean :in_forum

        #t.integer :linked_id
        #t.string :linked_type
        #t.boolean :processed, :default => false
        #t.string :action
        #t.string :value

        #t.timestamps
      #end
      #add_index :news, :page_views_counter
      #add_index :news, :in_forum
      #add_index :news, [:in_forum, :type]

      #create_table :news_views do |t|
        #t.integer :news_id
        #t.integer :user_id
        #t.integer :comment_id

        #t.timestamps
      #end
    end
  end

  def self.down
    ActiveRecord::Base.transaction do
      remove_column :entries, :linked_id
      remove_column :entries, :linked_type
      remove_column :entries, :processed
      remove_column :entries, :action
      remove_column :entries, :value

      remove_column :entries, :in_forum

      remove_column :entries, :text

      rename_column :entries, :title, :subject

      remove_column :entries, :type

      rename_column :entry_views, :entry_id, :topic_id
      rename_table :entry_views, :topic_views
      rename_table :entries, :topics
    end
  end
end
