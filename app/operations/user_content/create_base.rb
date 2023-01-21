# frozen_string_literal: true

class UserContent::CreateBase
  extend DslAttribute
  dsl_attribute :klass
  dsl_attribute :is_auto_acceptable
  dsl_attribute :is_publishable

  method_object :params

  def call
    klass.transaction do
      model = klass.create params

      if model.persisted?
        is_publishable ?
          model.generate_topic(forum_id: Forum::HIDDEN_ID) :
          model.generate_topic

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
