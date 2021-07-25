class Studio < ApplicationRecord
  validates :name, presence: true, length: { maximum: 255 }

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
  DESYNCABLE = %w[
    name
  ]
  STUDIO_NAME_FILTER =
    /°|^studios? | studios?$| productions?$| entertainment?$| animation?$|^animation? /i

  validates :image, attachment_content_type: { content_type: /\Aimage/ }

  # Relations
  has_attached_file :image,
    url: '/system/studios/:style/:id.:extension',
    path: ':rails_root/public/system/studios/:style/:id.:extension'

  def self.filtered_name name
    # name.downcase.gsub(STUDIO_NAME_FILTER, '')
    name.gsub(STUDIO_NAME_FILTER, '')
  end

  def filtered_name
    Studio.filtered_name name
  end

  # возвращет настоящую струдию, если это была склеенная студия
  def real
    MERGED.key?(id) ? self.class.find(MERGED[id]) : self
  end

  # возвращет все id, связанные с текущим
  def self.related(id)
    MERGED.map do |k, v|
      if k == id
        v
      else
        (v == id ? k : nil)
      end
    end
    .compact << id
  end

  def to_param
    format(
      '%<id>d-%<name>s',
      id: id,
      name: name.gsub(/[^\w]+/, '-').gsub(/^-|-$/, '')
    )
  end
end
