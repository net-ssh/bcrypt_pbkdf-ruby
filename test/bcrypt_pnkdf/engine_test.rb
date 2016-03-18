require 'minitest/autorun'
require 'test_helper'

# bcrypt_pbkdf in ruby using libsodium
require 'rbnacl/libsodium'
require 'rbnacl'
require 'rbnacl/hash'

BCRYPT_BLOCKS = 8
BCRYPT_HASHSIZE = BCRYPT_BLOCKS * 4

def bcrypt_pbkdf(password, salt, keylen, rounds)
  stride = (keylen + BCRYPT_HASHSIZE - 1) / BCRYPT_HASHSIZE
  amt = (keylen + stride - 1) / stride

  sha2pass = RbNaCl::Hash.sha512(password)
  puts "[RB] sha2pass:#{sha2pass.inspect} #{sha2pass.size}"

  remlen = keylen

  countsalt = salt + "\x00"*4
  saltlen = salt.size

  key = "\x00"*keylen

  # generate key in BCRYPT_HASHSIZE pieces
  count = 1
  while remlen > 0
    countsalt[saltlen + 0] = ((count >> 24) & 0xff).chr
    countsalt[saltlen + 1] = ((count >> 16) & 0xff).chr
    countsalt[saltlen + 2] = ((count >> 8) & 0xff).chr
    countsalt[saltlen + 3] = (count & 0xff).chr
    puts "[RC] countsalt: #{countsalt.inspect} len:#{countsalt.size}"

    sha2salt = RbNaCl::Hash.sha512(countsalt)
    tmpout = BCryptPbkdf::Engine::__bc_crypt_hash(sha2pass, sha2salt)
    out = tmpout.clone

    puts "[RB] out: #{out.inspect} keylen:#{remlen} count:#{count}"
    (1...rounds).each do |i|
      sha2salt = RbNaCl::Hash.sha512(tmpout)
      tmpout = BCryptPbkdf::Engine::__bc_crypt_hash(sha2pass, sha2salt)
      out.bytes.each_with_index {|o,j| out.setbyte(j,o ^ tmpout[j].ord) }
    end

    amt = [amt, remlen].min
    (0...amt).each do |i|
      dest = i * stride + (count -1)
      key[dest] = out[i] if (dest < keylen)
    end
    
    remlen -= amt
    count += 1
  end
  key
end


class TestExt < MiniTest::Unit::TestCase
  
  def test_ruby_and_native_returns_the_same
    assert_equal bcrypt_pbkdf('pass2','salt2',12,2), BCryptPbkdf::Engine::__bc_crypt_pbkdf('pass2','salt2',12,2)
  end
end