describe AniMangaDecorator do
  subject(:decorator) { anime.decorate }

  describe '#release_date_text & #release_date_tooltip' do
    let(:anime) do
      build :anime,
        status: status,
        aired_on: aired_date,
        released_on: released_date,
        season: season
    end

    let(:aired_on) { nil }
    let(:released_on) { nil }
    let(:season) { nil }

    let(:aired_date) { aired_on ? Time.zone.parse(aired_on) : nil }
    let(:released_date) { released_on ? Time.zone.parse(released_on) : nil }

    context 'no dates' do
      let(:status) { :released }
      its(:release_date_text) { is_expected.to be_nil }
      its(:release_date_tooltip) { is_expected.to be_nil }
    end

    context 'released' do
      let(:status) { :released }

      context 'aired_on & released_on' do
        let(:aired_on) { '02-02-2011' }

        context 'different years' do
          let(:released_on) { '03-03-2012' }
          its(:release_date_text) { is_expected.to eq 'в 2011-2012 гг.' }
          its(:release_date_tooltip) { is_expected.to eq 'С 2 февраля 2011 г. по 3 марта 2012 г.' }
        end

        context 'same year' do
          let(:released_on) { '03-03-2011' }
          its(:release_date_text) { is_expected.to eq 'с 2 февр. 2011 г. по 3 марта 2011 г.' }
          its(:release_date_tooltip) { is_expected.to eq 'С 2 февраля 2011 г. по 3 марта 2011 г.' }
        end
      end

      context 'released_on' do
        let(:released_on) { '03-03-2012' }

        its(:release_date_text) { is_expected.to eq '3 марта 2012 г.' }
        its(:release_date_tooltip) { is_expected.to be_nil }
      end

      context 'aired_on' do
        let(:aired_on) { '03-03-2011' }

        its(:release_date_text) { is_expected.to eq '3 марта 2011 г.' }
        its(:release_date_tooltip) { is_expected.to be_nil }
      end
    end

    context 'anons' do
      let(:status) { :anons }

      context 'aired_on & released_on' do
        let(:aired_on) { '02-02-2011' }
        let(:released_on) { '03-03-2012' }

        its(:release_date_text) { is_expected.to eq 'на 2 февр. 2011 г.' }
        its(:release_date_tooltip) { is_expected.to be_nil }
      end

      context 'released_on' do
        let(:released_on) { '03-03-2012' }

        its(:release_date_text) { is_expected.to be_nil }
        its(:release_date_tooltip) { is_expected.to be_nil }
      end

      context 'aired_on' do
        let(:aired_on) { '03-03-2012' }

        its(:release_date_text) { is_expected.to eq 'на 3 марта 2012 г.' }
        its(:release_date_tooltip) { is_expected.to be_nil }
      end

      context 'aired_on wo day' do
        let(:aired_on) { '01-03-2012' }

        its(:release_date_text) { is_expected.to eq 'на март 2012 г.' }
        its(:release_date_tooltip) { is_expected.to be_nil }
      end

      context 'aired_on wo month' do
        let(:aired_on) { '01-01-2012' }

        context 'w/o season' do
          its(:release_date_text) { is_expected.to eq 'на 2012 г.' }
          its(:release_date_tooltip) { is_expected.to be_nil }
        end

        context 'with season' do
          let(:season) { 'winter_2012' }
          its(:release_date_text) { is_expected.to eq 'на январь 2012 г.' }
          its(:release_date_tooltip) { is_expected.to be_nil }
        end
      end
    end

    context 'ongoing' do
      let(:status) { :ongoing }

      context 'aired_on & released_on' do
        let(:aired_on) { '02-02-2011' }
        let(:released_on) { '03-03-2012' }

        its(:release_date_text) { is_expected.to eq 'с 2 февр. 2011 г. по 3 марта 2012 г.' }
        its(:release_date_tooltip) { is_expected.to be_nil }
      end

      context 'released_on' do
        let(:released_on) { '03-03-2012' }

        its(:release_date_text) { is_expected.to eq 'до 3 марта 2012 г.' }
        its(:release_date_tooltip) { is_expected.to be_nil }
      end

      context 'aired_on' do
        let(:aired_on) { '03-03-2011' }

        its(:release_date_text) { is_expected.to eq 'с 3 марта 2011 г.' }
        its(:release_date_tooltip) { is_expected.to be_nil }
      end
    end
  end

  describe '#available_external_links, #menu_external_links' do
    let(:anime) do
      build_stubbed :anime,
        mal_id: mal_id,
        all_external_links: [
          external_link_1,
          external_link_2,
          external_link_3,
          external_link_4,
          external_link_5,
          external_link_6
        ]
    end
    let!(:external_link_1) do
      build_stubbed :external_link, :shikimori, :wikipedia,
        url: 'https://en.wikipedia.org/wiki/Kono_Oto_Tomare!'
    end
    let!(:external_link_2) do
      build_stubbed :external_link, kind: :smotret_anime, source: :smotret_anime
    end
    let!(:external_link_3) do
      build_stubbed :external_link, :wikipedia,
        source: :smotret_anime,
        url: 'https://en.wikipedia.org/wiki/Kono_Oto_Tomare!'
    end
    let!(:external_link_4) do
      build_stubbed :external_link, :wikipedia,
        source: :smotret_anime,
        url: 'https://ja.wikipedia.org/wiki/%E3%81%93%E3%81%AE%E9%9F%B3%E3%81%A8%E3%81%BE%E3%82%8C!c'
    end
    let!(:external_link_5) { build_stubbed :external_link, :official_site }
    let!(:external_link_6) { build_stubbed :external_link, :wakanim }

    context 'without mal_id' do
      let(:mal_id) { nil }
      its(:menu_external_links) do
        is_expected.to eq [
          external_link_5,
          external_link_1,
          external_link_4
        ]
      end
      its(:available_external_links) do
        is_expected.to eq [
          external_link_5,
          external_link_1,
          external_link_4
        ]
      end
    end

    context 'with mal_id' do
      let(:mal_id) { 123 }
      its(:menu_external_links) do
        is_expected.to eq [
          external_link_5,
          external_link_1,
          external_link_4,
          decorator.send(:mal_external_link)
        ]
      end
      its(:available_external_links) do
        is_expected.to eq [
          external_link_5,
          external_link_1,
          external_link_4,
          decorator.send(:mal_external_link)
        ]
      end
    end
  end
end
