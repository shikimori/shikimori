require 'spec_helper'

describe DanbooruImporter do
  let(:limit) { 2 }
  let(:importer) { DanbooruImporter.new }
  subject(:import) { DanbooruImporter.new.import limit }

  it { expect{import}.to change(DanbooruTag, :count).by(limit * 1000) }

  describe 'import only new tags' do
    before { import}
    it { expect{importer.import limit + 1}.to change(DanbooruTag, :count).by(999) }
  end
end
