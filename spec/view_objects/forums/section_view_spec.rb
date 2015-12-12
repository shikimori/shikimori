describe Forums::SectionView do
  include_context :view_object_warden_stub

  let(:view) { Forums::SectionView.new }
  let(:user) { seed :user }
  let(:params) {{ section: 'all' }}

  before { allow(view.h).to receive(:params).and_return params }

  describe '#section' do
    it do
      expect(view.section).to have_attributes(
        id: nil,
        permalink: 'all'
      )
    end
  end

  describe '#topics' do
  end

  describe '#page' do
    context 'has page in params' do
      let(:params) {{ page: 2 }}
      it { expect(view.page).to eq 2 }
    end

    context 'no page in params' do
      it { expect(view.page).to eq 1 }
    end
  end

  describe '#limit' do
    context 'no format' do
      it { expect(view.limit).to eq 8 }
    end

    context 'rss format' do
      let(:params) {{ format: 'rss' }}
      it { expect(view.limit).to eq 30 }
    end
  end

  describe '#add_postloader' do
    it { expect(view.add_postloader?).to eq false }
  end
end
