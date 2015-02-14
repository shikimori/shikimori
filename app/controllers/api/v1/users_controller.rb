class Api::V1::UsersController < Api::V1::ApiController
  before_filter :authenticate_user!, only: [:messages, :unread_messages]

  respond_to :json

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, '/users', 'List users'
  def index
    @limit = [[params[:limit].to_i, 1].max, 100].min
    @page = [params[:page].to_i, 1].max

    query = if params[:search].present?
      UsersQuery.new(params).search
    else
      User
        .where.not(id: 1)
        .where.not(last_online_at: nil)
        .order('(case when last_online_at>current_sign_in_at then last_online_at else current_sign_in_at end) desc')
    end

    @collection = query.offset(@limit * (@page-1)).limit(@limit + 1)
    respond_with @collection
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, '/users/:id', 'Show an user'
  def show
    respond_with UserProfileDecorator.new(user), serializer: UserProfileSerializer
  end

  api :GET, "/users/whoami", "Show current user's brief info"
  def whoami
    respond_with current_user
  end

  api :GET, "/users/:id/friends", "Show user's friends"
  def friends
    respond_with user.friends
  end

  api :GET, "/users/:id/clubs", "Show user's clubs"
  def clubs
    respond_with user.groups
  end

  api :GET, "/users/:id/anime_rates", "Show user's anime list"
  def anime_rates
    @limit = [[params[:limit].to_i, 1].max, 5000].min
    @page = [params[:page].to_i, 1].max

    @rates = Rails.cache.fetch [user, :anime_rates, params[:status]] do
      rates = user
        .anime_rates
        .includes(:anime)

      rates = rates.where status: params[:status] if params[:status].present?
      rates.to_a
    end

    @rates = @rates[@limit * (@page-1), @limit+1]
    respond_with @rates
  end

  api :GET, "/users/:id/manga_rates", "Show user's manga list"
  def manga_rates
    @limit = [[params[:limit].to_i, 1].max, 5000].min
    @page = [params[:page].to_i, 1].max

    @rates = Rails.cache.fetch [user, :manga_rates, params[:status]] do
      rates = user
        .manga_rates
        .includes(:manga)

      rates = rates.where status: params[:status] if params[:status].present?
      rates.to_a
    end

    @rates = @rates[@limit * (@page-1), @limit+1]
    respond_with @rates
  end

  api :GET, "/users/:id/favourites", "Show user's favourites"
  def favourites
    respond_with(
      animes: user.fav_animes.map {|v| FavouriteSerializer.new v },
      mangas: user.fav_mangas.map {|v| FavouriteSerializer.new v },
      characters: user.fav_characters.map {|v| FavouriteSerializer.new v },
      people: user.fav_persons.map {|v| FavouriteSerializer.new v },
      mangakas: user.fav_mangakas.map {|v| FavouriteSerializer.new v },
      seyu: user.fav_seyu.map {|v| FavouriteSerializer.new v },
      producers: user.fav_producers.map {|v| FavouriteSerializer.new v }
    )
  end

  api :GET, "/users/:id/messages", "Show current user's messages. Authorization required."
  def messages
    @limit = [[params[:limit].to_i, 1].max, 100].min
    @page = [params[:page].to_i, 1].max

    respond_with MessagesQuery.new(current_user, params[:type].try(:to_sym) || '').fetch @page, @limit
  end

  api :GET, "/users/:id/unread_messages", "Show current user's unread messages counts. Authorization required."
  def unread_messages
    respond_with(
      messages: current_user.unread_messages,
      news: current_user.unread_news,
      notifications: current_user.unread_notifications
    )
  end

  api :GET, "/users/:id/history", "Show user's history"
  def history
    @limit = [[params[:limit].to_i, 1].max, 100].min
    @page = [params[:page].to_i, 1].max

    respond_with user
      .all_history
      .offset(@limit * (@page-1))
      .limit(@limit + 1)
      .decorate
  end

private
  def user
    User.find_by(id: params[:id]) || User.find_by(nickname: params[:id]) || raise(NotFound, params[:id])
  end

  def decorator
    user.decorate
  end
end
