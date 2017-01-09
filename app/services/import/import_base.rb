class Import::ImportBase
  method_object :data
  attr_implement :klass

  SPECIAL_FIELDS = %i()
  IGNORED_FIELDS = %i()

  def call
    entry.assign_attributes data_to_assign
    entry.imported_at = Time.zone.now
    assign_special_fields
    entry.save!

    entry
  end

private

  def entry
    @entry ||= klass.find_or_initialize_by id: @data[:id]
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
      entry.class.name.downcase,
      entry.id
    )
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
