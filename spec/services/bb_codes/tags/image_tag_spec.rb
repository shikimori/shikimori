describe BbCodes::Tags::ImageTag do
  include_context :timecop, '2015-03-01T20:53:13.183710+03:00'

  subject { described_class.instance.format text, text_hash }
  let(:text_hash) { 'hash' }

  let(:text) { "[image=#{user_image.id}]" }
  let(:user_image) { create :user_image, width: 400, height: 500 }

  let(:attrs) do
    {
      id: user_image.id,
      width: (width if defined? width),
      height: (height if defined? height),
      isNoZoom: (is_no_zoom if defined? is_no_zoom),
      class: (css_class if defined? css_class)
    }.compact
  end

  context 'common case' do
    it do
      is_expected.to eq(
        <<-HTML.squish.strip
            <a href='#{user_image.image.url :original, false}'
              rel='#{text_hash}'
              class='b-image unprocessed'
              data-attrs='#{ERB::Util.h attrs.to_json}'><img
                src='#{user_image.image.url :thumbnail, false}'
                data-width='#{user_image.width}'
                data-height='#{user_image.height}'
                loading='lazy'
                /><span class='marker'><span class='marker-text'>400x500</span></span></a>
        HTML
      )
    end
  end

  context 'no zoom' do
    let(:text) { "[image=#{user_image.id} no-zoom]" }
    let(:is_no_zoom) { true }

    it do
      is_expected.to eq(
        <<-HTML.squish.strip
            <span class='b-image no-zoom'
              data-attrs='#{ERB::Util.h attrs.to_json}'><img
                src='#{user_image.image.url :original, false}'
                class='check-width'
                loading='lazy'
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
        <<-HTML.squish.strip
          <a
            href='#{user_image.image.url :original, false}'
            rel='#{text_hash}'
            class='b-image unprocessed'
            data-attrs='#{ERB::Util.h attrs.to_json}'><img
              src='#{user_image.image.url :thumbnail, false}'
              data-width='#{user_image.width}'
              data-height='#{user_image.height}'
              loading='lazy'
              /><span class='marker'><span class='marker-text'>400x500</span></span></a>
          <a
            href='#{user_image_2.image.url :original, false}'
            rel='#{text_hash}'
            class='b-image unprocessed'
            data-attrs='#{ERB::Util.h({ id: user_image_2.id }.to_json)}'><img
              src='#{user_image_2.image.url :thumbnail, false}'
              data-width='#{user_image_2.width}'
              data-height='#{user_image_2.height}'
              loading='lazy'
              /><span class='marker'><span class='marker-text'>1000x1000</span></span></a>
        HTML
      )
    end
  end

  context 'small image' do
    let(:user_image) { create :user_image, width: 249, height: 249 }
    let(:is_no_zoom) { true }

    it do
      is_expected.to eq(
        <<-HTML.squish
          <span class='b-image no-zoom'
            data-attrs='#{ERB::Util.h attrs.to_json}'><img
              src='#{user_image.image.url :original, false}'
              class='check-width'
              loading='lazy'
              /></span>
        HTML
      )
    end

    context 'css_class' do
      let(:text) { "[image=#{user_image.id} class=#{css_class}]" }
      let(:user_image) { create :user_image, width: 249, height: 249 }
      let(:css_class) { 'abc' }

      it do
        is_expected.to eq(
          <<-HTML.squish
            <span class='b-image no-zoom abc'
              data-attrs='#{ERB::Util.h attrs.to_json}'><img
                src='#{user_image.image.url :original, false}'
                class='check-width'
                loading='lazy'
                /></span>
          HTML
        )
      end
    end
  end

  context 'deleted image' do
    let(:text) { "[image=#{described_class::DELETED_MARKER}]" }
    it { is_expected.to eq described_class::DELETED_IMAGE_HTML }
  end

  context 'not found image' do
    let(:text) { '[image=1234677]' }

    it do
      is_expected.to eq(
        "<span class='b-entry-404'><del>#{text}</del></span>"
      )
    end
  end

  context 'with sizes' do
    let(:user_image) { create :user_image, width: 400, height: 400 }
    let(:text) { "[image=#{user_image.id} #{width}x#{height}]" }

    let(:width) { 400 }
    let(:height) { 400 }

    it do
      is_expected.to eq(
        <<-HTML.squish
          <a
            href='#{user_image.image.url :original, false}'
            rel='#{text_hash}'
            class='b-image unprocessed'
            data-attrs='#{ERB::Util.h attrs.to_json}'><img
              src='#{user_image.image.url :preview, false}'
              width='400'
              height='400'
              data-width='#{user_image.width}'
              data-height='#{user_image.height}'
              loading='lazy'
              /><span class='marker'><span class='marker-text'>400x400</span></span></a>
        HTML
      )
    end

    context 'keeps aspect ratio' do
      let(:height) { 500 }

      it do
        is_expected.to eq(
          <<-HTML.squish
            <a
              href='#{user_image.image.url :original, false}'
              rel='#{text_hash}'
              class='b-image unprocessed'
              data-attrs='#{ERB::Util.h({ **attrs, height: 400 }.to_json)}'><img
                src='#{user_image.image.url :preview, false}'
                width='400'
                height='400'
                data-width='#{user_image.width}'
                data-height='#{user_image.height}'
                loading='lazy'
                /><span class='marker'><span class='marker-text'>400x400</span></span></a>
          HTML
        )
      end
    end
  end

  context 'with width' do
    let(:text) { "[image=#{user_image.id} w=400]" }
    let(:width) { 400 }

    it do
      is_expected.to eq(
        <<-HTML.squish
          <a
            href='#{user_image.image.url :original, false}'
            rel='#{text_hash}'
            class='b-image unprocessed'
            data-attrs='#{ERB::Util.h attrs.to_json}'><img
              src='#{user_image.image.url :preview, false}'
              width='400'
              data-width='#{user_image.width}'
              data-height='#{user_image.height}'
              loading='lazy'
              /><span class='marker'><span class='marker-text'>400x500</span></span></a>
        HTML
      )
    end
  end

  context 'with height' do
    let(:text) { "[image=#{user_image.id} h=#{height}]" }
    let(:height) { 400 }

    it do
      is_expected.to eq(
        <<-HTML.squish
          <a href='#{user_image.image.url :original, false}'
            rel='#{text_hash}'
            class='b-image unprocessed'
            data-attrs='#{ERB::Util.h attrs.to_json}'><img
              src='#{user_image.image.url :preview, false}'
              height='400'
              data-width='#{user_image.width}'
              data-height='#{user_image.height}'
              loading='lazy'
              /><span class='marker'><span class='marker-text'>400x500</span></span></a>
        HTML
      )
    end
  end

  context 'with width&height' do
    let(:text) { "[image=#{user_image.id} w=#{width} h=#{height}]" }
    let(:width) { 400 }
    let(:height) { 500 }

    it do
      is_expected.to eq(
        <<-HTML.squish
          <a
            href='#{user_image.image.url :original, false}'
            rel='#{text_hash}'
            class='b-image unprocessed'
            data-attrs='#{ERB::Util.h attrs.to_json}'><img
              src='#{user_image.image.url :preview, false}'
              width='400'
              height='500'
              data-width='#{user_image.width}'
              data-height='#{user_image.height}'
              loading='lazy'
              /><span class='marker'><span class='marker-text'>400x500</span></span></a>
        HTML
      )
    end
  end

  context 'with class' do
    let(:text) { "[image=#{user_image.id} w=#{width} h=#{height} c=#{css_class}]" }
    let(:width) { 400 }
    let(:height) { 500 }
    let(:css_class) { 'test' }

    it do
      is_expected.to eq(
        <<-HTML.squish
          <a
            href='#{user_image.image.url :original, false}'
            rel='#{text_hash}'
            class='b-image unprocessed test'
            data-attrs='#{ERB::Util.h attrs.to_json}'><img
              src='#{user_image.image.url :preview, false}'
              width='400'
              height='500'
              data-width='#{user_image.width}'
              data-height='#{user_image.height}'
              loading='lazy'
              /><span class='marker'><span class='marker-text'>400x500</span></span></a>
        HTML
      )
    end
  end
end
