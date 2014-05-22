require 'spec_helper'

describe UserListParser do
  let(:parser) { UserListParser.new klass }
  let(:klass) { Anime }
  subject { parser.parse params }

  context :mal do
    let(:params) {{ list_type: 'mal', data: "[{\"id\":1,\"status\":2,\"episodes\":3,\"rewatches\":4,\"score\":5.0,\"name\":\"anime name\"}]" }}
    it { should eq [{id: 1, status: 2, episodes: 3, rewatches: 4, score: 5.0}] }
  end

  context :anime_planet do
    let(:klass) { Manga }
    let(:params) {{ list_type: 'anime_planet', login: 'shikitest' }}
    it { should eq [{name: "Maid Sama!", status: 2, score: 6.0, year: 2005, volumes: 18, chapters: 0, id: nil}] }
  end

  context :xml do
  end

  context :unsupported do
    let(:params) {{ list_type: 'hz' }}
    it { expect{subject}.to raise_error UnsupportedListType }
  end
end
