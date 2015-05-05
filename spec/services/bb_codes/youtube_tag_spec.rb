describe BbCodes::YoutubeTag do
  let(:tag) { BbCodes::YoutubeTag.instance }

  describe '#format' do
    let(:text) { '[youtube]http://www.youtube.com/watch?v=xbOhbJcgFOw&feature=youtu.be[/youtube]' }
    it { expect(tag.format text).to include '<embed src' }
  end
end
