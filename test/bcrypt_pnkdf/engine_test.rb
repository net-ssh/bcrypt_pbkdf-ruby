require 'minitest/autorun'
require 'test_helper'

# bcrypt_pbkdf in ruby
require 'openssl'

BCRYPT_BLOCKS = 8
BCRYPT_HASHSIZE = BCRYPT_BLOCKS * 4

def bcrypt_pbkdf(password, salt, keylen, rounds)
  stride = (keylen + BCRYPT_HASHSIZE - 1) / BCRYPT_HASHSIZE
  amt = (keylen + stride - 1) / stride

  sha2pass = OpenSSL::Digest::SHA512.new(password).digest
  #puts "[RB] sha2pass:#{sha2pass.inspect} #{sha2pass.size}"

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
    #puts "[RC] countsalt: #{countsalt.inspect} len:#{countsalt.size}"

    sha2salt = OpenSSL::Digest::SHA512.new(countsalt).digest
    tmpout = BCryptPbkdf::Engine::__bc_crypt_hash(sha2pass, sha2salt)
    out = tmpout.clone

    #puts "[RB] out: #{out.inspect} keylen:#{remlen} count:#{count}"
    (1...rounds).each do |i|
      sha2salt = OpenSSL::Digest::SHA512.new(tmpout).digest
      tmpout = BCryptPbkdf::Engine::__bc_crypt_hash(sha2pass, sha2salt)
      out.bytes.each_with_index {|o,j| out.setbyte(j,o ^ tmpout[j].ord) }
    end

    amt = [amt, remlen].min
    (0...amt).each do |i|
      dest = i * stride + (count - 1)
      key[dest] = out[i] if (dest < keylen)
    end

    remlen -= amt
    count += 1
  end
  key
end


class TestExt < Minitest::Test
  def test_table
    assert_equal table, table.map{ |p,s,l,r| [p,s,l,r,BCryptPbkdf::Engine::__bc_crypt_pbkdf(p,s,l,r).bytes] }
  end
  def test_ruby_and_native_returns_the_same
    table.each do |p,s,l,r|
      assert_equal bcrypt_pbkdf(p,s,l,r), BCryptPbkdf::Engine::__bc_crypt_pbkdf(p,s,l,r)
      assert_equal bcrypt_pbkdf(p,s,l,r), BCryptPbkdf::key(p,s,l,r)
    end
  end


  def table
    [
      ["pass2", "salt2", 12, 2, [214, 14, 48, 162, 131, 206, 121, 176, 50, 104, 231, 252]],
      ["\u0000\u0001foo", "\u0001\u0002fooo3", 14, 5, [46, 189, 32, 185, 94, 85, 232, 10, 84, 26, 44, 161, 49, 126]],
      ["doozoasd", "fooo$AS!", 14, 22, [57, 62, 50, 107, 70, 155, 65, 5, 129, 211, 189, 169, 188, 65]],
      # vectors from jBCrypt (https://github.com/kruton/jbcrypt) by Kenny Root
      ["password", "salt", 32, 4,  [0x5b, 0xbf, 0x0c, 0xc2, 0x93, 0x58, 0x7f, 0x1c, 0x36, 0x35, 0x55, 0x5c, 0x27, 0x79, 0x65, 0x98,
                                    0xd4, 0x7e, 0x57, 0x90, 0x71, 0xbf, 0x42, 0x7e, 0x9d, 0x8f, 0xbe, 0x84, 0x2a, 0xba, 0x34, 0xd9]],
      ["password", "salt", 64, 8,  [0xe1, 0x36, 0x7e, 0xc5, 0x15, 0x1a, 0x33, 0xfa, 0xac, 0x4c, 0xc1, 0xc1, 0x44, 0xcd, 0x23, 0xfa,
                                    0x15, 0xd5, 0x54, 0x84, 0x93, 0xec, 0xc9, 0x9b, 0x9b, 0x5d, 0x9c, 0x0d, 0x3b, 0x27, 0xbe, 0xc7,
                                    0x62, 0x27, 0xea, 0x66, 0x08, 0x8b, 0x84, 0x9b, 0x20, 0xab, 0x7a, 0xa4, 0x78, 0x01, 0x02, 0x46,
                                    0xe7, 0x4b, 0xba, 0x51, 0x72, 0x3f, 0xef, 0xa9, 0xf9, 0x47, 0x4d, 0x65, 0x08, 0x84, 0x5e, 0x8d]],
      ["password", "salt", 16, 42, [0x83, 0x3c, 0xf0, 0xdc, 0xf5, 0x6d, 0xb6, 0x56, 0x08, 0xe8, 0xf0, 0xdc, 0x0c, 0xe8, 0x82, 0xbd]],
    ]
  end
end
