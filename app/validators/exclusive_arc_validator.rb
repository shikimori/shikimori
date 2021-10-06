# https://github.com/rails/rails/blob/main/activerecord/lib/active_record/validations/uniqueness.rb
class ExclusiveArcValidator < ActiveModel::EachValidator 
  def initialize options
    if options[:fields].blank?
      # raise ArgumentError, "#{options[:conditions]} was passed as :conditions but is not callable. " \
      #                       "Pass a callable instead: `conditions: -> { where(approved: true) }`"
    end
  end
  
  def validate(record)
    if some_complex_logic
      record.errors[:base] = "This record is invalid"
    end
  end
end
