require 'spec_helper'

describe MangaOnline::ReadMangaWorker do
  describe '.perform' do
    let(:worker) { MangaOnline::ReadMangaWorker.new }
    before { worker.stub(:process) }
    subject { worker.perform }

    context 'nothing to parse' do
      let!(:manga_1) { create :manga, read_manga_id: 'rm_1', parsed_at: Time.current }
      before { subject }
      it { expect(worker).to_not have_received(:process) }
    end

    context 'nothing to parse' do
      let!(:manga_1) { create :manga, read_manga_id: 'rm_1', parsed_at: Time.current }
      let!(:manga_2) { create :manga, read_manga_id: nil, parsed_at: nil }
      let!(:manga_3) { create :manga, read_manga_id: 'rm_3', parsed_at: nil }
      before { subject }
      it { expect(worker).to have_received(:process).once }
    end
  end
end
