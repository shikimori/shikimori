class BbCodes::Text # rubocop:disable ClassLength
  method_object :text, %i[object is_event]

  # TODO: cleanup
  # delete CommentHelper
  # delete BB_CODE_REPLACERS
  # delete include Rails.application.routes.url_helpers
  include CommentHelper
  BB_CODE_REPLACERS = COMPLEX_BB_CODES.map { |v| "#{v}_to_html".to_sym }.reverse
  include Rails.application.routes.url_helpers

  SIMPLE_BB_CODES = %i[
    b s u i url img list right center solid
  ]

  HASH_TAGS = BbCodes::ToTagParser.call %i[image img]

  MARKDOWNS = BbCodes::ToMarkdownParser.call %i[
    headline
    list_quote
    spoiler_inline
  ]

  TAGS_LIST = %i[
    db_entry_url
    video_url video
    url

    mention
    quote replies
    user comment topic review message

    poster wall_image db_entries
    wall poll

    contest_status contest_round_status
    source broadcast

    div span hr br p
    b i u s
    size center right
    color solid
    list h3

    spoiler
    html5_video
  ]
  TAGS = BbCodes::ToTagParser.call TAGS_LIST
  PRE_POST_PROCESS_TAG_LIST = %i[
    code
    smiley
  ]
  # html5_video must be after url tag
  # spoiler must be after other tags because its label can't contain any other bbcodes

  DB_ENTRY_BB_CODES = %i[anime manga ranobe character person]
  DB_ENTRY_TAGS = BbCodes::ToTagParser.call DB_ENTRY_BB_CODES

  PRE_POST_PROCESS_TAG = BbCodes::ToTagParser.call PRE_POST_PROCESS_TAG_LIST

  OBSOLETE_TAGS = %r{\[user_change=\d+\] | \[/user_change\]}mix

  BANNED_DOMAINS = %r{
    (?:https?://)?
      (?:
       shikimori.online |
       images.webpark.ru |
       18xxx.me |
       myflirtcontacts1.com |
       (?:[^.]\.)?chatchu.com |
       (?:[^.]\.)?chatree.net |
       #{Users::CheckHacked::SPAM_DOMAINS.join '|'} |
       shikimori.cc |
       t.me/rezero_translation # copyright request
      )
  }mix
  BANNED_TEXT = '[deleted]'

  SEQUENTIAL_BR_GLOBAL_MATCH_REGEXP = /(?:<br(?: data-keep)?>){2,99}/
  SEQUENTIAL_BR_REPLACEMENT_REGEXP = /<br( data-keep|)>/

  EVENT_START_TIME = Time.zone.parse '2021-08-02 00:00:00 +0300'
  EVENT_END_TIME = Time.zone.parse '2021-08-16 23:59:59 +0300'
  EVENT_REGEXP = /
    #{BbCodes::Tags::UrlTag::BEFORE_URL.source}
    (меха|киберпанк)
    #{BbCodes::Tags::UrlTag::AFTER_URL.source}
  /xi
  EVENT_URL = 'https://www8.hp.com/ru/ru/gaming/omen/15-laptop-intel.html?jumpid=ba_04ce0c8043&utm_source=Shikimori&utm_medium=other&utm_campaign=RU_Q3_FY21_PS_CPS_CPS%20Gaming_CPS%20Gaming_OMG_Regional__Gaming____&utm_content=sp'
  EVENT_REPLACEMENT = "<a class='b-link' href='#{ERB::Util.h EVENT_URL}' target='_blank'>\\1</a>"

  default_url_options[:protocol] = Shikimori::PROTOCOL
  default_url_options[:host] ||=
    if Rails.env.development?
      'shikimori.local'
    # elsif Rails.env.beta?
    #   "beta.#{Shikimori::DOMAIN}"
    else
      Shikimori::DOMAIN
    end

  def call
    text = prepare @text
    text = remove_spam text

    text = String.new ERB::Util.h(text)
    text = highlight_event text if @object || @is_event
    text = bb_codes text

    BbCodes::CleanupHtml.call text
  end

  def bb_codes text
    tags = PRE_POST_PROCESS_TAG.map(&:new)

    text = tags.inject(text) { |memo, tag| tag.preprocess memo }
    text = parse text

    tags.reverse.inject(text) { |memo, tag| tag.postprocess memo }
  rescue BbCodes::BrokenTagError
    parse text
  end

  def remove_spam text
    text.gsub BANNED_DOMAINS, BANNED_TEXT
  end

private

  def prepare text
    (text || '').fix_encoding.strip.gsub(/\r\n|\r/, "\n")
  end

  def parse text # rubocop:disable all
    text_hash = XXhash.xxh32 text, 0

    # text = BbCodes::Tags::CleanupNewLines.call(
    #   text,
    #   BbCodes::Tags::CleanupNewLines::TAGS
    # )

    # must be in the beginning to avaid collisions
    # when other bbcodes coud produce text that can be accidentally treated as db_entry mention
    text = BbCodes::UserMention.call text
    text = BbCodes::DbEntryMention.call text

    MARKDOWNS.each do |markdown_parser|
      text = markdown_parser.instance.format text
    end

    TAGS.each do |tag_parser|
      text = tag_parser.instance.format text
    end

    HASH_TAGS.each do |tag_klass|
      text = tag_klass.instance.format text, text_hash
    end

    BB_CODE_REPLACERS.each do |processor|
      text = send processor, text
    end

    text = text.gsub OBSOLETE_TAGS, ''

    DB_ENTRY_TAGS.each do |tag_klass|
      text = tag_klass.instance.format text
    end

    mark_sequential_br(new_lines_to_br(text))
  end

  def new_lines_to_br text
    text.gsub(/\n/, '<br>')
  end

  def mark_sequential_br text
    text.gsub(SEQUENTIAL_BR_GLOBAL_MATCH_REGEXP) do |match|
      match.gsub(SEQUENTIAL_BR_REPLACEMENT_REGEXP, '<br class="br"\1>')
    end
  end

  def highlight_event text
    now = Time.zone.now
    unless !@object || @object.new_record? ||
        (@object.created_at >= EVENT_START_TIME && @object.created_at <= EVENT_END_TIME)
      return text
    end
    return text unless now >= EVENT_START_TIME && now <= EVENT_END_TIME

    text.gsub EVENT_REGEXP, EVENT_REPLACEMENT
  end
end
