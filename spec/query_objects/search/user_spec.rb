describe Search::User do
  before do
    allow(Elasticsearch::Query::User)
      .to receive(:call)
      .with(phrase:, limit: ids_limit)
      .and_return results
  end

  subject { described_class.call scope:, phrase:, ids_limit: }

  let(:scope) { User.all }
  let(:phrase) { 'zxct' }
  let(:ids_limit) { 2 }

  let(:results) { { user_1.id => 0.123123 } }

  let!(:user_1) { create :user }
  let!(:user_2) { create :user }

  it { is_expected.to eq [user_1] }
end
