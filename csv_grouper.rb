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
end
