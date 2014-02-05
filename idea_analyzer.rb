require "resque"
require "./jobs/video_process"

idea = ARGV
puts "Analyzing your idea: #{idea.join(" ")}"
idea.each do |word|
  puts "Asking for a job to analyze: #{word}"
  Resque.enqueue(VideoProcess, word)
end