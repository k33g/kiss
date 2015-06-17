module kiss.crypto

import java.security.Key
import javax.crypto.Cipher
import javax.crypto.spec.SecretKeySpec
import sun.misc.BASE64Decoder
import sun.misc.BASE64Encoder

struct crypt = {
  secret
}

augment crypt {
  # For AES alogithm your key must have 16 chars.
  # For DES algorithm it will be 8 chars.
  function algorithm = |this| {
    if this: secret(): length(): equals(16) { return "AES" }
    if this: secret(): length(): equals(8) { return "DES" } else {}
  }
  function generateKey = |this| -> SecretKeySpec(this: secret(): getBytes(), this: algorithm())
  function encrypt = |this, value| {
    let key = this: generateKey()
    let cipher = Cipher.getInstance(this: algorithm())
    cipher: init(Cipher.ENCRYPT_MODE(), key)
    let encryptedByteValue = cipher: doFinal(value:getBytes("utf-8"))
    let encryptedValue64 = BASE64Encoder(): encode(encryptedByteValue)
    return encryptedValue64
  }
  function decrypt = |this, value| {
    let key = this: generateKey()
    let cipher = Cipher.getInstance(this: algorithm())
    cipher: init(Cipher.DECRYPT_MODE(), key)
    let decryptedValue64 = BASE64Decoder(): decodeBuffer(value)
    let decryptedByteValue = cipher: doFinal(decryptedValue64)
    let decryptedValue = String(decryptedByteValue,"utf-8")
    return decryptedValue
  }
}

function main = |args| {
  println(crypt("bob-morane-00001"): encrypt("morane"))
  println(crypt("bob-morane-00001"): decrypt("zggpA+4xfUKGyc1sA215bw=="))
  println(crypt("bobby-01"): encrypt("morane"))
  println(crypt("bobby-01"): decrypt("d8HBD7EVFVY="))

}