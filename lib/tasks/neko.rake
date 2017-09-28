NEKO_RULES_FILE = "#{Rails.root.join}/../neko-achievements/priv/rules/*"
NEKO_IDS_FILE = "#{Rails.root.join}/lib/types/achievement/neko_id.rb"

namespace :neko do
  desc "generate achievements.yml"
  task update: :environment do
    rules = Dir[NEKO_RULES_FILE].flat_map do |rule_file|
      YAML.load_file(rule_file)
    end

    neko_ids = %w[test] + rules.map { |v| v['neko_id'] }.uniq.sort
    neko_ids_type = open(NEKO_IDS_FILE).read.gsub(
      /(?<=NEKO_IDS\ =\ %i\[).*?(?=\])/mix,
      "\n      " + neko_ids.join("\n      ") + "\n    "
    )

    File.open(NEKO_IDS_FILE, 'w') do |file|
      file.write neko_ids_type
    end

    neko_rules = rules.map do |raw_rule|
      Neko::Rule.new(
        neko_id: raw_rule['neko_id'],
        level: raw_rule['level'],
        image: raw_rule['shikimori']['image'],
        border: raw_rule['shikimori']['border'],
        title_ru: raw_rule['shikimori']['title_ru'],
        text_ru: raw_rule['shikimori']['text_ru'],
      )
    end
    File.open(Neko::Repository::CONFIG_FILE, 'w') do |file|
      file.write neko_rules.map(&:to_hash).to_yaml
    end

    neko_rules.each do |neko_rule|
      puts "#{neko_rule.neko_id} #{neko_rule.level}"
    end
  end
end
