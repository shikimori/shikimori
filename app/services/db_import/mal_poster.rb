class DbImport::MalPoster < DbImport::MalImage
  MAX_ATTEMPTS = 2

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

  def policy
    DbImport::PosterPolicy.new entry: @entry, image_url: @image_url
  end

  def safe_download
    io = download_image
    return unless io && !entry_became_desynced?

    Poster.transaction do
      @entry.poster&.update! deleted_at: Time.zone.now
      @entry.posters.create! image: io, mal_url: @image_url
    end
  end

  def no_image?
    @entry.poster.nil?
  end

  def entry_became_desynced?
    @entry.reload.desynced.include? 'poster'
  end
end
