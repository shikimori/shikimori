class Publisher < ApplicationRecord
  MERGED = {
    # 48 => 8,
    # 206 => 81,
    # 108 => 72,
    # 229 => 12,
    # 397 => 12,
    # 129 => 83
  }
  DESYNCABLE = %w[
    name
  ]

  has_and_belongs_to_many :mangas

  def to_param
    format('%<id>d-%<slug>s', id: id, slug: name.gsub(/[^\w]+/, '-').gsub(/^-|-$/, ''))
  end

  def name
    self[:name].gsub(/^Weekly |^Monthly | ?\(.*\)/i, '').sub(//, '').strip
  end

  # возвращет все id, связанные с текущим
  def self.related id, recursive = false
    related = MERGED.map { |k, v| k == id ? v : (v == id ? k : nil) }.compact
    related = related.map { |v| self.related(v, true) }.flatten.uniq unless recursive
    related << id
  end

  # возвращет настоящего издателя, если это был склеенный издатель
  def real
    MERGED.key?(id) ? self.class.find(MERGED[id]) : self
  end
end
