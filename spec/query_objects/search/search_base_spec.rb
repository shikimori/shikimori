describe Search::SearchBase, :vcr do
  # include_context :disable_vcr
  include_context :chewy_urgent
  include_context :chewy_indexes, %i[users]
  # include_context :chewy_logger

  subject do
    Search::User.call(
      scope: scope,
      phrase: phrase,
      ids_limit: ids_limit
    )
  end

  let(:scope) { User.all }
  let(:phrase) { 'zxct' }
  let(:ids_limit) { 2 }

  let!(:user_1) { create :user, nickname: 'test' }
  let!(:user_2) { create :user, nickname: 'test zxct' }

  it { is_expected.to eq [user_2] }
end
