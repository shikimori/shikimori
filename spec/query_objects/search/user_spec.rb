describe Search::User do
  subject(:query) do
    Search::User.call(
      scope: scope,
      phrase: phrase,
      ids_limit: ids_limit
    )
  end

  describe '#call' do
    let(:scope) { User.all }
    let(:phrase) { 'Kaichou' }
    let(:ids_limit) { 10 }

    let!(:user_1) { create :user }
    let!(:user_2) { create :user }
    let!(:user_3) { create :user }

    before do
      allow(Elasticsearch::Query::User).to receive(:call)
        .with(phrase: phrase, limit: ids_limit)
        .and_return [
          { '_id' => user_3.id },
          { '_id' => user_1.id }
        ]
    end

    it do
      is_expected.to eq [user_3, user_1]
    end
  end
end
