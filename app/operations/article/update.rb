# frozen_string_literal: true

class Article::Update < ServiceObjectBase
  pattr_initialize :model, :params

  def call
    Article.transaction do
      update_article
      generate_topic if @model.published? && @model.topics.none?
    end
    @model
  end

private

  def update_article
    @model.update @params
  end

  def generate_topic
    @model.generate_topics @model.locale
  end
end
