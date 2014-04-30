# TODO: если жалоб пользователей на удаление Feed не будет, то выпилить этот раздел с логикой подписок на топики совсем
class Section < ActiveRecord::Base
  has_many :topics, dependent: :destroy

  before_create :set_permalink

  News = Section.new(
    position: -1,
    name: 'Новости',
    permalink: 'news',
    description: 'Новости аниме и манги.',
    meta_title: 'Новости аниме и манги',
    meta_keywords: 'аниме, манга, новости, события',
    meta_description: 'Новости аниме и манги на шикимори.',
    is_visible: true
  )
  All = Section.new(
    position: -2,
    name: 'Все',
    description: 'Все активные топики сайта.',
    permalink: 'all',
    meta_title: 'Энциклопедия аниме и манги',
    meta_keywords: 'аниме, манга, список, каталог, форум, обсуждения, отзывы, персонажи, герои, косплей, сайт, анимэ, anime, manga',
    meta_description: 'Шикимори - энциклопедия аниме и манги, площадка для дискуссий на анимешные темы.',
    is_visible: true
  )
  Feed = Section.new(
    position: -3,
    name: 'Лента',
    description: 'Топики, где я участвую в обсуждении, или за которыми я слежу.',
    permalink: 'f',
    meta_title: 'Моя лента',
    is_visible: true
  )

  NewsId = [2,6]
  AnimeNewsId = 2
  GroupsId = 10
  OfftopicId = 8
  ContestsId = 13
  TestId = 5

  def to_param
    permalink
  end

  # задание пермалинка, если он не был задан
  def set_permalink
    self.permalink = Russian.translit(self.name.gsub(/[^A-zА-я0-9]/, '-').gsub(/-+/, '-').sub(/-$|^-/, '')).downcase unless permalink
  end

  def self.with_aggregated
    @with_aggregated ||= ([All, News] + real).sort_by(&:position)
  end

  def self.visible
    with_aggregated.select(&:is_visible)
  end

  def self.real
    @real ||= all.to_a
  end

  def self.find_by_permalink permalink
    with_aggregated.find {|v| v.permalink == permalink }
  end

  #def self.with_aggregated user
    #@sections ||= {}
    #@sections[user.present?] ||= ((user.present? ? [Feed, All, News] : [All, News]) + all.to_a).sort_by(&:position)
  #end

  #def self.visible_for user
    #with_aggregated(user).select(&:is_visible)
  #end

  #def self.find_by_permalink permalink, user
    #with_aggregated(user).find {|v| v[:permalink] == permalink }
  #end
end
