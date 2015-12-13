class Forums::Menu < ViewObjectBase
  instance_cache :clubs

  def clubs
    GroupComment
      .includes(:linked)
      .order(updated_at: :desc)
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
end
