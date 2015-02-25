# set path to app that will be used to configure unicorn,
# note the trailing slash in this example
@dir = File.expand_path '../../', File.dirname(__FILE__)

worker_processes 2
working_directory @dir

timeout 30

# Specify path to socket unicorn listens to,
# we will use this in our nginx.conf later
listen "/var/lib/inventory/unicorn.sock", :backlog => 64

# Set process id path
pid "/var/run/inventory/unicorn.pid"

# Set log file paths
stderr_path "/var/log/inventory/unicorn-error.log"
stdout_path "/var/log/inventory/unicorn.log"
