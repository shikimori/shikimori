class Animes::Filters::ByUserList < Animes::Filters::FilterBase
  dry_type Types::UserRate::Status
  field :mylist

  method_object :scope, :value, :user

  JOIN_SQL = <<-SQL.squish
    left join
      user_rates on
      user_rates.user_id = %<user_id>i and
      user_rates.target_type = '%<target_type>s' and
      user_rates.target_id = %<table_name>s.id
  SQL

  def call
    return @scope if positives.none? && negatives.none?

    scope = joins_user_rates @scope

    scope = apply_positives scope if positives.any?
    scope = apply_negatives scope if negatives.any?

    scope
  end

private

  def joins_user_rates scope
    scope.joins(
      format(
        JOIN_SQL,
        user_id: @user.id,
        target_type: scope.klass.base_class.name,
        table_name: scope.table_name
      )
    )
  end

  def apply_positives scope
    scope.where(user_rates: { status: map(positives) })
  end

  def apply_negatives scope
    scope
      .where(
        'user_rates.status is null or user_rates.status not in (?)',
        map(negatives)
      )
  end

  def map terms
    terms.map do |term|
      UserRate.status_id term
    end
  end

  def fixed_value
    @value.to_s.gsub(/\b\d\b/) do |status_id|
      UserRate.statuses.find { |_name, id| id == status_id.to_i }&.first || fail_with(@value)
    end
  end

  # def terms_sql terms
    # @user
    #   .send(association_name)
    #   .where(status: terms)
    #   .select(:target_id)
  # end

  # def association_name
  #   if @scope.respond_to? :model
  #     :"#{@scope.model.base_class.name.downcase}_rates"
  #   else
  #     :"#{@scope.base_class.name.downcase}_rates"
  #   end
  # end
  def fail_with value
    raise Dry::Types::ConstraintError.new(Types::UserRate::Status.values, value)
  end
end
