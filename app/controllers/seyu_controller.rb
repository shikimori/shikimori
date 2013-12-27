class SeyuController < PeopleController
  # поиск по сейю
  def index
    @query = SeyuQuery.new(params)
    @people = postload_paginate(params[:page], 10) { @query.fetch }
    @query.fill_works @people
    direct
  end

  # отображение сейю
  def show
    @entry = SeyuDecorator.new Person.find(params[:id].to_i)
    direct

    unless @director.redirected?
      redirect_to person_url(@entry) if !@entry.seyu || (@entry.seyu && (@entry.producer || @entry.mangaka))
    end
  end
end
