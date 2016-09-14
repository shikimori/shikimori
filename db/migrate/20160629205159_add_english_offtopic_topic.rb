class AddEnglishOfftopicTopic < ActiveRecord::Migration
  EN_OFFTOPIC_TOPIC_ID = 210_000

  def up
    return if Rails.env.test?

    Topic.create!(
      id: EN_OFFTOPIC_TOPIC_ID,
      user_id: en_offtopic_user.id,
      forum_id: Forum::OFFTOPIC_ID,
      title: 'Off-topic thread',
      body: en_offtopic_body,
      locale: :en
    )
  end

  def down
    return if Rails.env.test?

    en_offtopic_topic = Topic.find(EN_OFFTOPIC_TOPIC_ID)
    en_offtopic_topic.user.destroy
    en_offtopic_topic.destroy
  end

private

  def en_offtopic_user
    User.skip_callback :create, :after, :send_welcome_message
    User.create!(
      email: 'vbhmjasy@dasd.asd',
      password: '1z6NYlLd9B9ikA==',
      name: '',
      nickname: 'Offtopic-tyan',
      avatar: ru_offtopic_user.avatar,
      locale: :en,
      locale_from_domain: :en
    )
  end

  def ru_offtopic_user
    User.find(40990)
  end

  def en_offtopic_body
    'Let\'s move all discussions here as soon as they are not about anime'\
      ' but playing video games and similar stuff. Also come here to talk'\
      ' about whatever you like or just to drink a cup of tea with cookies :)'
  end
end
