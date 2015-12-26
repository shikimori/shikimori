class Forums::Menu < ViewObjectBase
  pattr_initialize :forum, :linked
  instance_cache :clubs, :reviews

  def clubs
    ClubComment
      .includes(:linked)
      .order(updated_at: :desc)
      .limit(3)
  end

  def changeable_forums?
    h.user_signed_in? && h.params[:action] == 'index' && h.params[:forum].nil?
  end

  def forums
    Forums::List.new
  end

  def reviews
    @reviews ||= Review
      .where('created_at >= ?',  2.weeks.ago)
      .visible
      .includes(:user, :target, thread: [:forum])
      .order(created_at: :desc)
      .limit(3)
  end

  def sticked_topics
    [
      StickedTopic.new(
        url: '/s/79042-Pravila-sayta',
        title: "#{I18n.t 'site_rules'}",
        description: 'Что не стоит делать на сайте'
      ),
      StickedTopic.new(
        url: '/s/85018-FAQ-Chasto-zadavaemye-voprosy',
        title: 'FAQ',
        description: "#{I18n.t 'faq'}"
      ),
      StickedTopic.new(
        url: '/s/103553-Opisaniya-zhanrov',
        title: 'Описания жанров',
        description: 'Для желающих помочь сайту'
      ),
      StickedTopic.new(
        url: '/s/10586-Pozhelaniya-po-saytu',
        title: 'Идеи и предложения',
        description: 'Было бы неплохо реализовать это...'
      ),
      StickedTopic.new(
        url: '/s/102-Tema-ob-oshibkah',
        title: 'Ошибки',
        description: 'Топик о любых проблемах на сайте'
      )
    ]
  end

  def new_topic_url
    h.new_topic_url(
      forum: forum,
      linked_id: h.params[:linked_id],
      linked_type: h.params[:linked_type],
      'topic[user_id]' => h.current_user.id,
      'topic[forum_id]' => forum ? forum.id : nil,
      'topic[linked_id]' => linked ? linked.id : nil,
      'topic[linked_type]' => linked ? linked.class.name : nil
    )
  end
end
