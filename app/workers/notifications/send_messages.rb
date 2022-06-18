class Notifications::SendMessages
  include Sidekiq::Worker

  sidekiq_options(
    lock: :until_executed,
    lock_args_method: ->(args) { args.to_json },
    queue: :history_jobs
  )

  def perform message_attributes, user_ids
    messages = build_messages message_attributes, user_ids
    Message.wo_timestamp do
      Message.import messages, validate: false
    end
    messages
  end

private

  def build_messages message_attributes, user_ids
    user_ids.map do |user_id|
      Message.new(message_attributes) do |message|
        message.to_id = user_id
      end
    end
  end
end
