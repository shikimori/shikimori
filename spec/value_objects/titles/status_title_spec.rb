describe Titles::StatusTitle do
  let(:title) { Titles::StatusTitle.new status, Anime }

  describe 'ongoing' do
    let(:status) { :ongoing }

    it { expect(title.text).to eq 'ongoing' }
    it { expect(title.url_params).to eq season: nil, status: 'ongoing', kind: nil }
    it { expect(title.catalog_title).to eq 'Сейчас выходит' }
    it { expect(title.short_title).to eq 'Онгоинги' }
    it { expect(title.full_title).to eq 'Онгоинги аниме' }
  end

  describe 'anons' do
    let(:status) { :anons }

    it { expect(title.catalog_title).to eq 'Анонсировано' }
    it { expect(title.short_title).to eq 'Анонсы' }
    it { expect(title.full_title).to eq 'Анонсы аниме' }
  end

  describe 'released' do
    let(:status) { :released }

    it { expect(title.catalog_title).to eq 'Вышедшее' }
    it { expect(title.short_title).to eq 'Вышедшее' }
    it { expect(title.full_title).to eq 'Вышедшие аниме' }
  end

  describe 'lates' do
    let(:status) { :latest }

    it { expect(title.catalog_title).to eq 'Недавно вышедшее' }
    it { expect(title.short_title).to eq 'Недавно вышедшее' }
    it { expect(title.full_title).to eq 'Недавно вышедшие аниме' }
  end
end
