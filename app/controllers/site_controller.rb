class SiteController < ApplicationController
  #layout 'index'

  def index
  end

  def userbox
    render :partial => 'site/userbox'
  end
end
