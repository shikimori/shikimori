class ExclusiveArcValidator < ActiveModel::EachValidator
  def initialize options
    super

    if options.blank?
      raise ArgumentError, 'options are not specified'
    end
  end

  def validate_each record, attribute, _value
    target_fields = [attribute] + options[:in]
    sum = target_fields.sum { |field| record.send(field).present? ? 1 : 0 }

    if sum.zero?
      record.errors[:base] << "Must specify one of :#{target_fields.join(', :')}"
    elsif sum > 1
      record.errors[:base] << "Must specify only one of :#{target_fields.join(', :')}"
    end
  end
end
