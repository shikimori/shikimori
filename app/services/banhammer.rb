class Banhammer
  include Singleton

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

  ABUSIVE_WORDS = YAML::load_file Rails.root.join 'config/app/abusive_words.yml'

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
        eba |
        на!
      )
    (?:#{X}|\Z|$)
  /mix

  def release! comment
    ban comment if abusive? comment.body
  end

  def abusive? text
    abusiveness(text) > 0
  end

  def censor text
    replace_abusiveness text, 'x'
  end

private

  def ban comment
    duration = ban_duration comment

    comment.update_column :body, replace_abusiveness(comment.body, nil)
    # TODO localize ban reason later
    Ban.create!(
      user: comment.user,
      comment: comment,
      duration: duration,
      reason: "п.3 [url=//shikimori.org/s/79042-pravila-sayta]правил сайта[/url]",
      moderator: User.find(User::BANHAMMER_ID)
    )
  end

  def ban_duration comment
    duration = if comment.user.bans.size >= 2 && comment.user.bans.last.created_at > 36.hours.ago
      '1d'
    elsif comment.user.bans.any?
      '2h'
    else
      '15m'
    end

    multiplier = BanDuration.new(duration).to_i
    BanDuration.new(multiplier * abusiveness(comment.body)).to_s
  end

  def replace_abusiveness text, replacement
    text.gsub ABUSE do |match|
      if replacement
        "#{match.size.times.inject('') { |v| v + replacement }}"
      else
        "[color=#ff4136]#{match.size.times.inject('') { |v| v + '#' }}[/color]"
      end
    end
  end

  def abusiveness text
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
