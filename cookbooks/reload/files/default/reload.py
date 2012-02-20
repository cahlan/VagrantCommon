##
# This is here to run a command when a folder is changed
# 
# also check out Pexpect if we ever want to make this more bulletproof
# http://www.noah.org/wiki/Pexpect
# 
# @example
#   python monitor.py -h
#
# @since  2-3-12
##
 
# import os
# 
# p = os.popen('ls -R -l /vagrant',"r")
# while 1:
#     line = p.readline()
#     if not line: break
#     print line


import subprocess, hashlib, time, syslog, argparse

# http://docs.python.org/library/argparse.html#module-argparse
parser = argparse.ArgumentParser(description='Run a command when monitored folder contents change')
parser.add_argument('--dir', help='the directory to monitor',required=True)
parser.add_argument('--filter',default="", help='a regex to filter the monitor command through')
parser.add_argument('--cmd', help='The command to run when a change is found in --dir', required=True)
parser.add_argument('--daemonize','-d', default=False, action='store_true', help='send output to syslog')
parser.add_argument('--interval', default=2, type=int, help='how many seconds between check')

args = parser.parse_args()

# error handling
# if not args.cmd:
#   raise NameError("--cmd not passed in")
#   parser.print_help()
# if not args.dir:
#   raise NameError("--dir not passed in")
#   parser.print_help()

monitor_cmd = 'ls -R -l %s' % args.dir
# pass the output through a filter if available
if args.filter:
  monitor_cmd = 'ls -R -l %s | grep -iE "%s"' % (args.dir,args.filter)

cmd = args.cmd
daemonize = args.daemonize
interval = args.interval
last_hash = ''

while True:
  
  p = subprocess.Popen(monitor_cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,shell = True)
  
  output, errors = p.communicate()
  
  current_hash = hashlib.md5(output).hexdigest() # http://www.dreamincode.net/code/snippet1851.htm
  if last_hash:
    if current_hash != last_hash: 
    
      p2 = subprocess.Popen(cmd,stdout=subprocess.PIPE,stderr=subprocess.PIPE,shell = True)
      output, errors = p2.communicate() 
      result = ''
      
      if errors:
        result = 'Command Failed to run "%s" with return code %s and output: %s %s' % (cmd,p2.returncode,output,errors)
      else:
        result = 'Succesfully ran "%s"' % (cmd)
      
      if daemonize:
        # syslog.syslog(syslog.LOG_ERR,result)
        syslog.syslog(syslog.LOG_ERR,result) 
      else:
        print result
  
  last_hash = current_hash 
  time.sleep(interval)
  
