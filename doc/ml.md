### Animes data

```ruby
File.open('/tmp/animes.json' , 'w') { |f| f.write Anime.where.not(status: :anons).map { |v| v.attributes.except(*%w[coub_tags license_name_ru fansubbers fandubbers options licensors digital_released_on russia_released_on score_2 authorized_imported_at synonyms mal_id japanese english broadcast english desynced site_score torrents_name imageboard_tag next_episode_at imported_at episodes_aired description_ru description_en updated_at created_at image_file_name image_content_type image_file_size image_updated_at russian]) }.to_json }
```
