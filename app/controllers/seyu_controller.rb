class SeyuController < PeopleController
  # поиск по сэйю
  def index
    @query = SeyuQuery.new(params)
    @people = postload_paginate(params[:page], 10) { @query.fetch }
    @query.fill_works @people
    direct
  end

  # отображение сэйю
  def show
    @entry = SeyuDecorator.new Person.find(params[:id].to_i)
    direct

    unless @director.redirected?
      if !@entry.seyu || (@entry.seyu && (@entry.producer || @entry.mangaka))
        if params[:direct]
          @canonical = person_url(@entry)
        else
          redirect_to person_url(@entry)
        end
      end
    end
  end
end
