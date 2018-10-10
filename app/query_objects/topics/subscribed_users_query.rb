class Topics::SubscribedUsersQuery
  method_object :topic

  USER_RATES_SQL = <<~SQL.squish
    #{UserRate.table_name}.target_type = :target_type and
      #{UserRate.table_name}.target_id = :target_id
  SQL

  def call # rubocop:disable MethodLength
    if @topic.broadcast?
      all_scope

    elsif anons?
      users_scope Types::User::NotificationSettings[:any_anons], nil

    elsif ongoing?
      users_scope(
        Types::User::NotificationSettings[:any_ongoing],
        Types::User::NotificationSettings[:my_ongoing]
      )

    elsif episode?
      users_scope nil, Types::User::NotificationSettings[:my_episode]

    elsif released?
      users_scope(
        Types::User::NotificationSettings[:any_released],
        Types::User::NotificationSettings[:my_released]
      )

    else
      none_scope
    end
  end

private

  def all_scope
    User.all
  end

  def none_scope
    User.none
  end

  def anons?
    @topic.action == Types::Topic::NewsTopic::Action[AnimeHistoryAction::Anons]
  end

  def ongoing?
    @topic.action == Types::Topic::NewsTopic::Action[AnimeHistoryAction::Ongoing]
  end

  def episode?
    @topic.action == Types::Topic::NewsTopic::Action[AnimeHistoryAction::Episode]
  end

  def released?
    @topic.action == Types::Topic::NewsTopic::Action[AnimeHistoryAction::Released]
  end

  def users_scope any_key, my_key
    if any_key && my_key
      any_scope(any_key).or(my_scope(my_key))

    elsif any_key
      any_scope any_key

    elsif my_key
      my_scope my_key
    end
  end

  def any_scope key
    User.where("notification_settings && '{#{key}}'")
  end

  def my_scope key
    scope = User
      .where("notification_settings && '{#{key}}'")
      .joins(:anime_rates)
      .where(
        USER_RATES_SQL,
        target_type: @topic.linked_type,
        target_id: @topic.linked_id
      )
      .group(:user_id)
      .select(:user_id)

    User.where(id: scope)
  end
end
