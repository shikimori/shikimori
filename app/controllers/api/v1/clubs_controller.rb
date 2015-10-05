class Api::V1::ClubsController < Api::V1::ApiController
  respond_to :json

  before_action :fetch_club, except: :index

  LIMIT = 30

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, '/clubs', 'List clubs'
  def index
    page = [params[:page].to_i, 1].max
    limit = [[params[:limit].to_i, 1].max, LIMIT].min

    @collection = ClubsQuery.new.fetch page, limit

    respond_with @collection
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, '/clubs/:id', 'Show a club'
  def show
    if @collection
      respond_with @collection, each_serializer: GroupProfileSerializer
    else
      respond_with @club, serializer: GroupProfileSerializer
    end
  end

  api :GET, "/clubs/:id/animes", "Show club's animes"
  def animes
    respond_with @club.all_animes
  end

  api :GET, "/clubs/:id/mangas", "Show club's mangas"
  def mangas
    respond_with @club.all_mangas
  end

  api :GET, "/clubs/:id/characters", "Show club's characters"
  def characters
    respond_with @club.all_characters
  end

  api :GET, "/clubs/:id/members", "Show club's members"
  def members
    respond_with @club.all_members
  end

  api :GET, "/clubs/:id/images", "Show club's images"
  def images
    respond_with @club.all_images
  end

  api :POST, '/clubs/:id/join', 'Join a club'
  def join
    authorize! :join, @club
    @club.join current_user
    head 200
  end

  api :POST, '/clubs/:id/leave', 'Leave a club'
  def leave
    authorize! :leave, @club
    @club.leave current_user
    head 200
  end

private

  def fetch_club
    ids = params[:id].split(',')

    if ids.one?
      @club = Group.find(params[:id]).decorate
    else
      @collection = Group.where(id: ids).limit(LIMIT).decorate
    end
  end
end
