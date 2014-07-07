require 'spec_helper'

describe TorrentsParser do
  subject { TorrentsParser.extract_episodes_num name }

  describe 'should match common cases' do
    it { TorrentsParser.extract_episodes_num('[Local-Raws] Bakuman 11 RAW (1280x720 x264 AAC NHKE).mp4').should eq [11] }
    it { TorrentsParser.extract_episodes_num('[Leopard-Raws] Bakuman. - 11 RAW (NHKE 1280x720 x264 AAC).mp4').should eq [11] }
    it { TorrentsParser.extract_episodes_num('[Leopard-Raws] Bakuman. - 11 RAW (NHKE 1920x1200 x264 AAC).mp4').should eq [11] }
    it { TorrentsParser.extract_episodes_num('[Local-Ras] ONE PIECE 470 RAW (1280x720 x264 AAC 30fps uhb).mp4').should eq [470] }
    it { TorrentsParser.extract_episodes_num('[GRUNNRAW] Heartcatch Precure! - 43 (EX 1280x720 x264).mp4').should eq [43] }
    it { TorrentsParser.extract_episodes_num('[Leopard-Raws] MM! - 11 RAW (ATX 1280x720 x264 AAC).mp4').should eq [11] }
    it { TorrentsParser.extract_episodes_num('Tanoshii Moomin Ikka 07 (DVD 640x480 x264 AAC).mp4').should eq [7] }
    it { TorrentsParser.extract_episodes_num('[ReinForce] Amagami SS - 23 (TBS 1280x720 x264 AAC).mkv').should eq [23] }
    it { TorrentsParser.extract_episodes_num('[Ritsuka] Bakuman - 07 (NHK-E 1280x720 x264 AAC).mp4').should eq [7] }
    it { TorrentsParser.extract_episodes_num('[BSS]_Mobile_Suit_Gundam_Unicorn_-_02_[720p][E05AEDDD].mkv').should eq [2] }
    it { TorrentsParser.extract_episodes_num('[Coalgirls]_Mobile_Suit_Gundam_Unicorn_02_(1280x720_Blu-Ray_FLAC)_[6BD5CB24].mkv').should eq [2] }
    it { TorrentsParser.extract_episodes_num('[QTS] Mobile Suit Gundam Unicorn Vol.1 (BD H264 1280x720 24fps AAC 2.0J+2.0E).mkv').should eq [1] }
    it { TorrentsParser.extract_episodes_num('[ReinForce] Tegami Bachi REVERSE - 10 (TX 1280x720 x264 AAC).mkv').should eq [10] }
    it { TorrentsParser.extract_episodes_num('[Yousei-raws] Tales of Symphonia - Tethe`alla Hen Vol.1-2 [DVDrip 848x480 x264 FLAC].mkv').should eq [1,2] }
    it { TorrentsParser.extract_episodes_num('[Yousei-raws] Tales of Symphonia - Tethe`alla Hen Vol.1-3 [DVDrip 848x480 x264 FLAC].mkv').should eq [1,2,3] }
    it { TorrentsParser.extract_episodes_num('[BadRaws]Tales of Symphonia The Animation Tethealla Hen 3 (DVD NTSC H.264 FLAC).mkv').should eq [3] }
    it { TorrentsParser.extract_episodes_num('[inshuheki] Bakuman 03 [720p][6ABBCC13].mkv').should eq [3] }
    it { TorrentsParser.extract_episodes_num('[TV-Japan] NARUTO Shippuuden - 192 Raw [1280x720 h264+AAC D-TX].mp4').should eq [192] }
    it { TorrentsParser.extract_episodes_num('TV-Japan] Bleach - 302 [1280x720 h264+AAC D-TX].mkv').should eq [302] }
    it { TorrentsParser.extract_episodes_num('[Animworld.com] One Piece 481 - RAW [480p] [H.264] [MP3].mp4').should eq [481] }
    it { TorrentsParser.extract_episodes_num('Detective Conan 593-595, 598 RAW 720р').should eq [593,594,595,598] }
    it { TorrentsParser.extract_episodes_num("[KOP-Raw's] Detective Conan 591-593 (1600x900 x264 ac3 24fps avi)").should eq [591,592,593] }
    it { TorrentsParser.extract_episodes_num('[sage]_Sekaiichi_Hatsukoi_2_-_07_[720p][10bit][E5CC0581].mkv').should eq [07] }
    it { TorrentsParser.extract_episodes_num('[OPC-Raws]_One_Piece_556_[CX_1280x720_VFR_H264_AAC]_[F8F6F8A2].mp4').should eq [556] }
    it { TorrentsParser.extract_episodes_num('[OPC-Raws]_One_Piece_556_[D-CX_1280x720_VFR_H264_AAC]_[F8F6F8A2].mp4').should eq [556] }
    it { TorrentsParser.extract_episodes_num('[Leopard-Raws] Panty & Stocking with Garterbelt - 01 RAW (BS4 1280x720 x264 AAC).mp4').should eq [1] }
    it { TorrentsParser.extract_episodes_num('[Sena-Raws] Teekyuu 2 - 04 (AT-X HD! 1280x720 x264 AAC).mp4').should eq [4] }
  end

  it 'last episodes' do
    TorrentsParser.extract_episodes_num('[Leopard-Raws] Kuroshitsuji II - 12 END (MBS 1280x720 x264 AAC).mp4').should eq [12]
    TorrentsParser.extract_episodes_num('[Leopard-Raws] MM! - 12 END (MBS 1280x720 x264 AAC).mp4').should eq [12]
  end

  it 'match wrong cases' do
    TorrentsParser.extract_episodes_num('[Leopard-Raws] Ore no Imouto ga Konna ni Kawaii Wake ga Nai OP9 (MX 1280x720 x264).mp4').should eq []
    TorrentsParser.extract_episodes_num('[FaggotryRaws] Tegami Bachi (REVERSE) - Letter Bee - 28 (03) (TV TOKYO 1280x720).mkv').should eq []
  end

  it 'too big numbers' do
    TorrentsParser.extract_episodes_num('[Leopard-Raws] Anime 999 (MBS 1280x720 x264 AAC).mp3').should eq [999]
    TorrentsParser.extract_episodes_num('[Leopard-Raws] Anime 1001 (MBS 1280x720 x264 AAC).mp3').should eq []
  end

  it 'gintama' do
    TorrentsParser.extract_episodes_num('[Leopard-Raws] gintama 253 (MBS 1280x720 x264 AAC).mp3').should eq [1]
    TorrentsParser.extract_episodes_num('[Leopard-Raws] gintama 250 (MBS 1280x720 x264 AAC).mp3').should eq []
  end

  describe 'episodes with #' do
    let(:name) { '[Leopard-Raws] Bakuman #12 (MBS 1280x720 x264 AAC).mp4' }
    it { should eq [12] }
  end

  describe 'episodes with data hash only' do
    let(:name) { '[WhyNot] Phi Brain - Kami no Puzzle S2 - 13 [1ED5F495].mkv' }
    it { should eq [13] }
  end

  describe 'names with rev2' do
    let(:name) { '[Raws-4U] Bounen no Xamdou - 01 rev2 (PSN 1920x1080 x264 AAC 5.1ch).mp4' }
    it { should eq [1] }
  end

  describe '~ and other symbols' do
    let(:name) { '[Winter] Mashiro-iro Symphony ~The Color of Lovers~ 99 [BDrip 1280x720 x264 Vorbis].mkv' }
    it { should eq [99] }
  end

  describe 'without brackets at end' do
    let(:name) { '[Raws] Chousoku Henkei Gyrozetter - 22.mp4' }
    it { should eq [22] }
  end

  describe 'name with brackets' do
    let(:name) { '[HorribleSubs] Rozen Maiden (2013) - 01 [720p].mkv' }
    it { should eq [1] }
  end

  describe 'episode num after "ch-"' do
    let(:name) { '[kingtqi-Raws] Saikyou Ginga Ultimate Zero - Battle Spirits CH-04 (ABC 1280x720 x264 AAC).mp4' }
    it { should eq [4] }
  end

  describe 'episode num with zero' do
    let(:name) { '[SubDESU] Shijou Saikyou no Deshi Kenichi OVA - 05v0 (640x360 x264 AAC) [8D5C93AE].mp4' }
    it { should eq [5] }
  end
end
