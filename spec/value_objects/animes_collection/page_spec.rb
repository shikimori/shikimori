describe AnimesCollection::Page do
  let(:page) do
    AnimesCollection::Page.new(
      collection: [],
      page: current_page,
      pages_count: pages_count
    )
  end

  describe '#next_page & #prev_page' do
    context 'first page' do
      let(:current_page) { 1 }
      let(:pages_count) { 2 }

      it { expect(page.next_page).to eq 2 }
      it { expect(page.prev_page).to be_nil }
    end

    context 'only page' do
      let(:current_page) { 1 }
      let(:pages_count) { 1 }

      it { expect(page.next_page).to be_nil }
      it { expect(page.prev_page).to be_nil }
    end

    context 'middle page' do
      let(:current_page) { 2 }
      let(:pages_count) { 3 }

      it { expect(page.next_page).to eq 3 }
      it { expect(page.prev_page).to eq 1 }
    end

    context 'last page' do
      let(:current_page) { 2 }
      let(:pages_count) { 2 }

      it { expect(page.next_page).to be_nil }
      it { expect(page.prev_page).to eq 1 }
    end
  end
end
