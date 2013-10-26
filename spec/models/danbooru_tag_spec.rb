require 'spec_helper'

describe DanbooruTag do
  let(:limit) { 3 }

  it 'imports all found tags' do
    expect {
      DanbooruTag.import_from_danbooru(limit)
    }.to change(DanbooruTag, :count).by(3000)
  end

  it 'imports only new tags' do
    DanbooruTag.import_from_danbooru(limit)
    expect {
      DanbooruTag.import_from_danbooru(limit+1)
    }.to change(DanbooruTag, :count).by(1000)
  end
end
