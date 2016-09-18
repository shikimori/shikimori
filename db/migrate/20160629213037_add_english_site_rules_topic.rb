class AddEnglishSiteRulesTopic < ActiveRecord::Migration
  EN_SITE_RULES_TOPIC_ID = 220_000

  def up
    return if Rails.env.test?

    Topic.create!(
      id: EN_SITE_RULES_TOPIC_ID,
      title: 'Site rules',
      user_id: 1,
      forum_id: Forum::SITE_ID,
      body: body,
      locale: :en
    )
  end

  def down
    return if Rails.env.test?
    Topic.find(EN_SITE_RULES_TOPIC_ID).destroy
  end

private

  def body
    I18n.t(
      'sticky_topic_view.site_rules.body',
      offtopic_topic_id: Topic::TOPIC_IDS[Forum::OFFTOPIC_ID][:site_rules][:en],
      locale: :en
    )
  end
end
