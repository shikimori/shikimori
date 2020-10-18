describe Users::Query do
  let(:query) { Users::Query.fetch }

  include_context :timecop

  before { User.delete_all }

  let!(:user_1) do
    create :user,
      current_sign_in_at: 10.days.ago,
      current_sign_in_ip: '127.0.0.1'
  end
  let!(:user_2) do
    create :user,
      current_sign_in_at: 20.days.ago,
      last_sign_in_ip: '127.0.0.1',
      created_at: 2.days.ago
  end
  let!(:user_3) do
    create :user,
      current_sign_in_at: 70.days.ago,
      created_at: 3.days.ago.beginning_of_day
  end
  let!(:user_4) do
    create :user,
      current_sign_in_at: 50.days.ago,
      created_at: 3.days.ago.end_of_day
  end

  let(:all_users) { [user_4, user_3, user_2, user_1] }

  describe '.fetch' do
    subject { query }

    it { is_expected.to eq all_users }
  end

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
      let(:phrase) { ['', nil].sample }

      it do
        is_expected.to eq all_users
        expect(Elasticsearch::Query::User).to_not have_received :call
      end
    end
  end

  describe '#id' do
    subject { query.id id }

    context 'present id' do
      let(:id) { user_1.id }
      it { is_expected.to eq [user_1] }
    end

    context 'missing id' do
      let(:id) { ['', nil, 0].sample }
      it { is_expected.to eq all_users }
    end
  end

  describe '#email' do
    subject { query.email email }

    context 'present email' do
      let(:email) { user_1.email }
      it { is_expected.to eq [user_1] }
    end

    context 'missing email' do
      let(:email) { ['', nil].sample }
      it { is_expected.to eq all_users }
    end
  end

  describe '#current_sign_in_ip' do
    subject { query.current_sign_in_ip ip }

    context 'present ip' do
      let(:ip) { '127.0.0.1' }
      it { is_expected.to eq [user_1] }
    end

    context 'missing ip' do
      let(:ip) { ['', nil].sample }
      it { is_expected.to eq all_users }
    end
  end

  describe '#last_sign_in_ip' do
    subject { query.last_sign_in_ip ip }

    context 'present ip' do
      let(:ip) { '127.0.0.1' }
      it { is_expected.to eq [user_2] }
    end

    context 'missing ip' do
      let(:ip) { ['', nil].sample }
      it { is_expected.to eq all_users }
    end
  end

  describe '#created_on' do
    subject { query.created_on date }

    context 'present date' do
      let(:date) { 3.days.ago.to_date.to_s }
      it { is_expected.to eq [user_3, user_4] }
    end

    context 'no date' do
      let(:date) { ['', nil].sample }
      it { is_expected.to eq all_users }
    end
  end
end
