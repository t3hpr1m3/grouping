require 'active_support/inflector'

class CSVGrouper
  def parse_header(line)
    return nil if line.nil?
    line.split(',').collect { |s| s.strip.underscore.to_sym }
  end
end

