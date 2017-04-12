class RemoveDefaultsFromTopicTopilcy < ActiveRecord::Migration[5.0]
  def up
    change_column_default :clubs, :topic_policy, nil
  end

  def down
    change_column_default(
      :clubs,
      :topic_policy,
      Types::Club::TopicPolicy[:members]
    )
  end
end
