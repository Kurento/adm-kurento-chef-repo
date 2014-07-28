#!/bin/bash

sync_maven() {
if [ "$#" -ne 1 ]; then
    echo "sync_maven version[@]"
    echo "      Synchronizes pom.xml version to the one given."
    echo ""
    echo "      params:"
    echo "          version[@] is the reference to an array in scope"
    echo "          created as in export version=(4 0 0)"
    echo ""
    return 1
fi
local -a curver=("${!1}")
local newver=${curver[@]}
newver=${newver// -/-}
newver=${newver// /.}
# Check release numbers for cmake or npm mixed projects
if [ -f pom.xml ]; then
    local pom_version="$(xmlstarlet sel -t  -v '/_:project/_:parent/_:version' pom.xml 2>/dev/null)"
    if [ -n "$pom_version" ]; then # we are the son
        pom_version="$(xmlstarlet sel -t  -v '/_:project/_:parent/_:version' pom.xml )"
    else
        pom_version="$(xmlstarlet sel -t  -v '/_:project/_:version' pom.xml )"
    fi
    pom_version=(${pom_version//[.-]/ }) # make it an array MAJOR MINOR PATCH EXTRA
    echo "pom.xml found, we need = ${newver}, we have = ${pom_version[@]}"
    # Change the version in the POMs from ${pom_version[@]}" to a ${newver}
    if [ -n "$(xmlstarlet sel -t  -v '/_:project/_:parent/_:version' pom.xml 2>/dev/null)" ]; then # we are the son
      xmlstarlet ed -O -P -L -u "/_:project/_:parent/_:version" -v "${newver}" pom.xml
    else # change the project version
      xmlstarlet ed -O -P -L -u "/_:project/_:version" -v "${newver}" pom.xml
    fi
else
    return 100
fi
} && echo "defined sync_maven"

sync_cmake() {
if [ "$#" -ne 1 ]; then
    echo "sync_cmake version[@]"
    echo "      Synchronizes CMakeLists.txt version to the one given."
    echo ""
    echo "      params:"
    echo "          version[@] is the reference to an array in scope"
    echo "          created as in export version=(4 0 0)"
    echo ""
    return 1
fi
local -a curver=("${!1}")
# Check release numbers for cmake or npm mixed projects
if [ -f CMakeLists.txt ]; then
    local -a cmakeversion=($(grep "set(.*_VERSION.*)" CMakeLists.txt | sed -e "s@set(.*_VERSION \(.*\))@\1@" | sed -e "s@-@ -@" ))
    local -a parts=(MAJOR MINOR PATCH)
    local -a newver=(${curver[@]})
    newver[2]=${curver[@]:2}
    newver[2]=${newver[2]// /}
    newver[2]=${newver[2]/SNAPSHOT/dev}
    echo "CMakeLists.txt found, pom version = ${newver[@]}, cmake version = ${cmakeversion[@]}"
    for i in 0 1 2; do
       sed -i -e "s@\(${parts[$i]}_VERSION \).*)@\1${newver[$i]})@" CMakeLists.txt;
    done
else
    return 100
fi
} && echo "defined sync_cmake"

sync_deb() {
if [ "$#" -ne 1 ]; then
    echo "sync_deb version[@]"
    echo "      Synchronizes debian/changelog version to the one given."
    echo "      For release versions it updates the changelog of"
    echo "       the release"
    echo ""
    echo "      params:"
    echo "          version[@] is the reference to an array in scope"
    echo "          created as in export version=(4 0 0)"
    echo ""
    return 1
fi
local -a current_version=("${!1}")
# Check release numbers for cmake or npm mixed projects
if [ -f debian/changelog ]; then
    local -a debversion=($(grep "(.*)" debian/changelog | head -1 | sed -e "s@.*(\(.*\)).*@\1@" -e "s@\.@ @g" -e "s@-@ -@"))
    local newver=${current_version[@]}
    newver=${newver// -/-}
    newver=${newver// /.}
    newver=${newver/-SNAPSHOT/-dev}
    echo "debian/changelog found, pom version = ${newver}, deb version = ${debversion[@]}"
    local distro=testing
    if [ "${current_version[3]}" == "" ]; then
        git dch --ignore-branch --since origin/master --new-version=${newver}  --distribution ${distro};
    fi
else
    return 100
fi
} && echo "defined sync_deb"

sync_node() {
if [ "$#" -ne 1 ]; then
    echo "sync_node version[@]"
    echo "      Synchronizes package.json version to the one given."
    echo "      For release versions it updates the changelog of"
    echo "      the release"
    echo ""
    echo "      params:"
    echo "          version[@] is the reference to an array in scope"
    echo "          created as in export version=(4 0 0)"
    echo ""
    return 1
fi
local -a current_version=("${!1}")
# Check release numbers for cmake or npm mixed projects
if [ -f package.json ]; then
    local -a nodeversion=($(nodejs /usr/lib/node_modules/npm/bin/read-package-json.js package.json version))
    local newver=${current_version[@]}
    newver=${newver// -/-}
    newver=${newver// /.}
    #newver=${newver/-SNAPSHOT/-dev}
    echo "package.json found, pom version = ${newver}, node version = ${nodeversion[@]}"
    sed -i -e "s@\(.*\"version\".*\)\"${nodeversion}\"\(.*\)@\1\"${newver}\"\2@" package.json
else
    return 100
fi
} && echo "defined sync_node"

sync_sphinx() {
if [ "$#" -ne 1 ]; then
    echo "sync_sphinx version[@]"
    echo "      Synchronizes source/conf.py version to the one given."
    echo "      For release versions it updates the changelog of"
    echo "       the release"
    echo ""
    echo "      params:"
    echo "          version[@] is the reference to an array in scope"
    echo "          created as in export version=(4 0 0)"
    echo ""
    return 1
fi
local -a current_version=("${!1}")
# Check release numbers for sphinx based projects
if [ -f source/conf.py ]; then
    local -a docversion=($(grep -E "^\s*release\s*=\s*['\"]" source/conf.py | sed -e "s@.*['\"]\(.*\)['\"]@\1@" ))
    local newver=${current_version[@]}
    newver=${newver// -/-}
    newver=${newver// /.}
    newver=${newver/-SNAPSHOT/-dev}
    echo "source/conf.py found, release version = ${newver}, doc version = ${docversion[@]}"
    sed -i -e "s@\(^\s*version\s*=\s*['\"]\).*\(['\"].*$\)@\1${newver/-dev}\2@" source/conf.py;
    sed -i -e "s@\(^\s*release\s*=\s*['\"]\).*\(['\"].*$\)@\1${newver}\2@" source/conf.py;
else
    return 100
fi
} && echo "defined sync_sphinx"



release_plugin() {
if [ "$#" -ne 4  ]; then
        echo "release_plugin project VERSION NEW_VERSION LOCAL_REPO)"
        echo ""
        echo "       Releases a maven project as two local commits and a local tag"
        echo "       Assumes the user has git set up correctly and working dir is the project root."
        echo "       Assumes develop branch"
        echo ""
        echo "  params:"
        echo "       project         Name of project to be released"
        echo "       VERSION         Version of next release"
        echo "       NEW_VERSION     Version for development after release"
        echo "       LOCAL_REPO      Local repository for install so that staged"
        echo "                       dependent project releases can proceed"
        echo "                       layering"
        echo ""
        return 1
fi
    project=$1
    VERSION=$2
    local v=${VERSION//./ }
    local -a split_version=(${v//-/ -})
    NEW_VERSION=$3
    v=${NEW_VERSION//./ }
    local -a split_new_version=(${v//-/ -})
    LOCAL_REPO=$4
    local to_commit=""

# Check that there are no uncommitted changes in the sources
if [ -n "$(git status --porcelain)" ]; then 
  echo "There are changes in the repository"
  git status
  return 2; 
fi

local want_version=${VERSION}
want_version=${want_version//-/ -}
want_version=${want_version//./ }
local -a cur_version=(${want_version}) #array MAJOR MINOR PATCH -EXTRA
# Change the version in the POMs from development to new one
sync_maven cur_version[@]

# Check that there are no SNAPSHOT dependencies
# we assume that the parent is OK, only check for our pom
if [ -n "$(xmlstarlet sel -t  -v "/_:project/_:dependencies/_:dependency/_:version[contains(.,'version')]" pom.xml 2>/dev/null | grep -- -SNAPSHOT)" ]; then
  echo "you have -SNAPSHOT dependencies"
  return 
fi

# Transform the SCM information in the POM to include the final destination of the tag
export tag="${project}-${VERSION}"
export scmtag="$(xmlstarlet sel -t  -v '/_:project/_:scm' pom.xml 2>/dev/null)" # scm was there
export devtag="$(xmlstarlet sel -t  -v '/_:project/_:scm/_:tag' pom.xml 2>/dev/null)" # scm/tag was there
if [ -n "${devtag}" -o -n "${scmtag}" ]; then # there was a tag, change
  xmlstarlet ed -O -P -L -u "/_:project/_:scm/_:tag" -v "${tag}" pom.xml
else
  xmlstarlet ed -O -P -L -s "/_:project"       -t elem -n scm pom.xml
  xmlstarlet ed -O -P -L -s "/_:project/_:scm" -t elem -n tag -v "${tag}" pom.xml
fi

# Check release numbers for maven projects
[ -f pom.xml ] && to_commit="$to_commit pom.xml"

# Check release numbers for cmake projects
sync_cmake split_version[@] && to_commit="$to_commit CMakeLists.txt"

# Check release numbers for deb projects
sync_deb split_version[@] && to_commit="$to_commit debian/changelog"

# Check release numbers for node projects
sync_node split_version[@] && to_commit="$to_commit package.json"

# Check release numbers for sphinx projects
sync_sphinx split_version[@] && to_commit="$to_commit source/conf.py"

if [ -f configure.ac ]; then # line is AC_INIT([$prokect],[1.0.3-dev])
    export autotoolsversion=($(grep AC_INIT configure.ac  | sed -e "s@AC_INIT(\[$project\],\[\(.*\)\])@\1@" | tr "." " " | sed -e "s@-\(.*\)@ \1@"))
    echo "configure.ac found, version = ${autotoolsversion[@]}"
fi


# Run the project tests against the modified POMs to confirm everything is in working order
if [ -f pom.xml ]; then
    mvn -U -Dmaven.repo.local=${LOCAL_REPO} clean verify || (echo "=== Build failed, can't release ${project}" && return 4)
    mvn -U -Dmaven.repo.local=${LOCAL_REPO} install && echo "installed in local repo for test" || (echo "=== Build failed, can't install ${project}" && return 4)
    # next line fails asking for auth in github :(
    #( cd target && fresh_checkout "${project}-test" ${VERSION} && ( cd "${project}-test" release_plugin "${project}-test" ${VERSION} ${NEW_VERSION} ${LOCAL_REPO} ||  (echo "=== Build failed, can't release ${project}-test" && return 8) ) )
fi

# Commit the modified POMs
echo "committing release..."
git add $to_commit && git commit -m "[release] ${VERSION}"
echo "tagging release..."
# Tag the code in the SCM with a version name (this will be prompted for)
git tag "${project}-${VERSION}"

# Bump the version in the POMs to a new value y-SNAPSHOT (these values will also be prompted for)
want_version=${NEW_VERSION}
want_version=${want_version//-/ -}
want_version=${want_version//./ }
cur_version=(${want_version}) #array MAJOR MINOR PATCH -EXTRA
# Change the version in the POMs from development to new one
sync_maven cur_version[@]

# reset the scm/tag to the original value
if [ -n "${devtag}" ]; then 
  xmlstarlet ed -O -P -L -u "/_:project/_:scm/_:tag" -v "${devtag}" pom.xml
elif [ -n "${scmtag}" ]; then # or delete the scm/tag element
  xmlstarlet ed -O -P -L -d "/_:project/_:scm/_:tag" pom.xml
else # or event delete the scm element
  xmlstarlet ed -O -P -L -d "/_:project/_:scm" pom.xml
fi
# Check release numbers for cmake mixed projects
sync_cmake split_new_version[@]

# Check release numbers for deb mixed projects
sync_deb split_new_version[@]

# Check release numbers for node mixed projects
sync_node split_new_version[@]

# Check release numbers for sphinx projects
sync_sphinx split_new_version[@]

# Commit the modified POMs
git add $to_commit && git commit -m "[release] Prepare for next development iteration"
} && echo "defined release_plugin"

review_commits() {
    # reviews commits from a previous release
if [ "$#" -ne 5  ]; then
        echo "review_commits project VERSION NEW_VERSION LOCAL_REPO PHASE)"
        echo ""
        echo "       Reviews release commits as a draft gerrit change."
        echo "       Assumes the user has git and gerrit set up correctly."
        echo ""
        echo "  params:"
        echo "       project         Name of project to be released"
        echo "       VERSION         Version of next release"
        echo "       NEW_VERSION     Version for further development"
        echo "       LOCAL_REPO      Local repository for install so that staged"
        echo "                       dependent project releases can proceed"
        echo "       PHASE           Arbitrary identifier indicating dependency"
        echo "                       layering"
        echo ""
        return 1
fi
    project=$1
    VERSION=$2
    NEW_VERSION=$3
    LOCAL_REPO=$4
    PHASE=$5
    cd ${project} &&\
    git checkout ${project}-${VERSION} &&\
    git review -D -y -t "release-${VERSION}_${PHASE}" &&\
    git checkout develop &&\
    git review -D -y -t "postrelease-${VERSION}_${PHASE}" || (cd .. && return 4)
    cd ..
} && echo "defined review_commits"

fresh_checkout() {
if [ "$#" -ne 2  ]; then
        echo "fresh_checkout project VERSION"
        echo ""
        echo "       Check out a fresh copy of origin/develop"
        echo "       from the repo in the current work dir."
        echo "       Cleans and reset working copy, and remove"
        echo "       any existing tags from previous release attempts"
        echo ""
        return 1
fi
        project=$1
        VERSION=$2
    # try to reuse a local repository, if it is not there clone and checkout
    if [ -d "${project}" ]; then
      echo "project: ${project}, working copy exists. Reusing it."
      #rm -rf "${project}"
      cd ${project} && \
      git remote update && git checkout develop 2>/dev/null &&\
      git reset --hard origin/develop &&\
      ( git tag -d ${project}-${VERSION} 2>/dev/null || echo "no pre-existing tag" ) ||\
            (echo "checkout failed" || return 2)
    else
      # git clone ssh://repository.kurento.com:12345/${project} && cd ${project} && git checkout develop
      git clone "https://github.com/Kurento/${project}.git" && cd ${project} && git checkout develop 2>/dev/null ||\
            (echo "checkout failed" || return 2)
    fi
    cd ..
} && echo "defined fresh_checkouts"

release_maven_project() {
    # releases a project
if [ "$#" -ne 5  ]; then
        echo "release_maven_project project VERSION NEW_VERSION LOCAL_REPO PHASE)"
        echo ""
        echo "       Releases a maven project as a draft gerrit change."
        echo "       Assumes the user has git and gerrit set up correctly."
        echo ""
        echo "  params:"
        echo "       project         Name of project to be released"
        echo "       VERSION         Version of next release"
        echo "       NEW_VERSION     Version for further development"
        echo "       LOCAL_REPO      Local repository for install so that staged"
        echo "                       dependent project releases can proceed"
        echo "       PHASE           Arbitrary identifier indicating dependency"
        echo "                       layering"
        return 1
fi
    project=$1
    VERSION=$2
    NEW_VERSION=$3
    LOCAL_REPO=$4
    PHASE=$5
    fresh_checkout ${project} ${VERSION} || return 1 
    cd ${project} 
    git review -s || return 1
    release_plugin ${project} ${VERSION} ${NEW_VERSION} ${LOCAL_REPO} || (echo "Release Failed, project ${version}" && cd .. && return 4)
    git checkout ${project}-${VERSION} 2>/dev/null && echo "checked out release for install" &&\
    ( [ -f pom.xml ] && mvn -Dmaven.repo.local=${LOCAL_REPO} clean install || return 4 ) &&\
    git checkout develop  2>/dev/null && echo "checked out back develop" && cd .. && return
    cd .. && return 8
} && echo "defined release_maven_project"

release_interf_project() {
    # releases a project
if [ "$#" -ne 5  ]; then
        echo "release_interf_project project VERSION NEW_VERSION LOCAL_REPO PHASE"
        echo ""
        echo "       Releases a mixed maven/thrift project as a draft gerrit change."
        echo "       Assumes the user has git and gerrit set up correctly."
        echo ""
        echo "  params:"
        echo "       project         Name of project to be released"
        echo "       VERSION         Version of next release"
        echo "       NEW_VERSION     Version for further development"
        echo "       LOCAL_REPO      Local repository for install so that staged"
        echo "                       dependent project releases can proceed"
        echo "       PHASE           Arbitrary identifier indicating dependency"
        echo "                       layering"
        return 1
fi
    project=$1
    VERSION=$2
    NEW_VERSION=$3
    LOCAL_REPO=$4
    PHASE=$5
    fresh_checkout ${project} ${VERSION} || return 2
    cd ${project} &&\
    git review -s &&\
    release_plugin ${project} ${VERSION} ${NEW_VERSION} ${LOCAL_REPO} &&\
    git checkout ${project}-${VERSION} &&\
    mvn -Dmaven.repo.local=${LOCAL_REPO} clean install && git review -D -y -t "release-${VERSION}_${PHASE}" &&\
    git checkout develop &&\
    git review -D -y -t "postrelease-${VERSION}_${PHASE}" || (cd .. && return 4)
    cd ..
}

release_phase() {
if [ "$#" -lt 5  ]; then
        echo "release_phase PHASE VERSION NEW_VERSION LOCAL_REPO projects[@] [ test_projects[@] ]"
        echo ""
        echo "       Releases a number of projects."
        echo "       Assumes the user has git and gerrit set up correctly."
        echo ""
        echo "  params:"
        echo "       PHASE           Arbitrary identifier indicating dependency"
        echo "                       layering"
        echo "       VERSION         Version of release"
        echo "       NEW_VERSION     Version to be used for development"
        echo "       LOCAL_REPO      Local repository for install so that dependent"
        echo "                       dependent project releases can proceed"
        echo "       projects        Array of projects to be released"
        echo "       test_projects   Optional array of test projects to be tested"
        return 1
else
    PHASE=$1
    VERSION=$2
    NEW_VERSION=$3
    LOCAL_REPO=$4
    declare -a projects=("${!5}")
    declare -a test_projects=("${!6}")
fi
    mkdir -p ${PHASE}
    cd ${PHASE} && echo "chdir to $(pwd) for release PHASE ${PHASE}"
    echo ""
    echo "===== RELEASE PHASE ${PHASE} ====="
    echo "===== Releasing ${projects[@]} with test projects ${test_projects[@]} ====="
    echo "====="
    echo ""
    for project in ${projects[@]};
    do
        release_maven_project ${project} ${VERSION} ${NEW_VERSION} ${LOCAL_REPO} ${PHASE} || (echo "error in project ${project}" && return 2)
        echo "Release of ${project} suceeded!"
    done
    for project in ${test_projects[@]};
    do
        release_maven_project ${project} ${VERSION} ${NEW_VERSION} ${LOCAL_REPO} ${PHASE} || (echo "error in test project ${project}" && return 2)
    done
    for project in ${projects[@]};
    do
        review_commits ${project} ${VERSION} ${NEW_VERSION} ${LOCAL_REPO} ${PHASE}  || (echo "error reviewing ${project} commits" && return 2)
    done
    for project in ${test_projects[@]};
    do
        review_commits ${project} ${VERSION} ${NEW_VERSION} ${LOCAL_REPO} ${PHASE} || (echo "error reviewing ${project} commits" && return 2)
    done
    cd .. && echo "chdir back to $(pwd)"
} && echo "defined release_phase"

release_all() {
if [ "$#" -ne 3  ]; then
        echo "release_all VERSION NEW_VERSION LOCAL_REPO"
        echo ""
        echo "       Releases kurento projects."
        echo "       Assumes the user has git and gerrit set up correctly."
        echo ""
        echo "  params:"
        echo "       VERSION         Version of release"
        echo "       NEW_VERSION     Version to be used for development"
        echo "       LOCAL_REPO      Local repository for install so that dependent"
        return 1
else
    VERSION=$1
    NEW_VERSION=$2
    LOCAL_REPO=$3
fi
    local maven_round_minus_one="kmf-parent-pom"

    local maven_round_zero=(kmf-commons kmf-spring kmf-content-protocol kms-interface)
    local node_round_zero=(kws-rpc-builder)
    local zee_round_zero=(kms-dtls-plugins)

    local maven_round_one=(kmf-repository-api kmf-jsonrpcconnector)
    local maven_round_one_test=(kmf-repository-api-test kmf-jsonrpcconnector-test)
    local node_round_one=(kws-content-api kws-media-api)
    local zee_round_one=(gst-kurento-plugins)

    local maven_round_two=(kmf-thrift-interface ${maven_round_one_test[@]})
    local zee_round_two=(kurento-media-server)

    local maven_round_three=(kmf-media-api)
    local maven_round_three_test=(kmf-media-api-test)

    local maven_round_four=(kmf-content-api kmf-media-connector)
    local maven_round_four_test=(kmf-content-api-test kmf-media-connector-test)

    local maven_round_five=(kmf-content-demo fi-lab-demo doc-kurento)

    echo "------>release phase from $(pwd)"
    release_phase minus_one ${VERSION} ${NEW_VERSION} ${LOCAL_REPO} maven_round_minus_one[@] || (echo "error in phase minus_one" && return 2)
    echo "------>release phase from $(pwd)"
    release_phase zero      ${VERSION} ${NEW_VERSION} ${LOCAL_REPO} maven_round_zero[@] || (echo "error in phase zero" && return 2)
    release_phase zero      ${VERSION} ${NEW_VERSION} ${LOCAL_REPO} interf_round_zero[@] || (echo "error in phase zero" && return 2)
    release_phase zero      ${VERSION} ${NEW_VERSION} ${LOCAL_REPO} node_round_zero[@] || (echo "error in phase zero" && return 2)
    echo "------>release phase from $(pwd)"
    release_phase one       ${VERSION} ${NEW_VERSION} ${LOCAL_REPO} maven_round_one[@]  maven_round_one_test[@] || (echo "error in phase one" && return 2)
    echo "------>release phase from $(pwd)"
    release_phase two       ${VERSION} ${NEW_VERSION} ${LOCAL_REPO} maven_round_two[@]  maven_round_two_test[@] || (echo "error in phase two" && return 2)
    echo "------>release phase from $(pwd)"
    release_phase three     ${VERSION} ${NEW_VERSION} ${LOCAL_REPO} maven_round_three[@] maven_round_three_test[@] || (echo "error in phase three" && return 2)
    echo "------>release phase from $(pwd)"
    release_phase four      ${VERSION} ${NEW_VERSION} ${LOCAL_REPO} maven_round_four[@] maven_round_four_test[@] || (echo "error in phase four" && return 2)
    echo "------>release phase from $(pwd)"
    release_phase five      ${VERSION} ${NEW_VERSION} ${LOCAL_REPO} maven_round_five[@] maven_round_five_test[@] || (echo "error in phase five" && return 2)
} && echo "defined release_all"

usage() {
   echo """
This is as script to perform releases in kurento.

Functions:

* $(release_all)

* $(release_phase)

* $(release_maven_project)

* $(release_plugin)

* $(fresh_checkout)

""" | less
}

if [ "$#" -eq 0  ]; then
    usage;
elif [ "$1" == "-h"  ]; then
    usage;
else
    "$@";
fi
