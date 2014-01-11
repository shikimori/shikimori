class Api::V1::UsersController < Api::V1::ApiController
  before_filter :authenticate_user!, only: [:messages, :unread_messages]

  respond_to :json, :xml

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/users/:id", "Show an user"
  def show
    respond_with UserProfileDecorator.new(user), serializer: UserProfileSerializer
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/users/:id/friends"
  def friends
    respond_with user.friends
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/users/:id/clubs"
  def clubs
    respond_with user.groups
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/users/:id/favourites"
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

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/users/:id/messages"
  def messages
    @limit = [[params[:limit].to_i, 1].max, 100].min
    @page = [params[:page].to_i, 1].max

    respond_with MessagesQuery.new(current_user, params[:type] || '').fetch @page, @limit
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/users/:id/unread_messages"
  def unread_messages
    respond_with ({
      messages: current_user.unread_messages,
      news: current_user.unread_news,
      notifications: current_user.unread_notifications
    })
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/users/:id/history"
  def history
    @limit = [[params[:limit].to_i, 1].max, 100].min
    @page = [params[:page].to_i, 1].max

    respond_with user
      .all_history
      .order { updated_at.desc }
      .offset(@limit * (@page-1))
      .limit(@limit + 1)
      .decorate
  end

private
  def user
    User.find params[:id]
  end

  def decorator
    user.decorate
  end
end
