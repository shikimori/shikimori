describe Search::SearchBase, :vcr do
  around { |example| Chewy.strategy(:urgent) { example.run } }
  before do
    # VCR.configure { |c| c.ignore_request { |_request| true } }
    # Chewy.logger = ActiveSupport::Logger.new(STDOUT)
    # Chewy.transport_logger = ActiveSupport::Logger.new(STDOUT)
    ActiveRecord::Base.connection.reset_pk_sequence! :users
    UsersIndex.purge!
  end

  subject { Search::User.call scope: scope, phrase: phrase, ids_limit: ids_limit }

  let(:scope) { User.all }
  let(:phrase) { 'zxct' }
  let(:ids_limit) { 2 }

  let!(:user_1) { create :user, nickname: 'test' }
  let!(:user_2) { create :user, nickname: 'test zxct' }

  it { is_expected.to eq [user_2] }
end
