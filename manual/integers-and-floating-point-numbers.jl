### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ ffbc9a17-ece1-4219-974e-f97db5d47d6a
md"""
# Integers and Floating-Point Numbers
"""

# ╔═╡ 24c9c004-0617-495b-baa7-c9161e4a96b6
md"""
Integers and floating-point values are the basic building blocks of arithmetic and computation. Built-in representations of such values are called numeric primitives, while representations of integers and floating-point numbers as immediate values in code are known as numeric literals. For example, `1` is an integer literal, while `1.0` is a floating-point literal; their binary in-memory representations as objects are numeric primitives.
"""

# ╔═╡ 23a0c9af-53c6-4b7d-9e31-e90eb017af7f
md"""
Julia provides a broad range of primitive numeric types, and a full complement of arithmetic and bitwise operators as well as standard mathematical functions are defined over them. These map directly onto numeric types and operations that are natively supported on modern computers, thus allowing Julia to take full advantage of computational resources. Additionally, Julia provides software support for [Arbitrary Precision Arithmetic](@ref), which can handle operations on numeric values that cannot be represented effectively in native hardware representations, but at the cost of relatively slower performance.
"""

# ╔═╡ 4c127fc5-79cb-4965-9ea0-158278102aec
md"""
The following are Julia's primitive numeric types:
"""

# ╔═╡ 22b43ec8-1244-4813-a761-582b2ee41e8c
md"""
  * **Integer types:**
"""

# ╔═╡ d16e8eb5-0071-4a1a-9d0d-60d3f0b9a525
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

# ╔═╡ 04f43bff-1cc7-4c11-87e4-7695aa9a9fb5
md"""
  * **Floating-point types:**
"""

# ╔═╡ 9911acda-cea7-4f97-9661-b4f125583792
md"""
| Type              | Precision                                                                      | Number of bits |
|:----------------- |:------------------------------------------------------------------------------ |:-------------- |
| [`Float16`](@ref) | [half](https://en.wikipedia.org/wiki/Half-precision_floating-point_format)     | 16             |
| [`Float32`](@ref) | [single](https://en.wikipedia.org/wiki/Single_precision_floating-point_format) | 32             |
| [`Float64`](@ref) | [double](https://en.wikipedia.org/wiki/Double_precision_floating-point_format) | 64             |
"""

# ╔═╡ 9fe1626e-9cd8-46df-8fe2-f103af55f53c
md"""
Additionally, full support for [Complex and Rational Numbers](@ref) is built on top of these primitive numeric types. All numeric types interoperate naturally without explicit casting, thanks to a flexible, user-extensible [type promotion system](@ref conversion-and-promotion).
"""

# ╔═╡ 31d0a577-2e54-4351-bdc2-ec417291a3ac
md"""
## Integers
"""

# ╔═╡ 158be076-5bd4-450c-b632-013f301f78ce
md"""
Literal integers are represented in the standard manner:
"""

# ╔═╡ 6900dab3-dedc-4d76-99d6-b8dd31d58e51
1

# ╔═╡ 5e105ca4-6632-43fc-84b9-3258bc04ff0a
1234

# ╔═╡ 1f21067c-62fb-4e29-a4b3-08ef6610886c
md"""
The default type for an integer literal depends on whether the target system has a 32-bit architecture or a 64-bit architecture:
"""

# ╔═╡ f2ce9662-da3a-40e8-ae48-9e3794d6c65f
# 32-bit system:

# ╔═╡ 7593690b-63f2-4ab9-8733-dedbc55df333
typeof(1)

# ╔═╡ 34c6c269-5f91-4307-b853-30f0264e5ee4
typeof(1)

# ╔═╡ 455a27be-cd94-491b-8d8e-f9dcf9dca899
md"""
The Julia internal variable [`Sys.WORD_SIZE`](@ref) indicates whether the target system is 32-bit or 64-bit:
"""

# ╔═╡ 1f61c6cd-3a1c-4ded-b40a-04e0896689a2
# 32-bit system:

# ╔═╡ 249d5fb0-29ca-4137-bfde-0eca649cb196
Sys.WORD_SIZE

# ╔═╡ 56952014-4eb6-45c0-a94f-681e889fdea3
Sys.WORD_SIZE

# ╔═╡ 57542111-06b1-41ef-ac5e-822af6428c5c
md"""
Julia also defines the types `Int` and `UInt`, which are aliases for the system's signed and unsigned native integer types respectively:
"""

# ╔═╡ c8ef69a6-bb4a-4925-8c93-f0be33c4dc6f
# 32-bit system:

# ╔═╡ 5a140e84-ff46-468c-a813-2c2079f5d784
Int

# ╔═╡ edbfd7f4-8843-414a-8656-ec01951fd4f6
UInt

# ╔═╡ cc66bee2-ce63-4d7b-b761-bdd27acf80cd
Int

# ╔═╡ dfb5c7b3-7f13-446b-a581-b7524a9c041c
UInt

# ╔═╡ 2beeaa76-9f58-4914-8cc1-3569d1a2991a
md"""
Larger integer literals that cannot be represented using only 32 bits but can be represented in 64 bits always create 64-bit integers, regardless of the system type:
"""

# ╔═╡ 174b28fc-5936-4e83-b820-2f32f48b6c8d
# 32-bit or 64-bit system:

# ╔═╡ 3461d9c1-7fc0-4132-8b39-189175363895
typeof(3000000000)

# ╔═╡ e7092bc0-a1f4-4d15-ac86-219abf860f49
md"""
Unsigned integers are input and output using the `0x` prefix and hexadecimal (base 16) digits `0-9a-f` (the capitalized digits `A-F` also work for input). The size of the unsigned value is determined by the number of hex digits used:
"""

# ╔═╡ b26d4539-f6f1-47f7-a271-3dd868264a4f
x = 0x1

# ╔═╡ af46e2ce-c371-4edb-8832-0e7626f5cd3a
typeof(x)

# ╔═╡ 751537b8-4012-4f77-9073-f748ca642438
x = 0x123

# ╔═╡ 074ab82f-249b-4200-8460-673fd9918358
typeof(x)

# ╔═╡ fdf944aa-acb5-4305-ac92-7a7dea2da437
x = 0x1234567

# ╔═╡ 60c8d728-9ac0-43ed-8d26-53e948db93f0
typeof(x)

# ╔═╡ 160d0f04-c980-4e90-97fb-f13d354e3452
x = 0x123456789abcdef

# ╔═╡ 2502e061-8d31-4a33-a63c-787765b47b59
typeof(x)

# ╔═╡ c8c63d31-c2ab-465a-8104-1f79f2aae75c
x = 0x11112222333344445555666677778888

# ╔═╡ a36e6987-df41-4fe4-a05b-82c62e8d9db2
typeof(x)

# ╔═╡ 87a9cab8-357e-49e7-889b-c78adf1f0666
md"""
This behavior is based on the observation that when one uses unsigned hex literals for integer values, one typically is using them to represent a fixed numeric byte sequence, rather than just an integer value.
"""

# ╔═╡ e38bac82-f1df-4f45-b1f3-85390ea92b34
md"""
Binary and octal literals are also supported:
"""

# ╔═╡ 0a6eca0a-64e4-4dc5-8d04-5ae1c397602c
x = 0b10

# ╔═╡ f8ffa2c8-ce43-4231-adeb-c369519fd795
typeof(x)

# ╔═╡ 61e8b82f-14a7-4eb5-a8bc-fbc1173a395d
x = 0o010

# ╔═╡ 14486ee5-5d69-4867-b5e8-41de610cce66
typeof(x)

# ╔═╡ e40d03ff-9195-4480-b142-27ce9e27cc3e
x = 0x00000000000000001111222233334444

# ╔═╡ f47a6f6a-e1b1-4dc0-9004-56a968f0162a
typeof(x)

# ╔═╡ 9c1f4cf6-2139-4113-8de1-620a1e4bb59d
md"""
As for hexadecimal literals, binary and octal literals produce unsigned integer types. The size of the binary data item is the minimal needed size, if the leading digit of the literal is not `0`. In the case of leading zeros, the size is determined by the minimal needed size for a literal, which has the same length but leading digit `1`. That allows the user to control the size. Values which cannot be stored in `UInt128` cannot be written as such literals.
"""

# ╔═╡ 9d2491d6-168a-4823-a214-2a1a5aaa26d8
md"""
Binary, octal, and hexadecimal literals may be signed by a `-` immediately preceding the unsigned literal. They produce an unsigned integer of the same size as the unsigned literal would do, with the two's complement of the value:
"""

# ╔═╡ 1575d04a-f9bd-4972-949b-f67ba7d7f3cb
-0x2

# ╔═╡ bb55b346-0144-4635-9e06-e18916024630
-0x0002

# ╔═╡ 5b09f10d-9359-4ec7-991f-d54c71ef5390
md"""
The minimum and maximum representable values of primitive numeric types such as integers are given by the [`typemin`](@ref) and [`typemax`](@ref) functions:
"""

# ╔═╡ 997a2990-81f9-44a2-a7d2-f2474868ae1c
(typemin(Int32), typemax(Int32))

# ╔═╡ ff2b82b5-ca1c-4cb5-831c-439e44e3a04f
for T in [Int8,Int16,Int32,Int64,Int128,UInt8,UInt16,UInt32,UInt64,UInt128]
     println("$(lpad(T,7)): [$(typemin(T)),$(typemax(T))]")
 end

# ╔═╡ 07990599-1d3f-4737-ae7e-d02580502b60
md"""
The values returned by [`typemin`](@ref) and [`typemax`](@ref) are always of the given argument type. (The above expression uses several features that have yet to be introduced, including [for loops](@ref man-loops), [Strings](@ref man-strings), and [Interpolation](@ref string-interpolation), but should be easy enough to understand for users with some existing programming experience.)
"""

# ╔═╡ f288ac6a-9e4f-4b6a-9e4f-c351acc9fa53
md"""
### Overflow behavior
"""

# ╔═╡ ff676447-46a2-4701-94c0-bb81fa4d29eb
md"""
In Julia, exceeding the maximum representable value of a given type results in a wraparound behavior:
"""

# ╔═╡ 8133e27b-3a18-4bbe-b26c-82436ccc6f09
x = typemax(Int64)

# ╔═╡ 53c10a97-3cf0-48d8-8fc7-3438b49bb181
x + 1

# ╔═╡ a2fa705c-1723-4454-b368-80eb5f6389a9
x + 1 == typemin(Int64)

# ╔═╡ bd7305e5-9d9f-4b7a-8e09-9db3635be348
md"""
Thus, arithmetic with Julia integers is actually a form of [modular arithmetic](https://en.wikipedia.org/wiki/Modular_arithmetic). This reflects the characteristics of the underlying arithmetic of integers as implemented on modern computers. In applications where overflow is possible, explicit checking for wraparound produced by overflow is essential; otherwise, the [`BigInt`](@ref) type in [Arbitrary Precision Arithmetic](@ref) is recommended instead.
"""

# ╔═╡ 8fe9d749-1a47-4628-b1f9-f8634ace43a4
md"""
An example of overflow behavior and how to potentially resolve it is as follows:
"""

# ╔═╡ a6aad170-f268-4947-8b68-4306b15dc536
10^19

# ╔═╡ 54e158d5-93f3-4a07-86fd-f589f556fb78
big(10)^19

# ╔═╡ 72bfd10e-263e-4c0d-a4fc-26e6fefda7c3
md"""
### Division errors
"""

# ╔═╡ 733ad076-ebf4-4999-b139-56d0f4926e02
md"""
Integer division (the `div` function) has two exceptional cases: dividing by zero, and dividing the lowest negative number ([`typemin`](@ref)) by -1. Both of these cases throw a [`DivideError`](@ref). The remainder and modulus functions (`rem` and `mod`) throw a [`DivideError`](@ref) when their second argument is zero.
"""

# ╔═╡ 5e460aef-3d66-413d-996b-751908bcc770
md"""
## Floating-Point Numbers
"""

# ╔═╡ dd25dfea-9b03-4369-820e-5f46bb27d314
md"""
Literal floating-point numbers are represented in the standard formats, using [E-notation](https://en.wikipedia.org/wiki/Scientific_notation#E_notation) when necessary:
"""

# ╔═╡ e74919fe-2318-43ab-a336-db582b2f8fea
1.0

# ╔═╡ 1813abd8-5e7e-4f20-894d-2fc22659b638
1.

# ╔═╡ 7a46fb4d-9495-4ad5-83e4-277cde190ad5
0.5

# ╔═╡ 9a7bd230-939b-40b4-9652-910265aeedb8
.5

# ╔═╡ fbcca441-ed1f-44ea-9157-91c47104b747
-1.23

# ╔═╡ 2f08dcf1-20d7-4e2f-8a8e-1f88b5989947
1e10

# ╔═╡ eadae5a0-41b6-43d4-bd6f-ed838fd4d014
2.5e-4

# ╔═╡ 8c1c281f-432d-446c-b785-4b7e097028da
md"""
The above results are all [`Float64`](@ref) values. Literal [`Float32`](@ref) values can be entered by writing an `f` in place of `e`:
"""

# ╔═╡ a6ba5db3-f077-4076-a314-3d9b1e6cc371
x = 0.5f0

# ╔═╡ cd7640ad-71f6-4c86-badd-c7b0b0f63e00
typeof(x)

# ╔═╡ d9f6bec2-5c0b-4641-a553-ea658513fd38
2.5f-4

# ╔═╡ 8f0b0155-70ec-4c83-9565-19631b1af844
md"""
Values can be converted to [`Float32`](@ref) easily:
"""

# ╔═╡ 0d301202-af6f-403a-9518-fbbe2842f7c2
x = Float32(-1.5)

# ╔═╡ d4fd5544-0fce-4859-8c83-868d570c426f
typeof(x)

# ╔═╡ b1b3df3d-57eb-4d1c-bbe3-ec2c6ca96fd2
md"""
Hexadecimal floating-point literals are also valid, but only as [`Float64`](@ref) values, with `p` preceding the base-2 exponent:
"""

# ╔═╡ f62410e9-e759-49f5-89de-680bea97c7a6
0x1p0

# ╔═╡ ea9dcbde-c0b1-4bb4-96e3-f6d95fdd206f
0x1.8p3

# ╔═╡ 34fbe369-d92a-4405-a6a3-f953bfce4f6d
x = 0x.4p-1

# ╔═╡ 98509499-03a5-4cef-80ba-5a83a0bc88e3
typeof(x)

# ╔═╡ 72c7f034-e928-487d-8ca5-692229cd8520
md"""
Half-precision floating-point numbers are also supported ([`Float16`](@ref)), but they are implemented in software and use [`Float32`](@ref) for calculations.
"""

# ╔═╡ f3c0f2a1-a12c-4304-9f64-85e3264d9a0c
sizeof(Float16(4.))

# ╔═╡ 8106dd39-9907-4fc3-b967-30333ae0fc1b
2*Float16(4.)

# ╔═╡ 9e5c0a9d-12ef-44c5-9002-1ba0cd8f3e14
md"""
The underscore `_` can be used as digit separator:
"""

# ╔═╡ e52fdd5d-cf85-4a18-ac82-3d8e54fc77a9
10_000, 0.000_000_005, 0xdead_beef, 0b1011_0010

# ╔═╡ d5c57515-36d1-4e3e-aeef-865264bf3792
md"""
### Floating-point zero
"""

# ╔═╡ 59ded7e0-f51e-46ff-b929-6be82822bb42
md"""
Floating-point numbers have [two zeros](https://en.wikipedia.org/wiki/Signed_zero), positive zero and negative zero. They are equal to each other but have different binary representations, as can be seen using the [`bitstring`](@ref) function:
"""

# ╔═╡ 4123d0bc-593e-4c3b-9cdf-f3c4e005be75
0.0 == -0.0

# ╔═╡ 311873db-1018-45e7-a711-26ac7bd5d813
bitstring(0.0)

# ╔═╡ cf98b451-8ce3-49e6-a5c3-cc33986e7bc1
bitstring(-0.0)

# ╔═╡ 9ef725de-164d-482b-a435-80becbbf291f
md"""
### Special floating-point values
"""

# ╔═╡ e6653102-8eec-4fef-9072-9ffdea566b74
md"""
There are three specified standard floating-point values that do not correspond to any point on the real number line:
"""

# ╔═╡ 7cf35ff3-2c15-41a8-8b95-6eb5372820a5
md"""
| `Float16` | `Float32` | `Float64` | Name              | Description                                                     |
|:--------- |:--------- |:--------- |:----------------- |:--------------------------------------------------------------- |
| `Inf16`   | `Inf32`   | `Inf`     | positive infinity | a value greater than all finite floating-point values           |
| `-Inf16`  | `-Inf32`  | `-Inf`    | negative infinity | a value less than all finite floating-point values              |
| `NaN16`   | `NaN32`   | `NaN`     | not a number      | a value not `==` to any floating-point value (including itself) |
"""

# ╔═╡ bf659ae4-b529-40c6-965c-0e90a916c57d
md"""
For further discussion of how these non-finite floating-point values are ordered with respect to each other and other floats, see [Numeric Comparisons](@ref). By the [IEEE 754 standard](https://en.wikipedia.org/wiki/IEEE_754-2008), these floating-point values are the results of certain arithmetic operations:
"""

# ╔═╡ 186093a2-7455-4e50-8b43-a2822dc73ac8
1/Inf

# ╔═╡ b6c8c439-5b57-4d74-8bc5-c6a2e64856be
1/0

# ╔═╡ 99cf8ac5-6e34-41ec-8ec8-a413be8af8c4
-5/0

# ╔═╡ 2a53da3f-4ebb-4dfc-a0b2-f1ce91ba8e79
0.000001/0

# ╔═╡ 67bf0ac6-a126-43ff-bf0d-9a33b94dcb4a
0/0

# ╔═╡ 7d6b6026-9898-45a5-adcb-8fef9c7f1e49
500 + Inf

# ╔═╡ 37c6ba94-86eb-4359-bbd9-9362509b45ac
500 - Inf

# ╔═╡ 1444c5fa-246d-481c-8850-d32e1c2e27f2
Inf + Inf

# ╔═╡ 5917e5d7-0f5f-465f-b05c-d53624360d5c
Inf - Inf

# ╔═╡ 75ac5b4c-a7a2-486f-b0a3-e8e24cbe4ad2
Inf * Inf

# ╔═╡ 3a7c6fc7-22bc-4749-aa1d-5d549e855a7c
Inf / Inf

# ╔═╡ 6a92fa0f-f785-48ef-9c99-d2a957a71e60
0 * Inf

# ╔═╡ d91908a7-92dc-4582-8f62-e16061985a6d
md"""
The [`typemin`](@ref) and [`typemax`](@ref) functions also apply to floating-point types:
"""

# ╔═╡ 9646ff1e-37dd-4cdc-bc3c-43914bbd6c44
(typemin(Float16),typemax(Float16))

# ╔═╡ f4723495-a218-4acf-9a43-afef3e96364f
(typemin(Float32),typemax(Float32))

# ╔═╡ 17ad0ea9-cbbd-4ff3-b553-53066d1b18d7
(typemin(Float64),typemax(Float64))

# ╔═╡ 24810b80-ca64-4d5f-bf40-d79b570b6950
md"""
### Machine epsilon
"""

# ╔═╡ 564e20e9-8531-4fe2-b1fd-c9da9914b565
md"""
Most real numbers cannot be represented exactly with floating-point numbers, and so for many purposes it is important to know the distance between two adjacent representable floating-point numbers, which is often known as [machine epsilon](https://en.wikipedia.org/wiki/Machine_epsilon).
"""

# ╔═╡ eb97ab89-74e7-4f31-8c85-8b196f109c26
md"""
Julia provides [`eps`](@ref), which gives the distance between `1.0` and the next larger representable floating-point value:
"""

# ╔═╡ 8d1f62e1-f127-4392-a82b-57d8fe1df16b
eps(Float32)

# ╔═╡ b2f694c7-9f2d-4680-9ec5-98f393f7487f
eps(Float64)

# ╔═╡ 3443afb0-6076-414e-8af7-72d01d2eb8ab
eps() # same as eps(Float64)

# ╔═╡ 0e6a019e-2c73-4429-aaca-ad6fbec9416a
md"""
These values are `2.0^-23` and `2.0^-52` as [`Float32`](@ref) and [`Float64`](@ref) values, respectively. The [`eps`](@ref) function can also take a floating-point value as an argument, and gives the absolute difference between that value and the next representable floating point value. That is, `eps(x)` yields a value of the same type as `x` such that `x + eps(x)` is the next representable floating-point value larger than `x`:
"""

# ╔═╡ fab62b9f-f6a0-4dab-bf71-885522131820
eps(1.0)

# ╔═╡ a1fcfc9b-e4c4-4ba3-a887-dffe70be3160
eps(1000.)

# ╔═╡ 11c40da4-8345-41fc-9782-43ecb812ed2b
eps(1e-27)

# ╔═╡ 339374a3-3e43-493a-bacf-229464a656e9
eps(0.0)

# ╔═╡ 05546f70-6f33-439d-9b86-8087ce7bccdb
md"""
The distance between two adjacent representable floating-point numbers is not constant, but is smaller for smaller values and larger for larger values. In other words, the representable floating-point numbers are densest in the real number line near zero, and grow sparser exponentially as one moves farther away from zero. By definition, `eps(1.0)` is the same as `eps(Float64)` since `1.0` is a 64-bit floating-point value.
"""

# ╔═╡ ea29a18b-e74c-49fb-b534-870cf3b9de8c
md"""
Julia also provides the [`nextfloat`](@ref) and [`prevfloat`](@ref) functions which return the next largest or smallest representable floating-point number to the argument respectively:
"""

# ╔═╡ 0c70c4e2-3432-4089-b641-eb06bc0fb2a1
x = 1.25f0

# ╔═╡ f17dd1ad-41d7-4c61-b390-4ca8cee61e31
nextfloat(x)

# ╔═╡ 420f8b13-a4d5-47ee-81c1-da9fa69fc4dd
prevfloat(x)

# ╔═╡ b5869cce-0fb6-4579-a9f4-0c5f0ff2bd53
bitstring(prevfloat(x))

# ╔═╡ 8c03c2cd-41de-4433-bcaa-eade1527fe3d
bitstring(x)

# ╔═╡ b319085b-6e9a-431e-ba97-3465c339c927
bitstring(nextfloat(x))

# ╔═╡ 4ff33a88-8513-432c-b5fe-7d4a7c993e42
md"""
This example highlights the general principle that the adjacent representable floating-point numbers also have adjacent binary integer representations.
"""

# ╔═╡ 2eeac7ae-18eb-4f9f-872a-0befecf1158e
md"""
### Rounding modes
"""

# ╔═╡ 783f7cf3-f3dd-4af1-a3fd-9e0e35824701
md"""
If a number doesn't have an exact floating-point representation, it must be rounded to an appropriate representable value. However, the manner in which this rounding is done can be changed if required according to the rounding modes presented in the [IEEE 754 standard](https://en.wikipedia.org/wiki/IEEE_754-2008).
"""

# ╔═╡ b23d4765-5449-4284-98d7-fd2d69feaf77
md"""
The default mode used is always [`RoundNearest`](@ref), which rounds to the nearest representable value, with ties rounded towards the nearest value with an even least significant bit.
"""

# ╔═╡ 31ea45b4-8afd-42f3-bca3-cf088c5426a5
md"""
### Background and References
"""

# ╔═╡ ad6ea342-82d6-4626-b020-a41fb873d259
md"""
Floating-point arithmetic entails many subtleties which can be surprising to users who are unfamiliar with the low-level implementation details. However, these subtleties are described in detail in most books on scientific computation, and also in the following references:
"""

# ╔═╡ ba911167-d56d-472f-a56c-3e2aec4211cd
md"""
  * The definitive guide to floating point arithmetic is the [IEEE 754-2008 Standard](https://standards.ieee.org/standard/754-2008.html); however, it is not available for free online.
  * For a brief but lucid presentation of how floating-point numbers are represented, see John D. Cook's [article](https://www.johndcook.com/blog/2009/04/06/anatomy-of-a-floating-point-number/) on the subject as well as his [introduction](https://www.johndcook.com/blog/2009/04/06/numbers-are-a-leaky-abstraction/) to some of the issues arising from how this representation differs in behavior from the idealized abstraction of real numbers.
  * Also recommended is Bruce Dawson's [series of blog posts on floating-point numbers](https://randomascii.wordpress.com/2012/05/20/thats-not-normalthe-performance-of-odd-floats/).
  * For an excellent, in-depth discussion of floating-point numbers and issues of numerical accuracy encountered when computing with them, see David Goldberg's paper [What Every Computer Scientist Should Know About Floating-Point Arithmetic](http://citeseerx.ist.psu.edu/viewdoc/download?doi=10.1.1.22.6768&rep=rep1&type=pdf).
  * For even more extensive documentation of the history of, rationale for, and issues with floating-point numbers, as well as discussion of many other topics in numerical computing, see the [collected writings](https://people.eecs.berkeley.edu/~wkahan/) of [William Kahan](https://en.wikipedia.org/wiki/William_Kahan), commonly known as the \"Father of Floating-Point\". Of particular interest may be [An Interview with the Old Man of Floating-Point](https://people.eecs.berkeley.edu/~wkahan/ieee754status/754story.html).
"""

# ╔═╡ 508f49d7-b0c6-4a3e-ba04-d756244b5df3
md"""
## Arbitrary Precision Arithmetic
"""

# ╔═╡ b3201be1-6c8e-4c05-b24e-cbf0c512bc9c
md"""
To allow computations with arbitrary-precision integers and floating point numbers, Julia wraps the [GNU Multiple Precision Arithmetic Library (GMP)](https://gmplib.org) and the [GNU MPFR Library](https://www.mpfr.org), respectively. The [`BigInt`](@ref) and [`BigFloat`](@ref) types are available in Julia for arbitrary precision integer and floating point numbers respectively.
"""

# ╔═╡ 2e0f2d5c-b337-4567-a934-4360ce35c1e7
md"""
Constructors exist to create these types from primitive numerical types, and the [string literal](@ref non-standard-string-literals) [`@big_str`](@ref) or [`parse`](@ref) can be used to construct them from `AbstractString`s. `BigInt`s can also be input as integer literals when they are too big for other built-in integer types. Note that as there is no unsigned arbitrary-precision integer type in `Base` (`BigInt` is sufficient in most cases), hexadecimal, octal and binary literals can be used (in addition to decimal literals).
"""

# ╔═╡ 7be5c9ec-10c5-4bec-a81b-370db1d121ba
md"""
Once created, they participate in arithmetic with all other numeric types thanks to Julia's [type promotion and conversion mechanism](@ref conversion-and-promotion):
"""

# ╔═╡ c175e004-a515-41b2-b5fa-671b6204941d
BigInt(typemax(Int64)) + 1

# ╔═╡ 06719ebe-e725-4f16-8516-98f99d787e8b
big"123456789012345678901234567890" + 1

# ╔═╡ 193e8714-3d6e-4053-8e5e-c7d03b85bfd1
parse(BigInt, "123456789012345678901234567890") + 1

# ╔═╡ 6e429ce7-7976-41af-aee7-387433d10f44
string(big"2"^200, base=16)

# ╔═╡ 5e3380aa-7a6f-4218-a141-aa740acaab18
0x100000000000000000000000000000000-1 == typemax(UInt128)

# ╔═╡ 02747cd8-1f87-4663-aa6f-af93007e4802
0x000000000000000000000000000000000

# ╔═╡ db69a9e4-cdab-49dd-9438-93ef03951964
typeof(ans)

# ╔═╡ f4f4996c-1a81-4b18-8150-a7d9780a2dca
big"1.23456789012345678901"

# ╔═╡ 8462a359-d17e-48c9-b255-09cfa5bb4381
parse(BigFloat, "1.23456789012345678901")

# ╔═╡ 4b58f95f-8a22-41ab-963d-8984e8bc69c5
BigFloat(2.0^66) / 3

# ╔═╡ 1e91ece9-8feb-4d57-ab1f-ee82080004ce
factorial(BigInt(40))

# ╔═╡ 9e2ee5f6-362f-4033-8e9a-a5dd908eff34
md"""
However, type promotion between the primitive types above and [`BigInt`](@ref)/[`BigFloat`](@ref) is not automatic and must be explicitly stated.
"""

# ╔═╡ 0eb6adfc-c162-4d22-be87-004f88f36a58
x = typemin(Int64)

# ╔═╡ 3ec6da78-ac08-4b63-b7a1-274244062593
x = x - 1

# ╔═╡ b02df6ec-d665-4d0b-a887-e7c84de6f4b2
typeof(x)

# ╔═╡ f5f20738-37d6-4137-a3e1-39fffe4923ba
y = BigInt(typemin(Int64))

# ╔═╡ 28f62e38-2d98-40bd-b6f1-0961d79006c3
y = y - 1

# ╔═╡ 92c3c644-bbd8-4978-a760-aef9bfdee01a
typeof(y)

# ╔═╡ 60920413-5229-4cd9-91d6-aaa380114574
md"""
The default precision (in number of bits of the significand) and rounding mode of [`BigFloat`](@ref) operations can be changed globally by calling [`setprecision`](@ref) and [`setrounding`](@ref), and all further calculations will take these changes in account.  Alternatively, the precision or the rounding can be changed only within the execution of a particular block of code by using the same functions with a `do` block:
"""

# ╔═╡ 4527b8d6-2fb5-41bd-8aab-5e74be5bdb7c
setrounding(BigFloat, RoundUp) do
     BigFloat(1) + parse(BigFloat, "0.1")
 end

# ╔═╡ 7daf4ffe-721d-400b-8756-4130d91fee24
setrounding(BigFloat, RoundDown) do
     BigFloat(1) + parse(BigFloat, "0.1")
 end

# ╔═╡ cb5ddd54-b502-43ab-a33d-f15482205f46
setprecision(40) do
     BigFloat(1) + parse(BigFloat, "0.1")
 end

# ╔═╡ 3c618580-0df9-4ce9-a743-ab45b82c7f42
md"""
## [Numeric Literal Coefficients](@id man-numeric-literal-coefficients)
"""

# ╔═╡ 82892954-ae10-4895-b0a3-04197a2c69b2
md"""
To make common numeric formulae and expressions clearer, Julia allows variables to be immediately preceded by a numeric literal, implying multiplication. This makes writing polynomial expressions much cleaner:
"""

# ╔═╡ 0a5737f2-502d-4bc7-b26c-e503b4cc7f63
x = 3

# ╔═╡ e69bf6d4-08fc-4933-bd73-712459859720
2x^2 - 3x + 1

# ╔═╡ ccc44ad5-1422-4e3c-ae25-637485041346
1.5x^2 - .5x + 1

# ╔═╡ af52231e-d20a-47d3-b342-7be961238fed
md"""
It also makes writing exponential functions more elegant:
"""

# ╔═╡ 8d9a9fc4-d3cf-4267-bf9a-a6dc502d2922
2^2x

# ╔═╡ 183a9a9c-7465-4ba7-be71-d5b6748bcd5e
md"""
The precedence of numeric literal coefficients is slightly lower than that of unary operators such as negation. So `-2x` is parsed as `(-2) * x` and `√2x` is parsed as `(√2) * x`. However, numeric literal coefficients parse similarly to unary operators when combined with exponentiation. For example `2^3x` is parsed as `2^(3x)`, and `2x^3` is parsed as `2*(x^3)`.
"""

# ╔═╡ 70a2bed2-1357-49ad-af22-b4ecf4eb423a
md"""
Numeric literals also work as coefficients to parenthesized expressions:
"""

# ╔═╡ c2d8c815-7fa8-42f2-a9fc-793baa45f34f
2(x-1)^2 - 3(x-1) + 1

# ╔═╡ 253ffc42-398a-4d63-af66-d83ac51f5e76
md"""
!!! note
    The precedence of numeric literal coefficients used for implicit multiplication is higher than other binary operators such as multiplication (`*`), and division (`/`, `\`, and `//`).  This means, for example, that `1 / 2im` equals `-0.5im` and `6 // 2(2 + 1)` equals `1 // 1`.
"""

# ╔═╡ 4ddd421e-25e2-470a-b7ee-fef6e416a280
md"""
Additionally, parenthesized expressions can be used as coefficients to variables, implying multiplication of the expression by the variable:
"""

# ╔═╡ 7de8af1e-1e07-4061-9950-db51a77ffcfb
(x-1)x

# ╔═╡ 6935240e-4c44-479b-bc62-d2111bd731fa
md"""
Neither juxtaposition of two parenthesized expressions, nor placing a variable before a parenthesized expression, however, can be used to imply multiplication:
"""

# ╔═╡ 4cb7cdb9-edaa-4692-9d19-bf06e8f58521
(x-1)(x+1)

# ╔═╡ fed081bc-4b58-4e04-b091-cd18de8fcfce
x(x+1)

# ╔═╡ 681c5620-fbfb-44bb-906b-dad0aa0975cb
md"""
Both expressions are interpreted as function application: any expression that is not a numeric literal, when immediately followed by a parenthetical, is interpreted as a function applied to the values in parentheses (see [Functions](@ref) for more about functions). Thus, in both of these cases, an error occurs since the left-hand value is not a function.
"""

# ╔═╡ 207889dd-ac96-4854-aa10-48b6b86b1941
md"""
The above syntactic enhancements significantly reduce the visual noise incurred when writing common mathematical formulae. Note that no whitespace may come between a numeric literal coefficient and the identifier or parenthesized expression which it multiplies.
"""

# ╔═╡ 56adb5e8-c2c4-40f5-b41d-0a330af10101
md"""
### Syntax Conflicts
"""

# ╔═╡ 59c5baf1-eac7-4595-8591-1e5c7841df70
md"""
Juxtaposed literal coefficient syntax may conflict with some numeric literal syntaxes: hexadecimal, octal and binary integer literals and engineering notation for floating-point literals. Here are some situations where syntactic conflicts arise:
"""

# ╔═╡ b7d18a60-eafc-4fad-ac2c-bb9d038f5111
md"""
  * The hexadecimal integer literal expression `0xff` could be interpreted as the numeric literal `0` multiplied by the variable `xff`. Similar ambiguities arise with octal and binary literals like `0o777` or `0b01001010`.
  * The floating-point literal expression `1e10` could be interpreted as the numeric literal `1` multiplied by the variable `e10`, and similarly with the equivalent `E` form.
  * The 32-bit floating-point literal expression `1.5f22` could be interpreted as the numeric literal `1.5` multiplied by the variable `f22`.
"""

# ╔═╡ 885b7ff8-5c0a-4358-97ab-b434899a6b61
md"""
In all cases the ambiguity is resolved in favor of interpretation as numeric literals:
"""

# ╔═╡ cd89b2ea-6a7f-4668-a9cb-c0ba2e6e2ed3
md"""
  * Expressions starting with `0x`/`0o`/`0b` are always hexadecimal/octal/binary literals.
  * Expressions starting with a numeric literal followed by `e` or `E` are always floating-point literals.
  * Expressions starting with a numeric literal followed by `f` are always 32-bit floating-point literals.
"""

# ╔═╡ a41cd00a-9139-4380-a1e2-4022f9fbacb7
md"""
Unlike `E`, which is equivalent to `e` in numeric literals for historical reasons, `F` is just another letter and does not behave like `f` in numeric literals. Hence, expressions starting with a numeric literal followed by `F` are interpreted as the numerical literal multiplied by a variable, which means that, for example, `1.5F22` is equal to `1.5 * F22`.
"""

# ╔═╡ fe766cd4-3e78-41c4-ba38-33d59cba2d4a
md"""
## Literal zero and one
"""

# ╔═╡ 0682721d-00bf-4dbf-9362-75eb310041da
md"""
Julia provides functions which return literal 0 and 1 corresponding to a specified type or the type of a given variable.
"""

# ╔═╡ bd0294fa-d98b-4a7e-ace3-460e29333e2a
md"""
| Function          | Description                                      |
|:----------------- |:------------------------------------------------ |
| [`zero(x)`](@ref) | Literal zero of type `x` or type of variable `x` |
| [`one(x)`](@ref)  | Literal one of type `x` or type of variable `x`  |
"""

# ╔═╡ a725c811-4fd2-4ab2-8f9a-ad614c3ff4ed
md"""
These functions are useful in [Numeric Comparisons](@ref) to avoid overhead from unnecessary [type conversion](@ref conversion-and-promotion).
"""

# ╔═╡ 8628e347-b7b0-41a8-bf2d-dd0336ca3c80
md"""
Examples:
"""

# ╔═╡ 0fd3c309-93bd-450f-8073-ff5288e23d34
zero(Float32)

# ╔═╡ 93cf554f-ee0e-4e01-8f53-8e6f67e56279
zero(1.0)

# ╔═╡ 287b395c-770b-4e61-9c72-accf5b1f86f2
one(Int32)

# ╔═╡ 5410c0d5-6eeb-47ff-80b4-18a6405cbd8a
one(BigFloat)

# ╔═╡ Cell order:
# ╟─ffbc9a17-ece1-4219-974e-f97db5d47d6a
# ╟─24c9c004-0617-495b-baa7-c9161e4a96b6
# ╟─23a0c9af-53c6-4b7d-9e31-e90eb017af7f
# ╟─4c127fc5-79cb-4965-9ea0-158278102aec
# ╟─22b43ec8-1244-4813-a761-582b2ee41e8c
# ╟─d16e8eb5-0071-4a1a-9d0d-60d3f0b9a525
# ╟─04f43bff-1cc7-4c11-87e4-7695aa9a9fb5
# ╟─9911acda-cea7-4f97-9661-b4f125583792
# ╟─9fe1626e-9cd8-46df-8fe2-f103af55f53c
# ╟─31d0a577-2e54-4351-bdc2-ec417291a3ac
# ╟─158be076-5bd4-450c-b632-013f301f78ce
# ╠═6900dab3-dedc-4d76-99d6-b8dd31d58e51
# ╠═5e105ca4-6632-43fc-84b9-3258bc04ff0a
# ╟─1f21067c-62fb-4e29-a4b3-08ef6610886c
# ╠═f2ce9662-da3a-40e8-ae48-9e3794d6c65f
# ╠═7593690b-63f2-4ab9-8733-dedbc55df333
# ╠═34c6c269-5f91-4307-b853-30f0264e5ee4
# ╟─455a27be-cd94-491b-8d8e-f9dcf9dca899
# ╠═1f61c6cd-3a1c-4ded-b40a-04e0896689a2
# ╠═249d5fb0-29ca-4137-bfde-0eca649cb196
# ╠═56952014-4eb6-45c0-a94f-681e889fdea3
# ╟─57542111-06b1-41ef-ac5e-822af6428c5c
# ╠═c8ef69a6-bb4a-4925-8c93-f0be33c4dc6f
# ╠═5a140e84-ff46-468c-a813-2c2079f5d784
# ╠═edbfd7f4-8843-414a-8656-ec01951fd4f6
# ╠═cc66bee2-ce63-4d7b-b761-bdd27acf80cd
# ╠═dfb5c7b3-7f13-446b-a581-b7524a9c041c
# ╟─2beeaa76-9f58-4914-8cc1-3569d1a2991a
# ╠═174b28fc-5936-4e83-b820-2f32f48b6c8d
# ╠═3461d9c1-7fc0-4132-8b39-189175363895
# ╟─e7092bc0-a1f4-4d15-ac86-219abf860f49
# ╠═b26d4539-f6f1-47f7-a271-3dd868264a4f
# ╠═af46e2ce-c371-4edb-8832-0e7626f5cd3a
# ╠═751537b8-4012-4f77-9073-f748ca642438
# ╠═074ab82f-249b-4200-8460-673fd9918358
# ╠═fdf944aa-acb5-4305-ac92-7a7dea2da437
# ╠═60c8d728-9ac0-43ed-8d26-53e948db93f0
# ╠═160d0f04-c980-4e90-97fb-f13d354e3452
# ╠═2502e061-8d31-4a33-a63c-787765b47b59
# ╠═c8c63d31-c2ab-465a-8104-1f79f2aae75c
# ╠═a36e6987-df41-4fe4-a05b-82c62e8d9db2
# ╟─87a9cab8-357e-49e7-889b-c78adf1f0666
# ╟─e38bac82-f1df-4f45-b1f3-85390ea92b34
# ╠═0a6eca0a-64e4-4dc5-8d04-5ae1c397602c
# ╠═f8ffa2c8-ce43-4231-adeb-c369519fd795
# ╠═61e8b82f-14a7-4eb5-a8bc-fbc1173a395d
# ╠═14486ee5-5d69-4867-b5e8-41de610cce66
# ╠═e40d03ff-9195-4480-b142-27ce9e27cc3e
# ╠═f47a6f6a-e1b1-4dc0-9004-56a968f0162a
# ╟─9c1f4cf6-2139-4113-8de1-620a1e4bb59d
# ╟─9d2491d6-168a-4823-a214-2a1a5aaa26d8
# ╠═1575d04a-f9bd-4972-949b-f67ba7d7f3cb
# ╠═bb55b346-0144-4635-9e06-e18916024630
# ╟─5b09f10d-9359-4ec7-991f-d54c71ef5390
# ╠═997a2990-81f9-44a2-a7d2-f2474868ae1c
# ╠═ff2b82b5-ca1c-4cb5-831c-439e44e3a04f
# ╟─07990599-1d3f-4737-ae7e-d02580502b60
# ╟─f288ac6a-9e4f-4b6a-9e4f-c351acc9fa53
# ╟─ff676447-46a2-4701-94c0-bb81fa4d29eb
# ╠═8133e27b-3a18-4bbe-b26c-82436ccc6f09
# ╠═53c10a97-3cf0-48d8-8fc7-3438b49bb181
# ╠═a2fa705c-1723-4454-b368-80eb5f6389a9
# ╟─bd7305e5-9d9f-4b7a-8e09-9db3635be348
# ╟─8fe9d749-1a47-4628-b1f9-f8634ace43a4
# ╠═a6aad170-f268-4947-8b68-4306b15dc536
# ╠═54e158d5-93f3-4a07-86fd-f589f556fb78
# ╟─72bfd10e-263e-4c0d-a4fc-26e6fefda7c3
# ╟─733ad076-ebf4-4999-b139-56d0f4926e02
# ╟─5e460aef-3d66-413d-996b-751908bcc770
# ╟─dd25dfea-9b03-4369-820e-5f46bb27d314
# ╠═e74919fe-2318-43ab-a336-db582b2f8fea
# ╠═1813abd8-5e7e-4f20-894d-2fc22659b638
# ╠═7a46fb4d-9495-4ad5-83e4-277cde190ad5
# ╠═9a7bd230-939b-40b4-9652-910265aeedb8
# ╠═fbcca441-ed1f-44ea-9157-91c47104b747
# ╠═2f08dcf1-20d7-4e2f-8a8e-1f88b5989947
# ╠═eadae5a0-41b6-43d4-bd6f-ed838fd4d014
# ╟─8c1c281f-432d-446c-b785-4b7e097028da
# ╠═a6ba5db3-f077-4076-a314-3d9b1e6cc371
# ╠═cd7640ad-71f6-4c86-badd-c7b0b0f63e00
# ╠═d9f6bec2-5c0b-4641-a553-ea658513fd38
# ╟─8f0b0155-70ec-4c83-9565-19631b1af844
# ╠═0d301202-af6f-403a-9518-fbbe2842f7c2
# ╠═d4fd5544-0fce-4859-8c83-868d570c426f
# ╟─b1b3df3d-57eb-4d1c-bbe3-ec2c6ca96fd2
# ╠═f62410e9-e759-49f5-89de-680bea97c7a6
# ╠═ea9dcbde-c0b1-4bb4-96e3-f6d95fdd206f
# ╠═34fbe369-d92a-4405-a6a3-f953bfce4f6d
# ╠═98509499-03a5-4cef-80ba-5a83a0bc88e3
# ╟─72c7f034-e928-487d-8ca5-692229cd8520
# ╠═f3c0f2a1-a12c-4304-9f64-85e3264d9a0c
# ╠═8106dd39-9907-4fc3-b967-30333ae0fc1b
# ╟─9e5c0a9d-12ef-44c5-9002-1ba0cd8f3e14
# ╠═e52fdd5d-cf85-4a18-ac82-3d8e54fc77a9
# ╟─d5c57515-36d1-4e3e-aeef-865264bf3792
# ╟─59ded7e0-f51e-46ff-b929-6be82822bb42
# ╠═4123d0bc-593e-4c3b-9cdf-f3c4e005be75
# ╠═311873db-1018-45e7-a711-26ac7bd5d813
# ╠═cf98b451-8ce3-49e6-a5c3-cc33986e7bc1
# ╟─9ef725de-164d-482b-a435-80becbbf291f
# ╟─e6653102-8eec-4fef-9072-9ffdea566b74
# ╟─7cf35ff3-2c15-41a8-8b95-6eb5372820a5
# ╟─bf659ae4-b529-40c6-965c-0e90a916c57d
# ╠═186093a2-7455-4e50-8b43-a2822dc73ac8
# ╠═b6c8c439-5b57-4d74-8bc5-c6a2e64856be
# ╠═99cf8ac5-6e34-41ec-8ec8-a413be8af8c4
# ╠═2a53da3f-4ebb-4dfc-a0b2-f1ce91ba8e79
# ╠═67bf0ac6-a126-43ff-bf0d-9a33b94dcb4a
# ╠═7d6b6026-9898-45a5-adcb-8fef9c7f1e49
# ╠═37c6ba94-86eb-4359-bbd9-9362509b45ac
# ╠═1444c5fa-246d-481c-8850-d32e1c2e27f2
# ╠═5917e5d7-0f5f-465f-b05c-d53624360d5c
# ╠═75ac5b4c-a7a2-486f-b0a3-e8e24cbe4ad2
# ╠═3a7c6fc7-22bc-4749-aa1d-5d549e855a7c
# ╠═6a92fa0f-f785-48ef-9c99-d2a957a71e60
# ╟─d91908a7-92dc-4582-8f62-e16061985a6d
# ╠═9646ff1e-37dd-4cdc-bc3c-43914bbd6c44
# ╠═f4723495-a218-4acf-9a43-afef3e96364f
# ╠═17ad0ea9-cbbd-4ff3-b553-53066d1b18d7
# ╟─24810b80-ca64-4d5f-bf40-d79b570b6950
# ╟─564e20e9-8531-4fe2-b1fd-c9da9914b565
# ╟─eb97ab89-74e7-4f31-8c85-8b196f109c26
# ╠═8d1f62e1-f127-4392-a82b-57d8fe1df16b
# ╠═b2f694c7-9f2d-4680-9ec5-98f393f7487f
# ╠═3443afb0-6076-414e-8af7-72d01d2eb8ab
# ╟─0e6a019e-2c73-4429-aaca-ad6fbec9416a
# ╠═fab62b9f-f6a0-4dab-bf71-885522131820
# ╠═a1fcfc9b-e4c4-4ba3-a887-dffe70be3160
# ╠═11c40da4-8345-41fc-9782-43ecb812ed2b
# ╠═339374a3-3e43-493a-bacf-229464a656e9
# ╟─05546f70-6f33-439d-9b86-8087ce7bccdb
# ╟─ea29a18b-e74c-49fb-b534-870cf3b9de8c
# ╠═0c70c4e2-3432-4089-b641-eb06bc0fb2a1
# ╠═f17dd1ad-41d7-4c61-b390-4ca8cee61e31
# ╠═420f8b13-a4d5-47ee-81c1-da9fa69fc4dd
# ╠═b5869cce-0fb6-4579-a9f4-0c5f0ff2bd53
# ╠═8c03c2cd-41de-4433-bcaa-eade1527fe3d
# ╠═b319085b-6e9a-431e-ba97-3465c339c927
# ╟─4ff33a88-8513-432c-b5fe-7d4a7c993e42
# ╟─2eeac7ae-18eb-4f9f-872a-0befecf1158e
# ╟─783f7cf3-f3dd-4af1-a3fd-9e0e35824701
# ╟─b23d4765-5449-4284-98d7-fd2d69feaf77
# ╟─31ea45b4-8afd-42f3-bca3-cf088c5426a5
# ╟─ad6ea342-82d6-4626-b020-a41fb873d259
# ╟─ba911167-d56d-472f-a56c-3e2aec4211cd
# ╟─508f49d7-b0c6-4a3e-ba04-d756244b5df3
# ╟─b3201be1-6c8e-4c05-b24e-cbf0c512bc9c
# ╟─2e0f2d5c-b337-4567-a934-4360ce35c1e7
# ╟─7be5c9ec-10c5-4bec-a81b-370db1d121ba
# ╠═c175e004-a515-41b2-b5fa-671b6204941d
# ╠═06719ebe-e725-4f16-8516-98f99d787e8b
# ╠═193e8714-3d6e-4053-8e5e-c7d03b85bfd1
# ╠═6e429ce7-7976-41af-aee7-387433d10f44
# ╠═5e3380aa-7a6f-4218-a141-aa740acaab18
# ╠═02747cd8-1f87-4663-aa6f-af93007e4802
# ╠═db69a9e4-cdab-49dd-9438-93ef03951964
# ╠═f4f4996c-1a81-4b18-8150-a7d9780a2dca
# ╠═8462a359-d17e-48c9-b255-09cfa5bb4381
# ╠═4b58f95f-8a22-41ab-963d-8984e8bc69c5
# ╠═1e91ece9-8feb-4d57-ab1f-ee82080004ce
# ╟─9e2ee5f6-362f-4033-8e9a-a5dd908eff34
# ╠═0eb6adfc-c162-4d22-be87-004f88f36a58
# ╠═3ec6da78-ac08-4b63-b7a1-274244062593
# ╠═b02df6ec-d665-4d0b-a887-e7c84de6f4b2
# ╠═f5f20738-37d6-4137-a3e1-39fffe4923ba
# ╠═28f62e38-2d98-40bd-b6f1-0961d79006c3
# ╠═92c3c644-bbd8-4978-a760-aef9bfdee01a
# ╟─60920413-5229-4cd9-91d6-aaa380114574
# ╠═4527b8d6-2fb5-41bd-8aab-5e74be5bdb7c
# ╠═7daf4ffe-721d-400b-8756-4130d91fee24
# ╠═cb5ddd54-b502-43ab-a33d-f15482205f46
# ╟─3c618580-0df9-4ce9-a743-ab45b82c7f42
# ╟─82892954-ae10-4895-b0a3-04197a2c69b2
# ╠═0a5737f2-502d-4bc7-b26c-e503b4cc7f63
# ╠═e69bf6d4-08fc-4933-bd73-712459859720
# ╠═ccc44ad5-1422-4e3c-ae25-637485041346
# ╟─af52231e-d20a-47d3-b342-7be961238fed
# ╠═8d9a9fc4-d3cf-4267-bf9a-a6dc502d2922
# ╟─183a9a9c-7465-4ba7-be71-d5b6748bcd5e
# ╟─70a2bed2-1357-49ad-af22-b4ecf4eb423a
# ╠═c2d8c815-7fa8-42f2-a9fc-793baa45f34f
# ╟─253ffc42-398a-4d63-af66-d83ac51f5e76
# ╟─4ddd421e-25e2-470a-b7ee-fef6e416a280
# ╠═7de8af1e-1e07-4061-9950-db51a77ffcfb
# ╟─6935240e-4c44-479b-bc62-d2111bd731fa
# ╠═4cb7cdb9-edaa-4692-9d19-bf06e8f58521
# ╠═fed081bc-4b58-4e04-b091-cd18de8fcfce
# ╟─681c5620-fbfb-44bb-906b-dad0aa0975cb
# ╟─207889dd-ac96-4854-aa10-48b6b86b1941
# ╟─56adb5e8-c2c4-40f5-b41d-0a330af10101
# ╟─59c5baf1-eac7-4595-8591-1e5c7841df70
# ╟─b7d18a60-eafc-4fad-ac2c-bb9d038f5111
# ╟─885b7ff8-5c0a-4358-97ab-b434899a6b61
# ╟─cd89b2ea-6a7f-4668-a9cb-c0ba2e6e2ed3
# ╟─a41cd00a-9139-4380-a1e2-4022f9fbacb7
# ╟─fe766cd4-3e78-41c4-ba38-33d59cba2d4a
# ╟─0682721d-00bf-4dbf-9362-75eb310041da
# ╟─bd0294fa-d98b-4a7e-ace3-460e29333e2a
# ╟─a725c811-4fd2-4ab2-8f9a-ad614c3ff4ed
# ╟─8628e347-b7b0-41a8-bf2d-dd0336ca3c80
# ╠═0fd3c309-93bd-450f-8073-ff5288e23d34
# ╠═93cf554f-ee0e-4e01-8f53-8e6f67e56279
# ╠═287b395c-770b-4e61-9c72-accf5b1f86f2
# ╠═5410c0d5-6eeb-47ff-80b4-18a6405cbd8a
