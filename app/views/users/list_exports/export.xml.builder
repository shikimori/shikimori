xml.instruct!
xml.myanimelist do
  xml.myinfo { xml.user_export_type @export_type }

  @collection.each do |user_rate|
    xml.tag! user_rate.target_type.downcase do
      raise user_rate.id.to_json if user_rate.target.nil?
      xml.series_title user_rate.target.name
      xml.series_type user_rate.target.kind

      if @export_type == ListImports::ParseXml::ANIME_TYPE
        xml.series_episodes user_rate.target.episodes
        xml.series_animedb_id user_rate.target_id
        xml.my_watched_episodes user_rate.episodes
      else
        xml.series_volumes user_rate.target.volumes
        xml.series_chapters user_rate.target.chapters
        xml.manga_mangadb_id user_rate.target_id
        xml.my_read_volumes user_rate.volumes
        xml.my_read_chapters user_rate.chapters
      end

      xml.my_times_watched user_rate.rewatches
      xml.my_score user_rate.score || 0
      xml.my_status ListImports::XmlStatus.call(
        user_rate.status,
        @export_type,
        true
      )
      xml.shiki_status ListImports::XmlStatus.call(
        user_rate.status,
        @export_type,
        false
      )
      xml.my_comments user_rate.text
      xml.update_on_import 1
    end
  end
end
