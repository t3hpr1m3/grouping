#!/usr/bin/env ruby

$LOAD_PATH.unshift(File.expand_path(File.join(File.dirname(__FILE__))))

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

  def process
    f = File.open(@filename, "r")
    csv = CSV.new(f, headers: true)
    csv.each do |row|
      @store.put(row)
    end
    f.close
    headers_printed = false
    @store.records.each do |id, record|
      unless headers_printed
        output "Id,#{record.row.headers.join(',')}"
        headers_printed = true
      end
      output "#{record.uuid},#{record.row.to_csv}"
    end
  end

  def output(msg)
    puts msg
  end
end
