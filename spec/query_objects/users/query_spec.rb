describe Users::Query do
  let(:query) { Users::Query.fetch }

  include_context :timecop

  before { User.delete_all }

  let!(:user_1) { create :user, current_sign_in_at: 1.day.ago }
  let!(:user_2) { create :user, current_sign_in_at: 2.days.ago }
  let!(:user_3) { create :user, current_sign_in_at: 3.days.ago }

  describe '.fetch' do
    subject { query }
    it { is_expected.to eq [user_1, user_2, user_3] }

    describe '#search' do
      subject { query.search phrase }

      context 'present search phrase' do
        before do
          allow(Elasticsearch::Query::User).to receive(:call).with(
            phrase: phrase,
            limit: Collections::Query::SEARCH_LIMIT
          ).and_return(
            [
              { '_id' => user_3.id },
              { '_id' => user_2.id }
            ]
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
          is_expected.to eq [user_1, user_2, user_3]
          expect(Elasticsearch::Query::User).to_not have_received :call
        end
      end
    end
  end
end
