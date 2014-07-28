#!/usr/bin/env python
from os import popen
#from xml.dom import minidom
#xmldoc = minidom.parse("pom.xml")
ns='{http://maven.apache.org/POM/4.0.0}'
from xml.etree.ElementTree import ElementTree as ET
root = ET().parse("pom.xml")
artifactId = root.find('./' + ns + 'artifactId').text
version = root.find('./' + ns + 'version')
if version is None:
    version = root.find('./' + ns + 'parent/' + ns + 'version' ).text
else:
    version = root.find('./' + ns + 'version').text
tagName = root.find('./' + ns + 'tag')
if tagName is not None:
    tagName = tagName.text
else:
    tagName = ''
if tagName:
    popen("git fetch origin tag " + tagName) # just in case, should fail
print "Reading tags...",
tags       = popen("git tag").read().split()
print ", ".join(tags)

if tagName == artifactId + '-' + version: #we are processing the pom.xml that should be tagged
    if tagName not in tags: # git is not already tagged
        print "Tagging:", tagName
        #create a local tag
        popen("git tag " + tagName)
        print "Pushing tag:", tagName
        #push the tag to the remote
        popen("git push origin " + tagName)
        #make master advance to the new release locally
        popen("git rebase " + tagName + " master")
        #push master
        popen("git push origin master")
        exit(0)
    else:
        print "Error: tag", tagName, "already exists"
        exit(-1)
else:
    print "tag", tagName, "is not a release tag, ignoring"
