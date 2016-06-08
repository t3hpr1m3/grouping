require 'spec_helper'

require 'csv_grouper.rb'

describe CSVGrouper do

  it { is_expected.to respond_to(:headers) }

  describe 'headers' do
    let(:header_line) { 'FirstName,LastName,Phone,Email,Zip' }

    it 'converts them to snake_case' do
      allow(File).to receive(:open).with('test.csv').and_return(header_line)
      g = CSVGrouper.new('test.csv')
      expect(g.headers).to eql(['first_name', 'last_name', 'phone', 'email', 'zip'])
    end

    it 'stores them for later use' do
      allow(File).to receive(:open).once.and_return(header_line)
      g = CSVGrouper.new('test.csv')
      g.headers
      expect(File).not_to receive(:open)
      g.headers
    end
  end
end
