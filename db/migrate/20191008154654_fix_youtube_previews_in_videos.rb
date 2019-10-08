class FixYoutubePreviewsInVideos < ActiveRecord::Migration[5.2]
  def change
    Video
      .connection
      .execute("update videos set image_url=REPLACE(image_url, 'mqdefault.jpg', 'hqdefault.jpg')")
      .to_a
  end
end
