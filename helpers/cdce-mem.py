import sys
import textwrap


def bits7(value):
    return format(value, "07b")


def bits8(value):
    return format(value, "08b")


def start(addr):
    global scl, sda
    scl += "11"
    sda += "10"
    scl += "000000000"
    sda += bits7(addr) + "01"


def stop():
    global scl, sda
    scl += "01"
    sda += "01"


def write(addr, value):
    global scl, sda
    scl += "000000000"
    sda += bits8(addr >> 8) + "1"
    scl += "000000000"
    sda += bits8(addr & 0xFF) + "1"
    scl += "000000000"
    sda += bits8(value >> 8) + "1"
    scl += "000000000"
    sda += bits8(value & 0xFF) + "1"


if len(sys.argv) != 2:
    print("Usage: cdce-mem.py freq", file=sys.stderr)
    print(" freq - frequency expressed in MHz (100 or 122.88)", file=sys.stderr)
    sys.exit(1)

if sys.argv[1] == "122.88":
    data = [
        (0x0000, 0x1004),
        (0x004F, 0x0208),
        (0x004E, 0x0000),
        (0x004C, 0x0188),
        (0x004B, 0x8008),
        (0x0049, 0x1000),
        (0x0048, 0x0005),
        (0x0044, 0x1000),
        (0x003F, 0x1000),
        (0x0039, 0x1000),
        (0x0032, 0x07C0),
        (0x0031, 0x001F),
        (0x0030, 0x180A),
        (0x002F, 0x0500),
        (0x001E, 0x0040),
        (0x001B, 0x0004),
        (0x0019, 0x0401),
        (0x0018, 0x8718),
        (0x0005, 0x0000),
        (0x0004, 0x0070),
        (0x0002, 0x0002),
        (0x0000, 0x1004),
    ]
else:
    data = [
        (0x0000, 0x1004),
        (0x004F, 0x0208),
        (0x004E, 0x0000),
        (0x004C, 0x0188),
        (0x004B, 0x8008),
        (0x0049, 0x1000),
        (0x0048, 0x0006),
        (0x0044, 0x1000),
        (0x003F, 0x1000),
        (0x0039, 0x1000),
        (0x0032, 0x07C0),
        (0x0031, 0x001F),
        (0x0030, 0x300A),
        (0x002F, 0x0500),
        (0x001E, 0x007D),
        (0x001B, 0x0004),
        (0x0019, 0x0402),
        (0x0018, 0x9524),
        (0x0005, 0x0000),
        (0x0004, 0x0070),
        (0x0002, 0x0002),
        (0x0000, 0x1004),
    ]

scl = ""
sda = ""

for (addr, value) in data:
    start(0x67)
    write(addr, value)
    stop()

fill = 16 - len(scl) % 16

scl += "1" * fill
sda += "1" * fill

scl = textwrap.wrap(scl, 16)
sda = textwrap.wrap(sda, 16)

result = ["ffffffff" for i in range(64)]
result += [format(eval("0b" + a + b), "08x") for a, b in zip(scl, sda)]

print("\n".join(result))
