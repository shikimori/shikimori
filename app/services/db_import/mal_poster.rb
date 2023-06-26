class DbImport::MalPoster < DbImport::MalImage
  MAX_ATTEMPTS = 3

  PROXY_OPTIONS = {
    **DbImport::MalImage::PROXY_OPTIONS,
    validate_jpg: false
  }

  def call
    return unless policy.need_import?

    attempt = 0

    begin
      if (attempt += 1) <= MAX_ATTEMPTS
        log "downloading attempt=#{attempt}"
        safe_download
        log "downloaded attempt=#{attempt}"
      else
        log "failed download attempt=#{attempt - 1}"
      end
    rescue *::Network::FaradayGet::NET_ERRORS, ActiveRecord::RecordInvalid
      log 'retry'
      retry
    end
  end

private

  def policy
    DbImport::PosterPolicy.new entry: @entry, image_url: @image_url
  end

  def safe_download
    io = download_image
    if entry_became_desynced?
      log 'became desynced'
      return
    end
    unless io
      log 'io=nil'
      raise ActiveRecord::RecordInvalid
    end

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

  def log text
    NamedLogger.mal_poster.info "#{@entry.class.name}##{@entry.id} #{text}"
  end
end
