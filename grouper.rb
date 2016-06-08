require 'csv'
require 'active_support/core_ext/object'

class Grouper

  class InvalidFileError < StandardError; end

  def initialize(filename = '')
    @filename = filename
  end

  def valid?
    return false if @filename.blank?
    return false unless File.exists?(@filename)
    true
  end

  def process(match_fields = [])
    # Ensure the file we're processing is actually valid
    raise InvalidFileError, "Invalid input file: #{@filename}" unless valid?

    # Ensure we were actually given at least 1 field to match
    match_fields = [*match_fields]
    raise ArgumentError, "No match fields given" if match_fields.empty?

    f = File.open(@filename, "r")
    csv = CSV.new(@filename, headers: true)
    headers = nil
    csv.each do |row|
      if headers.nil?
        headers = csv.headers
        create_lookup_tables(match_fields, csv.headers)
        output "Id,#{csv.headers.join(',')}"
      end
      id = lookup_id(row)
      output "#{id},#{row.to_csv}"
    end
    f.close
  end

  def create_lookup_tables(match_fields, headers)
    # these hashes have the potential to become very large.  If processing
    # extremely large files, these should be moved to ACTUAL tables in a
    # sqlite (or similar) external database.

    # first, extract the actual keys from the match_fields
    keys = match_fields.collect { |s| s.split('_', 2).last.underscore }

    # now, run the headers through the same transformation
    @lookup_tables = {}
    headers.each do |h|
      keys.each do |key|
        if h.underscore.start_with?(key)
          @lookup_tables[h] = {}
        end
      end
    end
    @lookup_tables
  end

  def lookup_id(row)
  end
end
