# frozen_string_literal: true
require 'uri'
require 'net/http'


module VMaf
  extend Rake::DSL

  DOWNLOADS_BASE_URL = 'https://github.com/Netflix/vmaf/archive'
  VERSION = ENV['VMAF_VERSION']
  TARBALL_EXT = '.tar.xz'
  PREFIX = ENV['VMAF_DIR']

  BASE_NAME = "vmaf-#{VERSION}"
  SRC_TARBALL = "#{VMAF_BUILD_DIR}/#{BASE_NAME}#{TARBALL_EXT}"
  SRC_DIR = "#{VMAF_BUILD_DIR}/#{BASE_NAME}"
  BUILD_DIR = "#{VMAF_BUILD_DIR}/#{ENV['STACK']}/#{BASE_NAME}"

  directory PREFIX
  file PREFIX => ["#{BUILD_DIR}/Makefile"] do |t|
    Dir.chdir File.dirname t.prerequisites.first do
      sh 'make'
      sh 'make', 'install'
    end
  end
  CLEAN << PREFIX

  file "#{BUILD_DIR}/Makefile" => [BUILD_DIR] do |t|
    prefix = File.absolute_path PREFIX
    Dir.chdir File.dirname t.name do
    end
  end

  directory BUILD_DIR
  CLEAN << BUILD_DIR

  file SRC_TARBALL do |t|
    uri = URI "#{DOWNLOADS_BASE_URL}/#{File.basename t.name}"
    rake_output_message "Download #{uri} to #{t.name}"
    File.write t.name, Net::HTTP.get(uri)
  end
  CLOBBER << SRC_TARBALL
end
