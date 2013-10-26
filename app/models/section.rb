class Section < ActiveRecord::Base
  belongs_to :forum
  has_many :topics, :dependent => :destroy

  before_create :set_permalink

  attr_accessible :id, :name, :permalink, :description, :meta_title, :meta_keywords, :meta_description

  News = Section.new({
    name: 'Новости',
    permalink: 'news',
    description: 'Новости аниме и манги.',
    meta_title: 'Новости аниме и манги',
    meta_keywords: 'аниме, манга, новости, события',
    meta_description: 'Новости аниме и манги на шикимори.'
  })

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
end
