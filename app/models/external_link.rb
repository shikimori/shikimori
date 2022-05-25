class ExternalLink < ApplicationRecord
  belongs_to :entry, polymorphic: true, touch: true
  validates :source, :kind, :url, presence: true

  validates :checksum, uniqueness: true, if: -> { url != NO_URL }

  enumerize :kind,
    in: Types::ExternalLink::Kind.values,
    predicates: { prefix: true }

  enumerize :source,
    in: Types::ExternalLink::Source.values,
    predicates: { prefix: true }

  before_validation :compute_checksum, if: -> {
    new_record? ||
      will_save_change_to_url? ||
      will_save_change_to_entry_id? ||
      will_save_change_to_entry_type? ||
      will_save_change_to_source?
  }

  LANG_WIKIPEDIA_REGEXP = %r{/(?<lang>ru|en|ja|zh|ko)\.wikipedia\.org/}
  BAIKE_BAIDU_WIKI_REGEXP = /baike.baidu.com/
  NAMU_WIKI_REGEXP = /namu.wiki/
  MANGALIB_REGEXP = /(?:mangalib|hentailib).\w+/

  WIKIPEDIA_LABELS = {
    ru: 'Википедия',
    en: 'Wikipedia',
    ja: 'ウィキペディア',
    zh: '维基百科',
    ko: '위키백과'
  }

  NO_URL = 'NONE'

  def url= value
    if value.present? && value != NO_URL
      super cleanup_url(value)
    else
      super
    end
  end

  def visible?
    !source_hidden? &&
      Types::ExternalLink::INVISIBLE_KINDS.exclude?(kind.to_sym)
  end

  def disabled?
    url&.ends_with?(NO_URL) ||
      Types::ExternalLink::NOT_AVAILABLE_IN_RUSSIA_KINDS.include?(kind.to_sym)
  end

  def watch_online?
    Types::ExternalLink::WATCH_ONLINE_KINDS.include? kind.to_sym
  end

  def read_online?
    Types::ExternalLink::MANGA_READ_ONLINE_KINDS.include?(kind.to_sym) ||
      Types::ExternalLink::RANOBE_READ_ONLINE_KINDS.include?(kind.to_sym)
  end

  def label
    if kind_wikipedia? && url =~ LANG_WIKIPEDIA_REGEXP
      WIKIPEDIA_LABELS[$LAST_MATCH_INFO[:lang].to_sym] || kind_text
    elsif baike_baidu_wiki?
      'Wiki Baidu'
    elsif namu_wiki?
      'Wiki Namu'
    else
      kind_text
    end
  end

  def icon_kind
    if baike_baidu_wiki?
      'baike_baidu_wiki'
    elsif namu_wiki?
      'namu_wiki'
    else
      kind.to_s
    end
  end

private

  def baike_baidu_wiki?
    kind_wikipedia? && url.match?(BAIKE_BAIDU_WIKI_REGEXP)
  end

  def namu_wiki?
    kind_wikipedia? && url.match?(NAMU_WIKI_REGEXP)
  end

  def compute_checksum
    self.checksum = Digest::MD5.hexdigest(
      <<~HASH
        #{Url.new(url).without_protocol.cut_slash if url.present?}
        #{entry_id}
        #{entry_type}
        #{source}
      HASH
    )
  end

  def cleanup_url url
    fixed_url = Url.new(url).with_protocol.to_s
    fixed_url = fixed_url.gsub(/\?.*/, '') if fixed_url.match MANGALIB_REGEXP
    fixed_url
  end
end
