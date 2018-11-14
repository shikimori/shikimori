describe Neko::IsAllowed do
  subject { described_class.call anime }
  let(:anime) do
    build :anime, status, kind,
      id: id,
      franchise: franchise,
      name: name,
      english: english,
      russian: russian,
      description_en: description_en,
      description_ru: description_ru
      # duration: duration
  end
  let(:id) { nil }
  let(:status) { :released }
  let(:kind) { :tv }
  let(:name) { 'zrecap' }
  let(:franchise) { nil }
  let(:english) { nil }
  let(:russian) { nil }
  let(:description_en) { nil }
  let(:description_ru) { nil }
  # let(:duration) { Neko::IsAllowed::SHORT_DURATION + 1 }

  it { is_expected.to eq true }

  context 'anons' do
    let(:status) { :anons }
    it { is_expected.to eq false }
  end

  context 'music' do
    let(:kind) { :music }
    it { is_expected.to eq false }
  end

  # context 'extra short' do
  #   let(:duration) { Neko::IsAllowed::SHORT_DURATION }
  #   it { is_expected.to eq false }
  # end

  context 'banned in NekoRule' do
    let(:status) { :anons }
    let(:franchise) { 'gundam' }
    let(:kind) { :tv }
    let(:id) { 3963 }

    it { is_expected.to eq false }
  end

  context 'allowed in NekoRule' do
    let(:status) { :anons }
    let(:franchise) { 'gundam' }
    let(:kind) { %i[tv movie special ova].sample }
    let(:id) { 2269 }

    it { is_expected.to eq true }
  end

  context 'special/ova/movie' do
    let(:kind) { %i[special ova movie].sample }

    context 'name' do
      context 'recap' do
        let(:name) { (described_class::EN_RECAP + described_class::RU_RECAP).sample }
        it { is_expected.to eq false }
      end

      context 'not recap' do
        let(:name) { 'zxc' }
        it { is_expected.to eq true }
      end
    end

    context 'english' do
      context 'recap' do
        let(:english) { described_class::EN_RECAP.sample }
        it { is_expected.to eq false }
      end

      context 'not recap' do
        let(:english) { described_class::RU_RECAP.sample }
        it { is_expected.to eq true }
      end
    end

    context 'russian' do
      context 'recap' do
        let(:russian) { described_class::RU_RECAP.sample }
        it { is_expected.to eq false }
      end

      context 'not recap' do
        let(:russian) { described_class::EN_RECAP.sample }
        it { is_expected.to eq true }
      end
    end

    context 'recap description_en' do
      context 'recap' do
        let(:description_en) { described_class::EN_RECAP.sample }
        it { is_expected.to eq false }
      end

      context 'not recap' do
        let(:description_en) { described_class::RU_RECAP.sample }
        it { is_expected.to eq true }
      end
    end

    context 'recap description_ru' do
      context 'recap' do
        let(:description_ru) { described_class::RU_RECAP.sample }
        it { is_expected.to eq false }
      end

      context 'not recap' do
        let(:description_ru) { described_class::EN_RECAP.sample }
        it { is_expected.to eq true }
      end
    end
  end
end
