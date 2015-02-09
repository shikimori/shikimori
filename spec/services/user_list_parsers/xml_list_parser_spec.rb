describe UserListParsers::XmlListParser do
  let(:parser) { UserListParsers::XmlListParser.new klass }
  let(:login) { 'shikitest' }
  let(:wont_watch_strategy) { nil }
  subject(:parsed) { parser.parse xml }

  context 'anime' do
    let(:klass) { Anime }
    let(:xml) {
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<myanimelist>
  <myinfo>
    <user_export_type>#{UserRatesImporter::AnimeType}</user_export_type>
  </myinfo>
  <anime>
    <anime_animedb_id>1</anime_animedb_id>
    <my_watched_episodes>2</my_watched_episodes>
    <my_times_watched>4</my_times_watched>
    <my_score>5</my_score>
    <my_status>Plan to Watch</my_status>
    <shiki_status>Rewatching</shiki_status>
    <my_comments><![CDATA[test test]]></my_comments>
  </anime>
</myanimelist>"
    }


    it { should eq [{id: 1, status: UserRate.status_id(:rewatching), episodes: 2, rewatches: 4, score: 5.0, text: 'test test'}] }
  end

  context 'manga' do
    let(:klass) { Manga }

    let(:xml) {
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<myanimelist>
  <myinfo>
    <user_export_type>#{UserRatesImporter::MangaType}</user_export_type>
  </myinfo>
  <manga>
    <manga_mangadb_id>1</manga_mangadb_id>
    <my_read_volumes>2</my_read_volumes>
    <my_read_chapters>3</my_read_chapters>
    <my_times_watched>4</my_times_watched>
    <my_score>5</my_score>
    <my_status>Plan to Read</my_status>
    <my_comments><![CDATA[test test]]></my_comments>
  </manga>
</myanimelist>"
      }

    it { should eq [{id: 1, status: UserRate.status_id(:planned), volumes: 2, chapters: 3, rewatches: 4, score: 5.0, text: 'test test'}] }
  end
end
