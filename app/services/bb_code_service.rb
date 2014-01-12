require 'singleton'

# Обработчик текста ббкодами
# todo: отрефакторить comments хелперы и вынести всё сюда
class BbCodeService
  include Singleton

  include CommentHelper
  include Rails.application.routes.url_helpers

  default_url_options[:host] ||= Rails.env.development? ? 'dev.shikimori.org' : 'shikimori.org'

  MALWARE_DOMAINS = /(https?:\/\/)?images.webpark.ru/i

  # форматирование описания чего-либо
  def format_description text, entry
    if entry.class == Review || entry.class == Contest
      paragraphs(format_comment(text))
    elsif entry.respond_to? :characters
      paragraphs(format_comment(character_names(text, entry)))
    else
      format_comment(text)
    end
  end

  # форматирование текста комментариев
  def format_comment initial_text
    text = remove_wiki_codes initial_text
    text = strip_malware text
    text = user_mention text
    text = super text
    text = cleanup text

    text.html_safe
  end

  def preprocess_comment text
    user_mention(text)
  end

  # удаление из текста вредоносных доменов
  def strip_malware text
    text.gsub MALWARE_DOMAINS, 'malware.domain'
  end

  # замена концов строк на параграфы
  def paragraphs text
    text.gsub(/(.+?)(?:\n|<br\s?\/?>|&lt;br\s?\/?&gt;|$)/x, '<p class="prgrph">\1</p>')
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

  # удаление мусора из текста
  def cleanup text
    text.gsub(/!!!+/, '!')
        .gsub(/\?\?\?+/, '?')
        .gsub(/\.\.\.\.+/, '.')
        .gsub(/\)\)\)+/, ')')
        .gsub(/\(\(\(+/, '(')
        .gsub(/(<img .*? class="smiley" \/>)\s*<img .*? class="smiley" \/>(?:\s*<img .*? class="smiley" \/>)+/, '\1')
  end
end
