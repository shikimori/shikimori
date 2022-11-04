```ruby
ActiveRecord::Base.logger = nil;
Dalli.logger = nil;
puts "автор;url;кол-во аниме;суммарная длительность аниме;threshold;threshold * длительность;человек с ачивкой;популярность"

NekoRepository.instance.
  select { |rule| rule.author? && rule.level == 1 }.
  map do |rule|
    animes = rule.animes_scope
    total_duration = animes.sum {|anime| Neko::Duration.call anime }
    threshold_percent = rule.threshold_percent(animes.count)

    [
      rule.title_en,
      "https://shikimori.one/achievements/author/#{rule.neko_id}",
      animes.count,
      total_duration,
      rule.rule[:threshold],
      (threshold_percent / 100.0 * total_duration).ceil,
      Achievements::UsersQuery.fetch(User.find(1)).filter(neko_id: rule.neko_id, level: rule.level).size,
      ::Types::Achievement::ORDERED_NEKO_IDS.index(rule.neko_id)
    ]
  end.
  sort_by(&:last).
  map.with_index { |v, index| v[v.size - 1] = index + 1; v }.
  each { |v| puts v.join(';') };
```
