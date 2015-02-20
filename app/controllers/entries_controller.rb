class EntriesController < ShikimoriController
  include TopicsHelper

  # список топиков
  def index
    redirect_to root_url, status: 301 # редирект на новый форум
  end

  # отображение топика
  def show
    topic = Entry.find params[:id].to_i

    redirect_to topic_url(topic), status: 301 and return unless json? # редирект на новый форум

    render json: {
      user: topic.user.nickname,
      body: topic.body,
      id: topic.id,
      kind: 'entry'
    }
  end
end
