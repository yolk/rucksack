module Rucksack
  module Packer
    class YuiCompressor < Rucksack::Packer::Base
      
      supports :javascripts, :stylesheets
      YUI_COMPRESSOR = "#{File.dirname(__FILE__)}/../../../vendor/yuicompressor-2.4.2.jar"
      
      def pack(source, target)
        `java -jar #{YUI_COMPRESSOR} --charset utf8  #{source} -o #{target}`
      end
      
    end
  end
end