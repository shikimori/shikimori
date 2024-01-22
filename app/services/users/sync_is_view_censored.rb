class Users::SyncIsViewCensored
  method_object :user

  def call
    if @user.preferences.view_censored?
      @user.preferences.update(
        is_view_censored: @user.age.present? && @user.age >= 18
      )
    end
  end
end
