describe BbCodes::ImageTag do
  let(:tag) { BbCodes::ImageTag.instance }
  let(:text_hash) { 'hash' }

  before { Timecop.freeze '2015-03-01T20:53:13.183710+03:00' }
  after { Timecop.return }

  describe '#format' do
    subject { tag.format text, text_hash }

    let(:text) { "[image=#{user_image.id}]" }
    let(:user_image) { create :user_image, user: build_stubbed(:user), width: 400, height: 500 }

    context 'common case' do
      it { should eq "<a href=\"#{user_image.image.url :original}\" rel=\"#{text_hash}\" class=\"b-image unprocessed\">\
<img src=\"#{user_image.image.url :thumbnail}\" class=\"\"/>\
<span class=\"marker\">400x500</span></a>" }
    end

    context 'multiple images' do
      let(:user_image_2) { create :user_image, user: build_stubbed(:user) }
      let(:text) { "[image=#{user_image.id}] [image=#{user_image_2.id}]" }
      it { should eq "<a href=\"#{user_image.image.url :original}\" rel=\"#{text_hash}\" class=\"b-image unprocessed\">\
<img src=\"#{user_image.image.url :thumbnail}\" class=\"\"/>\
<span class=\"marker\">400x500</span></a> <a href=\"#{user_image_2.image.url :original}\" rel=\"#{text_hash}\" class=\"b-image unprocessed\">\
<img src=\"#{user_image_2.image.url :thumbnail}\" class=\"\"/>\
<span class=\"marker\">1000x1000</span></a>" }
    end

    context 'small image' do
      let(:user_image) { create :user_image, user: build_stubbed(:user), width: 249, height: 249 }
      it { should eq "<img src=\"#{user_image.image.url :original}\"/>" }
    end

    context 'with sizes' do
      let(:user_image) { create :user_image, user: build_stubbed(:user), width: 400, height: 400 }
      let(:text) { "[image=#{user_image.id} 400x500]" }
      it { should eq "<a href=\"#{user_image.image.url :original}\" rel=\"#{text_hash}\" class=\"b-image unprocessed\">\
<img src=\"#{user_image.image.url :preview}\" class=\"\" width=\"400\" height=\"400\"/>\
<span class=\"marker\">400x400</span></a>" }
    end

    context 'with width' do
      let(:text) { "[image=#{user_image.id} w=400]" }
      it { should eq "<a href=\"#{user_image.image.url :original}\" rel=\"#{text_hash}\" class=\"b-image unprocessed\">\
<img src=\"#{user_image.image.url :preview}\" class=\"\" width=\"400\"/>\
<span class=\"marker\">400x500</span></a>" }
    end

    context 'with height' do
      let(:text) { "[image=#{user_image.id} h=400]" }
      it { should eq "<a href=\"#{user_image.image.url :original}\" rel=\"#{text_hash}\" class=\"b-image unprocessed\">\
<img src=\"#{user_image.image.url :preview}\" class=\"\" height=\"400\"/>\
<span class=\"marker\">400x500</span></a>" }
    end

    context 'with width&height' do
      let(:text) { "[image=#{user_image.id} w=400 h=500]" }
      it { should eq "<a href=\"#{user_image.image.url :original}\" rel=\"#{text_hash}\" class=\"b-image unprocessed\">\
<img src=\"#{user_image.image.url :preview}\" class=\"\" width=\"400\" height=\"500\"/>\
<span class=\"marker\">400x500</span></a>" }
    end

    context 'with class' do
      let(:text) { "[image=#{user_image.id} w=400 h=500 c=test]" }
      it { should eq "<a href=\"#{user_image.image.url :original}\" rel=\"#{text_hash}\" class=\"b-image unprocessed\">\
<img src=\"#{user_image.image.url :preview}\" class=\"test\" width=\"400\" height=\"500\"/>\
<span class=\"marker\">400x500</span></a>" }
    end
  end
end
