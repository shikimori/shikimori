class Api::V1::UsersController < Api::V1Controller
  before_action :authenticate_user!, only: %i[messages unread_messages]
  before_action :authorize_lists_access, only: %i[anime_rates manga_rates history]
  skip_before_action :verify_authenticity_token, only: :csrf_token

  before_action only: %i[messages unread_messages] do
    doorkeeper_authorize! :messages if doorkeeper_token.present?
  end

  caches_action :anime_rates, :manga_rates,
    cache_path: proc {
      "#{user.cache_key_with_version}|#{XXhash.xxh32 params.to_json}"
    }

  USERS_LIMIT = 100
  MESSAGES_LIMIT = 100
  USER_RATES_LIMIT = 5000
  HISTORY_LIMIT = 100
  ANIME_VIDEO_REPORTS_LIMIT = 2000

  api :GET, '/users', 'List users'
  param :page, :pagination, required: false
  param :limit, :number, required: false, desc: "#{USERS_LIMIT} maximum"
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

  api :GET, '/users/sign_out', 'Sign out the user'
  def sign_out
    super current_user
    render plain: 'signed out'
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
  param :limit, :number,
    required: false,
    desc: "#{USER_RATES_LIMIT} maximum"
  param :status, Types::UserRate::Status.values.map(&:to_s),
    required: false
  param :censored, %w[true false],
    required: false,
    desc: 'Set to `true` to discard hentai, yaoi and yuri'
  def anime_rates # rubocop:disable AbcSize
    @limit = [[params[:limit].to_i, 1].max, USER_RATES_LIMIT].min

    @rates = Rails.cache.fetch [user, :anime_rates, params[:status], params[:censored]] do
      rates = user.anime_rates.includes(:anime, :user)
      rates.where! status: Types::UserRate::Status[params[:status]] if params[:status].present?

      if params[:censored] == 'true'
        rates = rates.joins(:anime).where(animes: { is_censored: false })
      end

      rates.to_a
    end

    @rates = @rates[@limit * (@page - 1), @limit + 1]
    respond_with @rates, each_serializer: UserRateFullSerializer
  end

  api :GET, '/users/:id/manga_rates', "Show user's manga list"
  param :page, :pagination, required: false
  param :limit, :number,
    required: false,
    desc: "#{USER_RATES_LIMIT} maximum"
  param :censored, %w[true false],
    required: false,
    desc: 'Set to `true` to discard hentai, yaoi and yuri'
  def manga_rates # rubocop:disable AbcSize
    @limit = [[params[:limit].to_i, 1].max, USER_RATES_LIMIT].min

    @rates = Rails.cache.fetch [user, :manga_rates, params[:status], params[:censored]] do
      rates = user.manga_rates.includes(:manga, :user)
      rates.where! status: params[:status] if params[:status].present?

      if params[:censored] == 'true'
        rates = rates.joins(:manga).where(mangas: { is_censored: false })
      end

      rates.to_a
    end

    @rates = @rates[@limit * (@page - 1), @limit + 1]
    respond_with @rates, each_serializer: UserRateFullSerializer
  end

  api :GET, '/users/:id/favourites', "Show user's favourites"
  def favourites
    view = Profiles::FavoritesView.new(user)

    respond_with(
      animes: view.animes.map { |v| FavouriteSerializer.new v },
      mangas: view.mangas.map { |v| FavouriteSerializer.new v },
      characters: view.characters.map { |v| FavouriteSerializer.new v },
      people: view.people.map { |v| FavouriteSerializer.new v },
      mangakas: view.mangakas.map { |v| FavouriteSerializer.new v },
      seyu: view.seyu.map { |v| FavouriteSerializer.new v },
      producers: view.producers.map { |v| FavouriteSerializer.new v }
    )
  end

  api :GET, '/users/:id/messages', "Show current user's messages"
  description 'Requires `messages` oauth scope'
  param :page, :pagination, required: false
  param :limit, :number, required: false, desc: "#{MESSAGES_LIMIT} maximum"
  param :type, %w[inbox private sent news notifications], required: true
  def messages
    @limit = [[params[:limit].to_i, 1].max, MESSAGES_LIMIT].min

    messages = ::Messages::Query
      .fetch(current_user, params[:type].try(:to_sym) || '')
      .paginate_n1(@page, @limit)
      .transform(&:decorate)

    respond_with messages
  end

  api :GET, '/users/:id/unread_messages',
    "Show current user's unread messages counts"
  description 'Requires `messages` oauth scope'
  def unread_messages
    respond_with(
      messages: current_user.unread.messages,
      news: current_user.unread.news,
      notifications: current_user.unread.notifications
    )
  end

  api :GET, '/users/:id/history', 'Show user history'
  param :page, :pagination, required: false
  param :limit, :number, required: false, desc: "#{HISTORY_LIMIT} maximum"
  param :target_id, :number, required: false
  param :target_type, %w[Anime Manga], required: false
  def history
    @limit = [[params[:limit].to_i, 1].max, HISTORY_LIMIT].min

    @collection = user
      .all_history
      .offset(@limit * (@page - 1))
      .limit(@limit + 1)

    if params[:target_id]
      @collection.where! target_id: params[:target_id]
    end
    if params[:target_type]
      @collection.where! target_type: params[:target_type]
    end
    if params[:updated_at_gte]
      @collection.where! 'updated_at >= ?', Time.zone.parse(params[:updated_at_gte])
    end
    if params[:updated_at_lte]
      @collection.where! 'updated_at <= ?', Time.zone.parse(params[:updated_at_lte])
    end

    respond_with @collection.decorate
  end

  api :GET, '/users/:id/bans', "Show user's bans"
  def bans
    @collection = user.bans.reverse
    respond_with @collection
  end

  def csrf_token
    if current_user&.admin?
      render json: {
        _csrf_token: session[:_csrf_token],
        x_csrf_token: request.x_csrf_token,
        # unmasked_x_csrf_token: ((unmask_token(Base64.strict_decode64(request.x_csrf_token)) rescue ArgumentError) if request.x_csrf_token.present?), # rubocop: disable all
        is_valid: request_authenticity_tokens.any? do |token|
          valid_authenticity_token?(session, token)
        end,
        verified_request: verified_request?,
        shiki_type: ENV['SHIKI_TYPE'],
        rack_url_scheme: request['rack.url_scheme']
      }
    else
      raise CanCan::AccessDenied
    end
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
