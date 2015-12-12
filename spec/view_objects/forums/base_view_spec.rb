describe Forums::BaseView do
  include_context :view_object_warden_stub

  let(:view) { Forums::SectionView.new }
  let(:user) { seed :user }
  let(:params) {{ }}

  before { allow(view.h).to receive(:params).and_return params }

  describe '#linked' do
    before { allow(view).to receive_message_chain(:section, :permalink)
      .and_return permalink }
    let(:params) {{ linked: entry.id }}

    context 'a' do
      let(:permalink) { 'a' }
      let(:entry) { create :anime }

      it { expect(view.linked).to eq entry }
    end

    context 'm' do
      let(:permalink) { 'm' }
      let(:entry) { create :manga }

      it { expect(view.linked).to eq entry }
    end

    context 'c' do
      let(:permalink) { 'c' }
      let(:entry) { create :character }

      it { expect(view.linked).to eq entry }
    end

    context 'g' do
      let(:permalink) { 'g' }
      let(:entry) { create :group }

      it { expect(view.linked).to eq entry }
    end

    context 'reviews' do
      let(:permalink) { 'reviews' }
      let(:entry) { create :review }

      it { expect(view.linked).to eq entry }
    end

    context 'other' do
      let(:params) {{ linked: 'zzz' }}
      let(:permalink) { 'other' }

      it { expect(view.linked).to be_nil }
    end

    context 'no linekd' do
      let(:params) {{ }}
      let(:permalink) { }

      it { expect(view.linked).to be_nil }
    end
  end
end
