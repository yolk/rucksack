module Rucksack
  module Packer
    class YuiCompressor
      
      YUI_COMPRESSOR = "#{File.dirname(__FILE__)}/../../../vendor/yuicompressor-2.4.2.jar"
      
      def pack(source, target)
        `java -jar #{YUI_COMPRESSOR} #{source} -o #{target}`
      end
      
    end
  end
end