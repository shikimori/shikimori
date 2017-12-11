describe Search::User do
  before do
    allow(Elasticsearch::Query::User)
      .to receive(:call)
      .with(phrase: phrase, limit: ids_limit)
      .and_return results
  end
  subject do
    Search::User.call(
      scope: scope,
      phrase: phrase,
      ids_limit: ids_limit
    )
  end

  describe '#call' do
    let(:scope) { User.all }
    let(:phrase) { 'zxct' }
    let(:ids_limit) { 2 }
    let(:results) { { user_1.id => 0.123123 } }

    let!(:user_1) { create :user, nickname: 'test' }
    let!(:user_2) { create :user, nickname: 'test zxct' }

    it { is_expected.to eq [user_1] }
  end
end
