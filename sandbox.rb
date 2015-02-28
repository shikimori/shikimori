#!/usr/bin/env ruby
ENV['RAILS_ENV'] = ARGV.first || ENV['RAILS_ENV'] || 'development'
require File.expand_path(File.dirname(__FILE__) + "/config/environment")

require 'zlib'

class Faraday::Gzip < Faraday::Response::Middleware
  def call env
    @app.call(env).on_complete do |res|
      encoding = env[:response_headers]['content-encoding'].to_s.downcase
      case encoding
      when 'gzip'
        env[:body] = Zlib::GzipReader.new(StringIO.new(env[:body]), encoding: 'ASCII-8BIT').read
        env[:response_headers].delete('content-encoding')
      when 'deflate'
        env[:body] = Zlib::Inflate.inflate(env[:body])
        env[:response_headers].delete('content-encoding')
      end
    end
  end
end

class Faraday::PersistedCookies < Faraday::Middleware
  def initialize app, options={}
    super app
    @cookies = options[:cookies]# || HTTP::CookieJar.new
  end

  def call env
    env[:cookies] ||= @cookies
    cookies = @cookies.cookies env[:url]

    env[:request_headers]["Cookie"] = HTTP::Cookie.cookie_value(cookies) unless cookies.empty?

    @app.call(env).on_complete do |res|
      if res[:response_headers] && res[:response_headers]["Set-Cookie"]
        @cookies.parse res[:response_headers]["Set-Cookie"], env[:url]
      end
    end
  end
end

class Faraday::IncapsulaUnsuccessful < Faraday::Middleware
  def call env
    perform_with_iframe_check env
  end

  def perform_with_iframe_check env
    response = @app.call env

    response.on_complete do |res|
      if with_iframe?(res)
        binding.pry
        iframe_response = fetch_iframe iframe_url(env, res), env[:cookies]
        binding.pry

        #env[:original_url] = env[:url]
        #env[:url] += iframe_url(env, res)
        #@app.call(env)

        #ap '-----------'
        #ap env[:cookies]
        #ap env[:body]

        #env[:url] += env[:original_url]
        #response = @app.call env

        #ap '-----------'
        #ap env[:cookies]
        #ap env[:body]
      end
    end

    response
  end

  def with_iframe? res
    res[:body] =~ /Request unsuccessful. Incapsula incident ID/
  end

  def iframe_url env, res
    "http://#{env[:url].hostname}#{res[:body][/(?<= src=") .*? (?= ")/x]}"
  end

  def fetch_iframe url, cookies
    conn = Faraday.new do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger
      faraday.response :gzip
      faraday.adapter Faraday.default_adapter

      faraday.use :persisted_cookies, cookies: cookies
    end

    conn.headers['Accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
    conn.headers['Accept-Encoding'] = 'gzip,deflate,sdch'
    conn.headers['Accept-Language'] = 'en-US,en;q=0.8'
    conn.headers['Connection'] = 'keep-alive'
    conn.headers['DNT'] = '1'
    conn.headers['User-Agent'] = 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'

    conn.get url
  end
end

Faraday.register_middleware persisted_cookies: lambda { Faraday::PersistedCookies }
Faraday.register_middleware incapsula_unsuccessful: lambda { Faraday::IncapsulaUnsuccessful }
Faraday::Response.register_middleware gzip: lambda { Faraday::Gzip }


class Far
  def do
    conn = Faraday.new do |faraday|
      faraday.request  :url_encoded
      faraday.response :logger
      faraday.response :gzip
      faraday.adapter Faraday.default_adapter

      faraday.use :incapsula_unsuccessful
      faraday.use :persisted_cookies, cookies: HTTP::CookieJar.new
    end

    conn.headers['Accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8'
    conn.headers['Accept-Encoding'] = 'gzip,deflate,sdch'
    conn.headers['Accept-Language'] = 'en-US,en;q=0.8'
    conn.headers['Connection'] = 'keep-alive'
    conn.headers['DNT'] = '1'
    conn.headers['User-Agent'] = 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)'

    response = conn.get 'http://myanimelist.net/'
  end
end

#class Faraday::PersistedCookies < Faraday::Middleware
  #def initialize app
    #super
    #@cookies = HTTP::CookieJar.new
  #end

  #def call env
    #cookies = @cookies.cookies env[:url]

    #env[:request_headers]["Cookie"] = HTTP::Cookie.cookie_value(cookies) unless cookies.empty?

    #@app.call(env).on_complete do |res|
      #if res[:response_headers] && res[:response_headers]["Set-Cookie"]
        #@cookies.parse res[:response_headers]["Set-Cookie"], env[:url]
      #end
    #end
  #end
#end

#class Faraday::IncapsulaUnsuccessful do
  ##Request unsuccessful. Incapsula incident ID

  #def call env
    #response = @app.call(env)

    #binding.pry
    #response.on_complete do |res|
    #end
  #end
#end

#Faraday.register_middleware persisted_cookies: lambda { Faraday::PersistedCookies }
#Faraday.register_middleware incapsula_unsuccessful: lambda { Faraday::IncapsulaUnsuccessful }


#conn = Faraday.new do |faraday|
  #faraday.request  :url_encoded
  #faraday.response :logger
  #faraday.adapter Faraday.default_adapter
  ##faraday.use Faraday::PersistedCookies
  #faraday.use :persisted_cookies
  #faraday.use :incapsula_unsuccessful
#end;

#conn.headers['Accept'] = 'text/html,application/xhtml+xml,application/xml;q=0.9,image/webp,*/*;q=0.8';
#conn.headers['Accept-Encoding'] = 'gzip,deflate,sdch';
#conn.headers['Accept-Language'] = 'en-US,en;q=0.8';
#conn.headers['Connection'] = 'keep-alive';
#conn.headers['DNT'] = '1';
##conn.headers['User-Agent'] = 'Mozilla/5.0 (Macintosh; Intel Mac OS X 10_9_0) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/30.0.1599.101 Safari/537.36';
#conn.headers['User-Agent'] = 'Mozilla/5.0 (compatible; Googlebot/2.1; +http://www.google.com/bot.html)';

#response = conn.get 'http://myanimelist.net/'
#response.body

#Nokogiri::HTML(response.body).css('script').text.strip

#cxt = V8::Context.new
#cxt.eval('7 * 6')


exit
Review.where(user_id: 2357).update_all state: :accepted, approver_id: 1
exit
Message.wo_antispam do
  User.where(id: UserToken.where(provider: ['google_apps', 'yandex']).map(&:user_id)).each do |user|
    message = Message.create(
      from_id: 1,
      to_id: user.id,
      kind: MessageType::Private,
      body: "Привет!
Где-то во второй половине Июля на сайте произойдёт обновление, которое навсегда поломает авторизацию через Google и Yandex. Авторизация через эти сервисы будет отключена ([spoiler=возможно]позже может быть вернётся назад немного в другом виде, но войти в прежние аккаунты через неё не выйдет[/spoiler]).
Немного уточню, речь идёт не о регистрации на почту гугла или яндекса, а о регистрация через одну из этих двух кнопочек 
[url=http://img855.imageshack.us/img855/4896/88820130613005456.png][img]http://img855.imageshack.us/img855/4896/88820130613005456.th.png[/img][/url]

Пишу вам это сообщение, т.к. вы зарегистрированы на сайте как раз через Google(Yandex).
Пожалуйста, убедитесь, что сможете в дальнейшем залогиниться на сайт без этого способа.
Для этого в настройках профиля должен быть задан емайл и пароль, либо же подключён к аккаунту ещё один способ авторизации через вконтакт или фейсбук.
[url=http://img43.imageshack.us/img43/9965/88820130613005332.png][img]http://img43.imageshack.us/img43/9965/88820130613005332.th.png[/img][/url]

Прошу прощения за доставленные неудобства :bow:"
    )
    Sendgrid.delay.private_message_email(message)
  end
end

exit
#require 'rake_tasks'
#AniDbParser.new.fetch_animes
#ap FansubsParser.process('One Piece')
#exit
#ThreadPool.defaults = {log: true}
#ProxyTools.get_proxy_list(false)
#CharacterMalParser.import
#exit
#require 'faye'

#bayeux = Faye::RackAdapter.new({
  #:mount => '/faye',
  #:timeout => 25,
  #:engine  => {
    #:type  => Faye::Redis,
    #:host  => 'localhost',
    #:port  => 6379
  #}
#})
#bayeux.listen(9292)
exit
AnimedbRuScreenshotsJob.new.perform
exit
ProxyGetJob.new.perform
exit
FansubsParser.new.import(Anime.find(934))
exit
ProxyParser.instance.fetch
exit
ProxyTools.get_proxy_list false
exit
ReadMangaImporter.import id: 1268
exit
ap Comment.first
exit
AdultMangaImporter.import id: 'the_center_of_the_hair_whorl'
exit
ProxyTools.use_cache = true
parser = AnimedbRuParser.new
parser.cache[:max_id] = parser.fetch_max_id
parser.fetch_animes(false, 1)
exit
ProxyTools.use_cache = true
ReadMangaImporter.new(ReadMangaParser.new).import
#ReadmangaParser.new.fetch_entry('hibiutsuroi')
exit
parser = WorldArtParser.new
#parser.cache[:max_id] = parser.fetch_max_id
parser.fetch_animes(false, 100)
#parser.merge_with_database
exit
#ap WikipediaParser.new.extract_characters(Anime.new(:name => 'zxcgsdfhdsf', :russian => 'Прочти или умри'))
#exit
#ToshokanJob.new.perform
#exit
require Rails.root.join('lib', 'rake_tasks')
SubtitlesTasks.new.ongoing
exit
p = RecommendationsService.new
p.get_recommendations(p.prepare_stats(1..30), 1)
exit
CharsDescriptionJob.new.perform(anime_ids: [7059,11285], manga_ids: [])
exit
ProxyTools.use_cache = true

exit
#AnimeHistoryService.process
#AniDbParser.new.fetch_animes

tags = Set.new(DanbooruTag.where(:kind => DanbooruTag::Character, :ambiguous => false).all.map {|v| v.name })
Character.where(:tags => nil).find_each(:batch_size => 5000) do |v|
  tag = DanbooruTag.match(([v.name] + [v.name.split(' ').reverse.join(' ')]).uniq, tags)
  v.update_attribute(:tags, tag) if tag
end


exit
#AnimeMalParser.new.import
#MangaMalParser.new.import
#CharacterMalParser.new.import
#PersonMalParser.new.import

#1.upto(3).parallel do |thread|
  ##Thread.new(thread) do |thread|
    #i = 0
    #begin
      #print "#{thread} #{i}\n"
      #i += 1
    #end while true
  ##end
#end

#begin
  #sleep(1)
#end while true


#bot = DcBot.new
#bot.start

#LatestAnimeImages.new.perform

#data = CosplayImage.all
#data.each do |v|
  #v.image.reprocess!
#end


#SangakuComplexParser.new.fetch_posts

#MalTasks.new.import(1024)

#robot = Jabber::Client::new(Jabber::JID::new("shikimoriorg@gmail.com"))
#robot.connect
#robot.auth("szqrvufuwvdnigti")
#robot.send(Jabber::Presence.new.set_show(nil))

#coding: utf-8
#require "xmpp4r"

#AnimeHistoryService.process
#TokyoToshokanParser.grab_ongoings

#def saver

#end

#(1..999999).parallel(:threads => 10, :log => true, :saver => lambda { ap "SAVER" }, :saver_interval => 5) do |v|
  #sleep rand(10)
  #0/0
  #raise 'test'
  #print "%s\n" % v
  #print "worker tick %s\n" % v
#end


#WorldArtParser.new.merge_with_database
#AniDbParser.new.merge_animes_with_database

#parser = MalParser.new
#ap parser.fetch_person(158)
#parser.init_saver
#parser.fetch_animes_list
#parser.fetch_animes(true)
#parser.fetch_characters(true)
#parser.fetch_people(true)
#parser.apply_fixes

#ap Anime.find(10766).matches_for("[한샛-Raws] Detective Conan - 618 (NTV 1280x720 x264 AAC).mp4")
#ap Anime.find(9712).matches_for("[Leopard-Raws] Maria Holic - 11 (DVD 704x480 H264 AAC).mp4")
#ap Anime.find(10163).matches_for("[ReinForce] Astarotte no Omocha! - 01 (TVS 1280x720 x264 AAC).mkv")
#
#ap MALParser.fetch_character(8041)
#c = MALParser.load_cache
#anime = c[:animes][8795]
#ap MALParser.fetch_anime_characters(anime)
#exit

#parser = CosRainParser.new
#parser.fetch_links
#parser.fetch_entries
#parser.merge_with_database
#parser.clean_database

#parser = TriDolkiParser.new
#parser.fetch_links
#parser.fetch_entries
#parser.merge_with_database
#parser.clean_database



#anime_id = 9756
#animes = [anime_id]

#MALParser.init
#MALParser.load_cache
#MALParser.fetch_animes(true, animes)
#MALParser.fetch_characters(:all, animes)
#MALParser.fetch_people(true, animes)
#MALParser.apply_fixes
#MALParser.save_cache

#anime_id = 10165
#animes = [anime_id]
#MALParser.init
#cache = MALParser.load_cache and 1
#ap cache[:animes][anime_id]
#cache[:animes][anime_id][:imported] = DateTime.now - 2.weeks
#MALParser.fetch_animes(true, animes)

#anime = Anime.find_or_create_by_id_and_name(:id => 8986, :name => 'Supernatural: The Animation')
#TokyoToshokanParser.grab_ongoings
#TokyoToshokanParser.grab_ongoings(true, 9756)
#TokyoToshokanParser.add_episodes(Anime.find(8986), [
    #{
           #:link => "http://www.nyaa.eu/?page=download&tid=197057",
        #:pubDate => DateTime.parse('2011-02-28 23:00 UTC'),# + (87*0).hours,
           #:guid => "http://www.nyaa.eu/?page=torrentinfo&tid=197057",
          #:title => "[LightNeverFades]_Supernatural_The_Animation_01-04_[ENG_DUB]_[HQ_DVDRIP_480p]"
    #}
#])

#cache = MALParser.load_cache
#ap Character.where('id not in(?)', cache[:characters].keys).count
#ap Person.where('id not in(?)', cache[:people].keys).count
#cache = MALParser.load_cache
#ap Character.where('id not in(?)', cache[:characters].keys).count
#ap Person.where('id not in(?)', cache[:people].keys).count

#ap AniDbParser.new.fetch_studio 10871

#parser = AniDbParser.new
#parser.fetch_studios_list
#parser.save_cache
#WorldArtParser.new.merge_with_database
#ap AniDbParser.new.fetch_score({:id => 7591})
#AniDbParser.new.fetch_animes
#AniDbParser.new.merge_animes_with_database
#AniDbParser.new.merge_studios_with_database
#AniDbParser.new.fetch_studios

#Rails.env = "test"
#WorldArtParser.new.fetch_score({:id => 7740})
#WorldArtParser.new.fetch_animes
#WorldArtParser.new.merge_with_database

#cache = MALParser.load_cache
#cache[:people][6519] = MALParser.fetch_person(6519)
#ap MALParser.fetch_person(1870)
#MALParser.save_cache
#ap MALParser.fetch_anime_data(9289)

#c = MALParser.load_cache
#c[:people].each do |k,v|
  #v[:imported] = DateTime.now - 10.days
#end
#MALParser.save_cache

#WorldArtParser.new.merge_with_database
#AniDbParser.new.fetch_score({:id => 6816})

#require 'pp'
#require 'mal_parser'
#require 'btjunkie_parser'
#require 'tokyo_toshokan_parser'


##animes = Anime.order(:id).all.select {|v| !v.anons? && v.subtitles.empty? }
#animes = Anime.order(:id).all.select {|v| v.ongoing? && !v.anons? }
#mutex = Mutex.new
#count = animes.count
#i = 0
##Parallel.for(animes, :pool_size => 10) do |anime|
#[Anime.find(235)].each do |anime|
  #cache = anime.fill_subtitles_cache(mutex)
  #mutex.synchronize {
    #i += 1
    #print "%d\t%d\t%d\t%s\n" % [cache.size, count-i, anime.id, anime.name] if cache
    #print "failed for %d\t%d\t%s\n" % [count-i, anime.id, anime.name] unless cache
  #}
  #sleep(1)
#end
#exit

#animes = Anime.all
#count = animes.count
#i = 0
#animes.each do |anime|
  #torrents = anime.torrents
  #BlobData.set("anime_%d_torrents" % anime.id, torrents) if torrents.size > 0
  #torrents_720p = anime.torrents_720p
  #BlobData.set("anime_%d_torrents_720p" % anime.id, torrents) if torrents.size > 0
  #torrents_1080p = anime.torrents_1080p
  #BlobData.set("anime_%d_torrents_1080p" % anime.id, torrents) if torrents.size > 0
  #subtitles = anime.subtitles
  #BlobData.set("anime_%d_subtitles" % anime.id, subtitles) if subtitles.size > 0
  #Rails.cache.delete("anime_%d_torrents" % anime.id)
  #Rails.cache.delete("anime_%d_torrents_720p" % anime.id)
  #Rails.cache.delete("anime_%d_torrents_1080p" % anime.id)
  #Rails.cache.delete("anime_%d_subtitles" % anime.id)
  #i += 1
  #print "%d left\n" % [count-i]
#end

#ProxyTools.get_page("http://cdn.myanimelist.net/images/anime/12/21451l.jpg", :timeout => 30, :ban_texts => [/^(<html>|<hr>|<b>|<h2>)/i], :log => true)

#c = MALParser.do
#exit

#MALParser.apply_fixes
#ap({:animes => {8769 => {:name => 'Ore no Imouto ga Kawaii Wake ga Nai'}}}.to_yaml)

#AnimeHistory.create_for_new_anons(Anime.find(10015))

    #AnimeHistory.where("action != 'new_episode'").
                 #includes(:anime).
                 #limit(3).
                 #order('id desc').
                 #all.
                   #each do |entry|
      #case entry.action
        #when AnimeHistoryAction::Release
          #AnimeHistory.create_for_new_released(entry.anime)
          #ap entry

        #when AnimeHistoryAction::Anons
          #AnimeHistory.create_for_new_anons(entry.anime)
          #ap entry

        #when AnimeHistoryAction::Ongoing
          #AnimeHistory.create_for_new_ongoing(entry.anime)
          #ap entry
      #end
    #end


#ap Anime.where(AnimeSeason.query_for('ongoing')).size
#ap Anime.order(:id).all.select {|v| v.ongoing?(true) }.size
#ap Anime.order(:id).all.select {|v| v.ongoing?(true) } - Anime.where(AnimeSeason.query_for('ongoing'))
#AnimeHistoryService.process
#TokyoToshokanParser.grab_ongoings
#TokyoToshokanParser.grab_ongoings(false, 8937)
#MALParser.do
#exit
#ap Anime.find(8311).
#matches_for("GOSICK - 01 (1280x720).avi +DDL")
#fill_torrents_cache#.map {|v| v[:title] }
#exit

#mutex = Mutex.new
#animes = Anime.order(:id).all.select {|v| !v.anons? && v.torrents.empty? }
##animes = Anime.order(:id).all.select {|v| v.ongoing? && !v.anons? }
#count = animes.count
#i = 0
##Parallel.for(animes, :pool_size => 120) do |anime|
##[animes.first].each do |anime|
#[Anime.find(8425)].each do |anime|
##[Anime.find(7724)].each do |anime|
##[Anime.find(7456)].each do |anime|
  #cache = anime.fill_torrents_cache
  #mutex.synchronize {
    #i += 1
    #print "%d\t%d\t%d\t%s\n" % [cache.size, count-i, anime.id, anime.name] if cache
    #print "failed for %d\t%d\t%s\n" % [count-i, anime.id, anime.name] unless cache
  #}
#end
