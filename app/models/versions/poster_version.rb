class Versions::PosterVersion < Version
  FIELD = 'image'

  def apply_changes
    if item.respond_to? :desynced
      item.desynced = (item.desynced + [FIELD]).uniq
    end
    item.save
  end

  def reject *args
    Version.transaction do
      super
      rollback_changes
    end
  end

  def reject! *args
    Version.transaction do
      super
      rollback_changes
    end
  end

  def to_deleted *args
    was_pending = pending?
    Version.transaction do
      super
      rollback_changes if was_pending
    end
  end

  def to_deleted! *args
    was_pending = pending?
    Version.transaction do
      super
      rollback_changes if was_pending
    end
  end

  def rollback_changes
    item.update! image: nil if latest_image?
    true
  end

  def latest_image?
    item&.image_file_name&.permalinked == item_diff['image'][1]&.permalinked
  end

  # def deleteable?
  #   false
  # end
end
