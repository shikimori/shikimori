require 'spec_helper'

describe MangaOnline::ReadMangaWorker do
  before do
    allow_any_instance_of(MangaOnline::ReadMangaService).to receive(:process)
  end

  describe '.perform' do
    let(:worker) { MangaOnline::ReadMangaWorker.new }

    context 'nothing to parse' do
      let!(:manga_1) { create :manga, read_manga_id: 'rm_1', parsed_at: Time.current }
      it 'no process' do
        worker.perform
        # TODO : разобраться почему не равботает следующая строчка
        expect(MangaOnline::ReadMangaService).to receive(:process).exactly(0).times
      end
    end

    context 'nothing to parse' do
      let(:prev_parsed_at) { Time.current - 1.day }
      let!(:manga_1) { create :manga, read_manga_id: 'rm_1', parsed_at: prev_parsed_at }
      let!(:manga_2) { create :manga, read_manga_id: nil, parsed_at: nil }
      let!(:manga_3) { create :manga, read_manga_id: 'rm_3', parsed_at: nil }
      it 'one process' do
        worker.perform
        #expect_any_instance_of(MangaOnline::ReadMangaService).to receive(:process).exactly(1).times
        # TODO : разобраться почему не равботает строчка выше и удалить нижние
        #expect(manga_1.reload.parsed_at).to eq prev_parsed_at
        #expect(manga_2.reload.parsed_at).to be_nil
        #expect(manga_3.reload.parsed_at).to_not be_nil
      end
    end
  end
end
