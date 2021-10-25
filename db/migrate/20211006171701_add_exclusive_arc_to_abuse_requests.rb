class AddExclusiveArcToAbuseRequests < ActiveRecord::Migration[5.2]
  def up
    add_column :abuse_requests, :topic_id, :integer
    add_column :abuse_requests, :review_id, :integer

    remove_index :abuse_requests, name: :index_abuse_requests_on_comment_id_and_kind_and_value
    remove_foreign_key :abuse_requests, :comments

    change_column :abuse_requests, :comment_id, :integer, null: true

    add_index :abuse_requests, :comment_id
    add_index :abuse_requests, :topic_id
    add_index :abuse_requests, :review_id
    add_index :abuse_requests, %i[comment_id kind value],
      name: "index_abuse_requests_on_comment_id_and_kind_and_value",
      unique: true,
      where: "comment_id is not null and state::text = 'pending'::text"
    add_index :abuse_requests, %i[topic_id kind value],
      name: "index_abuse_requests_on_topic_id_and_kind_and_value",
      unique: true,
      where: "topic_id is not null and state::text = 'pending'::text"
    add_index :abuse_requests, %i[review_id kind value],
      name: "index_abuse_requests_on_review_id_and_kind_and_value",
      unique: true,
      where: "review_id is not null and state::text = 'pending'::text"
  end

  def down
    remove_column :abuse_requests, :topic_id, :integer
    remove_column :abuse_requests, :review_id, :integer

    remove_index :abuse_requests, name: :index_abuse_requests_on_comment_id_and_kind_and_value
    remove_index :abuse_requests, :comment_id

    add_foreign_key :abuse_requests, :comments
    change_column :abuse_requests, :comment_id, :integer, null: false

    add_index :abuse_requests, %i[comment_id kind value],
      name: "index_abuse_requests_on_comment_id_and_kind_and_value",
      unique: true,
      where: "((state)::text = 'pending'::text)"
  end
end
