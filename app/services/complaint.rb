# TODO remove after migrate to AnimeVideoReport. @blackchestnut
class Complaint
  def from user
    @user = user
    self
  end

  def send_message url, video_id, complaint_kind
    Message.create!(
      from_id: @user.id,
      to_id: User::Blackchestnut_ID,
      subject: complaint_kind,
      kind: MessageType::Notification,
      body: "Пожаловались на видео id:#{video_id} [#{complaint_kind}] #{url}"
    )
  end
end
