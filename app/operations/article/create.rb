# frozen_string_literal: true

class Article::Create < ServiceObjectBase
  pattr_initialize :params, :locale

  def call
    Article.create params
  end

private

  def params
    @params.merge(
      state: Types::Article::State[:unpublished],
      locale: @locale
    )
  end
end
