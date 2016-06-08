require 'spec_helper'
require 'grouper'

describe Grouper do

  it { is_expected.to respond_to(:valid?) }

  describe '#valid?' do
    it 'ensures a filename was passed' do
      g = Grouper.new
      expect(g.valid?).to be false
    end

    it 'ensures the file exists' do
      g = Grouper.new('invalid.csv')
      expect(File).to receive(:exists?).with('invalid.csv').and_return(false)
      expect(g.valid?).to be false
    end
  end

  describe '#process' do
    let(:grouper) { Grouper.new('test.csv') }

    context 'with a non-existent file' do
      before do
        allow(grouper).to receive(:valid?).and_return(false)
      end

      it 'does not open the CSV file' do
        expect(File).not_to receive(:open)
        begin
          grouper.process(nil)
        rescue; end
      end

      it 'does not create a CSV object' do
        expect(CSV).not_to receive(:new)
        begin
          grouper.process(nil)
        rescue; end
      end

      it 'raises an InvalidFileError' do
        expect { grouper.process(nil) }.to raise_error(Grouper::InvalidFileError)
      end
    end

    context 'with a valid file' do

      before do
        allow(grouper).to receive(:valid?).and_return(true)
      end

      context 'and no match_fields supplied' do
        let(:match_fields) { nil }

        it 'does not open the CSV file' do
          expect(File).not_to receive(:open)
          begin
            grouper.process(match_fields)
          rescue; end
        end

        it 'does not create a CSV object' do
          expect(CSV).not_to receive(:new)
          begin
            grouper.process(match_fields)
          rescue; end
        end

        it 'raises ArgumentError' do
          expect { grouper.process(match_fields) }.to raise_error(ArgumentError)
        end
      end

      context 'and a list of match_fields supplied' do

        let(:match_fields) { ['same_email'] }

        let(:row1) { double('CSV::Row', to_csv: 'Row1') }
        let(:row2) { double('CSV::Row', to_csv: 'Row2') }
        let(:row3) { double('CSV::Row', to_csv: 'Row3') }
        let(:csv) { double('CSV', headers: %w(FirstName LastName Email1 Email2)) }
        let(:file) { double('File', close: nil) }

        before do
          allow(grouper).to receive(:valid?).and_return(true)
          allow(grouper).to receive(:output)
          allow(File).to receive(:open).and_return(file)
          allow(CSV).to receive(:new).and_return(csv)
          allow(csv).to receive(:each).and_yield(row1).and_yield(row2).and_yield(row3)
        end

        it 'opens the CSV file for reading' do
          expect(File).to receive(:open).and_return(file)
          grouper.process(match_fields)
        end

        it 'creates a CSV object' do
          expect(CSV).to receive(:new)
          grouper.process(match_fields)
        end

        it 'prints the headers' do
          expect(grouper).to receive(:output).with(
            'Id,FirstName,LastName,Email1,Email2'
          )
          grouper.process(match_fields)
        end

        it 'looks up the Id for each row' do
          expect(grouper).to receive(:lookup_id).exactly(3).times
          grouper.process(match_fields)
        end

        it 'prints each row, including the Id' do
          allow(grouper).to receive(:lookup_id).and_return('1')
          expect(grouper).to receive(:output).with('1,Row1')
          expect(grouper).to receive(:output).with('1,Row2')
          expect(grouper).to receive(:output).with('1,Row3')
          grouper.process(match_fields)
        end

        it 'closes the CSV file' do
          expect(file).to receive(:close)
          grouper.process(match_fields)
        end
      end
    end
  end
end
