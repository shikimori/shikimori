# frozen_string_literal: true

class UserContent::CreateBase < ServiceObjectBase
  extend DslAttribute
  pattr_initialize :params, :locale
  dsl_attribute :klass

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
  end
end
