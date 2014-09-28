class ClubsController < ShikimoriController
  before_action :authenticate_user!, only: [:new, :create, :update]
  before_action :fetch_resource, if: :resource_id
  before_action :resource_redirect, if: -> { @resource }
  before_action :set_title

  def index
    @page = [params[:page].to_i, 1].max
    @limit = [[params[:limit].to_i, 48].max, 96].min
    @collection, @add_postloader = ClubsQuery.new.postload @page, @limit
  end

private
  def fetch_resource
    @resource = Group.find resource_id
  end

  def set_title
    page_title 'Клубы'
    page_title @resource.name if @resource
  end
end
