require 'spec_helper'

#'image with class' => [
  #/\[img class=([\w-]+)\](.*?)\[\/img\]/mi,
  #'<img class="\1" src="\2" />',
  #'Image tag with class',
  #'[img class=test]link_to_image[/img]',
  #:image_with_class
#],
#'Image (Alternative)' => [
  #/\[img=([^\[\]].*?)\.(#{@@imageformats})\]/im,
  #'<img src="\1.\2" alt="" class="check-width" />',
  #'Display an image (alternative format)', 
  #'[img=http://myimage.com/logo.gif]',
  #:img],
#'Image' => [
  #/\[img(:.+)?\]([^\[\]].*?)\.(#{@@imageformats})\[\/img\1?\]/im,
  #'<img src="\2.\3" alt="" class="check-width" />',
  #'Display an image',
  #'Check out this crazy cat: [img]http://catsweekly.com/crazycat.jpg[/img]',
  #:img],


describe BbCodes::ImgTag do
  let(:tag) { BbCodes::ImgTag.instance }
  let(:text_hash) { 'hash' }

  describe :format do
    subject { tag.format text, text_hash }
    let(:url) { 'http://site.com/site-url' }
    let(:text) { "[img]#{url}[/img]" }

    context :common_case do
      it { should eq "<a href=\"#{url}\" rel=\"#{text_hash}\"><img src=\"#{url}\" class=\"check-width\"/></a>" }
    end

    context :multiple_images do
      let(:url_2) { 'http://site.com/site-url-2' }
      let(:text) { "[img]#{url}[/img] [img]#{url_2}[/img]" }
      it { should eq "<a href=\"#{url}\" rel=\"#{text_hash}\"><img src=\"#{url}\" class=\"check-width\"/></a> <a href=\"#{url_2}\" rel=\"#{text_hash}\"><img src=\"#{url_2}\" class=\"check-width\"/></a>" }
    end

    context :with_sizes do
      let(:text) { "[img 400x500]#{url}[/img]" }
      it { should eq "<a href=\"#{url}\" rel=\"#{text_hash}\"><img src=\"#{url}\" class=\"check-width\" width=\"400\" height=\"500\"/></a>" }
    end

    context :with_width do
      let(:text) { "[img w=400]#{url}[/img]" }
      it { should eq "<a href=\"#{url}\" rel=\"#{text_hash}\"><img src=\"#{url}\" class=\"check-width\" width=\"400\"/></a>" }
    end

    context :with_height do
      let(:text) { "[img h=500]#{url}[/img]" }
      it { should eq "<a href=\"#{url}\" rel=\"#{text_hash}\"><img src=\"#{url}\" class=\"check-width\" height=\"500\"/></a>" }
    end

    context 'with width&height' do
      let(:text) { "[img width=400 height=500]#{url}[/img]" }
      it { should eq "<a href=\"#{url}\" rel=\"#{text_hash}\"><img src=\"#{url}\" class=\"check-width\" width=\"400\" height=\"500\"/></a>" }
    end

    context :with_class do
      let(:text) { "[img class=zxc]#{url}[/img]" }
      it { should eq "<a href=\"#{url}\" rel=\"#{text_hash}\"><img src=\"#{url}\" class=\"check-width zxc\"/></a>" }
    end
  end
end
