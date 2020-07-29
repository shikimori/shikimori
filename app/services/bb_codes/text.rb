class BbCodes::Text
  method_object :text

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

  HASH_TAGS = BbCodes::ToTag.call %i[image img]

  TAGS = BbCodes::ToTag.call %i[
    quote replies comment topic message

    db_entry_url video_url video
    poster wall_image entries
    wall poll

    contest_status contest_round_status
    source broadcast

    div hr br p
    b i u s
    size center right
    color solid url
    list h3

    html5_video
  ] # html5_video must be after url tag

  DB_ENTRY_BB_CODES = %i[anime manga ranobe character person]
  DB_ENTRY_TAGS = BbCodes::ToTag.call DB_ENTRY_BB_CODES

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
       t.me/rezero_translation # copyright request
      )
  }mix

  BANNED_TEXT = '[deleted]'

  default_url_options[:protocol] = Shikimori::PROTOCOL
  default_url_options[:host] ||=
    if Rails.env.development?
      'shikimori.local'
    elsif Rails.env.beta?
      "beta.#{Shikimori::DOMAIN}"
    else
      Shikimori::DOMAIN
    end

  def call
    text = (@text || '').fix_encoding.strip
    text = remove_spam text

    text = String.new ERB::Util.h(text)
    text = bb_codes text

    BbCodes::CleanupHtml.call text
  end

  # обработка ббкодов текста
  # TODO: перенести весь код ббкодов сюда или в связанные классы
  def bb_codes text
    code_tag = BbCodes::Tags::CodeTag.new(text)

    code_tag.postprocess parse(code_tag.preprocess)
  rescue BbCodes::Tags::CodeTag::BrokenTagError
    parse(text)
  end

  def remove_spam text
    text.gsub BANNED_DOMAINS, BANNED_TEXT
  end

private

  def parse text # rubocop:disable all
    text_hash = XXhash.xxh32 text, 0

    text = text.gsub(/\r\n|\r/, "\n")
    text = BbCodes::Tags::CleanupNewLines.call(
      text,
      BbCodes::Tags::CleanupNewLines::TAGS
    )

    # must be in the beginning to avaid collisions
    # when other bbcodes coud produce text that can be accidentally treated as db_entry mention
    text = BbCodes::UserMention.call text
    text = BbCodes::DbEntryMention.call text

    HASH_TAGS.each do |tag_klass|
      text = tag_klass.instance.format text, text_hash
    end

    TAGS.each do |tag_klass|
      text = tag_klass.instance.format text
    end

    BB_CODE_REPLACERS.each do |processor|
      text = send processor, text
    end

    text = text.gsub OBSOLETE_TAGS, ''

    DB_ENTRY_TAGS.each do |tag_klass|
      text = tag_klass.instance.format text
    end

    text.gsub(/\r\n|\r|\n/, '<br>')
  end
end
