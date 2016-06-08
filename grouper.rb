require 'csv'
require 'store'
require 'active_support/core_ext/object'

class Grouper

  class InvalidFileError < StandardError; end

  def initialize(filename = '', match_fields = [])
    @filename = filename
    @match_fields = [*match_fields]

    # Ensure the file we're processing is actually valid
    raise InvalidFileError, "input file required" if filename.blank?
    raise InvalidFileError, "Invalid input file: #{@filename}" unless File.exists?(filename)

    # Ensure we were actually given at least 1 field to match
    match_fields = [*match_fields]
    raise ArgumentError, "No match fields given" if match_fields.empty?

    @store = Store.new(match_fields)
  end

  def process(match_fields = [])
    f = File.open(@filename, "r")
    csv = CSV.new(@filename, headers: true)
    headers_printed = false
    csv.each do |row|
      unless headers_printed
        output "Id,#{row.headers.join(',')}"
        headers_printed = true
      end
      id = @store.put(row)
      output "#{id},#{row.to_csv}"
    end
    f.close
  end
end
