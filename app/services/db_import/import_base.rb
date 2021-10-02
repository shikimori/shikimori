class DbImport::ImportBase
  method_object :data

  SPECIAL_FIELDS = %i[]
  IGNORED_FIELDS = %i[]

  def call
    return if DbImport::BannedIds.instance.banned? @data[:id], klass.name.downcase

    # was_new_record = entry.new_record?
    ApplicationRecord.transaction { import }

    # if was_new_record && entry.persisted?
    #   schedule_fetch_authorized
    # end

    entry
  end

private

  def import
    entry.assign_attributes data_to_assign
    assign_special_fields

    entry.mal_id ||= @data[:id]
    entry.imported_at = Time.zone.now

    entry.save!
  end

  def entry
    @entry ||= klass.find_or_initialize_by id: @data[:id]
  end

  def klass
    self.class.name.gsub(/.*:/, '').constantize
  end

  def assign_special_fields
    self.class::SPECIAL_FIELDS.each do |field|
      next if field.in?(desynced_fields)
      next if @data[field].blank? && field != :image

      send "assign_#{field}", @data[field]
    end
  end

  def assign_synopsis synopsis
    return if :description_en.in? desynced_fields

    text = Mal::ProcessDescription.call(
      Mal::SanitizeText.call(synopsis),
      klass.name.downcase,
      entry.id
    )
    return if text.blank?

    entry.description_en = text
  end

  def assign_image image
    DbImport::MalImage.call entry, image
  end

  def data_to_assign
    ignored_fields = self.class::SPECIAL_FIELDS +
      self.class::IGNORED_FIELDS +
      desynced_fields

    @data
      .except(*ignored_fields)
      .delete_if { |_k, v| v.blank? }
  end

  def desynced_fields
    @desynced_fields ||= entry.desynced.map(&:to_sym)
  end

  # def schedule_fetch_authorized
  # end
end
