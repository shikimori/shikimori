class Topics::ComposeBody < ServiceObjectBase
  pattr_initialize :params

  def call
    body = params[:body]
    body += wall params[:video_id], params[:wall_ids] if wall?(params)
    body
  end

private

  def wall? params
    params[:video_id] || params[:wall_ids]
  end

  def wall video_id, image_ids
    "[wall]#{video video_id}#{images image_ids}[/wall]"
  end

  def video video_id
    "[video=#{video_id}]" if video_id
  end

  def images image_ids
    image_ids.map { |v| "[image=#{v}]" }.join('') if image_ids
  end

  # def video video_id
    # video = Video.find_by id: video_id
    # "[video=#{video.id}]" if video
  # end

  # def images image_ids
    # image_ids&.map(&:to_i)
    # images = UserImage.where(id: ids).sort_by { |v| ids.index v.id } if ids

    # images.sum { |v| image_to_html v } if images&.any?
  # end

  # def image_to_html image
    # "[url=#{ImageUrlGenerator.instance.url image, :original}]\
# [poster=#{image.id}]\
# [/url]"
  # end
end
