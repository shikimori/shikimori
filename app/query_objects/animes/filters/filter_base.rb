class Animes::Filters::FilterBase
  extend DslAttribute
  method_object :scope, :value

  dsl_attribute :dry_type
  dsl_attribute :field

  delegate :positives, :negatives, to: :terms

  module DryRescue
    def call
      super
    rescue Dry::Types::ConstraintError => e
      if field
        raise InvalidParameterError.new(field, e.input, e.message)
      else
        raise
      end
    rescue Dry::Types::CoercionError => e
      if field
        raise InvalidParameterError.new(field, '', e.message)
      else
        raise
      end
    end
  end

  def self.inherited subclass
    subclass.send :prepend, DryRescue
    super
  end

private

  def terms
    @terms ||= Animes::Filters::Terms.new(fixed_value, dry_type)
  end

  # can be overriden in a child class
  def fixed_value
    @value
  end

  def table_name
    @scope.table_name
  end

  def sanitize term
    ApplicationRecord.sanitize term
  end

  def fail_with_negative!
    raise InvalidParameterError.new field, "!#{negatives[0]}"
  end

  def fail_with_scope!
    raise InvalidParameterError.new field, @value
  end

  def anime?
    @scope.name == Anime.name
  end
end
