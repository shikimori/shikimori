class AddEnglishAnimeIndustryTopic < ActiveRecord::Migration
  TOPIC_ID = Topic::TOPIC_IDS[Forum::SITE_ID][:anime_industry][:en]

  def up
    return if Rails.env.test?

    Topic.create!(
      id: TOPIC_ID,
      title: 'Some charts',
      user_id: 1,
      forum_id: Forum::SITE_ID,
      body: body,
      processed: true,
      locale: :en
    )
  end

  def down
    return if Rails.env.test?
    Topic.find(TOPIC_ID).destroy
  end

private

  def body
    <<-TEXT.squish
      A few days ago it just struck me that having all this information
      about anime it would be nice to group and sort data somehow,
      collect various stats and visualize it all in chart form.
      So why not?
      [br]
      Result of this work is this
      [url=http://shikimori.net/anime-history]page[/url]
      about anime industry.
    TEXT
  end
end
