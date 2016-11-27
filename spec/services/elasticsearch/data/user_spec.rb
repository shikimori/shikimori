describe Elasticsearch::Data::User do
  subject { Elasticsearch::Data::User.call user }
  let(:user) { create :user, nickname: 'zzz' }

  it { is_expected.to eq nickname: 'zzz' }
end
