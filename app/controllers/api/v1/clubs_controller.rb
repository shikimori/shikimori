class Api::V1::ClubsController < Api::V1Controller
  before_action :fetch_club, except: :index
  before_action :restrict_domain, except: [:index, :create, :new]

  LIMIT = 30

  caches_action :animes, :mangas, :characters, :members, :images,
    cache_path: proc {
      "#{@club.cache_key}|#{params[:action]}"
    }

  api :GET, '/clubs', 'List clubs'
  param :page, :number, required: false
  param :limit, :number, required: false, desc: "#{LIMIT} maximum"
  def index
    page = [params[:page].to_i, 1].max
    limit = [[params[:limit].to_i, 1].max, LIMIT].min

    @collection = ClubsQuery
      .new(locale_from_host)
      .fetch(page, limit, true)

    respond_with @collection
  end

  # AUTO GENERATED LINE: REMOVE THIS TO PREVENT REGENARATING
  api :GET, '/clubs/:id', 'Show a club'
  def show
    if @collection
      respond_with @collection, each_serializer: ClubProfileSerializer
    else
      respond_with @club, serializer: ClubProfileSerializer
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
    respond_with @club.all_member_roles.map(&:user)
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
      @club = Club.find(params[:id]).decorate
    else
      @collection = Club.where(id: ids).limit(LIMIT).decorate
    end
  end

  def restrict_domain
    raise ActiveRecord::RecordNotFound if @club.locale != locale_from_host
  end
end
