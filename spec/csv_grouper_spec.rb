require 'spec_helper'

require 'csv_grouper.rb'

describe CSVGrouper do

  let(:header) { 'FirstName,LastName,Phone,Email,Zip' }

  describe 'parse_header' do
    it 'converts the headers to symbols' do
      g = CSVGrouper.new
      expect(g.parse_header(header)).to eql([
        :first_name,
        :last_name,
        :phone,
        :email,
        :zip
      ])
    end
  end
end

