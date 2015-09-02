class Banhammer
  vattr_initialize :comment

  Z = '[!@#$%&*^]'
  X = '[\s.,-:?!)(\]\[]'
  TAG = '(?: \[ [^\]]+  \] )?'

  SYNONYMS = {
    а: ['a', 'а'],
    б: ['b', 'б'],
    в: ['v', 'в'],
    д: ['d', 'д'],
    е: ['e', 'е', 'ё'],
    з: ['z', '3', 'з'],
    и: ['i', 'и'],
    й: ['y', 'i', 'й'],
    к: ['k', 'к'],
    л: ['l', 'л'],
    н: ['n', 'н'],
    о: ['o', 'о'],
    п: ['p', 'п'],
    р: ['р', 'p', 'r'],
    с: ['c', 's', 'с'],
    т: ['t', 'т'],
    у: ['y', 'у'],
    х: ['x', 'h', 'х'],
    ч: ['ch', 'ч'],
    я: ['ya', 'я'],
  }

  def self.w word
    "(?:#{word.to_s.split(//).map {|v| l v }.join ' '})"
  end

  def self.l letter
    synonyms = SYNONYMS[letter.to_sym] || [letter]
    "(?:#{synonyms.join('|')}|#{Z})#{TAG}"
  end

  ABUSIVE_WORDS = %w{
    бля
    блядина
    блядки
    блядовать
    блядский
    блядство
    блядь
    блять
    взъебка
    впиздячить
    вхуярить
    выебать
    выебон
    выебывается
    выебываться
    выпиздеться
    выпиздить
    доебался
    доебаться
    долбоеб
    допиздеться
    дуроеб
    еба
    ебало
    ебальник
    ебанатик
    ебанешься
    ебанной
    ебанный
    ебанул
    ебанулся
    ебанутый
    ебануть
    ебаный
    ебаришка
    ебарь
    ебаторий
    ебать
    ебаться
    ебистика
    ебическая
    ебливая
    ебло
    еблом
    еблысь
    ебля
    ебнутый
    ебнуть
    ебнуться
    ебукентий
    заебанный
    заебать
    заебаться
    заебись
    запиздеть
    захуярить
    злоебучая
    испиздить
    исхуячить
    коноебиться
    мозгоеб
    мудоеб
    наебнуться
    напиздить
    настоебать
    нах
    нахер
    нахуй
    нахуяриться
    однохуйственно
    остопиздеть
    отпиздить
    отъебаться
    охуел
    охуенно
    охуенный
    охуеть
    охуительный
    охуячить
    пезды
    перехуярить
    пизда
    пиздабол
    пиздануть
    пизде
    пиздеж
    пиздеть
    пиздец
    пиздить
    пиздить
    пиздобол
    пиздобратия
    пиздой
    пиздолет
    пиздорванец
    пиздорванка
    пиздошить
    пиздошить
    пизду
    пиздуй
    пиздун
    пизды
    пиздюк
    пиздюлей
    пиздюли
    пиздюлина
    пиздюрить
    пиздюхать
    пиздюшник
    поебать
    поебень
    попиздеть
    попиздили
    пох
    похер
    похуярили
    приебаться
    припиздить
    прихуярить
    проебать
    проебаться
    пропиздить
    разебанный
    разъебай
    разъебаться
    распиздон
    распиздяй
    распиздяйка
    расхуюжить
    спиздил
    спиздить
    сука
    сученок
    сучка
    схуярить
    уебался
    уебать
    уебище
    уебывать
    упиздить
    хер
    хера
    херня
    херово
    херь
    худоебина
    хуебратия
    хуев
    хуеватенький
    хуевато
    хуевина
    хуевничать
    хуево
    хуеву
    хуевый
    хуеглот
    хуегрыз
    хуем
    хуемырло
    хуеплет
    хуесос
    хуета
    хуетень
    хуила
    хуй
    хуйло
    хуйнуть
    хуйню
    хуйня
    хули
    хуя
    хуя
    хуяк
    хуями
    хуячить
  }

  ABUSE = /
    (?<= #{X}|\A|^ )
    (
      #{ABUSIVE_WORDS.map {|word| w word }.join ' | '}
    )
    (?= #{X}|\Z|$ )
  /mix

  ABUSE_SYMBOL = /#{Z}|[\[\]\/]/
  NOT_ABUSE = /
    (?:#{X}|\A|^)
      (?:
        #{Z}{1,12} |
        her |
        eba
      )
    (?:#{X}|\Z|$)
  /mix

  def release
    ban if abusive?
  end

  def abusive? text = self.comment.body
    abusiveness(text) > 0
  end

private

  def ban
    duration = ban_duration

    comment.update_column :body, censored_body
    # TODO localize ban reason later
    Ban.create!(
      user: comment.user,
      comment: comment,
      duration: duration,
      reason: "п.3 [url=http://shikimori.org/s/79042-pravila-sayta]правил сайта[/url]",
      moderator: User.find(User::Banhammer_ID)
    )
  end

  def ban_duration
    duration = if comment.user.bans.size >= 2 && comment.user.bans.last.created_at > 36.hours.ago
      '1d'
    elsif comment.user.bans.any?
      '2h'
    else
      '15m'
    end

    multiplier = BanDuration.new(duration).to_i
    BanDuration.new(multiplier * abusiveness).to_s
  end

  def censored_body
    comment.body.gsub ABUSE do |match|
      "[color=#ff4136]#{match.size.times.inject(''){|v| v + '#' }}[/color]"
    end
  end

  def abusiveness text = self.comment.body
    @abusivenesses ||= {}
    @abusivenesses[text] ||=
      text
        .gsub(BbCodes::UrlTag::REGEXP, '')
        .gsub(BbCodes::ImgTag::REGEXP, '')
        .gsub(BbCodes::PosterTag::REGEXP, '')
        .scan(ABUSE)
        .select do |group|
          group.select(&:present?).select do |match|
            match.size >= 3 && match !~ NOT_ABUSE &&
              match.scan(ABUSE_SYMBOL).size <= (match.size / 2).floor
          end.any?
        end
        .size
  end
end
