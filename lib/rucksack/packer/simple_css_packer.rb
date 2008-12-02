module Rucksack
  module Packer
    class SimpleCssPacker < Rucksack::Packer::Base
      
      supports :stylesheets
      
      def pack(source, target)
        File.open(source, "r") do |source_file|        
          
          css = source_file.read
          
          ##
          # Compression code borrowed from asset_packager
          # http://github.com/sbecker/asset_packager/tree/master
          css.gsub!(/\s+/, " ") # collapse space
          css.gsub!(/\/\*(.*?)\*\/ /, "") # remove comments - caution, might want to remove this if using css hacks
          css.gsub!(/\} /, "}\n") # add line breaks
          css.gsub!(/\n$/, "") # remove last break
          css.gsub!(/ \{ /, " {") # trim inside brackets
          css.gsub!(/; \}/, "}") # trim inside brackets
          
          File.open(target, "w+"){ |target_file| target_file << css }
        end
      end
      
    end
  end
end


