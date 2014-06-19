require_dependency 'genre'
require_dependency 'studio'
require_dependency 'publisher'

class UserlistComparerController < ShikimoriController
  before_filter :noindex
  before_filter :nofollow

  def show
    @klass = Object.const_get(params[:list_type].downcase.capitalize)
    params[:klass] = @klass

    @user_1 = User.find_by_nickname(User.param_to params[:user_1])
    @user_2 = User.find_by_nickname(User.param_to params[:user_2])

    if @user_1.blank? || @user_2.blank?
      redirect_to :root, alert: "Невозможно сравнить списки, пользователь #{User.param_to @user_1.blank? ? params[:user_1] : params[:user_2]} не найден"
      return
    end

    @cache_key = "#{@user_1.cache_key}_#{@user_2.cache_key}_list_comparer_#{Digest::MD5.hexdigest(params.to_yaml)}"
    @entries = Rails.cache.fetch("#{@cache_key}_data", expires_in: 10.minutes) do
      expire_fragment(@cache_key)
      @entries = ListCompareService.fetch(@user_1, @user_2, params)
    end

    @page_title = "Сравнение списка #{@klass == Anime ? 'аниме' : 'манги'} #{@user_1.nickname} и #{@user_2.nickname}"

    respond_to do |format|
      format.html {
        # для левого меню
        @genres, @studios, @publishers = Rails.cache.fetch('genres_studios_publishers', expires_in: 30.minutes) do
          [Genre.order(:position).all, Studio.all, Publisher.all]
        end
        render
      }
      format.json {
        render json: { content: render_to_string(partial: 'userlist_comparer/table.html', layout: false, formats: :html) }
      }
    end
  end
end
