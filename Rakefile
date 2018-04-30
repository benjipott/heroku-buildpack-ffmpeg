# frozen_string_literal: true
require 'rake/clean'
require 'aws-sdk'

ENV['STACK'] ||= case `lsb_release -irs`.chomp.split
                   when ['Ubuntu', '14.04'] then 'cedar-14'
                   when ['Ubuntu', '16.04'] then 'heroku-16'
                   else abort 'Cannot recognize Heroku Stack'
                 end
ENV['AWS_REGION'] ||= 'us-east-1'
ENV['FFMPEG_S3_BUCKET'] ||= 'kc-heroku-buildpack-binaries'
ENV['FFMPEG_VERSION'] ||= '4.0'
ENV['VMAF_S3_BUCKET'] ||= ENV['FFMPEG_S3_BUCKET']
ENV['VMAF_VERSION'] ||= 'v1.3.1'

abort 'Config var FFMPEG_DIR must be set.' unless ENV['FFMPEG_DIR']
abort 'Config var VMAF_DIR must be set.' unless ENV['VMAF_DIR']

FFMPEG_BUILD_DIR = "#{ENV['FFMPEG_DIR']}.build"
FFMPEG_TARBALL = "#{FFMPEG_BUILD_DIR}/#{ENV['STACK']}/#{ENV['FFMPEG_VERSION']}.tar.xz"
VMAF_BUILD_DIR = "#{ENV['VMAF_DIR']}.build"
VMAF_TARBALL = "#{VMAF_BUILD_DIR}/#{ENV['STACK']}/#{ENV['VMAF_VERSION']}.tar.xz"

task default: [:dist]

#VMAF

desc "Upload custom-build binaries to be accessible by FFmpeg Heroku buildpack."
task dist: [VMAF_TARBALL] do |t|
  key = "ffmpeg/#{ENV['STACK']}/#{ENV['VMAF_VERSION']}.tar.xz"
  rake_output_message "Upload Vmaf binaries to s3://#{ENV['VMAF_S3_BUCKET']}/#{key}"
  Aws::S3::Client.new.
      put_object bucket: ENV['FFMPEG_S3_BUCKET'],
                 key: key,
                 body: File.open(t.prerequisites.first),
                 acl: 'public-read'
end

file VMAF_TARBALL => [ENV['VMAF_DIR'], VMAF_BUILD_DIR] do |t|
  excludes = %w[include share/man share/vmaf/examples]
  exclude_args = excludes.map {|x| ['--exclude', x]}.flatten
  sh 'tar', '-cJf', t.name, '-C', t.prerequisites.first,
     *exclude_args, '.'
end
CLEAN << VMAF_TARBALL

directory File.dirname(VMAF_TARBALL)
CLOBBER << File.dirname(VMAF_TARBALL)

#FFMPEG

desc "Upload custom-build binaries to be accessible by FFmpeg Heroku buildpack."
task dist: [FFMPEG_TARBALL] do |t|
  key = "ffmpeg/#{ENV['STACK']}/#{ENV['FFMPEG_VERSION']}.tar.xz"
  rake_output_message "Upload FFmpeg binaries to s3://#{ENV['FFMPEG_S3_BUCKET']}/#{key}"
  Aws::S3::Client.new.
      put_object bucket: ENV['FFMPEG_S3_BUCKET'],
                 key: key,
                 body: File.open(t.prerequisites.first),
                 acl: 'public-read'
end

file FFMPEG_TARBALL => [ENV['FFMPEG_DIR'], FFMPEG_BUILD_DIR] do |t|
  excludes = %w[include share/man share/ffmpeg/examples]
  exclude_args = excludes.map {|x| ['--exclude', x]}.flatten
  sh 'tar', '-cJf', t.name, '-C', t.prerequisites.first,
     *exclude_args, '.'
end
CLEAN << FFMPEG_TARBALL

directory File.dirname(FFMPEG_TARBALL)
CLOBBER << File.dirname(FFMPEG_TARBALL)
