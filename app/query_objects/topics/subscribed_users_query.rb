class Topics::SubscribedUsersQuery
  method_object :topic

  USER_RATES_SQL = <<~SQL.squish
    #{UserRate.table_name}.target_type = :target_type and
      #{UserRate.table_name}.target_id = :target_id
  SQL

  def call
    if @topic.broadcast?
      User.all

    elsif @topic.action == Types::Topic::NewsTopic::Action[AnimeHistoryAction::Anons]
      users_scope Types::User::NotificationSettings[:any_anons], nil

    elsif @topic.action == Types::Topic::NewsTopic::Action[AnimeHistoryAction::Ongoing]
      users_scope(
        Types::User::NotificationSettings[:any_ongoing],
        Types::User::NotificationSettings[:my_ongoing]
      )

    elsif @topic.action == Types::Topic::NewsTopic::Action[AnimeHistoryAction::Episode]
      users_scope nil, Types::User::NotificationSettings[:my_episode]

    elsif @topic.action == Types::Topic::NewsTopic::Action[AnimeHistoryAction::Released]
      users_scope(
        Types::User::NotificationSettings[:any_released],
        Types::User::NotificationSettings[:my_released]
      )

    else
      User.none
    end
  end

private

  def users_scope any_key, my_key
    User.where("notification_settings && '{#{any_key}}'")

      # .joins(:user_rates)
      # .wher(
      #   USER_RATES_SQL,
      #   target_type: @topic.target_type,
  end
end
