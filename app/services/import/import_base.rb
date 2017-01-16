class Import::ImportBase
  method_object :data

  SPECIAL_FIELDS = %i()
  IGNORED_FIELDS = %i()

  def call
    ActiveRecord::Base.transaction { import }
    entry
  end
  # rubocop:enable AbcSize

private

  def import
    entry.assign_attributes data_to_assign
    assign_special_fields

    entry.mal_id = @data[:id] if entry.new_record?
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
      unless field.in?(desynced_fields) || @data[field].blank?
        send "assign_#{field}", @data[field]
      end
    end
  end

  def assign_synopsis synopsis
    entry.description_en = Mal::ProcessDescription.call(
      Mal::SanitizeText.call(synopsis),
      klass.name.downcase,
      entry.id
    )
  end

  def assign_image image
    Import::MalImage.call entry, image
  end

  def data_to_assign
    ignored_fields = self.class::SPECIAL_FIELDS +
      self.class::IGNORED_FIELDS +
      desynced_fields

    @data.except(*ignored_fields)
  end

  def desynced_fields
    @desynced_fields ||= entry.desynced.map(&:to_sym)
  end
end
