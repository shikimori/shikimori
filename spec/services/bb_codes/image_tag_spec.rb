describe BbCodes::ImageTag do
  let(:tag) { BbCodes::ImageTag.instance }
  let(:text_hash) { 'hash' }

  before { Timecop.freeze '2015-03-01T20:53:13.183710+03:00' }
  after { Timecop.return }

  describe '#format' do
    subject { tag.format text, text_hash }

    let(:text) { "[image=#{user_image.id}]" }
    let(:user_image) { create :user_image, user: build_stubbed(:user),
      width: 400, height: 500 }

    context 'common case' do
      it { is_expected.to eq "<a href=\"#{user_image.image.url :original, false}\" rel=\"#{text_hash}\" class=\"b-image unprocessed\">\
<img src=\"#{user_image.image.url :thumbnail, false}\" class=\"\" \
data-width=\"#{user_image.width}\" data-height=\"#{user_image.height}\" />\
<span class=\"marker\">400x500</span></a>" }
    end

    context 'multiple images' do
      let(:user_image_2) { create :user_image, user: build_stubbed(:user) }
      let(:text) { "[image=#{user_image.id}] [image=#{user_image_2.id}]" }
      it { is_expected.to eq "<a href=\"#{user_image.image.url :original, false}\" rel=\"#{text_hash}\" class=\"b-image unprocessed\">\
<img src=\"#{user_image.image.url :thumbnail, false}\" class=\"\" \
data-width=\"#{user_image.width}\" data-height=\"#{user_image.height}\" />\
<span class=\"marker\">400x500</span></a> <a href=\"#{user_image_2.image.url :original, false}\" rel=\"#{text_hash}\" class=\"b-image unprocessed\">\
<img src=\"#{user_image_2.image.url :thumbnail, false}\" class=\"\" \
data-width=\"#{user_image_2.width}\" data-height=\"#{user_image_2.height}\" />\
<span class=\"marker\">1000x1000</span></a>" }
    end

    context 'small image' do
      let(:user_image) { create :user_image, user: build_stubbed(:user), width: 249, height: 249 }
      it { is_expected.to eq "<img src=\"#{user_image.image.url :original, false}\" \
data-width=\"#{user_image.width}\" data-height=\"#{user_image.height}\" />" }
    end

    context 'with sizes' do
      let(:user_image) { create :user_image, user: build_stubbed(:user), width: 400, height: 400 }
      let(:text) { "[image=#{user_image.id} 400x500]" }
      it { is_expected.to eq "<a href=\"#{user_image.image.url :original, false}\" rel=\"#{text_hash}\" class=\"b-image unprocessed\">\
<img src=\"#{user_image.image.url :preview, false}\" class=\"\" width=\"400\" height=\"400\" \
data-width=\"#{user_image.width}\" data-height=\"#{user_image.height}\" />\
<span class=\"marker\">400x400</span></a>" }
    end

    context 'with width' do
      let(:text) { "[image=#{user_image.id} w=400]" }
      it { is_expected.to eq "<a href=\"#{user_image.image.url :original, false}\" rel=\"#{text_hash}\" class=\"b-image unprocessed\">\
<img src=\"#{user_image.image.url :preview, false}\" class=\"\" width=\"400\" \
data-width=\"#{user_image.width}\" data-height=\"#{user_image.height}\" />\
<span class=\"marker\">400x500</span></a>" }
    end

    context 'with height' do
      let(:text) { "[image=#{user_image.id} h=400]" }
      it { is_expected.to eq "<a href=\"#{user_image.image.url :original, false}\" rel=\"#{text_hash}\" class=\"b-image unprocessed\">\
<img src=\"#{user_image.image.url :preview, false}\" class=\"\" height=\"400\" \
data-width=\"#{user_image.width}\" data-height=\"#{user_image.height}\" />\
<span class=\"marker\">400x500</span></a>" }
    end

    context 'with width&height' do
      let(:text) { "[image=#{user_image.id} w=400 h=500]" }
      it { is_expected.to eq "<a href=\"#{user_image.image.url :original, false}\" rel=\"#{text_hash}\" class=\"b-image unprocessed\">\
<img src=\"#{user_image.image.url :preview, false}\" class=\"\" width=\"400\" height=\"500\" \
data-width=\"#{user_image.width}\" data-height=\"#{user_image.height}\" />\
<span class=\"marker\">400x500</span></a>" }
    end

    context 'with class' do
      let(:text) { "[image=#{user_image.id} w=400 h=500 c=test]" }
      it { is_expected.to eq "<a href=\"#{user_image.image.url :original, false}\" rel=\"#{text_hash}\" class=\"b-image unprocessed\">\
<img src=\"#{user_image.image.url :preview, false}\" class=\"test\" width=\"400\" height=\"500\" \
data-width=\"#{user_image.width}\" data-height=\"#{user_image.height}\" />\
<span class=\"marker\">400x500</span></a>" }
    end
  end
end
