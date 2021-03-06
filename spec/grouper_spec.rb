require 'spec_helper'
require 'grouper'

describe Grouper do

  before do
    allow(File).to receive(:exists?).and_return(true)
  end

  it 'requires a valid input file' do
    allow(File).to receive(:exists?).and_return(false)
    expect { Grouper.new('invalid.csv') }.to raise_error(Grouper::InvalidFileError)
  end

  it 'requires at least 1 match_field' do
    allow(File).to receive(:exists?).and_return(true)
    expect { Grouper.new('valid.csv', nil) }.to raise_error(ArgumentError)
  end

  describe '#process' do
    let(:grouper) { Grouper.new('test.csv', %w(email)) }
    let(:headers) { 'RowHeaders' }
    let(:row1) { double('Record', to_csv: 'Row1Data') }
    let(:row2) { double('Record', to_csv: 'Row2Data') }
    let(:row3) { double('Record', to_csv: 'Row3Data') }
    let(:csv) { double('CSV') }
    let(:file) { double('File', close: nil) }
    let(:store) { double('Store', put: nil, records: {0 => row1, 1 => row2, 2 => row3}, headers: headers) }

    before do
      allow(Store).to receive(:new).and_return(store)
      allow(grouper).to receive(:output)
      allow(File).to receive(:open).and_return(file)
      allow(CSV).to receive(:new).and_return(csv)
      allow(csv).to receive(:each).and_yield(row1).and_yield(row2).and_yield(row3)
    end

    it 'opens the CSV file for reading' do
      expect(File).to receive(:open).and_return(file)
      grouper.process
    end

    it 'creates a CSV object' do
      expect(CSV).to receive(:new)
      grouper.process
    end

    it 'prints the headers' do
      expect(grouper).to receive(:output).with(
        'RowHeaders'
      )
      grouper.process
    end

    it 'adds all the records to the store' do
      expect(store).to receive(:put).exactly(3).times
      grouper.process
    end

    it 'prints each row, including the Id' do
      expect(grouper).to receive(:output).with('Row1Data')
      expect(grouper).to receive(:output).with('Row2Data')
      expect(grouper).to receive(:output).with('Row3Data')
      grouper.process
    end

    it 'closes the CSV file' do
      expect(file).to receive(:close)
      grouper.process
    end
  end
end
