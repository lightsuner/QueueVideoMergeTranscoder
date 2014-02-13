require 'yaml'
require 'fileutils'

class BaseJob

  # initialize config
  def load_config
    config_file = self.class.instance_variable_get :@config_file

    if config_file.nil? || config_file.empty?
      return
    end

    @config = YAML::load(File.open(__dir__ + "/../config/#{config_file}.yml"))
    .inject({}) { |storage, (k, v)| storage[k.to_sym] = v; storage }

  end


  # make new directory (recursive) if it doesn't exist
  def prepare_output_dir(dir_path)
    unless Dir.exists?(dir_path)
      FileUtils.mkpath dir_path
    end

  end

end