### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ 03d6de66-9e19-11eb-2405-45c3efc128d3
md"""
# [Strings](@id man-strings)
"""

# ╔═╡ 03d6dee8-9e19-11eb-3927-b1203f595a8c
md"""
Strings are finite sequences of characters. Of course, the real trouble comes when one asks what a character is. The characters that English speakers are familiar with are the letters `A`, `B`, `C`, etc., together with numerals and common punctuation symbols. These characters are standardized together with a mapping to integer values between 0 and 127 by the [ASCII](https://en.wikipedia.org/wiki/ASCII) standard. There are, of course, many other characters used in non-English languages, including variants of the ASCII characters with accents and other modifications, related scripts such as Cyrillic and Greek, and scripts completely unrelated to ASCII and English, including Arabic, Chinese, Hebrew, Hindi, Japanese, and Korean. The [Unicode](https://en.wikipedia.org/wiki/Unicode) standard tackles the complexities of what exactly a character is, and is generally accepted as the definitive standard addressing this problem. Depending on your needs, you can either ignore these complexities entirely and just pretend that only ASCII characters exist, or you can write code that can handle any of the characters or encodings that one may encounter when handling non-ASCII text. Julia makes dealing with plain ASCII text simple and efficient, and handling Unicode is as simple and efficient as possible. In particular, you can write C-style string code to process ASCII strings, and they will work as expected, both in terms of performance and semantics. If such code encounters non-ASCII text, it will gracefully fail with a clear error message, rather than silently introducing corrupt results. When this happens, modifying the code to handle non-ASCII data is straightforward.
"""

# ╔═╡ 03d6defc-9e19-11eb-1ef7-85510ea1e766
md"""
There are a few noteworthy high-level features about Julia's strings:
"""

# ╔═╡ 03d6e1a4-9e19-11eb-105f-fb1c4f54bbed
md"""
  * The built-in concrete type used for strings (and string literals) in Julia is [`String`](@ref). This supports the full range of [Unicode](https://en.wikipedia.org/wiki/Unicode) characters via the [UTF-8](https://en.wikipedia.org/wiki/UTF-8) encoding. (A [`transcode`](@ref) function is provided to convert to/from other Unicode encodings.)
  * All string types are subtypes of the abstract type `AbstractString`, and external packages define additional `AbstractString` subtypes (e.g. for other encodings).  If you define a function expecting a string argument, you should declare the type as `AbstractString` in order to accept any string type.
  * Like C and Java, but unlike most dynamic languages, Julia has a first-class type for representing a single character, called [`AbstractChar`](@ref). The built-in [`Char`](@ref) subtype of `AbstractChar` is a 32-bit primitive type that can represent any Unicode character (and which is based on the UTF-8 encoding).
  * As in Java, strings are immutable: the value of an `AbstractString` object cannot be changed. To construct a different string value, you construct a new string from parts of other strings.
  * Conceptually, a string is a *partial function* from indices to characters: for some index values, no character value is returned, and instead an exception is thrown. This allows for efficient indexing into strings by the byte index of an encoded representation rather than by a character index, which cannot be implemented both efficiently and simply for variable-width encodings of Unicode strings.
"""

# ╔═╡ 03d6e1d6-9e19-11eb-09c9-87ccb8fe06a3
md"""
## [Characters](@id man-characters)
"""

# ╔═╡ 03d6e212-9e19-11eb-14f8-93522cf0c441
md"""
A `Char` value represents a single character: it is just a 32-bit primitive type with a special literal representation and appropriate arithmetic behaviors, and which can be converted to a numeric value representing a [Unicode code point](https://en.wikipedia.org/wiki/Code_point).  (Julia packages may define other subtypes of `AbstractChar`, e.g. to optimize operations for other [text encodings](https://en.wikipedia.org/wiki/Character_encoding).) Here is how `Char` values are input and shown:
"""

# ╔═╡ 03d6e686-9e19-11eb-2507-5fea8bfc4f8e
c = 'x'

# ╔═╡ 03d6e690-9e19-11eb-3932-65a5e155ee6b
typeof(c)

# ╔═╡ 03d6e6b8-9e19-11eb-04a4-7d3bb518fb91
md"""
You can easily convert a `Char` to its integer value, i.e. code point:
"""

# ╔═╡ 03d6e8e8-9e19-11eb-2806-eb795fc5d352
c = Int('x')

# ╔═╡ 03d6e906-9e19-11eb-293d-bffed35902f7
typeof(c)

# ╔═╡ 03d6e92e-9e19-11eb-30b3-07f07d188fd0
md"""
On 32-bit architectures, [`typeof(c)`](@ref) will be [`Int32`](@ref). You can convert an integer value back to a `Char` just as easily:
"""

# ╔═╡ 03d6ea6e-9e19-11eb-1f1a-addacf7cc189
Char(120)

# ╔═╡ 03d6ea96-9e19-11eb-0439-4da1bd4eda37
md"""
Not all integer values are valid Unicode code points, but for performance, the `Char` conversion does not check that every character value is valid. If you want to check that each converted value is a valid code point, use the [`isvalid`](@ref) function:
"""

# ╔═╡ 03d6ed52-9e19-11eb-135e-774ce370c752
Char(0x110000)

# ╔═╡ 03d6ed52-9e19-11eb-1665-250beaede44c
isvalid(Char, 0x110000)

# ╔═╡ 03d6ed7a-9e19-11eb-009d-abf1ecfb1fea
md"""
As of this writing, the valid Unicode code points are `U+0000` through `U+D7FF` and `U+E000` through `U+10FFFF`. These have not all been assigned intelligible meanings yet, nor are they necessarily interpretable by applications, but all of these values are considered to be valid Unicode characters.
"""

# ╔═╡ 03d6ed98-9e19-11eb-2b9e-492c63fa48d7
md"""
You can input any Unicode character in single quotes using `\u` followed by up to four hexadecimal digits or `\U` followed by up to eight hexadecimal digits (the longest valid value only requires six):
"""

# ╔═╡ 03d6f042-9e19-11eb-35bf-7f2f915e6c6a
'\u0'

# ╔═╡ 03d6f054-9e19-11eb-1884-ad75409b6a42
'\u78'

# ╔═╡ 03d6f054-9e19-11eb-3d2a-a7d8894ca6f4
'\u2200'

# ╔═╡ 03d6f05e-9e19-11eb-14f0-39b8b43378a1
'\U10ffff'

# ╔═╡ 03d6f086-9e19-11eb-14e6-4944d01fbd62
md"""
Julia uses your system's locale and language settings to determine which characters can be printed as-is and which must be output using the generic, escaped `\u` or `\U` input forms. In addition to these Unicode escape forms, all of [C's traditional escaped input forms](https://en.wikipedia.org/wiki/C_syntax#Backslash_escapes) can also be used:
"""

# ╔═╡ 03d6f9dc-9e19-11eb-2909-455550d8d4d5
Int('\0')

# ╔═╡ 03d6f9e8-9e19-11eb-23a9-1361f4ed031d
Int('\t')

# ╔═╡ 03d6f9f0-9e19-11eb-05be-8750b752f871
Int('\n')

# ╔═╡ 03d6f9f0-9e19-11eb-2ced-e51fccad00b7
Int('\e')

# ╔═╡ 03d6fa1a-9e19-11eb-1b73-ede233a0495b
Int('\x7f')

# ╔═╡ 03d6fa22-9e19-11eb-294f-c5f3f6e68c61
Int('\177')

# ╔═╡ 03d6fa68-9e19-11eb-35cc-0d51373eef9d
md"""
You can do comparisons and a limited amount of arithmetic with `Char` values:
"""

# ╔═╡ 03d6ff2c-9e19-11eb-0710-d3646965c2c1
'A' < 'a'

# ╔═╡ 03d6ff40-9e19-11eb-1190-f7cca7bfbd87
'A' <= 'a' <= 'Z'

# ╔═╡ 03d6ff4a-9e19-11eb-3878-1f68cc2aefb3
'A' <= 'X' <= 'Z'

# ╔═╡ 03d6ff4a-9e19-11eb-31d9-65b3bc2e82cd
'x' - 'a'

# ╔═╡ 03d6ff56-9e19-11eb-399d-71fa33a505ad
'A' + 1

# ╔═╡ 03d6ff72-9e19-11eb-23a7-afe5aebea04b
md"""
## String Basics
"""

# ╔═╡ 03d6ff7c-9e19-11eb-2500-dd1682bf1ed6
md"""
String literals are delimited by double quotes or triple double quotes:
"""

# ╔═╡ 03d70286-9e19-11eb-2309-6b3c45647c48
str = "Hello, world.\n"

# ╔═╡ 03d70286-9e19-11eb-2602-2d5020efe489
"""Contains "quote" characters"""
"Contains \"quote\" characters"

# ╔═╡ 03d702a6-9e19-11eb-3ee8-6d6094b746b9
md"""
If you want to extract a character from a string, you index into it:
"""

# ╔═╡ 03d70602-9e19-11eb-3d50-9b80b3f25baa
str[begin]

# ╔═╡ 03d70602-9e19-11eb-3d23-eb0e73d9c6ac
str[1]

# ╔═╡ 03d7060c-9e19-11eb-0be1-41edca97b780
str[6]

# ╔═╡ 03d7060c-9e19-11eb-3846-91b6c5b41006
str[end]

# ╔═╡ 03d70670-9e19-11eb-3a5e-cf4bfcbf2511
md"""
Many Julia objects, including strings, can be indexed with integers. The index of the first element (the first character of a string) is returned by [`firstindex(str)`](@ref), and the index of the last element (character) with [`lastindex(str)`](@ref). The keywords `begin` and `end` can be used inside an indexing operation as shorthand for the first and last indices, respectively, along the given dimension. String indexing, like most indexing in Julia, is 1-based: `firstindex` always returns `1` for any `AbstractString`. As we will see below, however, `lastindex(str)` is *not* in general the same as `length(str)` for a string, because some Unicode characters can occupy multiple "code units".
"""

# ╔═╡ 03d706b6-9e19-11eb-174b-7d58ad4a9ebe
md"""
You can perform arithmetic and other operations with [`end`](@ref), just like a normal value:
"""

# ╔═╡ 03d70936-9e19-11eb-16c0-e50268471a8d
str[end-1]

# ╔═╡ 03d70940-9e19-11eb-3500-8da664bb2935
str[end÷2]

# ╔═╡ 03d70968-9e19-11eb-2422-6323bd1690ba
md"""
Using an index less than `begin` (`1`) or greater than `end` raises an error:
"""

# ╔═╡ 03d70bac-9e19-11eb-3b22-2fd79cb7fb7e
str[begin-1]

# ╔═╡ 03d70bb6-9e19-11eb-2190-11ac85722f62
str[end+1]

# ╔═╡ 03d70bc0-9e19-11eb-3f6f-adb86cdd3bf8
md"""
You can also extract a substring using range indexing:
"""

# ╔═╡ 03d70d34-9e19-11eb-0e06-2775db2627cc
str[4:9]

# ╔═╡ 03d70d50-9e19-11eb-1ee7-557996bec61a
md"""
Notice that the expressions `str[k]` and `str[k:k]` do not give the same result:
"""

# ╔═╡ 03d70f3a-9e19-11eb-0d63-23b870364b04
str[6]

# ╔═╡ 03d70f3a-9e19-11eb-389c-a3e4fb87bc6e
str[6:6]

# ╔═╡ 03d70f58-9e19-11eb-37c9-c530aa8b233c
md"""
The former is a single character value of type `Char`, while the latter is a string value that happens to contain only a single character. In Julia these are very different things.
"""

# ╔═╡ 03d70f76-9e19-11eb-1751-b9d57c348502
md"""
Range indexing makes a copy of the selected part of the original string. Alternatively, it is possible to create a view into a string using the type [`SubString`](@ref), for example:
"""

# ╔═╡ 03d712aa-9e19-11eb-0516-959dec0af5b8
str = "long string"

# ╔═╡ 03d712aa-9e19-11eb-2eb8-234e1cbe8098
substr = SubString(str, 1, 4)

# ╔═╡ 03d712be-9e19-11eb-01f8-95e359514da8
typeof(substr)

# ╔═╡ 03d712f0-9e19-11eb-37af-990eafb96907
md"""
Several standard functions like [`chop`](@ref), [`chomp`](@ref) or [`strip`](@ref) return a [`SubString`](@ref).
"""

# ╔═╡ 03d71302-9e19-11eb-0131-dbe34069d3ef
md"""
## Unicode and UTF-8
"""

# ╔═╡ 03d7132c-9e19-11eb-3998-0168c65c35dc
md"""
Julia fully supports Unicode characters and strings. As [discussed above](@ref man-characters), in character literals, Unicode code points can be represented using Unicode `\u` and `\U` escape sequences, as well as all the standard C escape sequences. These can likewise be used to write string literals:
"""

# ╔═╡ 03d7144e-9e19-11eb-04dd-7f66578d7248
s = "\u2200 x \u2203 y"

# ╔═╡ 03d7146a-9e19-11eb-2eed-151d9a2dcfea
md"""
Whether these Unicode characters are displayed as escapes or shown as special characters depends on your terminal's locale settings and its support for Unicode. String literals are encoded using the UTF-8 encoding. UTF-8 is a variable-width encoding, meaning that not all characters are encoded in the same number of bytes ("code units"). In UTF-8, ASCII characters — i.e. those with code points less than 0x80 (128) – are encoded as they are in ASCII, using a single byte, while code points 0x80 and above are encoded using multiple bytes — up to four per character.
"""

# ╔═╡ 03d7148a-9e19-11eb-2b26-fd2b3d0d5da7
md"""
String indices in Julia refer to code units (= bytes for UTF-8), the fixed-width building blocks that are used to encode arbitrary characters (code points). This means that not every index into a `String` is necessarily a valid index for a character. If you index into a string at such an invalid byte index, an error is thrown:
"""

# ╔═╡ 03d7173a-9e19-11eb-3989-eff53fa4e66d
s[1]

# ╔═╡ 03d71750-9e19-11eb-2495-b7ddd66a45c6
s[2]

# ╔═╡ 03d71750-9e19-11eb-15f4-53bae67351d8
s[3]

# ╔═╡ 03d7175a-9e19-11eb-0046-95f904f5b6eb
s[4]

# ╔═╡ 03d71782-9e19-11eb-3673-f1cb8e87e0c9
md"""
In this case, the character `∀` is a three-byte character, so the indices 2 and 3 are invalid and the next character's index is 4; this next valid index can be computed by [`nextind(s,1)`](@ref), and the next index after that by `nextind(s,4)` and so on.
"""

# ╔═╡ 03d71796-9e19-11eb-3be6-7fcfa85142ae
md"""
Since `end` is always the last valid index into a collection, `end-1` references an invalid byte index if the second-to-last character is multibyte.
"""

# ╔═╡ 03d73a00-9e19-11eb-22f6-cb5a4cf28495
s[end-1]

# ╔═╡ 03d73a00-9e19-11eb-353e-4930e6d1c508
s[end-2]

# ╔═╡ 03d73a0a-9e19-11eb-1de9-8bbc5cb635dd
s[prevind(s, end, 2)]

# ╔═╡ 03d73a5a-9e19-11eb-0baf-611cbfe27177
md"""
The first case works, because the last character `y` and the space are one-byte characters, whereas `end-2` indexes into the middle of the `∃` multibyte representation. The correct way for this case is using `prevind(s, lastindex(s), 2)` or, if you're using that value to index into `s` you can write `s[prevind(s, end, 2)]` and `end` expands to `lastindex(s)`.
"""

# ╔═╡ 03d73a64-9e19-11eb-3774-e7e62321a276
md"""
Extraction of a substring using range indexing also expects valid byte indices or an error is thrown:
"""

# ╔═╡ 03d73e6a-9e19-11eb-1afb-49820cb86b54
s[1:1]

# ╔═╡ 03d73e7e-9e19-11eb-15fa-0fd817d882ae
s[1:2]

# ╔═╡ 03d73e7e-9e19-11eb-065e-b9232589dc56
s[1:4]

# ╔═╡ 03d73eb0-9e19-11eb-269f-b9e939fdd25e
md"""
Because of variable-length encodings, the number of characters in a string (given by [`length(s)`](@ref)) is not always the same as the last index. If you iterate through the indices 1 through [`lastindex(s)`](@ref) and index into `s`, the sequence of characters returned when errors aren't thrown is the sequence of characters comprising the string `s`. Thus we have the identity that `length(s) <= lastindex(s)`, since each character in a string must have its own index. The following is an inefficient and verbose way to iterate through the characters of `s`:
"""

# ╔═╡ 03d7425c-9e19-11eb-18cd-fd21020e77f7
for i = firstindex(s):lastindex(s)
           try
               println(s[i])
           catch
               # ignore the index error
           end
       end

# ╔═╡ 03d7427c-9e19-11eb-19e6-a9d9622a88bd
md"""
The blank lines actually have spaces on them. Fortunately, the above awkward idiom is unnecessary for iterating through the characters in a string, since you can just use the string as an iterable object, no exception handling required:
"""

# ╔═╡ 03d7441e-9e19-11eb-0485-cb3c7260a311
for c in s
           println(c)
       end

# ╔═╡ 03d74444-9e19-11eb-1850-1f5956eb9452
md"""
If you need to obtain valid indices for a string, you can use the [`nextind`](@ref) and [`prevind`](@ref) functions to increment/decrement to the next/previous valid index, as mentioned above. You can also use the [`eachindex`](@ref) function to iterate over the valid character indices:
"""

# ╔═╡ 03d74554-9e19-11eb-3f46-a753669c5fc8
collect(eachindex(s))

# ╔═╡ 03d745a4-9e19-11eb-355d-c19f9de6b1c6
md"""
To access the raw code units (bytes for UTF-8) of the encoding, you can use the [`codeunit(s,i)`](@ref) function, where the index `i` runs consecutively from `1` to [`ncodeunits(s)`](@ref).  The [`codeunits(s)`](@ref) function returns an `AbstractVector{UInt8}` wrapper that lets you access these raw codeunits (bytes) as an array.
"""

# ╔═╡ 03d745c2-9e19-11eb-2791-2164febb3e99
md"""
Strings in Julia can contain invalid UTF-8 code unit sequences. This convention allows to treat any byte sequence as a `String`. In such situations a rule is that when parsing a sequence of code units from left to right characters are formed by the longest sequence of 8-bit code units that matches the start of one of the following bit patterns (each `x` can be `0` or `1`):
"""

# ╔═╡ 03d7469e-9e19-11eb-2766-a35b486e3a41
md"""
  * `0xxxxxxx`;
  * `110xxxxx` `10xxxxxx`;
  * `1110xxxx` `10xxxxxx` `10xxxxxx`;
  * `11110xxx` `10xxxxxx` `10xxxxxx` `10xxxxxx`;
  * `10xxxxxx`;
  * `11111xxx`.
"""

# ╔═╡ 03d746bc-9e19-11eb-09ff-0b9726095478
md"""
In particular this means that overlong and too-high code unit sequences and prefixes thereof are treated as a single invalid character rather than multiple invalid characters. This rule may be best explained with an example:
"""

# ╔═╡ 03d74b58-9e19-11eb-3cfc-29b34c5a2609
s = "\xc0\xa0\xe2\x88\xe2|"

# ╔═╡ 03d74b58-9e19-11eb-0e49-69a8d62c2524
foreach(display, s)

# ╔═╡ 03d74b62-9e19-11eb-12ee-7906488bbb03
isvalid.(collect(s))

# ╔═╡ 03d74b62-9e19-11eb-0112-d3747cf15f01
s2 = "\xf7\xbf\xbf\xbf"

# ╔═╡ 03d74b76-9e19-11eb-23a9-238320736917
foreach(display, s2)

# ╔═╡ 03d74b9e-9e19-11eb-046d-472c206eeff8
md"""
We can see that the first two code units in the string `s` form an overlong encoding of space character. It is invalid, but is accepted in a string as a single character. The next two code units form a valid start of a three-byte UTF-8 sequence. However, the fifth code unit `\xe2` is not its valid continuation. Therefore code units 3 and 4 are also interpreted as malformed characters in this string. Similarly code unit 5 forms a malformed character because `|` is not a valid continuation to it. Finally the string `s2` contains one too high code point.
"""

# ╔═╡ 03d74bd0-9e19-11eb-330c-111c031db3d3
md"""
Julia uses the UTF-8 encoding by default, and support for new encodings can be added by packages. For example, the [LegacyStrings.jl](https://github.com/JuliaStrings/LegacyStrings.jl) package implements `UTF16String` and `UTF32String` types. Additional discussion of other encodings and how to implement support for them is beyond the scope of this document for the time being. For further discussion of UTF-8 encoding issues, see the section below on [byte array literals](@ref man-byte-array-literals). The [`transcode`](@ref) function is provided to convert data between the various UTF-xx encodings, primarily for working with external data and libraries.
"""

# ╔═╡ 03d74bf8-9e19-11eb-1486-75fe43ce65f6
md"""
## [Concatenation](@id man-concatenation)
"""

# ╔═╡ 03d74c02-9e19-11eb-33fe-df3bba1a9c47
md"""
One of the most common and useful string operations is concatenation:
"""

# ╔═╡ 03d74f52-9e19-11eb-25c2-8ddc6be04b2a
greet = "Hello"

# ╔═╡ 03d74f5e-9e19-11eb-0403-1f323eb25713
whom = "world"

# ╔═╡ 03d74f5e-9e19-11eb-170b-27dff183964a
string(greet, ", ", whom, ".\n")

# ╔═╡ 03d74f7c-9e19-11eb-21ee-afee216bd342
md"""
It's important to be aware of potentially dangerous situations such as concatenation of invalid UTF-8 strings. The resulting string may contain different characters than the input strings, and its number of characters may be lower than sum of numbers of characters of the concatenated strings, e.g.:
"""

# ╔═╡ 03d75418-9e19-11eb-1eab-bf99ec926c6c
a, b = "\xe2\x88", "\x80"

# ╔═╡ 03d75422-9e19-11eb-0775-f16fa73a0eb3
c = a*b

# ╔═╡ 03d75422-9e19-11eb-3eca-61fccd1421a1
collect.([a, b, c])

# ╔═╡ 03d75436-9e19-11eb-37e4-1fb638557264
length.([a, b, c])

# ╔═╡ 03d7544a-9e19-11eb-3728-2120368e467b
md"""
This situation can happen only for invalid UTF-8 strings. For valid UTF-8 strings concatenation preserves all characters in strings and additivity of string lengths.
"""

# ╔═╡ 03d75468-9e19-11eb-2833-a50474a6cf2e
md"""
Julia also provides [`*`](@ref) for string concatenation:
"""

# ╔═╡ 03d755bc-9e19-11eb-2fe8-256f1929cff9
greet * ", " * whom * ".\n"

# ╔═╡ 03d755ee-9e19-11eb-376e-a16e7a61de4d
md"""
While `*` may seem like a surprising choice to users of languages that provide `+` for string concatenation, this use of `*` has precedent in mathematics, particularly in abstract algebra.
"""

# ╔═╡ 03d75628-9e19-11eb-26a8-c36508e80de0
md"""
In mathematics, `+` usually denotes a *commutative* operation, where the order of the operands does not matter. An example of this is matrix addition, where `A + B == B + A` for any matrices `A` and `B` that have the same shape. In contrast, `*` typically denotes a *noncommutative* operation, where the order of the operands *does* matter. An example of this is matrix multiplication, where in general `A * B != B * A`. As with matrix multiplication, string concatenation is noncommutative: `greet * whom != whom * greet`. As such, `*` is a more natural choice for an infix string concatenation operator, consistent with common mathematical use.
"""

# ╔═╡ 03d75666-9e19-11eb-1b6c-b3413a8cbdca
md"""
More precisely, the set of all finite-length strings *S* together with the string concatenation operator `*` forms a [free monoid](https://en.wikipedia.org/wiki/Free_monoid) (*S*, `*`). The identity element of this set is the empty string, `""`. Whenever a free monoid is not commutative, the operation is typically represented as `\cdot`, `*`, or a similar symbol, rather than `+`, which as stated usually implies commutativity.
"""

# ╔═╡ 03d75684-9e19-11eb-12cf-f7befd6baa1e
md"""
## [Interpolation](@id string-interpolation)
"""

# ╔═╡ 03d756a2-9e19-11eb-343b-3f5374bf4e50
md"""
Constructing strings using concatenation can become a bit cumbersome, however. To reduce the need for these verbose calls to [`string`](@ref) or repeated multiplications, Julia allows interpolation into string literals using `$`, as in Perl:
"""

# ╔═╡ 03d7581e-9e19-11eb-2659-0babd02f38ca
"$greet, $whom.\n"
"Hello, world.\n"

# ╔═╡ 03d7583c-9e19-11eb-19a9-c9e3011338c3
md"""
This is more readable and convenient and equivalent to the above string concatenation – the system rewrites this apparent single string literal into the call `string(greet, ", ", whom, ".\n")`.
"""

# ╔═╡ 03d7585a-9e19-11eb-2bd3-550bf1dd54b5
md"""
The shortest complete expression after the `$` is taken as the expression whose value is to be interpolated into the string. Thus, you can interpolate any expression into a string using parentheses:
"""

# ╔═╡ 03d75a92-9e19-11eb-3dee-ade5f2a44f8f
"1 + 2 = $(1 + 2)"
"1 + 2 = 3"

# ╔═╡ 03d75ac6-9e19-11eb-0eba-b525029bf23f
md"""
Both concatenation and string interpolation call [`string`](@ref) to convert objects into string form. However, `string` actually just returns the output of [`print`](@ref), so new types should add methods to [`print`](@ref) or [`show`](@ref) instead of `string`.
"""

# ╔═╡ 03d75aee-9e19-11eb-333c-ef1f3572a8b8
md"""
Most non-`AbstractString` objects are converted to strings closely corresponding to how they are entered as literal expressions:
"""

# ╔═╡ 03d75daa-9e19-11eb-2c01-8981b5ca302b
v = [1,2,3]

# ╔═╡ 03d75daa-9e19-11eb-30fc-3f020f44f9c5
"v: $v"
"v: [1, 2, 3]"

# ╔═╡ 03d75dd4-9e19-11eb-35eb-21dfe3191cbb
md"""
[`string`](@ref) is the identity for `AbstractString` and `AbstractChar` values, so these are interpolated into strings as themselves, unquoted and unescaped:
"""

# ╔═╡ 03d75fee-9e19-11eb-3be4-2f2a2777d91e
c = 'x'

# ╔═╡ 03d75fee-9e19-11eb-0b23-d5ad8d4116d4
"hi, $c"
"hi, x"

# ╔═╡ 03d76000-9e19-11eb-0b85-7759dfdefee5
md"""
To include a literal `$` in a string literal, escape it with a backslash:
"""

# ╔═╡ 03d76142-9e19-11eb-3082-0f08814e0842
print("I have \$100 in my account.\n")

# ╔═╡ 03d76168-9e19-11eb-3519-07fd59eee292
md"""
## Triple-Quoted String Literals
"""

# ╔═╡ 03d76188-9e19-11eb-1745-db24c67df49b
md"""
When strings are created using triple-quotes (`"""..."""`) they have some special behavior that can be useful for creating longer blocks of text.
"""

# ╔═╡ 03d76192-9e19-11eb-366d-0d71c976264e
md"""
First, triple-quoted strings are also dedented to the level of the least-indented line. This is useful for defining strings within code that is indented. For example:
"""

# ╔═╡ 03d763ae-9e19-11eb-0c74-b1d896d2a2d8
str = """
           Hello,
           world.
         """

# ╔═╡ 03d763cc-9e19-11eb-2881-c7aa141e10aa
md"""
In this case the final (empty) line before the closing `"""` sets the indentation level.
"""

# ╔═╡ 03d763ea-9e19-11eb-1ea7-77d35b546c4b
md"""
The dedentation level is determined as the longest common starting sequence of spaces or tabs in all lines, excluding the line following the opening `"""` and lines containing only spaces or tabs (the line containing the closing `"""` is always included). Then for all lines, excluding the text following the opening `"""`, the common starting sequence is removed (including lines containing only spaces and tabs if they start with this sequence), e.g.:
"""

# ╔═╡ 03d765e8-9e19-11eb-3003-6138a630e31a
"""    This
         is
           a test"""
"    This\nis\n  a test"

# ╔═╡ 03d7661a-9e19-11eb-2063-d1d4dd251dfa
md"""
Next, if the opening `"""` is followed by a newline, the newline is stripped from the resulting string.
"""

# ╔═╡ 03d76656-9e19-11eb-3016-fd18598ede67
md"""
```julia
"""hello"""
```
"""

# ╔═╡ 03d76660-9e19-11eb-00b7-57161cbcc4d1
md"""
is equivalent to
"""

# ╔═╡ 03d7667e-9e19-11eb-1bde-558bf8eadd56
md"""
```julia
"""
hello"""
```
"""

# ╔═╡ 03d7669c-9e19-11eb-2c76-bbd51182f08d
md"""
but
"""

# ╔═╡ 03d766a4-9e19-11eb-125c-e109b837d252
md"""
```julia
"""

hello"""
```
"""

# ╔═╡ 03d766ba-9e19-11eb-0966-85d580f27481
md"""
will contain a literal newline at the beginning.
"""

# ╔═╡ 03d766ce-9e19-11eb-1daf-0716112bc64d
md"""
Stripping of the newline is performed after the dedentation. For example:
"""

# ╔═╡ 03d76890-9e19-11eb-32eb-1dee250f5237
"""
         Hello,
         world."""
"Hello,\nworld."

# ╔═╡ 03d768a4-9e19-11eb-1f1b-3bdeb3dcc9d9
md"""
Trailing whitespace is left unaltered.
"""

# ╔═╡ 03d768b8-9e19-11eb-3341-fbeb00058829
md"""
Triple-quoted string literals can contain `"` characters without escaping.
"""

# ╔═╡ 03d768e2-9e19-11eb-1399-b1dbbd69ca2e
md"""
Note that line breaks in literal strings, whether single- or triple-quoted, result in a newline (LF) character `\n` in the string, even if your editor uses a carriage return `\r` (CR) or CRLF combination to end lines. To include a CR in a string, use an explicit escape `\r`; for example, you can enter the literal string `"a CRLF line ending\r\n"`.
"""

# ╔═╡ 03d768f4-9e19-11eb-0b40-0dad306f5f17
md"""
## Common Operations
"""

# ╔═╡ 03d76914-9e19-11eb-2cde-19cd64cff4de
md"""
You can lexicographically compare strings using the standard comparison operators:
"""

# ╔═╡ 03d76e58-9e19-11eb-349c-73a47030a98b
"abracadabra" < "xylophone"

# ╔═╡ 03d76e62-9e19-11eb-3a33-5fa9cca18f38
"abracadabra" == "xylophone"

# ╔═╡ 03d76e62-9e19-11eb-1132-2da5c271adae
"Hello, world." != "Goodbye, world."

# ╔═╡ 03d76e62-9e19-11eb-052a-df94a5149a40
"1 + 2 = 3" == "1 + 2 = $(1 + 2)"

# ╔═╡ 03d76e9e-9e19-11eb-3033-8fd9b7cb8f0e
md"""
You can search for the index of a particular character using the [`findfirst`](@ref) and [`findlast`](@ref) functions:
"""

# ╔═╡ 03d773f0-9e19-11eb-0285-e9dccc91c6b4
findfirst(isequal('o'), "xylophone")

# ╔═╡ 03d773f0-9e19-11eb-1ab8-215c51eb19a5
findlast(isequal('o'), "xylophone")

# ╔═╡ 03d773f8-9e19-11eb-3478-d3f03bf2ec51
findfirst(isequal('z'), "xylophone")

# ╔═╡ 03d77422-9e19-11eb-3123-d33cfd6197ed
md"""
You can start the search for a character at a given offset by using the functions [`findnext`](@ref) and [`findprev`](@ref):
"""

# ╔═╡ 03d77be6-9e19-11eb-15a3-edfd8fe2d171
findnext(isequal('o'), "xylophone", 1)

# ╔═╡ 03d77be6-9e19-11eb-18b8-097bbe7ac3eb
findnext(isequal('o'), "xylophone", 5)

# ╔═╡ 03d77bf0-9e19-11eb-0975-d327bda82da4
findprev(isequal('o'), "xylophone", 5)

# ╔═╡ 03d77bf0-9e19-11eb-23a3-89e4e3417e4b
findnext(isequal('o'), "xylophone", 8)

# ╔═╡ 03d77c18-9e19-11eb-1ee6-b52c7ba5b030
md"""
You can use the [`occursin`](@ref) function to check if a substring is found within a string:
"""

# ╔═╡ 03d78122-9e19-11eb-169c-21796c16b917
occursin("world", "Hello, world.")

# ╔═╡ 03d78122-9e19-11eb-1b9b-5956e290c312
occursin("o", "Xylophon")

# ╔═╡ 03d78122-9e19-11eb-1cbf-2ddfdc58dc5d
occursin("a", "Xylophon")

# ╔═╡ 03d78140-9e19-11eb-37a6-57b884ca1b31
occursin('o', "Xylophon")

# ╔═╡ 03d7815e-9e19-11eb-18a2-5bffcda89dbc
md"""
The last example shows that [`occursin`](@ref) can also look for a character literal.
"""

# ╔═╡ 03d78172-9e19-11eb-088b-7922fe052712
md"""
Two other handy string functions are [`repeat`](@ref) and [`join`](@ref):
"""

# ╔═╡ 03d78596-9e19-11eb-2169-ed375ae49c48
repeat(".:Z:.", 10)

# ╔═╡ 03d785aa-9e19-11eb-17ad-758b5a53819f
join(["apples", "bananas", "pineapples"], ", ", " and ")

# ╔═╡ 03d785be-9e19-11eb-134c-dbc85c6e1f49
md"""
Some other useful functions include:
"""

# ╔═╡ 03d7874e-9e19-11eb-3a83-9f5343d91de7
md"""
  * [`firstindex(str)`](@ref) gives the minimal (byte) index that can be used to index into `str` (always 1 for strings, not necessarily true for other containers).
  * [`lastindex(str)`](@ref) gives the maximal (byte) index that can be used to index into `str`.
  * [`length(str)`](@ref) the number of characters in `str`.
  * [`length(str, i, j)`](@ref) the number of valid character indices in `str` from `i` to `j`.
  * [`ncodeunits(str)`](@ref) number of [code units](https://en.wikipedia.org/wiki/Character_encoding#Terminology) in a string.
  * [`codeunit(str, i)`](@ref) gives the code unit value in the string `str` at index `i`.
  * [`thisind(str, i)`](@ref) given an arbitrary index into a string find the first index of the character into which the index points.
  * [`nextind(str, i, n=1)`](@ref) find the start of the `n`th character starting after index `i`.
  * [`prevind(str, i, n=1)`](@ref) find the start of the `n`th character starting before index `i`.
"""

# ╔═╡ 03d7876a-9e19-11eb-0e48-352575f653c6
md"""
## [Non-Standard String Literals](@id non-standard-string-literals)
"""

# ╔═╡ 03d7879c-9e19-11eb-2902-9fabe4e5b15b
md"""
There are situations when you want to construct a string or use string semantics, but the behavior of the standard string construct is not quite what is needed. For these kinds of situations, Julia provides [non-standard string literals](@ref). A non-standard string literal looks like a regular double-quoted string literal, but is immediately prefixed by an identifier, and doesn't behave quite like a normal string literal.  Regular expressions, byte array literals and version number literals, as described below, are some examples of non-standard string literals. Other examples are given in the [Metaprogramming](@ref) section.
"""

# ╔═╡ 03d787a8-9e19-11eb-0ac5-651a768249f6
md"""
## Regular Expressions
"""

# ╔═╡ 03d787e4-9e19-11eb-171f-a755abd76101
md"""
Julia has Perl-compatible regular expressions (regexes), as provided by the [PCRE](http://www.pcre.org/) library (a description of the syntax can be found [here](http://www.pcre.org/current/doc/html/pcre2syntax.html)). Regular expressions are related to strings in two ways: the obvious connection is that regular expressions are used to find regular patterns in strings; the other connection is that regular expressions are themselves input as strings, which are parsed into a state machine that can be used to efficiently search for patterns in strings. In Julia, regular expressions are input using non-standard string literals prefixed with various identifiers beginning with `r`. The most basic regular expression literal without any options turned on just uses `r"..."`:
"""

# ╔═╡ 03d789e2-9e19-11eb-2fff-8d5d40ee63c0
re = r"^\s*(?:#|$)"

# ╔═╡ 03d789e2-9e19-11eb-32c7-eb6be16593ee
typeof(re)

# ╔═╡ 03d78a00-9e19-11eb-25e0-259ecb72b7b1
md"""
To check if a regex matches a string, use [`occursin`](@ref):
"""

# ╔═╡ 03d78d2a-9e19-11eb-3d31-11fe5e097084
occursin(r"^\s*(?:#|$)", "not a comment")

# ╔═╡ 03d78d3c-9e19-11eb-36a8-77d9dfe881e5
occursin(r"^\s*(?:#|$)", "# a comment")

# ╔═╡ 03d78d66-9e19-11eb-3eb0-91c092871d10
md"""
As one can see here, [`occursin`](@ref) simply returns true or false, indicating whether a match for the given regex occurs in the string. Commonly, however, one wants to know not just whether a string matched, but also *how* it matched. To capture this information about a match, use the [`match`](@ref) function instead:
"""

# ╔═╡ 03d7907e-9e19-11eb-3935-2d75f305b77f
match(r"^\s*(?:#|$)", "not a comment")

# ╔═╡ 03d79086-9e19-11eb-306a-8dee81026758
match(r"^\s*(?:#|$)", "# a comment")

# ╔═╡ 03d790b8-9e19-11eb-1899-15d20f23304e
md"""
If the regular expression does not match the given string, [`match`](@ref) returns [`nothing`](@ref) – a special value that does not print anything at the interactive prompt. Other than not printing, it is a completely normal value and you can test for it programmatically:
"""

# ╔═╡ 03d790d6-9e19-11eb-1775-5555a735d265
md"""
```julia
m = match(r"^\s*(?:#|$)", line)
if m === nothing
    println("not a comment")
else
    println("blank or comment")
end
```
"""

# ╔═╡ 03d790f4-9e19-11eb-1765-4fbd00fafc45
md"""
If a regular expression does match, the value returned by [`match`](@ref) is a `RegexMatch` object. These objects record how the expression matches, including the substring that the pattern matches and any captured substrings, if there are any. This example only captures the portion of the substring that matches, but perhaps we want to capture any non-blank text after the comment character. We could do the following:
"""

# ╔═╡ 03d7932e-9e19-11eb-340f-8deb1679635e
m = match(r"^\s*(?:#\s*(.*?)\s*$|$)", "# a comment ")

# ╔═╡ 03d7934e-9e19-11eb-16a6-7bbe243e5113
md"""
When calling [`match`](@ref), you have the option to specify an index at which to start the search. For example:
"""

# ╔═╡ 03d799b2-9e19-11eb-1081-a7b89e1d6025
m = match(r"[0-9]","aaaa1aaaa2aaaa3",1)

# ╔═╡ 03d799b2-9e19-11eb-2ad7-1555a231d2bc
m = match(r"[0-9]","aaaa1aaaa2aaaa3",6)

# ╔═╡ 03d799be-9e19-11eb-0713-d9f13e9304d0
m = match(r"[0-9]","aaaa1aaaa2aaaa3",11)

# ╔═╡ 03d799dc-9e19-11eb-28ef-3bb371c05f36
md"""
You can extract the following info from a `RegexMatch` object:
"""

# ╔═╡ 03d79a68-9e19-11eb-0c60-09b17d3e9713
md"""
  * the entire substring matched: `m.match`
  * the captured substrings as an array of strings: `m.captures`
  * the offset at which the whole match begins: `m.offset`
  * the offsets of the captured substrings as a vector: `m.offsets`
"""

# ╔═╡ 03d79a88-9e19-11eb-258c-0bdd5c843130
md"""
For when a capture doesn't match, instead of a substring, `m.captures` contains `nothing` in that position, and `m.offsets` has a zero offset (recall that indices in Julia are 1-based, so a zero offset into a string is invalid). Here is a pair of somewhat contrived examples:
"""

# ╔═╡ 03d7a242-9e19-11eb-3c1a-0d2140294563
m = match(r"(a|b)(c)?(d)", "acd")

# ╔═╡ 03d7a242-9e19-11eb-1137-8d4028c901ad
m.match

# ╔═╡ 03d7a24c-9e19-11eb-2036-9f006b54abf9
m.captures

# ╔═╡ 03d7a24c-9e19-11eb-3a13-d9053ffc5b15
m.offset

# ╔═╡ 03d7a256-9e19-11eb-025d-2f594a6d3a51
m.offsets

# ╔═╡ 03d7a26a-9e19-11eb-3490-01a834dae58d
m = match(r"(a|b)(c)?(d)", "ad")

# ╔═╡ 03d7a26a-9e19-11eb-3338-c97c089d0e76
m.match

# ╔═╡ 03d7a274-9e19-11eb-038c-11daab2d1557
m.captures

# ╔═╡ 03d7a274-9e19-11eb-0d82-a1ab2aba5c9c
m.offset

# ╔═╡ 03d7a27e-9e19-11eb-236f-d74cc14c3288
m.offsets

# ╔═╡ 03d7a2a6-9e19-11eb-3382-1f47dfff4f74
md"""
It is convenient to have captures returned as an array so that one can use destructuring syntax to bind them to local variables:
"""

# ╔═╡ 03d7a472-9e19-11eb-0c24-4d37cb0dfa35
first, second, third = m.captures; first

# ╔═╡ 03d7a48e-9e19-11eb-0896-532f1b193aef
md"""
Captures can also be accessed by indexing the `RegexMatch` object with the number or name of the capture group:
"""

# ╔═╡ 03d7a862-9e19-11eb-31ce-2176f528e8f9
m=match(r"(?<hour>\d+):(?<minute>\d+)","12:45")

# ╔═╡ 03d7a86e-9e19-11eb-1a2c-a7885cea7d15
m[:minute]

# ╔═╡ 03d7a86e-9e19-11eb-19cf-e90995a8eb13
m[2]

# ╔═╡ 03d7a894-9e19-11eb-020b-dde21ffc6c73
md"""
Captures can be referenced in a substitution string when using [`replace`](@ref) by using `\n` to refer to the nth capture group and prefixing the substitution string with `s`. Capture group 0 refers to the entire match object. Named capture groups can be referenced in the substitution with `\g<groupname>`. For example:
"""

# ╔═╡ 03d7ab04-9e19-11eb-1809-55abb3a5d57f
replace("first second", r"(\w+) (?<agroup>\w+)" => s"\g<agroup> \1")

# ╔═╡ 03d7ab32-9e19-11eb-0a39-5b2f77d7ca40
md"""
Numbered capture groups can also be referenced as `\g<n>` for disambiguation, as in:
"""

# ╔═╡ 03d7ad46-9e19-11eb-3c41-4f63ed608075
replace("a", r"." => s"\g<0>1")

# ╔═╡ 03d7ad70-9e19-11eb-3f73-c90c97b8915c
md"""
You can modify the behavior of regular expressions by some combination of the flags `i`, `m`, `s`, and `x` after the closing double quote mark. These flags have the same meaning as they do in Perl, as explained in this excerpt from the [perlre manpage](http://perldoc.perl.org/perlre.html#Modifiers):
"""

# ╔═╡ 03d7ae68-9e19-11eb-3f3a-634dc695c358
i   Do

# ╔═╡ 03d7ae7c-9e19-11eb-3eb3-0b59e95af706
md"""
For example, the following regex has all three flags turned on:
"""

# ╔═╡ 03d7b104-9e19-11eb-2998-cbe61b78b1c4
r"a+.*b+.*?d$"ism

# ╔═╡ 03d7b104-9e19-11eb-0c80-f1102f70931d
match(r"a+.*b+.*?d$"ism, "Goodbye,\nOh, angry,\nBad world\n")

# ╔═╡ 03d7b12e-9e19-11eb-12aa-07dcdf09e9e5
md"""
The `r"..."` literal is constructed without interpolation and unescaping (except for quotation mark `"` which still has to be escaped). Here is an example showing the difference from standard string literals:
"""

# ╔═╡ 03d7b4d8-9e19-11eb-10cd-bbe9e3e3d7c3
x = 10

# ╔═╡ 03d7b4d8-9e19-11eb-2e4b-69daa0408cce
r"$x"

# ╔═╡ 03d7b4e4-9e19-11eb-14cc-fb6f64233140
"$x"
"10"

# ╔═╡ 03d7b4e4-9e19-11eb-2967-977fe06f402e
r"\x"

# ╔═╡ 03d7b4ee-9e19-11eb-297d-cde28fc5f691
"\x"

# ╔═╡ 03d7b50a-9e19-11eb-37b0-a1708d1bdb0d
md"""
Triple-quoted regex strings, of the form `r"""..."""`, are also supported (and may be convenient for regular expressions containing quotation marks or newlines).
"""

# ╔═╡ 03d7b520-9e19-11eb-18ef-cbaed27f58ec
md"""
The `Regex()` constructor may be used to create a valid regex string programmatically.  This permits using the contents of string variables and other string operations when constructing the regex string. Any of the regex codes above can be used within the single string argument to `Regex()`. Here are some examples:
"""

# ╔═╡ 03d7bfd4-9e19-11eb-220c-85b1c76805f2
using Dates

# ╔═╡ 03d7bfde-9e19-11eb-3f57-e571e19b7eda
d = Date(1962,7,10)

# ╔═╡ 03d7bfde-9e19-11eb-166e-a17c9b8b02ae
regex_d = Regex("Day " * string(day(d)))

# ╔═╡ 03d7bfe6-9e19-11eb-0556-a5fbb23707e9
match(regex_d, "It happened on Day 10")

# ╔═╡ 03d7bfe6-9e19-11eb-25b8-015100b39dd4
name = "Jon"

# ╔═╡ 03d7bffc-9e19-11eb-1a8f-115af7c0d854
regex_name = Regex("[\"( ]$name[\") ]")  # interpolate value of name

# ╔═╡ 03d7c006-9e19-11eb-0fee-09c3a6958f8a
match(regex_name," Jon ")

# ╔═╡ 03d7c006-9e19-11eb-0523-87e7dadbef08
match(regex_name,"[Jon]") === nothing

# ╔═╡ 03d7c024-9e19-11eb-0edf-57a4216b33a2
md"""
## [Byte Array Literals](@id man-byte-array-literals)
"""

# ╔═╡ 03d7c04c-9e19-11eb-36ac-f57fc969d0e4
md"""
Another useful non-standard string literal is the byte-array string literal: `b"..."`. This form lets you use string notation to express read only literal byte arrays – i.e. arrays of [`UInt8`](@ref) values. The type of those objects is `CodeUnits{UInt8, String}`. The rules for byte array literals are the following:
"""

# ╔═╡ 03d7c0bc-9e19-11eb-1d34-832c64821e7a
md"""
  * ASCII characters and ASCII escapes produce a single byte.
  * `\x` and octal escape sequences produce the *byte* corresponding to the escape value.
  * Unicode escape sequences produce a sequence of bytes encoding that code point in UTF-8.
"""

# ╔═╡ 03d7c0ce-9e19-11eb-1ce6-f94cbea2099d
md"""
There is some overlap between these rules since the behavior of `\x` and octal escapes less than 0x80 (128) are covered by both of the first two rules, but here these rules agree. Together, these rules allow one to easily use ASCII characters, arbitrary byte values, and UTF-8 sequences to produce arrays of bytes. Here is an example using all three:
"""

# ╔═╡ 03d7c1be-9e19-11eb-08c8-89bf4c53a8d1
b"DATA\xff\u2200"

# ╔═╡ 03d7c1e6-9e19-11eb-08e0-f9a2f8b9aea3
md"""
The ASCII string "DATA" corresponds to the bytes 68, 65, 84, 65. `\xff` produces the single byte 255. The Unicode escape `\u2200` is encoded in UTF-8 as the three bytes 226, 136, 128. Note that the resulting byte array does not correspond to a valid UTF-8 string:
"""

# ╔═╡ 03d7c308-9e19-11eb-25eb-13f08ea4c023
isvalid("DATA\xff\u2200")

# ╔═╡ 03d7c33a-9e19-11eb-0b3f-bbd266c26a04
md"""
As it was mentioned `CodeUnits{UInt8, String}` type behaves like read only array of `UInt8` and if you need a standard vector you can convert it using `Vector{UInt8}`:
"""

# ╔═╡ 03d7c74a-9e19-11eb-242c-e518ad84e473
x = b"123"

# ╔═╡ 03d7c760-9e19-11eb-2c71-c75be963ce03
x[1]

# ╔═╡ 03d7c760-9e19-11eb-2b83-cf15372d10e8
x[1] = 0x32

# ╔═╡ 03d7c768-9e19-11eb-12b8-1dd233c90a67
Vector{UInt8}(x)

# ╔═╡ 03d7c792-9e19-11eb-266f-3907899abce5
md"""
Also observe the significant distinction between `\xff` and `\uff`: the former escape sequence encodes the *byte 255*, whereas the latter escape sequence represents the *code point 255*, which is encoded as two bytes in UTF-8:
"""

# ╔═╡ 03d7c8da-9e19-11eb-3c39-d99377c068df
b"\xff"

# ╔═╡ 03d7c8da-9e19-11eb-0232-d76118a0f06e
b"\uff"

# ╔═╡ 03d7c8ee-9e19-11eb-2fdd-d34c59a991d3
md"""
Character literals use the same behavior.
"""

# ╔═╡ 03d7c916-9e19-11eb-1f10-cd9ceca84d64
md"""
For code points less than `\u80`, it happens that the UTF-8 encoding of each code point is just the single byte produced by the corresponding `\x` escape, so the distinction can safely be ignored. For the escapes `\x80` through `\xff` as compared to `\u80` through `\uff`, however, there is a major difference: the former escapes all encode single bytes, which – unless followed by very specific continuation bytes – do not form valid UTF-8 data, whereas the latter escapes all represent Unicode code points with two-byte encodings.
"""

# ╔═╡ 03d7c934-9e19-11eb-3e98-0dabb7658e76
md"""
If this is all extremely confusing, try reading ["The Absolute Minimum Every Software Developer Absolutely, Positively Must Know About Unicode and Character Sets"](https://www.joelonsoftware.com/2003/10/08/the-absolute-minimum-every-software-developer-absolutely-positively-must-know-about-unicode-and-character-sets-no-excuses/). It's an excellent introduction to Unicode and UTF-8, and may help alleviate some confusion regarding the matter.
"""

# ╔═╡ 03d7c952-9e19-11eb-1d04-b58695beba92
md"""
## [Version Number Literals](@id man-version-number-literals)
"""

# ╔═╡ 03d7c9a2-9e19-11eb-3e30-95a4b1e1d2f9
md"""
Version numbers can easily be expressed with non-standard string literals of the form [`v"..."`](@ref @v_str). Version number literals create [`VersionNumber`](@ref) objects which follow the specifications of [semantic versioning](https://semver.org/), and therefore are composed of major, minor and patch numeric values, followed by pre-release and build alpha-numeric annotations. For example, `v"0.2.1-rc1+win64"` is broken into major version `0`, minor version `2`, patch version `1`, pre-release `rc1` and build `win64`. When entering a version literal, everything except the major version number is optional, therefore e.g.  `v"0.2"` is equivalent to `v"0.2.0"` (with empty pre-release/build annotations), `v"2"` is equivalent to `v"2.0.0"`, and so on.
"""

# ╔═╡ 03d7c9ca-9e19-11eb-117a-c14ffddb5ea4
md"""
`VersionNumber` objects are mostly useful to easily and correctly compare two (or more) versions. For example, the constant [`VERSION`](@ref) holds Julia version number as a `VersionNumber` object, and therefore one can define some version-specific behavior using simple statements as:
"""

# ╔═╡ 03d7c9de-9e19-11eb-3c22-cff189974bd1
md"""
```julia
if v"0.2" <= VERSION < v"0.3-"
    # do something specific to 0.2 release series
end
```
"""

# ╔═╡ 03d7ca06-9e19-11eb-27ce-ffc34ead4a5c
md"""
Note that in the above example the non-standard version number `v"0.3-"` is used, with a trailing `-`: this notation is a Julia extension of the standard, and it's used to indicate a version which is lower than any `0.3` release, including all of its pre-releases. So in the above example the code would only run with stable `0.2` versions, and exclude such versions as `v"0.3.0-rc1"`. In order to also allow for unstable (i.e. pre-release) `0.2` versions, the lower bound check should be modified like this: `v"0.2-" <= VERSION`.
"""

# ╔═╡ 03d7ca30-9e19-11eb-26d9-8f982209710d
md"""
Another non-standard version specification extension allows one to use a trailing `+` to express an upper limit on build versions, e.g.  `VERSION > v"0.2-rc1+"` can be used to mean any version above `0.2-rc1` and any of its builds: it will return `false` for version `v"0.2-rc1+win64"` and `true` for `v"0.2-rc2"`.
"""

# ╔═╡ 03d7ca42-9e19-11eb-182a-2924253536ed
md"""
It is good practice to use such special versions in comparisons (particularly, the trailing `-` should always be used on upper bounds unless there's a good reason not to), but they must not be used as the actual version number of anything, as they are invalid in the semantic versioning scheme.
"""

# ╔═╡ 03d7ca62-9e19-11eb-3583-e398adc5ca86
md"""
Besides being used for the [`VERSION`](@ref) constant, `VersionNumber` objects are widely used in the `Pkg` module, to specify packages versions and their dependencies.
"""

# ╔═╡ 03d7ca74-9e19-11eb-3e19-9b720bc25007
md"""
## [Raw String Literals](@id man-raw-string-literals)
"""

# ╔═╡ 03d7ca94-9e19-11eb-36bc-ebd28ec67f2f
md"""
Raw strings without interpolation or unescaping can be expressed with non-standard string literals of the form `raw"..."`. Raw string literals create ordinary `String` objects which contain the enclosed contents exactly as entered with no interpolation or unescaping. This is useful for strings which contain code or markup in other languages which use `$` or `\` as special characters.
"""

# ╔═╡ 03d7caa6-9e19-11eb-063c-19591a889ece
md"""
The exception is that quotation marks still must be escaped, e.g. `raw"\""` is equivalent to `"\""`. To make it possible to express all strings, backslashes then also must be escaped, but only when appearing right before a quote character:
"""

# ╔═╡ 03d7cc0e-9e19-11eb-372e-e193c35343cd
println(raw"\\ \\\"")

# ╔═╡ 03d7cc22-9e19-11eb-047b-f5cf57db2cb3
md"""
Notice that the first two backslashes appear verbatim in the output, since they do not precede a quote character. However, the next backslash character escapes the backslash that follows it, and the last backslash escapes a quote, since these backslashes appear before a quote.
"""

# ╔═╡ Cell order:
# ╟─03d6de66-9e19-11eb-2405-45c3efc128d3
# ╟─03d6dee8-9e19-11eb-3927-b1203f595a8c
# ╟─03d6defc-9e19-11eb-1ef7-85510ea1e766
# ╟─03d6e1a4-9e19-11eb-105f-fb1c4f54bbed
# ╟─03d6e1d6-9e19-11eb-09c9-87ccb8fe06a3
# ╟─03d6e212-9e19-11eb-14f8-93522cf0c441
# ╠═03d6e686-9e19-11eb-2507-5fea8bfc4f8e
# ╠═03d6e690-9e19-11eb-3932-65a5e155ee6b
# ╟─03d6e6b8-9e19-11eb-04a4-7d3bb518fb91
# ╠═03d6e8e8-9e19-11eb-2806-eb795fc5d352
# ╠═03d6e906-9e19-11eb-293d-bffed35902f7
# ╟─03d6e92e-9e19-11eb-30b3-07f07d188fd0
# ╠═03d6ea6e-9e19-11eb-1f1a-addacf7cc189
# ╟─03d6ea96-9e19-11eb-0439-4da1bd4eda37
# ╠═03d6ed52-9e19-11eb-135e-774ce370c752
# ╠═03d6ed52-9e19-11eb-1665-250beaede44c
# ╟─03d6ed7a-9e19-11eb-009d-abf1ecfb1fea
# ╟─03d6ed98-9e19-11eb-2b9e-492c63fa48d7
# ╠═03d6f042-9e19-11eb-35bf-7f2f915e6c6a
# ╠═03d6f054-9e19-11eb-1884-ad75409b6a42
# ╠═03d6f054-9e19-11eb-3d2a-a7d8894ca6f4
# ╠═03d6f05e-9e19-11eb-14f0-39b8b43378a1
# ╟─03d6f086-9e19-11eb-14e6-4944d01fbd62
# ╠═03d6f9dc-9e19-11eb-2909-455550d8d4d5
# ╠═03d6f9e8-9e19-11eb-23a9-1361f4ed031d
# ╠═03d6f9f0-9e19-11eb-05be-8750b752f871
# ╠═03d6f9f0-9e19-11eb-2ced-e51fccad00b7
# ╠═03d6fa1a-9e19-11eb-1b73-ede233a0495b
# ╠═03d6fa22-9e19-11eb-294f-c5f3f6e68c61
# ╟─03d6fa68-9e19-11eb-35cc-0d51373eef9d
# ╠═03d6ff2c-9e19-11eb-0710-d3646965c2c1
# ╠═03d6ff40-9e19-11eb-1190-f7cca7bfbd87
# ╠═03d6ff4a-9e19-11eb-3878-1f68cc2aefb3
# ╠═03d6ff4a-9e19-11eb-31d9-65b3bc2e82cd
# ╠═03d6ff56-9e19-11eb-399d-71fa33a505ad
# ╟─03d6ff72-9e19-11eb-23a7-afe5aebea04b
# ╟─03d6ff7c-9e19-11eb-2500-dd1682bf1ed6
# ╠═03d70286-9e19-11eb-2309-6b3c45647c48
# ╠═03d70286-9e19-11eb-2602-2d5020efe489
# ╟─03d702a6-9e19-11eb-3ee8-6d6094b746b9
# ╠═03d70602-9e19-11eb-3d50-9b80b3f25baa
# ╠═03d70602-9e19-11eb-3d23-eb0e73d9c6ac
# ╠═03d7060c-9e19-11eb-0be1-41edca97b780
# ╠═03d7060c-9e19-11eb-3846-91b6c5b41006
# ╟─03d70670-9e19-11eb-3a5e-cf4bfcbf2511
# ╟─03d706b6-9e19-11eb-174b-7d58ad4a9ebe
# ╠═03d70936-9e19-11eb-16c0-e50268471a8d
# ╠═03d70940-9e19-11eb-3500-8da664bb2935
# ╟─03d70968-9e19-11eb-2422-6323bd1690ba
# ╠═03d70bac-9e19-11eb-3b22-2fd79cb7fb7e
# ╠═03d70bb6-9e19-11eb-2190-11ac85722f62
# ╟─03d70bc0-9e19-11eb-3f6f-adb86cdd3bf8
# ╠═03d70d34-9e19-11eb-0e06-2775db2627cc
# ╟─03d70d50-9e19-11eb-1ee7-557996bec61a
# ╠═03d70f3a-9e19-11eb-0d63-23b870364b04
# ╠═03d70f3a-9e19-11eb-389c-a3e4fb87bc6e
# ╟─03d70f58-9e19-11eb-37c9-c530aa8b233c
# ╟─03d70f76-9e19-11eb-1751-b9d57c348502
# ╠═03d712aa-9e19-11eb-0516-959dec0af5b8
# ╠═03d712aa-9e19-11eb-2eb8-234e1cbe8098
# ╠═03d712be-9e19-11eb-01f8-95e359514da8
# ╟─03d712f0-9e19-11eb-37af-990eafb96907
# ╟─03d71302-9e19-11eb-0131-dbe34069d3ef
# ╟─03d7132c-9e19-11eb-3998-0168c65c35dc
# ╠═03d7144e-9e19-11eb-04dd-7f66578d7248
# ╟─03d7146a-9e19-11eb-2eed-151d9a2dcfea
# ╟─03d7148a-9e19-11eb-2b26-fd2b3d0d5da7
# ╠═03d7173a-9e19-11eb-3989-eff53fa4e66d
# ╠═03d71750-9e19-11eb-2495-b7ddd66a45c6
# ╠═03d71750-9e19-11eb-15f4-53bae67351d8
# ╠═03d7175a-9e19-11eb-0046-95f904f5b6eb
# ╟─03d71782-9e19-11eb-3673-f1cb8e87e0c9
# ╟─03d71796-9e19-11eb-3be6-7fcfa85142ae
# ╠═03d73a00-9e19-11eb-22f6-cb5a4cf28495
# ╠═03d73a00-9e19-11eb-353e-4930e6d1c508
# ╠═03d73a0a-9e19-11eb-1de9-8bbc5cb635dd
# ╟─03d73a5a-9e19-11eb-0baf-611cbfe27177
# ╟─03d73a64-9e19-11eb-3774-e7e62321a276
# ╠═03d73e6a-9e19-11eb-1afb-49820cb86b54
# ╠═03d73e7e-9e19-11eb-15fa-0fd817d882ae
# ╠═03d73e7e-9e19-11eb-065e-b9232589dc56
# ╟─03d73eb0-9e19-11eb-269f-b9e939fdd25e
# ╠═03d7425c-9e19-11eb-18cd-fd21020e77f7
# ╟─03d7427c-9e19-11eb-19e6-a9d9622a88bd
# ╠═03d7441e-9e19-11eb-0485-cb3c7260a311
# ╟─03d74444-9e19-11eb-1850-1f5956eb9452
# ╠═03d74554-9e19-11eb-3f46-a753669c5fc8
# ╟─03d745a4-9e19-11eb-355d-c19f9de6b1c6
# ╟─03d745c2-9e19-11eb-2791-2164febb3e99
# ╟─03d7469e-9e19-11eb-2766-a35b486e3a41
# ╟─03d746bc-9e19-11eb-09ff-0b9726095478
# ╠═03d74b58-9e19-11eb-3cfc-29b34c5a2609
# ╠═03d74b58-9e19-11eb-0e49-69a8d62c2524
# ╠═03d74b62-9e19-11eb-12ee-7906488bbb03
# ╠═03d74b62-9e19-11eb-0112-d3747cf15f01
# ╠═03d74b76-9e19-11eb-23a9-238320736917
# ╟─03d74b9e-9e19-11eb-046d-472c206eeff8
# ╟─03d74bd0-9e19-11eb-330c-111c031db3d3
# ╟─03d74bf8-9e19-11eb-1486-75fe43ce65f6
# ╟─03d74c02-9e19-11eb-33fe-df3bba1a9c47
# ╠═03d74f52-9e19-11eb-25c2-8ddc6be04b2a
# ╠═03d74f5e-9e19-11eb-0403-1f323eb25713
# ╠═03d74f5e-9e19-11eb-170b-27dff183964a
# ╟─03d74f7c-9e19-11eb-21ee-afee216bd342
# ╠═03d75418-9e19-11eb-1eab-bf99ec926c6c
# ╠═03d75422-9e19-11eb-0775-f16fa73a0eb3
# ╠═03d75422-9e19-11eb-3eca-61fccd1421a1
# ╠═03d75436-9e19-11eb-37e4-1fb638557264
# ╟─03d7544a-9e19-11eb-3728-2120368e467b
# ╟─03d75468-9e19-11eb-2833-a50474a6cf2e
# ╠═03d755bc-9e19-11eb-2fe8-256f1929cff9
# ╟─03d755ee-9e19-11eb-376e-a16e7a61de4d
# ╟─03d75628-9e19-11eb-26a8-c36508e80de0
# ╟─03d75666-9e19-11eb-1b6c-b3413a8cbdca
# ╟─03d75684-9e19-11eb-12cf-f7befd6baa1e
# ╟─03d756a2-9e19-11eb-343b-3f5374bf4e50
# ╠═03d7581e-9e19-11eb-2659-0babd02f38ca
# ╟─03d7583c-9e19-11eb-19a9-c9e3011338c3
# ╟─03d7585a-9e19-11eb-2bd3-550bf1dd54b5
# ╠═03d75a92-9e19-11eb-3dee-ade5f2a44f8f
# ╟─03d75ac6-9e19-11eb-0eba-b525029bf23f
# ╟─03d75aee-9e19-11eb-333c-ef1f3572a8b8
# ╠═03d75daa-9e19-11eb-2c01-8981b5ca302b
# ╠═03d75daa-9e19-11eb-30fc-3f020f44f9c5
# ╟─03d75dd4-9e19-11eb-35eb-21dfe3191cbb
# ╠═03d75fee-9e19-11eb-3be4-2f2a2777d91e
# ╠═03d75fee-9e19-11eb-0b23-d5ad8d4116d4
# ╟─03d76000-9e19-11eb-0b85-7759dfdefee5
# ╠═03d76142-9e19-11eb-3082-0f08814e0842
# ╟─03d76168-9e19-11eb-3519-07fd59eee292
# ╟─03d76188-9e19-11eb-1745-db24c67df49b
# ╟─03d76192-9e19-11eb-366d-0d71c976264e
# ╠═03d763ae-9e19-11eb-0c74-b1d896d2a2d8
# ╟─03d763cc-9e19-11eb-2881-c7aa141e10aa
# ╟─03d763ea-9e19-11eb-1ea7-77d35b546c4b
# ╠═03d765e8-9e19-11eb-3003-6138a630e31a
# ╟─03d7661a-9e19-11eb-2063-d1d4dd251dfa
# ╟─03d76656-9e19-11eb-3016-fd18598ede67
# ╟─03d76660-9e19-11eb-00b7-57161cbcc4d1
# ╟─03d7667e-9e19-11eb-1bde-558bf8eadd56
# ╟─03d7669c-9e19-11eb-2c76-bbd51182f08d
# ╟─03d766a4-9e19-11eb-125c-e109b837d252
# ╟─03d766ba-9e19-11eb-0966-85d580f27481
# ╟─03d766ce-9e19-11eb-1daf-0716112bc64d
# ╠═03d76890-9e19-11eb-32eb-1dee250f5237
# ╟─03d768a4-9e19-11eb-1f1b-3bdeb3dcc9d9
# ╟─03d768b8-9e19-11eb-3341-fbeb00058829
# ╟─03d768e2-9e19-11eb-1399-b1dbbd69ca2e
# ╟─03d768f4-9e19-11eb-0b40-0dad306f5f17
# ╟─03d76914-9e19-11eb-2cde-19cd64cff4de
# ╠═03d76e58-9e19-11eb-349c-73a47030a98b
# ╠═03d76e62-9e19-11eb-3a33-5fa9cca18f38
# ╠═03d76e62-9e19-11eb-1132-2da5c271adae
# ╠═03d76e62-9e19-11eb-052a-df94a5149a40
# ╟─03d76e9e-9e19-11eb-3033-8fd9b7cb8f0e
# ╠═03d773f0-9e19-11eb-0285-e9dccc91c6b4
# ╠═03d773f0-9e19-11eb-1ab8-215c51eb19a5
# ╠═03d773f8-9e19-11eb-3478-d3f03bf2ec51
# ╟─03d77422-9e19-11eb-3123-d33cfd6197ed
# ╠═03d77be6-9e19-11eb-15a3-edfd8fe2d171
# ╠═03d77be6-9e19-11eb-18b8-097bbe7ac3eb
# ╠═03d77bf0-9e19-11eb-0975-d327bda82da4
# ╠═03d77bf0-9e19-11eb-23a3-89e4e3417e4b
# ╟─03d77c18-9e19-11eb-1ee6-b52c7ba5b030
# ╠═03d78122-9e19-11eb-169c-21796c16b917
# ╠═03d78122-9e19-11eb-1b9b-5956e290c312
# ╠═03d78122-9e19-11eb-1cbf-2ddfdc58dc5d
# ╠═03d78140-9e19-11eb-37a6-57b884ca1b31
# ╟─03d7815e-9e19-11eb-18a2-5bffcda89dbc
# ╟─03d78172-9e19-11eb-088b-7922fe052712
# ╠═03d78596-9e19-11eb-2169-ed375ae49c48
# ╠═03d785aa-9e19-11eb-17ad-758b5a53819f
# ╟─03d785be-9e19-11eb-134c-dbc85c6e1f49
# ╟─03d7874e-9e19-11eb-3a83-9f5343d91de7
# ╟─03d7876a-9e19-11eb-0e48-352575f653c6
# ╟─03d7879c-9e19-11eb-2902-9fabe4e5b15b
# ╟─03d787a8-9e19-11eb-0ac5-651a768249f6
# ╟─03d787e4-9e19-11eb-171f-a755abd76101
# ╠═03d789e2-9e19-11eb-2fff-8d5d40ee63c0
# ╠═03d789e2-9e19-11eb-32c7-eb6be16593ee
# ╟─03d78a00-9e19-11eb-25e0-259ecb72b7b1
# ╠═03d78d2a-9e19-11eb-3d31-11fe5e097084
# ╠═03d78d3c-9e19-11eb-36a8-77d9dfe881e5
# ╟─03d78d66-9e19-11eb-3eb0-91c092871d10
# ╠═03d7907e-9e19-11eb-3935-2d75f305b77f
# ╠═03d79086-9e19-11eb-306a-8dee81026758
# ╟─03d790b8-9e19-11eb-1899-15d20f23304e
# ╟─03d790d6-9e19-11eb-1775-5555a735d265
# ╟─03d790f4-9e19-11eb-1765-4fbd00fafc45
# ╠═03d7932e-9e19-11eb-340f-8deb1679635e
# ╟─03d7934e-9e19-11eb-16a6-7bbe243e5113
# ╠═03d799b2-9e19-11eb-1081-a7b89e1d6025
# ╠═03d799b2-9e19-11eb-2ad7-1555a231d2bc
# ╠═03d799be-9e19-11eb-0713-d9f13e9304d0
# ╟─03d799dc-9e19-11eb-28ef-3bb371c05f36
# ╟─03d79a68-9e19-11eb-0c60-09b17d3e9713
# ╟─03d79a88-9e19-11eb-258c-0bdd5c843130
# ╠═03d7a242-9e19-11eb-3c1a-0d2140294563
# ╠═03d7a242-9e19-11eb-1137-8d4028c901ad
# ╠═03d7a24c-9e19-11eb-2036-9f006b54abf9
# ╠═03d7a24c-9e19-11eb-3a13-d9053ffc5b15
# ╠═03d7a256-9e19-11eb-025d-2f594a6d3a51
# ╠═03d7a26a-9e19-11eb-3490-01a834dae58d
# ╠═03d7a26a-9e19-11eb-3338-c97c089d0e76
# ╠═03d7a274-9e19-11eb-038c-11daab2d1557
# ╠═03d7a274-9e19-11eb-0d82-a1ab2aba5c9c
# ╠═03d7a27e-9e19-11eb-236f-d74cc14c3288
# ╟─03d7a2a6-9e19-11eb-3382-1f47dfff4f74
# ╠═03d7a472-9e19-11eb-0c24-4d37cb0dfa35
# ╟─03d7a48e-9e19-11eb-0896-532f1b193aef
# ╠═03d7a862-9e19-11eb-31ce-2176f528e8f9
# ╠═03d7a86e-9e19-11eb-1a2c-a7885cea7d15
# ╠═03d7a86e-9e19-11eb-19cf-e90995a8eb13
# ╟─03d7a894-9e19-11eb-020b-dde21ffc6c73
# ╠═03d7ab04-9e19-11eb-1809-55abb3a5d57f
# ╟─03d7ab32-9e19-11eb-0a39-5b2f77d7ca40
# ╠═03d7ad46-9e19-11eb-3c41-4f63ed608075
# ╟─03d7ad70-9e19-11eb-3f73-c90c97b8915c
# ╠═03d7ae68-9e19-11eb-3f3a-634dc695c358
# ╟─03d7ae7c-9e19-11eb-3eb3-0b59e95af706
# ╠═03d7b104-9e19-11eb-2998-cbe61b78b1c4
# ╠═03d7b104-9e19-11eb-0c80-f1102f70931d
# ╟─03d7b12e-9e19-11eb-12aa-07dcdf09e9e5
# ╠═03d7b4d8-9e19-11eb-10cd-bbe9e3e3d7c3
# ╠═03d7b4d8-9e19-11eb-2e4b-69daa0408cce
# ╠═03d7b4e4-9e19-11eb-14cc-fb6f64233140
# ╠═03d7b4e4-9e19-11eb-2967-977fe06f402e
# ╠═03d7b4ee-9e19-11eb-297d-cde28fc5f691
# ╟─03d7b50a-9e19-11eb-37b0-a1708d1bdb0d
# ╟─03d7b520-9e19-11eb-18ef-cbaed27f58ec
# ╠═03d7bfd4-9e19-11eb-220c-85b1c76805f2
# ╠═03d7bfde-9e19-11eb-3f57-e571e19b7eda
# ╠═03d7bfde-9e19-11eb-166e-a17c9b8b02ae
# ╠═03d7bfe6-9e19-11eb-0556-a5fbb23707e9
# ╠═03d7bfe6-9e19-11eb-25b8-015100b39dd4
# ╠═03d7bffc-9e19-11eb-1a8f-115af7c0d854
# ╠═03d7c006-9e19-11eb-0fee-09c3a6958f8a
# ╠═03d7c006-9e19-11eb-0523-87e7dadbef08
# ╟─03d7c024-9e19-11eb-0edf-57a4216b33a2
# ╟─03d7c04c-9e19-11eb-36ac-f57fc969d0e4
# ╟─03d7c0bc-9e19-11eb-1d34-832c64821e7a
# ╟─03d7c0ce-9e19-11eb-1ce6-f94cbea2099d
# ╠═03d7c1be-9e19-11eb-08c8-89bf4c53a8d1
# ╟─03d7c1e6-9e19-11eb-08e0-f9a2f8b9aea3
# ╠═03d7c308-9e19-11eb-25eb-13f08ea4c023
# ╟─03d7c33a-9e19-11eb-0b3f-bbd266c26a04
# ╠═03d7c74a-9e19-11eb-242c-e518ad84e473
# ╠═03d7c760-9e19-11eb-2c71-c75be963ce03
# ╠═03d7c760-9e19-11eb-2b83-cf15372d10e8
# ╠═03d7c768-9e19-11eb-12b8-1dd233c90a67
# ╟─03d7c792-9e19-11eb-266f-3907899abce5
# ╠═03d7c8da-9e19-11eb-3c39-d99377c068df
# ╠═03d7c8da-9e19-11eb-0232-d76118a0f06e
# ╟─03d7c8ee-9e19-11eb-2fdd-d34c59a991d3
# ╟─03d7c916-9e19-11eb-1f10-cd9ceca84d64
# ╟─03d7c934-9e19-11eb-3e98-0dabb7658e76
# ╟─03d7c952-9e19-11eb-1d04-b58695beba92
# ╟─03d7c9a2-9e19-11eb-3e30-95a4b1e1d2f9
# ╟─03d7c9ca-9e19-11eb-117a-c14ffddb5ea4
# ╟─03d7c9de-9e19-11eb-3c22-cff189974bd1
# ╟─03d7ca06-9e19-11eb-27ce-ffc34ead4a5c
# ╟─03d7ca30-9e19-11eb-26d9-8f982209710d
# ╟─03d7ca42-9e19-11eb-182a-2924253536ed
# ╟─03d7ca62-9e19-11eb-3583-e398adc5ca86
# ╟─03d7ca74-9e19-11eb-3e19-9b720bc25007
# ╟─03d7ca94-9e19-11eb-36bc-ebd28ec67f2f
# ╟─03d7caa6-9e19-11eb-063c-19591a889ece
# ╠═03d7cc0e-9e19-11eb-372e-e193c35343cd
# ╟─03d7cc22-9e19-11eb-047b-f5cf57db2cb3
