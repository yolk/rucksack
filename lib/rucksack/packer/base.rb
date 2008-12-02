module Rucksack
  module Packer
    class Base
      
      class_inheritable_accessor :siupported_formats
      
      def self.supports(*formats)
        self.siupported_formats = formats.map(&:to_sym)
      end
      
      def supports?(format)
        self.class.siupported_formats.include?(format.to_sym)
      end
      
      def pack(source, target)
        raise "Pack method not implemented"
      end
    end
  end
end