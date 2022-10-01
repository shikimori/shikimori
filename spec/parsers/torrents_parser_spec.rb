describe TorrentsParser do
  describe '#extract_episodes_num' do
    subject { TorrentsParser.extract_episodes_num name }

    describe 'is_expected.to match common cases' do
      it { expect(TorrentsParser.extract_episodes_num('[Local-Raws] Bakuman 11 RAW (1280x720 x264 AAC NHKE).mp4')).to eq [11] }
      it { expect(TorrentsParser.extract_episodes_num('[Leopard-Raws] Bakuman. - 11 RAW (NHKE 1280x720 x264 AAC).mp4')).to eq [11] }
      it { expect(TorrentsParser.extract_episodes_num('[Leopard-Raws] Bakuman. - 11 RAW (NHKE 1920x1200 x264 AAC).mp4')).to eq [11] }
      it { expect(TorrentsParser.extract_episodes_num('[Local-Ras] ONE PIECE 470 RAW (1280x720 x264 AAC 30fps uhb).mp4')).to eq [470] }
      it { expect(TorrentsParser.extract_episodes_num('[GRUNNRAW] Heartcatch Precure! - 43 (EX 1280x720 x264).mp4')).to eq [43] }
      it { expect(TorrentsParser.extract_episodes_num('[Leopard-Raws] MM! - 11 RAW (ATX 1280x720 x264 AAC).mp4')).to eq [11] }
      it { expect(TorrentsParser.extract_episodes_num('Tanoshii Moomin Ikka 07 (DVD 640x480 x264 AAC).mp4')).to eq [7] }
      it { expect(TorrentsParser.extract_episodes_num('[ReinForce] Amagami SS - 23 (TBS 1280x720 x264 AAC).mkv')).to eq [23] }
      it { expect(TorrentsParser.extract_episodes_num('[Ritsuka] Bakuman - 07 (NHK-E 1280x720 x264 AAC).mp4')).to eq [7] }
      it { expect(TorrentsParser.extract_episodes_num('[BSS]_Mobile_Suit_Gundam_Unicorn_-_02_[720p][E05AEDDD].mkv')).to eq [2] }
      it { expect(TorrentsParser.extract_episodes_num('[Coalgirls]_Mobile_Suit_Gundam_Unicorn_02_(1280x720_Blu-Ray_FLAC)_[6BD5CB24].mkv')).to eq [2] }
      it { expect(TorrentsParser.extract_episodes_num('[QTS] Mobile Suit Gundam Unicorn Vol.1 (BD H264 1280x720 24fps AAC 2.0J+2.0E).mkv')).to eq [1] }
      it { expect(TorrentsParser.extract_episodes_num('[ReinForce] Tegami Bachi REVERSE - 10 (TX 1280x720 x264 AAC).mkv')).to eq [10] }
      it { expect(TorrentsParser.extract_episodes_num('[Yousei-raws] Tales of Symphonia - Tethe`alla Hen Vol.1-2 [DVDrip 848x480 x264 FLAC].mkv')).to eq [1, 2] }
      it { expect(TorrentsParser.extract_episodes_num('[Yousei-raws] Tales of Symphonia - Tethe`alla Hen Vol.1-3 [DVDrip 848x480 x264 FLAC].mkv')).to eq [1, 2, 3] }
      it { expect(TorrentsParser.extract_episodes_num('[BadRaws]Tales of Symphonia The Animation Tethealla Hen 3 (DVD NTSC H.264 FLAC).mkv')).to eq [3] }
      it { expect(TorrentsParser.extract_episodes_num('[inshuheki] Bakuman 03 [720p][6ABBCC13].mkv')).to eq [3] }
      it { expect(TorrentsParser.extract_episodes_num('[TV-Japan] NARUTO Shippuuden - 192 Raw [1280x720 h264+AAC D-TX].mp4')).to eq [192] }
      it { expect(TorrentsParser.extract_episodes_num('TV-Japan] Bleach - 302 [1280x720 h264+AAC D-TX].mkv')).to eq [302] }
      it { expect(TorrentsParser.extract_episodes_num('[Animworld.com] One Piece 481 - RAW [480p] [H.264] [MP3].mp4')).to eq [481] }
      it { expect(TorrentsParser.extract_episodes_num('Detective Conan 593-595, 598 RAW 720р')).to eq [593, 594, 595, 598] }
      it { expect(TorrentsParser.extract_episodes_num("[KOP-Raw's] Detective Conan 591-593 (1600x900 x264 ac3 24fps avi)")).to eq [591, 592, 593] }
      it { expect(TorrentsParser.extract_episodes_num('[sage]_Sekaiichi_Hatsukoi_2_-_07_[720p][10bit][E5CC0581].mkv')).to eq [7] }
      it { expect(TorrentsParser.extract_episodes_num('[OPC-Raws]_One_Piece_556_[CX_1280x720_VFR_H264_AAC]_[F8F6F8A2].mp4')).to eq [556] }
      it { expect(TorrentsParser.extract_episodes_num('[OPC-Raws]_One_Piece_556_[D-CX_1280x720_VFR_H264_AAC]_[F8F6F8A2].mp4')).to eq [556] }
      it { expect(TorrentsParser.extract_episodes_num('[Leopard-Raws] Panty & Stocking with Garterbelt - 01 RAW (BS4 1280x720 x264 AAC).mp4')).to eq [1] }
      it { expect(TorrentsParser.extract_episodes_num('[Sena-Raws] Teekyuu 2 - 04 (AT-X HD! 1280x720 x264 AAC).mp4')).to eq [4] }
      it { expect(TorrentsParser.extract_episodes_num('[SSA] Detective Conan - 1006 [480p].mkv')).to eq [1006] }
    end

    it 'last episodes' do
      expect(TorrentsParser.extract_episodes_num('[Leopard-Raws] Kuroshitsuji II - 12 END (MBS 1280x720 x264 AAC).mp4')).to eq [12]
      expect(TorrentsParser.extract_episodes_num('[Leopard-Raws] MM! - 12 END (MBS 1280x720 x264 AAC).mp4')).to eq [12]
    end

    it 'match wrong cases' do
      expect(TorrentsParser.extract_episodes_num('[Leopard-Raws] Ore no Imouto ga Konna ni Kawaii Wake ga Nai OP9 (MX 1280x720 x264).mp4')).to eq []
    end

    it 'too big numbers' do
      expect(TorrentsParser.extract_episodes_num('[Leopard-Raws] Anime 999 (MBS 1280x720 x264 AAC).mp3')).to eq [999]
      expect(TorrentsParser.extract_episodes_num('[Leopard-Raws] Anime 2001 (MBS 1280x720 x264 AAC).mp3')).to eq []
    end

    it 'gintama' do
      expect(TorrentsParser.extract_episodes_num('[Leopard-Raws] gintama 253 (MBS 1280x720 x264 AAC).mp3')).to eq [253]
      expect(TorrentsParser.extract_episodes_num('[Leopard-Raws] gintama 250 (MBS 1280x720 x264 AAC).mp3')).to eq [250]
    end

    describe 'episodes with #' do
      let(:name) { '[Leopard-Raws] Bakuman #12 (MBS 1280x720 x264 AAC).mp4' }
      it { is_expected.to eq [12] }
    end

    describe 'episodes with data hash only' do
      let(:name) { '[WhyNot] Phi Brain - Kami no Puzzle S2 - 13 [1ED5F495].mkv' }
      it { is_expected.to eq [13] }
    end

    describe 'names with rev2' do
      let(:name) { '[Raws-4U] Bounen no Xamdou - 01 rev2 (PSN 1920x1080 x264 AAC 5.1ch).mp4' }
      it { is_expected.to eq [1] }
    end

    describe '~ and other symbols' do
      let(:name) { '[Winter] Mashiro-iro Symphony ~The Color of Lovers~ 99 [BDrip 1280x720 x264 Vorbis].mkv' }
      it { is_expected.to eq [99] }
    end

    describe 'without brackets at end' do
      let(:name) { '[Raws] Chousoku Henkei Gyrozetter - 22.mp4' }
      it { is_expected.to eq [22] }
    end

    describe 'with long dash at end of name' do
      let(:name) { '[Mezashite] Aikatsu! ‒ 101 [6936887B].mkv' }
      it { is_expected.to eq [101] }
    end

    describe 'name with brackets' do
      let(:name) { '[HorribleSubs] Rozen Maiden (2013) - 01 [720p].mkv' }
      it { is_expected.to eq [1] }
    end

    describe 'season 2' do
      let(:name) { '[HorribleSubs] Rozen Maiden 2 - 01 [720p].mkv' }
      it { is_expected.to eq [1] }

      describe 'with year' do
        let(:name) { '[HorribleSubs] Rozen Maiden 2 (2013) - 01 [720p].mkv' }
        it { is_expected.to eq [1] }
      end
    end

    describe 'name with plus' do
      let(:name) { '[Ohys-Raws] Sin Strange+ - 02 (AT-X 1280x720 x264 AAC).mp4' }
      it { is_expected.to eq [2] }
    end

    describe 'episode num after "ch-"' do
      let(:name) { '[kingtqi-Raws] Saikyou Ginga Ultimate Zero - Battle Spirits CH-04 (ABC 1280x720 x264 AAC).mp4' }
      it { is_expected.to eq [4] }
    end

    describe 'episode num with zero' do
      let(:name) { '[SubDESU] Shijou Saikyou no Deshi Kenichi OVA - 05v0 (640x360 x264 AAC) [8D5C93AE].mp4' }
      it { is_expected.to eq [5] }
    end

    # describe 'episode with part' do
    #   let(:name) { '[BakedFish] Re:Zero kara Hajimeru Isekai Seikatsu - 01 - Part 2 [720p][AAC].mp4' }
    #   it { is_expected.to eq [1] }
    # end

    context 'episode with year' do
      let(:name) { '[Ohys-Raws] Shingeki no Kyojin Season 3 (2019) - 05 (NHKG 1280x720 x264 AAC).mp4' }
      it { is_expected.to eq [5] }
    end

    describe 'multiple episodes' do
      let(:name) { '[HorribleSubs] Tsukimonogatari - (01-04) [1080p].mkv' }
      it { is_expected.to eq [1, 2, 3, 4] }
    end

    describe 'ignored phrases' do
      context 'full match' do
        let(:name) { '[Local-Raws] Flying Witch Petit 11 RAW (1280x720 x264 AAC NHKE).mp4' }
        it { is_expected.to eq [] }
      end

      context 'partial match' do
        let(:name) { '[Local-Raws] Flying Witch 11 RAW (1280x720 x264 AAC NHKE).mp4' }
        it { is_expected.to eq [11] }
      end
    end

    describe 'additional number in brackets' do
      let(:name) { '[Leopard-Raws] Rewrite 2nd Season - Moon Hen, Terra Hen - 05 (18) RAW (BS11 1280x720 x264 AAC).mp4' }
      it { is_expected.to eq [5] }
    end
  end

  describe '#check_aired_episodes' do
    let(:episodes_aired) { 1 }
    let(:episodes) { 24 }
    let(:anime) do
      create :anime,
        episodes_aired: episodes_aired,
        episodes: episodes,
        status: :ongoing
    end
    let(:multiplier) { Shikimori::DOMAIN_LOCALES.size }

    subject { TorrentsParser.check_aired_episodes anime, feed }

    describe 'episode' do
      let(:feed) { [{ title: '[QTS] Mobile Suit Gundam Unicorn Vol.2 (BD H264 1280x720 24fps AAC 5.1J+5.1E).mkv' }] }

      it do
        expect { subject }.to change(Topics::NewsTopic, :count).by(1)
        expect(anime.reload.episodes_aired).to eq 2
      end
    end

    describe 'few episodes' do
      let(:feed) do
        [
          { title: '[QTS] Mobile Suit Gundam Unicorn Vol.3 (BD H264 1280x720 24fps AAC 5.1J+5.1E).mkv' },
          { title: '[QTS] Mobile Suit Gundam Unicorn Vol.2 (BD H264 1280x720 24fps AAC 5.1J+5.1E).mkv' },
          { title: '[QTS] Mobile Suit Gundam Unicorn Vol.4 (BD H264 1280x720 24fps AAC 5.1J+5.1E).mkv' }
        ]
      end

      it do
        expect { subject }.to change(Topics::NewsTopic, :count).by 3
        expect(anime.reload.episodes_aired).to eq 4
      end
    end

    describe 'interval with next episode' do
      let(:feed) { [{ title: '[QTS] Mobile Suit Gundam Unicorn Vol.2-6 (BD H264 1280x720 24fps AAC 5.1J+5.1E).mkv' }] }

      it do
        expect { subject }.to change(Topics::NewsTopic, :count).by 5
        expect(anime.episodes_aired).to eq 6
      end
    end

    describe 'interval not intersect' do
      let(:feed) { [{ title: '[QTS] Mobile Suit Gundam Unicorn Vol.3-6 (BD H264 1280x720 24fps AAC 5.1J+5.1E).mkv' }] }

      it do
        expect { subject }.to change(Topics::NewsTopic, :count).by 0
        expect(anime.reload.episodes_aired).to eq episodes_aired
      end
    end

    describe 'interval intersect' do
      let(:episodes_aired) { 5 }
      let(:feed) { [{ title: '[QTS] Mobile Suit Gundam Unicorn Vol.2-6 (BD H264 1280x720 24fps AAC 5.1J+5.1E).mkv' }] }

      it do
        expect { subject }.to change(Topics::NewsTopic, :count).by 1
        expect(anime.reload.episodes_aired).to eq 6
      end
    end

    describe 'episodes limit' do
      let(:feed) { [{ title: '[QTS] Mobile Suit Gundam Unicorn Vol.6-15 (BD H264 1280x720 24fps AAC 5.1J+5.1E).mkv' }] }

      context 'too many' do
        let(:episodes_aired) { 5 }
        it do
          expect { subject }.to_not change Topics::NewsTopic, :count
          expect(anime.reload.episodes_aired).to eq 5
        end
      end

      context 'not too many' do
        let(:episodes_aired) { 6 }
        it do
          expect { subject }.to change(Topics::NewsTopic, :count).by 9
          expect(anime.reload.episodes_aired).to eq 15
        end
      end
    end

    describe 'wrong episode number' do
      let(:feed) { [{ title: '[QTS] Mobile Suit Gundam Unicorn Vol.3 (BD H264 1280x720 24fps AAC 5.1J+5.1E).mkv' }] }

      it do
        expect { subject }.to_not change Topics::NewsTopic, :count
        expect(anime.reload.episodes_aired).to eq episodes_aired
      end
    end

    describe 'any episode number should affect anime if episodes is not specified' do
      let(:episodes) { 0 }
      let(:episodes_aired) { 98 }
      let(:feed) { [{ title: '[QTS] Mobile Suit Gundam Unicorn Vol.99 (BD H264 1280x720 24fps AAC 5.1J+5.1E).mkv' }] }

      it do
        expect { subject }.to change(Topics::NewsTopic, :count).by 1
        expect(anime.reload.episodes_aired).to eq 99
      end
    end
  end
end
