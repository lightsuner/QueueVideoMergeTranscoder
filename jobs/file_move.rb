class FileMove < BaseJob
  @queue = :file_move
  @config_file = 'file_move'

  def self.perform(file_path)
    new(file_path).move
  end

  def initialize(file_path)
    @file_path = file_path
    @file_name = File.basename(@file_path)

    load_config
  end

  def move
    unless File.exists?(@file_path)
      raise "The file '#{@file_path}' does not exist!"
    end

    prepare_output_dir @config[:dest_path]

    new_file_path = @config[:dest_path]+@file_name

    FileUtils.mv @file_path, new_file_path

    FileUtils.chmod 0755, new_file_path

    Resque.enqueue(UpdateVideoStatus, new_file_path)

  end

end