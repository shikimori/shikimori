require 'spec_helper'

describe FindAnimeParser do
  before { SiteParserWithCache.stub(:load_cache).and_return entries: {} }
  before { SiteParserWithCache.stub :save_cache }

  let(:parser) { FindAnimeParser.new }

  it { parser.fetch_pages_num.should eq 34 }
  it { parser.fetch_page_links(0).should have(FindAnimeParser::PageSize).items }

  describe :fetch_entry do
    it 'common entry' do
      entry = parser.fetch_entry 'attack_on_titan'
      entry[:id].should eq 'attack_on_titan'
      entry[:names].should eq ['Вторжение гигантов', 'Attack on Titan', 'Shingeki no Kyojin']
      entry[:russian].should eq 'Вторжение гигантов'
      entry[:score].should be_within(1).of 9
      entry[:description].should be_present
      entry[:source].should eq 'http://findanime.ru/attack_on_titan'
      entry[:episodes].should have(26).items

      entry[:episodes][0][:episode].should eq 26
      entry[:episodes][0][:url].should eq 'http://findanime.ru/attack_on_titan/series26?mature=1'
      entry[:episodes][0][:videos].should have(9).items

      entry[:episodes][0][:videos][3][:kind].should eq :dubbed
      entry[:episodes][0][:videos][3][:language].should eq :russian
      entry[:episodes][0][:videos][3][:author].should eq 'JazzWay Anime'
      #entry[:episodes][0][:videos][3][:author].should eq 'JazzWay Anime'
      entry[:episodes][0][:videos][3][:episode].should eq 26

      entry[:episodes][25][:episode].should eq 1
      entry[:episodes][25][:url].should eq 'http://findanime.ru/attack_on_titan/series1?mature=1'
      entry[:episodes][25][:videos].should have(14).items
    end
  end

  describe :extract_language do
    subject { parser.extract_language text }

    describe :английские_сабы do
      let(:text) { 'Английские сабы' }
      it { should eq :english }
    end

    describe :other do
      let(:text) { 'other' }
      it { should eq :russian }
    end
  end

  describe :extract_kind do
    subject { parser.extract_kind text }

    describe :озвучка do
      let(:text) { 'Озвучка' }
      it { should eq :dubbed }
    end

    describe :сабы do
      let(:text) { 'Сабы' }
      it { should eq :subbed }
    end

    describe :английские_сабы do
      let(:text) { 'Английские сабы' }
      it { should eq :subbed }
    end

    describe :оригинал do
      let(:text) { 'Оригинал' }
      it { should eq :raw }
    end

    describe :mismatch do
      let(:text) { 'mismatch' }
      specify { expect{subject}.to raise_error }
    end
  end

  describe :extract_url do
    subject { parser.extract_url html }

    describe :vk do
      let(:html) { "<iframe src=\"http://vk.com/video_ext.php?oid=-31193397&id=165152640&hash=924605cf891257c2&hd=1\" width=\"730\" height=\"480\" frameborder=\"0\"></iframe>" }
      it { should eq 'http://vk.com/video_ext.php?oid=-31193397&id=165152640&hash=924605cf891257c2&hd=3' }
    end

    describe :myvi do
      let(:html) { "<object style=\"height: 390px; width: 640px\"><param name=\"movie\" value=\"http://myvi.ru/player/flash/oIxbMgoWkVjUm-HHtYw1d1Gwj5xxyVdusrAmuarGU8ycjTIaeOcNlgGbGEZGhTGLE0\"><param name=\"allowFullScreen\" value=\"true\"><param name=\"allowScriptAccess\" value=\"always\"><embed src=\"http://myvi.ru/player/flash/oIxbMgoWkVjUm-HHtYw1d1Gwj5xxyVdusrAmuarGU8ycjTIaeOcNlgGbGEZGhTGLE0\" type=\"application/x-shockwave-flash\" allowfullscreen=\"true\" allowScriptAccess=\"always\" width=\"730\" height=\"480\"></object>" }
      it { should eq 'http://myvi.ru/player/flash/oIxbMgoWkVjUm-HHtYw1d1Gwj5xxyVdusrAmuarGU8ycjTIaeOcNlgGbGEZGhTGLE0' }
    end

    describe :mail_ru_short do
      let(:html) { "<iframe src=\"http://api.video.mail.ru/videos/embed/mail/bel_comp1/14985/16397.html\" width=\"730\" height=\"480\" frameborder=\"0\"></iframe>" }
      it { should eq 'http://api.video.mail.ru/videos/embed/mail/bel_comp1/14985/16397.html' }
    end

    describe :mail_ru_full do
      let(:html) { "<object classid=\"clsid:d27cdb6e-ae6d-11cf-96b8-444553540000\" width=\"730\" height=\"480\" id=\"movie_name\" align=\"middle\"><param name=\"movie\" value=\"http://my9.imgsmail.ru/r/video2/uvpv3.swf?3\"/><param name=\"flashvars\" value=\"movieSrc=mail/bel_comp1/14985/15939&autoplay=0\" /><param name=\"allowFullScreen\" value=\"true\" /><param name=\"AllowScriptAccess\" value=\"always\" /><!--[if !IE]>--><object type=\"application/x-shockwave-flash\" data=\"http://my9.imgsmail.ru/r/video2/uvpv3.swf?3\" width=\"730\" height=\"480\"><param name=\"movie\" value=\"http://my9.imgsmail.ru/r/video2/uvpv3.swf?3\"/><param name=\"flashvars\" value=\"movieSrc=mail/bel_comp1/14985/15939&autoplay=0\" /><param name=\"allowFullScreen\" value=\"true\" /><param name=\"AllowScriptAccess\" value=\"always\" /><!--<![endif]--><a href=\"http://www.adobe.com/go/getflash\"><img src=\"http://www.adobe.com/images/shared/download_buttons/get_flash_player.gif\" alt=\"Get Adobe Flash player\"/></a><!--[if !IE]>--></object><!--<![endif]--></object>" }
      it { should eq 'http://api.video.mail.ru/videos/embed/mail/bel_comp1/14985/15939.html' }
    end

    describe :rutube do
      let(:html) { "<iframe type=\"text/html\" width=\"730\" height=\"480\" src=\"http://rutube.ru/video/embed/6504640\" frameborder=\"0\"></iframe>" }
      it { should eq 'http://rutube.ru/video/embed/6504640' }
    end

    describe :sibnet do
      let(:html) { "<iframe width=\"730\" height=\"480\" src=\"http://video.sibnet.ru/shell.php?videoid=1186077\" frameborder=\"0\" scrolling=\"no\" allowfullscreen></iframe>" }
      it { should eq 'http://video.sibnet.ru/shell.php?videoid=1186077' }
    end
  end
end
