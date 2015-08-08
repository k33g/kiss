module kiss.crypto

import java.security.Key
import javax.crypto.Cipher
import javax.crypto.spec.SecretKeySpec
import sun.misc.BASE64Decoder
import sun.misc.BASE64Encoder
import com.sun.crypto.provider.Sun
import com.sun.crypto.provider.SunJSSE
import com.sun.crypto.provider.SunJCE
import com.sun.crypto.provider.SunRsaSign

struct crypt = {
  secret,
  algorithm
}

augment crypt {
  # For AES alogithm your key must have 16 chars.
  # For DES algorithm it will be 8 chars.
  # For PBEWithMD5AndTripleDES algorithm it will be 64 chars.

  function getCipher = |this| {
    if this: algorithm(): equals("AES") { return Cipher.getInstance(this: algorithm())}
    if this: algorithm(): equals("DES") { return Cipher.getInstance(this: algorithm())}
    if this: algorithm(): equals("PBEWithMD5AndTripleDES") { return Cipher.getInstance(this: algorithm())}
    #if this: algorithm(): equals("HmacSHA256") { return Mac.getInstance(this: algorithm())}
  }

  function AES = |this| -> this: algorithm("AES")
  function DES = |this| -> this: algorithm("DES")
  function PBEWithMD5AndTripleDES = |this| -> this: algorithm("PBEWithMD5AndTripleDES")

  function generateKey = |this| -> SecretKeySpec(this: secret(): getBytes(), this: algorithm())
  function encrypt = |this, value| {
    let key = this: generateKey()
    let cipher = this: getCipher()
    cipher: init(Cipher.ENCRYPT_MODE(), key)
    let encryptedByteValue = cipher: doFinal(value:getBytes("utf-8"))
    let encryptedValue64 = BASE64Encoder(): encode(encryptedByteValue)
    return encryptedValue64
  }
  function decrypt = |this, value| {
    let key = this: generateKey()
    let cipher = this: getCipher()
    cipher: init(Cipher.DECRYPT_MODE(), key)
    let decryptedValue64 = BASE64Decoder(): decodeBuffer(value)
    let decryptedByteValue = cipher: doFinal(decryptedValue64)
    let decryptedValue = String(decryptedByteValue,"utf-8")
    return decryptedValue
  }
}

# for tests
function main = |args| {
  println(crypt(): secret("bob-morane-00001"): AES(): encrypt("morane"))
  println(crypt(): secret("bob-morane-00001"): AES(): decrypt("zggpA+4xfUKGyc1sA215bw=="))
  println(crypt(): secret("bobby-01"): DES(): encrypt("morane"))
  println(crypt(): secret("bobby-01"): DES(): decrypt("d8HBD7EVFVY="))
}
