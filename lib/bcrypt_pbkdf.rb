module BCryptPbkdf
end

begin
  RUBY_VERSION =~ /(\d+.\d+)/
  require "#{$1}/bcrypt_pbkdf_ext"
rescue LoadError
  puts "GOT:bcrypt_pbkdf_ext\n"
  require "bcrypt_pbkdf_ext"
end
