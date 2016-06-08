require 'active_support/core_ext/object'

#
# This has the potential to grow VERY large if processing an extremely large
# file.  If that becomes an issue, this class could be reworked to wrap
# something like a sqlite table.
#
class Store
  attr_reader :mapping, :tables

  def initialize(match_fields = [])
    # Ensure we were actually given at least 1 field to match
    match_fields = [*match_fields]
    raise ArgumentError, "No match fields given" if match_fields.empty?

    @mapping = {}

    @tables = match_fields.inject({}) do |memo, k|
      memo[k] = {}
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
    if @mapping.empty?
      @tables.keys.each do |k|
        row.headers.each do |h|
          if h.underscore.start_with?(k)
            @mapping[h] = k
          end
        end
      end
    end

    uuid = nil
    # See if something in this row already exists
    row.headers.each do |h|
      mapping_key = @mapping[h]
      if mapping_key.present?
        value = row[h]
        if @tables[mapping_key].key?(value)
          # something is already in the table for this field
          uuid = @tables[mapping_key][value]
          break
        end
      end
    end

    # if uuid is still nil, nothing from this row matched
    uuid = self.generate_uuid if uuid.nil?

    # this is just writing ALL mapped fields, whether they already existed or
    # not.  not the most performant, but probably cheaper than checking first
    row.headers.each do |h|
      mapping_key = @mapping[h]
      if mapping_key.present? && row[h].present?
        @tables[mapping_key][row[h]] = uuid
      end
    end
    uuid
  end
end
