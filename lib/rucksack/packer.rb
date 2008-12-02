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
      raise "#{packer.class.name} can't compress #{packed_file.type}!" unless packer.supports?(packed_file.type)
      
      packer.pack(packed_file.tmp_file_path, packed_file.file_path)
      
      100 - ((File.size(packed_file.file_path).to_f / File.size(packed_file.tmp_file_path))*100).to_i
    end
    
  end
end