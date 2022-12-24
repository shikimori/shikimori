class DbImport::ImagePolicy
  pattr_initialize %i[entry! image_url!]

  ONGOING_INTERVAL = 2.weeks
  LATEST_INTERVAL = 3.months
  OLD_INTERVAL = ((30 * 4) - 2).days

  def need_import?
    return false if bad_image?
    return true if no_image?
    return true unless ImageChecker.valid? @entry.image.path

    file_expired?
  end

private

  def bad_image?
    @image_url.blank? ||
      @image_url.include?('na_series.gif') ||
      @image_url.include?('na.gif')
  end

  def no_image?
    @entry.new_record? || !@entry.image.exists?
  end

  def file_expired?
    File.mtime(@entry.image.path) < expire_interval.ago
  end

  def expire_interval
    return ONGOING_INTERVAL if ongoing? || belongs_to_ongoing?
    return LATEST_INTERVAL if latest?

    OLD_INTERVAL
  end

  def ongoing?
    @entry.respond_to?(:ongoing?) && @entry.ongoing?
  end

  def belongs_to_ongoing?
    @entry.is_a?(Character) && @entry.animes.where(status: :ongoing).any?
  end

  def latest?
    @entry.respond_to?(:latest?) && @entry.latest?
  end
end
