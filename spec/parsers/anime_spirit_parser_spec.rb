require 'spec_helper'

describe AnimeSpiritParser do
  let(:parser) { AnimeSpiritParser.new }

  it { parser.fetch_pages_num.should eq 389 }
  it { parser.fetch_page_links(1).should have(10).items }
  it { parser.fetch_pages(1..1).should have(10).items }

  describe :fetch_entry do
    subject(:entry) { OpenStruct.new parser.fetch_entry link }
    context :slayers do
      let(:link) { 'http://www.animespirit.ru/anime/rs/series-rus/109-slayers-rubaki.html' }

      its(:russian) { should eq 'Рубаки' }
      its(:name) { should eq 'Slayers' }
      its(:year) { should eq 1995 }
      its(:videos) { should have(26).items }

      specify { subject[:videos].all? {|v| v[:url].present? }.should be true }

      context :video do
        subject { OpenStruct.new entry[:videos].first }
        its(:episode) { should eq 1 }
        its(:source) { should eq link }
        its(:url) { 'http://video.rutube.ru/cdc409fc58ac4ac357c98ae47d519208' }
        its(:kind) { should eq :unknown }
        its(:author) { should be nil }
      end
    end

    context :binbougami do
      let(:link) { 'http://www.animespirit.ru/anime/rs/series-rus/7837-nishhebog-zhe-binbougami-ga.html' }

      its(:russian) { should eq 'Нищебог же!' }
      its(:name) { should eq 'Binbougami ga!' }
      its(:year) { should eq 2012 }
      its(:videos) { should have(52).items }

      specify { subject[:videos].all? {|v| v[:url].present? }.should be true }

      context :video do
        context :first do
          subject { OpenStruct.new entry[:videos].first }

          its(:episode) { should eq 1 }
          its(:source) { should eq link }
          its(:url) { should eq 'http://myvi.ru/ru/flash/player/pre/oSTs693yvbob77Dom0Toa_b5OpvotLMAYhUh18hYP2b0euHBvbNKtSE2BVqVmcTiO0' }
          its(:kind) { should eq :subtitles }
          its(:author) { should be nil }
        end

        context :last do
          subject { OpenStruct.new entry[:videos].last }
          its(:author) { should be nil }
          its(:episode) { should eq 13 }
          its(:kind) { should eq :fandub }
          its(:url) { should eq 'http://video.sibnet.ru/shell.swf?videoid=710879' }
        end
      end
    end

    context :angel_beats do
      let(:link) { 'http://www.animespirit.ru/anime/rs/series-rus/2406-angel-beats-mgnoveniya-angelov.html' }
      its(:russian) { should eq 'Ангельские Ритмы!' }
      its(:name) { should eq 'Angel Beats!' }
      its(:year) { should eq 2010 }
      its(:videos) { should have(130).items }

      specify { subject[:videos].all? {|v| v[:url].present? }.should be true }
    end
  end
end
