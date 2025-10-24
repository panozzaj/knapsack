describe Knapsack::Report do
  let(:report) { described_class.send(:new) }
  let(:report_path) { 'tmp/fake_report.json' }
  let(:report_json) do
    %Q[{"a_spec.rb": #{rand(Math::E..Math::PI)}}]
  end

  describe '#config' do
    context 'when passed options' do
      let(:args) do
        {
          report_path: 'knapsack_new_report.json',
          fake: true
        }
      end

      it do
        expect(report.config(args)).to eql({
          report_path: 'knapsack_new_report.json',
          fake: true
        })
      end
    end

    context "when didn't pass options" do
      it { expect(report.config).to eql({}) }
    end
  end

  describe '#save', :clear_tmp do
    before do
      expect(report).to receive(:report_json).and_return(report_json)
      report.config({
        report_path: report_path
      })
      report.save
    end

    it { expect(File.read(report_path)).to eql report_json }
  end

  describe '.open' do
    let(:subject) { report.open }

    before do
      report.config({
        report_path: report_path
      })
    end

    context 'when cache exists' do
      before do
        allow(Knapsack::Cache).to receive(:load).and_return({"cached_spec.rb" => 1.5})
      end

      it 'returns cache data' do
        expect(subject).to eql({"cached_spec.rb" => 1.5})
      end
    end

    context 'when cache is empty but report file exists' do
      before do
        allow(Knapsack::Cache).to receive(:load).and_return({})
        expect(File).to receive(:read).with(report_path).and_return(report_json)
      end

      it 'falls back to report file' do
        expect(subject).to eql(JSON.parse(report_json))
      end
    end

    context "when neither cache nor report file exist" do
      let(:report_path) { 'tmp/non_existing_report.json' }

      before do
        allow(Knapsack::Cache).to receive(:load).and_return({})
      end

      it 'returns empty hash (graceful degradation)' do
        expect(subject).to eql({})
      end
    end
  end
end
