class Complaint
  def from user
    @user = user
    self
  end

  def send_message url, video_id, complaint_kind
    Message.create!({
      src: @user,
      dst_id: 1077,
      dst_type: User.name,
      kind: MessageType::Notification,
      body: "Пожаловались на видео #{video_id} [#{complaint_kind}] #{url}"
    })
  end
end
