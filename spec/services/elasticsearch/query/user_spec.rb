describe Elasticsearch::Query::User, :vcr do
  # include_context :disable_vcr
  include_context :chewy_urgent
  include_context :chewy_indexes, %i[users]
  # include_context :chewy_logger

  subject { described_class.call phrase:, limit: ids_limit }

  let!(:user_1) { create :user, nickname: 'test' }
  let!(:user_2) { create :user, nickname: 'test zxct' }

  let(:ids_limit) { 10 }
  let(:phrase) { 'test' }

  it { is_expected.to have_keys [user_1.id, user_2.id] }
end
