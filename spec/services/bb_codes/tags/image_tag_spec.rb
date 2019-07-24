describe BbCodes::Tags::ImageTag do
  let(:tag) { described_class.instance }
  let(:text_hash) { 'hash' }

  include_context :timecop, '2015-03-01T20:53:13.183710+03:00'

  describe '#format' do
    subject { tag.format text, text_hash }

    let(:text) { "[image=#{user_image.id}]" }
    let(:user_image) { create :user_image, width: 400, height: 500 }

    context 'common case' do
      it do
        is_expected.to eq(
          <<-HTML.squish.strip
            <a href="#{user_image.image.url :original, false}"
              rel="#{text_hash}"
              class="b-image unprocessed"><img
                src="#{user_image.image.url :thumbnail, false}"
                data-width="#{user_image.width}"
                data-height="#{user_image.height}"
              /><span class="marker">400x500</span></a>
          HTML
        )
      end
    end

    context 'no zoom' do
      let(:text) { "[image=#{user_image.id} no-zoom]" }

      it do
        is_expected.to eq(
          <<-HTML.squish.strip
            <span class="b-image no-zoom"><img
              src="#{user_image.image.url :original, false}"
              class="check-width"
            /></span>
          HTML
        )
      end
    end

    context 'multiple images' do
      let(:user_image_2) { create :user_image }
      let(:text) { "[image=#{user_image.id}] [image=#{user_image_2.id}]" }
      it do
        is_expected.to eq(
          "<a href=\"#{user_image.image.url :original, false}\" rel=\"#{text_hash}\" class=\"b-image unprocessed\">\
<img src=\"#{user_image.image.url :thumbnail, false}\" \
data-width=\"#{user_image.width}\" data-height=\"#{user_image.height}\" />\
<span class=\"marker\">400x500</span></a> <a href=\"#{user_image_2.image.url :original, false}\" rel=\"#{text_hash}\" class=\"b-image unprocessed\">\
<img src=\"#{user_image_2.image.url :thumbnail, false}\" \
data-width=\"#{user_image_2.width}\" data-height=\"#{user_image_2.height}\" />\
<span class=\"marker\">1000x1000</span></a>"
        )
      end
    end

    context 'small image' do
      let(:user_image) { create :user_image, width: 249, height: 249 }
      it do
        is_expected.to eq(
          <<-HTML.squish.strip
            <span class="b-image no-zoom"><img
              src="#{user_image.image.url :original, false}" class="check-width"
            /></span>
          HTML
        )
      end

      context 'css_class' do
        let(:text) { "[image=#{user_image.id} class=abc]" }
        let(:user_image) { create :user_image, width: 249, height: 249 }

        it do
          is_expected.to eq(
            <<-HTML.squish.strip
              <span class="b-image no-zoom"><img
                src="#{user_image.image.url :original, false}" class="check-width abc"
              /></span>
            HTML
          )
        end
      end
    end

    context 'deleted image' do
      let(:text) { "[image=#{described_class::DELETED_MARKER}]" }
      it do
        is_expected.to eq(
          "<img src=\"#{described_class::DELETED_IMAGE_PATH}\" />"
        )
      end
    end

    context 'with sizes' do
      let(:user_image) { create :user_image, width: 400, height: 400 }
      let(:text) { "[image=#{user_image.id} 400x500]" }
      it do
        is_expected.to eq(
          "<a href=\"#{user_image.image.url :original, false}\" rel=\"#{text_hash}\" class=\"b-image unprocessed\">\
<img src=\"#{user_image.image.url :preview, false}\" width=\"400\" height=\"400\" \
data-width=\"#{user_image.width}\" data-height=\"#{user_image.height}\" />\
<span class=\"marker\">400x400</span></a>"
        )
      end
    end

    context 'with width' do
      let(:text) { "[image=#{user_image.id} w=400]" }
      it do
        is_expected.to eq(
          "<a href=\"#{user_image.image.url :original, false}\" rel=\"#{text_hash}\" class=\"b-image unprocessed\">\
<img src=\"#{user_image.image.url :preview, false}\" width=\"400\" \
data-width=\"#{user_image.width}\" data-height=\"#{user_image.height}\" />\
<span class=\"marker\">400x500</span></a>"
        )
      end
    end

    context 'with height' do
      let(:text) { "[image=#{user_image.id} h=400]" }
      it do
        is_expected.to eq(
          "<a href=\"#{user_image.image.url :original, false}\" rel=\"#{text_hash}\" class=\"b-image unprocessed\">\
<img src=\"#{user_image.image.url :preview, false}\" height=\"400\" \
data-width=\"#{user_image.width}\" data-height=\"#{user_image.height}\" />\
<span class=\"marker\">400x500</span></a>"
        )
      end
    end

    context 'with width&height' do
      let(:text) { "[image=#{user_image.id} w=400 h=500]" }
      it do
        is_expected.to eq(
          "<a href=\"#{user_image.image.url :original, false}\" rel=\"#{text_hash}\" class=\"b-image unprocessed\">\
<img src=\"#{user_image.image.url :preview, false}\" width=\"400\" height=\"500\" \
data-width=\"#{user_image.width}\" data-height=\"#{user_image.height}\" />\
<span class=\"marker\">400x500</span></a>"
        )
      end
    end

    context 'with class' do
      let(:text) { "[image=#{user_image.id} w=400 h=500 c=test]" }
      it do
        puts subject
        is_expected.to eq(
          "<a href=\"#{user_image.image.url :original, false}\" rel=\"#{text_hash}\" class=\"b-image unprocessed\">\
<img src=\"#{user_image.image.url :preview, false}\" class=\"test\" width=\"400\" height=\"500\" \
data-width=\"#{user_image.width}\" data-height=\"#{user_image.height}\" />\
<span class=\"marker\">400x500</span></a>"
        )
      end
    end
  end
end
