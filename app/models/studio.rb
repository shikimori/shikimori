class Studio < ApplicationRecord
  MERGED = {
    83 => 48,
    88 => 48,
    292 => 48,
    425 => 48,
    436 => 48,
    805 => 48,
    141 => 18,
    94 => 73
  }

  validates :image, attachment_content_type: { content_type: /\Aimage/ }

  # Relations
  has_and_belongs_to_many :animes
  has_attached_file :image,
    url: '/system/studios/:style/:id.:extension',
    path: ':rails_root/public/system/studios/:style/:id.:extension'

  STUDIO_NAME_FILTER = /°|^studios? | studios?$| productions?$| entertainment?$| animation?$|^animation? /i

  def self.filtered_name name
    # name.downcase.gsub(STUDIO_NAME_FILTER, '')
    name.gsub(STUDIO_NAME_FILTER, '')
  end

  def filtered_name
    Studio.filtered_name name
  end

  # возвращет настоящую струдию, если это была склеенная студия
  def real
    MERGED.keys.include?(id) ? self.class.find(MERGED[id]) : self
  end

  # возвращет все id, связанные с текущим
  def self.related(id)
    MERGED.map { |k, v| k == id ? v : (v == id ? k : nil) }.compact << id
  end

  # возвращает все аниме студии с учетом склеенных студий
  def all_animes
    animes unless MERGED.values.include?(id)
    ids = []
    ApplicationRecord.connection
        .execute(format('SELECT * FROM animes_studios where studio_id in (%s)', (MERGED.select { |_k, v| v == id }.map { |k, _v| k } + [id]).join(','))).each do |v|
      ids << v[0]
    end
    Anime.where(id: ids)
  end

  def to_param
    format('%d-%s', id, name.gsub(/[^\w]+/, '-').gsub(/^-|-$/, ''))
  end
end
