describe JsExports::Supervisor do
  let(:user) { build_stubbed :user }
  let(:view) { described_class.instance }

  let(:user_rates_export) { JsExports::UserRatesExport.instance }
  let(:topics_export) { JsExports::TopicsExport.instance }
  let(:reviews_export) { JsExports::ReviewsExport.instance }
  let(:comments_export) { JsExports::CommentsExport.instance }
  let(:polls_export) { JsExports::PollsExport.instance }

  describe '#export' do
    subject(:export) { view.export user }
    it do
      expect(export).to be_kind_of Hash
      expect(export.keys).to eq described_class::KEYS
    end
  end

  describe '#sweep' do
    before do
      allow(user_rates_export).to receive :sweep
      allow(topics_export).to receive :sweep
      allow(comments_export).to receive :sweep
      allow(polls_export).to receive :sweep
    end
    subject! { view.sweep html }

    context 'with html' do
      let(:html) { 'test' }
      it do
        is_expected.to eq html
        expect(user_rates_export).to have_received(:sweep).with html
        expect(topics_export).to have_received(:sweep).with html
        expect(comments_export).to have_received(:sweep).with html
        expect(polls_export).to have_received(:sweep).with html
      end
    end

    context 'without html' do
      let(:html) { nil }
      it do
        is_expected.to eq html
        expect(user_rates_export).to_not have_received :sweep
        expect(topics_export).to_not have_received :sweep
        expect(comments_export).to_not have_received :sweep
        expect(polls_export).to_not have_received :sweep
      end
    end
  end
end
