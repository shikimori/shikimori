class SiteController < ApplicationController
  #layout 'index'

  def index
  end

  def userbox
    render partial: 'blocks/userbox'
  end
end
