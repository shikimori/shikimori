class AddEnglishOfftopicTopic < ActiveRecord::Migration
  EN_OFFTOPIC_TOPIC = 210_000

  def change
    Topic.create!(
      id: EN_OFFTOPIC_TOPIC,
      user_id: en_offtopic_user.id,
      forum_id: 8,
      title: 'Off-topic thread',
      body: en_offtopic_body,
      locale: :en
    )
  end

private

  def en_offtopic_user
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
      ' about whatever you want or just drink tea with cakes :)'
  end
end
