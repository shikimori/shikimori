require_dependency 'genre'
require_dependency 'studio'
require_dependency 'publisher'

class UserListsController < UsersController
  include AniMangaListImporter
  AnimeType = 1
  MangaType = 2

  alias_method :users_show, :show

  # отображение аниме листа пользователяс с наложенными фильтрами
  def show
    unless params[:order]
      redirect_to ani_manga_filtered_list_url(params.merge(order: user_signed_in? ? current_user.preferences.default_sort : UserPreferences::DefaultSort))
      return
    end
    params[:with_censored] = true
    current_user.preferences.update_sorting(params[:order]) if user_signed_in?

    @params_type = params[:type]
    @page = (params[:page] || 1).to_i
    @limit = 400

    @field_name = anime? ? 'episodes' : 'chapters'

    @klass = params[:list_type].capitalize.constantize

    # полный список
    full_list = Rails.cache.fetch(user_list_cache_key) { extract_full_list }
    @list = prepare_list(full_list, @page, @limit)
    @add_postloader = @list.any? && (@list.keys.last != full_list.keys.last ||
        @list[@list.keys.last][:entries].size != full_list[full_list.keys.last].size)

    unless @add_postloader
      @total_stats = full_list.map {|k,v| list_stats(v, false) }.inject({}) do |rez,data|
        data.each do |k,v|
          rez[k] ||= 0
          rez[k] += v
        end
        rez
      end
      @total_stats[:days] = @total_stats[:days].round(2) if @total_stats[:days]
      @total_stats.delete_if {|k,v| !(v > 0) }
    end

    @page_title = UsersController.profile_title("Список #{params[:list_type] == 'anime' ? 'аниме' : 'манги'}", @user)
    params[:type] = "#{params[:list_type]}list"

    respond_to do |format|
      format.json do
        # первую страницу рисуем как обычно
        if @page == 1
          render json: {
            content: render_to_string(partial: 'ani_manga_list', layout: false, formats: :html),
            title_page: @page_title
          }
        # а все остальные лишь таблицей со списком
        else
          render json: {
            content: render_to_string(partial: 'user_lists/ani_manga_list_content', layout: false, formats: :html)
          }
        end
      end
      format.html { users_show }
    end
  end

  # история изменения списка аниме/манги
  def history
    limit = 90
    @page = (params[:page] || 1).to_i

    history = @user
      .all_history
      .order { updated_at.desc }
      .offset(limit * (@page-1))
      .limit(limit + 1)
      .all

    @add_postloader = history.size > limit
    history = history.take(limit) if history.size > limit
    history.map! &:decorate

    @history = history.group_by do |v|
      today = DateTime.parse(Date.today.to_s)
      updated_at = v.updated_at.to_datetime
      if today < updated_at then 'Сегодня'
      elsif today - 1.day < updated_at then 'Вчера'
      elsif today - 1.week < updated_at then 'В течение недели'
      elsif today - 2.weeks < updated_at then 'Две недели назад'
      elsif today - 3.weeks < updated_at then 'Три недели назад'
      elsif today - 4.weeks < updated_at then 'Четыре недели назад'
      elsif today - 2.months < updated_at then 'Месяц назад'
      elsif today - 3.months < updated_at then 'Два месяца назад'
      elsif today - 4.months < updated_at then 'Три месяца назад'
      elsif today - 5.months < updated_at then 'Четыре месяца назад'
      elsif today - 6.months < updated_at then 'Пять месяцев назад'
      elsif today - 9.months < updated_at then 'Более полугода назад'
      elsif today - 1.year < updated_at then 'Почти год назад'
      elsif today - 2.year < updated_at then 'Более года назад'
      else 'Совсем давно'
      end
    end

    @page_title = UsersController.profile_title('История', @user)
    users_show
  end

  # экспорт аниме листа
  def export
    raise Forbidden unless user_signed_in? && @user.can_be_edited_by?(current_user)
    @type = params[:list_type]
    @list = @user.send("#{@type}_rates")

    response.headers['Content-Description'] = 'File Transfer';
    response.headers['Content-Disposition'] = "attachment; filename=#{@type}list.xml";
  end

  # импорт списка
  def list_import
    raise Unauthorized unless user_signed_in?
    #if Rails.cache.read('import-lock') && Rails.env.production?
      #redirect_to user_url(current_user)
      #flash[:notice] = "В данный момент система нагружена импортами. Пожалуйста, повторите попытку через несколько минут."
      #return
    #end
    #Rails.cache.write('import-lock', current_user.id, :expires_in => 1.minute)

    klass = Object.const_get(params[:klass].capitalize)
    rewrite = params[:rewrite] == true || params[:rewrite] == '1'

    # в ситуации, когда через yql не получилось, можно попробовать вручную скачать список
    if params[:mal_login].present?
      params[:file] = open "http://myanimelist.net/malappinfo.php?u=#{params[:mal_login]}&status=all&type=#{params[:klass]}"
      params[:list_type] = 'xml'
    end

    if params[:list_type].to_sym == :mal
      prepared_list = JSON.parse(params[:data]).map do |v|
        {
          id: v['id'].to_i,
          episodes: v.include?('episodes') ? v['episodes'].to_i : 0,
          volumes: v.include?('volumes') ? v['volumes'].to_i : 0,
          chapters: v.include?('chapters') ? v['chapters'].to_i : 0,
          status: v['status'],
          score: v['score'] || 0
        }
      end.compact

      added, updated, not_imported = import(current_user, klass, prepared_list, rewrite)

    elsif params[:list_type].to_sym == :anime_planet
      raise Forbidden if params[:login].empty?
      parser = AnimePlanetParser.new(params[:login], klass)
      parser.get_pages_num
      list = parser.get_list

      added, updated, not_imported = parser.import_list(current_user, list, rewrite, params[:wont_watch_strategy] == UserRateStatus::Dropped ? UserRateStatus::Dropped : nil)

    elsif params[:list_type].to_sym == :xml
      raw_xml = if params[:file].kind_of? ActionDispatch::Http::UploadedFile
        if params[:file].original_filename =~ /\.gz$/
          Zlib::GzipReader.open(params[:file].tempfile).read
        else
          params[:file].read
        end
      else
        Rails.env.test? ? params[:file] : params[:file].read
      end

      prepared_list = Hash.from_xml(raw_xml.fix_encoding)['myanimelist'][params[:klass]]
      prepared_list = [prepared_list] if prepared_list.kind_of?(Hash)
      prepared_list.map! do |v|
        {
          id: (v['series_animedb_id'] || v['series_mangadb_id'] || v['manga_mangadb_id'] || v['anime_animedb_id']).to_i,
          episodes: v['my_watched_episodes'] || 0,
          volumes: v['my_read_volumes'] || 0,
          chapters: v['my_read_chapters'] || 0,
          status: v['my_status'] =~ /^\d+$/ ? UserRateStatus.get(v['my_status'].to_i) : v['my_status'].sub('Plan to Read', 'Plan to Watch').sub('Reading', 'Watching'),
          score: v['my_score'] || 0
        }
      end
      added, updated, not_imported = import(current_user, klass, prepared_list, rewrite)
      params[:list_type] = 'mal'

    else
      raise Forbidden
    end

    if added.size > 0 || updated.size > 0
      current_user.touch
      UserHistory.create({
          user_id: current_user.id,
          action: UserHistoryAction.const_get("#{params[:list_type].to_sym == :mal ? 'Mal' : 'Ap'}#{klass.name}Import"),
          value: added.size + updated.size
        })
    end

    message = []

    if added.size > 0
      items = klass.where(:id => added).select([:id, :name])
      if klass == Manga
        message << "В ваш список #{Russian.p(added.size, 'импортирована', 'импортированы', 'импортированы')} #{added.size} #{Russian.p(added.size, 'манга', 'манги', 'манги')}:"
      else
        message << "В ваш список #{Russian.p(added.size, 'импортировано', 'импортированы', 'импортированы')} #{added.size} #{Russian.p(added.size, 'аниме', 'аниме', 'аниме')}:"
      end
      message = message + items.sort_by {|v| v.name }.map {|v| "<a class=\"bubbled\" data-remote=\"true\" href=\"#{url_for(v)}\">#{v.name}</a>" }
      message << ''
    end

    if updated.size > 0
      items = klass.where(:id => updated).select([:id, :name])
      if klass == Manga
        message << "В вашем списке #{Russian.p(updated.size, 'обновлена', 'обновлены', 'обновлены')} #{updated.size} #{Russian.p(updated.size, 'манга', 'манги', 'манги')}:"
      else
        message << "В вашем списке #{Russian.p(updated.size, 'обновлено', 'обновлены', 'обновлены')} #{updated.size} #{Russian.p(updated.size, 'аниме', 'аниме', 'аниме')}:"
      end
      message = message + items.sort_by {|v| v.name }.map {|v| "<a class=\"bubbled\" data-remote=\"true\" href=\"#{url_for(v)}\">#{v.name}</a>" }
      message << ''
    end

    if not_imported.size > 0
      message << "Не удалось импортировать (распознать) #{not_imported.size} #{klass == Manga ? Russian.p(not_imported.size, 'мангу', 'манги', 'манг') : 'аниме'}, пожалуйста, добавьте их в свой список самостоятельно:"
      message = message + not_imported.sort
    end
    message << "Ничего нового не импортировано." if message.empty?

    poster = BotsService.get_poster
    messages = message.each_slice(400).to_a.reverse
    messages.each_with_index do |message,index|
      message = ['(продолжение предыдущего сообщения)<br>'] + message if index != messages.size - 1
      Message.create!(
        from_id: poster.id,
        to_id: current_user.id,
        kind: MessageType::Private,
        body: message.join('<br>')
      )
      sleep(1)
    end

    current_user.touch # указываем, что пользователь обновлён

    redirect_to messages_url(type: :inbox)
  rescue Exception => e
    flash[:alert] = 'Произошла ошибка. Возможно, некорректный формат файла.'
    redirect_to :back
  end

private
  # полный список пользователя
  def extract_full_list
    params[:order] = 'russian' if user_signed_in? && current_user.preferences.russian_names? && params[:order] == 'name'
    pars = params.clone.merge(:klass => @klass)
    pars.delete(:order)

    rate_ds = @user.send("#{params[:list_type]}_rates")
    rate_ds = rate_ds.where(:status => UserRateStatus.get(params[:list_type_kind])) if params[:list_type_kind]
    rate_ids = rate_ds.select('distinct(target_id)').map(&:target_id)

    entries = AniMangaQuery.new(@klass, pars, @user)
        .fetch
        .where(id: rate_ids)
        .select("#{params[:list_type].tableize}.id,
                 #{params[:list_type].tableize}.kind,
                 #{params[:list_type].tableize}.name,
                 #{params[:list_type].tableize}.russian,
                 #{params[:list_type].tableize}.status,
                 #{params[:list_type].tableize}.aired_at,
                 #{params[:list_type].tableize}.released_at,
                 #{@klass == Anime ? "#{params[:list_type].tableize}.episodes_aired" : '0'} as episodes_aired,
                 #{params[:list_type].tableize}.#{@klass == Anime ? 'episodes' : 'chapters'}
                 #{@klass == Anime ? ",#{params[:list_type].tableize}.duration" : ''}")
        .all
        .each_with_object({}) { |entry, memo| memo[entry.id] = entry }

    rates = @user.send("#{params[:list_type]}_rates")
        .where(target_id: entries.keys)
        .joins(params[:list_type].to_sym)
        .order("user_rates.status, #{AniMangaQuery.order_sql(params[:order], @klass)}")
        .all

    list = rates.inject({}) do |result, v|
      target = entries[v.target_id]

      result[v.status] = [] unless result.include?(v.status)
      result[v.status] << {
        id: target.id,
        name: view_context.localized_name(target),
        kind: target.kind,
        kind_localized: target.kind.blank? ? '' : view_context.localized_kind(target, true),
        status_localized: target.status.present? ? I18n.t("AniMangaStatusUpper.#{target.status}") : '',
        url: "/#{params[:list_type]}s/#{v.target_id}",
        rate_url: "/#{params[:list_type]}s/#{v.target_id}/rate",
        episodes_value: v[@field_name],
        episodes_aired: target.episodes_aired,
        ongoing?: target.ongoing?,
        anons?: target.anons?,
        score: v.score && v.score != 0 ? v.score : '&ndash;',
        episodes: anime? ? (target.episodes == 0 ? '?' : target.episodes) :
                            (target.chapters == 0 ? '?' : target.chapters),
        duration: anime? ? target.duration : Manga::Duration
      }

      result
    end
  end

  # подготовка списка
  def prepare_list(full_list, page, limit)
    list = truncate_list(full_list, @page, @limit)

    list.each do |status,data|
      list[status][:stats] = list_stats(full_list[status]) if list[status][:stats]
      list[status][:size] = full_list[status].size
    end

    list
  end

  # формирование содержимого нужной страницы из списка
  def truncate_list(full_list, page, limit)
    list = {}
    from = limit * (page - 1)
    to = from + limit

    # счётчик общего числа элементах
    i = 0
    # счётчик числа элементов в пределах группы
    j = 0

    full_list.each do |status,entries|
      j = 0

      entries.each do |entry|
        j += 1
        i += 1

        next if i <= from
        if i > to
          list[status].delete(:stats) if list[status]
          break
        end

        list[status] ||=  { entries: [], stats: {} }
        list[status][:entries] << entry.merge(:index => j)
      end
    end
    list
  end

  # аггрегированная статистика по данным
  def list_stats(data, reduce=true)
    stats = {
      tv: data.sum {|v| v[:kind] == 'TV' ? 1 : 0 },
      movie: data.sum {|v| v[:kind] == 'Movie' ? 1 : 0 },
      ova: data.sum {|v| v[:kind] == 'OVA' || v[:kind] == 'ONA' ? 1 : 0 },
      #ona: data.sum {|v| v[:kind] == 'ONA' ? 1 : 0 },
      special: data.sum {|v| v[:kind] == 'Special' ? 1 : 0 },
      music: data.sum {|v| v[:kind] == 'Music' ? 1 : 0 },
      manga: data.sum {|v| ['Manga', 'Manhwa', 'Manhua'].include?(v[:kind]) ? 1 : 0 },
      #manhwa: data.sum {|v| v[:kind] == 'Manhwa' ? 1 : 0 },
      #manhua: data.sum {|v| v[:kind] == 'Manhua' ? 1 : 0 },
      oneshot: data.sum {|v| v[:kind] == 'One Shot' ? 1 : 0 },
      novel: data.sum {|v| v[:kind] == 'Novel' ? 1 : 0 },
      doujin: data.sum {|v| v[:kind] == 'Doujin' ? 1 : 0 }
    }
    stats[anime? ? :episodes : :chapters] = data.sum {|v| v[:episodes_value] }
    stats[:days] = (data.sum {|v| v[:episodes_value] * v[:duration] }.to_f / 60 / 24).round(2)

    reduce ? stats.select { |k,v| v > 0 }.to_hash : stats
  end

  # формирование статистики по списку
  def prepare_list_stats(full_list, list)
    stats = full_list.map do |k,v|
    end
  end

  # ключ от кеша для списка пользователя
  def user_list_cache_key
    "#{@user.cache_key}_#{Digest::MD5.hexdigest(request.url.gsub(/\.json$/, '').gsub(/\/page\/\d+/, ''))}_#{user_signed_in? ? current_user.preferences.russian_names? : false}"
  end

  def anime?
    params[:list_type] == 'anime'
  end
end
