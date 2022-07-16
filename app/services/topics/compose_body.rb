class Topics::ComposeBody
  method_object :params

  def call
    body = params[:body]
    body += wall params[:video_id], params[:wall_ids] if wall? params
    body += source params[:source] if source? params
    body
  end

private

  def wall? params
    params[:video_id] || params[:wall_ids]
  end

  def source? params
    params[:source].present?
  end

  def wall video_id, image_ids
    "[wall]#{video video_id}#{images image_ids}[/wall]"
  end

  def video video_id
    "[video=#{video_id}]" if video_id
  end

  def source url
    "[source]#{url}[/source]"
  end

  def images image_ids
    image_ids&.map { |v| "[wall_image=#{v}]" }&.join
  end
end
