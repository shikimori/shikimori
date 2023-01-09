# frozen_string_literal: true

class UserContent::CreateBase
  extend DslAttribute
  dsl_attribute :klass
  dsl_attribute :is_auto_acceptable, false

  method_object :params

  def call
    klass.transaction do
      model = klass.create params

      if model.persisted?
        model.generate_topic forum_id: Forum::HIDDEN_ID
        model.accept approver: model.user if auto_acceptable? model
      end

      model
    end
  end

private

  def params
    @params.merge(
      state: "Types::#{klass}::State".constantize[:unpublished]
    )
  rescue NameError
    @params
  end

  def state
    "Types::#{klass}::State".constantize[:unpublished]
  end

  def auto_acceptable? model
    is_auto_acceptable && model.may_accept? && Ability.new(model.user).can?(:accept, model)
  end
end
