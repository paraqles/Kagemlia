root_dir = File.dirname File.absolute_path File.dirname __FILE__

spec_dir = Dir.new( root_dir + '/spec' )

spec_dir.each do | file |
  puts file if file =~ /.*\.rb/
end
