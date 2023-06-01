import os
import json
## open the project
#project = XcodeProject.load('myApp.xcodeproj/project.pbxproj')
#
## add a file to it, force=false to not add it if it's already in the project
#project.add_file('MyClass.swift', force=False)
#
## set a Other Linker Flags
#project.add_other_ldflags('-ObjC')
#
## save the project, otherwise your changes won't be picked up by Xcode
#project.save()

#search_text = "shellScript = "
#replace_text = "shellScript = \"${BUILD_DIR%/Build/*}/SourcePackages/checkouts/firebase-ios-sdk/Crashlytics/run\" ;"

os.chdir('myApp.xcodeproj')
dir_list = os.listdir('./')
file_path = './'
for x in dir_list:
    if x.endswith(".pbxproj"):
        print("i m here")
        file_path += x

print(file_path)

f = open(file_path,"r")

data = f.read()

d = {}
with open(file_path) as f:
    for line in f:
       (key, val) = line.split()
       d[int(key)] = val

##print(data.find("buildPhases = ("))
"""
start_index=0
for i in range(len(data)):
  j = data.find("buildPhases = (",start_index)
  if(j!=-1):
    start_index = j+1
    f.seek(j)
    
    print(f.readline())

#data = data.replace(search_text, replace_text)

#f.close()

#f = open(file_path, "w")

#f.write(data)

#print("Text replaced")

"""
