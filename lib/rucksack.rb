module Rucksack
  
  VERSION = "0.1"
  
  mattr_reader :unpacked_files
  @@unpacked_files = (File.exists?("#{Rails.root}/config/rucksack.yml") ? 
  YAML.load_file("#{Rails.root}/config/rucksack.yml") : {})
  
  mattr_accessor :environments
  @@environments ||= %w(production staging profile)
  
  def self.install
    yml_path = "#{Rails.root}/config/rucksack.yml"
    
    unless File.exists?(yml_path)
      yml = Hash.new
      
      yml['javascripts'] = {"base" => build_file_list("#{Rails.root}/public/javascripts", "js")}
      yml['stylesheets'] = {"base" => build_file_list("#{Rails.root}/public/stylesheets", "css")}

      File.open(yml_path, "w") { |out| YAML.dump(yml, out) }
  
      puts "config/rucksack.yml example file created!"
      puts "Please reorder files so dependencies are loaded in correct order."
    else
      puts "config/rucksack.yml already exists."
    end
  end
  
  def self.warmup
    ActionController::Base.helper(RucksackHelper)

    all_unpacked_files do |type, name, files|
      unpacked_files[type][name] = Rucksack::PackedFile.new(type, name, files).check_files
    end
    
    packed_files if pack?
  end
  
  def self.pack
    packed, existed, timer = [], [], Time.now
    all_unpacked_files do |type, name, files|
      file = Rucksack::PackedFile.new(type, name, files).pack
      if file.compression_rate
        packed << "#{file.file_name} (#{file.packed_size}KB saved #{file.compression_rate}%)"
      else
        existed << file.file_name
      end
    end
    timer = (Time.now - timer).to_i
    puts "Packed #{packed.size} files: #{packed.sort.join(", ")} (#{timer}s)" if packed.any?
    puts "Skipped #{existed.size} already existing files: #{existed.sort.join(", ")} (#{timer}s)" if existed.any?
  end
  
  def self.unpack
    removed = []
    all_unpacked_files do |type, name, files|
      file = Rucksack::PackedFile.new(type, name, files)
      removed << file.file_name if file.remove_file
    end
    puts "Removed #{removed.size} files: #{removed.sort.join(", ")}"
  end
  
  def self.content
    pack? ? packed_files : unpacked_files
  end
  
  def self.packed_files
    @@packed_files ||= begin
      r = {}
      all_unpacked_files do |type, name, files|
        file = Rucksack::PackedFile.new(type, name, files)
        (r[type] ||= {})[name] = file.exist? ?
        [file.file_name] : file.files
      end
      r
    end
  end
  
  def self.pack?
    environments.include?(Rails.env)
  end
  
  private
  
  def self.all_unpacked_files
    unpacked_files.keys.each do |type|
      unpacked_files[type].each do |name, files|
        yield type, name, files
      end if unpacked_files[type]
    end
  end
  
  def self.build_file_list(path, extension)
    re = Regexp.new(".#{extension}\\z")
    file_list = Dir.new(path).entries.delete_if { |x| ! (x =~ re) }.map {|x| x.chomp(".#{extension}")}
    # reverse javascript entries so prototype comes first on a base rails app
    file_list.reverse! if extension == "js"
    file_list
  end
  
  class PackedFile
    
    attr_reader :type, :name, :files, :compression_rate, :packed_size
    
    def initialize(type, name, files)
      @type = type
      @name = name
      @files = files
    end

    def check_files
      files.map! do |file|
        patterns = [
          "#{type_path}/#{file}", 
          "#{type_path}/#{file}.#{file_extension}",
          "#{public_path}/#{file}",
          "#{public_path}/#{file}.#{file_extension}"
        ]        
        patterns.each do |pattern|
          return pattern if File.file?(pattern)
        end
        raise "Can't find file: #{file} in #{type_path} or #{public_path}"
      end    
    end
    
    def pack
      unless exist?
        merge!
        @compression_rate, @packed_size = Rucksack::Packer.pack(self)
        remove_merged!
      end
      self
    end
    
    def remove_file
      FileUtils.rm_f(file_path) if exist?
    end
    
    def file_name
      "#{name}.pack.#{file_extension}"
    end
    
    def file_path
      "#{type_path}/#{file_name}"
    end
    
    def tmp_file_path
      "#{Rails.root}/tmp/#{name}.tmp.#{file_extension}"
    end
    
    def exist?
      File.exist?(file_path)
    end
    
    private
    
    def merge!
      remove_merged!
      File.open(tmp_file_path, "w+") do |tmp_file|
        files.each do |file_name|
          File.open(file_name, "r") do |file| 
            tmp_file << file.read + "\n" 
          end
        end
      end
    end
    
    def remove_merged!
      FileUtils.rm_f(tmp_file_path)
    end
    
    def type_path
      "#{public_path}/#{type}"
    end
    
    def public_path
      "#{RAILS_ROOT}/public"
    end    
    
    def file_extension
      type == "javascripts" ? "js" : "css"
    end
     
  end
  
end