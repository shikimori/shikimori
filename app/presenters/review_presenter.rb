class ReviewPresenter < BasePresenter
  proxy :name

  def url
    url_for [@object.target, @object]
  end

  #def image
    #@object.logo
  #end
end
