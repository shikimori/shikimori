class Animes::Filters::ByUserList < Animes::Filters::FilterBase
  dry_type Types::UserRate::Status
  field :mylist

  method_object :scope, :value, :user

  def call
    scope = @scope

    scope = scope.where(id: terms_sql(positives)) if positives.any?
    scope = scope.where.not(id: terms_sql(negatives)) if negatives.any?

    scope
  end

private

  def fixed_value
    @value.to_s.gsub(/\b\d\b/) do |status_id|
      UserRate.statuses.find { |_name, id| id == status_id.to_i }.first
    end
  end

  def terms_sql terms
    @user
      .send(association_name)
      .where(status: terms)
      .select(:target_id)
  end

  def association_name
    if @scope.respond_to? :model
      :"#{@scope.model.base_class.name.downcase}_rates"
    else
      :"#{@scope.base_class.name.downcase}_rates"
    end
  end
end
