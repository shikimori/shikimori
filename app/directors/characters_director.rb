#class CharactersDirector < BaseDirector
  #page :info
  #page :comments, -> { user_signed_in? || entry.thread.comments.any? }
  #page :cosplay, -> { entry.cosplay_galleries.any? }
  #page :images, -> { !entry.tags.blank? || entry.images.count > 0 }
  #page [:edit, [:description]], -> { user_signed_in? }
  #page [:edit, [:russian]], -> { user_signed_in? }

  #def index
    #append_title! 'Поиск персонажа'
    #append_title! SearchHelper.unescape(params[:search])
  #end

  #def show
    #noindex if params[:page] != 'info' || entry.description.blank?
    #append_title! [entry.russian, entry.name]

    #redirect!
  #end

  #def edit
    #noindex && nofollow
  #end

  #def page
    #show

    #noindex && nofollow
    #case params[:page].to_sym
      #when :images
        #append_title! 'Галерея'

      #when :cosplay
        #append_title! 'Косплей'
        #raise NotFound if entry.cosplay_galleries.empty?

      #when :comments
        #append_title! 'Обсуждение'
    #end
  #end

  #def tooltip
    #noindex && nofollow
    #redirect! character_tooltip_url(entry)
  #end

  #def entry_url_builder
    #:character_url
  #end

  #def entry_search_url_builder
    #:character_search_path
  #end

#private
  #def redirect?
    #entry.to_param != params[:id]
  #end
#end
