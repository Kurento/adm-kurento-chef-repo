#!/usr/bin/env python
from xml.dom import minidom
xmldoc = minidom.parse("pom.xml")
required=set(('modelVersion', 'groupId', 'artifactId', 'version', 'packaging', 'name', 'description', 'url', 'licenses', 'scm', 'developers' ))
required2=set(('url','connection'))
print """This script checks that a pom.xml file
in the current directory complies with the conditions
for deployment in maven central stated in TODO.

It has to include the following elements at top level:""", ', '.join(required)
print """In addition, the <scm> element has to include the following
subelemtents:""", ', '.join(required2)
missing_elements = required - set(n.tagName for n in xmldoc.childNodes[0].childNodes if n.nodeType==1)
print "====== checking ====="
print
print
if missing_elements:
    print "Missing elements in pom.xml",  ', '.join(sorted(missing_elements))
if 'scm' not in missing_elements:
    missing_scm_elements = required2-set(m.tagName for m in [n.childNodes for n in xmldoc.childNodes[0].childNodes if n.nodeType==1 and n.tagName=='scm'][0] if m.nodeType==1)
    if missing_scm_elements:
        print "Missing elements inside toplevel <scm>", ', '.join(sorted(missing_scm_elements))
else:
    print "Additionally, the element <scm> must contain:",  ', '.join(sorted(required2))
