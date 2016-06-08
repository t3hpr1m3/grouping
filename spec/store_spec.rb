require 'spec_helper'
require 'store'
require 'csv'

describe Store do
  it 'requires the match_fields' do
    expect { Store.new(nil) }.to raise_error(ArgumentError)
  end

  it 'initializes a valid starter table' do
    store = Store.new(%w(email))
    expect(store.tables).to include({ 'email' => {} })
  end

  it 'initializes an empty mapping' do
    store = Store.new(%w(email))
    expect(store.mapping).to be_empty
  end

  describe '#put' do
    let(:headers) { %w(FirstName Email1 Email2) }
    let(:initial_row) { CSV::Row.new(headers, %w(Joe foo@bar.com biz@baz.com)) }
    let(:matching_row) { CSV::Row.new(headers, %w(Jim baz@bar.com foo@bar.com)) } # dup email
    let(:new_row) { CSV::Row.new(headers, %w(John new@foo.com)) }
    let(:store) { Store.new(%w(email)) }

    before do
      allow(store).to receive(:generate_uuid).and_return('1111', '2222', '3333')
    end

    it 'creates the proper mapping' do
      store.put(initial_row)
      expect(store.mapping).to include({ 'Email1' => 'email' })
    end

    context 'when no matching record exists' do

      before do
        store.clear
      end

      it 'generates a new uuid' do
        expect(store).to receive(:generate_uuid)
        store.put(initial_row)
      end

      it 'stores all matching fields' do
        allow(store).to receive(:generate_uuid).and_return('1234')
        store.put(initial_row)
        tables = store.tables
        expect(tables['email']).to include({ 'foo@bar.com' => '1234', 'biz@baz.com' => '1234' })
      end
    end

    context 'when a matching record exists' do

      before do
        store.clear
        store.put(initial_row)
      end

      it 'does not generate a new uuid' do
        expect(store).not_to receive(:generate_uuid)
        store.put(matching_row)
      end

      it 'stores the new data in the table' do
        store.put(matching_row)
        expect(store.tables['email']).to eql({
          'foo@bar.com' => '1111',
          'biz@baz.com' => '1111',
          'baz@bar.com' => '1111'
        })
      end
    end

    context 'when a record exists, but does not match' do
      before do
        store.clear
        store.put(initial_row)
      end

      it 'generates a new uuid' do
        expect(store).to receive(:generate_uuid)
        store.put(new_row)
      end

      it 'adds the new data to the table' do
        store.put(new_row)
        expect(store.tables['email']).to eql({
          'foo@bar.com' => '1111',
          'biz@baz.com' => '1111',
          'new@foo.com' => '2222'
        })
      end

      it 'returns the new uuid' do
        expect(store.put(new_row)).to eql('2222')
      end
    end
  end
end
