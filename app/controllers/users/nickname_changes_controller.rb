class Users::NicknameChangesController < ProfilesController
  before_action do
    @back_url = profile_url @user
  end

  def index
    og noindex: true, nofollow: true
    @collection = Users::NicknameChangesQuery.call(@user, can?(:manage, Ban))
    render formats: :html
  end
end
