package org.netssh.bcrypt_pbkdf;

import org.jcodings.specific.ASCIIEncoding;
import org.jruby.Ruby;
import org.jruby.RubyClass;
import org.jruby.RubyModule;
import org.jruby.RubyNumeric;
import org.jruby.RubyString;
import org.jruby.anno.JRubyMethod;
import org.jruby.runtime.ThreadContext;
import org.jruby.runtime.builtin.IRubyObject;

public final class BCryptPbkdfExt {

  public static void load(final Ruby runtime) {
    RubyModule bcryptPbkdf = runtime.getOrCreateModule("BCryptPbkdf");
    RubyClass engine = bcryptPbkdf.defineOrGetClassUnder("Engine", runtime.getObject());
    engine.getSingletonClass().defineAnnotatedMethods(BCryptPbkdfExt.class);
  }

  @JRubyMethod(required = 4, rest = true)
  public static IRubyObject __bc_crypt_pbkdf(ThreadContext context, IRubyObject self, IRubyObject[] args) {
    byte[] key = BCryptPbkdf.cryptPbkdf(
            stringToBytes(args[0]),
            stringToBytes(args[1]),
            RubyNumeric.num2int(args[2]),
            RubyNumeric.num2int(args[3]));
    if (key == null) return context.nil;
    return newString(context.runtime, key);
  }


  @JRubyMethod(required = 2, rest = true)
  public static IRubyObject __bc_crypt_hash(ThreadContext context, IRubyObject self, IRubyObject[] args) {
    byte[] out = BCryptPbkdf.cryptHash(stringToBytes(args[0]), stringToBytes(args[1]));
    if (out == null) return context.nil;
    return newString(context.runtime, out);
  }

  private static byte[] stringToBytes(final IRubyObject value) {
    return value.convertToString().getBytes();
  }

  private static RubyString newString(final Ruby runtime, final byte[] bytes) {
    return RubyString.newString(runtime, bytes, 0, bytes.length, ASCIIEncoding.INSTANCE);
  }
}
