class Api::V1::UsersController < Api::V1Controller
  before_action :authenticate_user!, only: %i[messages unread_messages]
  before_action :authorize_lists_access, only: %i[anime_rates manga_rates history]

  caches_action :anime_rates, :manga_rates,
    cache_path: proc {
      "#{user.cache_key}|#{Digest::MD5.hexdigest params.to_json}"
    }

  USERS_LIMIT = 100
  MESSAGES_LIMIT = 100
  USER_RATES_LIMIT = 5000
  HISTORY_LIMIT = 100
  ANIME_VIDEO_REPORTS_LIMIT = 2000

  api :GET, '/users', 'List users'
  param :page, :pagination, required: false
  param :limit, :pagination, required: false, desc: "#{USERS_LIMIT} maximum"
  def index
    @limit = [[params[:limit].to_i, 1].max, USERS_LIMIT].min

    @collection = Users::Query.fetch
      .search(params[:search])
      .paginate_n1(@page, @limit)

    respond_with @collection
  end

  api :GET, '/users/:id', 'Show an user'
  param :is_nickname, %w[1], desc: '`1` if you want to get user by its nickname'
  def show
    respond_with UserProfileDecorator.new(user), serializer: UserProfileSerializer
  end

  api :GET, '/users/:id/info', "Show user's brief info"
  def info
    respond_with user, serializer: UserInfoSerializer
  end

  api :GET, '/users/whoami', "Show current user's brief info"
  def whoami
    respond_with current_user, serializer: UserInfoSerializer
  end

  api :GET, '/users/:id/friends', "Show user's friends"
  def friends
    respond_with user.friends
  end

  api :GET, '/users/:id/clubs', "Show user's clubs"
  def clubs
    respond_with user.clubs
  end

  api :GET, '/users/:id/anime_rates', "Show user's anime list"
  param :page, :pagination, required: false
  param :limit, :pagination,
    required: false,
    desc: "#{USER_RATES_LIMIT} maximum"
  def anime_rates
    @limit = [[params[:limit].to_i, 1].max, USER_RATES_LIMIT].min

    @rates = Rails.cache.fetch [user, :anime_rates, params[:status]] do
      rates = user.anime_rates.includes(:anime, :user)
      rates = rates.where status: params[:status] if params[:status].present?
      rates.to_a
    end

    @rates = @rates[@limit * (@page - 1), @limit + 1]
    respond_with @rates, each_serializer: UserRateFullSerializer
  end

  api :GET, '/users/:id/manga_rates', "Show user's manga list"
  param :page, :pagination, required: false
  param :limit, :pagination,
    required: false,
    desc: "#{USER_RATES_LIMIT} maximum"
  def manga_rates
    @limit = [[params[:limit].to_i, 1].max, USER_RATES_LIMIT].min

    @rates = Rails.cache.fetch [user, :manga_rates, params[:status]] do
      rates = user.manga_rates.includes(:manga, :user)
      rates = rates.where status: params[:status] if params[:status].present?
      rates.to_a
    end

    @rates = @rates[@limit * (@page - 1), @limit + 1]
    respond_with @rates, each_serializer: UserRateFullSerializer
  end

  api :GET, '/users/:id/favourites', "Show user's favourites"
  def favourites
    respond_with(
      animes: user.fav_animes.map { |v| FavouriteSerializer.new v },
      mangas: user.fav_mangas.map { |v| FavouriteSerializer.new v },
      characters: user.fav_characters.map { |v| FavouriteSerializer.new v },
      people: user.fav_persons.map { |v| FavouriteSerializer.new v },
      mangakas: user.fav_mangakas.map { |v| FavouriteSerializer.new v },
      seyu: user.fav_seyu.map { |v| FavouriteSerializer.new v },
      producers: user.fav_producers.map { |v| FavouriteSerializer.new v }
    )
  end

  api :GET, '/users/:id/messages', "Show current user's messages. Authorization required."
  param :page, :pagination, required: false
  param :limit, :pagination, required: false, desc: "#{MESSAGES_LIMIT} maximum"
  param :type, %w[inbox private sent news notifications], required: true
  def messages
    @limit = [[params[:limit].to_i, 1].max, MESSAGES_LIMIT].min

    messages = MessagesQuery
      .new(current_user, params[:type].try(:to_sym) || '')
      .fetch(@page, @limit)
      .decorate

    respond_with messages
  end

  api :GET, '/users/:id/unread_messages',
    "Show current user's unread messages counts. Authorization required."
  def unread_messages
    respond_with(
      messages: current_user.unread_messages,
      news: current_user.unread_news,
      notifications: current_user.unread_notifications
    )
  end

  api :GET, '/users/:id/history', 'Show user history'
  param :page, :pagination, required: false
  param :limit, :pagination, required: false, desc: "#{HISTORY_LIMIT} maximum"
  def history
    @limit = [[params[:limit].to_i, 1].max, HISTORY_LIMIT].min

    @collection = user
      .all_history
      .offset(@limit * (@page - 1))
      .limit(@limit + 1)

    if params[:updated_at_gte]
      @collection = @collection.where(
        'updated_at >= ?', Time.zone.parse(params[:updated_at_gte])
      )
    end
    if params[:updated_at_lte]
      @collection = @collection.where(
        'updated_at <= ?', Time.zone.parse(params[:updated_at_lte])
      )
    end

    respond_with @collection.decorate
  end

  api :GET, '/users/:id/bans', "Show user's bans"
  def bans
    @collection = user.bans.reverse
    respond_with @collection
  end

  api :GET, '/users/:id/anime_video_reports'
  param :page, :pagination, required: false
  param :limit, :pagination,
    required: false,
    desc: "#{ANIME_VIDEO_REPORTS_LIMIT} maximum"
  def anime_video_reports
    @limit = [[params[:limit].to_i, 1].max, ANIME_VIDEO_REPORTS_LIMIT].min

    scope = AnimeVideoReport
      .where(user: user)
      .includes(:user, :approver, anime_video: :author)
      .order(id: :desc)

    @collection = QueryObjectBase.new(scope).paginate(@page, @limit)

    respond_with @collection.to_a
  end

private

  def user
    @user ||=
      if params[:is_nickname] == '1'
        User.find_by!(nickname: User.param_to(params[:id]))
      else
        User.find_by(id: params[:id]) ||
          User.find_by!(nickname: User.param_to(params[:id]))
      end
  end

  def decorator
    user.decorate
  end

  def authorize_lists_access
    authorize! :access_list, user
  end
end
