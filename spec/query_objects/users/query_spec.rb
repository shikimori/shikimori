describe Users::Query do
  let(:query) { Users::Query.fetch }

  include_context :timecop

  before { User.delete_all }

  let!(:user_1) do
    create :user, current_sign_in_at: 10.days.ago, last_online_at: 10.days.ago
  end
  let!(:user_2) do
    create :user, current_sign_in_at: 20.days.ago, last_online_at: 20.days.ago
  end
  let!(:user_3) do
    create :user, current_sign_in_at: 70.days.ago, last_online_at: 60.days.ago
  end
  let!(:user_4) do
    create :user, current_sign_in_at: 50.days.ago, last_online_at: 40.days.ago
  end
  let!(:user_5) do
    create :user, current_sign_in_at: 50.days.ago, last_online_at: 40.days.ago
  end

  describe '.fetch' do
    subject { query }

    it { is_expected.to eq [user_1, user_2, user_5, user_4, user_3] }

    describe '#search' do
      subject { query.search phrase }

      context 'present search phrase' do
        before do
          allow(Elasticsearch::Query::User).to receive(:call).with(
            phrase: phrase,
            limit: Collections::Query::SEARCH_LIMIT
          ).and_return(
            user_3.id => 1.23,
            user_2.id => 1.11
          )
        end
        let(:phrase) { 'test' }

        it do
          is_expected.to eq [user_3, user_2]
          expect(Elasticsearch::Query::User).to have_received(:call).once
        end
      end

      context 'missing search phrase' do
        before { allow(Elasticsearch::Query::User).to receive :call }
        let(:phrase) { '' }

        it do
          is_expected.to eq [user_1, user_2, user_5, user_4, user_3]
          expect(Elasticsearch::Query::User).to_not have_received :call
        end
      end
    end
  end
end
