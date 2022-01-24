### Move anime data from development to production
```ruby
[14813, 33161, 18753, 23847].each do |anime_id|
  anime = Anime.find(anime_id);

  File.open("/tmp/anime_#{anime_id}.json", 'w') do |f|
    f.write({
      anime_id: anime_id,
      anime: anime,
      person_roles: anime.person_roles,
      user_rates: anime.rates,
      user_history: anime.user_histories,
      user_rate_logs: anime.user_rate_logs,
      topics: anime.all_topics,
      collection_links: anime.collection_links,
      versions: anime.versions,
      club_links: anime.club_links,
      contest_links: anime.contest_links,
      contest_winners: anime.contest_winners,
      favourites: anime.favourites,
      comments: (anime.all_topics + anime.reviews.flat_map(&:all_topics)).flat_map(&:comments),
      related: anime.related,
      similar: anime.similar,
      cosplay_gallery_links: anime.cosplay_gallery_links,
      reviews: anime.reviews,
      screenshots: anime.all_screenshots,
      videos: anime.videos,
      recommendation_ignores: anime.recommendation_ignores,
      anime_calendars: anime.anime_calendars,
      anime_videos: anime.anime_videos,
      episode_notifications: anime.episode_notifications,
      name_matches: anime.name_matches,
      links: anime.links,
      external_links: anime.external_links
    }.to_json);
  end;
end
```

```sh
scp /tmp/anime_*.json devops@shiki:/tmp/
```

```ruby
json = JSON.parse(open('/tmp/anime_33161.json').read).symbolize_keys;
anime_id = json['anime_id']

anime = Anime.wo_timestamp { z = Anime.find_or_initialize_by(id: json[:anime]['id']); z.assign_attributes json[:anime]; z.save validate: false; z };
anime.all_topics.destroy_all;

mappings = {
  related: RelatedAnime,
  similar: SimilarAnime,
  links: AnimeLink
}
%i[
  person_roles
  topics
  collection_links
  versions
  club_links
  contest_links
  contest_winners
  favourites
  related
  similar
  cosplay_gallery_links
  reviews
  screenshots
  videos
  recommendation_ignores
  anime_calendars
  anime_videos
  episode_notifications
  name_matches
  links
  external_links
  comments
].each do |kind|
  puts kind
  puts '=============================================='
  ApplicationRecord.transaction do
    klass = mappings[kind] || kind.to_s.classify.constantize
    klass.wo_timestamp { klass.import(json[kind].map {|v| klass.new v }, validate: false, on_duplicate_key_ignore: true); };
  end
end;

class UserRate < ApplicationRecord
  def log_created; end
  def log_deleted; end
end
ApplicationRecord.transaction do
  UserRate.where(target: anime).delete_all;
  UserRate.wo_timestamp { UserRate.import(json[:user_rates].map {|v| UserRate.new v }, validate: false, on_duplicate_key_ignore: true); };
end;

anime.touch;

# ApplicationRecord.transaction do
#   UserRateLog.where(target: anime).delete_all;
#   UserRateLog.wo_timestamp { UserRateLog.import(json[:user_rate_logs].map {|v| UserRateLog.new v }, validate: false); };
# end;

ApplicationRecord.transaction do
  UserHistory.where(target: anime).delete_all;
  UserHistory.wo_timestamp { UserHistory.import(json[:user_history].map {|v| UserHistory.new v }, validate: false, on_duplicate_key_ignore: true); };
end;

anime.touch;
User.where(id: UserRate.where(target: anime).select('user_id')).update_all updated_at: Time.zone.now;

```


### Generate favicons

```sh
convert -resize 144x144 /tmp/favicon.png public/favicons/ms-icon-144x144.png
convert -resize 228x228 /tmp/favicon.png public/favicons/opera-icon-228x228.png
convert -resize 180x180 /tmp/favicon.png public/favicons/apple-touch-icon-180x180.png
convert -resize 152x152 /tmp/favicon.png public/favicons/apple-touch-icon-152x152.png
convert -resize 144x144 /tmp/favicon.png public/favicons/apple-touch-icon-144x144.png
convert -resize 120x120 /tmp/favicon.png public/favicons/apple-touch-icon-120x120.png
convert -resize 114x114 /tmp/favicon.png public/favicons/apple-touch-icon-114x114.png

convert -resize 76x76 /tmp/favicon.png public/favicons/apple-touch-icon-76x76.png
convert -resize 72x72 /tmp/favicon.png public/favicons/apple-touch-icon-72x72.png
convert -resize 60x60 /tmp/favicon.png public/favicons/apple-touch-icon-60x60.png
convert -resize 57x57 /tmp/favicon.png public/favicons/apple-touch-icon-57x57.png

convert -resize 192x192 /tmp/favicon.png public/favicons/favicon-192x192.png
convert -resize 96x96 /tmp/favicon.png public/favicons/favicon-96x96.png
convert -resize 32x32 /tmp/favicon.png public/favicons/favicon-32x32.png
convert -resize 16x16 /tmp/favicon.png public/favicons/favicon-16x16.png

convert -resize 64x64 /tmp/favicon.png public/favicon.ico

# convert /tmp/favicon.png -bordercolor white -border 0 \
#   \( -clone 0 -resize 16x16 \) \
#   \( -clone 0 -resize 32x32 \) \
#   \( -clone 0 -resize 48x48 \) \
#   \( -clone 0 -resize 64x64 \) \
#   public/favicon.ico

cp app/assets/images/src/favicon.svg public/favicons/safari-pinned-tab.svg
```

### Grant access to pg_stat_statements_reset()
```sh
psql -d postgres
```
```sql
\connect shikimori_production;
GRANT EXECUTE ON FUNCTION pg_stat_statements_reset() TO shikimori_production;
```

### Generate apipie documentation
```sh
APIPIE_RECORD=all rspec spec/controllers/api/*
```

### Fix ElasticSearch readonly mode
https://www.elastic.co/guide/en/elasticsearch/reference/6.8/disk-allocator.html
```sh
curl -XPUT -H "Content-Type: application/json" http://192.168.0.2:9200/_cluster/settings \
  -d '{ "transient": {
    "cluster.routing.allocation.disk.watermark.low": "20gb",
    "cluster.routing.allocation.disk.watermark.high": "15gb",
    "cluster.routing.allocation.disk.watermark.flood_stage": "10gb"
  } }'
```

### Manually refresh i18n-js translations
```sh
rails i18n:js:export
```

### Manually update proxies
```sh
rails runner "ProxyWorker.new.perform; File.open('/tmp/proxies.json', 'w') { |f| f.write Proxy.all.to_json }" && scp /tmp/proxies.json shiki:/tmp/ && ssh devops@shiki 'source /home/devops/.zshrc && cd /home/apps/shikimori/production/current && RAILS_ENV=production bundle exec rails runner "Proxy.transaction do; Proxy.delete_all; JSON.parse(open(\"/tmp/proxies.json\").read, symbolize_names: true).each {|v| Proxy.create! v }; end; puts Proxy.count"'
```

### Snippets

#### Convert topic to article
```ruby
ApplicationRecord.transaction do
  topic_id = 296373
  topic = Topic.find topic_id
  article = Article.create!(
    state: 'published',
    moderation_state: 'accepted',
    approver_id: 1,
    locale: 'ru',
    created_at: topic.created_at,
    updated_at: topic.updated_at,
    changed_at: topic.updated_at,
    name: topic.title,
    user_id: topic.user_id,
    body: topic.body
  )
  topic.update_columns(
    title: nil,
    forum_id: 21,
    type: "Topics::EntryTopics::ArticleTopic",
    generated: true,
    body: nil,
    linked_id: article.id,
    linked_type: 'Article'
  )
end
```

#### Restore from UserRateLog
```ruby
user_id = 794365;
scope = User.find(user_id).user_rate_logs.order(:id);

UserHistory.where(user_id: user_id).where('created_at >= ?', scope.first.created_at).each(&:destroy);

class UserRate < ApplicationRecord
  def log_created; end
  def log_deleted; end
end

UserRate.transaction do
  scope.each do |log|
    Timecop.freeze(log.created_at) do
      base_attrs = { user_id: user_id, target_type: log.target_type, target_id: log.target_id }
      diff_attrs = log.diff.except('id').each_with_object({}) {|(k,(old,new)),memo| memo[k] = new }

      if log.diff['id']
        if log.diff['id'][0].nil?
          base_attrs_with_id = base_attrs.merge('id' => log.diff['id'][1])

          prior_rate = UserRate.find_by(base_attrs)

          attrs = diff_attrs.merge(
            prior_rate ?
              prior_rate.attributes.except('id') :
              base_attrs_with_id
          )
          prior_rate&.destroy

          user_rate = UserRate.find_or_initialize_by(base_attrs_with_id)
          user_rate.assign_attributes(attrs)

          user_rate.save!
        else
          UserRate.find_by(id: log.diff['id'][0])&.destroy
        end
      else
        user_rate = UserRate.find_or_initialize_by(base_attrs)
        user_rate.assign_attributes(diff_attrs)
        ap user_rate
        user_rate.save!
      end
    end
  end
end

User.find(user_id).update! rate_at: Time.zone.now
```

#### Move user data from development to production
```ruby
user = User.find(794365);

class IPAddr
  def as_json(options = nil)
    to_s
  end
end

File.open('/tmp/z.json', 'w') do |f|
  f.write({
    # user: user,
    # user_preferences: user.preferences,
    # style: user.style,
    user_history: UserHistory.where(user_id: user.id),
    # user_rate_logs: UserRateLog.where(user_id: user.id),
    user_rates: UserRate.where(user_id: user.id)
  }.to_json);
end;
```

```sh
scp /tmp/z.json devops@shiki:/tmp/
ssh shiki
rc
```

```ruby
user_id = 794365;
json = JSON.parse(open('/tmp/x.json').read).symbolize_keys;

class UserRate < ApplicationRecord
  def log_created; end
  def log_deleted; end
end

ApplicationRecord.transaction do
  UserRate.where(user_id: user_id).destroy_all;
  UserRate.wo_timestamp { UserRate.import(json[:user_rates].map {|v| UserRate.new v }); };
end;

ApplicationRecord.transaction do
  UserRateLog.where(user_id: user_id).destroy_all;
  UserRateLog.wo_timestamp { UserRateLog.import(json[:user_rate_logs].map {|v| UserRateLog.new v }); };
 end;

ApplicationRecord.transaction do
  UserHistory.where(user_id: user_id).destroy_all;
  UserHistory.wo_timestamp { UserHistory.import(json[:user_history].map {|v| UserHistory.new v }); };
end;

# User.wo_timestamp { v = User.new json[:user]; v.save validate: false }
# UserPreferences.wo_timestamp { v = UserPreferences.new json[:user_preferences]; v.save validate: false }
# Style.wo_timestamp { v = Style.new json[:style]; v.save validate: false }

User.find(user_id).update rate_at: Time.zone.now
```

### Restore images from backup
```ruby
urls = [
  "/system/user_images/original/6811/971.jpg?1423554170"
];

is_validate = false;
processes = 13;
items = JSON.parse(open('/tmp/urls').read);
batches = items.each_slice(items.size / processes).to_a;

Parallel.each(batches, in_processes: processes) do |batch|
  sleep Parallel.worker_number;
  %w[thumbnail original preview].each do |type|
    batch.
      map { |v| v.gsub(/\?.*|\/system\//, '') }.
      each_with_index do |v, index|
        message = "#{type} #{index} of #{batch.size} Worker##{Parallel.worker_number}";
        from_path = "/Volumes/backup/shikimori_new/#{v.gsub('original', type)}"
        to_path = "/mnt/store/system/#{v.gsub('original', type)}"
        host = 'devops@shiki'

        if is_validate
          puts `if [ $(ssh #{host} [[ -f #{to_path} ]];echo $?) -eq 1 ]; then scp #{from_path} #{host}:#{to_path}; echo "#{message} uploaed #{to_path} uploaded"; else echo "#{message} skipped #{to_path}"; fi`
        else
          puts message
          `scp #{from_path} #{host}:#{to_path}`
        end
    end
  end;
end;
```

### Fix review replies
```ruby
def extract tag, data
  case tag
    when 'quote', '>?'
      if data =~ Comments::ExtractQuotedModels::FORUM_ENTRY_QUOTE_REGEXP
        $LAST_MATCH_INFO[:comment_id]
      end

    when 'comment'
      data

    else
      nil
  end
end

Review.
  where('comments_count > 0').
  find_each do |review|
    comment_ids = review.
      body.
      scan(BbCodes::Tags::RepliesTag::REGEXP).
      flat_map { |_, _, ids| ids.split(',').map(&:to_i) }

    comments = Comment.where(id: comment_ids).to_a
    ap comments

    matched_ids = comments.
      flat_map do |comment|
        mathed_ids = comment.
          body.
          scan(Comments::ExtractQuotedModels::REGEXP).
          map do |(tag_1, data_1, tag_2, data_2)|
            extract tag_1 || tag_2, data_1 || data_2
          end
      end

    original_comment_id = matched_ids.
      compact.
      each_with_object({}) { |id, memo| memo[id] ||= 0; memo[id] += 1 }.
      select { |id, _count| Comment.find_by(id: id).nil? }.
      sort_by { |_id, count| -count }.
      first&.first

    next unless original_comment_id

    comments.each do |comment|
      original_comment = Comment.new(id: original_comment_id)

      comment.update_column(
        :body,
        BbCodes::Quotes::Replace.call(
          text: comment.body,
          from_reply: original_comment,
          to_reply: review
        )
      )
    end
  end;
```

### Convert review topics
```ruby
Review.includes(:comments).find_each do |review|
  review.send :generate_topics, :ru

  Comments::Move.call(
    comment_ids: review.comments.map(&:id),
    commentable: review.topics.first,
    from_reply: review,
    to_reply: review.topics.first
  )

end
```
