#!/usr/bin/env ruby
puts 'loading rails...'
ENV['RAILS_ENV'] = ARGV.first || ENV['RAILS_ENV'] || 'development'
require File.expand_path(File.dirname(__FILE__) + "/../config/environment")

authors_yml = "#{ENV['HOME']}/develop/neko-achievements/priv/rules/_authors.yml"

puts 'loading authors...'
raw_data = YAML.load_file(authors_yml)

data = raw_data.dup.reject { |rule| rule['level'].zero? }

# puts 'generating anime_ids...'
# data
#   .each do |rule|
#     rule['filters'] ||= {}
#     rule['filters']['anime_ids'] = PersonRole
#       .where.not(anime_id: nil)
#       .where(person_id: rule['generator']['person_id'])
#       .includes(:anime)
#       .map(&:anime)
#       .select { |anime| Neko::IsAllowed.call anime }
#       .map(&:id)
#       .sort
#       .uniq
#     end

# data.each do |rule|
#   t = rule['threshold']
#   g = rule['generator']
#   f = rule['filters']
#   m = rule['metadata']

#   rule.delete 'threshold'
#   rule.delete 'generator'
#   rule.delete 'filters'
#   rule.delete 'metadata'

#   rule['threshold'] = t || '100%'
#   rule['filters'] = f
#   rule['metadata'] = m
#   rule['generator'] = g
# end

# puts 'excluding recaps...'
# data.each do |rule|
#   recap_ids = Anime
#     .where(id: rule['filters']['anime_ids'])
#     .reject { |anime| Neko::IsAllowed.call anime }
#     .map(&:id)

#   not_anime_ids = ((rule['filters']['not_anime_ids'] || []) + recap_ids).uniq.sort -
#     (rule.dig('generator', 'not_ignored_ids') || [])

#   not_anime_ids =  Anime
#     .where.not(status: :anons)
#     .where(id: not_anime_ids)
#     .order(:id)
#     .pluck(:id)

#   if not_anime_ids.any?
#     rule['filters']['not_anime_ids'] = not_anime_ids
#   else
#     rule['filters'].delete 'not_anime_ids'
#   end
# end

puts 'downloading images...'
data
  .select { |rule| rule['metadata']['image'].present? }
  .reject { |rule| Array(rule['metadata']['image']).first.match? %r{^/assets/achievements/anime/author} }
  .each do |rule|
    image_url = CGI.unescape(Array(rule['metadata']['image']).first)
    puts "downloading #{image_url}"

    image_io = open_image(image_url)
    neko_id = rule['neko_id']

    extension = image_io.original_filename.split('.').last
    extension = image_url.split('.').last if extension.size > 3

    download_path = "app/assets/images/achievements/anime/author/#{neko_id}.#{extension}"
    File.open(Rails.root.join(download_path), 'wb') { |f| f.write image_io.read }

    rule['metadata']['image'] = "/assets/achievements/anime/author/#{neko_id}.#{extension}"
    File.open(authors_yml, 'w') { |f| f.write data.to_yaml }
  end

# puts 'generating thresholds...'
# data
#   .each do |rule|
#     franchise = Anime.where(franchise: rule['filters']['franchise'])
#     if rule['filters']['not_anime_ids'].present?
#       franchise = franchise.where.not(id: rule['filters']['not_anime_ids'])
#     end
#     franchise = franchise.reject(&:anons?)

#     ova = franchise.select(&:kind_ova?)
#     long_specials = franchise
#       .select(&:kind_special?)
#       .select { |v| v.duration >= 22 }
#     short_specials = franchise
#       .select(&:kind_special?)
#       .select { |v| v.duration < 22 && v.duration > 5 }
#     mini_specials = (franchise.select(&:kind_special?) + franchise.select(&:kind_ona?))
#       .select { |v| v.duration <= 5 }

#     important_titles = franchise.reject(&:kind_special?)

#     total_duration = franchise.sum { |v| Neko::Duration.call v }
#     ova_duration = ova.sum { |v| Neko::Duration.call v }
#     long_specials_duration = long_specials.sum { |v| Neko::Duration.call v }
#     short_specials_duration = short_specials.sum { |v| Neko::Duration.call v }
#     mini_specials_duration = mini_specials.sum { |v| Neko::Duration.call v }

#     ova_duration_subtract =
#       if ova_duration * 1.0 / total_duration <= 0.1 && franchise.size > 5 && ova.size > 2
#         ova_duration / 2
#       else
#         0
#       end

#     long_specials_duration_subtract =
#       if long_specials_duration * 1.0 / total_duration <= 0.1
#         (long_specials.size > 2 ? long_specials_duration / 2.0 : long_specials_duration)
#       else
#         0
#       end

#     short_specials_duration_subtract = short_specials.size <= 3 ? short_specials_duration : short_specials_duration / 2.0

#     ignored_latest_duration = Anime
#       .where(id: rule.dig('generator', 'ignore_latest_ids') || [])
#       .where(
#         'released_on is not null and released_on > ? or aired_on > ?',
#         1.year.ago,
#         1.year.ago
#       )
#       .sum { |v| Neko::Duration.call v }

#     formula_threshold = (
#       total_duration -
#       ova_duration_subtract -
#       long_specials_duration_subtract -
#       short_specials_duration_subtract -
#       mini_specials_duration -
#       ignored_latest_duration
#     ) * 100.0 / total_duration

#     if total_duration > 30_000
#       formula_threshold = [60, formula_threshold].min
#     elsif total_duration > 20_000
#       formula_threshold = [70, formula_threshold].min
#     elsif total_duration > 10_000
#       formula_threshold = [80, formula_threshold].min
#     elsif total_duration > 5_000
#       formula_threshold = [90, formula_threshold].min
#     end

#     if franchise.size >= 7 || total_duration > 2_000
#       formula_threshold = [95, formula_threshold].min
#     end

#     # animes_with_year = franchise.reject(&:kind_special?).select(&:year)
#     # average_year = animes_with_year.sum(&:year) * 1.0 / animes_with_year.size
#     # if average_year < 1987
#     #   formula_threshold -= 15
#     # elsif average_year < 1991
#     #   formula_threshold -= 10
#     # elsif average_year < 1996
#     #   formula_threshold -= 5
#     # end

#     important_durations = important_titles
#       .map { |v| Neko::Duration.call v }
#       .sort
#       .reverse

#     important_duration = important_durations[0..[(important_titles.size * 0.4).round, 3].max].sum -
#       ignored_latest_duration
#     important_threshold = important_duration * 100.0 / total_duration

#     threshold = [important_threshold, formula_threshold].max

#     current_threshold = rule['threshold'].to_s.gsub('%', '').to_f
#     new_threshold = threshold.floor(1)

#     if rule.dig('generator', 'threshold').present?
#       new_threshold = rule['generator']['threshold'].to_s.gsub('%', '').to_f
#     end

#     if current_threshold != new_threshold
#       ap(
#         franchise: rule['filters']['franchise'],
#         threshold: "#{current_threshold} -> #{new_threshold}"
#       )
#       rule['threshold'] = "#{new_threshold}%".gsub(/\.0%$/, '%')
#     end
#   end

# puts 'generating 0 levels...'
# authors_index = data
#   .map { |rule| rule['neko_id'] }
#
# data = data + data.map { |rule| rule.dup.merge('level' => 0, 'threshold' => 0.01) }
#
# data = data.sort_by do |rule|
#   [authors_index.index(rule['neko_id']), -rule['level']]
# end

if data.any? && data.size >= raw_data.size
  File.open(authors_yml, 'w') { |f| f.write data.to_yaml }
  puts "\n" + data.map { |v| v['neko_id'] }.uniq.join(' ')
else
  raise 'invalid data'
end

popularity = {}

begin
  puts "\nsorting by popularity...\n"
  data = data
    .sort_by do |rule|
      neko_id = rule['neko_id']
      popularity[neko_id] ||= Rails.cache.fetch [:franchise, :popularity, neko_id] do
        puts "calculating for #{neko_id}"
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

      [-popularity[neko_id], -rule['level']]
    end

  if data.any? && data.size >= raw_data.size
    File.open(authors_yml, 'w') { |f| f.write data.to_yaml }
    puts "\n" + data.map { |v| v['neko_id'] }.uniq.join(' ')
  else
    raise 'invalid data'
  end
rescue Interrupt
end
