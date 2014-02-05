require 'yaml'

class VideoProcess
  @queue = :video_process

  def self.perform(session_name)
    candidate_file = "#{session_name}|candidate.flv"
    expert_file = "#{session_name}|expert.flv"

    self.video_merge candidate_file, expert_file

    puts "session name = #{session_name}"
  end

  def self.video_merge(left, right)
    self.load_config
  end

  def self.load_config
    config = YAML::load(File.open(__dir__  + '/../config/video_process.yml'))
    .inject({}){|storage,(k,v)| storage[k.to_sym] = v; storage}
    config.merge!({
        command: 'ffmpeg',
        padding: config[:video_w] + config[:video_space],
        overlay: config[:video_w] * 2 + config[:video_space]
    })

    p config
  end

end