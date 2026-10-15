class_name QrCode
extends RefCounted
## Makes a QR code: the swap code one phone shows and the other scans (SwapScreen, LanLink).
## Byte mode, error correction level M, versions 1-10 (up to 213 bytes) - a swap code is ~50.
## Follows ISO/IEC 18004 the same way Project Nayuki's reference generator does: data and
## Reed-Solomon codewords, interleaved into blocks, placed around the fixed patterns, then the
## mask with the lowest penalty - plus one rule of our own: avoid any mask that leaves a lookalike
## corner square in the data. ZXing's corner test is looser than the standard's penalty, and
## tested over 2400 codes, one with a lookalike failed to scan 1 time in 80 against 1 in 1000
## without. A code whose every mask has one gets a new secret instead (LanLink.code).
##
##   var rows := QrCode.encode("hello")   # Array of PackedByteArray, 1 = dark; [] if too long

const MAX_VERSION := 10
## Level M, per version 1-10: error correction codewords per block, and how many blocks.
const ECC_PER_BLOCK := [10, 16, 26, 18, 24, 16, 18, 22, 22, 26]
const BLOCKS := [1, 1, 1, 2, 2, 4, 4, 4, 5, 5]
const FORMAT_M := 0  # the two format bits for level M

var _size := 0
var _dark := PackedByteArray()
var _fixed := PackedByteArray()


## `mask` 0-7 forces one (for tests); -1 picks the easiest to read.
static func encode(text: String, mask := -1) -> Array:
	var data := text.to_utf8_buffer()
	var ver := 0
	for v in range(1, MAX_VERSION + 1):
		if 4 + _count_bits(v) + data.size() * 8 <= _data_codewords(v) * 8:
			ver = v
			break
	if ver == 0:
		return []
	var q := QrCode.new()
	return q._make(ver, _codewords(ver, data), mask)


# --- Data --------------------------------------------------------------------------------------

static func _count_bits(ver: int) -> int:
	return 8 if ver <= 9 else 16


## Modules left for data and error correction once the fixed patterns are placed.
static func _raw_modules(ver: int) -> int:
	var r := (16 * ver + 128) * ver + 64
	if ver >= 2:
		var na := ver / 7 + 2
		r -= (25 * na - 10) * na - 55
		if ver >= 7:
			r -= 36
	return r


static func _data_codewords(ver: int) -> int:
	return _raw_modules(ver) / 8 - ECC_PER_BLOCK[ver - 1] * BLOCKS[ver - 1]


## The bytes as one bit stream (mode, length, data, terminator, padding), then split into blocks,
## each given its error correction, and interleaved.
static func _codewords(ver: int, data: PackedByteArray) -> PackedByteArray:
	var bits := PackedByteArray()
	_put(bits, 0b0100, 4)
	_put(bits, data.size(), _count_bits(ver))
	for b in data:
		_put(bits, b, 8)
	var cap := _data_codewords(ver) * 8
	_put(bits, 0, mini(4, cap - bits.size()))
	_put(bits, 0, (8 - bits.size() % 8) % 8)
	var words := PackedByteArray()
	for i in range(0, bits.size(), 8):
		var w := 0
		for k in 8:
			w = (w << 1) | bits[i + k]
		words.append(w)
	var pad := 0xEC
	while words.size() < cap / 8:
		words.append(pad)
		pad ^= 0xEC ^ 0x11

	var nblocks: int = BLOCKS[ver - 1]
	var ecc_len: int = ECC_PER_BLOCK[ver - 1]
	var raw := _raw_modules(ver) / 8
	var short_blocks := nblocks - raw % nblocks
	var short_len := raw / nblocks
	var divisor := _rs_divisor(ecc_len)
	var blocks := []
	var k := 0
	for i in nblocks:
		var n := short_len - ecc_len + (0 if i < short_blocks else 1)
		var dat := words.slice(k, k + n)
		k += n
		var ecc := _rs_remainder(dat, divisor)
		if i < short_blocks:
			dat.append(0)
		dat.append_array(ecc)
		blocks.append(dat)
	var out := PackedByteArray()
	for i in (blocks[0] as PackedByteArray).size():
		for j in nblocks:
			if i != short_len - ecc_len or j >= short_blocks:
				out.append(blocks[j][i])
	return out


static func _put(bits: PackedByteArray, value: int, count: int) -> void:
	for i in range(count - 1, -1, -1):
		bits.append((value >> i) & 1)


# --- Reed-Solomon over GF(256), polynomial 0x11D ----------------------------------------------

static func _gf_mul(x: int, y: int) -> int:
	var z := 0
	for i in range(7, -1, -1):
		z = (z << 1) ^ ((z >> 7) * 0x11D)
		z ^= ((y >> i) & 1) * x
	return z


static func _rs_divisor(degree: int) -> PackedByteArray:
	var result := PackedByteArray()
	result.resize(degree)
	result[degree - 1] = 1
	var root := 1
	for i in degree:
		for j in degree:
			result[j] = _gf_mul(result[j], root)
			if j + 1 < degree:
				result[j] ^= result[j + 1]
		root = _gf_mul(root, 0x02)
	return result


static func _rs_remainder(data: PackedByteArray, divisor: PackedByteArray) -> PackedByteArray:
	var result := PackedByteArray()
	result.resize(divisor.size())
	for b in data:
		var factor: int = b ^ result[0]
		result = result.slice(1)
		result.append(0)
		for i in result.size():
			result[i] ^= _gf_mul(divisor[i], factor)
	return result


# --- The grid ----------------------------------------------------------------------------------

func _make(ver: int, words: PackedByteArray, forced := -1) -> Array:
	_size = ver * 4 + 17
	_dark.resize(_size * _size)
	_fixed.resize(_size * _size)
	_patterns(ver)
	_place(words)
	var best := forced
	var lowest := -1
	for mask in (8 if forced < 0 else 0):
		_mask(mask)
		_format(mask)
		var p := _penalty()
		if lowest < 0 or p < lowest:
			lowest = p
			best = mask
		_mask(mask)  # a mask is its own undo
	_mask(best)
	_format(best)
	var rows := []
	for y in _size:
		rows.append(_dark.slice(y * _size, (y + 1) * _size))
	return rows


func _set_fixed(x: int, y: int, dark: bool) -> void:
	_dark[y * _size + x] = 1 if dark else 0
	_fixed[y * _size + x] = 1


func _patterns(ver: int) -> void:
	for i in _size:
		_set_fixed(6, i, i % 2 == 0)
		_set_fixed(i, 6, i % 2 == 0)
	for c in [Vector2i(3, 3), Vector2i(_size - 4, 3), Vector2i(3, _size - 4)]:
		for dy in range(-4, 5):
			for dx in range(-4, 5):
				var x: int = c.x + dx
				var y: int = c.y + dy
				if x >= 0 and x < _size and y >= 0 and y < _size:
					var d := maxi(absi(dx), absi(dy))
					_set_fixed(x, y, d != 2 and d != 4)
	var at := _alignment(ver)
	var n := at.size()
	for i in n:
		for j in n:
			if (i == 0 and j == 0) or (i == 0 and j == n - 1) or (i == n - 1 and j == 0):
				continue
			for dy in range(-2, 3):
				for dx in range(-2, 3):
					_set_fixed(at[i] + dx, at[j] + dy, maxi(absi(dx), absi(dy)) != 1)
	_format(0)  # reserves the format areas; the real bits go in once the mask is chosen
	if ver >= 7:
		var rem := ver
		for i in 12:
			rem = (rem << 1) ^ ((rem >> 11) * 0x1F25)
		var bits := (ver << 12) | rem
		for i in 18:
			var bit := ((bits >> i) & 1) == 1
			var a := _size - 11 + i % 3
			var b := i / 3
			_set_fixed(a, b, bit)
			_set_fixed(b, a, bit)


func _alignment(ver: int) -> Array:
	if ver == 1:
		return []
	var n := ver / 7 + 2
	var step := (ver * 8 + n * 3 + 5) / (n * 4 - 4) * 2
	var out := [6]
	var pos := _size - 7
	while out.size() < n:
		out.insert(1, pos)
		pos -= step
	return out


func _format(mask: int) -> void:
	var data := (FORMAT_M << 3) | mask
	var rem := data
	for i in 10:
		rem = (rem << 1) ^ ((rem >> 9) * 0x537)
	var bits := ((data << 10) | rem) ^ 0x5412
	for i in 6:
		_set_fixed(8, i, _bit(bits, i))
	_set_fixed(8, 7, _bit(bits, 6))
	_set_fixed(8, 8, _bit(bits, 7))
	_set_fixed(7, 8, _bit(bits, 8))
	for i in range(9, 15):
		_set_fixed(14 - i, 8, _bit(bits, i))
	for i in 8:
		_set_fixed(_size - 1 - i, 8, _bit(bits, i))
	for i in range(8, 15):
		_set_fixed(8, _size - 15 + i, _bit(bits, i))
	_set_fixed(8, _size - 8, true)


static func _bit(x: int, i: int) -> bool:
	return ((x >> i) & 1) == 1


## The codewords zigzag up and down two columns at a time from the bottom right.
func _place(words: PackedByteArray) -> void:
	var i := 0
	var total := words.size() * 8
	var right := _size - 1
	while right >= 1:
		if right == 6:
			right = 5
		for vert in _size:
			for j in 2:
				var x := right - j
				var up := ((right + 1) & 2) == 0
				var y := _size - 1 - vert if up else vert
				if _fixed[y * _size + x] == 0 and i < total:
					_dark[y * _size + x] = (words[i >> 3] >> (7 - (i & 7))) & 1
					i += 1
		right -= 2


func _mask(mask: int) -> void:
	for y in _size:
		for x in _size:
			if _fixed[y * _size + x] == 1:
				continue
			var flip := false
			match mask:
				0: flip = (x + y) % 2 == 0
				1: flip = y % 2 == 0
				2: flip = x % 3 == 0
				3: flip = (x + y) % 3 == 0
				4: flip = (x / 3 + y / 2) % 2 == 0
				5: flip = x * y % 2 + x * y % 3 == 0
				6: flip = (x * y % 2 + x * y % 3) % 2 == 0
				7: flip = ((x + y) % 2 + x * y % 3) % 2 == 0
			if flip:
				_dark[y * _size + x] ^= 1


## Lower is easier to read: few long runs, few solid boxes, nothing that looks like a finder,
## and dark and light about even.
func _penalty() -> int:
	var p := 0
	for horizontal in [true, false]:
		for a in _size:
			var run := 0
			var last := -1
			var line := PackedByteArray()
			for b in _size:
				var m := _dark[a * _size + b] if horizontal else _dark[b * _size + a]
				line.append(m)
				if m == last:
					run += 1
					if run == 5:
						p += 3
					elif run > 5:
						p += 1
				else:
					run = 1
					last = m
			p += 40 * _finder_like(line)
	for y in _size - 1:
		for x in _size - 1:
			var c := _dark[y * _size + x]
			if c == _dark[y * _size + x + 1] and c == _dark[(y + 1) * _size + x] and c == _dark[(y + 1) * _size + x + 1]:
				p += 3
	var dark := 0
	for m in _dark:
		dark += m
	var total := _size * _size
	var k := ceili(absf(dark * 20.0 - total * 10.0) / total) - 1
	p += maxi(k, 0) * 10
	return p + 10000 * _lookalikes()


## How many lookalike corner squares a made code has: 0 is the easiest to scan.
static func lookalikes(rows: Array) -> int:
	var q := QrCode.new()
	q._size = rows.size()
	for r in rows:
		q._dark.append_array(r)
	return q._lookalikes()


## Places in the data that pass a scanner's corner-square test both across and down: dark, light,
## a dark middle 2-5 wide, light, dark (ZXing's ratio test, FinderPatternFinder.foundPatternCross).
func _lookalikes() -> int:
	var rows := []
	var cols := []
	for a in _size:
		rows.append(_runs(a, true))
		cols.append(_runs(a, false))
	var count := 0
	for y in _size:
		var runs: Array = rows[y]
		for i in range(2, runs.size() - 2):
			if runs[i][0] != 1 or not _finder_ratio(runs, i):
				continue
			var x: int = runs[i][1] + runs[i][2] / 2
			if (x < 9 and y < 9) or (x >= _size - 9 and y < 9) or (x < 9 and y >= _size - 9):
				continue  # a real one
			var down: Array = cols[x]
			for j in range(2, down.size() - 2):
				if down[j][0] == 1 and down[j][1] <= y and y < down[j][1] + down[j][2]:
					if _finder_ratio(down, j):
						count += 1
					break
	return count


## A line as runs [dark, start, length]; the quiet zone round the code makes the end runs longer.
func _runs(a: int, across: bool) -> Array:
	var out := []
	var start := 0
	for b in range(1, _size + 1):
		var here := _dark[a * _size + start] if across else _dark[start * _size + a]
		var next := -1
		if b < _size:
			next = _dark[a * _size + b] if across else _dark[b * _size + a]
		if next != here:
			var length := b - start
			if start == 0 or b == _size:
				length += 4 if here == 0 else 0
			out.append([here, start, length])
			start = b
	return out


static func _finder_ratio(runs: Array, i: int) -> bool:
	var c := []
	for k in range(i - 2, i + 3):
		c.append(float(runs[k][2]))
	var module: float = (c[0] + c[1] + c[2] + c[3] + c[4]) / 7.0
	var v := module / 2.0
	return absf(module - c[0]) < v and absf(module - c[1]) < v and absf(3.0 * module - c[2]) < 3.0 * v 		and absf(module - c[3]) < v and absf(module - c[4]) < v


## 1:1:3:1:1 dark-light-dark-light-dark with four light on one side (outside counts as light).
static func _finder_like(line: PackedByteArray) -> int:
	const A := [1, 0, 1, 1, 1, 0, 1, 0, 0, 0, 0]
	const B := [0, 0, 0, 0, 1, 0, 1, 1, 1, 0, 1]
	var n := line.size()
	var count := 0
	for s in range(-4, n - 6):
		for pat in [A, B]:
			var ok := true
			for i in 11:
				var at: int = s + i
				var m := line[at] if at >= 0 and at < n else 0
				if m != pat[i]:
					ok = false
					break
			if ok:
				count += 1
	return count
