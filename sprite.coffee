palette = [
  0x788084, 0x0000fc, 0x0000c4, 0x4028c4
  0x94008c, 0xac0028, 0xac1000, 0x8c1800
  0x503000, 0x007800, 0x006800, 0x005800
  0x004058, 0x000000, 0x000000, 0x000008
  0xbcc0c4, 0x0078fc, 0x0088fc, 0x6848fc
  0xdc00d4, 0xe40060, 0xfc3800, 0xe46918
  0xac8000, 0x00b800, 0x00a800, 0x00a848
  0x008894, 0x2c2c2c, 0x000000, 0x000000
  0xfcf8fc, 0x38c0fc, 0x6888fc, 0x9c78fc
  0xfc78fc, 0xfc589c, 0xfc7858, 0xfca048
  0xfcb800, 0xbcf818, 0x58d858, 0x58f89c
  0x00e8e4, 0x606060, 0x000000, 0x000000
  0xfcf8fc, 0xa4e8fc, 0xbcb8fc, 0xdcb8fc
  0xfcb8fc, 0xf4c0e0, 0xf4d0b4, 0xfce0b4
  0xfcd884, 0xdcf878, 0xb8f878, 0xb0f0d8
  0x00f8fc, 0xc8c0c0, 0x000000, 0x000000
]

Sprite = ->

Sprite::get_color = (index) ->
  palette[index]

Sprite::load_sprites = (chr) ->
  sprites = []
  i = 0

  while i < chr.length
    sprites.push chr[i] & 0xFF
    i++

  sprites

Sprite::get_sprite = (index, sprites) ->
  iA = index * 16
  iB = iA + 8
  iC = iB + 8
  channelA = sprites.slice(iA, iB)
  channelB = sprites.slice(iB, iC)
  @decode_sprite channelA, channelB

Sprite::decode_sprite = (channelA, channelB) ->
  sprite = []
  y = 0

  while y < 8
    a = channelA[y]
    b = channelB[y]
    line = []
    x = 0

    while x < 8
      bit = Math.pow(2, 7 - x)
      pixel = -1
      if not (a & bit) and not (b & bit)
        pixel = 0
      else if (a & bit) and not (b & bit)
        pixel = 1
      else if not (a & bit) and (b & bit)
        pixel = 2
      else pixel = 3  if (a & bit) and (b & bit)
      line.push pixel
      x++
    sprite.push line
    y++
  sprite

Sprite::put_sprite = (index, sprites, spr) ->
  start = index * 16
  encoded = @encode_sprite(spr)
  i = start
  j = 0

  while i < (start + 16)
    sprites[i] = encoded[j]
    i++
    j++
  sprites

Sprite::encode_sprite = (spr) ->
  channelA = []
  channelB = []
  y = 0

  while y < 8
    a = 0
    b = 0
    x = 0

    while x < 8
      pixel = spr[y][x]
      bit = Math.pow(2, 7 - x)
      switch pixel
        when 1
          a = a | bit
        when 2
          b = b | bit
        when 3
          a = a | bit
          b = b | bit
      x++
    channelA.push a
    channelB.push b
    y++
  channelA.concat channelB

module.exports = sprite = new Sprite()

main = ->
  buffer = new Buffer("007D5555557D5555007E6666667E6666", "hex")
  sprites = sprite.load_sprites(buffer)
  console.log sprite.get_sprite(0, sprites)


if require.main == module
  main()
