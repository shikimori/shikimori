# frozen_string_literal: true

class Collection::Create < ServiceObjectBase
  pattr_initialize :params, :locale

  def call
    model = Collection.create params

    if model.persisted?
      model.generate_topics model.locale, forum_id: Forum::HIDDEN_ID
    end

    model
  end

private

  def params
    @params.merge(
      state: Types::Collection::State[:unpublished],
      locale: @locale
    )
  end
end
