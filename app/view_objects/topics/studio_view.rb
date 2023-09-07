class Topics::StudioView < Topics::View
  def poster_image_url(*)
    ApplicationController.helpers.cdn_image_url(@topic.linked, :original)
  end
end
