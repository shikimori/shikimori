require 'singleton'

# TODO: отрефакторить comments хелперы и вынести всё сюда
class BbCodeFormatter
  include Singleton

  include CommentHelper
  include Rails.application.routes.url_helpers

  HASH_TAGS = [BbCodes::ImageTag, BbCodes::ImgTag]
  TAGS = [
    BbCodes::VideoUrlTag, BbCodes::VideoTag,
    BbCodes::PosterTag, BbCodes::WallImageTag, BbCodes::EntriesTag,
    BbCodes::WallTag, BbCodes::HrTag, BbCodes::BrTag, BbCodes::PTag,
    BbCodes::BTag, BbCodes::ITag, BbCodes::UTag, BbCodes::STag,
    BbCodes::SizeTag, BbCodes::CenterTag, BbCodes::RightTag,
    BbCodes::ColorTag, BbCodes::SolidTag, BbCodes::UrlTag,
    BbCodes::ListTag, BbCodes::H3Tag, BbCodes::RepliesTag,
    BbCodes::ContestStatusTag, BbCodes::ContestRoundStatusTag,
    BbCodes::Html5VideoTag, BbCodes::SourceTag
  ]
  OBSOLETE_TAGS = %r(
    \[user_change=\d+\] | \[\/user_change\]
  )mix

  DB_ENTRY_TAGS = [
    BbCodes::AnimeTag, BbCodes::MangaTag,
    BbCodes::CharacterTag, BbCodes::PersonTag,
  ]
  DB_ENTRY_BB_CODES = [:anime, :manga, :character, :person]

  default_url_options[:protocol] = false
  default_url_options[:host] ||= if Rails.env.development?
    'shikimori.dev'
  elsif Rails.env.beta?
    "beta.#{Site::DOMAIN}"
  else
    Site::DOMAIN
  end

  MALWARE_DOMAINS = /(https?:\/\/)?images.webpark.ru/i
  MIN_PARAGRAPH_SIZE = 110

  # форматирование описания чего-либо
  def format_description text, entry
    text ||= ''

    if entry.kind_of?(Review) || entry.kind_of?(Contest) || entry.kind_of?(Genre) || entry.kind_of?(Club)
      format_comment paragraphs(text)

    elsif entry.respond_to? :characters
      format_comment paragraphs(character_names(text, entry)) # очень важно сначала персонажей, а только потом параграфы

    else
      format_comment paragraphs(text)
    end
  end

  # форматирование текста комментариев
  def format_comment original_body
    text = (original_body || '').fix_encoding.strip
    text = remove_wiki_codes text
    text = strip_malware text
    text = user_mention text

    text = ERB::Util.h(text)
    text = bb_codes text

    cleanup_html(text).html_safe
  end

  # обработка ббкодов текста
  # TODO: перенести весь код ббкодов сюда или в связанные классы
  def bb_codes original_body
    text_hash = XXhash.xxh32 original_body, 0
    text = original_body.gsub %r{\r\n|\r|\n}, '<br>'

    HASH_TAGS.each do |tag_klass|
      text = tag_klass.instance.format text, text_hash
    end

    TAGS.each do |tag_klass|
      text = tag_klass.instance.format text
    end

    text = text.gsub '<ul><br>', '<ul>'
    text = text.gsub '</ul><br>', '</ul>'

    BbCodeReplacers.each do |processor|
      text = send processor, text
    end

    text = text.gsub OBSOLETE_TAGS, ''
    text = db_entry_mention text

    DB_ENTRY_TAGS.each do |tag_klass|
      text = tag_klass.instance.format text
    end

    text
  end

  # удаление из текста вредоносных доменов
  def strip_malware text
    text.gsub MALWARE_DOMAINS, 'malware.domain'
  end

  # замена концов строк на параграфы
  def paragraphs text
    # препроцессинг контента, чтобы теги параграфов не разрывали содержимое тегов
    text = text.gsub(/
        (?<tag>
          \[
            (?:quote|list|spoiler)
            (\[.*?\] | [^\]])*
          \]
          (?!\r\n|\r|\n|<br>)
        )
      /mix) do |line|
        "#{$~[:tag]}\n"
      end

    text.gsub(/(?<line>.+?)(?:\n|<br\s?\/?>|&lt;br\s?\/?&gt;|$)/x) do |line|
      unbalanced_tags = [:quote,:list,:spoiler].inject(0) do |memo, tag|
        memo + (line.scan("[#{tag}").size - line.scan("[/#{tag}]").size).abs
      end

      if line.size >= MIN_PARAGRAPH_SIZE && line !~ /^ *\[\*\]/ && unbalanced_tags.zero?
        "[p]#{line.gsub(/\r\n|\n|<br\s?\/?>|&lt;br\s?\/?&gt;/, '')}[/p]"
      else
        line
      end
    end.html_safe
  end

  # замена имён персонажей на ббкоды
  def character_names text, entry
    CharactersNamesService.instance.process(text, entry)
  end

  # обработка обращений к пользователю
  def user_mention text
    text.gsub(/@([^\n\r,]{1,20})/) do |matched|
      nickname = $1
      text = []

      while nickname.present?
        user = User.find_by_nickname nickname

        break if user
        break if nickname !~ / |\./
        nickname = nickname.sub(/(.*)((?: |\.).*)/, '\1')
        text << $2
      end

      if user
        "[mention=#{user.id}]#{user.nickname}[/mention]#{text.reverse.join ''}"
      else
        matched
      end
    end
  end

  def preprocess_comment text
    user_mention(text)
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
  end

  # TODO: refactor to name match
  def db_entry_mention text
    text.gsub %r{\[(?!\/|#{(SIMPLE_BB_CODES + COMPLEX_BB_CODES + DB_ENTRY_BB_CODES).map {|v| "#{v}\\b" }.join('|') })(.*?)\]} do |matched|
      name = $1.gsub('&#x27;', "'").gsub('&quot;', '"')

      splitted_name = name.split(' ')

      entry = if name.contains_russian?
        Anime.order('score desc').find_by_russian(name) ||
          Manga.order('score desc').find_by_russian(name) ||
          Character.find_by_russian(name) ||
          (splitted_name.size == 2 ? Character.find_by_russian(splitted_name.reverse.join ' ') : nil)
      elsif name != 'manga' && name != 'list' && name != 'anime'
        Anime.order('score desc').find_by_name(name) ||
          Manga.order('score desc').find_by_name(name) ||
          Character.find_by_name(name) ||
          (splitted_name.size == 2 ? Character.find_by_name(splitted_name.reverse.join ' ') : nil) ||
          Person.find_by_name(name) ||
          (splitted_name.size == 2 ? Person.find_by_name(splitted_name.reverse.join ' ') : nil)
      end

      entry ? "[#{entry.class.name.downcase}=#{entry.id}]" : matched
    end
  end
end
