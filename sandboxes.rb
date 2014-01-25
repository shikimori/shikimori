#!/usr/bin/env ruby
###########################
# всякие полезные сендбоксы
###########################
Comment.includes(:user).includes(:commentable).each {|v| v.user.subscribe(v.commentable) }
Topic.includes(:user).each {|v| v.user.subscribe(v) }

###########################
# заполнение контеста голосами пользователей
###########################
Contest.last.current_round.matches.each {|match| (rand*200).to_i.times { match.votes.create(user_id: users.sample.id, item_id: (rand > 0.5 ? match.left_id : match.right_id), ip: users.sample.current_sign_in_ip) rescue nil } }
Contest.last.process!

###########################
# дубликаты пользователей
###########################
User.joins('inner join users as u on u.nickname=users.nickname and u.id != users.id and users.id+1 = u.id').group('users.id').select('users.id as uid, u.id as uuid').order(:last_online_at.desc).map {|v| v.uid }
User.joins('inner join users as u on u.nickname=users.nickname and u.id != users.id and users.id+1 = u.id').group('users.id').select('users.id as uid, u.id as uuid').order(:last_online_at.desc).map {|v| User.find(v.uid).destroy }
###########################
# импорт описаний из википедии
###########################
CharsDescriptionJob.new.perform anime_ids: [5041], manga_ids: []
###########################
# включение кеша для прокси
###########################
ProxyTools.use_cache = true
###########################
# чистка продублировавшихся сообщений от перезапуска HistoryJob
###########################
Message.where(id: Message.where(linked_id: 116580).group(:to_id).having('count(*) > 1').pluck(:id)).delete_all
###########################
# чистка удалённой на MAL манги, которой нет ни в чьих списках
###########################
Manga.where(imported_at: nil).includes(:rates).select{|v| v.rates.empty? }.each(&:destroy)
###########################
# изменение column collation
###########################
"ALTER TABLE anime_video_authors MODIFY name varchar(255) CHARACTER SET utf8 COLLATE utf8_general_ci"
###########################
# Очистка пустых картинок
###########################
Person.where(image_file_name: ['na.gif', 'na_series.gif']).update_all image_file_name:nil, image_content_type: nil, image_file_size: nil
###########################
# Починка битых каринок, если они загрузились без расширения
###########################
Dir.foreach(Rails.root.join 'public', 'images', 'person', 'original').select {|v| v =~ /\d+\.$/ }.each do |id|
  entry = Person.find id
  FileUtils.mv entry.image.path.sub(/jpg$/, ''), entry.image.path
  entry.image.reprocess!
end
###########################
# оценки пользователей в CSV после сбора их через SVD
###########################
#------user
#|
#|
#|
#title

reload!;matrix,users,entries=Svd.generate! Svd::Full;
CSV.open("/tmp/rates.csv", "wb") do |csv|
  csv << ['anime_id'] + users.keys.map {|v| "user_#{v}" }
  z.send(:rows).each_with_index do |row,index|
    csv << [entries.keys[index]] + row;
  end;
end;
###########################
# отключение timestamp для таблицы
###########################
Entry.record_timestamps = false
AniMangaComment.record_timestamps = false
CharacterComment.record_timestamps = false
AnimeNews.record_timestamps = false
MangaNews.record_timestamps = false
Topic.record_timestamps = false
Entry.where({:action.not_eq => AnimeHistoryAction::Episode} | {:action => nil }).find_each(batch_size: 300) { |v| v.update_attributes(title: v.title) }

ReviewComment.record_timestamps = false
ReviewComment.find_each {|v| v.update_column :updated_at, (v.comments.last ? v.comments.last.created_at : v.created_at) }
ReviewComment.record_timestamps = true

###########################
# парсинг AnimedbRu
parser = AnimedbRuParser.new and nil
parser.cache[:max_id] = parser.fetch_max_id and nil
#parser.cache[:animes].delete_if { |k,v| k > 6000 } and nil
parser.fetch_animes(false, 1) and nil
parser.merge_russian and nil
parser.merge_screenshots and nil

###########################
# импорт с адултманги
###########################
AdultMangaImporter.import id: 'reversal_of_love_talk'

###########################
# Выполнение sql запроса
###########################
ActiveRecord::Base.connection.execute("sql here")

###########################
# конверт тега в персонажа
###########################
character_id = 9272
tag_name = 'Kagamine Rin'
character = Character.find(character_id)
CosplayGallery.tagged_with(tag_name).each do |v|
  v.tag_list = ""
  v.characters = [character]
  v.save
end
Tag.where(:name => tag_name).destroy_all
###########################

###########################
# добавление торрента и эпизода аниме
###########################
TokyoToshokanParser.add_episodes(Anime.find(10578), [
    {
           :link => 'http://www.nyaa.eu/?page=download&tid=269272',
        :pubDate => DateTime.parse('2011-12-17 18:03 UTC'),
           :guid => 'http://www.nyaa.eu/?page=torrentinfo&tid=269272',
          :title => '[Zero-Raws] C3 - 12 END (MX 1280x720 x264 AAC).mp4'
    }
])
###########################
# добавление эпизода без торрента
###########################
anime = Anime.find(9938)
anime.update_attribute(:episodes_aired, anime.episodes_aired+1)
AnimeNews.create_for_new_episode(anime, anime.released_at - 1.minute).update_attribute(:processed, true)
#AnimeNews.create_for_new_episode(anime, DateTime.now - 2.days)


###########################
# экспорт данных об аниме в csv
###########################
genres = Genre.order(:name).each_with_object({}) do |genre,rez|
  rez[genre.id] = genre
end;
entry_ids = Svd.new(scale: Svd::Full, kind: Anime.name).send(:prepare_ids, Svd::Full)[1];
entries = Anime.includes(:genres).where(id: entry_ids).all;
#entries = Anime.includes(:genres).all;

CSV.open("/tmp/animes.csv", "wb") do |csv|
  csv << [:anime_id, :anime_name, :anime_year, :anime_kind, :anime_rating, :anime_duration_in_minutes, :anime_episodes, :anime_score, :anime_status] + genres.values.map(&:name).map(&:downcase)

  entries.each do |entry|
    csv << [entry.id, entry.name,  entry.aired_at ? entry.aired_at.year : '', entry.kind, entry.rating, entry.duration, entry.episodes, entry.score, entry.status] + genres.map {|k,v| entry.genres.any? {|v| v.id == k} ? 1 : 0}
  end;
end;

###########################
# экспорт данных об оценках в csv
###########################
genres = Genre.all.each_with_object({}) do |genre,rez|
  rez[genre.id] = genre
end
#user_ids = (User.joins(:anime_rates).group('users.id').having('count(*) >= 50 and count(*) <= 150').select('users.id').map(&:id) + [1945]).uniq
rates = UserRate.where(user_id: user_ids, target_type: 'Anime').includes(:anime => :genres)
File.open('/tmp/rates.csv', 'w') do |file|
  file.write "user_id;rate_score;rate_status;anime_id;anime_name;anime_year;anime_kind;anime_rating;anime_duration_in_minutes;anime_episodes;anime_score;anime_status;#{genres.map{|k,v| v.name.downcase}.join(';')}\n"
  rates.each do |rate|
    file.write "#{rate.user_id};#{rate.score};#{UserRateStatus.get rate.status};#{rate.target_id};\"#{rate.anime.name}\";#{rate.anime.aired_at ? rate.anime.aired_at.year : ''};#{rate.anime.kind};#{rate.anime.rating};#{rate.anime.duration};#{rate.anime.episodes};#{rate.anime.score};#{rate.anime.status};#{genres.map{|k,v| rate.anime.genres.any? {|v| v.id == k} ? 1 : 0}.join(';')}\n"
  end
end
###########################
# синхронизация числа комментариев
###########################
Entry.record_timestamps = false
Topic.record_timestamps = false
AnimeNews.record_timestamps = false

Entry.reset_column_information
Entry.includes(:comments).all.each do |v|
  v.update_attributes(:comments_count => v.comments.length)
end
###########################
# восстановление информации об аниме из бекапа
###########################
def dump(ids)
  Anime.where(id: ids).all.map do |anime|
    {
      id: anime.id,
      attributes: anime.attributes.except('description','id','description_html', 'russian'),
      genres: anime.genres.pluck(:id)
    }
  end.to_json
end
dump [19115,16009,6504,18771,18893,18001,16419,6336,19631,16051,17080,18365,1735,17357,17653]

def restore(json_data)
  JSON.parse(json_data).each do |entry|
    ap entry
    anime = Anime.find entry['id']
    entry['attributes'].each {|k,v| anime.update_attribute k, v }
    anime.genres = []
    entry['genres'].each do |id|
      anime.genres << Genre.find(id)
    end
  end
end
###########################
# рассылка о том, что гугл и яндекс скоро будут отключены
###########################
users = UserToken.where(provider: ['google_apps', 'yandex']).includes(:user => [:anime_rates, :manga_rates]).map(&:user).compact.select {|v| (v.email.blank? || v.email =~ /generated/) && v.user_tokens.size == 1 && v.password.blank? && v.current_sign_in_at > 3.month.ago && (v.anime_rates.count > 0 || v.manga_rates.count > 0) }.map {|v| [v.id, v.nickname] }
Message.wo_antispam do
  users.each do |(user_id,nickname)|
    message = Message.create({
      from_id: 1,
      to_id: user_id,
      kind: MessageType::Private,
      body: "Привет!
  Где-то во второй половине Июля на сайте произойдёт обновление, которое навсегда поломает авторизацию через Google и Yandex. Авторизация через эти сервисы будет отключена ([spoiler=возможно]позже может быть вернётся назад немного в другом виде, но войти в прежние аккаунты через неё не выйдет[/spoiler]).
  Немного уточню, речь идёт не о регистрации на почту гугла или яндекса, а о регистрация через одну из этих двух кнопочек
  [url=http://img855.imageshack.us/img855/4896/88820130613005456.png][img]http://img855.imageshack.us/img855/4896/88820130613005456.th.png[/img][/url]
  Пишу вам это сообщение, т.к. вы зарегистрированы на сайте как раз через Google(Yandex). Пожалуйста, убедитесь, что сможете в дальнейшем залогиниться на сайт без этого способа.
  Для этого в настройках профиля задайте емайл и пароль, либо же подключите к аккаунту ещё один способ авторизации, через вконтакт или фейсбук.
  [url=http://img43.imageshack.us/img43/9965/88820130613005332.png][img]http://img43.imageshack.us/img43/9965/88820130613005332.th.png[/img][/url]
  Прошу прощения за доставленные неудобства :bow:"
    })
    #Sendgrid.delay.private_message_email(message)
  end
end
