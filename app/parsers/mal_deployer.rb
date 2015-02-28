# TODO: refactor
module MalDeployer
  # применение импортированных данных к элементу и сохранение элемента в базу
  def deploy entry, data
    deploy_genres entry, data[:entry][:genres] if data[:entry].include? :genres
    deploy_studios entry, data[:entry][:studios] if data[:entry].include? :studios
    deploy_publishers entry, data[:entry][:publishers] if data[:entry].include? :publishers

    deploy_related entry, data[:entry][:related] if data[:entry].include? :related
    deploy_recommendations entry, data[:recommendations] if data.include? :recommendations
    deploy_characters entry, data[:characters] if data.include? :characters
    deploy_people entry, data[:people] if data.include? :people

    deploy_seyu entry, data[:entry][:seyu] if data[:entry].include? :seyu

    # изменения самого элемента
    data[:entry]
      .except(:related, :genres, :authors, :publishers, :members, :seyu, :favorites, :img, :studios)
      .each do |field,value|
        entry[field] = value
      end

    entry.mal_scores = data[:scores] if data.include? :scores

    entry.image = reload_image entry, data if reload_image? entry, data

    # дата импорта и сохранение элемента, делать надо обязательно в последнюю очередь
    entry.imported_at = Time.zone.now
    entry.save!
  end

  # загрузка привязанных жанров
  def deploy_genres entry, entry_genres
    return if entry_genres.empty?
    # добавление новых жанров
    (entry_genres.map {|v| v[:id] } - self.genres.keys).map do |genre_id|
      entry_genres.select {|v| v[:id] == genre_id }.first
    end.each do |genre|
      self.genres[genre[:id]] = Genre.find_or_create_by(id: genre[:id], name: genre[:name])
      print "added genre #{genre[:name]}\n" unless Rails.env.test?
    end
    # и привязка всех жанров элемента к элементу
    entry.genres = entry_genres.map {|v| self.genres[v[:id]] }
  end

  # загрузка привязанных студий
  def deploy_studios entry, entry_studios
    return if entry_studios.empty?
    # добавление новых студий
    (entry_studios.map {|v| v[:id] } - self.studios.keys).map do |studio_id|
      entry_studios.select {|v| v[:id] == studio_id }.first
    end.each do |studio|
      self.studios[studio[:id]] = Studio.find_or_create_by(id: studio[:id], name: studio[:name])
      print "added studio #{studio[:name]}\n" unless Rails.env.test?
    end
    # и привязка всех студий элемента к элементу
    entry.studios = entry_studios.map {|v| self.studios[v[:id]] }
  end

  # загрузка привязанных издателей
  def deploy_publishers entry, entry_publishers
    return if entry_publishers.empty?
    # добавление новых студий
    (entry_publishers.map {|v| v[:id] } - self.publishers.keys).map do |publisher_id|
      entry_publishers.select {|v| v[:id] == publisher_id }.first
    end.each do |publisher|
      self.publishers[publisher[:id]] = Publisher.find_or_create_by(id: publisher[:id], name: publisher[:name])
      print "added publisher #{publisher[:name]}\n" unless Rails.env.test?
    end
    # и привязка всех студий издателей к элементу
    entry.publishers = entry_publishers.map {|v| self.publishers[v[:id]] }
  end

  # загрузка привязки похожих элементов
  def deploy_recommendations entry, recommendations
    return if recommendations.empty?
    klass = Object.const_get("Similar#{type.camelize}")
    klass.where(src_id: entry.id).delete_all

    time = DateTime.now.strftime('%Y-%m-%d %H:%M:%S')
    queries = recommendations.reverse.map do |rec|
      "(#{entry.id}, #{rec["#{type}_id".to_sym]}, '#{time}', '#{time}')"
    end
    ActiveRecord::Base.connection.
      execute("insert into #{klass.table_name} (src_id, dst_id, created_at, updated_at)
                  values #{queries.join(',')}") unless queries.empty?
  end

  # загрузка связанных элементов
  def deploy_related entry, related
    # похожие элементы
    klass = Object.const_get("Related#{type.camelize}")
    klass.where(source_id: entry.id).delete_all

    time = DateTime.now.strftime('%Y-%m-%d %H:%M:%S')

    queries = related.map do |relation,related_ids|
      related_ids.map do |related_id|
        "(#{entry.id},
          #{(entry.class == Anime && relation != 'Adaptation') || (entry.class == Manga && relation == 'Adaptation') ? related_id.to_i : 'null'},
          #{(entry.class == Anime && relation == 'Adaptation') || (entry.class == Manga && relation != 'Adaptation') ? related_id.to_i : 'null'},
          '#{relation}',
          '#{time}',
          '#{time}')"
      end
    end.flatten

    ActiveRecord::Base.connection.
      execute("insert into #{klass.table_name} (source_id, anime_id, manga_id, relation, created_at, updated_at)
                  values #{queries.join(',')}") unless queries.empty?
  end

  # загрузка привязок к персонажам
  def deploy_characters entry, characters
    # сперва удаляем все старые записи, затем создаём новые привязки
    PersonRole.where("#{type}_id = ? and character_id is not null", entry.id).delete_all
    time = DateTime.now.strftime('%Y-%m-%d %H:%M:%S')
    queries = characters.map do |k,v|
      "('#{v[:role]}', #{entry.id}, #{v[:id]}, '#{time}', '#{time}')"
    end

    ActiveRecord::Base.connection.
      execute("insert into person_roles (role, #{type}_id, character_id, created_at, updated_at)
                  values #{queries.join(',')}") unless queries.empty?
  end

  # загрузка привязок к людям
  def deploy_people entry, people
    # сперва удаляем все старые записи, затем создаём новые привязки
    PersonRole.where("#{type}_id = ? and person_id is not null", entry.id).delete_all
    time = DateTime.now.strftime('%Y-%m-%d %H:%M:%S')
    queries = people.map do |k,v|
      "('#{v[:role]}', #{entry.id}, #{v[:id]}, '#{time}', '#{time}')"
    end

    ActiveRecord::Base.connection.
      execute("insert into person_roles (role, #{type}_id, person_id, created_at, updated_at)
                  values #{queries.join(',')}") unless queries.empty?
  end

  # загрузка картинки с mal
  def mal_image url, is_new_image
    if is_new_image && url !~ /\.jpe?g$/
      open_image url, 'User-Agent' => 'Mozilla/4.0 (compatible; ICS)'
    else
      Proxy.get url, timeout: 30, validate_jpg: true, return_file: true, no_proxy: @no_proxy, log: @proxy_log
    end

  rescue RuntimeError => e
    raise if e.message !~ /HTTP redirection loop/
    Proxy.get url, timeout: 30, validate_jpg: true, return_file: true, no_proxy: @no_proxy, log: @proxy_log
  end

  # загрузка картинки
  def reload_image entry, data
    io = if File.exists? "/var/www/#{type}_fixed/original/#{entry.id}.jpg"
      open_image "/var/www/#{type}_fixed/original/#{entry.id}.jpg"
    else
      mal_image data[:entry][:img], !entry.image.exists?
    end

    io && io.original_filename.blank? ? nil : io if data[:entry].include?(:img)

  rescue OpenURI::HTTPError => e
    raise e unless e.message == "404 Not Found"
    nil
  end

  # надо ли загружать картинку?
  def reload_image? entry, data
    return false if Rails.env.test? || data[:entry][:img].include?("na_series.gif") || data[:entry][:img].include?("na.gif")
    return true unless entry.image.exists?

    interval = if (entry.respond_to?(:ongoing?) && entry.ongoing?) || (entry.kind_of?(Character) && entry.animes.ongoing.any?)
      2.weeks
    elsif entry.respond_to?(:latest?) && entry.latest?
      3.months
    else
      6.months
    end

    File.mtime(entry.image.path).to_datetime < DateTime.now - interval
  end
end
