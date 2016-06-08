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

  describe 'matching_columns' do
    it 'returns all columns that match the given criteria' do
      g = CSVGrouper.new('test.csv')
      allow(g).to receive(:headers).and_return(['phone1', 'email1', 'email2'])
      expect(g.matching_columns('email')).to eql(['email1', 'email2'])
    end

    it 'accepts multiple names' do
      g = CSVGrouper.new('test.csv')
      allow(g).to receive(:headers).and_return(['last_name', 'phone1', 'email1', 'email2', 'zip'])
      expect(g.matching_columns(['phone', 'email'])).to eql(['phone1', 'email1', 'email2'])
    end
  end

  describe 'parse_line' do
    let(:line) { 'Wilson, (123) 456-7890, foo@bar.com, biz@baz.com, 12345' }
    it 'returns a hash representing the data in the line' do
      g = CSVGrouper.new
      allow(g).to receive(:headers).and_return(['last_name', 'phone1', 'email1', 'email2', 'zip'])
      expect(g.parse_line(line)).to include({
        'last_name' => 'Wilson',
        'phone1' => '(123) 456-7890',
        'email1' => 'foo@bar.com',
        'email2' => 'biz@baz.com',
        'zip' => '12345'
      })
    end
  end
end
