describe NameMatches::Cleaner do
  let(:service) { NameMatches::Cleaner.instance }
  let(:phrase) { 'zz (tv4)' }

  describe '#finalize' do
    it { expect(service.finalize phrase).to eq 'zzs4' }
  end

  describe '#finalizes' do
    it { expect(service.finalizes [phrase, phrase]).to eq ['zzs4'] }
  end

  describe '#post_process' do
    it { expect(service.post_process phrase).to eq 'zz s4' }
    it { expect(service.post_process 'Охотник х Охотник [ТВ]').to eq 'охотник х охотник tv' }
    it { expect(service.post_process 'Охотник х Охотник [ТВ-1]').to eq 'охотник х охотник' }
    it { expect(service.post_process 'Охотник х Охотник [ТВ-2]').to eq 'охотник х охотник s2' }
    it { expect(service.post_process 'Охотник х Охотник [ТВ2]').to eq 'охотник х охотник s2' }
    it { expect(service.post_process 'Охотник х Охотник 2000').to eq 'охотник х охотник 2000' }
    it { expect(service.post_process 'Охотник х Охотник (2000)').to eq 'охотник х охотник 2000' }
    it { expect(service.post_process 'Охотник х Охотник [2000]').to eq 'охотник х охотник 2000' }
  end

  describe '#cleanup' do
    it { expect(service.cleanup phrase).to eq 'zz tv4' }
    it { expect(service.cleanup '[t] te ☆ †♪ (TES!)').to eq 't te tes!' }
    it { expect(service.cleanup nil).to eq '' }
  end

  describe '#fix' do
    it { expect(service.fix phrase).to eq 'zztv4' }
    it { expect(service.fix ['[test]', 'test' '☆ †♪', '(TEST2)']).to eq ['test', 'test2'] }
  end

  describe '#compact' do
    it { expect(service.compact phrase).to eq 'zz(tv4)' }
  end

  describe '#desynonymize' do
    it { expect(service.desynonymize phrase).to eq 'zz (s4)' }
  end
end
