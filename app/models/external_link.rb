class ExternalLink < ApplicationRecord
  belongs_to :entry, polymorphic: true, touch: true
  validates :entry, :source, :kind, :url, presence: true

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
      super Url.new(value).with_protocol.to_s
    else
      super
    end
  end

  def visible?
    !source_hidden? &&
      Types::ExternalLink::INVISIBLE_KINDS.exclude?(kind.to_sym)
  end

  def disabled?
    url&.ends_with? NO_URL
  end

  def watch_online?
    Types::ExternalLink::WATCH_ONLINE_KINDS.include? kind.to_sym
  end

  def label
    if kind_wikipedia? && url =~ %r{/(?<lang>ru|en|ja|zh|ko)\.wikipedia\.org/}
      WIKIPEDIA_LABELS[$LAST_MATCH_INFO[:lang].to_sym] || kind_text
    else
      kind_text
    end
  end

private

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
end
