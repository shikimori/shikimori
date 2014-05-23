require 'spec_helper'

describe UserListParsers::XmlListParser do
  let(:parser) { UserListParsers::XmlListParser.new klass }
  let(:login) { 'shikitest' }
  let(:wont_watch_strategy) { nil }
  subject(:parsed) { parser.parse xml }

  context :anime do
    let(:klass) { Anime }
    let(:xml) {
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<myanimelist>
  <myinfo>
    <user_export_type>#{UserListsController::AnimeType}</user_export_type>
  </myinfo>
  <anime>
    <anime_animedb_id>1</anime_animedb_id>
    <my_watched_episodes>2</my_read_volumes>
    <my_score></my_score>
    <my_status>Plan to Read</my_status>
  </anime>
</myanimelist>"
    }


    it { should eq [{id: 1, status: 2, episodes: 3, rewatches: 4, score: 5.0}] }
  end

  context :manga do
    let(:klass) { Manga }

    let(:xml) {
      "<?xml version=\"1.0\" encoding=\"UTF-8\"?>
<myanimelist>
  <myinfo>
    <user_export_type>#{UserListsController::AnimeType}</user_export_type>
  </myinfo>
  <anime>
    <anime_animedb_id>1</anime_animedb_id>
    <my_read_volumes>2</my_read_volumes>
    <my_read_chapters>3</my_read_chapters>
    <my_score>1</my_score>
    <my_status>Plan to Read</my_status>
    <update_on_import>1</update_on_import>
  </anime>
</myanimelist>"
      }

    it { should eq [{id: 1, status: 2, episodes: 3, rewatches: 4, score: 5.0}] }
  end
end
