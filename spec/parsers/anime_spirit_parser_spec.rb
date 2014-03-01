require 'spec_helper'

describe AnimeSpiritParser do
  let(:parser) { AnimeSpiritParser.new }

  it { parser.fetch_pages_num.should eq 389 }
  it { parser.fetch_page_links(1).should have(10).items }
  it { parser.fetch_pages(1..2).should have(20).items }

  describe :fetch_entry, :focus do
    subject(:entry) { OpenStruct.new parser.fetch_entry link }
    let(:link) { 'http://www.animespirit.ru/anime/rs/series-rus/109-slayers-rubaki.html' }

    #its(:russian) { should eq 'Рубаки' }
    #its(:name) { should eq 'Slayers' }
    #its(:year) { should eq 1995 }
    it { ap subject }
  end
end
