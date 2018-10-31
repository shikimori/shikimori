#!/usr/bin/env ruby
puts 'loading rails...'
ENV['RAILS_ENV'] = ARGV.first || ENV['RAILS_ENV'] || 'development'
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")

franchise_yml = "#{ENV['HOME']}/develop/neko-achievements/priv/rules/_franchises.yml"

puts 'loading franchises...'
raw_data = YAML.load_file(franchise_yml)

data = raw_data.dup

puts 'excluding recaps...'
data.each do |rule|
  recap_ids = Anime
    .where(franchise: rule['filters']['franchise'])
    .select(&:kind_special?)
    .select do |anime|
      next if rule.dig('generator', 'not_ignored_ids')&.include? anime.id
      next unless anime.kind_special? || anime.kind_ova?

      anime.name.match?(/\brecaps?\b|compilation movie|picture drama|\bvr\b|\bрекап\b/i) ||
        anime.description_en&.match?(/\brecaps?\b|compilation movie|picture drama/i) ||
        anime.description_ru&.match?(/\bрекап\b|\bобобщение\b|\bчиби\b|краткое содержание/i)
    end
    .map(&:id)

  if recap_ids.any?
    rule['filters']['not_anime_ids'] = (
      (rule['filters']['not_anime_ids'] || []) + recap_ids
    ).uniq.sort - (rule.dig('generator', 'not_ignored_ids') || [])
  end
end

def duration anime
  episodes =
    if anime.anons?
      0
    elsif anime.released?
      anime.episodes
    else
      anime.episodes_aired.zero? ? anime.episodes : anime.episodes_aired
    end

  episodes * anime.duration
end

# data = data.select { |v| v['filters']['franchise'] == 'shakugan_no_shana' }

puts 'generating thresholds...'
data.each do |rule|
  franchise = Anime.where(franchise: rule['filters']['franchise'])
  if rule['filters']['not_anime_ids'].present?
    franchise = franchise.where.not(id: rule['filters']['not_anime_ids'])
  end
  franchise = franchise.reject(&:anons?)

  ova = franchise.select(&:kind_ova?)
  long_specials = franchise
    .select(&:kind_special?)
    .select { |v| v.duration >= 22 }
  short_specials = franchise
    .select(&:kind_special?)
    .select { |v| v.duration < 22 && v.duration > 5 }
  mini_specials = (franchise.select(&:kind_special?) + franchise.select(&:kind_ona?))
    .select { |v| v.duration <= 5 }

  important_titles = franchise.reject(&:kind_special?)

  total_duration = franchise.sum { |v| duration v }
  ova_duration = ova.sum { |v| duration v }
  long_specials_duration = long_specials.sum { |v| duration v }
  short_specials_duration = short_specials.sum { |v| duration v }
  mini_specials_duration = mini_specials.sum { |v| duration v }

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

  formula_threshold = (
    total_duration -
    ova_duration_subtract -
    long_specials_duration_subtract -
    short_specials_duration_subtract -
    mini_specials_duration
  ) * 100.0 / total_duration

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
    .map { |v| duration v }
    .sort
    .reverse

  important_duration = important_durations[0..[(important_titles.size * 0.4).round, 3].max].sum
  important_threshold = important_duration * 100.0 / total_duration

  threshold = [important_threshold, formula_threshold].max

  current_threshold = rule['threshold'].gsub('%', '').to_f
  new_threshold = threshold.floor(1)

  if current_threshold != new_threshold
    ap(
      franchise: rule['filters']['franchise'],
      threshold: "#{current_threshold} -> #{new_threshold}"
    )
    rule['threshold'] = "#{new_threshold}%".gsub(/\.0%$/, '%')
  end
end

if data.any? && data.size == raw_data.size
  File.open(franchise_yml, 'w') { |f| f.write data.to_yaml }
  puts "\n" + data.map { |v| v['filters']['franchise'] }.join(' ')
end

begin
  puts "\nsorting by popularity...\n"
  data = data
    .sort_by do |v|
        Anime
        .where(franchise: v['filters']['franchise'], status: 'released')
        .sum { |v| v.rates.where(status: %i[completed rewatching]).size }
    end
    .reverse

  if data.any? && data.size == raw_data.size
    File.open(franchise_yml, 'w') { |f| f.write data.to_yaml }
    puts data.map { |v| v['filters']['franchise'] }.join(' ')
  end
rescue Interrupt
end
