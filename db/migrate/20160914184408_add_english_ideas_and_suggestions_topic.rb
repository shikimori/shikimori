class AddEnglishIdeasAndSuggestionsTopic < ActiveRecord::Migration
  EN_IDEAS_AND_SUGGESTIONS_TOPIC_ID = 230_000

  def up
    return if Rails.env.test?

    Topic.create!(
      id: EN_IDEAS_AND_SUGGESTIONS_TOPIC_ID,
      title: 'Ideas and suggestions',
      user_id: 1,
      forum_id: Forum::SITE_ID,
      body: body,
      locale: :en
    )
  end

  def down
    return if Rails.env.test?
    Topic.find(EN_IDEAS_AND_SUGGESTIONS_TOPIC_ID).destroy
  end

private

  def body
    I18n.t 'sticky_topic_view.ideas_and_suggestions.body', locale: :en
  end
end
