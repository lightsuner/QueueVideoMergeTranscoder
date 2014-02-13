require "resque"
require './lib/base_job'
require "./jobs/video_process"
require "./jobs/file_move"
require "./jobs/update_video_status"


#VideoProcess.perform 'test'
#FileMove.perform '/Users/alkuk/Movies/test.flv'