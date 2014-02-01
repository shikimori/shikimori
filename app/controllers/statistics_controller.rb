class StatisticsController < ApplicationController
  respond_to :html
  YearsAgo = 26.years

  def index
    @page_title = 'История аниме'
    @page_description = 'Никогда не задумывались, сколько всего существует аниме, каких оно жанров и типов, и как оно менялось по прошествии лет? На данной странице представлены несколько графиков со статистикой по истории аниме за последние четверть века.'
    set_meta_tags description: @page_description
    set_meta_tags keywords: 'история аниме, статистка аниме сериалов, индустрия аниме, рейтинги аниме, студии аниме, жанры аниме'


    @kinds = ['TV', 'Movie', 'OVA', 'ONA', 'Special']
    @rating_kinds = ['TV', 'Movie', 'OVA']

    @total, @by_kind, @by_rating, @by_genre, @by_studio = Rails.cache.fetch('statistics_data_' % DateTime.now.strftime('%Y-%m')) do
      prepare
      [total_stats, stats_by_kind, stats_by_rating, stats_by_genre, stats_by_studio]
    end

    @topic = TopicPresenter.new(object: Topic.find(81906), template: view_context, limit: 1000, with_user: true)
  end

private
  # общая статистика
  def total_stats
    grouped = @animes.group_by(&:kind).sort

    by_kind = {
      name: 'Тип',
      data: grouped.map do |kind,group|
        {
          name: kind,
          y: group.size
        }
      end
    }
    by_score = {
      name: 'Оценка',
      data: grouped.map do |kind,group|
        group.group_by do |v|
          if v.score >= 8
            '8+'
          elsif v.score >= 7
            '7'
          else
            '6-'
          end
        end.sort.map do |score,group|
          {
            name: score,
            y: group.size
          }
        end
      end.flatten
    }

    {
      categories: [],
      series: [by_kind, by_score]
    }
  end

  # статистика по рейтингу
  def stats_by_rating
    ratings = ['G', 'PG', 'PG-13', 'R+', 'NC-17', 'Rx']
    @rating_kinds.each_with_object({}) do |kind,rez|
      rez[kind] = stats_data(@animes.select { |v| v.kind == kind && v[:ru_rating].present? }, :ru_rating, ratings)
    end
  end

  # статистика по жанрам
  def stats_by_genre
    top_genres = @rating_kinds.each_with_object({}) do |kind,rez|
      rez[kind] = normalize(stats_data(@animes.select { |v| v.kind == kind }.map { |v| v[:mapped_genres] }.flatten, :genre, @genres), 4)[:series].map { |v| v[:name] }
    end

    data = @rating_kinds.each_with_object({}) do |kind,rez|
      rez[kind] = stats_data(@animes.select { |v| v.kind == kind }.map { |v| v[:mapped_genres] }.flatten, :genre, @genres)
    end

    # отключаем второстепенные жанры
    data.each do |kind,stats|
      stats[:series].each do |stat|
        stat[:visible] = (top_genres[kind].include?(stat[:name]) && stat[:name] != 'Детское') || (kind == 'TV' && stat[:name] == 'Гарем')
      end
    end

    data
  end

  # статистика по студиям
  def stats_by_studio
    animes_10 = @tv.select { |v| v.aired_on >= DateTime.parse("#{DateTime.now.year}-01-01") - 10.years }
    #top_studios = normalize(stats_data(animes_10.map { |v| v[:mapped_studios] }.flatten, :studio, @studios), 0.75)[:series].map { |v| v[:name] }

    data = stats_data(animes_10.map { |v| v[:mapped_studios] }.flatten, :studio, @studios + ['Прочее'])
    other = {
      name: 'Прочее',
      data: [0,0,0,0,0,0,0,0,0,0,0],
      visible: false
    }
    data[:series].select! do |stat|
      if stat[:data].sum > 10
        true
      else
        stat[:data].each_with_index do |v,k|
          other[:data][k] += v
        end
        false
      end
    end
    data[:series].insert -1, other

    data
  end

  # статистика по типам
  def stats_by_kind
    stats_data(@animes, :kind, @kinds)
  end

  # подготовка общих данных
  def prepare
    @genres = Genre.order(:position).all.map(&:russian)
    @studios_by_id = Studio.all.each_with_object({}) do |v,rez|
      rez[v.id] = v
    end
    @studios = @studios_by_id.select { |v| v.real? }.map { |k,v| v.filtered_name }

    start_on = DateTime.parse("#{DateTime.now.year}-01-01") - YearsAgo
    finish_on = DateTime.parse("#{DateTime.now.year}-01-01") - 1.day + 1.year
    @animes = Anime.where { aired_on.not_eq(nil) }
        .where { aired_on.gte(start_on) }
        .where { aired_on.lte(finish_on) }
        .where(:kind => @kinds)
        .select([:id, :aired_on, :kind, :rating, :score])
        .order(:aired_on)
        .includes(:genres)
        .includes(:studios)

    @animes.each do |entry|
      entry[:ru_rating] = I18n.t "RatingShort.#{entry.rating}" if entry.rating != 'None'

      entry[:mapped_genres] = entry.genres.map do |genre|
        {
          genre: genre.russian,
          aired_on: entry.aired_on
        }
      end
      entry[:mapped_studios] = entry.real_studios.map do |studio|
        {
          studio: Studio::Merged.include?(studio.id) ? @studios_by_id[Studio::Merged[studio.id]].filtered_name : studio.filtered_name,
          aired_on: entry.aired_on
        }
      end
    end
    @tv = @animes.select { |v| v.kind == 'TV' }
  end

  # выборка статистики
  def stats_data(animes, grouping, categories)
    years = animes.group_by { |v| Russian.strftime(v[:aired_on], '%Y') }.keys

    groups = categories.each_with_object({}) do |group,rez|
      rez[group] = nil
    end

    data = animes.group_by {|v| v[grouping] }
                 .each_with_object(groups) do |entry,data|
      next unless data.include? entry[0]
      data[entry[0]] = years.each_with_object({}) { |v,rez| rez[v] = 0 }

      entry[1].group_by { |v| Russian.strftime(v[:aired_on], '%Y') }.each do |k,v|
        data[entry[0]][k] = v.size
      end
    end.select { |k,v| v.present? }

    {
      categories: years,
      series: data.map do |k,v|
        {
          name: k,
          data: v.values
        }
      end
    }
  end

  # приведение статистики к нормальному виду
  def normalize(data, minimum)
    new_series = data[:series].map do |entry|
      {
        name: entry[:name],
        data: entry[:data].each_with_index.map do |number,i|
          number * 100.0 / data[:series].sum { |entry| entry[:data][i] }
        end
      }
    end

    data[:series] = new_series.select do |stat|
      stat[:data].any? { |v| v >= minimum }
    end

    data
  end
end
