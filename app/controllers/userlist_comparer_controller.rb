class UserlistComparerController < ShikimoriController
  before_action :fetch_users
  before_action :authorize_lists_access

  def show
    @klass = params[:list_type].downcase.capitalize.constantize

    og noindex: true, nofollow: true
    og page_title: i18n_t(
      "page_title.#{@klass.name.downcase}",
      user_1: @user_1.nickname,
      user_2: @user_2.nickname
    )

    @entries = fetch_entries
    @menu = Menus::CollectionMenu.new @klass
  end

private

  def fetch_entries
    Rails.cache.fetch cache_key, expires_in: 10.minutes do
      ListCompareService.call(
        user_1: @user_1,
        user_2: @user_2,
        params: params.merge(klass: @klass)
      )
    end
  end

  def fetch_users
    @user_1 = User.find_by nickname: User.param_to(params[:user_1])
    @user_2 = User.find_by nickname: User.param_to(params[:user_2])

    if @user_1.blank? || @user_2.blank?
      blank_user = @user_1.blank? ? params[:user_1] : params[:user_2]
      alert = i18n_t(
        'fetch_users_alert',
        user: ERB::Util.html_escape(blank_user)
      )

      redirect_to :root, alert: alert
    end
  end

  def authorize_lists_access
    authorize! :access_list, @user_1
    authorize! :access_list, @user_2
  end

  def cache_key
    [
      :list_comparer,
      @user_1,
      @user_2,
      XXhash.xxh32(params.to_yaml),
      :v2
    ]
  end
end
