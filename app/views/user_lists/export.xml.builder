xml.instruct!
xml.myanimelist do
  xml.myinfo do
    xml.user_export_type @type == 'manga' ? UserListsController::MangaType : UserListsController::AnimeType
  end
  @list.each do |entry|
    xml.tag! @type do
      if @type == 'manga'
        xml.manga_mangadb_id entry.target_id
        xml.my_read_volumes entry.volumes
        xml.my_read_chapters entry.chapters
      else
        xml.series_animedb_id entry.target_id
        xml.my_watched_episodes entry.episodes
      end
      xml.my_score entry.score
      xml.my_status @type == 'manga' ? UserRateStatus.get(entry.status).sub('Plan to Watch', 'Plan to Read').sub('Watching', 'Reading') : UserRateStatus.get(entry.status)
      xml.update_on_import 1
    end
  end
end
