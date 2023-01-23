class DbImport::PosterPolicy < DbImport::ImagePolicy
  def need_import?
    return false if invalid_entry? || bad_image_url? || desynced_poster?
    return true if no_existing_poster? || broken_existing_image?

    poster_expired?
  end

private

  def invalid_entry?
    @entry.new_record? || !@entry.valid?
  end

  def desynced_poster?
    @entry.desynced.include?('poster') ||
      @entry.desynced.include?('image')
  end

  def no_existing_poster?
    @entry.poster.nil?
  end

  def poster_expired?
    @entry.poster.mal_url != @image_url
  end

  def image_path
    @entry.poster.image.storage.path @entry.poster.image.id
  end
end
