class PaginationValidator < Apipie::Validator::BaseValidator
  MINUMUM = 1
  MAXIMUM = 100_000

  def self.build param_description, argument, options, block
    if argument == :pagination
      new param_description
    end
  end

  def validate value
    value.to_s =~ /\A(0|[1-9]\d*)\Z$/ &&
      value.to_i >= MINUMUM &&
      value.to_i <= MAXIMUM
  end

  def description
    "Must be a number between #{MINUMUM} and #{MAXIMUM}."
  end
end
