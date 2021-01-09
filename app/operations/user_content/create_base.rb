# frozen_string_literal: true

class UserContent::CreateBase < ServiceObjectBase
  extend DslAttribute
  dsl_attribute :klass

  pattr_initialize :params, :locale

  def call
    klass.transaction do
      model = klass.create params

      if model.persisted?
        model.generate_topics model.locale, forum_id: Forum::HIDDEN_ID
      end

      model
    end
  end

private

  def params
    @params.merge(
      state: "Types::#{klass}::State".constantize[:unpublished],
      locale: @locale
    )
  rescue NameError
    @params.merge locale: @locale
  end

  def state
    "Types::#{klass}::State".constantize[:unpublished]
  end
end
