class DbImport::PosterPolicy < DbImport::ImagePolicy
  def need_import?
    return false if invalid_target? || bad_image? || desynced_poster?
    return true if no_existing_poster?

    poster_expired?
  end

private

  def invalid_target?
    @target.new_record? || !@target.valid?
  end

  def desynced_poster?
    @target.desynced.include? 'poster'
  end

  def no_existing_poster?
    @target.poster.nil?
  end

  def poster_expired?
    @target.poster.created_at < expire_interval.ago
  end
end
