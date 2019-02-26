describe TorrentsMatcher do
  describe 'matches_for' do
    def positive_match(string, options)
      matcher = TorrentsMatcher.new build(:anime, options)
      expect(matcher.matches_for(string)).to eq true
    end

    def negative_match(string, options)
      matcher = TorrentsMatcher.new build(:anime, options)
      expect(matcher.matches_for(string)).to eq false
    end

    it do
      positive_match('test 123', name: 'test')
      negative_match('ttest', name: 'test')
      positive_match('test zxcv', name: 'test zxcv')
      positive_match('test zxcv bnc', name: 'test zxcv')
      negative_match('ttest zxcv bnc', name: 'test zxcv')
      negative_match('[OWA Raws] Kodomo no Jikan ~ Kodomo no Natsu Jikan ~ (DVD 1280x720 h264 AC3 soft-upcon).mp4 ', name: 'Kodomo no Jikan OVA 5')
      negative_match('[ReinForce] To Aru Majutsu no Index II - 16 (TVS 1280x720 x264 AAC).mkv', name: 'Toaru Majutsu no Index II Specials')
      positive_match('[ReinForce] To Aru Majutsu no Index II - 16 (TVS 1280x720 x264 AAC).mkv', name: 'Toaru Majutsu no Index II')
      #positive_match('[HQR] Umi monogatari TV [DVDRip 1024x576 h264 aac]', name: 'Umi Monogatari: Anata ga Ite Kureta Koto', kind: 'TV')
      negative_match('[Leopard-Raws] Maria Holic - 11 (DVD 704x480 H264 AAC).mp4', name: 'Maria Holic 2', kind: 'tv')
      negative_match('[Leopard-Raws] Maria Holic - 11 (DVD 704x480 H264 AAC).mp4', name: 'Maria†Holic Alive', synonyms: ['Maria+Holic 2', 'Maria Holic 2', 'MariaHolic 2'], kind: 'TV')
      positive_match('[Leopard-Raws] Maria Holic 2e- 11 (DVD 704x480 H264 AAC).mp4', name: 'Maria Holic 2', kind: 'tv')
      positive_match('[Leopard-Raws] Bakuman 2 #11 (DVD 704x480 H264 AAC).mp4', name: 'Bakuman 2', kind: 'tv')
      negative_match('[Leopard-Raws] Testov Test 2e- 11 (DVD 704x480 H264 AAC).mp4', name: 'Testov Test', kind: 'tv', synonyms: ['Testov Test OVA'])
      negative_match('[Leopard-Raws] Testov Test 2e- 11 (DVD 704x480 H264 AAC).mp4', name: 'Testov Test', kind: 'tv', synonyms: ['Testov Test (OVA)'])
    end

    it 'II treated like 2' do
      positive_match('[Zero-Raws] Sekai Ichi Hatsukoi II - 08 (TVS 1280x720 x264 AAC).mp4', name: 'Sekai Ichi Hatsukoi 2', kind: 'tv')
    end

    it 'minus treated like whitespace' do
      positive_match('[Zero-Raws] Sekai Ichi Hatsukoi II - 08 (TVS 1280x720 x264 AAC).mp4', name: 'Sekaiichi Hatsukoi 2', synonyms: ['Sekai-ichi Hatsukoi 2'], kind: 'tv')
    end

    it 'matches names with underscores' do
      positive_match('[sage]_Sekaiichi_Hatsukoi_2_-_07_[720p][10bit][E5CC0581].mkv', name: 'Sekaiichi Hatsukoi 2', kind: 'tv')
    end

    it 'matches name with season w/o space' do
      positive_match('[Leopard-Raws] Bakuman2 - 11 (DVD 704x480 H264 AAC).mp4', name: 'Bakuman 2', kind: 'tv')
    end

    it 'matches name with season "S" letter' do
      positive_match('Shinryaku! Ika Musume S2 - 05v2 [94DCBFF3].mkv', name: 'Shinryaku! Ika Musume 2', kind: 'tv')
    end

    it 'matches name with season "S" letter' do
      positive_match('Shinryaku! Ika Musume S2 - 05v2 [94DCBFF3].mkv', name: 'Shinryaku! Ika Musume 2', kind: 'tv')
    end

    it 'matches name with season (TV)' do
      positive_match('[TV-J] Mirai Nikki - 11 [1440x810 h264+AAC TOKYO-MX].mp4', name: 'Mirai Nikki (TV)', kind: 'tv')
    end

    it 'matches name with dot' do
      positive_match('[Leopard-Raws] Aldnoah.Zero - 01 RAW (MX 1280x720 x264 AAC).mp4', name: 'Aldnoah.Zero', kind: 'tv')
    end

    it 'works for torrents_name' do
      positive_match('[TV-J] Mirai Nikki - 11 [1440x810 h264+AAC TOKYO-MX].mp4', name: 'Mirai Nikk', torrents_name: 'Mirai Nikki', kind: 'tv')
    end

    # it 'torrents_name top priority' do
      # negative_match('[TV-J] Mirai Nikki - 11 [1440x810 h264+AAC TOKYO-MX].mp4', name: 'Mirai Nikki', torrents_name: 'Mirai Nikk', kind: 'tv')
    # end

    it 'tilda and semicolon' do
      positive_match('[Zero-Raws] Queen\'s Blade ~Rebellion~ - 01 (AT-X 1280x720 x264 AAC).mp4', name: 'Queen\'s Blade: Rebellion', kind: 'tv')
    end

    it 'special symbols' do
      positive_match('[Zero-Raws] Fate kaleid liner Prism Illya - 01 (MX 1280x720 x264 AAC).mp4', name: 'Fate/kaleid liner Prisma☆Illya', kind: 'tv')
      positive_match('[Zero-Raws] Fatekaleid liner Prism Illya - 01 (MX 1280x720 x264 AAC).mp4', name: 'Fate/kaleid liner Prisma☆Illya', kind: 'tv')
      positive_match('[Zero-Raws] Fate kaleid liner PrismIllya - 01 (MX 1280x720 x264 AAC).mp4', name: 'Fate/kaleid liner Prisma☆Illya', kind: 'tv')
    end

    describe 'torrents_name specified' do
      it 'matches only exact match' do
        negative_match('[Hien] Hayate no Gotoku! - Can\'t Take My Eyes Off You - 05-06 [BD 1080p H.264 10-bit AAC]', name: 'Hayate no Gotoku! Cuties', torrents_name: 'Hayate no Gotoku! Cuties', kind: 'tv')
      end
    end

    it do
      positive_match('[HorribleSubs] Boogiepop wa Warawanai (2019) - 13 [1080p].mkv', name: 'Boogiepop wa Warawanai (2019)', kind: 'tv')
    end
  end
end
