class DbImport::PosterPolicy < DbImport::ImagePolicy
  def need_import?
    return false if invalid_entry? || bad_image? || desynced_poster?
    return true if no_existing_poster?

    poster_expired?
  end

private

  def invalid_entry?
    @entry.new_record? || !@entry.valid?
  end

  def desynced_poster?
    @entry.desynced.include? 'poster'
  end

  def no_existing_poster?
    @entry.poster.nil?
  end

  def poster_expired?
    @entry.poster.created_at < expire_interval.ago
  end
end
