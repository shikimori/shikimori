class BbCode
  include Singleton

  include CommentHelper
  BB_CODE_REPLACERS = COMPLEX_BB_CODES.map { |v| "#{v}_to_html".to_sym }.reverse

  include Rails.application.routes.url_helpers

  HASH_TAGS = BbCodes::ToTag.call %i[image img]

  TAGS = BbCodes::ToTag.call %i[
    quote replies comment
    db_entry_url video_url video
    poster wall_image entries
    wall poll

    contest_status contest_round_status
    html5_video source broadcast

    div hr br p
    b i u s
    size center right
    color solid url
    list h3
  ]

  DB_ENTRY_BB_CODES = %i[anime manga ranobe character person]
  DB_ENTRY_TAGS = BbCodes::ToTag.call DB_ENTRY_BB_CODES

  OBSOLETE_TAGS = %r{\[user_change=\d+\] | \[/user_change\]}mix

  MALWARE_DOMAINS = %r{(https?://)? (images.webpark.ru|shikme.ru) }mix

  default_url_options[:protocol] = false
  default_url_options[:host] ||=
    if Rails.env.development?
      'shikimori.dev'
    elsif Rails.env.beta?
      "beta.#{Shikimori::DOMAIN}"
    else
      Shikimori::DOMAIN
    end

  # форматирование текста комментариев
  def format_comment original_body
    text = (original_body || '').fix_encoding.strip
    text = remove_wiki_codes text
    text = strip_malware text
    text = user_mention text

    text = String.new ERB::Util.h(text)
    text = bb_codes text

    cleanup_html(text).html_safe
  end

  # обработка ббкодов текста
  # TODO: перенести весь код ббкодов сюда или в связанные классы
  def bb_codes text
    text_hash = XXhash.xxh32 text, 0

    code_tag = BbCodes::Tags::CodeTag.new(text)
    text = code_tag.preprocess
    text = text.gsub /\r\n|\r/, "\n"
    text = BbCodes::Tags::CleanupNewLines.call text, BbCodes::Tags::CleanupNewLines::TAGS

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
    text = db_entry_mention text

    DB_ENTRY_TAGS.each do |tag_klass|
      text = tag_klass.instance.format text
    end

    text = text.gsub /\r\n|\r|\n/, '<br>'
    text = code_tag.postprocess text
    text
  end

  # удаление из текста вредоносных доменов
  def strip_malware text
    text.gsub MALWARE_DOMAINS, 'malware.domain'
  end

  # обработка обращений к пользователю
  def user_mention text
    text.gsub(/@([^\n\r,]{1,20})/) do |matched|
      nickname = Regexp.last_match(1)
      text = []

      while nickname.present?
        user = User.find_by_nickname nickname

        break if user
        break if nickname !~ / |\./
        nickname = nickname.sub(/(.*)((?: |\.).*)/, '\1')
        text << Regexp.last_match(2)
      end

      if user
        "[mention=#{user.id}]#{user.nickname}[/mention]#{text.reverse.join ''}"
      else
        matched
      end
    end
  end

  def preprocess_comment text
    user_mention(text).strip
  end

  # удаление мусора из текста и нормализация битых тегов
  def cleanup_html text
    text = text
      .gsub(/!!!+/, '!')
      .gsub(/\?\?\?+/, '?')
      .gsub(/\.\.\.\.+/, '.')
      .gsub(/\)\)\)+/, ')')
      .gsub(/\(\(\(+/, '(')
      .gsub(/(<img [^>]*? class="smiley" \/>)\s*<img [^>]*? class="smiley" \/>(?:\s*<img .*? class="smiley" \/>)+/, '\1')

    Nokogiri::HTML::DocumentFragment
      .parse(text)
      .to_html(save_with: Nokogiri::XML::Node::SaveOptions::AS_HTML | Nokogiri::XML::Node::SaveOptions::NO_DECLARATION)

  # LoadError: cannot load such file -- enc/trans/single_byte
  rescue StandardError => e
    if e.message =~ /cannot load such file/
      text
    else
      raise
    end
  end

  # TODO: refactor to name match
  def db_entry_mention text
    text.gsub %r{\[(?!\/|#{(SIMPLE_BB_CODES + COMPLEX_BB_CODES + DB_ENTRY_BB_CODES).map { |v| "#{v}\\b" }.join('|') })(.*?)\]} do |matched|
      name = Regexp.last_match(1).gsub('&#x27;', "'").gsub('&quot;', '"')

      splitted_name = name.split(' ')

      entry =
        if name.contains_russian?
          Anime.order('score desc').find_by_russian(name) ||
            Manga.order('score desc').find_by_russian(name) ||
            Character.find_by_russian(name) ||
            (splitted_name.size == 2 ? Character.find_by_russian(splitted_name.reverse.join(' ')) : nil)
        elsif name != 'manga' && name != 'list' && name != 'anime'
          Anime.order('score desc').find_by_name(name) ||
            Manga.order('score desc').find_by_name(name) ||
            Character.find_by_name(name) ||
            (splitted_name.size == 2 ? Character.find_by_name(splitted_name.reverse.join(' ')) : nil) ||
            Person.find_by_name(name) ||
            (splitted_name.size == 2 ? Person.find_by_name(splitted_name.reverse.join(' ')) : nil)
        end

      entry ? "[#{entry.class.name.downcase}=#{entry.id}]" : matched
    end
  end
end
