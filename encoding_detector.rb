class EncodingDetector
  # Byte 1  Byte 2  Byte 3  Byte 4  Byte 5  Byte 6
  # 0-127 # 7Bit ASCII
  # 192-223 128-191
  # 224-239 128-191 128-191
  # 240-247 128-191 128-191 128-191
  # 248-251 128-191 128-191 128-191 128-191
  # 252-254 128-191 128-191 128-191 128-191 128-191

  UTF8_BOM = [239, 187, 191]
  CONTAINS_UTF8_MULTIBYTE_CHAR = /(19[2-9]{1}|2[0-9]{2}) (128|129|190|191|1[3-8]{1}\d{1}){1,5}/
  # unreasonable character for ASCII, but maybe in extended ASCII
  # => even there combination of two of those characters after each other should be fairly unreasonable
  # => first would be a geometrical or math symbol, second a non-english letter
  # => this matches UTF-8 sequences containing 1 or more non-ASCII letters
  UTF16_BE_BOM = [254, 255]
  UTF16_LE_BOM = [255, 254]
  CONTAINS_UTF16_BE_WS = / 0 32 /
  CONTAINS_EXTENDED_ASCII = /(128|129|25[0-4]{1}|1[3-9]{1}\d{1}|2[0-4]{1}[0-9]{1})/
  WS = " "

  def detect(str, prefer_utf8:true)
    bytes = str.bytes
    byte_str = bytes.map { |i| i.to_s }.join(WS)
    return "UTF-16BE" if bytes[0,2] == UTF16_BE_BOM
    return "UTF-16LE" if bytes[0,2] == UTF16_LE_BOM
    if byte_str =~ CONTAINS_UTF16_BE_WS
      if bytes[0, 1] == [0]
        return "UTF-16BE"
      else
        return "UTF-16LE"
      end
    end
    return "UTF-8" if bytes[0,3] == UTF8_BOM
    return "UTF-8" if byte_str =~ CONTAINS_UTF8_MULTIBYTE_CHAR
    return "ISO-8859-1" if byte_str =~ CONTAINS_EXTENDED_ASCII

    if prefer_utf8
      return "UTF-8"
    else
      return "ISO-8859-1"
    end
  end
end
