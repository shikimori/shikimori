class DbImport::MalPoster < DbImport::MalImage
  def call
    return unless policy.need_import?

    io = download_image
    return unless io && !entry_became_desynced?

    Poster.transaction do
      mark_old_poster_deleted
      create_new_poster io
    end
  rescue *::Network::FaradayGet::NET_ERRORS
  end

private

  def mark_old_poster_deleted
    @entry.poster&.update! deleted_at: Time.zone.now
  end

  def create_new_poster io
    @entry.posters.create! image: io, mal_url: @image_url
  end

  def policy
    DbImport::PosterPolicy.new entry: @entry, image_url: @image_url
  end

  def no_image?
    @entry.poster.nil?
  end

  def entry_became_desynced?
    @entry.reload.desynced.include? 'poster'
  end
end
