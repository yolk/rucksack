namespace :rucksack do
    desc "Merge and pack assets"
    task :pack => :environment do
      Rucksack.pack
    end

    desc "Remove all asset builds"
    task :unpack => :environment do
      Rucksack.unpack
    end
    
    desc "Generate rucksack.yml from existing assets"
    task :install => :environment do
      Rucksack.install
    end
end
