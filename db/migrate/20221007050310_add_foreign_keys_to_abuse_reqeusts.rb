class AddForeignKeysToAbuseReqeusts < ActiveRecord::Migration[6.1]
  def change
    reversible do |dir|
      dir.up do
        AbuseRequest
          .where.not(comment_id: nil)
          .left_joins(:comment)
          .where(comments: { id: nil })
          .delete_all
        AbuseRequest
          .where.not(topic_id: nil)
          .left_joins(:topic)
          .where(topics: { id: nil })
          .delete_all
        Ban
          .where.not(abuse_request_id: nil)
          .left_joins(:abuse_request)
          .where(abuse_requests: { id: nil })
          .update_all abuse_request_id: nil
      end
    end

    add_foreign_key :abuse_requests, :comments
    add_foreign_key :abuse_requests, :topics
    add_foreign_key :bans, :abuse_requests
  end
end
