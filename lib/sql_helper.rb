module SqlHelper
  def self.escapeWildcards(data, reverse = false)
    return nil if data.nil?
    
    if reverse
      data.gsub('\\\\', '\\').gsub('\\%', '%').gsub('\\_', '_')
    else
      data.gsub('\\', '\\\\\\\\').gsub('%', '\\%').gsub('_', '\\_')
    end
  end
end