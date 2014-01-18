class SubtitlesImporter
  include Sidekiq::Worker
  sidekiq_options unique: true,
                  unique_args: -> (args) { args },
                  retry: 1

  def perform options
    case options[:mode].to_sym
      when :ongoings then import_ongoings
      when :latest then import_latest
      else import_regular
    end
  end

  def import_ongoings
    print "getting subtitles for ongoings...\n"
    animes = Anime.ongoing
    get_fansubs animes
  end

  def import_latest
    print "getting parallel subtitles for latests...\n"
    animes = Anime.where(AniMangaStatus.query_for('latest')).all
    get_fansubs animes
  end

  def import_regular
    print "getting subtitles for animes..\n"
    animes = Anime.order(:id).all.select {|v| !v.anons? && v.subtitles.empty? && !v.ongoing? }
    get_fansubs animes
  end

private
  def get_fansubs animes
    count = animes.count
    i = 0

    animes.each do |anime|
      cache = FansubsParser.new.import(anime)
      i += 1
      print "%d\t%d\t%d\t%s\n" % [cache.size, count-i, anime.id, anime.name] if cache
      print "failed for %d\t%d\t%s\n" % [count-i, anime.id, anime.name] unless cache
      sleep(3)
    end
  end
end
