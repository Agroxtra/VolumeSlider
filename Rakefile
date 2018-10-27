#!/usr/bin/env ruby

require 'xcodeproj'

task :xcodeproj do
  system "swift package generate-xcodeproj"

  project = Xcodeproj::Project.open(Dir["*.xcodeproj"].first)
  project.build_configurations.each { |config|
    config.build_settings["SDKROOT"] = "iphoneos"
    config.build_settings.delete("SUPPORTED_PLATFORMS")
  }
  target = project.targets.select {|t|t.name=="VolumeSlider"}.first
  group = project.main_group["Sources/VolumeSlider"]
  file1 = group.new_file(File.expand_path("Sources/VolumeSlider/volume_off.png"))
  file2 = group.new_file(File.expand_path("Sources/VolumeSlider/volume_low.png"))
  file3 = group.new_file(File.expand_path("Sources/VolumeSlider/volume_mid.png"))
  file4 = group.new_file(File.expand_path("Sources/VolumeSlider/volume_high.png"))
  target.add_resources([file1, file2, file3, file4]);
  project.save

end
