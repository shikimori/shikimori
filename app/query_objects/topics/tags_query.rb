class Topics::TagsQuery
  method_object

  BASIC_TAGS = %w[
    аниме
    манга
    ранобэ
    сайт
    кино
    игры
    визуальные_новеллы
  ]

  def call
    Topics::NewsTopic.distinct.pluck(Arel.sql('unnest(tags) as tag')).sort - BASIC_TAGS
  end
end
