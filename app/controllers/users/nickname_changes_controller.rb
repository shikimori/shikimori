class Users::NicknameChangesController < ProfilesController
  PER_PAGE = 100

  before_action do
    @back_url = profile_url @user
  end

  def index
    og noindex: true, nofollow: true
    @collection = Users::NicknameChangesQuery
      .call(@user, can?(:manage, Ban))
      .take(PER_PAGE)

    render formats: :html
  end
end
