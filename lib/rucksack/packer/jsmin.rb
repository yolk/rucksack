module Rucksack
  module Packer
    class Jsmin < Rucksack::Packer::Base
      
      supports :javascripts
      JSMIN = "#{File.dirname(__FILE__)}/../../../vendor/jsmin.rb"
      
      def pack(source, target)
        `ruby #{JSMIN} <  #{source} > #{target}\n`
      end
      
    end
  end
end