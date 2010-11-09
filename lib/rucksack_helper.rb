module RucksackHelper
  def javascript_include_packed(*files)
    include_packed_files('javascripts', files) do |f|
      javascript_include_tag(*f)
    end.join.html_safe
  end
  
  def stylesheet_link_packed(*files)
    include_packed_files('stylesheets', files) do |f|
      stylesheet_link_tag(*f)
    end.join.html_safe
  end
  
  private
  
  def include_packed_files(type, files)
    return unless Rucksack.content[type]
    
    options = files.last.is_a?(Hash) ? files.pop.stringify_keys : {}
    
    files.map do |name|
      f = Rucksack.content[type][name.to_s] || next
      yield f.dup << options
    end
  end
end