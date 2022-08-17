class IncompleteDate
  include ShallowAttributes

  attribute :year, Integer, allow_nil: true
  attribute :month, Integer, allow_nil: true
  attribute :day, Integer, allow_nil: true
end

# class IncompleteDate
#   module IncompleteDateAttr
#     extend ActiveSupport::Concern
#     #
#     # Defines a new IncompleteDate virtual attribute with name +attr_name+
#     # corresponding to a real integer attribute named +raw_name+ that holds the
#     # raw date value in the database.
#     #
#     class_methods do
# 
#       def incomplete_date_attr(attr_name, raw_name)
#         instance_var = "@#{attr_name}"
# 
#         # getter
#         define_method "#{attr_name}" do
#           value = instance_variable_get(instance_var)
#           value ||= IncompleteDate.new(read_attribute(raw_name))
#           instance_variable_set(instance_var, value)
#           value
#         end
# 
#         # setter
#         define_method "#{attr_name}=" do |value|
#           #begin
#             value = IncompleteDate.new(value)
#             instance_variable_set(instance_var, value)
#             write_attribute(raw_name, value.to_i)
#           #rescue ArgumentError
#           #  errors.add(raw_name)
#           #end
#         end
#       end
# 
#       #
#       # Defines several virtual attributes at once for raw real attributes
#       #
#       def incomplete_date_attrs(*names)
#         options = names.extract_options!
#         prefix = options.fetch(:prefix, 'raw')
#         names.each do |name|
#           raw_name = "#{prefix}_#{name}"
#           incomplete_date_attr name, raw_name
#         end
#       end
# 
#     end
# 
#   end
# end
