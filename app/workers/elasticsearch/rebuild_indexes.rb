class Elasticsearch::RebuildIndexes
  def perform
    ClubsIndex.reset!
    CollectionsIndex.reset!
    ArticlesIndex.reset!
    LicensorsIndex.reset!
    FansubbersIndex.reset!
    AnimesIndex.reset!
    MangasIndex.reset!
    RanobeIndex.reset!
    PeopleIndex.reset!
    CharactersIndex.reset!
    TopicsIndex.reset!
    UsersIndex.reset!
  end
end
