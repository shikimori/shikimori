describe BbCodes::PosterTag do
  let(:tag) { BbCodes::PosterTag.instance }

  describe 'format' do
    subject { tag.format text }
    let(:url) { 'http://site.com/site-url' }
    let(:text) { "[poster]#{url}[/poster]" }

    it { should eq "<img class=\"b-poster\" src=\"#{url}\" />" }
  end
end
