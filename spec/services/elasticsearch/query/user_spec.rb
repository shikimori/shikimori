describe Elasticsearch::Query::User, :vcr do
  around { |example| Chewy.strategy(:urgent) { example.run } }
  before do
    # VCR.configure { |c| c.ignore_request { |_request| true } }
    # Chewy.logger = ActiveSupport::Logger.new(STDOUT)
    # Chewy.transport_logger = ActiveSupport::Logger.new(STDOUT)
    ActiveRecord::Base.connection.reset_pk_sequence! :users
    UsersIndex.purge!
  end

  subject { described_class.call phrase: phrase, limit: ids_limit }

  let!(:user_1) { create :user, nickname: 'test' }
  let!(:user_2) { create :user, nickname: 'test zxct' }

  let(:ids_limit) { 10 }
  let(:phrase) { 'test' }

  it { is_expected.to have_keys [user_1.id, user_2.id] }
end
