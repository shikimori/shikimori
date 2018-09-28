class UserRates::Log
  method_object %i[user_rate! ip! user_agent! oauth_application_id!]

  def call
    UserRateLog.create!(
      user: @user_rate.user,
      target: @user_rate.target,
      diff: diff_params,
      ip: @ip,
      user_agent: @user_agent,
      oauth_application_id: @oauth_application_id
    )
  end

private

  def diff_params
    if @user_rate.destroyed?
      {
        id: [@user_rate.id, nil]
      }
    else
      @user_rate.saved_changes.except(
        'user_id',
        'target_id',
        'target_type',
        'created_at',
        'updated_at'
      )
    end
  end
end
