require 'active_support/core_ext/object'
require 'securerandom'
#
# This has the potential to grow VERY large if processing an extremely large
# file.  If that becomes an issue, this class could be reworked to wrap
# something like a sqlite table.
#
class Record
  attr_reader :row
  attr_accessor :uuid

  def initialize(row)
    @row = row
  end
end
class Store
  attr_reader :mapping, :tables

  def initialize(match_fields = [])
    # Ensure we were actually given at least 1 field to match
    match_fields = [*match_fields]
    raise ArgumentError, "No match fields given" if match_fields.empty?

    @mapping = {}
    @tables = {
      records: {},
      indices: {}
    }

    match_fields.inject(@tables[:indices]) do |memo, k|
      memo[k.to_sym] = {}
      memo
    end
  end

  def clear
    @tables.keys.each do |k|
      @tables[k] = {}
    end
  end

  def put(row)
    # If this is the first put, setup the mapping table
    if self.mapping.empty?
      self.tables[:indices].keys.each do |k|
        row.headers.each do |h|
          if h.underscore.start_with?(k.to_s)
            self.mapping[h] = k
          end
        end
      end
    end

    #
    # First, find any records that "match" this one
    #
    ids = []
    self.mapping.each do |key, value|
      self.tables[:indices][value].fetch(row[key], []).each do |id|
        ids << id
      end
    end
    ids.uniq.sort!

    #
    # If we have any matches, grab the first uuid
    #
    if ids.present?
      uuid = self.tables[:records][ids.first].uuid

      #
      # Ensure all other matching records have this uuid
      #
      ids[1..-1].each do |id|
        self.tables[:records][id].uuid = uuid
      end
    end

    #
    # If we don't have a uuid, then there are no records that match.
    # We'll assign a uuid here.  It may be overwritten later when a
    # connecting match is found.
    #
    id = self.tables[:records].count
    uuid = self.generate_uuid if uuid.nil?

    #
    # Finally, write this record and its index entries
    #
    record = Record.new(row)
    record.uuid = uuid
    self.tables[:records][id] = record
    self.mapping.each do |key, value|
      if row[key].present?
        self.tables[:indices][value][row[key]] ||= []
        self.tables[:indices][value][row[key]] << id
      end
    end
  end

  def generate_uuid
    SecureRandom.uuid
  end

  def records
    self.tables[:records]
  end
end
