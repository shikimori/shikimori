describe Elasticsearch::Query::QueryBase, :vcr do
  around { |example| Chewy.strategy(:urgent) { example.run } }
  before do
    # VCR.configure { |c| c.ignore_request { |_request| true } }
    # Chewy.logger = ActiveSupport::Logger.new(STDOUT)
    # Chewy.transport_logger = ActiveSupport::Logger.new(STDOUT)
    ActiveRecord::Base.connection.reset_pk_sequence! :users
    UsersIndex.purge!
  end

  subject do
    Elasticsearch::Query::User.call(
      phrase: phrase,
      limit: ids_limit
    )
  end

  let!(:user_1) { create :user, nickname: 'test' }
  let!(:user_2) { create :user, nickname: 'test zxct' }
  let!(:user_3) { create :user, nickname: 'zxct' }
  let!(:user_4) { create :user, nickname: 'qw' }

  let(:ids_limit) { 10 }
  let(:phrase) { 'test' }

  context 'direct match' do
    it { is_expected.to have_keys [user_1.id, user_2.id] }
  end

  context 'limit' do
    let(:ids_limit) { 1 }
    it { is_expected.to have_keys [user_1.id] }
  end

  context 'partial match' do
    context 'one letter' do
      let(:phrase) { 't' }
      it { is_expected.to have_keys [user_2.id, user_1.id, user_3.id] }
    end

    context 'two letters' do
      let(:phrase) { 'te' }
      it { is_expected.to have_keys [user_2.id, user_1.id] }
    end

    context 'more letters' do
      let(:phrase) { 'tes' }
      it { is_expected.to have_keys [user_2.id, user_1.id] }
    end

    context 'second word' do
      let(:phrase) { 'zx' }
      it { is_expected.to have_keys [user_3.id, user_2.id] }
    end
  end

  context 'no matches' do
    let(:phrase) { 'io' }
    it { is_expected.to eq({}) }
  end
end
