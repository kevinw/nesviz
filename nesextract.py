import PIL.Image
import math
import struct
import re
import os.path
import zipfile
from pprint import pprint

ROM_PATH = "/Users/kevin/Desktop/roms/"

ROM_ZIP = re.compile(r"\.zip$", re.IGNORECASE)
NES_ROM = re.compile(r"\.nes$", re.IGNORECASE)

class SpriteLoader:
    def __init__(self, data):
        self.data = data

    @staticmethod
    def from_stream(stream):
        return SpriteLoader(stream.read())

    @staticmethod
    def from_string(string):
        return SpriteLoader(string)

    def get_sprite(self, index):
        iA = index * 16
        iB = iA + 8
        iC = iB + 8
        channelA = self.data[iA:iA+iB]
        channelB = self.data[iB:iB+iC]
        return self.decode_sprite(channelA, channelB)

    def decode_sprite(self, channelA, channelB):
        sprite = []
        y = 0

        print "channelA", len(channelA), channelA
        print "channelB", len(channelB), channelB

        while y < 8:
            a = ord(channelA[y])
            b = ord(channelB[y])
            line = []
            x = 0

            while x < 8:
                bit = int(math.pow(2, 7 - x))
                pixel = -1
                if not (a & bit) and not (b & bit):
                    pixel = 0
                elif (a & bit) and not (b & bit):
                    pixel = 1
                elif not (a & bit) and (b & bit):
                    pixel = 2
                elif (a & bit) and (b & bit):
                    pixel = 3
                line.append(pixel)
                x += 1
            sprite.append(line)
            y += 1

        return sprite

def handle_rom_data(fileobj):
    print fileobj.read(50)

def handle_rom_zip(filename):
    with zipfile.ZipFile(filename) as z:
        for info in z.infolist():
            if info.file_size > 0:
                if NES_ROM.search(info.filename):
                    handle_rom_data(z.open(info.filename))

def main():
    for root, dirs, filenames in os.walk(ROM_PATH):
        for name in filenames:
            if ROM_ZIP.search(name):
                handle_rom_zip(os.path.join(root, name))

if __name__ == '__main__':
    data = "007D5555557D5555007E6666667E6666".decode("hex")
    sprite_loader = SpriteLoader.from_string(data)
    sprite = sprite_loader.get_sprite(0)

    bytes = []
    for row in sprite:
        for col in row:
            bytes.append(col)
    print bytes

    sprite_bytes = struct.pack("B" * len(bytes), *bytes)
    image = PIL.Image.frombytes("P", (8, 8), sprite_bytes)
    print image
