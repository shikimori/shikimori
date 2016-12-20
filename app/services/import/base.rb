class Import::Base
  method_object :data
  attr_implement :klass

  SPECIAL_FIELDS = %i()

  def call
    entry.assign_attributes data_to_assign

    self.class::SPECIAL_FIELDS.each do |field|
      send "assign_#{field}", @data[field] unless field.in? desynced_fields
    end
    entry.imported_at = Time.zone.now
    entry.save!

    entry
  end

private

  def entry
    @entry ||= klass.find_or_initialize_by id: @data[:id]
  end

  def data_to_assign
    @data.except(*(self.class::SPECIAL_FIELDS + desynced_fields))
  end

  def desynced_fields
    @desynced_fields ||= entry.desynced.map(&:to_sym)
  end
end
