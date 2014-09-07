class SeyuController < PeopleController
  before_action :fetch_resource
  before_action :role_redirect

  # поиск по сэйю
  def index
    append_title! "Поиск сэйю"
    append_title! SearchHelper.unescape(params[:search])

    @query = SeyuQuery.new(params)
    @people = postload_paginate(params[:page], 10) { @query.fetch }
    @query.fill_works @people
  end

  # отображение сэйю
  def show
    @itemtype = @resource.itemtype
  end

private
  def fetch_resource
    @resource = SeyuDecorator.new Person.find(params[:id].to_i)
  end

  def role_redirect
    if !@resource.seyu || (@resource.seyu && (@resource.producer || @resource.mangaka))
      if params[:direct]
        @canonical = person_url(@resource)
      else
        redirect_to person_url(@resource)
      end
    end
  end
end
