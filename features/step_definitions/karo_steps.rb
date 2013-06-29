include FileUtils

FILES = %w(image.jpg document.pdf)

def create(path)
  base_directory   = File.dirname(path)
  assets_directory = File.basename(path)

  # Delete and create the path
  Dir.chdir base_directory do
    rm_rf assets_directory
    mkdir assets_directory
  end
end

Given(/^a path with some files at "(.*?)" to be synced at "(.*?)"$/) do |from_path, to_path|
  create from_path
  create to_path

  # Create test assets to be used for syncing
  Dir.chdir from_path do
  	FILES.each { |_| touch _ }
  end
end

Then(/^the assets should be synced out in the directory "(.*?)"$/) do |sync_to_path|
  File.exist?(sync_to_path).should == true

  Dir.chdir sync_to_path do
    FILES.each do |file|
      File.exist?(file).should == true
    end
  end
end
