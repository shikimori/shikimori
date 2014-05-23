xml.instruct!
xml.myanimelist do
  xml.myinfo do
    xml.user_export_type @type == 'manga' ? UserListsController::MangaType : UserListsController::AnimeType
  end

 ActiveModel::ArraySerializer.new(@list, each_serializer: UserRateExportSerializer).to_xml
end
