### Animes data

```ruby
File.open('/tmp/animes.json' , 'w') { |f| f.write Anime.where.not(status: :anons).map { |v| v.attributes.except(*%w[coub_tags license_name_ru fansubbers fandubbers options licensors digital_released_on russia_released_on score_2 authorized_imported_at synonyms mal_id japanese english broadcast english desynced site_score torrents_name imageboard_tag next_episode_at imported_at episodes_aired description_ru description_en updated_at created_at image_file_name image_content_type image_file_size image_updated_at russian]) }.to_json }
```

### Users data

```ruby
crypt = ActiveSupport::MessageEncryptor.new(Rails.application.secrets.secret_key_base[0..31])

users_data = []

User.where.not(id: User.excluded_from_statistics).includes(:anime_rates).find_each do |user|
  rates = user.anime_rates.select { |rate| rate.score.positive? && rate.completed? }
  next if rates.none?
  puts user.id

  users_data.push(
    user_id: crypt.encrypt_and_sign(user.id.to_s),
    rates: rates.map { |rate| { id: rate.target_id, score: rate.score } }
  )
end

File.open('/tmp/users.json', 'w') { |f| f.write users_data.to_json }
```
