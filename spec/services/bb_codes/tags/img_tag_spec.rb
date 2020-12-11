describe BbCodes::Tags::ImgTag do
  subject { described_class.instance.format text, text_hash }

  let(:text_hash) { 'hash' }
  let(:image_url) { 'http://site.com/site-url' }
  let(:text) { "[img]#{escaped_image_url}[/img]" }
  let(:camo_url) { UrlGenerator.instance.camo_url image_url }
  let(:attrs) { { src: image_url } }

  let(:escaped_image_url) { ERB::Util.h image_url }
  let(:escaped_image_url_2) { ERB::Util.h image_url_2 }
  let(:escaped_link_url) { ERB::Util.h link_url }

  context 'common case' do
    it do
      is_expected.to eq(
        <<-HTML.squish.strip
          <a href='#{escaped_image_url}'
            data-href='#{camo_url}'
            rel='#{text_hash}'
            class='b-image unprocessed'
            data-attrs='#{attrs.to_json}'><img
              src='#{camo_url}'
              class='check-width'
              loading='lazy'></a>
        HTML
      )
    end
  end

  context 'no-zoom' do
    let(:text) { "[img no-zoom]#{image_url}[/img]" }
    it do
      is_expected.to eq(
        <<-HTML.squish.strip
          <span class='b-image no-zoom'
            data-attrs='#{attrs.to_json}'><img src='#{camo_url}'
            class='check-width' loading='lazy'></span>
        HTML
      )
    end
  end

  context 'multiple images' do
    let(:image_url_2) { 'http://site.com/site-url-2' }
    let(:text) { "[img]#{image_url}[/img] [img]#{image_url_2}[/img]" }
    let(:camo_url_2) { UrlGenerator.instance.camo_url image_url_2 }
    let(:attrs_2) { { src: image_url_2 } }

    it do
      is_expected.to eq(
        <<~HTML.squish
          <a
            href='#{escaped_image_url}'
            data-href='#{camo_url}'
            rel='#{text_hash}'
            class='b-image unprocessed'
            data-attrs='#{attrs.to_json}'><img
              src='#{camo_url}'
              class='check-width'
              loading='lazy'></a>
            <a
              href='#{escaped_image_url_2}'
              data-href='#{camo_url_2}'
              rel='#{text_hash}'
              class='b-image unprocessed'
              data-attrs='#{attrs_2.to_json}'><img
                src='#{camo_url_2}'
                class='check-width'
                loading='lazy'></a>
        HTML
      )
    end
  end

  context 'with sizes' do
    let(:text) { "[img 400x500]#{image_url}[/img]" }
    it { is_expected.to include "width='400' height='500' loading='lazy'></a>" }
  end

  context 'with width' do
    let(:text) { "[img w=400]#{image_url}[/img]" }
    it { is_expected.to include "width='400' loading='lazy'></a>" }
  end

  context 'with height' do
    let(:text) { "[img h=500]#{image_url}[/img]" }
    it { is_expected.to include "height='500' loading='lazy'></a>" }
  end

  context 'with width&height' do
    let(:text) { "[img width=400 height=500]#{image_url}[/img]" }
    it { is_expected.to include "width='400' height='500' loading='lazy'></a>" }
  end

  context 'with class' do
    let(:text) { "[img class=zxc]#{image_url}[/img]" }
    it { is_expected.to include "class='b-image unprocessed zxc'" }
  end

  context 'inside url' do
    let(:text) { "[url=#{link_url}][img]#{image_url}[/img][/url]" }

    context 'normal link' do
      let(:link_url) { '/test' }
      it do
        is_expected.to eq(
          <<~HTML.squish
            <a
              href='#{escaped_link_url}'
              data-href='#{camo_url}'
              rel='hash'#{' '}
              class='b-image unprocessed'
              data-attrs='#{attrs.to_json}'><img
                src='#{camo_url}'
                class='check-width'
                loading='lazy'></a>
          HTML
        )
      end
    end

    context 'link to shiki image' do
      let(:link_url) { 'http://shikimori.test/test.jpg' }
      let(:camo_link_url) { UrlGenerator.instance.camo_url link_url }

      it do
        is_expected.to eq(
          <<~HTML.squish
            <a
              href='#{escaped_link_url}'
              data-href='#{camo_link_url}'
              rel='hash'
              class='b-image unprocessed'
              data-attrs='#{attrs.to_json}'><img
                src='#{camo_url}'
                class='check-width'
                loading='lazy'></a>
          HTML
        )
      end
    end
  end
end
