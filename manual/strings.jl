### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ b15e8b6b-0721-4193-a6c5-850e583643db
md"""
# [Strings](@id man-strings)
"""

# ╔═╡ 95d5e94e-5e20-4202-a37d-060e2a1f1876
md"""
Strings are finite sequences of characters. Of course, the real trouble comes when one asks what a character is. The characters that English speakers are familiar with are the letters `A`, `B`, `C`, etc., together with numerals and common punctuation symbols. These characters are standardized together with a mapping to integer values between 0 and 127 by the [ASCII](https://en.wikipedia.org/wiki/ASCII) standard. There are, of course, many other characters used in non-English languages, including variants of the ASCII characters with accents and other modifications, related scripts such as Cyrillic and Greek, and scripts completely unrelated to ASCII and English, including Arabic, Chinese, Hebrew, Hindi, Japanese, and Korean. The [Unicode](https://en.wikipedia.org/wiki/Unicode) standard tackles the complexities of what exactly a character is, and is generally accepted as the definitive standard addressing this problem. Depending on your needs, you can either ignore these complexities entirely and just pretend that only ASCII characters exist, or you can write code that can handle any of the characters or encodings that one may encounter when handling non-ASCII text. Julia makes dealing with plain ASCII text simple and efficient, and handling Unicode is as simple and efficient as possible. In particular, you can write C-style string code to process ASCII strings, and they will work as expected, both in terms of performance and semantics. If such code encounters non-ASCII text, it will gracefully fail with a clear error message, rather than silently introducing corrupt results. When this happens, modifying the code to handle non-ASCII data is straightforward.
"""

# ╔═╡ 09ec0d44-9eb4-410a-b8f4-a488c20e658f
md"""
There are a few noteworthy high-level features about Julia's strings:
"""

# ╔═╡ 0ba1899c-d085-4142-8a4b-5decc8b9bc31
md"""
  * The built-in concrete type used for strings (and string literals) in Julia is [`String`](@ref). This supports the full range of [Unicode](https://en.wikipedia.org/wiki/Unicode) characters via the [UTF-8](https://en.wikipedia.org/wiki/UTF-8) encoding. (A [`transcode`](@ref) function is provided to convert to/from other Unicode encodings.)
  * All string types are subtypes of the abstract type `AbstractString`, and external packages define additional `AbstractString` subtypes (e.g. for other encodings).  If you define a function expecting a string argument, you should declare the type as `AbstractString` in order to accept any string type.
  * Like C and Java, but unlike most dynamic languages, Julia has a first-class type for representing a single character, called [`AbstractChar`](@ref). The built-in [`Char`](@ref) subtype of `AbstractChar` is a 32-bit primitive type that can represent any Unicode character (and which is based on the UTF-8 encoding).
  * As in Java, strings are immutable: the value of an `AbstractString` object cannot be changed. To construct a different string value, you construct a new string from parts of other strings.
  * Conceptually, a string is a *partial function* from indices to characters: for some index values, no character value is returned, and instead an exception is thrown. This allows for efficient indexing into strings by the byte index of an encoded representation rather than by a character index, which cannot be implemented both efficiently and simply for variable-width encodings of Unicode strings.
"""

# ╔═╡ 95d7b4c2-5068-46a6-848b-be6ab9d20403
md"""
## [Characters](@id man-characters)
"""

# ╔═╡ 47ad0bb5-dd79-4e16-a1d6-2a80478d95f6
md"""
A `Char` value represents a single character: it is just a 32-bit primitive type with a special literal representation and appropriate arithmetic behaviors, and which can be converted to a numeric value representing a [Unicode code point](https://en.wikipedia.org/wiki/Code_point).  (Julia packages may define other subtypes of `AbstractChar`, e.g. to optimize operations for other [text encodings](https://en.wikipedia.org/wiki/Character_encoding).) Here is how `Char` values are input and shown:
"""

# ╔═╡ 3c2f79ec-11fa-4515-9ab2-fee088de8cf3
c = 'x'

# ╔═╡ 327af07c-2297-4511-80e6-81373e3527a8
typeof(c)

# ╔═╡ 87e057f3-96a5-4d0f-a277-abda284c12aa
md"""
You can easily convert a `Char` to its integer value, i.e. code point:
"""

# ╔═╡ e548909a-735e-450d-84d0-a75d4ce85118
c = Int('x')

# ╔═╡ 5f0f96fd-93d9-4dbb-8f09-dd4893b3c2ef
typeof(c)

# ╔═╡ 1d3463b1-9274-458d-85ee-335f379a0645
md"""
On 32-bit architectures, [`typeof(c)`](@ref) will be [`Int32`](@ref). You can convert an integer value back to a `Char` just as easily:
"""

# ╔═╡ 3993ef35-d0ae-4c98-9195-debe80e103ea
Char(120)

# ╔═╡ 273d7f25-c617-49c4-acdb-5c94fe393c32
md"""
Not all integer values are valid Unicode code points, but for performance, the `Char` conversion does not check that every character value is valid. If you want to check that each converted value is a valid code point, use the [`isvalid`](@ref) function:
"""

# ╔═╡ b4f78f7c-1339-4428-9755-f6eda54d0bc5
Char(0x110000)

# ╔═╡ d208c982-3659-4a7f-9e76-4c65f1a7fb7e
isvalid(Char, 0x110000)

# ╔═╡ f66d6364-6369-46c1-8dae-9e15c4c2376a
md"""
As of this writing, the valid Unicode code points are `U+0000` through `U+D7FF` and `U+E000` through `U+10FFFF`. These have not all been assigned intelligible meanings yet, nor are they necessarily interpretable by applications, but all of these values are considered to be valid Unicode characters.
"""

# ╔═╡ ec848bda-5d48-4515-8476-433fa3aee8d5
md"""
You can input any Unicode character in single quotes using `\u` followed by up to four hexadecimal digits or `\U` followed by up to eight hexadecimal digits (the longest valid value only requires six):
"""

# ╔═╡ fe4d78ec-7d34-448b-8c97-2fb508d23eba
'\u0'

# ╔═╡ 518e2a00-c0f0-4ca1-a798-022fbc9f73ef
'\u78'

# ╔═╡ 2e9442c2-8421-485d-9223-1d3e74462bef
'\u2200'

# ╔═╡ 6d45d921-ed00-45f1-8779-d0af175ce705
'\U10ffff'

# ╔═╡ 56c65342-462b-4bfa-beb2-e4a5b713f4cf
md"""
Julia uses your system's locale and language settings to determine which characters can be printed as-is and which must be output using the generic, escaped `\u` or `\U` input forms. In addition to these Unicode escape forms, all of [C's traditional escaped input forms](https://en.wikipedia.org/wiki/C_syntax#Backslash_escapes) can also be used:
"""

# ╔═╡ 8617acc0-c78d-481e-a51e-94aeaaeeedb9
Int('\0')

# ╔═╡ 75086f82-a9ff-477f-8bc7-ebcfe1adca33
Int('\t')

# ╔═╡ caa79d4f-87b2-4cf4-be48-bc462c66dbbc
Int('\n')

# ╔═╡ 09650e31-982c-461c-b131-0ce64af54029
Int('\e')

# ╔═╡ e77a81ac-16fd-415e-b258-1aaf0ee107bf
Int('\x7f')

# ╔═╡ 064af764-855c-46bc-8e6f-1d22e96db509
Int('\177')

# ╔═╡ 5bdd0e50-069a-4e2e-8097-0e0c714782f7
md"""
You can do comparisons and a limited amount of arithmetic with `Char` values:
"""

# ╔═╡ fed00260-481b-40a8-96b5-e09c492ad7a1
'A' < 'a'

# ╔═╡ 52b68640-079c-4abf-804b-0fd79c7bb0e3
'A' <= 'a' <= 'Z'

# ╔═╡ aacaa0ef-c4f6-4832-93fe-7c1d1b528f10
'A' <= 'X' <= 'Z'

# ╔═╡ 6bce0891-115a-464d-8cd8-16cf41149acb
'x' - 'a'

# ╔═╡ b3ccd1a3-74fa-49e9-9b64-abc7d8c27ddb
'A' + 1

# ╔═╡ 32b33218-c089-404c-8080-69ac13d3cc30
md"""
## String Basics
"""

# ╔═╡ 066374aa-eea1-43b3-9d08-c105addee0ab
md"""
String literals are delimited by double quotes or triple double quotes:
"""

# ╔═╡ 3c803af1-c0e2-4de5-994f-4b746f768707
str = "Hello, world.\n"

# ╔═╡ f982fe68-fc0e-4af6-aed2-d3f3e9794ee8
"""Contains "quote" characters"""
"Contains \"quote\" characters"

# ╔═╡ a76c691d-fbca-4e8d-81f3-573bf9e8df8c
md"""
If you want to extract a character from a string, you index into it:
"""

# ╔═╡ 995c2eaf-2aa7-4b53-ae26-363bd4e2d39d
str[begin]

# ╔═╡ d092c7b9-89ac-47fb-b1e4-eb2aa236161a
str[1]

# ╔═╡ 48f81a65-bd74-4f45-a145-a575785d2916
str[6]

# ╔═╡ d7a5aa31-25c1-4f90-97c6-1ad4330d49e5
str[end]

# ╔═╡ 0e78a609-8e0e-4222-97a2-31207cd42861
md"""
Many Julia objects, including strings, can be indexed with integers. The index of the first element (the first character of a string) is returned by [`firstindex(str)`](@ref), and the index of the last element (character) with [`lastindex(str)`](@ref). The keywords `begin` and `end` can be used inside an indexing operation as shorthand for the first and last indices, respectively, along the given dimension. String indexing, like most indexing in Julia, is 1-based: `firstindex` always returns `1` for any `AbstractString`. As we will see below, however, `lastindex(str)` is *not* in general the same as `length(str)` for a string, because some Unicode characters can occupy multiple \"code units\".
"""

# ╔═╡ 6b0578ed-3a36-4c96-b4dc-ae814b5e406f
md"""
You can perform arithmetic and other operations with [`end`](@ref), just like a normal value:
"""

# ╔═╡ 39af5a0f-a49b-4173-8b48-e9a21d872f9b
str[end-1]

# ╔═╡ bcfd892a-1aef-4d6f-a191-7cdec39de7c8
str[end÷2]

# ╔═╡ d728a6ce-2543-4ddc-9bfa-abbbe5c24398
md"""
Using an index less than `begin` (`1`) or greater than `end` raises an error:
"""

# ╔═╡ e5f06441-470a-4e3f-bb12-5b59601476eb
str[begin-1]

# ╔═╡ cae27199-317c-46a2-93f8-14b74dd7988d
str[end+1]

# ╔═╡ 04b25dea-4b79-49e6-9f98-060ff0c9d366
md"""
You can also extract a substring using range indexing:
"""

# ╔═╡ cc9bdaaf-a1a1-4acd-b184-c11b18a7202a
str[4:9]

# ╔═╡ c12dea6e-0945-4c24-8a29-0d5ca266fa4b
md"""
Notice that the expressions `str[k]` and `str[k:k]` do not give the same result:
"""

# ╔═╡ c79f7b66-ba81-4281-a1e0-ee2511917568
str[6]

# ╔═╡ 075352c4-d9c3-4f0d-a528-a96f7246b5e9
str[6:6]

# ╔═╡ c87fb4e7-349e-43da-84a9-4a6177570e24
md"""
The former is a single character value of type `Char`, while the latter is a string value that happens to contain only a single character. In Julia these are very different things.
"""

# ╔═╡ f3dabf82-6ad8-4a30-b7fe-9101a2292161
md"""
Range indexing makes a copy of the selected part of the original string. Alternatively, it is possible to create a view into a string using the type [`SubString`](@ref), for example:
"""

# ╔═╡ a65e7ea5-94f5-4820-a195-42f380e196a3
str = "long string"

# ╔═╡ d4c1327f-554d-49ab-828b-b6d2fcfe7412
substr = SubString(str, 1, 4)

# ╔═╡ 5db0ecfa-85c4-480c-aac0-1544e2fd5041
typeof(substr)

# ╔═╡ b05ee130-a8aa-4e99-9fe3-1a0a4d2cd3dc
md"""
Several standard functions like [`chop`](@ref), [`chomp`](@ref) or [`strip`](@ref) return a [`SubString`](@ref).
"""

# ╔═╡ 04dc8068-3dd2-48c0-a3ae-0cfd02f95486
md"""
## Unicode and UTF-8
"""

# ╔═╡ 203a650e-0bd7-458e-9840-da7e4bfdee36
md"""
Julia fully supports Unicode characters and strings. As [discussed above](@ref man-characters), in character literals, Unicode code points can be represented using Unicode `\u` and `\U` escape sequences, as well as all the standard C escape sequences. These can likewise be used to write string literals:
"""

# ╔═╡ 3f67d93f-74fd-4832-9b71-1dbc70034583
s = "\u2200 x \u2203 y"

# ╔═╡ aee9d593-228e-403c-8c26-9715d8f71ff1
md"""
Whether these Unicode characters are displayed as escapes or shown as special characters depends on your terminal's locale settings and its support for Unicode. String literals are encoded using the UTF-8 encoding. UTF-8 is a variable-width encoding, meaning that not all characters are encoded in the same number of bytes (\"code units\"). In UTF-8, ASCII characters — i.e. those with code points less than 0x80 (128) – are encoded as they are in ASCII, using a single byte, while code points 0x80 and above are encoded using multiple bytes — up to four per character.
"""

# ╔═╡ f889f166-544c-4840-a500-e84737b438cb
md"""
String indices in Julia refer to code units (= bytes for UTF-8), the fixed-width building blocks that are used to encode arbitrary characters (code points). This means that not every index into a `String` is necessarily a valid index for a character. If you index into a string at such an invalid byte index, an error is thrown:
"""

# ╔═╡ 3cae6e4f-08b0-45ab-9e7c-f1db14198c9e
s[1]

# ╔═╡ d0a44e0e-4840-4175-ad08-1912af3cc2a6
s[2]

# ╔═╡ e22ef343-dbe6-4dbc-9a82-1126a7319ca9
s[3]

# ╔═╡ 1dde162e-38d3-4890-9593-0ad87c43ebd4
s[4]

# ╔═╡ a9b5dc02-9e00-4ec1-b157-ae06d66fbd13
md"""
In this case, the character `∀` is a three-byte character, so the indices 2 and 3 are invalid and the next character's index is 4; this next valid index can be computed by [`nextind(s,1)`](@ref), and the next index after that by `nextind(s,4)` and so on.
"""

# ╔═╡ 8f3451ae-9aa7-4580-bfc5-a553e4bebbb9
md"""
Since `end` is always the last valid index into a collection, `end-1` references an invalid byte index if the second-to-last character is multibyte.
"""

# ╔═╡ c207e4cf-26e2-4933-8df0-51d54d959790
s[end-1]

# ╔═╡ 67643e9f-a9d2-4496-82dc-9df8c7ce120b
s[end-2]

# ╔═╡ 50bb68c6-f048-49b3-831e-01fe1815805a
s[prevind(s, end, 2)]

# ╔═╡ db7b708f-75cb-48d1-b509-2d0e090c0eb6
md"""
The first case works, because the last character `y` and the space are one-byte characters, whereas `end-2` indexes into the middle of the `∃` multibyte representation. The correct way for this case is using `prevind(s, lastindex(s), 2)` or, if you're using that value to index into `s` you can write `s[prevind(s, end, 2)]` and `end` expands to `lastindex(s)`.
"""

# ╔═╡ 3de43e3a-dca2-4964-8e47-64207d00510c
md"""
Extraction of a substring using range indexing also expects valid byte indices or an error is thrown:
"""

# ╔═╡ 0a674813-c4a2-4dd2-9f1a-69f0dcfbdd92
s[1:1]

# ╔═╡ 49113df0-85be-41cd-abc2-f95ca70b440f
s[1:2]

# ╔═╡ 751a287b-5fee-4c29-b9b5-1702d9da8071
s[1:4]

# ╔═╡ d6699545-4d50-429a-bfc2-87a053f35e6a
md"""
Because of variable-length encodings, the number of characters in a string (given by [`length(s)`](@ref)) is not always the same as the last index. If you iterate through the indices 1 through [`lastindex(s)`](@ref) and index into `s`, the sequence of characters returned when errors aren't thrown is the sequence of characters comprising the string `s`. Thus we have the identity that `length(s) <= lastindex(s)`, since each character in a string must have its own index. The following is an inefficient and verbose way to iterate through the characters of `s`:
"""

# ╔═╡ c22d752e-0a0e-4276-8950-56a4f9300dd6
for i = firstindex(s):lastindex(s)
     try
         println(s[i])
     catch
         # ignore the index error
     end
 end

# ╔═╡ 03f56f9d-5703-41c1-b76c-23690dde1ee3
md"""
The blank lines actually have spaces on them. Fortunately, the above awkward idiom is unnecessary for iterating through the characters in a string, since you can just use the string as an iterable object, no exception handling required:
"""

# ╔═╡ e1b483c5-971b-4471-a77e-716300f9a1b4
for c in s
     println(c)
 end

# ╔═╡ 4f1b8dba-92fa-44fa-8f5c-85e87e39585b
md"""
If you need to obtain valid indices for a string, you can use the [`nextind`](@ref) and [`prevind`](@ref) functions to increment/decrement to the next/previous valid index, as mentioned above. You can also use the [`eachindex`](@ref) function to iterate over the valid character indices:
"""

# ╔═╡ 536d9a21-3f75-4a9d-8113-a07313b0f648
collect(eachindex(s))

# ╔═╡ 2bc93ed8-8387-49ff-9c72-1528bf1dbd87
md"""
To access the raw code units (bytes for UTF-8) of the encoding, you can use the [`codeunit(s,i)`](@ref) function, where the index `i` runs consecutively from `1` to [`ncodeunits(s)`](@ref).  The [`codeunits(s)`](@ref) function returns an `AbstractVector{UInt8}` wrapper that lets you access these raw codeunits (bytes) as an array.
"""

# ╔═╡ 0e12dbb5-1ae9-4fb4-b56c-5d8a9a1626d8
md"""
Strings in Julia can contain invalid UTF-8 code unit sequences. This convention allows to treat any byte sequence as a `String`. In such situations a rule is that when parsing a sequence of code units from left to right characters are formed by the longest sequence of 8-bit code units that matches the start of one of the following bit patterns (each `x` can be `0` or `1`):
"""

# ╔═╡ c9722718-2dbb-4e81-acff-27630c4946b4
md"""
  * `0xxxxxxx`;
  * `110xxxxx` `10xxxxxx`;
  * `1110xxxx` `10xxxxxx` `10xxxxxx`;
  * `11110xxx` `10xxxxxx` `10xxxxxx` `10xxxxxx`;
  * `10xxxxxx`;
  * `11111xxx`.
"""

# ╔═╡ 7f61fa97-5d08-4e76-8d8c-9e3f19d11229
md"""
In particular this means that overlong and too-high code unit sequences and prefixes thereof are treated as a single invalid character rather than multiple invalid characters. This rule may be best explained with an example:
"""

# ╔═╡ fe143b8c-d827-45a9-b5dd-cd58738138f7
s = "\xc0\xa0\xe2\x88\xe2|"

# ╔═╡ 2df199e9-3345-4705-be27-f434ae9f62f4
foreach(display, s)

# ╔═╡ 68cc5425-0f8e-4987-b21e-d879cc244355
isvalid.(collect(s))

# ╔═╡ 0feff2a4-9955-4516-bfa8-6237389c71a7
s2 = "\xf7\xbf\xbf\xbf"

# ╔═╡ 8cea15c1-6a2e-4dd2-820d-0eac0e33b3f9
foreach(display, s2)

# ╔═╡ 8cf2b37c-ca8f-4b2b-b526-0eb02dd2a778
md"""
We can see that the first two code units in the string `s` form an overlong encoding of space character. It is invalid, but is accepted in a string as a single character. The next two code units form a valid start of a three-byte UTF-8 sequence. However, the fifth code unit `\xe2` is not its valid continuation. Therefore code units 3 and 4 are also interpreted as malformed characters in this string. Similarly code unit 5 forms a malformed character because `|` is not a valid continuation to it. Finally the string `s2` contains one too high code point.
"""

# ╔═╡ eb7c78b1-872c-49da-b18f-a087b007276b
md"""
Julia uses the UTF-8 encoding by default, and support for new encodings can be added by packages. For example, the [LegacyStrings.jl](https://github.com/JuliaStrings/LegacyStrings.jl) package implements `UTF16String` and `UTF32String` types. Additional discussion of other encodings and how to implement support for them is beyond the scope of this document for the time being. For further discussion of UTF-8 encoding issues, see the section below on [byte array literals](@ref man-byte-array-literals). The [`transcode`](@ref) function is provided to convert data between the various UTF-xx encodings, primarily for working with external data and libraries.
"""

# ╔═╡ bfa991d7-4517-4fcb-ac41-845d271f6a78
md"""
## [Concatenation](@id man-concatenation)
"""

# ╔═╡ 1c44dc8e-6bcb-44d9-9119-61051c23130e
md"""
One of the most common and useful string operations is concatenation:
"""

# ╔═╡ a296b103-67cd-46b7-9d7b-75d6f910bb3a
greet = "Hello"

# ╔═╡ d5fbcbcf-beb1-469c-a795-e990fa532f8b
whom = "world"

# ╔═╡ 82db73b2-a39f-437c-8986-6e9a218dfad3
string(greet, ", ", whom, ".\n")

# ╔═╡ e51e267e-8c94-4dd1-a55d-94f822156198
md"""
It's important to be aware of potentially dangerous situations such as concatenation of invalid UTF-8 strings. The resulting string may contain different characters than the input strings, and its number of characters may be lower than sum of numbers of characters of the concatenated strings, e.g.:
"""

# ╔═╡ b849c505-dac1-4fc7-9a83-2b2e35f6a4a6
a, b = "\xe2\x88", "\x80"

# ╔═╡ 19db9749-fbdb-404e-b5c4-2afc487291c4
c = a*b

# ╔═╡ 9014968b-c5eb-42a4-a0b0-c8d071dc618e
collect.([a, b, c])

# ╔═╡ 45ee1d1d-8164-44f5-883e-8b089824e09a
length.([a, b, c])

# ╔═╡ 4723c7f2-1e61-4244-8c7b-6a3509f66499
md"""
This situation can happen only for invalid UTF-8 strings. For valid UTF-8 strings concatenation preserves all characters in strings and additivity of string lengths.
"""

# ╔═╡ 80423090-b4bc-42ce-ba7f-49250f787aac
md"""
Julia also provides [`*`](@ref) for string concatenation:
"""

# ╔═╡ 102fae18-d839-43f4-8f65-46969ba2e1af
greet * ", " * whom * ".\n"

# ╔═╡ f5637fb9-71ab-405c-88b7-818bb1c432ce
md"""
While `*` may seem like a surprising choice to users of languages that provide `+` for string concatenation, this use of `*` has precedent in mathematics, particularly in abstract algebra.
"""

# ╔═╡ df4df84b-775f-4cb2-aba8-f4037c9f1716
md"""
In mathematics, `+` usually denotes a *commutative* operation, where the order of the operands does not matter. An example of this is matrix addition, where `A + B == B + A` for any matrices `A` and `B` that have the same shape. In contrast, `*` typically denotes a *noncommutative* operation, where the order of the operands *does* matter. An example of this is matrix multiplication, where in general `A * B != B * A`. As with matrix multiplication, string concatenation is noncommutative: `greet * whom != whom * greet`. As such, `*` is a more natural choice for an infix string concatenation operator, consistent with common mathematical use.
"""

# ╔═╡ cd2cd835-d364-4fe5-b8c9-2a841acb3531
md"""
More precisely, the set of all finite-length strings *S* together with the string concatenation operator `*` forms a [free monoid](https://en.wikipedia.org/wiki/Free_monoid) (*S*, `*`). The identity element of this set is the empty string, `\"\"`. Whenever a free monoid is not commutative, the operation is typically represented as `\cdot`, `*`, or a similar symbol, rather than `+`, which as stated usually implies commutativity.
"""

# ╔═╡ e4fc5921-a690-48c2-a1cb-370fa56afff8
md"""
## [Interpolation](@id string-interpolation)
"""

# ╔═╡ f9614c4c-f163-491d-b54e-c5ef862ca8fc
md"""
Constructing strings using concatenation can become a bit cumbersome, however. To reduce the need for these verbose calls to [`string`](@ref) or repeated multiplications, Julia allows interpolation into string literals using `$`, as in Perl:
"""

# ╔═╡ c27218e2-08b7-45bd-9f2c-dc0e3e79d071
"$greet, $whom.\n"
"Hello, world.\n"

# ╔═╡ 2b36f026-39d7-442e-b9bc-0f1a98fa4fe5
md"""
This is more readable and convenient and equivalent to the above string concatenation – the system rewrites this apparent single string literal into the call `string(greet, \", \", whom, \".\n\")`.
"""

# ╔═╡ 62c06a08-78c6-42df-8be1-fbea389a9ea3
md"""
The shortest complete expression after the `$` is taken as the expression whose value is to be interpolated into the string. Thus, you can interpolate any expression into a string using parentheses:
"""

# ╔═╡ 986eb3b4-ba98-4dcc-83bc-6bb9f98c84d1
"1 + 2 = $(1 + 2)"
"1 + 2 = 3"

# ╔═╡ fed2a353-b49b-4ca8-974e-30fd02c308de
md"""
Both concatenation and string interpolation call [`string`](@ref) to convert objects into string form. However, `string` actually just returns the output of [`print`](@ref), so new types should add methods to [`print`](@ref) or [`show`](@ref) instead of `string`.
"""

# ╔═╡ 265b6825-cb44-4b6e-8f1b-e7449fd5b3b1
md"""
Most non-`AbstractString` objects are converted to strings closely corresponding to how they are entered as literal expressions:
"""

# ╔═╡ 6abf2b45-40b1-4669-a3e1-af14c11f87eb
v = [1,2,3]

# ╔═╡ 3d93498d-5fb1-4320-8e60-c0783e22f9e1
"v: $v"
"v: [1, 2, 3]"

# ╔═╡ 4d480492-099b-4683-bd43-4af81bed422e
md"""
[`string`](@ref) is the identity for `AbstractString` and `AbstractChar` values, so these are interpolated into strings as themselves, unquoted and unescaped:
"""

# ╔═╡ 973f77ff-acb8-425e-bcef-811f62acaa8d
c = 'x'

# ╔═╡ c62671dc-672e-4b5b-84f2-168f004890f0
"hi, $c"
"hi, x"

# ╔═╡ 699a7f53-efd9-4954-8fa0-92bc46981831
md"""
To include a literal `$` in a string literal, escape it with a backslash:
"""

# ╔═╡ 8439d3a9-c305-461e-8da4-b310c4ff4a3c
print("I have \$100 in my account.\n")

# ╔═╡ 8d8a2b3e-f3f2-4e44-b48b-09abf64f18c0
md"""
## Triple-Quoted String Literals
"""

# ╔═╡ 993d6264-28ef-45a8-8a17-d2a155d1359f
md"""
When strings are created using triple-quotes (`\"\"\"...\"\"\"`) they have some special behavior that can be useful for creating longer blocks of text.
"""

# ╔═╡ c466adf3-2b20-4582-b56c-9af378188a0b
md"""
First, triple-quoted strings are also dedented to the level of the least-indented line. This is useful for defining strings within code that is indented. For example:
"""

# ╔═╡ 9236636c-3026-4f29-81ef-2150fad43be4
str = """
     Hello,
     world.
   """

# ╔═╡ f0a54462-8018-452b-9b24-82008fe5b185
md"""
In this case the final (empty) line before the closing `\"\"\"` sets the indentation level.
"""

# ╔═╡ 1e211621-be0c-47fc-935c-8055c724afeb
md"""
The dedentation level is determined as the longest common starting sequence of spaces or tabs in all lines, excluding the line following the opening `\"\"\"` and lines containing only spaces or tabs (the line containing the closing `\"\"\"` is always included). Then for all lines, excluding the text following the opening `\"\"\"`, the common starting sequence is removed (including lines containing only spaces and tabs if they start with this sequence), e.g.:
"""

# ╔═╡ 6b2cb86a-dedd-43f8-b83a-f6b8e9a97aff
"""    This
   is
     a test"""
"    This\nis\n  a test"

# ╔═╡ fd0a6f2e-65af-47ea-86c5-13a178395378
md"""
Next, if the opening `\"\"\"` is followed by a newline, the newline is stripped from the resulting string.
"""

# ╔═╡ 0b110470-dabf-4587-b598-be2deec7e9d2
md"""
```julia
\"\"\"hello\"\"\"
```
"""

# ╔═╡ 59ee5d43-04e6-49dd-821b-4899e1e189f5
md"""
is equivalent to
"""

# ╔═╡ 2692d516-6662-44c3-946d-b1fad3f06aa8
md"""
```julia
\"\"\"
hello\"\"\"
```
"""

# ╔═╡ 1fd6fc91-9783-4046-96f1-b87cea21418d
md"""
but
"""

# ╔═╡ 98da0c22-616b-4756-b5f3-a974a9dbac39
md"""
```julia
\"\"\"

hello\"\"\"
```
"""

# ╔═╡ ffb24ed8-aff7-4b23-9c69-ee336c56a2a7
md"""
will contain a literal newline at the beginning.
"""

# ╔═╡ 2cbadd4e-ab46-4aa2-ae5b-2a1d0d87d3bf
md"""
Stripping of the newline is performed after the dedentation. For example:
"""

# ╔═╡ 05c597a5-371b-45a1-8353-d0615f4cb07b
"""
   Hello,
   world."""
"Hello,\nworld."

# ╔═╡ 94084775-6fd0-4ff2-a08e-34e08e9d4669
md"""
Trailing whitespace is left unaltered.
"""

# ╔═╡ dd55122c-643b-4359-ab86-8f26784b12b9
md"""
Triple-quoted string literals can contain `\"` characters without escaping.
"""

# ╔═╡ 1e2cf694-625d-42b6-adaa-9224d1aeadde
md"""
Note that line breaks in literal strings, whether single- or triple-quoted, result in a newline (LF) character `\n` in the string, even if your editor uses a carriage return `\r` (CR) or CRLF combination to end lines. To include a CR in a string, use an explicit escape `\r`; for example, you can enter the literal string `\"a CRLF line ending\r\n\"`.
"""

# ╔═╡ 9d204a01-4e7f-4324-a515-61884dc81eea
md"""
## Common Operations
"""

# ╔═╡ b5364ad7-5f2f-44ef-8c56-b02fb389752a
md"""
You can lexicographically compare strings using the standard comparison operators:
"""

# ╔═╡ 0ee50c89-7ee6-43a4-80c8-fdd077012c9f
"abracadabra" < "xylophone"

# ╔═╡ d0b5d113-cff1-4ac0-8a1e-68fafdd6eac8
"abracadabra" == "xylophone"

# ╔═╡ 38ee3793-777c-4c2e-af46-71f11de0ee9e
"Hello, world." != "Goodbye, world."

# ╔═╡ 8191d687-85e2-4d63-8c80-f2bd81023762
"1 + 2 = 3" == "1 + 2 = $(1 + 2)"

# ╔═╡ 4b6385ff-f365-4b15-8b60-fbdac61aa808
md"""
You can search for the index of a particular character using the [`findfirst`](@ref) and [`findlast`](@ref) functions:
"""

# ╔═╡ f24c9343-e6ea-47ab-a519-31438cef5a16
findfirst(isequal('o'), "xylophone")

# ╔═╡ 981f3d39-68eb-4456-aece-52bb11112992
findlast(isequal('o'), "xylophone")

# ╔═╡ 53336ee7-0b9a-472d-9263-9c074e4c2831
findfirst(isequal('z'), "xylophone")

# ╔═╡ 1309ffb1-c117-4217-bab7-776072dbda75
md"""
You can start the search for a character at a given offset by using the functions [`findnext`](@ref) and [`findprev`](@ref):
"""

# ╔═╡ 9276cfe0-af59-4708-934d-b623ffb58892
findnext(isequal('o'), "xylophone", 1)

# ╔═╡ c6ed4972-6664-45cc-a095-2177b49ecc9b
findnext(isequal('o'), "xylophone", 5)

# ╔═╡ 4131a7c6-6fbc-41ce-9611-49d3d5b11bd4
findprev(isequal('o'), "xylophone", 5)

# ╔═╡ a26b6462-2969-4381-8f87-f584e54d0ce8
findnext(isequal('o'), "xylophone", 8)

# ╔═╡ bcabd5a9-42d4-4ba9-823c-9133aa76fe67
md"""
You can use the [`occursin`](@ref) function to check if a substring is found within a string:
"""

# ╔═╡ b478df28-3db8-492b-a968-4571e6136713
occursin("world", "Hello, world.")

# ╔═╡ 93916765-65db-4d74-8eec-104bad3e8d6f
occursin("o", "Xylophon")

# ╔═╡ 5fa38de7-0c70-4852-b683-b30ad84df122
occursin("a", "Xylophon")

# ╔═╡ 950129a8-6c4b-402c-a343-aa43fe60fa95
occursin('o', "Xylophon")

# ╔═╡ 7aab32bc-9a07-4aac-b025-55191d545895
md"""
The last example shows that [`occursin`](@ref) can also look for a character literal.
"""

# ╔═╡ 11d933da-f0a1-4831-9a15-9f3578f91bdf
md"""
Two other handy string functions are [`repeat`](@ref) and [`join`](@ref):
"""

# ╔═╡ 96a7693c-c871-435c-9d62-59405f74d6e8
repeat(".:Z:.", 10)

# ╔═╡ 39576c56-510d-4afe-937e-3686059d890e
join(["apples", "bananas", "pineapples"], ", ", " and ")

# ╔═╡ 6e08a0ad-15fb-492d-b4c9-5333e9d4039b
md"""
Some other useful functions include:
"""

# ╔═╡ e5c2a57a-15eb-4db3-b2b5-061d2f040e2e
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

# ╔═╡ 61adf36e-eed8-4f2d-a7a4-67e8533498d7
md"""
## [Non-Standard String Literals](@id non-standard-string-literals)
"""

# ╔═╡ d7e487fa-dd32-4350-a10e-d2cb5b401cce
md"""
There are situations when you want to construct a string or use string semantics, but the behavior of the standard string construct is not quite what is needed. For these kinds of situations, Julia provides [non-standard string literals](@ref). A non-standard string literal looks like a regular double-quoted string literal, but is immediately prefixed by an identifier, and doesn't behave quite like a normal string literal.  Regular expressions, byte array literals and version number literals, as described below, are some examples of non-standard string literals. Other examples are given in the [Metaprogramming](@ref) section.
"""

# ╔═╡ ac025198-aacf-45e7-9c12-18f73fa4fe5a
md"""
## Regular Expressions
"""

# ╔═╡ f1177760-6e52-40a3-8d67-13594b016c7a
md"""
Julia has Perl-compatible regular expressions (regexes), as provided by the [PCRE](http://www.pcre.org/) library (a description of the syntax can be found [here](http://www.pcre.org/current/doc/html/pcre2syntax.html)). Regular expressions are related to strings in two ways: the obvious connection is that regular expressions are used to find regular patterns in strings; the other connection is that regular expressions are themselves input as strings, which are parsed into a state machine that can be used to efficiently search for patterns in strings. In Julia, regular expressions are input using non-standard string literals prefixed with various identifiers beginning with `r`. The most basic regular expression literal without any options turned on just uses `r\"...\"`:
"""

# ╔═╡ 664c4793-ea2a-4fb8-87a3-65afa600e89b
re = r"^\s*(?:#|$)"

# ╔═╡ 4c407f2d-3875-4735-b39d-9c65756cbf7d
typeof(re)

# ╔═╡ 066a9db8-e05e-4b6d-9190-3032261a84b0
md"""
To check if a regex matches a string, use [`occursin`](@ref):
"""

# ╔═╡ 2c129ab0-c8ee-457e-af13-5934313f7c7b
occursin(r"^\s*(?:#|$)", "not a comment")

# ╔═╡ 8122ea03-9288-4a63-8c1f-6259718d4e9b
occursin(r"^\s*(?:#|$)", "# a comment")

# ╔═╡ 6e0e6180-619a-4fff-a434-3472de19d1f0
md"""
As one can see here, [`occursin`](@ref) simply returns true or false, indicating whether a match for the given regex occurs in the string. Commonly, however, one wants to know not just whether a string matched, but also *how* it matched. To capture this information about a match, use the [`match`](@ref) function instead:
"""

# ╔═╡ faaa6bc0-5fe0-4615-a630-fec9a65b9474
match(r"^\s*(?:#|$)", "not a comment")

# ╔═╡ 9f943cae-cbd6-4fc2-b1df-4b950e292518
match(r"^\s*(?:#|$)", "# a comment")

# ╔═╡ 53854580-96ed-4271-911f-ba6d5ddbf20c
md"""
If the regular expression does not match the given string, [`match`](@ref) returns [`nothing`](@ref) – a special value that does not print anything at the interactive prompt. Other than not printing, it is a completely normal value and you can test for it programmatically:
"""

# ╔═╡ 83a1e6b3-1200-4fd9-a124-a530eb2013f6
md"""
```julia
m = match(r\"^\s*(?:#|$)\", line)
if m === nothing
    println(\"not a comment\")
else
    println(\"blank or comment\")
end
```
"""

# ╔═╡ 1d802a5a-cff4-46a9-874b-e8f0ca66d174
md"""
If a regular expression does match, the value returned by [`match`](@ref) is a `RegexMatch` object. These objects record how the expression matches, including the substring that the pattern matches and any captured substrings, if there are any. This example only captures the portion of the substring that matches, but perhaps we want to capture any non-blank text after the comment character. We could do the following:
"""

# ╔═╡ 73351012-af40-4897-b349-23a77ed02111
m = match(r"^\s*(?:#\s*(.*?)\s*$|$)", "# a comment ")

# ╔═╡ 51709e56-7b74-44c8-84a9-67ccc01c6eb9
md"""
When calling [`match`](@ref), you have the option to specify an index at which to start the search. For example:
"""

# ╔═╡ 70fbe10a-a2a6-4db4-a4cc-e91bf763511f
m = match(r"[0-9]","aaaa1aaaa2aaaa3",1)

# ╔═╡ 8337a0ec-263a-425d-84f9-10e7da9b9517
m = match(r"[0-9]","aaaa1aaaa2aaaa3",6)

# ╔═╡ d3cc5b03-6946-4ba6-94fc-9908b8755b3e
m = match(r"[0-9]","aaaa1aaaa2aaaa3",11)

# ╔═╡ 5ed8e3c7-776e-4466-831c-7c308a622010
md"""
You can extract the following info from a `RegexMatch` object:
"""

# ╔═╡ f1adbec1-4892-464c-9f41-d1cbfc48051c
md"""
  * the entire substring matched: `m.match`
  * the captured substrings as an array of strings: `m.captures`
  * the offset at which the whole match begins: `m.offset`
  * the offsets of the captured substrings as a vector: `m.offsets`
"""

# ╔═╡ 30da86b6-a2c7-4b69-8223-a05ae9ce49d5
md"""
For when a capture doesn't match, instead of a substring, `m.captures` contains `nothing` in that position, and `m.offsets` has a zero offset (recall that indices in Julia are 1-based, so a zero offset into a string is invalid). Here is a pair of somewhat contrived examples:
"""

# ╔═╡ 1ebb4d6b-2a38-44cc-bb93-1d4bb4297c0c
m = match(r"(a|b)(c)?(d)", "acd")

# ╔═╡ 1616ca8f-d7d5-403d-9cae-8adc50d76160
m.match

# ╔═╡ d8b8d3df-a8b8-4957-bc33-4c6719f2f95a
m.captures

# ╔═╡ a99f2a22-f0e4-46b9-a68c-6097caee319f
m.offset

# ╔═╡ cfe0b9f9-d99f-4c73-b66d-d17b09b2d7ff
m.offsets

# ╔═╡ 012b81ee-ff1d-489c-8621-39b67c526f46
m = match(r"(a|b)(c)?(d)", "ad")

# ╔═╡ f8d1faf7-333a-4adf-82b7-86463771877f
m.match

# ╔═╡ 1d8cf2aa-9ccc-4392-baf4-8df620db1a82
m.captures

# ╔═╡ 0ee76a24-3ecd-4a1d-9795-b2fd166a9270
m.offset

# ╔═╡ 12896a3b-9c2b-4f87-9ebc-6a659a9d27a7
m.offsets

# ╔═╡ 42194c03-f398-4a97-835d-99636005b7d0
md"""
It is convenient to have captures returned as an array so that one can use destructuring syntax to bind them to local variables:
"""

# ╔═╡ da3e0acc-3105-4274-b64b-1dc80732c623
first, second, third = m.captures; first

# ╔═╡ e5e97702-48e2-4bf3-ad75-07a38a22df08
md"""
Captures can also be accessed by indexing the `RegexMatch` object with the number or name of the capture group:
"""

# ╔═╡ d08789c7-ffa7-4feb-a55d-dceb60549ff5
m=match(r"(?<hour>\d+):(?<minute>\d+)","12:45")

# ╔═╡ 922518da-8025-4be1-964e-09fdd11932c1
m[:minute]

# ╔═╡ 4b70822b-d5bd-4973-b079-d089f3cd09c5
m[2]

# ╔═╡ 6d88373a-77c6-4ca4-8ec0-e0c410accbd0
md"""
Captures can be referenced in a substitution string when using [`replace`](@ref) by using `\n` to refer to the nth capture group and prefixing the substitution string with `s`. Capture group 0 refers to the entire match object. Named capture groups can be referenced in the substitution with `\g<groupname>`. For example:
"""

# ╔═╡ b4fab237-0f89-4bfa-a064-644df389e95a
replace("first second", r"(\w+) (?<agroup>\w+)" => s"\g<agroup> \1")

# ╔═╡ 0f1ab0b5-fed2-4b7d-af26-563b1479cb2d
md"""
Numbered capture groups can also be referenced as `\g<n>` for disambiguation, as in:
"""

# ╔═╡ 36139330-7a0c-40ad-af7a-1739cc89fc22
replace("a", r"." => s"\g<0>1")

# ╔═╡ 99a3c453-cade-4cc0-ab29-dcb46f426029
md"""
You can modify the behavior of regular expressions by some combination of the flags `i`, `m`, `s`, and `x` after the closing double quote mark. These flags have the same meaning as they do in Perl, as explained in this excerpt from the [perlre manpage](http://perldoc.perl.org/perlre.html#Modifiers):
"""

# ╔═╡ 258e0f2b-8057-4525-9927-4f51c0a7a9fb
md"""
```
i   Do case-insensitive pattern matching.

    If locale matching rules are in effect, the case map is taken
    from the current locale for code points less than 255, and
    from Unicode rules for larger code points. However, matches
    that would cross the Unicode rules/non-Unicode rules boundary
    (ords 255/256) will not succeed.

m   Treat string as multiple lines.  That is, change \"^\" and \"$\"
    from matching the start or end of the string to matching the
    start or end of any line anywhere within the string.

s   Treat string as single line.  That is, change \".\" to match any
    character whatsoever, even a newline, which normally it would
    not match.

    Used together, as r\"\"ms, they let the \".\" match any character
    whatsoever, while still allowing \"^\" and \"$\" to match,
    respectively, just after and just before newlines within the
    string.

x   Tells the regular expression parser to ignore most whitespace
    that is neither backslashed nor within a character class. You
    can use this to break up your regular expression into
    (slightly) more readable parts. The '#' character is also
    treated as a metacharacter introducing a comment, just as in
    ordinary code.
```
"""

# ╔═╡ c56257d1-6810-40b1-81d4-4097d85121e3
md"""
For example, the following regex has all three flags turned on:
"""

# ╔═╡ 4ae116ea-77cb-4840-8173-387f83ae2d44
r"a+.*b+.*?d$"ism

# ╔═╡ d6d7f601-0984-486b-bb4c-178bd2204acd
match(r"a+.*b+.*?d$"ism, "Goodbye,\nOh, angry,\nBad world\n")

# ╔═╡ a603116b-3dac-4f19-9e31-388a43988cd4
md"""
The `r\"...\"` literal is constructed without interpolation and unescaping (except for quotation mark `\"` which still has to be escaped). Here is an example showing the difference from standard string literals:
"""

# ╔═╡ b6917f1c-583b-4201-8b7b-3ee6b1df9409
x = 10

# ╔═╡ 27cb0571-63a6-44af-871a-85ab773f39b1
r"$x"

# ╔═╡ a4c92c04-aa50-43bc-bc74-19ae593a67b7
"$x"
"10"

# ╔═╡ bffc1225-7217-4a75-8016-b37a45b0282f
r"\x"

# ╔═╡ 0fef06a9-cd7f-4154-8d61-6e0cbf78e51f
"\x"

# ╔═╡ 32ef8124-c57f-4d43-9657-dca4be977f51
md"""
Triple-quoted regex strings, of the form `r\"\"\"...\"\"\"`, are also supported (and may be convenient for regular expressions containing quotation marks or newlines).
"""

# ╔═╡ a82a82e3-469b-42bf-be87-7ad65e0e867c
md"""
The `Regex()` constructor may be used to create a valid regex string programmatically.  This permits using the contents of string variables and other string operations when constructing the regex string. Any of the regex codes above can be used within the single string argument to `Regex()`. Here are some examples:
"""

# ╔═╡ 6a066ab2-51f4-4ca1-ac33-c1ca336f34ce
using Dates

# ╔═╡ c9a88ff3-619e-49dc-80c0-c3e64427e421
d = Date(1962,7,10)

# ╔═╡ b04092c6-4aa7-4181-b6c0-1e139d1f3a6a
regex_d = Regex("Day " * string(day(d)))

# ╔═╡ b779a092-bd6c-400c-a619-6dfee3d50a63
match(regex_d, "It happened on Day 10")

# ╔═╡ 925ebac6-3be3-437c-b056-5ca42db37e18
name = "Jon"

# ╔═╡ 7f4fd632-828b-4303-9672-60174f1ce6e3
regex_name = Regex("[\"( ]$name[\") ]")  # interpolate value of name

# ╔═╡ 22508adf-87a2-4c87-a1c2-dfea6b07bba7
match(regex_name," Jon ")

# ╔═╡ 19e4fc40-eb0e-46d6-bc00-d4f60a34c709
match(regex_name,"[Jon]") === nothing

# ╔═╡ f0de63c0-fdba-4add-bf4f-911281f0190c
md"""
## [Byte Array Literals](@id man-byte-array-literals)
"""

# ╔═╡ c942891c-7aa4-4f99-95a2-ec5d25146694
md"""
Another useful non-standard string literal is the byte-array string literal: `b\"...\"`. This form lets you use string notation to express read only literal byte arrays – i.e. arrays of [`UInt8`](@ref) values. The type of those objects is `CodeUnits{UInt8, String}`. The rules for byte array literals are the following:
"""

# ╔═╡ cab1c519-9e2d-478f-9465-e95046a248cd
md"""
  * ASCII characters and ASCII escapes produce a single byte.
  * `\x` and octal escape sequences produce the *byte* corresponding to the escape value.
  * Unicode escape sequences produce a sequence of bytes encoding that code point in UTF-8.
"""

# ╔═╡ 78d0ef8d-beb2-4b0f-9afc-be0e7f2c71d0
md"""
There is some overlap between these rules since the behavior of `\x` and octal escapes less than 0x80 (128) are covered by both of the first two rules, but here these rules agree. Together, these rules allow one to easily use ASCII characters, arbitrary byte values, and UTF-8 sequences to produce arrays of bytes. Here is an example using all three:
"""

# ╔═╡ ea0bab70-bd3e-4e77-9e59-a02fdd3c67dd
b"DATA\xff\u2200"

# ╔═╡ b06c9107-17e5-49ce-909e-38b92a72b7b8
md"""
The ASCII string \"DATA\" corresponds to the bytes 68, 65, 84, 65. `\xff` produces the single byte 255. The Unicode escape `\u2200` is encoded in UTF-8 as the three bytes 226, 136, 128. Note that the resulting byte array does not correspond to a valid UTF-8 string:
"""

# ╔═╡ d172fac7-4929-47e3-9fe7-eaa9837c3684
isvalid("DATA\xff\u2200")

# ╔═╡ f052fd53-7f82-4e99-8c8f-0f276d7e60e4
md"""
As it was mentioned `CodeUnits{UInt8, String}` type behaves like read only array of `UInt8` and if you need a standard vector you can convert it using `Vector{UInt8}`:
"""

# ╔═╡ 56cf46bc-0fc4-403d-ac51-0dc1e0b6c95c
x = b"123"

# ╔═╡ 02744d6d-4879-4843-8cb4-4802f8034afc
x[1]

# ╔═╡ 40fd2e8a-9862-4084-b9b1-0de282cc1a5c
x[1] = 0x32

# ╔═╡ cecfccd7-4ba7-4b46-8caa-471a11c2394d
Vector{UInt8}(x)

# ╔═╡ 8964b9b4-83d3-4638-a3fa-638f6dba6884
md"""
Also observe the significant distinction between `\xff` and `\uff`: the former escape sequence encodes the *byte 255*, whereas the latter escape sequence represents the *code point 255*, which is encoded as two bytes in UTF-8:
"""

# ╔═╡ 91f65752-66ee-4f50-9e25-47fc2a4578b9
b"\xff"

# ╔═╡ 5e5c71cd-914b-4e8c-b32e-e16dab5b6da9
b"\uff"

# ╔═╡ d9973cf0-0715-4c6e-8daa-fc9b8bf60ce1
md"""
Character literals use the same behavior.
"""

# ╔═╡ fe18da98-98ff-42e3-9e3f-3912a0224afb
md"""
For code points less than `\u80`, it happens that the UTF-8 encoding of each code point is just the single byte produced by the corresponding `\x` escape, so the distinction can safely be ignored. For the escapes `\x80` through `\xff` as compared to `\u80` through `\uff`, however, there is a major difference: the former escapes all encode single bytes, which – unless followed by very specific continuation bytes – do not form valid UTF-8 data, whereas the latter escapes all represent Unicode code points with two-byte encodings.
"""

# ╔═╡ fa3c1a78-0ae8-4395-abb3-3b8d29232203
md"""
If this is all extremely confusing, try reading [\"The Absolute Minimum Every Software Developer Absolutely, Positively Must Know About Unicode and Character Sets\"](https://www.joelonsoftware.com/2003/10/08/the-absolute-minimum-every-software-developer-absolutely-positively-must-know-about-unicode-and-character-sets-no-excuses/). It's an excellent introduction to Unicode and UTF-8, and may help alleviate some confusion regarding the matter.
"""

# ╔═╡ d04e9c82-5d82-4844-bb6c-ba9b30d9a3eb
md"""
## [Version Number Literals](@id man-version-number-literals)
"""

# ╔═╡ ef3e0100-da11-4e82-af56-9137891d586a
md"""
Version numbers can easily be expressed with non-standard string literals of the form [`v\"...\"`](@ref @v_str). Version number literals create [`VersionNumber`](@ref) objects which follow the specifications of [semantic versioning](https://semver.org/), and therefore are composed of major, minor and patch numeric values, followed by pre-release and build alpha-numeric annotations. For example, `v\"0.2.1-rc1+win64\"` is broken into major version `0`, minor version `2`, patch version `1`, pre-release `rc1` and build `win64`. When entering a version literal, everything except the major version number is optional, therefore e.g.  `v\"0.2\"` is equivalent to `v\"0.2.0\"` (with empty pre-release/build annotations), `v\"2\"` is equivalent to `v\"2.0.0\"`, and so on.
"""

# ╔═╡ 1d43c742-adef-416f-b7c3-8827a520999e
md"""
`VersionNumber` objects are mostly useful to easily and correctly compare two (or more) versions. For example, the constant [`VERSION`](@ref) holds Julia version number as a `VersionNumber` object, and therefore one can define some version-specific behavior using simple statements as:
"""

# ╔═╡ 425bdb88-ade6-422b-8a83-55e939719b67
md"""
```julia
if v\"0.2\" <= VERSION < v\"0.3-\"
    # do something specific to 0.2 release series
end
```
"""

# ╔═╡ 69077728-f821-438f-ad91-e923eee63401
md"""
Note that in the above example the non-standard version number `v\"0.3-\"` is used, with a trailing `-`: this notation is a Julia extension of the standard, and it's used to indicate a version which is lower than any `0.3` release, including all of its pre-releases. So in the above example the code would only run with stable `0.2` versions, and exclude such versions as `v\"0.3.0-rc1\"`. In order to also allow for unstable (i.e. pre-release) `0.2` versions, the lower bound check should be modified like this: `v\"0.2-\" <= VERSION`.
"""

# ╔═╡ 0090bfe2-b387-4eb4-a062-4116f9cc0e94
md"""
Another non-standard version specification extension allows one to use a trailing `+` to express an upper limit on build versions, e.g.  `VERSION > v\"0.2-rc1+\"` can be used to mean any version above `0.2-rc1` and any of its builds: it will return `false` for version `v\"0.2-rc1+win64\"` and `true` for `v\"0.2-rc2\"`.
"""

# ╔═╡ 5e125e12-a144-4ff3-911e-c2ef9a14cac1
md"""
It is good practice to use such special versions in comparisons (particularly, the trailing `-` should always be used on upper bounds unless there's a good reason not to), but they must not be used as the actual version number of anything, as they are invalid in the semantic versioning scheme.
"""

# ╔═╡ 298a4267-7bb5-49f2-b3ca-acea9f730df6
md"""
Besides being used for the [`VERSION`](@ref) constant, `VersionNumber` objects are widely used in the `Pkg` module, to specify packages versions and their dependencies.
"""

# ╔═╡ 1c70ff5e-a581-4125-9e32-81769e8fdef2
md"""
## [Raw String Literals](@id man-raw-string-literals)
"""

# ╔═╡ c16b0dfe-acfd-4ec0-8715-2eb153233f04
md"""
Raw strings without interpolation or unescaping can be expressed with non-standard string literals of the form `raw\"...\"`. Raw string literals create ordinary `String` objects which contain the enclosed contents exactly as entered with no interpolation or unescaping. This is useful for strings which contain code or markup in other languages which use `$` or `\` as special characters.
"""

# ╔═╡ 35b565e8-1700-4a23-8e46-4c86a8bd80ab
md"""
The exception is that quotation marks still must be escaped, e.g. `raw\"\\"\"` is equivalent to `\"\\"\"`. To make it possible to express all strings, backslashes then also must be escaped, but only when appearing right before a quote character:
"""

# ╔═╡ ec54832e-4dcb-4594-8d0d-35a0b8a1b2d8
println(raw"\\ \\\"")

# ╔═╡ 06d8409c-f5f1-4323-9b46-c12cc40e2f09
md"""
Notice that the first two backslashes appear verbatim in the output, since they do not precede a quote character. However, the next backslash character escapes the backslash that follows it, and the last backslash escapes a quote, since these backslashes appear before a quote.
"""

# ╔═╡ Cell order:
# ╟─b15e8b6b-0721-4193-a6c5-850e583643db
# ╟─95d5e94e-5e20-4202-a37d-060e2a1f1876
# ╟─09ec0d44-9eb4-410a-b8f4-a488c20e658f
# ╟─0ba1899c-d085-4142-8a4b-5decc8b9bc31
# ╟─95d7b4c2-5068-46a6-848b-be6ab9d20403
# ╟─47ad0bb5-dd79-4e16-a1d6-2a80478d95f6
# ╠═3c2f79ec-11fa-4515-9ab2-fee088de8cf3
# ╠═327af07c-2297-4511-80e6-81373e3527a8
# ╟─87e057f3-96a5-4d0f-a277-abda284c12aa
# ╠═e548909a-735e-450d-84d0-a75d4ce85118
# ╠═5f0f96fd-93d9-4dbb-8f09-dd4893b3c2ef
# ╟─1d3463b1-9274-458d-85ee-335f379a0645
# ╠═3993ef35-d0ae-4c98-9195-debe80e103ea
# ╟─273d7f25-c617-49c4-acdb-5c94fe393c32
# ╠═b4f78f7c-1339-4428-9755-f6eda54d0bc5
# ╠═d208c982-3659-4a7f-9e76-4c65f1a7fb7e
# ╟─f66d6364-6369-46c1-8dae-9e15c4c2376a
# ╟─ec848bda-5d48-4515-8476-433fa3aee8d5
# ╠═fe4d78ec-7d34-448b-8c97-2fb508d23eba
# ╠═518e2a00-c0f0-4ca1-a798-022fbc9f73ef
# ╠═2e9442c2-8421-485d-9223-1d3e74462bef
# ╠═6d45d921-ed00-45f1-8779-d0af175ce705
# ╟─56c65342-462b-4bfa-beb2-e4a5b713f4cf
# ╠═8617acc0-c78d-481e-a51e-94aeaaeeedb9
# ╠═75086f82-a9ff-477f-8bc7-ebcfe1adca33
# ╠═caa79d4f-87b2-4cf4-be48-bc462c66dbbc
# ╠═09650e31-982c-461c-b131-0ce64af54029
# ╠═e77a81ac-16fd-415e-b258-1aaf0ee107bf
# ╠═064af764-855c-46bc-8e6f-1d22e96db509
# ╟─5bdd0e50-069a-4e2e-8097-0e0c714782f7
# ╠═fed00260-481b-40a8-96b5-e09c492ad7a1
# ╠═52b68640-079c-4abf-804b-0fd79c7bb0e3
# ╠═aacaa0ef-c4f6-4832-93fe-7c1d1b528f10
# ╠═6bce0891-115a-464d-8cd8-16cf41149acb
# ╠═b3ccd1a3-74fa-49e9-9b64-abc7d8c27ddb
# ╟─32b33218-c089-404c-8080-69ac13d3cc30
# ╟─066374aa-eea1-43b3-9d08-c105addee0ab
# ╠═3c803af1-c0e2-4de5-994f-4b746f768707
# ╠═f982fe68-fc0e-4af6-aed2-d3f3e9794ee8
# ╟─a76c691d-fbca-4e8d-81f3-573bf9e8df8c
# ╠═995c2eaf-2aa7-4b53-ae26-363bd4e2d39d
# ╠═d092c7b9-89ac-47fb-b1e4-eb2aa236161a
# ╠═48f81a65-bd74-4f45-a145-a575785d2916
# ╠═d7a5aa31-25c1-4f90-97c6-1ad4330d49e5
# ╟─0e78a609-8e0e-4222-97a2-31207cd42861
# ╟─6b0578ed-3a36-4c96-b4dc-ae814b5e406f
# ╠═39af5a0f-a49b-4173-8b48-e9a21d872f9b
# ╠═bcfd892a-1aef-4d6f-a191-7cdec39de7c8
# ╟─d728a6ce-2543-4ddc-9bfa-abbbe5c24398
# ╠═e5f06441-470a-4e3f-bb12-5b59601476eb
# ╠═cae27199-317c-46a2-93f8-14b74dd7988d
# ╟─04b25dea-4b79-49e6-9f98-060ff0c9d366
# ╠═cc9bdaaf-a1a1-4acd-b184-c11b18a7202a
# ╟─c12dea6e-0945-4c24-8a29-0d5ca266fa4b
# ╠═c79f7b66-ba81-4281-a1e0-ee2511917568
# ╠═075352c4-d9c3-4f0d-a528-a96f7246b5e9
# ╟─c87fb4e7-349e-43da-84a9-4a6177570e24
# ╟─f3dabf82-6ad8-4a30-b7fe-9101a2292161
# ╠═a65e7ea5-94f5-4820-a195-42f380e196a3
# ╠═d4c1327f-554d-49ab-828b-b6d2fcfe7412
# ╠═5db0ecfa-85c4-480c-aac0-1544e2fd5041
# ╟─b05ee130-a8aa-4e99-9fe3-1a0a4d2cd3dc
# ╟─04dc8068-3dd2-48c0-a3ae-0cfd02f95486
# ╟─203a650e-0bd7-458e-9840-da7e4bfdee36
# ╠═3f67d93f-74fd-4832-9b71-1dbc70034583
# ╟─aee9d593-228e-403c-8c26-9715d8f71ff1
# ╟─f889f166-544c-4840-a500-e84737b438cb
# ╠═3cae6e4f-08b0-45ab-9e7c-f1db14198c9e
# ╠═d0a44e0e-4840-4175-ad08-1912af3cc2a6
# ╠═e22ef343-dbe6-4dbc-9a82-1126a7319ca9
# ╠═1dde162e-38d3-4890-9593-0ad87c43ebd4
# ╟─a9b5dc02-9e00-4ec1-b157-ae06d66fbd13
# ╟─8f3451ae-9aa7-4580-bfc5-a553e4bebbb9
# ╠═c207e4cf-26e2-4933-8df0-51d54d959790
# ╠═67643e9f-a9d2-4496-82dc-9df8c7ce120b
# ╠═50bb68c6-f048-49b3-831e-01fe1815805a
# ╟─db7b708f-75cb-48d1-b509-2d0e090c0eb6
# ╟─3de43e3a-dca2-4964-8e47-64207d00510c
# ╠═0a674813-c4a2-4dd2-9f1a-69f0dcfbdd92
# ╠═49113df0-85be-41cd-abc2-f95ca70b440f
# ╠═751a287b-5fee-4c29-b9b5-1702d9da8071
# ╟─d6699545-4d50-429a-bfc2-87a053f35e6a
# ╠═c22d752e-0a0e-4276-8950-56a4f9300dd6
# ╟─03f56f9d-5703-41c1-b76c-23690dde1ee3
# ╠═e1b483c5-971b-4471-a77e-716300f9a1b4
# ╟─4f1b8dba-92fa-44fa-8f5c-85e87e39585b
# ╠═536d9a21-3f75-4a9d-8113-a07313b0f648
# ╟─2bc93ed8-8387-49ff-9c72-1528bf1dbd87
# ╟─0e12dbb5-1ae9-4fb4-b56c-5d8a9a1626d8
# ╟─c9722718-2dbb-4e81-acff-27630c4946b4
# ╟─7f61fa97-5d08-4e76-8d8c-9e3f19d11229
# ╠═fe143b8c-d827-45a9-b5dd-cd58738138f7
# ╠═2df199e9-3345-4705-be27-f434ae9f62f4
# ╠═68cc5425-0f8e-4987-b21e-d879cc244355
# ╠═0feff2a4-9955-4516-bfa8-6237389c71a7
# ╠═8cea15c1-6a2e-4dd2-820d-0eac0e33b3f9
# ╟─8cf2b37c-ca8f-4b2b-b526-0eb02dd2a778
# ╟─eb7c78b1-872c-49da-b18f-a087b007276b
# ╟─bfa991d7-4517-4fcb-ac41-845d271f6a78
# ╟─1c44dc8e-6bcb-44d9-9119-61051c23130e
# ╠═a296b103-67cd-46b7-9d7b-75d6f910bb3a
# ╠═d5fbcbcf-beb1-469c-a795-e990fa532f8b
# ╠═82db73b2-a39f-437c-8986-6e9a218dfad3
# ╟─e51e267e-8c94-4dd1-a55d-94f822156198
# ╠═b849c505-dac1-4fc7-9a83-2b2e35f6a4a6
# ╠═19db9749-fbdb-404e-b5c4-2afc487291c4
# ╠═9014968b-c5eb-42a4-a0b0-c8d071dc618e
# ╠═45ee1d1d-8164-44f5-883e-8b089824e09a
# ╟─4723c7f2-1e61-4244-8c7b-6a3509f66499
# ╟─80423090-b4bc-42ce-ba7f-49250f787aac
# ╠═102fae18-d839-43f4-8f65-46969ba2e1af
# ╟─f5637fb9-71ab-405c-88b7-818bb1c432ce
# ╟─df4df84b-775f-4cb2-aba8-f4037c9f1716
# ╟─cd2cd835-d364-4fe5-b8c9-2a841acb3531
# ╟─e4fc5921-a690-48c2-a1cb-370fa56afff8
# ╟─f9614c4c-f163-491d-b54e-c5ef862ca8fc
# ╠═c27218e2-08b7-45bd-9f2c-dc0e3e79d071
# ╟─2b36f026-39d7-442e-b9bc-0f1a98fa4fe5
# ╟─62c06a08-78c6-42df-8be1-fbea389a9ea3
# ╠═986eb3b4-ba98-4dcc-83bc-6bb9f98c84d1
# ╟─fed2a353-b49b-4ca8-974e-30fd02c308de
# ╟─265b6825-cb44-4b6e-8f1b-e7449fd5b3b1
# ╠═6abf2b45-40b1-4669-a3e1-af14c11f87eb
# ╠═3d93498d-5fb1-4320-8e60-c0783e22f9e1
# ╟─4d480492-099b-4683-bd43-4af81bed422e
# ╠═973f77ff-acb8-425e-bcef-811f62acaa8d
# ╠═c62671dc-672e-4b5b-84f2-168f004890f0
# ╟─699a7f53-efd9-4954-8fa0-92bc46981831
# ╠═8439d3a9-c305-461e-8da4-b310c4ff4a3c
# ╟─8d8a2b3e-f3f2-4e44-b48b-09abf64f18c0
# ╟─993d6264-28ef-45a8-8a17-d2a155d1359f
# ╟─c466adf3-2b20-4582-b56c-9af378188a0b
# ╠═9236636c-3026-4f29-81ef-2150fad43be4
# ╟─f0a54462-8018-452b-9b24-82008fe5b185
# ╟─1e211621-be0c-47fc-935c-8055c724afeb
# ╠═6b2cb86a-dedd-43f8-b83a-f6b8e9a97aff
# ╟─fd0a6f2e-65af-47ea-86c5-13a178395378
# ╟─0b110470-dabf-4587-b598-be2deec7e9d2
# ╟─59ee5d43-04e6-49dd-821b-4899e1e189f5
# ╟─2692d516-6662-44c3-946d-b1fad3f06aa8
# ╟─1fd6fc91-9783-4046-96f1-b87cea21418d
# ╟─98da0c22-616b-4756-b5f3-a974a9dbac39
# ╟─ffb24ed8-aff7-4b23-9c69-ee336c56a2a7
# ╟─2cbadd4e-ab46-4aa2-ae5b-2a1d0d87d3bf
# ╠═05c597a5-371b-45a1-8353-d0615f4cb07b
# ╟─94084775-6fd0-4ff2-a08e-34e08e9d4669
# ╟─dd55122c-643b-4359-ab86-8f26784b12b9
# ╟─1e2cf694-625d-42b6-adaa-9224d1aeadde
# ╟─9d204a01-4e7f-4324-a515-61884dc81eea
# ╟─b5364ad7-5f2f-44ef-8c56-b02fb389752a
# ╠═0ee50c89-7ee6-43a4-80c8-fdd077012c9f
# ╠═d0b5d113-cff1-4ac0-8a1e-68fafdd6eac8
# ╠═38ee3793-777c-4c2e-af46-71f11de0ee9e
# ╠═8191d687-85e2-4d63-8c80-f2bd81023762
# ╟─4b6385ff-f365-4b15-8b60-fbdac61aa808
# ╠═f24c9343-e6ea-47ab-a519-31438cef5a16
# ╠═981f3d39-68eb-4456-aece-52bb11112992
# ╠═53336ee7-0b9a-472d-9263-9c074e4c2831
# ╟─1309ffb1-c117-4217-bab7-776072dbda75
# ╠═9276cfe0-af59-4708-934d-b623ffb58892
# ╠═c6ed4972-6664-45cc-a095-2177b49ecc9b
# ╠═4131a7c6-6fbc-41ce-9611-49d3d5b11bd4
# ╠═a26b6462-2969-4381-8f87-f584e54d0ce8
# ╟─bcabd5a9-42d4-4ba9-823c-9133aa76fe67
# ╠═b478df28-3db8-492b-a968-4571e6136713
# ╠═93916765-65db-4d74-8eec-104bad3e8d6f
# ╠═5fa38de7-0c70-4852-b683-b30ad84df122
# ╠═950129a8-6c4b-402c-a343-aa43fe60fa95
# ╟─7aab32bc-9a07-4aac-b025-55191d545895
# ╟─11d933da-f0a1-4831-9a15-9f3578f91bdf
# ╠═96a7693c-c871-435c-9d62-59405f74d6e8
# ╠═39576c56-510d-4afe-937e-3686059d890e
# ╟─6e08a0ad-15fb-492d-b4c9-5333e9d4039b
# ╟─e5c2a57a-15eb-4db3-b2b5-061d2f040e2e
# ╟─61adf36e-eed8-4f2d-a7a4-67e8533498d7
# ╟─d7e487fa-dd32-4350-a10e-d2cb5b401cce
# ╟─ac025198-aacf-45e7-9c12-18f73fa4fe5a
# ╟─f1177760-6e52-40a3-8d67-13594b016c7a
# ╠═664c4793-ea2a-4fb8-87a3-65afa600e89b
# ╠═4c407f2d-3875-4735-b39d-9c65756cbf7d
# ╟─066a9db8-e05e-4b6d-9190-3032261a84b0
# ╠═2c129ab0-c8ee-457e-af13-5934313f7c7b
# ╠═8122ea03-9288-4a63-8c1f-6259718d4e9b
# ╟─6e0e6180-619a-4fff-a434-3472de19d1f0
# ╠═faaa6bc0-5fe0-4615-a630-fec9a65b9474
# ╠═9f943cae-cbd6-4fc2-b1df-4b950e292518
# ╟─53854580-96ed-4271-911f-ba6d5ddbf20c
# ╟─83a1e6b3-1200-4fd9-a124-a530eb2013f6
# ╟─1d802a5a-cff4-46a9-874b-e8f0ca66d174
# ╠═73351012-af40-4897-b349-23a77ed02111
# ╟─51709e56-7b74-44c8-84a9-67ccc01c6eb9
# ╠═70fbe10a-a2a6-4db4-a4cc-e91bf763511f
# ╠═8337a0ec-263a-425d-84f9-10e7da9b9517
# ╠═d3cc5b03-6946-4ba6-94fc-9908b8755b3e
# ╟─5ed8e3c7-776e-4466-831c-7c308a622010
# ╟─f1adbec1-4892-464c-9f41-d1cbfc48051c
# ╟─30da86b6-a2c7-4b69-8223-a05ae9ce49d5
# ╠═1ebb4d6b-2a38-44cc-bb93-1d4bb4297c0c
# ╠═1616ca8f-d7d5-403d-9cae-8adc50d76160
# ╠═d8b8d3df-a8b8-4957-bc33-4c6719f2f95a
# ╠═a99f2a22-f0e4-46b9-a68c-6097caee319f
# ╠═cfe0b9f9-d99f-4c73-b66d-d17b09b2d7ff
# ╠═012b81ee-ff1d-489c-8621-39b67c526f46
# ╠═f8d1faf7-333a-4adf-82b7-86463771877f
# ╠═1d8cf2aa-9ccc-4392-baf4-8df620db1a82
# ╠═0ee76a24-3ecd-4a1d-9795-b2fd166a9270
# ╠═12896a3b-9c2b-4f87-9ebc-6a659a9d27a7
# ╟─42194c03-f398-4a97-835d-99636005b7d0
# ╠═da3e0acc-3105-4274-b64b-1dc80732c623
# ╟─e5e97702-48e2-4bf3-ad75-07a38a22df08
# ╠═d08789c7-ffa7-4feb-a55d-dceb60549ff5
# ╠═922518da-8025-4be1-964e-09fdd11932c1
# ╠═4b70822b-d5bd-4973-b079-d089f3cd09c5
# ╟─6d88373a-77c6-4ca4-8ec0-e0c410accbd0
# ╠═b4fab237-0f89-4bfa-a064-644df389e95a
# ╟─0f1ab0b5-fed2-4b7d-af26-563b1479cb2d
# ╠═36139330-7a0c-40ad-af7a-1739cc89fc22
# ╟─99a3c453-cade-4cc0-ab29-dcb46f426029
# ╟─258e0f2b-8057-4525-9927-4f51c0a7a9fb
# ╟─c56257d1-6810-40b1-81d4-4097d85121e3
# ╠═4ae116ea-77cb-4840-8173-387f83ae2d44
# ╠═d6d7f601-0984-486b-bb4c-178bd2204acd
# ╟─a603116b-3dac-4f19-9e31-388a43988cd4
# ╠═b6917f1c-583b-4201-8b7b-3ee6b1df9409
# ╠═27cb0571-63a6-44af-871a-85ab773f39b1
# ╠═a4c92c04-aa50-43bc-bc74-19ae593a67b7
# ╠═bffc1225-7217-4a75-8016-b37a45b0282f
# ╠═0fef06a9-cd7f-4154-8d61-6e0cbf78e51f
# ╟─32ef8124-c57f-4d43-9657-dca4be977f51
# ╟─a82a82e3-469b-42bf-be87-7ad65e0e867c
# ╠═6a066ab2-51f4-4ca1-ac33-c1ca336f34ce
# ╠═c9a88ff3-619e-49dc-80c0-c3e64427e421
# ╠═b04092c6-4aa7-4181-b6c0-1e139d1f3a6a
# ╠═b779a092-bd6c-400c-a619-6dfee3d50a63
# ╠═925ebac6-3be3-437c-b056-5ca42db37e18
# ╠═7f4fd632-828b-4303-9672-60174f1ce6e3
# ╠═22508adf-87a2-4c87-a1c2-dfea6b07bba7
# ╠═19e4fc40-eb0e-46d6-bc00-d4f60a34c709
# ╟─f0de63c0-fdba-4add-bf4f-911281f0190c
# ╟─c942891c-7aa4-4f99-95a2-ec5d25146694
# ╟─cab1c519-9e2d-478f-9465-e95046a248cd
# ╟─78d0ef8d-beb2-4b0f-9afc-be0e7f2c71d0
# ╠═ea0bab70-bd3e-4e77-9e59-a02fdd3c67dd
# ╟─b06c9107-17e5-49ce-909e-38b92a72b7b8
# ╠═d172fac7-4929-47e3-9fe7-eaa9837c3684
# ╟─f052fd53-7f82-4e99-8c8f-0f276d7e60e4
# ╠═56cf46bc-0fc4-403d-ac51-0dc1e0b6c95c
# ╠═02744d6d-4879-4843-8cb4-4802f8034afc
# ╠═40fd2e8a-9862-4084-b9b1-0de282cc1a5c
# ╠═cecfccd7-4ba7-4b46-8caa-471a11c2394d
# ╟─8964b9b4-83d3-4638-a3fa-638f6dba6884
# ╠═91f65752-66ee-4f50-9e25-47fc2a4578b9
# ╠═5e5c71cd-914b-4e8c-b32e-e16dab5b6da9
# ╟─d9973cf0-0715-4c6e-8daa-fc9b8bf60ce1
# ╟─fe18da98-98ff-42e3-9e3f-3912a0224afb
# ╟─fa3c1a78-0ae8-4395-abb3-3b8d29232203
# ╟─d04e9c82-5d82-4844-bb6c-ba9b30d9a3eb
# ╟─ef3e0100-da11-4e82-af56-9137891d586a
# ╟─1d43c742-adef-416f-b7c3-8827a520999e
# ╟─425bdb88-ade6-422b-8a83-55e939719b67
# ╟─69077728-f821-438f-ad91-e923eee63401
# ╟─0090bfe2-b387-4eb4-a062-4116f9cc0e94
# ╟─5e125e12-a144-4ff3-911e-c2ef9a14cac1
# ╟─298a4267-7bb5-49f2-b3ca-acea9f730df6
# ╟─1c70ff5e-a581-4125-9e32-81769e8fdef2
# ╟─c16b0dfe-acfd-4ec0-8715-2eb153233f04
# ╟─35b565e8-1700-4a23-8e46-4c86a8bd80ab
# ╠═ec54832e-4dcb-4594-8d0d-35a0b8a1b2d8
# ╟─06d8409c-f5f1-4323-9b46-c12cc40e2f09
