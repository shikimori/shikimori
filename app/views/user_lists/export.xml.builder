xml.instruct!
xml.myanimelist do
  xml.myinfo do
    xml.user_export_type @klass == Manga ? UserListsController::MangaType : UserListsController::AnimeType
  end

  @list.each do |entry|
    xml.tag! @klass.name.downcase do
      xml.series_title entry.target.name
      xml.series_type entry.target.kind

      if @klass == Anime
        xml.series_episodes entry.target.episodes
        xml.series_animedb_id entry.target_id
        xml.my_watched_episodes entry.episodes
      else
        xml.series_volumes entry.target.volumes
        xml.series_chapters entry.target.chapters
        xml.manga_mangadb_id entry.target_id
        xml.my_read_volumes entry.volumes
        xml.my_read_chapters entry.chapters
      end
      xml.my_rewatches entry.rewatches
      xml.my_score entry.score || 0
      xml.my_status UserListParsers::XmlListParser.status_to_string(entry.status, @klass, true)
      xml.shiki_status UserListParsers::XmlListParser.status_to_string(entry.status, @klass, false)
      xml.update_on_import 1
    end
  end
end
