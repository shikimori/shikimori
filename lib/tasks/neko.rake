GITHUB_URL = 'https://github.com/shikimori/neko-achievements/tree/master/'
NEKO_RULES_FILE = "#{Rails.root}/../neko-achievements/priv/rules/*"
NEKO_IDS_FILE = "#{Rails.root}/app/models/types/achievement.rb"

namespace :neko do
  desc "generate achievements.yml"
  task update: :environment do
    rules = Dir[NEKO_RULES_FILE].flat_map do |rule_file|
      YAML.load_file(rule_file).map do |rule|
        rule.merge 'source' =>
          GITHUB_URL + rule_file.sub(%r{^.*\.\./neko-achievements/}, '')
      end
    rescue
      puts rule_file
      raise
    end

    neko_ids = %w[test] + rules.map { |v| v['neko_id'] }.uniq
    shiki_ids = open(NEKO_IDS_FILE).read
      .match(
        /(?<=NEKO_IDS\ =\ {).*?(?=})/mix
      )[0]
      .strip
      .split("\n")
      .map(&:strip)
      .select(&:present?)
      .select { |v| v =~ /^[A-Za-z_ 0-9]+$/ }
      .flat_map(&:split)

    if (neko_ids & shiki_ids).size != neko_ids.size
      raise '[unmatched neko_ids] missing ids: ' +
        (neko_ids - shiki_ids).join(',') + ' unknown ids: ' + 
        (shiki_ids - neko_ids).join(',')
    end
    # neko_ids_type = open(NEKO_IDS_FILE).read.gsub(
      # /(?<=NEKO_IDS\ =\ %i\[).*?(?=\])/mix,
      # "\n      " + neko_ids.join("\n      ") + "\n    "
    # )

    # File.open(NEKO_IDS_FILE, 'w') do |file|
      # file.write neko_ids_type
    # end

    neko_rules = rules.map do |raw_rule|
      Neko::Rule.new(
        neko_id: raw_rule['neko_id'],
        level: raw_rule['level'],
        image: raw_rule['metadata']['image'].is_a?(Array) ?
          raw_rule['metadata']['image'].join(',') :
          raw_rule['metadata']['image'],
        border_color: raw_rule['metadata']['border_color'].is_a?(Array) ?
          raw_rule['metadata']['border_color'].join(',') :
          raw_rule['metadata']['border_color'],
        title_ru: raw_rule['metadata']['title_ru'],
        text_ru: raw_rule['metadata']['text_ru'],
        title_en: raw_rule['metadata']['title_en'],
        text_en: raw_rule['metadata']['text_en'],
        topic_id: raw_rule['metadata']['topic_id'],
        rule: raw_rule.except('neko_id', 'level', 'metadata').symbolize_keys
      )
    end
    File.open(NekoRepository::CONFIG_FILE, 'w') do |file|
      file.write(neko_rules.to_yaml)
    end

    neko_rules.each do |neko_rule|
      puts "#{neko_rule.neko_id} #{neko_rule.level}"
    end
  end
end
