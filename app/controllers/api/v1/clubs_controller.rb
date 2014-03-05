class Api::V1::ClubsController < Api::V1::ApiController
  respond_to :json, :xml

  before_action :fetch_club, except: :index

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/clubs", "List clubs"
  def index
    page = [params[:page].to_i, 1].max
    limit = [[params[:limit].to_i, 1].max, 30].min

    @collection = ClubsQuery.new.fetch page, limit

    respond_with @collection
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/clubs/:id", "Show a club"
  def show
    respond_with @club, serializer: GroupProfileSerializer
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/clubs/:id/animes"
  def animes
    respond_with @club.all_animes
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/clubs/:id/mangas"
  def mangas
    respond_with @club.all_mangas
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/clubs/:id/characters"
  def characters
    respond_with @club.all_characters
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/clubs/:id/members"
  def members
    respond_with @club.all_members
  end

  # DOC GENERATED AUTOMATICALLY: REMOVE THIS LINE TO PREVENT REGENARATING NEXT TIME
  api :GET, "/clubs/:id/images"
  def images
    respond_with @club.all_images
  end

private
  def fetch_club
    @club = Group.find(params[:id]).decorate
  end
end
