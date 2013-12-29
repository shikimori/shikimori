class AnimeVideoComplaintDecorator < Draper::Decorator
  delegate_all

  def video_id
    @id ||= (body =~ /id:(\d+)/;$1).to_i
  end

  def video_url
    body =~ /(http:\/\/.*)/
    $1
  end
end
