describe ProlongateBan do
  let(:worker) { ProlongateBan.new }

  before { Timecop.freeze }
  after { Timecop.return }

  describe '#perform' do
    # let!(:user) { create :user }
    # let!(:user_2) { create :user, read_only_at: read_only_at, current_sign_in_ip: ip }

    # let(:read_only_at) { 1.week.from_now }
    # let(:ip) { '127.0.0.1' }

    # before { worker.perform user.id }

    # context 'not matched ip' do
      # it { expect(user.reload.read_only_at).to be_nil }
    # end

    # context 'matched ip' do
      # let!(:user) { create :user, id: id, current_sign_in_ip: ip, created_at: created_at }

      # let(:id) { 345678 }
      # let(:created_at) { 20.days.ago }

      # context 'new user' do
        # context 'ignored id' do
          # let(:id) { ProlongateBan::IGNORED_IDS.sample }
          # it { expect(user.reload.read_only_at).to be_nil }
        # end

        # context 'not ignored id' do
          # it { expect(user.reload.read_only_at).to eq read_only_at }
        # end
      # end

      # context 'old user' do
        # let(:created_at) { 22.days.ago }
        # it { expect(user.reload.read_only_at).to be_nil }
      # end
    # end
  end
end
