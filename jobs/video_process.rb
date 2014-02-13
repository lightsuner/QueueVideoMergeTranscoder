class VideoProcess < BaseJob
  @queue = :video_process
  @config_file = 'video_process'

  def self.perform(session_name)
    new(session_name).video_merge
  end

  def initialize(session_name)
    @session_name = session_name
    @candidate_file = "#{@session_name}|candidate.flv"
    @expert_file = "#{@session_name}|expert.flv"

    load_config
  end

  def video_merge()
    left_video = @config[:src_path]+@candidate_file
    right_video = @config[:src_path]+@expert_file

    unless File.exists?(left_video)
      raise "The file '#{left_video}' does not exist!"
    end

    unless File.exists?(right_video)
      raise "The file '#{right_video}' does not exist!"
    end

    prepare_output_dir @config[:dest_path]

    output_video = "#{@config[:dest_path]}#{@session_name}.#{@config[:output_ext]}"

    filter = generate_filter

    args = strip_spaces %Q|
      -i "#{left_video}"
      -i "#{right_video}"
      -filter_complex "#{filter}"
      -map "[out]"
      -y
      #{@config[:output_format]}
      #{output_video}
    |

    command = "#{@config[:command]} #{args} 2>&1" #2>&1 - move error to output

    output = `#{command}`

    unless $?.success?
      raise output
    end

    Resque.enqueue(FileMove, output_video)

    File.delete left_video, right_video

  end

  def generate_filter
    strip_spaces %Q!
      [0:v]scale=#{@config[:video_w]}:#{@config[:video_h]}, setpts=PTS-STARTPTS,
      pad=#{@config[:overlay]}:#{@config[:video_h]}:color=#{@config[:pad_color]}[left];
      [1:v]scale=#{@config[:video_w]}:#{@config[:video_h]}, setpts=PTS-STARTPTS[right];
      [left][right]overlay=#{@config[:padding]}:0[out];
      amix=inputs=2:duration=first
    !
  end

  def load_config

    super

    @config.merge!({
                       command: 'ffmpeg',
                       padding: @config[:video_w] + @config[:video_space],
                       overlay: @config[:video_w] * 2 + @config[:video_space]
                   })
  end

  # Strip multi spaces to one and remove new line symbol
  def strip_spaces(string)
    string.gsub("\n",'').gsub(/\s+/, ' ').strip!
  end

end