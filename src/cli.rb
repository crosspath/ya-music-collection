# frozen_string_literal: true

require "logger"

class CLI
  private

  def create_logger(file_name)
    Logger.new(File.expand_path("../#{file_name}", __dir__))
  end

  def raise_if_not_writable_file(file_name)
    test_name = File.exist?(file_name) ? file_name : File.dirname(file_name)
    raise("File is not writable!") if !File.writable?(test_name)
  end
end
