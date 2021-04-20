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
    лайв_экшен
    прочее
  ]
  PROMO_TAG = 'партнёрский_материал'
  BASIC_TAGS_WITH_PROMO = BASIC_TAGS + [PROMO_TAG]

  def call
    Topics::NewsTopic.distinct.pluck(Arel.sql('unnest(tags) as tag')).sort - BASIC_TAGS
  end
end
