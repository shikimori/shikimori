class TorrentsController < ShikimoriController
  def create
    @klass = Anime
    anime = Anime.find CopyrightedIds.instance.restore(params[:id], 'anime')

    authorize! :upload_episode, anime

    parser = TokyoToshokanParser

    if params[:torrent]['url']
      parser = case params[:torrent]['url']
        when /nyaa/
          NyaaParser

        when /jishaku/
          JishakuToshokanParser

        when /tokyotosho/
          TokyoToshokanParser

        else
          return redirect_back fallback_location: anime.decorate.edit_url, alert: 'Неизвестный трекер'
      end
      added = parser.grab_page Addressable::URI.unencode(params[:torrent]['url']), anime.id

    else
      unless params[:torrent]['link'] =~ URI::regexp
        return redirect_back fallback_location: anime.decorate.edit_url, alert: 'Link должен быть корректным URI'
      end
      begin
        params[:torrent]['pubDate'] = DateTime.parse(params[:torrent]['pubDate'])
      rescue
        return redirect_back fallback_location: anime.decorate.edit_url, alert: 'PubDate должен быть корректной датой'
      end

      params[:torrent]['guid'] = params[:torrent]['link'].sub('page=download', 'page=torrentinfo')
      added = TokyoToshokanParser.add_episodes(anime, [ params[:torrent] ])
    end

    if added > 0
      flash[:notice] = added == 1 ? "Новый торрент успешно добавлен" : "Новые торренты успешно добавлены"
      redirect_to anime.decorate.edit_url
    else
      return redirect_back fallback_location: anime.decorate.edit_url, alert: params[:torrent]['url'] ? 'Не найдено ни одного нового эпизода' : 'Не удалось добавить новый торрент, проверьте корректность Title'
    end
  end
end
