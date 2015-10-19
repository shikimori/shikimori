class ViewObjectBase
  include Draper::ViewHelpers
  include Translation

  prepend ActiveCacher.instance
  extend DslAttribute

  #dsl_attribute :paginated
  dsl_attribute :per_page_limit

  #attr_accessor :page

  #def initialize
    #defined_method paginated do
      #paginate h.params[:page], per_page_limit do
        #send "#{paginated}_query"
      #end
    #end if paginated
  #end

  #def postloader?
    #@add_postloader
  #end

  def page
    (h.params[:page] || 1).to_i
  end

#private

  #def paginate page, limit
    #@page = (h.params[:page] || 1).to_i
    #@limit = limit.to_i

    #ds = yield

    #entries = ds.offset(@limit * (@page-1)).limit(@limit + 1).to_a
    #@add_postloader = entries.size > @limit

    #@add_postloader ? entries.take(limit) : entries
  #end
end
