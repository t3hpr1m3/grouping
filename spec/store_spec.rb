require 'spec_helper'
require 'store'
require 'csv'

describe Store do
  it 'requires the match_fields' do
    expect { Store.new(nil) }.to raise_error(ArgumentError)
  end

  it 'initializes a valid starter table' do
    store = Store.new(%w(email))
    expect(store.tables).to include({ records: {}, indices: { email: {} } })
  end

  it 'initializes an empty mapping' do
    store = Store.new(%w(email))
    expect(store.mapping).to be_empty
  end

  describe '#put' do
    let(:headers) { %w(FirstName Email1 Email2) }
    let(:initial_row) { CSV::Row.new(headers, %w(User1 1@bar.com 1@bar.com)) }
    let(:interim_row) { CSV::Row.new(headers, %w(User2 2@foo.com 2@bar.com)) }
    let(:matching_row) { CSV::Row.new(headers, %w(User1 3@foo.com 2@bar.com)) }
    let(:non_matching_row) { CSV::Row.new(headers, %w(User4 4@foo.com 4@bar.com)) }
    let(:store) { Store.new(%w(first_name email)) }

    before do
      allow(store).to receive(:generate_uuid).and_return('1111', '2222', '3333', '4444')
    end

    it 'creates the proper mapping' do
      store.put(initial_row)
      expect(store.mapping).to include({ 'Email1' => :email })
    end

    it 'stores the row in the table' do
      store.put(initial_row)
      expect(store.tables[:records][0].row).to eql(initial_row)
    end

    it 'updates existing records uuids' do
      store.put(initial_row)
      store.put(interim_row)
      store.put(non_matching_row)
      store.put(matching_row)
      records = store.tables[:records]
      uuid = records[0].uuid
      expect(records[1].uuid).to eql(uuid)
      expect(records[2].uuid).not_to eql(uuid)
      expect(records[3].uuid).to eql(uuid)
    end
  end
end
