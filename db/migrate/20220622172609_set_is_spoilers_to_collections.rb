class SetIsSpoilersToCollections < ActiveRecord::Migration[6.1]
  KEYWORDS = %w[
    alert
    местами
    возможн[ыо]
    внимание
    ужасающие
    могут
    быть
    осторожно
    наверное
    нужные
    очень
    есть
    присутствуют
  ].join('|')
  SPOILER = '(?:[сc]п[оo]йле[рp](?:ы|ов|ами|)|spoiler)'
  SUFFIX = '[!, ?|\/.-]'
  KEYWORDS_WITH_SUFFIX = "(?:#{SUFFIX}|#{KEYWORDS})*"

  SPOILERS_REGEXP = %r{
    (?:
      \s?
      [\(\[!*「l]
      [\s+]?
      (?:
        (?: #{KEYWORDS_WITH_SUFFIX} | #{SPOILER} ) #{SUFFIX}*
      )+
      [\)\]!*」l] #{SUFFIX}*
      \s?
        |
      \A
      (?:
        #{KEYWORDS_WITH_SUFFIX} #{SPOILER} #{SUFFIX}*
      )+
      \s?
        |
      (?<= [.,] )
      #{KEYWORDS_WITH_SUFFIX}* #{SPOILER} #{SUFFIX}*
      \Z
    )
  }mix
  SKIP_REPLACEMENTS = ['Спойлеры поцелуев']

  def up
    Collection.where("name ILIKE '%спойлер%'").each do |collection|
        fixed_name = collection.name.in?(SKIP_REPLACEMENTS) ?
          collection.name :
          collection.name.gsub(SPOILERS_REGEXP, '')
      collection.update is_spoilers: true, name: fixed_name
    end
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
