require "resque"
require './lib/base_job'
require "./jobs/video_process"
require "./jobs/file_move"
require "./jobs/update_video_status"
require "resque/tasks"

Resque.logger = Logger.new STDOUT
Resque.logger.level = Logger::DEBUG
Resque.logger.info "Resque Logger Initialized!"
