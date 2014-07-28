#!/usr/bin/env python
"""
	Module create_jobs.py
	>>> create_job('test1', 'unknown', '', '')
	Traceback (most recent call last):
	  ...
	    raise ValueError('kind not in ' + str(list(known_types)))
	ValueError: kind not in ['maven', 'C', 'sphinx']
"""

import re, os, errno
from os import popen
import datetime

parse_vars = re.compile("<\$--{(?P<var>,?\w*)}-->", re.S|re.M)
macro_vars = {
    'date'    : datetime.datetime.now().strftime('%Y/%m/%d'),
    'time'    : datetime.datetime.now().strftime('%H:%M:%S'),
    'version' : popen('git describe --tags --always').read().strip()
}
parse_feature = re.compile("<!--{(?P<feature>,?\w*)}(?P<body>.*?)(--!{(?P=feature)}--(?P<altbody>.*?))?{(?P=feature)}-->", re.S|re.M)
known_types = {'sphinx', 'maven', 'C'}
project_features=[]
project_type=None
known_options = {'--features','--dir'}
known_features = dict(api          = 'For api projects, show javadoc warning on plain builds, for doc purposes',
                      arquillian   = 'job includes in container tests run by arquillian, uses jBoss and random ports',
                      autotools    = 'C job uses autotools to build, if not present cmake is assumed',
                      c_interfaces = 'wants to build C interfaces using ./build.sh post build',
                      emma         = 'job instruments with emma at android phone for code coverage',
                      emulator     = 'job uses android emulator for tests',
                      debug        = 'use a debug flag and don\'t fail or vote on failure',
                      dontdeploy   = 'don\'t deploy the project. For test and demo projects',
                      gwt          = 'gwt project, needs "release" profile to deploy',
                      internal     = 'deploy releases to internal repository',
                      kurento      = 'needs a Media Server instance: -Dkurento.properties.dir=<path_to_kurento.properties>',
                      kurento2     = 'needs a Media Server instance: -Dkurento.serverAddress=<serverip> -Dkurento.handlerAddress=<handlerip>',
                      node         = 'needs to delete node_modules directory in workspace before execution',
                      httpport     = 'Safe TCP port for tests, as "-http.port=${HTTP_PORT}"',
                      selenium     = 'selenium projects need to start Xvfb to support browsers',
                      testaggregator = 'use jenkins downstream project test aggregator',
                      binarch      = 'generate separate jobs for 32 and 64 bit archs'
                 )
target_dir = '../../jobs'
jobs = {'', '_merged', '_release'}


#
# config['maven'] is a template maven project configuration.
# it assumes that the ${projectname} variable will have a value
# also, it will conditionally include the <!--{feature_name}.*{feature_name}--> sections
# and create alternative !<--{}.*{}--><!--{_merged}.*{_merged}--> jobs
#
config = dict()
for buildtype in known_types:
    config[buildtype] = file('config-%s.xml' % (buildtype,)).read()

usage_string = """
Creates jenkins jobs for Kurento projects.
    project_name: the gerrit project name
    project_type: one of """ + ', '.join(sorted(known_types)) + """
    features    : comma separated optional features of the builds. Currently:
"""
for feature in sorted(known_features.keys()):
	usage_string += "      * " + feature + " -> " + known_features[feature] + '\n'
usage_string += """    target_dir  : dir where <jobname>/config.xml is written
                  default is ../../jobs (suitable for running from ~jenkins/tools/jenkins-job-creator"""

def usage(args, reason):
	print "Error       :", reason
	print "Usage       :", args[0], "project_name project_type  [--features feature,...] [--dir <target_dir>]"
	print usage_string

def check_template(name, template):
        """
	Check that features in the template are all known

	>>> for name,template in config.items():
	...     check_template(name, template)
	...
	>>>
        """
	errors = set(m.groupdict()['feature'] for m in parse_feature.finditer(template)) - set(known_features.keys()) - set(('', '_merged', '_release', 'dodebug', '32bits')) - set(('deploy',))
        if errors:
		print "Error: template", name,"has features not documented:", errors

def check_arguments(argv):
	"""
		Check the arguments to the script.
		Print usage and return False if the arguments are not correct.
		Return True if the checks pass

		>>> import sys
		>>> check_arguments(['c', 'test']) #doctest: +ELLIPSIS
		Error       : Too few arguments
		Usage       : c project_name project_type  [--features feature,...] [--dir <target_dir>]
		<BLANKLINE>
		Creates jenkins jobs for Kurento projects.
		    project_name: the gerrit project name
		    ...
		False
		>>> check_arguments(['myself', 'test','test']) #doctest: +ELLIPSIS
		Error       : project_type must be one of ['maven', 'C', 'sphinx']
		...
		False
		>>> check_arguments(['myself', 'test_project', 'maven','emma arquillian']) #doctest: +ELLIPSIS
		Error       : Extra argument(s): ['emma arquillian']
		...
		False
		>>> check_arguments(['myself', 'test_project', 'maven','--features']) #doctest: +ELLIPSIS
		Error       : option --features requires comma separated list of features
		...
		False
		>>> check_arguments(['myself', 'test_project', 'maven','--features', 'emma arquillian']) #doctest: +ELLIPSIS
		Error       : unknown feature 'emma arquillian'
		...
		False
		>>> check_arguments(['myself', 'test_project', 'maven','--features', 'emma,arquillian']) #doctest: +ELLIPSIS
		True
		>>> check_arguments(['myself', 'test_project', 'maven','--dir']) #doctest: +ELLIPSIS
		Error       : option --dir requires a directory
		...
		False
		>>> check_arguments(['myself', 'test_project', 'maven','--dir', '/etc']) #doctest: +ELLIPSIS
		Error       : --dir value (/etc) should be writable
		...
		False
	"""
	global project_name, project_type, project_features, target_dir
	if len(argv) < 3:
		usage(argv, "Too few arguments")
		return False
	if len(argv) > 7:
		usage(argv, "Too many arguments")
		return False
	# FIXME validate project name
	project_name = argv[1]
	if argv[2] not in known_types:
		usage(argv, "project_type must be one of " + str(list(known_types)))
		return False
	project_type=argv[2]
	if project_type not in known_types:
		print "Unknown project type:", project_type
	options = {opt for opt in argv[3:] if opt.startswith('--')}
	unknown_options = options - known_options
	if len(unknown_options) > 0:
		print "Unknown option(s):", list(unknown_options)
		return False
	if '--features' in argv:
		where = argv.index('--features')
		if where == len(argv)-1:
			usage(argv, "option --features requires comma separated list of features")
			return False
		project_features = [f.strip() for f in argv[where+1].split(',') if f.strip()]
		for feature in project_features:
			if feature not in known_features.keys():
				usage(argv, "unknown feature '" + feature + "'")
				return False
		argv=argv[:where]+argv[where+2:]
	if '--dir' in argv:
		where = argv.index('--dir')
		if where == len(argv)-1:
			usage(argv, "option --dir requires a directory")
			return False
		target_dir = argv[where+1]
		# check target_dir exists, is a directory and can be written/executed
		if not os.access(target_dir, os.W_OK):
			usage(argv, "--dir value (" + target_dir + ") should be writable")
			return False
		argv=argv[:where]+argv[where+2:]
	if len(list(arg for arg in argv[3:] if not arg.startswith('--'))) > 0:
		usage(argv, "Extra argument(s): " + str([arg for arg in argv[3:] if not arg.startswith('--')]))
		return False
	return True

def create_job(project_name, kind, features, target_dir):
	"""
		Returns a config.xml for a jenkins job that would build the given project.

		>>> create_job('test','test','','')
		Traceback (most recent call last):
		  ...
		    raise ValueError('kind not in ' + str(list(known_types)))
		ValueError: kind not in ['maven', 'C', 'sphinx']

	"""
	if kind not in known_types:
		raise ValueError('kind not in ' + str(list(known_types)))

def sub_project_name(config, name):
    """
        substitutes a number of variables in a template string

        >>> sub_project_name('${projectname} ${escapedprojectname} com.kurento.${groupid} ${artifactid}', 'kas-api')
        'kas-api kas-api com.kurento.kas kas-api'
        >>> sub_project_name('${projectname} ${escapedprojectname} com.kurento.${groupid} ${artifactid}', 'app-and-hnj-uci-user')
        'app-and-hnj-uci-user app-and-hnj-uci-user com.kurento.hnj hnj-uci-user'
    """
    conf = config
    known_variables = ['projectname',          # for instance kas/kas-api
                           'escapedprojectname',   # url escaped version of projectname
                           'groupid',              # com.kurento.${projectname/\/*/}
	                   'artifactid',           # ${projectname/*\//}
                           ]
    values = dict( projectname        = name,
                   escapedprojectname = '%2F'.join(name.split('/')),
                   groupid            = name.split('-')[-3] if len(name.split('-'))>2 else name.split('-')[0],
                   artifactid         = '-'.join(name.split('-')[-3:]),
                 )
    for key, value in values.iteritems():
        conf = re.sub('\${'+key+'}', value, conf)
    return conf

def remove_markers(text, f):
    """
        Removes template markers from text
        >>> remove_markers("text1<!--{feature}text2{feature}-->", 'feature')
        'text1text2'
    """
    res = text
    res = ''.join(re.split('<!--{' + f + '}', res, 1))
    return ''.join(re.split('{' + f + '}-->', res, 1))

def make_sure_path_exists(path):
    try:
        os.makedirs(path)
    except OSError as exception:
        if exception.errno != errno.EEXIST:
            raise

def subst_feature(config, features):
        result = config
        print "VAR SUBST:"
        fragment = parse_vars.search(result)
        while fragment:
            varname = fragment.groupdict()['var']
            if varname in macro_vars:
                result = result[:fragment.start()] + macro_vars[varname] + result[fragment.end():]
            fragment = parse_vars.search(result)
        print "SUBST:", config
        fragment = parse_feature.search(result)
        while fragment:
            feature = fragment.groupdict()['feature']
            #print "===feature===",feature,'for job', j
            if (feature in features) or (feature == job):
                # include main part
                print '+{'+feature+'}',
                result = result[:fragment.start()] +  subst_feature(fragment.groupdict()['body'] ,features) + result[fragment.end():]
            else:
                # include else part
		if fragment.groupdict()['altbody']:
                    print "*{"+feature+'}', fragment.groupdict()['altbody']
                    result = result[:fragment.start()] +  subst_feature(fragment.groupdict()['altbody'], features) + result[fragment.end():]
		else:
                    # remove feature/job
                    result = result[:fragment.start()] + result[fragment.end():]
                    print '-{'+feature+'}',
            #print "=== end feature===",feature,'for job', j
            fragment = parse_feature.search(result)
        #assert "<!--{" not in result, result
        return result

if __name__ == '__main__':
    """
		Module create_jobs.py
		>>> create_jobs test1 unknown
		project_type must be one of ['maven', 'C']
    """
    import sys
    success = check_arguments(sys.argv)
    if not success:
        sys.exit(-1)
    if 'debug' in project_features:
        jobs.add('_debug')
    if 'binarch' in project_features:
        jobs.add('_32')
        if 'dontdeploy' not in project_features:
            jobs.add('_merged_32')
        if 'debug' in project_features:
            jobs.add('_32_debug')
    print '=== Creating config for job of type' + project_type +  '==='
    for job in jobs:
        job_config = config[project_type]
        jobname = '_'.join(project_name.split('/'))
        if job:
            jobname = jobname + job
        job_features = list(project_features)
        if 'binarch' in job_features and ( job == '_32' or job == '_32_debug' ):
            job_features.append('') # _32 is a 'plain' job
            job_features.append('32bits')
        if job == '_merged_32':
            job_features.append('_merged')
            job_features.append('32bits')
        if ( job == '_merged' or job == '_release') and 'dontdeploy' not in project_features:
            job_features.append('deploy')
        if ( job == '_debug' or job == '_32_debug'):
            if '' not in job_features: job_features.append('') # debug is a 'plain' job
            job_features.append('dodebug')
        print "JF:",job_features
        # remove the nonrelevant 'job' in config[project_type]
        #for j in jobs-set(job):
        #    job_config = ''.join(re.split('<!--{' + j +'}.*{' + j + '}-->', job_config))
        # substitute the project_name variables
        job_config = sub_project_name(job_config, project_name)
        print "creating job '" + jobname + "'"
        # select the right job from config_<type>
        job_cfg = subst_feature(job_config, job_features)
        # if not exists mkdir target_dir + '/' + jobname
        make_sure_path_exists(target_dir + '/' + jobname)
        print 'saving at', jobname
        f = file( target_dir + '/' + jobname + '/config.xml', 'w')
        f.write(job_cfg)
        f.close()
