class TopicsOldController < ApplicationController
  include TopicsHelper

  # отображение темы
  def show
    topic = Entry.includes(:section).find(params[:id].to_i)
    redirect_to topic_url(topic), status: :moved_permanently # редирект на новый форум
  end
end
