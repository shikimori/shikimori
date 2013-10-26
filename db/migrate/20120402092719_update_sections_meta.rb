
class UpdateSectionsMeta < ActiveRecord::Migration
  def self.up
    Section.find_by_permalink('a').update_attributes({
        meta_title: 'Аниме форум',
        meta_keywords: 'аниме форум, блоги, обсуждения, обзоры, дискуссии, онгоиги',
        meta_description: 'Форум, посвящённый аниме: разговоры на любые анимешные темы, обсуждение сериалов, полнометражек и онгоигов. Обзоры, мнения и впечатления.'
      })
    Section.find_by_permalink('m').update_attributes({
        meta_title: 'Форум манги',
        meta_keywords: 'манга форум, новеллы, дискуссии, блоги, обсуждения, обзоры',
        meta_description: 'Форум, посвящённый манге: разговоры на любые темы о манге, новеллах и додзинси. Обзоры, мнения и впечатления.'
      })
    Section.find_by_permalink('c').update_attributes({
        meta_title: 'Форум о персонажах',
        meta_keywords: 'персонажи аниме и манги, обсуждения, дискуссии',
        meta_description: 'Форум, посвящённый персонажам аниме и манги.'
      })
    Section.find_by_permalink('s').update_attributes({
        meta_title: 'Форум сайта',
        meta_keywords: 'форум о сайте шикимори',
        meta_description: 'Работа сайта, новости, обновления, предложения об улучшении функционала'
      })
    Section.find_by_permalink('f').update_attributes({
        meta_title: 'Оффтопик',
        meta_keywords: 'оффтопик',
        meta_description: 'Форум обо всём, что не подходит для других разделов сайта.'
      })
  end

  def self.down
  end
end
