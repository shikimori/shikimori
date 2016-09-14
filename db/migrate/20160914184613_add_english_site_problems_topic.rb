class AddEnglishSiteProblemsTopic < ActiveRecord::Migration
  EN_SITE_PROBLEMS_TOPIC_ID = 240_000

  def up
    return if Rails.env.test?

    Topic.create!(
      id: EN_SITE_PROBLEMS_TOPIC_ID,
      title: 'Site problems',
      user_id: 1,
      forum_id: Forum::SITE_ID,
      body: body,
      locale: :en
    )
  end

  def down
    return if Rails.env.test?
    Topic.find(EN_SITE_PROBLEMS_TOPIC_ID).destroy
  end

private

  def body
    I18n.t 'sticky_topic_view.site_problems.body', locale: :en
  end
end
