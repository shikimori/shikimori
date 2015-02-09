describe I18n do
  describe '::time_part' do
    describe 'second' do
      it { expect(I18n.time_part 1, :second).to eq '1 секунда' }
      it { expect(I18n.time_part 2, :second).to eq '2 секунды' }
      it { expect(I18n.time_part 5, :second).to eq '5 секунд' }
    end

    describe 'minute' do
      it { expect(I18n.time_part 1, :minute).to eq '1 минута' }
      it { expect(I18n.time_part 2, :minute).to eq '2 минуты' }
      it { expect(I18n.time_part 5, :minute).to eq '5 минут' }
    end

    describe 'hour' do
    it { expect(I18n.time_part 1, :hour).to eq '1 час' }
    it { expect(I18n.time_part 2, :hour).to eq '2 часа' }
    it { expect(I18n.time_part 5, :hour).to eq '5 часов' }
    end

    describe 'day' do
      it { expect(I18n.time_part 1, :day).to eq '1 день' }
      it { expect(I18n.time_part 2, :day).to eq '2 дня' }
      it { expect(I18n.time_part 5, :day).to eq '5 дней' }
    end

    describe 'week' do
      it { expect(I18n.time_part 1, :week).to eq '1 неделя' }
      it { expect(I18n.time_part 2, :week).to eq '2 недели' }
      it { expect(I18n.time_part 5, :week).to eq '5 недель' }
    end

    describe 'month' do
      it { expect(I18n.time_part 1, :month).to eq '1 месяц' }
      it { expect(I18n.time_part 2, :month).to eq '2 месяца' }
      it { expect(I18n.time_part 5, :month).to eq '5 месяцев' }
    end

    describe 'year' do
      it { expect(I18n.time_part 1, :year).to eq '1 год' }
      it { expect(I18n.time_part 2, :year).to eq '2 года' }
      it { expect(I18n.time_part 5, :year).to eq '5 лет' }
    end
  end
end
