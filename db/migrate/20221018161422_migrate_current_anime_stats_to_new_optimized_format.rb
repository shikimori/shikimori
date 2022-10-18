class MigrateCurrentAnimeStatsToNewOptimizedFormat < ActiveRecord::Migration[6.1]
  FIELDS = %i[scores_stats list_stats]

  def up
    count = AnimeStat.count
    i = 0

    AnimeStat.find_each do |anime_stat|
      FIELDS.each do |field|
        if anime_stat.send(field)[0].is_a? Hash
          anime_stat.send(:"#{field}=", anime_stat.send(field).map { |v| [v['key'], v['value']] })
        end
      end

      anime_stat.save! if anime_stat.changed?

      i += 1
      puts "#{i} / #{count}"
    end
  end

  def down
    count = AnimeStat.count
    i = 0

    AnimeStat.find_each do |anime_stat|
      FIELDS.each do |field|
        if anime_stat.send(field)[0].is_a? Hash
          anime_stat.send(:"#{field}=", anime_stat.send(field).map { |v| { 'key' => v[0], 'value' => v[1] } })
        end
      end

      anime_stat.save! if anime_stat.changed?

      i += 1
      puts "#{i} / #{count}"
    end
  end
end
