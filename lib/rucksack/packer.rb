module Rucksack
  module Packer
    
    mattr_accessor :js_packer
    @@js_packer ||= Rucksack::Packer::YuiCompressor.new
    
    mattr_accessor :css_packer
    @@css_packer ||= Rucksack::Packer::YuiCompressor.new
    
    def self.pack(packed_file)
      packer = case packed_file.type
      when "javascripts"; js_packer
      when "stylesheets"; css_packer
      else
        raise "Unsupported file type: #{packed_file.type}"
      end
      
      packer.pack(packed_file.tmp_file_path, packed_file.file_path)
      
      raw_size = (File.size(packed_file.tmp_file_path)/10.24).round/100.0
      packed_size = (File.size(packed_file.file_path)/10.24).round/100.0
      [100 - (packed_size/raw_size)*100).to_i, packed_size]
    end
    
  end
end