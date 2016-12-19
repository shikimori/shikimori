class Import::Base
  method_object :data
  attr_implement :klass

  SPECIAL_FIELDS = %i()

  def call
    entry.assign_attributes @data.except(self.class::SPECIAL_FIELDS)

    self.class::SPECIAL_FIELDS.each do |field|
      send "assign_#{field}", @data[field]
    end
    entry.imported_at = Time.zone.now
    entry.save!

    entry
  end

private

  def entry
    @entry ||= klass.find_or_initialize_by id: @data[:id]
  end
end
