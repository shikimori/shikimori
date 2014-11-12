describe BbCodes::ImageTag do
  let(:tag) { BbCodes::ImageTag.instance }
  let(:text_hash) { 'hash' }

  describe 'format' do
    subject { tag.format text, text_hash }

    let(:text) { "[image=#{user_image.id}]" }
    let(:user_image) { create :user_image, user: build_stubbed(:user), width: 400, height: 500 }

    context 'common_case' do
      it { should eq "<a href=\"#{user_image.image.url :original, false}\" rel=\"#{text_hash}\" class=\"b-image unprocessed\">
<img src=\"#{user_image.image.url :thumbnail, false}\" class=\"\"/>
<span class=\"marker\">400x500</span></a>" }
    end

    context 'multiple_images' do
      let(:user_image_2) { create :user_image, user: build_stubbed(:user) }
      let(:text) { "[image=#{user_image.id}] [image=#{user_image_2.id}]" }
      it { should eq "<a href=\"#{user_image.image.url :original, false}\" rel=\"#{text_hash}\" class=\"b-image unprocessed\">
<img src=\"#{user_image.image.url :thumbnail, false}\" class=\"\"/>
<span class=\"marker\">400x500</span></a> <a href=\"#{user_image_2.image.url :original, false}\" rel=\"#{text_hash}\" class=\"b-image unprocessed\">
<img src=\"#{user_image_2.image.url :thumbnail, false}\" class=\"\"/>
<span class=\"marker\">1000x1000</span></a>" }
    end

    context 'small_image' do
      let(:user_image) { create :user_image, user: build_stubbed(:user), width: 249, height: 249 }
      it { should eq "<img src=\"#{user_image.image.url :original, false}\"/>" }
    end

    context 'with_sizes' do
      let(:user_image) { create :user_image, user: build_stubbed(:user), width: 400, height: 400 }
      let(:text) { "[image=#{user_image.id} 400x500]" }
      it { should eq "<a href=\"#{user_image.image.url :original, false}\" rel=\"#{text_hash}\" class=\"b-image unprocessed\">
<img src=\"#{user_image.image.url :preview, false}\" class=\"\" width=\"400\" height=\"400\"/>
<span class=\"marker\">400x400</span></a>" }
    end

    context 'with_width' do
      let(:text) { "[image=#{user_image.id} w=400]" }
      it { should eq "<a href=\"#{user_image.image.url :original, false}\" rel=\"#{text_hash}\" class=\"b-image unprocessed\">
<img src=\"#{user_image.image.url :preview, false}\" class=\"\" width=\"400\"/>
<span class=\"marker\">400x500</span></a>" }
    end

    context 'with_height' do
      let(:text) { "[image=#{user_image.id} h=400]" }
      it { should eq "<a href=\"#{user_image.image.url :original, false}\" rel=\"#{text_hash}\" class=\"b-image unprocessed\">
<img src=\"#{user_image.image.url :preview, false}\" class=\"\" height=\"400\"/>
<span class=\"marker\">400x500</span></a>" }
    end

    context 'with width&height' do
      let(:text) { "[image=#{user_image.id} w=400 h=500]" }
      it { should eq "<a href=\"#{user_image.image.url :original, false}\" rel=\"#{text_hash}\" class=\"b-image unprocessed\">
<img src=\"#{user_image.image.url :preview, false}\" class=\"\" width=\"400\" height=\"500\"/>
<span class=\"marker\">400x500</span></a>" }
    end

    context 'with_class' do
      let(:text) { "[image=#{user_image.id} w=400 h=500 c=test]" }
      it { should eq "<a href=\"#{user_image.image.url :original, false}\" rel=\"#{text_hash}\" class=\"b-image unprocessed\">
<img src=\"#{user_image.image.url :preview, false}\" class=\"test\" width=\"400\" height=\"500\"/>
<span class=\"marker\">400x500</span></a>" }
    end
  end
end
