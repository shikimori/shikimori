class DbImport::PosterPolicy < DbImport::ImagePolicy
  def need_import?
    return false if bad_image?
    return true unless @target.poster

    poster_expired?
  end

private

  def poster_expired?
    @target.poster.created_at < expire_interval.ago
  end
end
