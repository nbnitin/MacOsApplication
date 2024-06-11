#!/bin/sh

#  addFilesToXcodeProject.sh
#  
#
#  Created by Nitin Bhatia on 07/05/24.
#  
#!/bin/bash

# Define variables
PROJECT_PATH="/Users/nitin.bhatia/Documents/DaxkoProjects/ReactNative/Expo/my-app/ios/Nits.xcodeproj"
FOLDER_PATH="./AppIcons"
GROUP_NAME="AppIcons"
TARGET_NAME="Nits"

# Add files to the project using xcodeproj gem
ruby -e "
require 'xcodeproj'

# Open the Xcode project
project = Xcodeproj::Project.open('$PROJECT_PATH')

# Get the main group
main_group = project.main_group

# Find or create the group
group = main_group['$GROUP_NAME'] || main_group.new_group('$GROUP_NAME')

# Iterate over files in the folder
Dir.glob('$FOLDER_PATH/*').each do |file_path|
  # Add the file to the group
  file_reference = group.new_file(file_path)

  # Get the target
  target = project.targets.find { |t| t.name == '$TARGET_NAME' }

  # Add the file reference to the target
  target.source_build_phase.add_file_reference(file_reference)
end

# Save the changes
project.save
"
cp -R $FOLDER_PATH "/Users/nitin.bhatia/Documents/DaxkoProjects/ReactNative/Expo/my-app/ios/"
cd /Users/nitin.bhatia/Documents/DaxkoProjects/ReactNative/Expo/my-app/ios
pod install
echo "Files added to Xcode project successfully."
