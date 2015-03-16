describe AnimeOnline::VideoVkService do
  let(:service) { AnimeOnline::VideoVkService.new(video) }

  describe '#cut_hd!' do
    subject { service.cut_hd! }
    let(:video) { build(:anime_video, url: url) }
    before { subject }

    context 'vk video' do
      context 'with hd=3' do
        let(:url) { 'http://vk.com/video_ext.php?oid=-33905270&id=170631975&hash=6dbe6d7819d72441&hd=3' }
        it { expect(video.url).to eq 'http://vk.com/video_ext.php?oid=-33905270&id=170631975&hash=6dbe6d7819d72441' }
      end

      context 'without hd=3' do
        let(:url) { 'http://vk.com/video_ext.php?oid=-33905270&id=170631975&hash=6dbe6d7819d72441' }
        it { expect(video.url).to eq 'http://vk.com/video_ext.php?oid=-33905270&id=170631975&hash=6dbe6d7819d72441' }
      end

      context 'with hd=3 not at the end' do
        let(:url) { 'http://vk.com/video_ext.php?oid=-33905270&id=170631975&hash=6dbe6d7819d72441&hd=31' }
        it { expect(video.url).to eq 'http://vk.com/video_ext.php?oid=-33905270&id=170631975&hash=6dbe6d7819d72441&hd=31' }
      end
    end

    context 'not vk video' do
      context 'with hd=3' do
        let(:url) { 'http://youtube.com/embed/n9LwDdcAR4g&hd=3' }
        it { expect(video.url).to eq 'http://youtube.com/embed/n9LwDdcAR4g&hd=3' }
      end

      context 'without hd=3' do
        let(:url) { 'http://youtube.com/embed/n9LwDdcAR4g' }
        it { expect(video.url).to eq 'http://youtube.com/embed/n9LwDdcAR4g' }
      end
    end
  end
end
