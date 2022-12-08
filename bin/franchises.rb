#!/usr/bin/env ruby
puts 'loading rails...'
ENV['RAILS_ENV'] = ARGV.first || ENV['RAILS_ENV'] || 'development'
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")

franchise_yml = "#{ENV['HOME']}/develop/neko-achievements/priv/rules/_franchises.yml"

puts 'loading franchises...'
raw_data = YAML.load_file(franchise_yml)

# https://shikimori.org/comments/4307156
# https://monosnap.com/file/JewdpGZ9bf63WFU2hnf6C85ah1HdIZ
# https://monosnap.com/file/GpmxHTnn5MonPI5vVdvpudSH1Ct54l
# https://monosnap.com/file/7R0gdzL099NoDCPknAp6GYAmnX9TjA

FRANCHISES_TO_DELETE = %w[]

raw_data = raw_data.reject { |rule| FRANCHISES_TO_DELETE.include? rule['filters']['franchise'] }
data = raw_data.dup.reject { |rule| rule['level'].zero? }

FRANCHISES_TO_ADD = %w[]
  .reject { |franchise| data.find { |rule| rule['filters']['franchise'] == franchise } }

FRANCHISES_TO_ADD.each do |franchise|
  puts "added `#{franchise}` franchise"
  data.push(
    'neko_id' => franchise,
    'level' => 1,
    'algo' => 'duration',
    'filters' => {
      'franchise' => franchise
    },
    'threshold' => '100%',
    'metadata' => {
      'topic_id' => 247360
    }
  )
end

puts 'excluding recaps...'
data.each do |rule|
  recap_ids = Anime
    .where.not(status: :anons)
    .where(franchise: rule['filters']['franchise'])
    .reject { |anime| Neko::IsAllowed.call anime }
    .map(&:id)

  not_anime_ids = (
    ((rule['filters']['not_anime_ids'] || []) + recap_ids).uniq.sort -
      (rule.dig('generator', 'not_ignored_ids') || [])
  ).sort

  missing_ids = not_anime_ids - Anime.where(id: not_anime_ids).pluck(:id)
  missing_ids.each do |missing_id|
    Proxy.off!
    puts "importing anime ID=#{missing_id}"
    Chewy.strategy(:atomic) do
      MalParsers::FetchEntry.new.perform missing_id, 'anime'
    end
  end
  missing_ids = not_anime_ids - Anime.where(id: not_anime_ids).pluck(:id)

  if missing_ids.any?
    raise "Missing Anime ID=#{missing_ids.join ','}"
  end

  # exclude anonses
  # not_anime_ids = Anime
  #   .where.not(status: :anons)
  #   .where(id: not_anime_ids)
  #   .order(:id)
  #   .pluck(:id)

  if not_anime_ids.any?
    rule['filters']['not_anime_ids'] = not_anime_ids
  else
    rule['filters'].delete 'not_anime_ids'
  end
end

  # data = data.select { |v| v['filters']['franchise'] == 'shakugan_no_shana' }

puts 'downloading images...'
data
  .select { |rule| rule['metadata']['image'].present? }
  .reject { |rule| Array(rule['metadata']['image']).first.match? %r{^/assets/achievements/anime/franchise} }
  .each do |rule|
    image_url = CGI.unescape(Array(rule['metadata']['image']).first)
    puts "downloading #{image_url}"

    image_io = OpenURI.open_image(image_url)

    franchise = rule['filters']['franchise']
    extension = image_io.original_filename.split('.').last
    extension = image_url.split('.').last if extension.size > 3

    download_path = "app/assets/images/achievements/anime/franchise/#{franchise}.#{extension}"
    File.open(Rails.root.join(download_path), 'wb') { |f| f.write image_io.read }

    rule['metadata']['image'] = "/assets/achievements/anime/franchise/#{franchise}.#{extension}"
    File.open(franchise_yml, 'w') { |f| f.write data.to_yaml }
  end

puts 'generating thresholds...'
data
  .each do |rule|
    franchise = Anime.where(franchise: rule['filters']['franchise'])
    if rule['filters']['not_anime_ids'].present?
      franchise = franchise.where.not(id: rule['filters']['not_anime_ids'])
    end
    if rule.dig('generator', 'ignore_latest_ids').present? && rule.dig('generator', 'threshold').present?
      puts "both rule[generator][ignore_latest_ids] and rule[generator][threshold] are set in #{rule['filters']['franchise']} franchise"
    end

    franchise = franchise.reject(&:anons?)

    ova = franchise.select do |anime|
      anime.kind_ova? || (anime.kind_ona? && anime.episodes < 4 && anime.duration < 30 )
    end
    long_specials = franchise
      .select(&:kind_special?)
      .select { |v| v.duration >= 22 }
    short_specials = franchise
      .select(&:kind_special?)
      .select { |v| v.duration < 22 && v.duration > 5 }
    mini_specials = (franchise.select(&:kind_special?) + franchise.select(&:kind_ona?))
      .select { |v| v.duration <= 5 }

    important_titles = franchise.reject(&:kind_special?)

    total_duration = franchise.sum { |v| Neko::Duration.call v }

    ova_duration = ova.sum { |v| Neko::Duration.call v }
    long_specials_duration = long_specials.sum { |v| Neko::Duration.call v }
    short_specials_duration = short_specials.sum { |v| Neko::Duration.call v }
    mini_specials_duration = mini_specials.sum { |v| Neko::Duration.call v }

    ova_duration_subtract =
      if ova_duration * 1.0 / total_duration <= 0.1 && franchise.size > 5 && ova.size > 2
        ova_duration / 2
      else
        0
      end

    long_specials_duration_subtract =
      if long_specials_duration * 1.0 / total_duration <= 0.1
        (long_specials.size > 2 ? long_specials_duration / 2.0 : long_specials_duration)
      else
        0
      end

    short_specials_duration_subtract = short_specials.size <= 3 ? short_specials_duration : short_specials_duration / 2.0

    ignored_latest_duration = Anime
      .where(id: rule.dig('generator', 'ignore_latest_ids') || [])
      .where(
        '(released_on_computed is not null and released_on_computed > ?) or (aired_on_computed is not null and aired_on_computed > ?)',
        1.year.ago,
        1.year.ago
      )
      .sum { |v| Neko::Duration.call v }

    threshold_duration = total_duration -
      ova_duration_subtract -
      long_specials_duration_subtract -
      short_specials_duration_subtract -
      mini_specials_duration -
      ignored_latest_duration

    # ap [
    #   rule['filters']['franchise'], {
    #     total_duration: total_duration,
    #     threshold_duration: threshold_duration,
    #     threshold_duration_ova: threshold_duration + ova_duration_subtract,
    #     threshold_duration_ova_long: threshold_duration + ova_duration_subtract + long_specials_duration_subtract,
    #     threshold_duration_ova_long_short: threshold_duration + ova_duration_subtract + long_specials_duration_subtract + short_specials_duration_subtract,
    #     threshold_duration_ova_long_short_mini: threshold_duration + ova_duration_subtract + long_specials_duration_subtract + short_specials_duration_subtract + mini_specials_duration
    #   }
    # ] if threshold_duration < 700
    threshold_duration = 700 if threshold_duration < 700 && total_duration > 700

    formula_threshold = threshold_duration * 100.0 / total_duration

    if total_duration > 30_000
      formula_threshold = [60, formula_threshold].min
    elsif total_duration > 20_000
      formula_threshold = [70, formula_threshold].min
    elsif total_duration > 10_000
      formula_threshold = [80, formula_threshold].min
    elsif total_duration > 5_000
      formula_threshold = [90, formula_threshold].min
    end

    if franchise.size >= 7 || total_duration > 2_000
      formula_threshold = [95, formula_threshold].min
    end

    # animes_with_year = franchise.reject(&:kind_special?).select(&:year)
    # average_year = animes_with_year.sum(&:year) * 1.0 / animes_with_year.size
    # if average_year < 1987
    #   formula_threshold -= 15
    # elsif average_year < 1991
    #   formula_threshold -= 10
    # elsif average_year < 1996
    #   formula_threshold -= 5
    # end

    important_durations = important_titles
      .map { |v| Neko::Duration.call v }
      .sort
      .reverse

    important_duration = important_durations[0..[(important_titles.size * 0.4).round, 3].max].sum -
      ignored_latest_duration
    important_threshold = important_duration * 100.0 / total_duration

    threshold = [important_threshold, formula_threshold].max

    current_threshold = rule['threshold'].to_s.gsub('%', '').to_f
    new_threshold = threshold.floor(1)

    if rule.dig('generator', 'threshold').present?
      new_threshold = rule['generator']['threshold'].to_s.gsub('%', '').to_f
    end

    if current_threshold != new_threshold
      ap(
        franchise: rule['filters']['franchise'],
        threshold: "#{current_threshold} -> #{new_threshold}"
      )
      rule['threshold'] = "#{new_threshold}%".gsub(/\.0%$/, '%')
    end
  end

puts 'generating 0 levels...'
franchises_index = data
  .map { |rule| rule['filters']['franchise'] }

data = data + (data
  .select { |rule| rule['filters']['franchise'].present? }
  .map do |rule|
    rule.dup.merge('level' => 0, 'threshold' => 0.01)
  end
)

data = data.sort_by do |rule|
  [franchises_index.index(rule['filters']['franchise']), -rule['level']]
end

if data.any? && data.size >= raw_data.size
  File.open(franchise_yml, 'w') { |f| f.write data.to_yaml }
  puts "\n" + data.map { |v| v['filters']['franchise'] }.uniq.join(' ')
else
  raise 'invalid data'
end

popularity = {}

begin
  puts "\nsorting by popularity...\n"
  data = data
    .sort_by do |rule|
      franchise = rule['filters']['franchise']
      popularity[franchise] ||= Rails.cache.fetch [:franchise, :popularity, franchise] do
        puts "calculating for #{franchise}"
        neko_rule = Neko::Rule.new(
          Neko::Rule::NO_RULE.attributes.merge(
            rule: rule.except('neko_id', 'level', 'metadata').symbolize_keys
          )
        )

        UserRate
          .where(target_type: Anime.name)
          .where(target_id: neko_rule.animes_scope.pluck(:id))
          .where(status: %i[completed watching rewatching])
          .where.not(user_id: User.cheat_bot)
          .select('count(distinct(user_id))')
          .to_a
          .first
          .count
      end

      [-popularity[franchise], -rule['level']]
    end

  if data.any? && data.size >= raw_data.size
    File.open(franchise_yml, 'w') { |f| f.write data.to_yaml }
    puts data.map { |v| v['filters']['franchise'] }.uniq.join(' ')
  else
    raise 'invalid data'
  end
rescue Interrupt
end
