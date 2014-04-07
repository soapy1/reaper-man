module Reaper

  class Signer

    autoload :Rpm, 'reaper/signer/rpm'
    autoload :Deb, 'reaper/signer/deb'
    autoload :Rubygems, 'reaper/signer/rubygems'

    include Utils::Process

    attr_reader :key_id, :sign_chunk_size, :sign_type, :package_system, :key_password

    def initialize(args={})
      args = args.to_rash
      @key_id = args[:signing_key]
      @sign_chunk_size = args.fetch(:signing_chunk_size, 1)
      @sign_type = args.fetch(:signing_type, 'origin')
      @key_password = args.fetch(:key_password, ENV['REAPER_KEY_PASSWORD'])
      @package_system = args[:package_system]
      case package_system.to_sym
      when :deb, :apt
        extend Deb
      when :rpm, :yum
        extend Rpm
      when :gem, :rubygems
        extend Rubygems
      else
        raise TypeError.new "Unknown packaging type requested (#{package_system})"
      end
    end

    def file(src, dst=nil)
      opts = ['--detach-sign', '--armor']
      dst ||= src.sub(/#{Regexp.escape(File.extname(src))}$/, '.gpg')
      opts << "--output '#{dst}'"
      cmd = (['gpg'] + opts + [src]).join(' ')
      shellout!(cmd)
    end

  end

end
