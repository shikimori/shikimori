require_dependency 'genre'
require_dependency 'studio'
require_dependency 'publisher'

class UserlistComparerController < ShikimoriController
  before_action :fetch_users
  before_action :authorize_lists_access

  def show
    noindex && nofollow
    @klass = params[:list_type].downcase.capitalize.constantize
    params[:klass] = @klass

    @cache_key = "#{@user_1.cache_key}_#{@user_2.cache_key}_list_comparer_#{Digest::MD5.hexdigest(params.to_yaml)}"
    @entries = Rails.cache.fetch("#{@cache_key}_data", expires_in: 10.minutes) do
      expire_fragment(@cache_key)
      @entries = ListCompareService.fetch(@user_1, @user_2, params)
    end

    @page_title = "Сравнение списка #{@klass == Anime ? 'аниме' : 'манги'} #{@user_1.nickname} и #{@user_2.nickname}"

    @menu = CollectionMenu.new @klass

    respond_to do |format|
      format.html { render }
      format.json {
        render json: { content: render_to_string(partial: 'userlist_comparer/table.html', layout: false, formats: :html) }
      }
    end
  end

private

  def fetch_users
    @user_1 = User.find_by nickname: User.param_to(params[:user_1])
    @user_2 = User.find_by nickname: User.param_to(params[:user_2])

    if @user_1.blank? || @user_2.blank?
      blank_user = @user_1.blank? ? params[:user_1] : params[:user_2]
      redirect_to :root, alert: "Невозможно сравнить списки, пользователь #{ERB::Util.html_escape blank_user} не найден"
    end
  end

  def authorize_lists_access
    authorize! :access_list, @user_1
    authorize! :access_list, @user_2
  end
end
