require 'singleton'

# Обработчик текста ббкодами
# todo: отрефакторить comments хелперы и вынести всё сюда
class BbCodeFormatter
  include Singleton

  include CommentHelper
  include Rails.application.routes.url_helpers

  default_url_options[:host] ||= if Rails.env.development?
    'shikimori.dev'
  elsif Rails.env.beta?
    'beta.shikimori.org'
  else
    'shikimori.org'
  end

  MALWARE_DOMAINS = /(https?:\/\/)?images.webpark.ru/i

  # форматирование описания чего-либо
  def format_description text, entry
    if entry.kind_of?(Review) || entry.kind_of?(Contest) || entry.kind_of?(Genre) || entry.kind_of?(Group)
      paragraphs format_comment(text)
    elsif entry.respond_to? :characters
      paragraphs format_comment(character_names(text, entry))
    else
      #format_comment text
      paragraphs format_comment(text)
    end
  end

  # форматирование текста комментариев
  def format_comment original_text
    text = (original_text || '').strip
    text = remove_wiki_codes text
    text = strip_malware text
    text = user_mention text

    text = ERB::Util.h(text)
    text = bb_codes text

    text = cleanup text

    text.html_safe
  end

  # обработка ббкодов текста
  # TODO: перенести весь код ббкодов сюда или в связанные классы
  def bb_codes original_text
    text_hash = XXhash.xxh32 original_text, 0

    text = original_text.gsub %r{\r\n|\r|\n}, '<br />'

    text = BbCodes::VideoTag.instance.format text
    text = BbCodes::ImageTag.instance.format text, text_hash
    text = BbCodes::ImgTag.instance.format text, text_hash
    text = BbCodes::PosterTag.instance.format text

    text = text.bbcode_to_html @@custom_tags, false, :disable, :quote, :link, :image, :listitem, :img
    text = text.gsub %r{<a href="(?!http|/)}, '<a href="http://'
    text = text.gsub '<ul><br />', '<ul>'
    text = text.gsub '</ul><br />', '</ul>'

    BbCodeReplacers.each do |processor|
      text = send processor, text
    end

    text = db_entry_mention text
    text = anime_to_html text
    text = manga_to_html text
    text = character_to_html text
    text = person_to_html text

    text
  end

  # удаление из текста вредоносных доменов
  def strip_malware text
    text.gsub MALWARE_DOMAINS, 'malware.domain'
  end

  # замена концов строк на параграфы
  def paragraphs text
    text.gsub(/(.+?)(?:\n|<br\s?\/?>|&lt;br\s?\/?&gt;|$)/x, '<div class="prgrph">\1</div>').html_safe
  end

  # замена имён персонажей на ббкоды
  def character_names *args
    CharactersService.instance.process(*args)
  end

  # обработка обращений к пользователю
  def user_mention text
    text.gsub /@([^\n\r,]{1,20})/ do |matched|
      nickname = $1
      text = []

      while nickname.present?
        user = User.find_by_nickname nickname

        break if user
        break if nickname !~ / |\./
        nickname = nickname.sub /(.*)((?: |\.).*)/, '\1'
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

  # удаление мусора из текста
  def cleanup text
    text
      .gsub(/!!!+/, '!')
      .gsub(/\?\?\?+/, '?')
      .gsub(/\.\.\.\.+/, '.')
      .gsub(/\)\)\)+/, ')')
      .gsub(/\(\(\(+/, '(')
      .gsub(/(<img .*? class="smiley" \/>)\s*<img .*? class="smiley" \/>(?:\s*<img .*? class="smiley" \/>)+/, '\1')
  end
end
