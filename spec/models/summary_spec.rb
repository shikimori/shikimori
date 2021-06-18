describe Summary do
  describe 'associations' do
    it { is_expected.to belong_to :user }
    it { is_expected.to belong_to(:anime).optional }
    it { is_expected.to belong_to(:manga).optional }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of :body }
    # it { is_expected.to validate_presence_of :anime }
    # it { is_expected.to validate_presence_of :manga }
  end

  describe 'instance methods' do
    describe '#html_body' do
      subject { build :summary, body: body }
      let(:body) { '[b]zxc[/b]' }
      its(:html_body) { is_expected.to eq '<strong>zxc</strong>' }
    end
  end

  it_behaves_like :antispam_concern, :summary
end
