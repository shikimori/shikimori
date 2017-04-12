class AddTopicPolicyToClubs < ActiveRecord::Migration[5.0]
  def change
    add_column :clubs, :topic_policy, :string,
      null: false,
      default: Types::Club::TopicPolicy[:members]
  end
end
