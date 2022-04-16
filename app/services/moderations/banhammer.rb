class Moderations::Banhammer # rubocop:disable ClassLength
  include Translation
  include Singleton

  Z = '[@#$%&*^]'
  X = '[\s.,:?!)(\]\[\'"«»-]'
  TAG = '(?: \[ [^\]]+ \] )*'
  TAG_REGEXP = /#{TAG}/mix

  INVISIBLE_SYMBOLS = '[­]*'

  SYNONYMS = {
    а: %w[a а],
    б: %w[b б],
    в: %w[v в],
    д: %w[d д],
    е: %w[e е ё],
    з: %w[z 3 з],
    и: %w[i и],
    й: %w[y i й],
    к: %w[k к],
    л: %w[l л],
    н: %w[n н],
    о: %w[o о],
    п: %w[p п],
    р: %w[р p r],
    с: %w[c s с],
    т: %w[t т],
    у: %w[y у],
    х: %w[x h х],
    ч: %w[ch ч],
    ь: %w[ъ ь],
    я: %w[ya я]
  }

  MONTH_DURATION = 60 * 24 * 7 * 4
  DEFAULT_REPLACEMENT = '#'
  HEAVY_ABUVENESS = 10

  def self.w word
    fixed_word = word.to_s.chars.map { |v| l v }.join ' '
    "(?:#{fixed_word})"
  end

  def self.l letter
    synonyms = SYNONYMS[letter.to_sym] || [letter]
    "(?:#{synonyms.join('|')}|#{Z})#{INVISIBLE_SYMBOLS}?#{TAG}"
  end

  ABUSIVE_WORDS = YAML.load_file Rails.root.join('config/app/abusive_words.yml')

  ABUSE = /
    (?<= #{X}|\A|^ )
    (
      #{ABUSIVE_WORDS.map { |word| w word }.join ' | '}
    )
    (?= #{X}|\Z|$ )
  /mix

  ABUSE_SYMBOL = %r{#{Z}|[\[\]/]}
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
    abusiveness(text).positive?
  end

  def censor text, replacement = DEFAULT_REPLACEMENT
    replace_abusiveness text, replacement
  end

private

  def ban comment
    abusiveness = abusiveness comment.body
    duration = ban_duration comment, abusiveness

    comment.update_column(
      :body,
      replace_abusiveness(comment.body, abusiveness >= HEAVY_ABUVENESS ? '#' : nil)
    )

    Ban.create!(
      user: comment.user,
      comment: comment,
      duration: duration,
      reason: ban_reason(comment),
      moderator: User.find(User::BANHAMMER_ID)
    )
  end

  def ban_reason comment
    locale = comment.user.locale_from_host
    i18n_t('ban_reason', url: StickyTopicView.site_rules(locale).object.url)
  end

  def ban_duration comment, abusiveness
    duration = duration_by comment
    multiplier = BanDuration.new(duration).to_i

    BanDuration.new(
      [multiplier * abusiveness, MONTH_DURATION].min
    ).to_s
  end

  def duration_by comment
    if comment.user.bans.size >= 2 &&
        comment.user.bans.last.created_at > 36.hours.ago
      '1d'
    elsif comment.user.bans.any?
      '2h'
    else
      '15m'
    end
  end

  def replace_abusiveness text, replacement
    text.gsub ABUSE do |match|
      next match unless valid_match?(match)

      mached_text = match.size
        .times
        .inject('') { |v, _memo| v + (replacement || '#') }

      replacement ? mached_text : "[color=#ff4136]#{mached_text}[/color]"
    end
  end

  def abusiveness text
    @abusivenesses ||= {}
    @abusivenesses[text] ||=
      text
        .gsub(BbCodes::Tags::UrlTag::REGEXP, '')
        .gsub(BbCodes::Tags::ImgTag::REGEXP, '')
        .gsub(BbCodes::Tags::PosterTag::REGEXP, '')
        .scan(ABUSE)
        .count do |group|
          group
            .select(&:present?)
            .select { |match| valid_match? match }
            .any?
        end
  end

  def valid_match? match
    is_matched = match.size >= 3 && match !~ NOT_ABUSE
    match_wo_tags = match.gsub(TAG_REGEXP, '')

    is_matched &&
      match_wo_tags.scan(ABUSE_SYMBOL).size <= (match_wo_tags.size / 2).floor
  end
end
