require 'active_support/inflector'
require 'active_support/core_ext/object'

class CSVGrouper
  def initialize(file_name = '')
    @file_name = file_name
  end

  def headers
    @headers ||= begin
      # File.open will raise an exception if the file does not exist
      line = File.open(@file_name, &:readline)
      if line.present?
        line.split(',').collect { |s| s.strip.underscore }
      else
        []
      end
    end
  end

  def matching_columns(strings)
    strings = [*strings]
    headers.select do |h|
      match = false
      strings.each do |s|
        if h.start_with?(s)
          match = true
          break
        end
      end
      match
    end
  end

  def parse_line(line)
    values = line.split(',').collect { |s| s.strip }

    # if the number of columns doesn't match, bail
    return nil if values.length != headers.length

    headers.each_with_index.inject({}) do |memo, (header, idx)|
      memo[header] = values[idx]
      memo
    end
  end
end
