### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ 03c89356-9e19-11eb-110e-5d62314dae11
md"""
# Integers and Floating-Point Numbers
"""

# ╔═╡ 03c8937e-9e19-11eb-2dc8-2933e879d99a
md"""
Integers and floating-point values are the basic building blocks of arithmetic and computation. Built-in representations of such values are called numeric primitives, while representations of integers and floating-point numbers as immediate values in code are known as numeric literals. For example, `1` is an integer literal, while `1.0` is a floating-point literal; their binary in-memory representations as objects are numeric primitives.
"""

# ╔═╡ 03c893b0-9e19-11eb-2dad-45d44831af19
md"""
Julia provides a broad range of primitive numeric types, and a full complement of arithmetic and bitwise operators as well as standard mathematical functions are defined over them. These map directly onto numeric types and operations that are natively supported on modern computers, thus allowing Julia to take full advantage of computational resources. Additionally, Julia provides software support for [Arbitrary Precision Arithmetic](@ref), which can handle operations on numeric values that cannot be represented effectively in native hardware representations, but at the cost of relatively slower performance.
"""

# ╔═╡ 03c893c4-9e19-11eb-390e-fd154af71121
md"""
The following are Julia's primitive numeric types:
"""

# ╔═╡ 03c89482-9e19-11eb-15fe-13092b450017
md"""
  * **Integer types:**
"""

# ╔═╡ 03c89766-9e19-11eb-3841-c7bc5508ed5b
md"""
| Type              | Signed? | Number of bits | Smallest value | Largest value |
|:----------------- |:------- |:-------------- |:-------------- |:------------- |
| [`Int8`](@ref)    | ✓       | 8              | -2^7           | 2^7 - 1       |
| [`UInt8`](@ref)   |         | 8              | 0              | 2^8 - 1       |
| [`Int16`](@ref)   | ✓       | 16             | -2^15          | 2^15 - 1      |
| [`UInt16`](@ref)  |         | 16             | 0              | 2^16 - 1      |
| [`Int32`](@ref)   | ✓       | 32             | -2^31          | 2^31 - 1      |
| [`UInt32`](@ref)  |         | 32             | 0              | 2^32 - 1      |
| [`Int64`](@ref)   | ✓       | 64             | -2^63          | 2^63 - 1      |
| [`UInt64`](@ref)  |         | 64             | 0              | 2^64 - 1      |
| [`Int128`](@ref)  | ✓       | 128            | -2^127         | 2^127 - 1     |
| [`UInt128`](@ref) |         | 128            | 0              | 2^128 - 1     |
| [`Bool`](@ref)    | N/A     | 8              | `false` (0)    | `true` (1)    |
"""

# ╔═╡ 03c897a2-9e19-11eb-39de-d15c16d1c9be
md"""
  * **Floating-point types:**
"""

# ╔═╡ 03c89860-9e19-11eb-1c84-ab2124c5de69
md"""
| Type              | Precision                                                                      | Number of bits |
|:----------------- |:------------------------------------------------------------------------------ |:-------------- |
| [`Float16`](@ref) | [half](https://en.wikipedia.org/wiki/Half-precision_floating-point_format)     | 16             |
| [`Float32`](@ref) | [single](https://en.wikipedia.org/wiki/Single_precision_floating-point_format) | 32             |
| [`Float64`](@ref) | [double](https://en.wikipedia.org/wiki/Double_precision_floating-point_format) | 64             |
"""

# ╔═╡ 03c89888-9e19-11eb-3f5f-591d31d3f176
md"""
Additionally, full support for [Complex and Rational Numbers](@ref) is built on top of these primitive numeric types. All numeric types interoperate naturally without explicit casting, thanks to a flexible, user-extensible [type promotion system](@ref conversion-and-promotion).
"""

# ╔═╡ 03c898b2-9e19-11eb-3d57-91986bb6ec29
md"""
## Integers
"""

# ╔═╡ 03c898c4-9e19-11eb-1c18-f793d66ddced
md"""
Literal integers are represented in the standard manner:
"""

# ╔═╡ 03c89af4-9e19-11eb-2708-1d7e815aa1d8
1

# ╔═╡ 03c89af4-9e19-11eb-1d67-d327a5689f00
1234

# ╔═╡ 03c89b12-9e19-11eb-1c8f-79ca972eaac0
md"""
The default type for an integer literal depends on whether the target system has a 32-bit architecture or a 64-bit architecture:
"""

# ╔═╡ 03c89d38-9e19-11eb-39c4-89109f062b9f
# 32-bit system:

# ╔═╡ 03c89d42-9e19-11eb-0c64-d93b0241bc59
typeof(1)

# ╔═╡ 03c89d42-9e19-11eb-3980-eb83cd2948d7
typeof(1)

# ╔═╡ 03c89d6a-9e19-11eb-0eec-793d87eb6438
md"""
The Julia internal variable [`Sys.WORD_SIZE`](@ref) indicates whether the target system is 32-bit or 64-bit:
"""

# ╔═╡ 03c89efa-9e19-11eb-2000-51157f59d8fe
# 32-bit system:

# ╔═╡ 03c89f04-9e19-11eb-173e-a7a56e31732d
Sys.WORD_SIZE

# ╔═╡ 03c89f0e-9e19-11eb-0c7b-b192b8f52e53
Sys.WORD_SIZE

# ╔═╡ 03c89f2c-9e19-11eb-3b6f-158ed6c95791
md"""
Julia also defines the types `Int` and `UInt`, which are aliases for the system's signed and unsigned native integer types respectively:
"""

# ╔═╡ 03c8a102-9e19-11eb-0151-b157092744f7
# 32-bit system:

# ╔═╡ 03c8a10c-9e19-11eb-353c-af130c4b6137
Int

# ╔═╡ 03c8a116-9e19-11eb-3cdd-4b6c779db1e2
UInt

# ╔═╡ 03c8a116-9e19-11eb-3089-133e66a04b85
Int

# ╔═╡ 03c8a11e-9e19-11eb-2f25-65c950fad35f
UInt

# ╔═╡ 03c8a134-9e19-11eb-0711-01fc72ee29a8
md"""
Larger integer literals that cannot be represented using only 32 bits but can be represented in 64 bits always create 64-bit integers, regardless of the system type:
"""

# ╔═╡ 03c8a26a-9e19-11eb-0c11-3bc73d0180b0
# 32-bit or 64-bit system:

# ╔═╡ 03c8a26a-9e19-11eb-3396-4d7bcb680275
typeof(3000000000)

# ╔═╡ 03c8a292-9e19-11eb-0045-b5994961a83f
md"""
Unsigned integers are input and output using the `0x` prefix and hexadecimal (base 16) digits `0-9a-f` (the capitalized digits `A-F` also work for input). The size of the unsigned value is determined by the number of hex digits used:
"""

# ╔═╡ 03c8ab7a-9e19-11eb-3819-295674e24008
x = 0x1

# ╔═╡ 03c8ab84-9e19-11eb-08bc-4b03b10d0087
typeof(x)

# ╔═╡ 03c8ab8e-9e19-11eb-3164-27c83b75f13f
x = 0x123

# ╔═╡ 03c8ab9a-9e19-11eb-2fe8-195271eae976
typeof(x)

# ╔═╡ 03c8ab9a-9e19-11eb-2542-33f9eee1edfd
x = 0x1234567

# ╔═╡ 03c8aba2-9e19-11eb-2007-577e00cccb76
typeof(x)

# ╔═╡ 03c8abac-9e19-11eb-08c1-9b80af953723
x = 0x123456789abcdef

# ╔═╡ 03c8abb6-9e19-11eb-284e-a718fd0c6733
typeof(x)

# ╔═╡ 03c8abc0-9e19-11eb-02d6-1745a9173b79
x = 0x11112222333344445555666677778888

# ╔═╡ 03c8abc0-9e19-11eb-3e13-7f9a76cd1eb3
typeof(x)

# ╔═╡ 03c8abde-9e19-11eb-2993-bb9f149c8cbf
md"""
This behavior is based on the observation that when one uses unsigned hex literals for integer values, one typically is using them to represent a fixed numeric byte sequence, rather than just an integer value.
"""

# ╔═╡ 03c8abf2-9e19-11eb-1f37-57ac38d9362d
md"""
Binary and octal literals are also supported:
"""

# ╔═╡ 03c8b108-9e19-11eb-1d9b-f145e9352919
x = 0b10

# ╔═╡ 03c8b110-9e19-11eb-18b2-affb42724b03
typeof(x)

# ╔═╡ 03c8b110-9e19-11eb-3e97-77ab420bbc8d
x = 0o010

# ╔═╡ 03c8b11a-9e19-11eb-3eca-bd3d3bd91af6
typeof(x)

# ╔═╡ 03c8b124-9e19-11eb-3fe6-81ea3e66e281
x = 0x00000000000000001111222233334444

# ╔═╡ 03c8b124-9e19-11eb-358d-d1758b872b5f
typeof(x)

# ╔═╡ 03c8b142-9e19-11eb-2b55-e3629f3c5e83
md"""
As for hexadecimal literals, binary and octal literals produce unsigned integer types. The size of the binary data item is the minimal needed size, if the leading digit of the literal is not `0`. In the case of leading zeros, the size is determined by the minimal needed size for a literal, which has the same length but leading digit `1`. That allows the user to control the size. Values which cannot be stored in `UInt128` cannot be written as such literals.
"""

# ╔═╡ 03c8b160-9e19-11eb-3fed-bd052b592dcc
md"""
Binary, octal, and hexadecimal literals may be signed by a `-` immediately preceding the unsigned literal. They produce an unsigned integer of the same size as the unsigned literal would do, with the two's complement of the value:
"""

# ╔═╡ 03c8b2be-9e19-11eb-381e-91ace6c70235
-0x2

# ╔═╡ 03c8b2c8-9e19-11eb-1854-3b865221aa8a
-0x0002

# ╔═╡ 03c8b2f0-9e19-11eb-2c3c-614a77d97ae3
md"""
The minimum and maximum representable values of primitive numeric types such as integers are given by the [`typemin`](@ref) and [`typemax`](@ref) functions:
"""

# ╔═╡ 03c8ba0a-9e19-11eb-232e-6f006badc0b9
(typemin(Int32), typemax(Int32))

# ╔═╡ 03c8ba0a-9e19-11eb-0c72-59fdd872dae5
for T in [Int8,Int16,Int32,Int64,Int128,UInt8,UInt16,UInt32,UInt64,UInt128]
           println("$(lpad(T,7)): [$(typemin(T)),$(typemax(T))]")
       end

# ╔═╡ 03c8ba48-9e19-11eb-27cd-ad1cf8529585
md"""
The values returned by [`typemin`](@ref) and [`typemax`](@ref) are always of the given argument type. (The above expression uses several features that have yet to be introduced, including [for loops](@ref man-loops), [Strings](@ref man-strings), and [Interpolation](@ref string-interpolation), but should be easy enough to understand for users with some existing programming experience.)
"""

# ╔═╡ 03c8ba7a-9e19-11eb-26f9-df2f5d213388
md"""
### Overflow behavior
"""

# ╔═╡ 03c8ba8e-9e19-11eb-0f05-af49cca9612c
md"""
In Julia, exceeding the maximum representable value of a given type results in a wraparound behavior:
"""

# ╔═╡ 03c8bdfe-9e19-11eb-3918-4b464b293465
x = typemax(Int64)

# ╔═╡ 03c8be08-9e19-11eb-37d0-095585521f3c
x + 1

# ╔═╡ 03c8be08-9e19-11eb-3b11-4940e13029bf
x + 1 == typemin(Int64)

# ╔═╡ 03c8be30-9e19-11eb-1287-4976bb95dba2
md"""
Thus, arithmetic with Julia integers is actually a form of [modular arithmetic](https://en.wikipedia.org/wiki/Modular_arithmetic). This reflects the characteristics of the underlying arithmetic of integers as implemented on modern computers. In applications where overflow is possible, explicit checking for wraparound produced by overflow is essential; otherwise, the [`BigInt`](@ref) type in [Arbitrary Precision Arithmetic](@ref) is recommended instead.
"""

# ╔═╡ 03c8be42-9e19-11eb-1839-e3322a3fe6b7
md"""
An example of overflow behavior and how to potentially resolve it is as follows:
"""

# ╔═╡ 03c8c060-9e19-11eb-32a1-bbb2cde7077a
10^19

# ╔═╡ 03c8c06a-9e19-11eb-076f-5f61a3a981ca
big(10)^19

# ╔═╡ 03c8c080-9e19-11eb-3ed8-832164d0ead6
md"""
### Division errors
"""

# ╔═╡ 03c8c0ae-9e19-11eb-053b-2fa1d05e5602
md"""
Integer division (the `div` function) has two exceptional cases: dividing by zero, and dividing the lowest negative number ([`typemin`](@ref)) by -1. Both of these cases throw a [`DivideError`](@ref). The remainder and modulus functions (`rem` and `mod`) throw a [`DivideError`](@ref) when their second argument is zero.
"""

# ╔═╡ 03c8c0c4-9e19-11eb-1426-4b51099c2a60
md"""
## Floating-Point Numbers
"""

# ╔═╡ 03c8c0d8-9e19-11eb-313b-f95d4f1ab659
md"""
Literal floating-point numbers are represented in the standard formats, using [E-notation](https://en.wikipedia.org/wiki/Scientific_notation#E_notation) when necessary:
"""

# ╔═╡ 03c8c4de-9e19-11eb-14a0-7d8c862a091d
1.0

# ╔═╡ 03c8c4e6-9e19-11eb-0acf-e93e14d704c6
1.

# ╔═╡ 03c8c4f2-9e19-11eb-217a-0b594098a5b8
0.5

# ╔═╡ 03c8c4f2-9e19-11eb-2a87-fdf6b6d088c5
.5

# ╔═╡ 03c8c4fc-9e19-11eb-0a4f-09b29701a130
-1.23

# ╔═╡ 03c8c4fc-9e19-11eb-2ee2-15423ce06236
1e10

# ╔═╡ 03c8c506-9e19-11eb-0eae-d3a4688a6790
2.5e-4

# ╔═╡ 03c8c524-9e19-11eb-250b-4d2a2c6b7034
md"""
The above results are all [`Float64`](@ref) values. Literal [`Float32`](@ref) values can be entered by writing an `f` in place of `e`:
"""

# ╔═╡ 03c8c7a4-9e19-11eb-0572-df1ebe567a18
x = 0.5f0

# ╔═╡ 03c8c7ae-9e19-11eb-2c2e-95fc2feffd5d
typeof(x)

# ╔═╡ 03c8c7b6-9e19-11eb-2ba8-611bb2d15b0c
2.5f-4

# ╔═╡ 03c8c7cc-9e19-11eb-2933-3b6e8e7884aa
md"""
Values can be converted to [`Float32`](@ref) easily:
"""

# ╔═╡ 03c8c9e8-9e19-11eb-02da-0bac89ac1894
x = Float32(-1.5)

# ╔═╡ 03c8c9f4-9e19-11eb-0bee-efd8550a205a
typeof(x)

# ╔═╡ 03c8ca10-9e19-11eb-3ba1-6bb94d270d58
md"""
Hexadecimal floating-point literals are also valid, but only as [`Float64`](@ref) values, with `p` preceding the base-2 exponent:
"""

# ╔═╡ 03c8cd30-9e19-11eb-16e3-d15469c8cb3f
0x1p0

# ╔═╡ 03c8cd30-9e19-11eb-0368-d5e235033896
0x1.8p3

# ╔═╡ 03c8cd3a-9e19-11eb-1504-275385da8545
x = 0x.4p-1

# ╔═╡ 03c8cd44-9e19-11eb-12a4-2373cdecd615
typeof(x)

# ╔═╡ 03c8cd62-9e19-11eb-0386-f37660664d16
md"""
Half-precision floating-point numbers are also supported ([`Float16`](@ref)), but they are implemented in software and use [`Float32`](@ref) for calculations.
"""

# ╔═╡ 03c8cfec-9e19-11eb-0588-118d76a079e0
sizeof(Float16(4.))

# ╔═╡ 03c8cff4-9e19-11eb-3b72-31b0712223db
2*Float16(4.)

# ╔═╡ 03c8d00a-9e19-11eb-3d16-8f5051f2fd15
md"""
The underscore `_` can be used as digit separator:
"""

# ╔═╡ 03c8d26c-9e19-11eb-29f7-e59959f1d554
10_000, 0.000_000_005, 0xdead_beef, 0b1011_0010

# ╔═╡ 03c8d280-9e19-11eb-11c3-91834c46e3a0
md"""
### Floating-point zero
"""

# ╔═╡ 03c8d2a8-9e19-11eb-20da-733622cdc163
md"""
Floating-point numbers have [two zeros](https://en.wikipedia.org/wiki/Signed_zero), positive zero and negative zero. They are equal to each other but have different binary representations, as can be seen using the [`bitstring`](@ref) function:
"""

# ╔═╡ 03c8d5dc-9e19-11eb-0509-275dbeeadc46
0.0 == -0.0

# ╔═╡ 03c8d5e6-9e19-11eb-1091-574f14eff022
bitstring(0.0)

# ╔═╡ 03c8d5e6-9e19-11eb-2c33-5f5333a4e1bf
bitstring(-0.0)

# ╔═╡ 03c8d5fa-9e19-11eb-2753-2dc316989233
md"""
### Special floating-point values
"""

# ╔═╡ 03c8d60e-9e19-11eb-18d7-5d957f3b18ed
md"""
There are three specified standard floating-point values that do not correspond to any point on the real number line:
"""

# ╔═╡ 03c8d6f4-9e19-11eb-21eb-47d99ed3426f
md"""
| `Float16` | `Float32` | `Float64` | Name              | Description                                                     |
|:--------- |:--------- |:--------- |:----------------- |:--------------------------------------------------------------- |
| `Inf16`   | `Inf32`   | `Inf`     | positive infinity | a value greater than all finite floating-point values           |
| `-Inf16`  | `-Inf32`  | `-Inf`    | negative infinity | a value less than all finite floating-point values              |
| `NaN16`   | `NaN32`   | `NaN`     | not a number      | a value not `==` to any floating-point value (including itself) |
"""

# ╔═╡ 03c8d71c-9e19-11eb-0681-2f589e1add9c
md"""
For further discussion of how these non-finite floating-point values are ordered with respect to each other and other floats, see [Numeric Comparisons](@ref). By the [IEEE 754 standard](https://en.wikipedia.org/wiki/IEEE_754-2008), these floating-point values are the results of certain arithmetic operations:
"""

# ╔═╡ 03c8e004-9e19-11eb-39fe-a506bc085771
1/Inf

# ╔═╡ 03c8e010-9e19-11eb-39d5-17c693767904
1/0

# ╔═╡ 03c8e010-9e19-11eb-08d6-b5a188704cc3
-5/0

# ╔═╡ 03c8e018-9e19-11eb-34e8-ef88e086fd66
0.000001/0

# ╔═╡ 03c8e018-9e19-11eb-29a5-5f8900ae561c
0/0

# ╔═╡ 03c8e022-9e19-11eb-1b84-edb5b787c37e
500 + Inf

# ╔═╡ 03c8e022-9e19-11eb-1f97-8ff196e53970
500 - Inf

# ╔═╡ 03c8e02c-9e19-11eb-11c1-9725fe290908
Inf + Inf

# ╔═╡ 03c8e036-9e19-11eb-1b39-87bec5b1d678
Inf - Inf

# ╔═╡ 03c8e036-9e19-11eb-1cb7-33588e0a0b3d
Inf * Inf

# ╔═╡ 03c8e036-9e19-11eb-1924-51167f67a668
Inf / Inf

# ╔═╡ 03c8e03e-9e19-11eb-1031-4b8d4bebd79f
0 * Inf

# ╔═╡ 03c8e05e-9e19-11eb-06dd-77b750c6fd18
md"""
The [`typemin`](@ref) and [`typemax`](@ref) functions also apply to floating-point types:
"""

# ╔═╡ 03c8e4dc-9e19-11eb-1f23-9138145a360a
(typemin(Float16),typemax(Float16))

# ╔═╡ 03c8e4e6-9e19-11eb-0592-11de2337d475
(typemin(Float32),typemax(Float32))

# ╔═╡ 03c8e4f0-9e19-11eb-15d8-57ddddb03c14
(typemin(Float64),typemax(Float64))

# ╔═╡ 03c8e4fa-9e19-11eb-2ae3-a9877ce6db48
md"""
### Machine epsilon
"""

# ╔═╡ 03c8e51a-9e19-11eb-01fd-b50609c89c8e
md"""
Most real numbers cannot be represented exactly with floating-point numbers, and so for many purposes it is important to know the distance between two adjacent representable floating-point numbers, which is often known as [machine epsilon](https://en.wikipedia.org/wiki/Machine_epsilon).
"""

# ╔═╡ 03c8e536-9e19-11eb-0c1b-1f2f819300cb
md"""
Julia provides [`eps`](@ref), which gives the distance between `1.0` and the next larger representable floating-point value:
"""

# ╔═╡ 03c8e714-9e19-11eb-3008-73cf1b80682e
eps(Float32)

# ╔═╡ 03c8e714-9e19-11eb-07e9-973c37172bde
eps(Float64)

# ╔═╡ 03c8e720-9e19-11eb-0b13-4ddf373567ed
eps() # same as eps(Float64)

# ╔═╡ 03c8e752-9e19-11eb-3d45-93b7f38773e6
md"""
These values are `2.0^-23` and `2.0^-52` as [`Float32`](@ref) and [`Float64`](@ref) values, respectively. The [`eps`](@ref) function can also take a floating-point value as an argument, and gives the absolute difference between that value and the next representable floating point value. That is, `eps(x)` yields a value of the same type as `x` such that `x + eps(x)` is the next representable floating-point value larger than `x`:
"""

# ╔═╡ 03c8eaa4-9e19-11eb-190a-6f676301573c
eps(1.0)

# ╔═╡ 03c8eaa4-9e19-11eb-1265-bbee346c7b0d
eps(1000.)

# ╔═╡ 03c8eaae-9e19-11eb-1496-15dc7614d4dd
eps(1e-27)

# ╔═╡ 03c8eaba-9e19-11eb-103e-276bb3978a1e
eps(0.0)

# ╔═╡ 03c8ead6-9e19-11eb-33c7-07f1e5945acf
md"""
The distance between two adjacent representable floating-point numbers is not constant, but is smaller for smaller values and larger for larger values. In other words, the representable floating-point numbers are densest in the real number line near zero, and grow sparser exponentially as one moves farther away from zero. By definition, `eps(1.0)` is the same as `eps(Float64)` since `1.0` is a 64-bit floating-point value.
"""

# ╔═╡ 03c8eaf4-9e19-11eb-3c75-27733aa8bc71
md"""
Julia also provides the [`nextfloat`](@ref) and [`prevfloat`](@ref) functions which return the next largest or smallest representable floating-point number to the argument respectively:
"""

# ╔═╡ 03c8efe0-9e19-11eb-0f8b-5760a280de54
x = 1.25f0

# ╔═╡ 03c8efea-9e19-11eb-0720-dd8d189f76b2
nextfloat(x)

# ╔═╡ 03c8eff4-9e19-11eb-151c-e58eb11c9eef
prevfloat(x)

# ╔═╡ 03c8eff4-9e19-11eb-0b38-71a09b8b5af5
bitstring(prevfloat(x))

# ╔═╡ 03c8effe-9e19-11eb-382b-113c3a43e4bd
bitstring(x)

# ╔═╡ 03c8effe-9e19-11eb-3d55-4705037881f5
bitstring(nextfloat(x))

# ╔═╡ 03c8f012-9e19-11eb-100d-fb1ce7b709ce
md"""
This example highlights the general principle that the adjacent representable floating-point numbers also have adjacent binary integer representations.
"""

# ╔═╡ 03c8f028-9e19-11eb-239e-e5438c5db8df
md"""
### Rounding modes
"""

# ╔═╡ 03c8f03a-9e19-11eb-0846-b5ecccaf82bf
md"""
If a number doesn't have an exact floating-point representation, it must be rounded to an appropriate representable value. However, the manner in which this rounding is done can be changed if required according to the rounding modes presented in the [IEEE 754 standard](https://en.wikipedia.org/wiki/IEEE_754-2008).
"""

# ╔═╡ 03c8f05a-9e19-11eb-245f-2f5472da1866
md"""
The default mode used is always [`RoundNearest`](@ref), which rounds to the nearest representable value, with ties rounded towards the nearest value with an even least significant bit.
"""

# ╔═╡ 03c8f062-9e19-11eb-1aa8-b782011f95e6
md"""
### Background and References
"""

# ╔═╡ 03c8f076-9e19-11eb-20f3-79f0edd22fe8
md"""
Floating-point arithmetic entails many subtleties which can be surprising to users who are unfamiliar with the low-level implementation details. However, these subtleties are described in detail in most books on scientific computation, and also in the following references:
"""

# ╔═╡ 03c8f1fc-9e19-11eb-147e-2d893bbbda30
md"""
  * The definitive guide to floating point arithmetic is the [IEEE 754-2008 Standard](https://standards.ieee.org/standard/754-2008.html); however, it is not available for free online.
  * For a brief but lucid presentation of how floating-point numbers are represented, see John D. Cook's [article](https://www.johndcook.com/blog/2009/04/06/anatomy-of-a-floating-point-number/) on the subject as well as his [introduction](https://www.johndcook.com/blog/2009/04/06/numbers-are-a-leaky-abstraction/) to some of the issues arising from how this representation differs in behavior from the idealized abstraction of real numbers.
  * Also recommended is Bruce Dawson's [series of blog posts on floating-point numbers](https://randomascii.wordpress.com/2012/05/20/thats-not-normalthe-performance-of-odd-floats/).
  * For an excellent, in-depth discussion of floating-point numbers and issues of numerical accuracy encountered when computing with them, see David Goldberg's paper [What Every Computer Scientist Should Know About Floating-Point Arithmetic](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.22.6768&rep=rep1&type=pdf).
  * For even more extensive documentation of the history of, rationale for, and issues with floating-point numbers, as well as discussion of many other topics in numerical computing, see the [collected writings](https://people.eecs.berkeley.edu/~wkahan/) of [William Kahan](https://en.wikipedia.org/wiki/William_Kahan), commonly known as the "Father of Floating-Point". Of particular interest may be [An Interview with the Old Man of Floating-Point](https://people.eecs.berkeley.edu/~wkahan/ieee754status/754story.html).
"""

# ╔═╡ 03c8f210-9e19-11eb-1ab7-018ed5f85d62
md"""
## Arbitrary Precision Arithmetic
"""

# ╔═╡ 03c8f238-9e19-11eb-1139-7da9243e4abd
md"""
To allow computations with arbitrary-precision integers and floating point numbers, Julia wraps the [GNU Multiple Precision Arithmetic Library (GMP)](https://gmplib.org) and the [GNU MPFR Library](https://www.mpfr.org), respectively. The [`BigInt`](@ref) and [`BigFloat`](@ref) types are available in Julia for arbitrary precision integer and floating point numbers respectively.
"""

# ╔═╡ 03c8f26a-9e19-11eb-3e91-d76afc701860
md"""
Constructors exist to create these types from primitive numerical types, and the [string literal](@ref non-standard-string-literals) [`@big_str`](@ref) or [`parse`](@ref) can be used to construct them from `AbstractString`s. `BigInt`s can also be input as integer literals when they are too big for other built-in integer types. Note that as there is no unsigned arbitrary-precision integer type in `Base` (`BigInt` is sufficient in most cases), hexadecimal, octal and binary literals can be used (in addition to decimal literals).
"""

# ╔═╡ 03c8f288-9e19-11eb-379d-216768005141
md"""
Once created, they participate in arithmetic with all other numeric types thanks to Julia's [type promotion and conversion mechanism](@ref conversion-and-promotion):
"""

# ╔═╡ 03c902dc-9e19-11eb-39ab-3f5298ef59cc
BigInt(typemax(Int64)) + 1

# ╔═╡ 03c902dc-9e19-11eb-3d55-3d63c32d0ee2
big"123456789012345678901234567890" + 1

# ╔═╡ 03c902e6-9e19-11eb-2d66-157a69a45102
parse(BigInt, "123456789012345678901234567890") + 1

# ╔═╡ 03c902e6-9e19-11eb-362e-87ea2434c10e
string(big"2"^200, base=16)

# ╔═╡ 03c902f0-9e19-11eb-1a75-fdf61242e6c2
0x100000000000000000000000000000000-1 == typemax(UInt128)

# ╔═╡ 03c902fa-9e19-11eb-0cfa-4fda137cfc0c
0x000000000000000000000000000000000

# ╔═╡ 03c902fa-9e19-11eb-1018-0362c301537c
typeof(ans)

# ╔═╡ 03c90304-9e19-11eb-3abb-11ba3796ebc4
big"1.23456789012345678901"

# ╔═╡ 03c90304-9e19-11eb-047b-e91d8bbcd295
parse(BigFloat, "1.23456789012345678901")

# ╔═╡ 03c9030e-9e19-11eb-2b9b-458a3a9c20dc
BigFloat(2.0^66) / 3

# ╔═╡ 03c9030e-9e19-11eb-09b4-655edfd7edc1
factorial(BigInt(40))

# ╔═╡ 03c90336-9e19-11eb-173f-8555a0b5805f
md"""
However, type promotion between the primitive types above and [`BigInt`](@ref)/[`BigFloat`](@ref) is not automatic and must be explicitly stated.
"""

# ╔═╡ 03c908f4-9e19-11eb-18af-8939d7217126
x = typemin(Int64)

# ╔═╡ 03c908fe-9e19-11eb-162b-a9b54c6ac13a
x = x - 1

# ╔═╡ 03c908fe-9e19-11eb-0f81-6d3098225cbc
typeof(x)

# ╔═╡ 03c90908-9e19-11eb-13cd-a51835a955de
y = BigInt(typemin(Int64))

# ╔═╡ 03c90908-9e19-11eb-0dc4-91c3025fe1b0
y = y - 1

# ╔═╡ 03c90914-9e19-11eb-3069-9f5727411fc3
typeof(y)

# ╔═╡ 03c9094e-9e19-11eb-0250-c1a8292d2c91
md"""
The default precision (in number of bits of the significand) and rounding mode of [`BigFloat`](@ref) operations can be changed globally by calling [`setprecision`](@ref) and [`setrounding`](@ref), and all further calculations will take these changes in account.  Alternatively, the precision or the rounding can be changed only within the execution of a particular block of code by using the same functions with a `do` block:
"""

# ╔═╡ 03c9113c-9e19-11eb-3a8b-f53a1fe2919b
setrounding(BigFloat, RoundUp) do
           BigFloat(1) + parse(BigFloat, "0.1")
       end

# ╔═╡ 03c9113c-9e19-11eb-110e-7179186c1956
setrounding(BigFloat, RoundDown) do
           BigFloat(1) + parse(BigFloat, "0.1")
       end

# ╔═╡ 03c91146-9e19-11eb-164a-9747a27defbf
setprecision(40) do
           BigFloat(1) + parse(BigFloat, "0.1")
       end

# ╔═╡ 03c91164-9e19-11eb-00bd-7f7ef6bab78a
md"""
## [Numeric Literal Coefficients](@id man-numeric-literal-coefficients)
"""

# ╔═╡ 03c91178-9e19-11eb-318f-bf0235be4419
md"""
To make common numeric formulae and expressions clearer, Julia allows variables to be immediately preceded by a numeric literal, implying multiplication. This makes writing polynomial expressions much cleaner:
"""

# ╔═╡ 03c9160a-9e19-11eb-3f2f-819a3525280f
x = 3

# ╔═╡ 03c91614-9e19-11eb-1c40-1d7ca8279132
2x^2 - 3x + 1

# ╔═╡ 03c91614-9e19-11eb-1b11-27f1f05bdcba
1.5x^2 - .5x + 1

# ╔═╡ 03c91628-9e19-11eb-0726-2b16489020d3
md"""
It also makes writing exponential functions more elegant:
"""

# ╔═╡ 03c91720-9e19-11eb-00fd-a5daaed09dfa
2^2x

# ╔═╡ 03c9174a-9e19-11eb-17ae-db557d2c3dcf
md"""
The precedence of numeric literal coefficients is slightly lower than that of unary operators such as negation. So `-2x` is parsed as `(-2) * x` and `√2x` is parsed as `(√2) * x`. However, numeric literal coefficients parse similarly to unary operators when combined with exponentiation. For example `2^3x` is parsed as `2^(3x)`, and `2x^3` is parsed as `2*(x^3)`.
"""

# ╔═╡ 03c91752-9e19-11eb-2e5a-ed78a5cba99f
md"""
Numeric literals also work as coefficients to parenthesized expressions:
"""

# ╔═╡ 03c91a60-9e19-11eb-0bc6-8356457d7df6
2(x-1)^2 - 3(x-1) + 1

# ╔═╡ 03c91b14-9e19-11eb-03af-dbe84a1955aa
md"""
!!! note
    The precedence of numeric literal coefficients used for implicit multiplication is higher than other binary operators such as multiplication (`*`), and division (`/`, `\`, and `//`).  This means, for example, that `1 / 2im` equals `-0.5im` and `6 // 2(2 + 1)` equals `1 // 1`.
"""

# ╔═╡ 03c91b26-9e19-11eb-3277-35a52537b4e4
md"""
Additionally, parenthesized expressions can be used as coefficients to variables, implying multiplication of the expression by the variable:
"""

# ╔═╡ 03c91c8e-9e19-11eb-05fb-95c01d5e4729
(x-1)x

# ╔═╡ 03c91ca4-9e19-11eb-1693-cb012a8b3a79
md"""
Neither juxtaposition of two parenthesized expressions, nor placing a variable before a parenthesized expression, however, can be used to imply multiplication:
"""

# ╔═╡ 03c91fd8-9e19-11eb-06d9-073f86ddcc22
(x-1)(x+1)

# ╔═╡ 03c91fe2-9e19-11eb-3309-c17f668aad88
x(x+1)

# ╔═╡ 03c92000-9e19-11eb-2e32-e1d46a116406
md"""
Both expressions are interpreted as function application: any expression that is not a numeric literal, when immediately followed by a parenthetical, is interpreted as a function applied to the values in parentheses (see [Functions](@ref) for more about functions). Thus, in both of these cases, an error occurs since the left-hand value is not a function.
"""

# ╔═╡ 03c9201e-9e19-11eb-2a09-cbb1d797378e
md"""
The above syntactic enhancements significantly reduce the visual noise incurred when writing common mathematical formulae. Note that no whitespace may come between a numeric literal coefficient and the identifier or parenthesized expression which it multiplies.
"""

# ╔═╡ 03c92034-9e19-11eb-094c-f3af073aaf64
md"""
### Syntax Conflicts
"""

# ╔═╡ 03c92046-9e19-11eb-1c3e-e3079db00c74
md"""
Juxtaposed literal coefficient syntax may conflict with some numeric literal syntaxes: hexadecimal, octal and binary integer literals and engineering notation for floating-point literals. Here are some situations where syntactic conflicts arise:
"""

# ╔═╡ 03c920f8-9e19-11eb-3e67-791611f87a55
md"""
  * The hexadecimal integer literal expression `0xff` could be interpreted as the numeric literal `0` multiplied by the variable `xff`. Similar ambiguities arise with octal and binary literals like `0o777` or `0b01001010`.
  * The floating-point literal expression `1e10` could be interpreted as the numeric literal `1` multiplied by the variable `e10`, and similarly with the equivalent `E` form.
  * The 32-bit floating-point literal expression `1.5f22` could be interpreted as the numeric literal `1.5` multiplied by the variable `f22`.
"""

# ╔═╡ 03c9210e-9e19-11eb-3348-375c75730d61
md"""
In all cases the ambiguity is resolved in favor of interpretation as numeric literals:
"""

# ╔═╡ 03c92186-9e19-11eb-3bfe-c597ea4237a9
md"""
  * Expressions starting with `0x`/`0o`/`0b` are always hexadecimal/octal/binary literals.
  * Expressions starting with a numeric literal followed by `e` or `E` are always floating-point literals.
  * Expressions starting with a numeric literal followed by `f` are always 32-bit floating-point literals.
"""

# ╔═╡ 03c921ae-9e19-11eb-30a8-57deccebd8db
md"""
Unlike `E`, which is equivalent to `e` in numeric literals for historical reasons, `F` is just another letter and does not behave like `f` in numeric literals. Hence, expressions starting with a numeric literal followed by `F` are interpreted as the numerical literal multiplied by a variable, which means that, for example, `1.5F22` is equal to `1.5 * F22`.
"""

# ╔═╡ 03c921c2-9e19-11eb-3e22-dbfcd96ea9d0
md"""
## Literal zero and one
"""

# ╔═╡ 03c921d6-9e19-11eb-2722-e7d6c43979f1
md"""
Julia provides functions which return literal 0 and 1 corresponding to a specified type or the type of a given variable.
"""

# ╔═╡ 03c9226c-9e19-11eb-29d1-6d413be6b259
md"""
| Function          | Description                                      |
|:----------------- |:------------------------------------------------ |
| [`zero(x)`](@ref) | Literal zero of type `x` or type of variable `x` |
| [`one(x)`](@ref)  | Literal one of type `x` or type of variable `x`  |
"""

# ╔═╡ 03c92294-9e19-11eb-1adb-d1d5a9f8ef7c
md"""
These functions are useful in [Numeric Comparisons](@ref) to avoid overhead from unnecessary [type conversion](@ref conversion-and-promotion).
"""

# ╔═╡ 03c922a8-9e19-11eb-311b-ffa1b10a04dd
md"""
Examples:
"""

# ╔═╡ 03c925a2-9e19-11eb-1b5a-ef505d2db748
zero(Float32)

# ╔═╡ 03c925aa-9e19-11eb-1286-433bde5f4977
zero(1.0)

# ╔═╡ 03c925b4-9e19-11eb-170d-1b6ad9e17975
one(Int32)

# ╔═╡ 03c925b4-9e19-11eb-05c6-ef0c8717fa9b
one(BigFloat)

# ╔═╡ Cell order:
# ╟─03c89356-9e19-11eb-110e-5d62314dae11
# ╟─03c8937e-9e19-11eb-2dc8-2933e879d99a
# ╟─03c893b0-9e19-11eb-2dad-45d44831af19
# ╟─03c893c4-9e19-11eb-390e-fd154af71121
# ╟─03c89482-9e19-11eb-15fe-13092b450017
# ╟─03c89766-9e19-11eb-3841-c7bc5508ed5b
# ╟─03c897a2-9e19-11eb-39de-d15c16d1c9be
# ╟─03c89860-9e19-11eb-1c84-ab2124c5de69
# ╟─03c89888-9e19-11eb-3f5f-591d31d3f176
# ╟─03c898b2-9e19-11eb-3d57-91986bb6ec29
# ╟─03c898c4-9e19-11eb-1c18-f793d66ddced
# ╠═03c89af4-9e19-11eb-2708-1d7e815aa1d8
# ╠═03c89af4-9e19-11eb-1d67-d327a5689f00
# ╟─03c89b12-9e19-11eb-1c8f-79ca972eaac0
# ╠═03c89d38-9e19-11eb-39c4-89109f062b9f
# ╠═03c89d42-9e19-11eb-0c64-d93b0241bc59
# ╠═03c89d42-9e19-11eb-3980-eb83cd2948d7
# ╟─03c89d6a-9e19-11eb-0eec-793d87eb6438
# ╠═03c89efa-9e19-11eb-2000-51157f59d8fe
# ╠═03c89f04-9e19-11eb-173e-a7a56e31732d
# ╠═03c89f0e-9e19-11eb-0c7b-b192b8f52e53
# ╟─03c89f2c-9e19-11eb-3b6f-158ed6c95791
# ╠═03c8a102-9e19-11eb-0151-b157092744f7
# ╠═03c8a10c-9e19-11eb-353c-af130c4b6137
# ╠═03c8a116-9e19-11eb-3cdd-4b6c779db1e2
# ╠═03c8a116-9e19-11eb-3089-133e66a04b85
# ╠═03c8a11e-9e19-11eb-2f25-65c950fad35f
# ╟─03c8a134-9e19-11eb-0711-01fc72ee29a8
# ╠═03c8a26a-9e19-11eb-0c11-3bc73d0180b0
# ╠═03c8a26a-9e19-11eb-3396-4d7bcb680275
# ╟─03c8a292-9e19-11eb-0045-b5994961a83f
# ╠═03c8ab7a-9e19-11eb-3819-295674e24008
# ╠═03c8ab84-9e19-11eb-08bc-4b03b10d0087
# ╠═03c8ab8e-9e19-11eb-3164-27c83b75f13f
# ╠═03c8ab9a-9e19-11eb-2fe8-195271eae976
# ╠═03c8ab9a-9e19-11eb-2542-33f9eee1edfd
# ╠═03c8aba2-9e19-11eb-2007-577e00cccb76
# ╠═03c8abac-9e19-11eb-08c1-9b80af953723
# ╠═03c8abb6-9e19-11eb-284e-a718fd0c6733
# ╠═03c8abc0-9e19-11eb-02d6-1745a9173b79
# ╠═03c8abc0-9e19-11eb-3e13-7f9a76cd1eb3
# ╟─03c8abde-9e19-11eb-2993-bb9f149c8cbf
# ╟─03c8abf2-9e19-11eb-1f37-57ac38d9362d
# ╠═03c8b108-9e19-11eb-1d9b-f145e9352919
# ╠═03c8b110-9e19-11eb-18b2-affb42724b03
# ╠═03c8b110-9e19-11eb-3e97-77ab420bbc8d
# ╠═03c8b11a-9e19-11eb-3eca-bd3d3bd91af6
# ╠═03c8b124-9e19-11eb-3fe6-81ea3e66e281
# ╠═03c8b124-9e19-11eb-358d-d1758b872b5f
# ╟─03c8b142-9e19-11eb-2b55-e3629f3c5e83
# ╟─03c8b160-9e19-11eb-3fed-bd052b592dcc
# ╠═03c8b2be-9e19-11eb-381e-91ace6c70235
# ╠═03c8b2c8-9e19-11eb-1854-3b865221aa8a
# ╟─03c8b2f0-9e19-11eb-2c3c-614a77d97ae3
# ╠═03c8ba0a-9e19-11eb-232e-6f006badc0b9
# ╠═03c8ba0a-9e19-11eb-0c72-59fdd872dae5
# ╟─03c8ba48-9e19-11eb-27cd-ad1cf8529585
# ╟─03c8ba7a-9e19-11eb-26f9-df2f5d213388
# ╟─03c8ba8e-9e19-11eb-0f05-af49cca9612c
# ╠═03c8bdfe-9e19-11eb-3918-4b464b293465
# ╠═03c8be08-9e19-11eb-37d0-095585521f3c
# ╠═03c8be08-9e19-11eb-3b11-4940e13029bf
# ╟─03c8be30-9e19-11eb-1287-4976bb95dba2
# ╟─03c8be42-9e19-11eb-1839-e3322a3fe6b7
# ╠═03c8c060-9e19-11eb-32a1-bbb2cde7077a
# ╠═03c8c06a-9e19-11eb-076f-5f61a3a981ca
# ╟─03c8c080-9e19-11eb-3ed8-832164d0ead6
# ╟─03c8c0ae-9e19-11eb-053b-2fa1d05e5602
# ╟─03c8c0c4-9e19-11eb-1426-4b51099c2a60
# ╟─03c8c0d8-9e19-11eb-313b-f95d4f1ab659
# ╠═03c8c4de-9e19-11eb-14a0-7d8c862a091d
# ╠═03c8c4e6-9e19-11eb-0acf-e93e14d704c6
# ╠═03c8c4f2-9e19-11eb-217a-0b594098a5b8
# ╠═03c8c4f2-9e19-11eb-2a87-fdf6b6d088c5
# ╠═03c8c4fc-9e19-11eb-0a4f-09b29701a130
# ╠═03c8c4fc-9e19-11eb-2ee2-15423ce06236
# ╠═03c8c506-9e19-11eb-0eae-d3a4688a6790
# ╟─03c8c524-9e19-11eb-250b-4d2a2c6b7034
# ╠═03c8c7a4-9e19-11eb-0572-df1ebe567a18
# ╠═03c8c7ae-9e19-11eb-2c2e-95fc2feffd5d
# ╠═03c8c7b6-9e19-11eb-2ba8-611bb2d15b0c
# ╟─03c8c7cc-9e19-11eb-2933-3b6e8e7884aa
# ╠═03c8c9e8-9e19-11eb-02da-0bac89ac1894
# ╠═03c8c9f4-9e19-11eb-0bee-efd8550a205a
# ╟─03c8ca10-9e19-11eb-3ba1-6bb94d270d58
# ╠═03c8cd30-9e19-11eb-16e3-d15469c8cb3f
# ╠═03c8cd30-9e19-11eb-0368-d5e235033896
# ╠═03c8cd3a-9e19-11eb-1504-275385da8545
# ╠═03c8cd44-9e19-11eb-12a4-2373cdecd615
# ╟─03c8cd62-9e19-11eb-0386-f37660664d16
# ╠═03c8cfec-9e19-11eb-0588-118d76a079e0
# ╠═03c8cff4-9e19-11eb-3b72-31b0712223db
# ╟─03c8d00a-9e19-11eb-3d16-8f5051f2fd15
# ╠═03c8d26c-9e19-11eb-29f7-e59959f1d554
# ╟─03c8d280-9e19-11eb-11c3-91834c46e3a0
# ╟─03c8d2a8-9e19-11eb-20da-733622cdc163
# ╠═03c8d5dc-9e19-11eb-0509-275dbeeadc46
# ╠═03c8d5e6-9e19-11eb-1091-574f14eff022
# ╠═03c8d5e6-9e19-11eb-2c33-5f5333a4e1bf
# ╟─03c8d5fa-9e19-11eb-2753-2dc316989233
# ╟─03c8d60e-9e19-11eb-18d7-5d957f3b18ed
# ╟─03c8d6f4-9e19-11eb-21eb-47d99ed3426f
# ╟─03c8d71c-9e19-11eb-0681-2f589e1add9c
# ╠═03c8e004-9e19-11eb-39fe-a506bc085771
# ╠═03c8e010-9e19-11eb-39d5-17c693767904
# ╠═03c8e010-9e19-11eb-08d6-b5a188704cc3
# ╠═03c8e018-9e19-11eb-34e8-ef88e086fd66
# ╠═03c8e018-9e19-11eb-29a5-5f8900ae561c
# ╠═03c8e022-9e19-11eb-1b84-edb5b787c37e
# ╠═03c8e022-9e19-11eb-1f97-8ff196e53970
# ╠═03c8e02c-9e19-11eb-11c1-9725fe290908
# ╠═03c8e036-9e19-11eb-1b39-87bec5b1d678
# ╠═03c8e036-9e19-11eb-1cb7-33588e0a0b3d
# ╠═03c8e036-9e19-11eb-1924-51167f67a668
# ╠═03c8e03e-9e19-11eb-1031-4b8d4bebd79f
# ╟─03c8e05e-9e19-11eb-06dd-77b750c6fd18
# ╠═03c8e4dc-9e19-11eb-1f23-9138145a360a
# ╠═03c8e4e6-9e19-11eb-0592-11de2337d475
# ╠═03c8e4f0-9e19-11eb-15d8-57ddddb03c14
# ╟─03c8e4fa-9e19-11eb-2ae3-a9877ce6db48
# ╟─03c8e51a-9e19-11eb-01fd-b50609c89c8e
# ╟─03c8e536-9e19-11eb-0c1b-1f2f819300cb
# ╠═03c8e714-9e19-11eb-3008-73cf1b80682e
# ╠═03c8e714-9e19-11eb-07e9-973c37172bde
# ╠═03c8e720-9e19-11eb-0b13-4ddf373567ed
# ╟─03c8e752-9e19-11eb-3d45-93b7f38773e6
# ╠═03c8eaa4-9e19-11eb-190a-6f676301573c
# ╠═03c8eaa4-9e19-11eb-1265-bbee346c7b0d
# ╠═03c8eaae-9e19-11eb-1496-15dc7614d4dd
# ╠═03c8eaba-9e19-11eb-103e-276bb3978a1e
# ╟─03c8ead6-9e19-11eb-33c7-07f1e5945acf
# ╟─03c8eaf4-9e19-11eb-3c75-27733aa8bc71
# ╠═03c8efe0-9e19-11eb-0f8b-5760a280de54
# ╠═03c8efea-9e19-11eb-0720-dd8d189f76b2
# ╠═03c8eff4-9e19-11eb-151c-e58eb11c9eef
# ╠═03c8eff4-9e19-11eb-0b38-71a09b8b5af5
# ╠═03c8effe-9e19-11eb-382b-113c3a43e4bd
# ╠═03c8effe-9e19-11eb-3d55-4705037881f5
# ╟─03c8f012-9e19-11eb-100d-fb1ce7b709ce
# ╟─03c8f028-9e19-11eb-239e-e5438c5db8df
# ╟─03c8f03a-9e19-11eb-0846-b5ecccaf82bf
# ╟─03c8f05a-9e19-11eb-245f-2f5472da1866
# ╟─03c8f062-9e19-11eb-1aa8-b782011f95e6
# ╟─03c8f076-9e19-11eb-20f3-79f0edd22fe8
# ╟─03c8f1fc-9e19-11eb-147e-2d893bbbda30
# ╟─03c8f210-9e19-11eb-1ab7-018ed5f85d62
# ╟─03c8f238-9e19-11eb-1139-7da9243e4abd
# ╟─03c8f26a-9e19-11eb-3e91-d76afc701860
# ╟─03c8f288-9e19-11eb-379d-216768005141
# ╠═03c902dc-9e19-11eb-39ab-3f5298ef59cc
# ╠═03c902dc-9e19-11eb-3d55-3d63c32d0ee2
# ╠═03c902e6-9e19-11eb-2d66-157a69a45102
# ╠═03c902e6-9e19-11eb-362e-87ea2434c10e
# ╠═03c902f0-9e19-11eb-1a75-fdf61242e6c2
# ╠═03c902fa-9e19-11eb-0cfa-4fda137cfc0c
# ╠═03c902fa-9e19-11eb-1018-0362c301537c
# ╠═03c90304-9e19-11eb-3abb-11ba3796ebc4
# ╠═03c90304-9e19-11eb-047b-e91d8bbcd295
# ╠═03c9030e-9e19-11eb-2b9b-458a3a9c20dc
# ╠═03c9030e-9e19-11eb-09b4-655edfd7edc1
# ╟─03c90336-9e19-11eb-173f-8555a0b5805f
# ╠═03c908f4-9e19-11eb-18af-8939d7217126
# ╠═03c908fe-9e19-11eb-162b-a9b54c6ac13a
# ╠═03c908fe-9e19-11eb-0f81-6d3098225cbc
# ╠═03c90908-9e19-11eb-13cd-a51835a955de
# ╠═03c90908-9e19-11eb-0dc4-91c3025fe1b0
# ╠═03c90914-9e19-11eb-3069-9f5727411fc3
# ╟─03c9094e-9e19-11eb-0250-c1a8292d2c91
# ╠═03c9113c-9e19-11eb-3a8b-f53a1fe2919b
# ╠═03c9113c-9e19-11eb-110e-7179186c1956
# ╠═03c91146-9e19-11eb-164a-9747a27defbf
# ╟─03c91164-9e19-11eb-00bd-7f7ef6bab78a
# ╟─03c91178-9e19-11eb-318f-bf0235be4419
# ╠═03c9160a-9e19-11eb-3f2f-819a3525280f
# ╠═03c91614-9e19-11eb-1c40-1d7ca8279132
# ╠═03c91614-9e19-11eb-1b11-27f1f05bdcba
# ╟─03c91628-9e19-11eb-0726-2b16489020d3
# ╠═03c91720-9e19-11eb-00fd-a5daaed09dfa
# ╟─03c9174a-9e19-11eb-17ae-db557d2c3dcf
# ╟─03c91752-9e19-11eb-2e5a-ed78a5cba99f
# ╠═03c91a60-9e19-11eb-0bc6-8356457d7df6
# ╟─03c91b14-9e19-11eb-03af-dbe84a1955aa
# ╟─03c91b26-9e19-11eb-3277-35a52537b4e4
# ╠═03c91c8e-9e19-11eb-05fb-95c01d5e4729
# ╟─03c91ca4-9e19-11eb-1693-cb012a8b3a79
# ╠═03c91fd8-9e19-11eb-06d9-073f86ddcc22
# ╠═03c91fe2-9e19-11eb-3309-c17f668aad88
# ╟─03c92000-9e19-11eb-2e32-e1d46a116406
# ╟─03c9201e-9e19-11eb-2a09-cbb1d797378e
# ╟─03c92034-9e19-11eb-094c-f3af073aaf64
# ╟─03c92046-9e19-11eb-1c3e-e3079db00c74
# ╟─03c920f8-9e19-11eb-3e67-791611f87a55
# ╟─03c9210e-9e19-11eb-3348-375c75730d61
# ╟─03c92186-9e19-11eb-3bfe-c597ea4237a9
# ╟─03c921ae-9e19-11eb-30a8-57deccebd8db
# ╟─03c921c2-9e19-11eb-3e22-dbfcd96ea9d0
# ╟─03c921d6-9e19-11eb-2722-e7d6c43979f1
# ╟─03c9226c-9e19-11eb-29d1-6d413be6b259
# ╟─03c92294-9e19-11eb-1adb-d1d5a9f8ef7c
# ╟─03c922a8-9e19-11eb-311b-ffa1b10a04dd
# ╠═03c925a2-9e19-11eb-1b5a-ef505d2db748
# ╠═03c925aa-9e19-11eb-1286-433bde5f4977
# ╠═03c925b4-9e19-11eb-170d-1b6ad9e17975
# ╠═03c925b4-9e19-11eb-05c6-ef0c8717fa9b
