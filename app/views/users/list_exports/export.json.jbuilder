json.array! @collection do |user_rate|
  json.target_title user_rate.target.name
  json.target_title_ru user_rate.target.russian
  json.target_id user_rate.target_id
  json.target_type user_rate.target_type
  json.score user_rate.score
  json.status user_rate.status
  json.rewatches user_rate.rewatches

  if @export_type == ListImports::ParseXml::ANIME_TYPE
    json.episodes user_rate.episodes
  else
    json.volumes user_rate.volumes
    json.chapters user_rate.chapters
  end
  json.text user_rate.text
end
