require 'csv'
require 'active_support/core_ext/object'

class Grouper

  class InvalidFileError < StandardError; end

  def initialize(filename = '')
    @filename = filename
    @headers = nil
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
    csv.each do |row|
      unless @headers
        @headers = csv.headers
        output "Id,#{csv.headers.join(',')}"
        headers = false
      end
      id = lookup_id(row)
      output "#{id},#{row.to_csv}"
    end
    f.close
  end

  def lookup_id(row)
  end
end
