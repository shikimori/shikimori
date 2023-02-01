class DbImport::MalPoster < DbImport::MalImage
  MAX_ATTEMPTS = 3

  def call
    return unless policy.need_import?

    attempt = 0

    begin
      safe_download if (attempt += 1) <= MAX_ATTEMPTS
    rescue *::Network::FaradayGet::NET_ERRORS, ActiveRecord::RecordInvalid
      retry
    end
  end

private

  def safe_download
    io = download_image
    return unless io && !entry_became_desynced?

    Poster.transaction do
      mark_old_poster_deleted
      poster = create_new_poster io
      raise ActiveRecord::RecordInvalid unless valid_image? poster
    end
  end

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

  def valid_image? poster
    ImageChecker.valid? poster.image.storage.path(poster.image.id)
  end
end
