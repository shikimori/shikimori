if @video.persisted?
  json.video_id @video.id
  json.content render(
    partial: 'videos/video',
    object: @video,
    formats: :html
  )
else
  json.errors @video.errors.full_messages
end
