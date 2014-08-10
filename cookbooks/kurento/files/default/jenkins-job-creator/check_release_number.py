#!/usr/bin/env python
from os import popen
import re
from sys import argv

def node_version(path='.'):
    """Prints the version in package.json in the given path.
    """
    try:
        jsfilename = path + '/package.json'
        with open(jsfilename) as pfile:
            import json
            jsversion = json.load(pfile)['version']
            return jsversion
    except IOError:
        print("No package.json present in", path)
        raise

def cmake_version(path='.'):
    """Prints the version in CMakeLists.txt in the given path.
    """
    try:
        cmfilename = path + '/CMakeLists.txt'
        with open(cmfilename) as cmfile:
            lines = cmfile.readlines()
            artifactName =  [re.findall(r"\^(.*)-",l)[0] for l in lines if re.search(r"\^(.*)-", l)][0]
            cmversion = '.'.join([re.split('[ )]',l)[1] for l in lines if "set(" in l and "_VERSION" in l and ')' in l][0:3])
            return cmversion
    except IOError:
        print("No CMakeLists.txt present in", path)
        raise

def maven_version(path='.'):
    """Returns the version in pom.xml in the given path.
    """
    try:
        jfilename = path + '/pom.xml'
        ns='{http://maven.apache.org/POM/4.0.0}'
        from xml.etree.ElementTree import ElementTree as ET
        root = ET().parse(jfilename)
        parent_version = root.find('./' + ns + 'parent/' + ns + "version" )
        if parent_version is not None: return parent_version.text # child project
        my_version = root.find('./' + ns + 'version' ) # parent project
        if my_version is not None: return my_version.text # parent has explicit version
        raise "no version!"
    except IOError:
        print("No pom.xml present in", path)
        raise

def maven_artifactId(path="."):
    """Returns the artifactId of pom.xml in the given path.
    """
    try:
        jfilename = path + '/pom.xml'
        ns='{http://maven.apache.org/POM/4.0.0}'
        from xml.etree.ElementTree import ElementTree as ET
        root = ET().parse(jfilename)
        artifactId     = root.find('./' + ns + 'artifactId' )
        if artifactId is not None:
            return artifactId.text
        return ''
    except IOError:
        print("No pom.xml present in", path)
        raise


def check_submodules():
    """Check that git submodules are in a release tag.

       return True if they are, False if they are not.
    """
    check_submodule_command = "git submodule foreach " + argv[0] + " -r" # we want to error for non-release modules
    pipe = popen( check_submodule_command )
    res = pipe.read().strip()
    if res: print(res)
    rc = pipe.close()
    if rc is not None and rc >> 8:
        return False
    return True

def tag_release(artifactName, version):
    """Tag a release and push the tag to origin/master.

    git branch master origin/master     # create master if not exists
    git fetch --tags                    # load remote tags
    git tag                             # read tags into variable "tags"
    git tag $tagName                    # create local tag
    git rebase $tagname master          # move master to new tag
    git push origin $tagName            # push tag to origin/master
    git push origin master              # push master to origin
    """

    popen("git branch master origin/master").read() # create master if not exists
    popen("git fetch --tags").read()                # load remote tags
    tags = popen("git tag").read().split()          # read tags into variable "tags"
    tagName = artifactName + "-" + version
    if tagName in tags:                             # warn if git is already tagged
        print "Warning: local tag", tagName, "already exists"
    print "Tagging:", tagName, "locally"
    popen("git tag " + tagName)                     # create local tag
    popen("git rebase " + tagName + " master")      # move master to new tag
    print "Pushing tag:", tagName, "to gerrit"
    popen("git push origin " + tagName)             # push tag to origin/master
    print "Pushing master to gerrit"
    popen("git push origin master")                 # push master to origin
    exit(0)

def check_releases(fileName, artifactName, version, ensure_release=False, make_release_tag=False):
    """
    Check that release status is ok
        either we are in a -dev release number or
               the current commit has a tag compatible with the current version and
               submodules are in a tag release number
    if ensure_release is True don't allow -dev releases
    if make_release_tag is True the tag will be done and pushed to origin/master after checking
    """
    # if make_release_tag we need to tag the repository if a release number is found, do nothing for -dev
    if not ensure_release:
        #check submodules and fail if they are not in a release already
        if "-dev" not in version and "-SNAPSHOT" not in version:
            if check_submodules(): # not a development snapshot and submodules are ok
                if make_release_tag:
                    tag_release(artifactName, version)
                exit(code=0)
            else:
                print "a submodule is not in a release, failing..."
                exit(code=1) # a submodule failed
        else:
            if ensure_release:
                print "code is not in a release, failing..."
                exit(code=1) # should be in release
            print version, "is not a release version, doing nothing"
            exit(code=0)
    # if called with -r, ensure_release is True and we should check submodules and error if repo not in a release
    release = popen("git tag --contains HEAD").read().strip().split('-')[-1]
    if version != release:
        print "Error:", artifactName+":", "release version", release, "!=", fileName, "version", version
        exit(code=1)
    else:
        if check_submodules():
            print artifactName+":", "release version", release, "==", fileName, "version", version
            exit(0)
        else:
            exit(code=1)

name = argv[0].split("/")[-1]
make_release_tag = True
# without options we ignore if -dev, check release consistency if in release
check_option = '-r' # raise if not in release
tag_option   = '-t' # tag and push tag if we are in release
ensure_release   = False
make_release_tag = False
for option in argv[1:]:
    if option  == tag_option:
        make_release_tag = True
    if option  == check_option:
        ensure_release = True

# If there is a source/conf.py file
try:
    cfilename = "source/conf.py"
    regex=re.compile(r"release\s*=\s*['\"](.*)['\"]")
    with open(cfilename) as cfile:
        artifactName = 'doc-kurento'
        cversion = [regex.match(l).groups()[0] for l in open(cfilename).readlines() if regex.match(l)][0]
        check_releases(cfilename, artifactName, cversion, ensure_release, make_release_tag)
except IOError:
    pass


# If there is a configure.ac in top level
try:
    acfilename = "configure.ac"
    with open(acfilename) as acfile:
        acline = [l for l in acfile.readlines() if "AC_INIT" in l][0].strip()
        artifactName = re.split('[\]\[]', acline)[1]
        acversion = re.split('[\]\[]', acline)[3]
        check_releases(acfilename, artifactName, acversion, ensure_release, make_release_tag)
except IOError:
    pass


# capture maven info
try:
    jfilename   = "pom.xml"
    artifactId  = maven_artifactId()
    jversion    = maven_version()
    check_releases(jfilename, artifactId, jversion, ensure_release, make_release_tag)
    #print jversion
except IOError:
    # kurento media server is tested here.
    # maven does its own tagging, so
    # maven+cmake gets a special treatment below.
    try:
        cmfilename = "CMakeLists.txt"
        with open(cmfilename) as cmfile:
            lines = cmfile.readlines()
            artifactName = ''
            cmversion = ''
            for l in lines:
              if "set" in l and "_VERSION" in l and ')' in l and "PROJECT_" in l:
                try:
                  number = re.split("_VERSION ", l)[1][0:-2]
                  if cmversion == "":
                    cmversion = number
                  else:
                    cmversion += "." + number
                except:
                  pass
              if ("set" in l or "SET" in l) and "PROJECT_NAME " in l:
                try:
                  artifactName = re.split("\"", l)[1]
                except:
                  pass
            check_releases(cmfilename, artifactName, cmversion, ensure_release, make_release_tag)
            cmrelease = popen("git tag --contains HEAD").read().strip().split('-')[-1]
            exit(code=0)
    except IOError:
        pass
    # kws-rpc-builder is tested here, as it has no pom.xml
    try:
        jsfilename = "package.json"
        with open(jsfilename) as pfile:
            import json
            jfile = json.load(pfile)
            jsversion = jfile['version']
            artifactName = jfile['name']
            check_releases(jsfilename, artifactName, jsversion, ensure_release, make_release_tag)
            print jsversion
            if jversion != jsversion:
                print "Error:", artifactId+":", "pom version", jversion, "!=", jsfilename, "version", jsversion
                exit(code=1)
            else:
                print name+":", "pom version", jversion, "==", "package.json version", jsversion
            exit(code=0)
    except IOError:
        pass#print name+":", "No package.json present, will not check it."


    exit(code=0)


# maven + nodejs projects
try:
    jsfilename = "package.json"
    with open(jsfilename) as pfile:
        import json
        jsversion = json.load(pfile)['version']
        #print jsversion
        if jversion != jsversion:
            print "Error:", artifactId+":", "pom version", jversion, "!=", jsfilename, "version", jsversion
            exit(code=1)
        else:
            print name+":", "pom version", jversion, "==", "package.json version", jsversion
except IOError:
    pass#print name+":", "No package.json present, will not check it."

# maven + cmake projects
try:
    with open("CMakeLists.txt") as cmfile:
        cmversion = '.'.join([re.split('[ )]',l)[1] for l in cmfile.readlines() if "set(" in l and "_VERSION" in l and ')' in l])
        #print jversion, cmversion
        if jversion != re.sub('-dev','-SNAPSHOT', cmversion):
            print "Error:", artifactId+":", "pom version", jversion, "!=", "CMakeLists.txt version", cmversion
            exit(code=1)
        else:
            if check_submodules():
                print artifactId+":", "pom version", jversion, "==", "CMakeLists.txt version", cmversion
                exit(0)
            else:
                exit(code=1)
except IOError:
    pass#print name+":", "No CMakeLists.txt present, will not check"

