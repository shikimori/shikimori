class Neko::IsAllowed
  method_object :entry

  EN_RECAP = [
    'recap',
    'recaps',
    'compilation movie',
    'picture drama',
    'vr',
    'chibi'
  ]
  RU_RECAP = [
    'рекап',
    'обобщение',
    'чиби',
    'краткое содержание',
    'краткий пересказ'
  ]

  EN_RECAP_REGEXP = /\b(?:#{EN_RECAP.join('|')})\b/i
  RU_RECAP_REGEXP = /\b(?:#{RU_RECAP.join('|')})\b/i

  ALL_RECAP_REGEXP = /\b(?:#{(EN_RECAP + RU_RECAP).join('|')})\b/i

  # SHORT_DURATION = 5

  def call
    allowed_in_neko? || !(
      @entry.anons? || @entry.kind_music? ||
      (recap_kind? && recap_name?) # ||
      # extra_short?
    )
  end

private

  def allowed_in_neko?
    neko_rule.rule.dig(:generator, 'not_ignored_ids')&.include? entry.id
  end

  def neko_rule
    NekoRepository.instance.find @entry.franchise, 1
  end

  def recap_kind?
    @entry.kind_special? || @entry.kind_ova? || @entry.kind.movie?
  end

  def recap_name?
    @entry.name.match?(ALL_RECAP_REGEXP) ||
      @entry.english&.match?(EN_RECAP_REGEXP) ||
      @entry.russian&.match?(RU_RECAP_REGEXP) ||
      @entry.description_en&.match?(EN_RECAP_REGEXP) ||
      @entry.description_ru&.match?(RU_RECAP_REGEXP)
  end

  # def extra_short?
  #   @entry.duration <= SHORT_DURATION
  # end
end
