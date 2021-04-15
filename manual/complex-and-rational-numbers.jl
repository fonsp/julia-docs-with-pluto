### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ 03bbf8d0-9e19-11eb-0b7e-bd743b32338a
md"""
# Complex and Rational Numbers
"""

# ╔═╡ 03bbf97a-9e19-11eb-0b17-a9cd49b6a901
md"""
Julia includes predefined types for both complex and rational numbers, and supports all the standard [Mathematical Operations and Elementary Functions](@ref) on them. [Conversion and Promotion](@ref conversion-and-promotion) are defined so that operations on any combination of predefined numeric types, whether primitive or composite, behave as expected.
"""

# ╔═╡ 03bbf9ac-9e19-11eb-0a15-0bfe310cf499
md"""
## Complex Numbers
"""

# ╔═╡ 03bbf9fc-9e19-11eb-3b52-732a2752c922
md"""
The global constant [`im`](@ref) is bound to the complex number *i*, representing the principal square root of -1. (Using mathematicians' `i` or engineers' `j` for this global constant were rejected since they are such popular index variable names.) Since Julia allows numeric literals to be [juxtaposed with identifiers as coefficients](@ref man-numeric-literal-coefficients), this binding suffices to provide convenient syntax for complex numbers, similar to the traditional mathematical notation:
"""

# ╔═╡ 03bbfe0c-9e19-11eb-06e5-1bdb18c8233d
1+2im

# ╔═╡ 03bbfe20-9e19-11eb-0fa1-435975f956a7
md"""
You can perform all the standard arithmetic operations with complex numbers:
"""

# ╔═╡ 03bc1386-9e19-11eb-328b-811ac2d218e7
(1 + 2im)*(2 - 3im)

# ╔═╡ 03bc139c-9e19-11eb-0634-23d6d46ac9fa
(1 + 2im)/(1 - 2im)

# ╔═╡ 03bc13a6-9e19-11eb-13bd-b33d8b7dec2a
(1 + 2im) + (1 - 2im)

# ╔═╡ 03bc13a6-9e19-11eb-1d6a-43d31d9d92da
(-3 + 2im) - (5 - 1im)

# ╔═╡ 03bc13a6-9e19-11eb-000e-e1c1e91290e0
(-1 + 2im)^2

# ╔═╡ 03bc13b0-9e19-11eb-2fd5-2966d051d49d
(-1 + 2im)^2.5

# ╔═╡ 03bc13ea-9e19-11eb-2912-ff9db056ddcc
(-1 + 2im)^(1 + 1im)

# ╔═╡ 03bc13f6-9e19-11eb-0eb0-3dfae3ba605b
3(2 - 5im)

# ╔═╡ 03bc13f6-9e19-11eb-2ef2-19f1e08e85c3
3(2 - 5im)^2

# ╔═╡ 03bc13f6-9e19-11eb-2a8f-1f5cf9755d9e
3(2 - 5im)^-1.0

# ╔═╡ 03bc141e-9e19-11eb-0449-6bca6a3e4971
md"""
The promotion mechanism ensures that combinations of operands of different types just work:
"""

# ╔═╡ 03bc2256-9e19-11eb-0460-87fe3735094f
2(1 - 1im)

# ╔═╡ 03bc2256-9e19-11eb-0ddf-5d55bbfd9081
(2 + 3im) - 1

# ╔═╡ 03bc2260-9e19-11eb-2d5b-5198e8b90810
(1 + 2im) + 0.5

# ╔═╡ 03bc2260-9e19-11eb-250b-09633d1806ec
(2 + 3im) - 0.5im

# ╔═╡ 03bc2274-9e19-11eb-01ee-13394429533d
0.75(1 + 2im)

# ╔═╡ 03bc2274-9e19-11eb-2641-b1e6abf0f552
(2 + 3im) / 2

# ╔═╡ 03bc227e-9e19-11eb-3f03-35b89063436a
(1 - 3im) / (2 + 2im)

# ╔═╡ 03bc227e-9e19-11eb-17e4-0dec8c178bfc
2im^2

# ╔═╡ 03bc227e-9e19-11eb-3587-ada1c8e4536b
1 + 3/4im

# ╔═╡ 03bc22a6-9e19-11eb-2951-fbd8b037902c
md"""
Note that `3/4im == 3/(4*im) == -(3/4*im)`, since a literal coefficient binds more tightly than division.
"""

# ╔═╡ 03bc22ba-9e19-11eb-1ae9-793a993a5e06
md"""
Standard functions to manipulate complex values are provided:
"""

# ╔═╡ 03bc2e22-9e19-11eb-018d-9b4a8d5b7c7b
z = 1 + 2im

# ╔═╡ 03bc2e36-9e19-11eb-1868-bdac72d03e98
real(1 + 2im) # real part of z

# ╔═╡ 03bc2e40-9e19-11eb-1bd4-5dacd96d012e
imag(1 + 2im) # imaginary part of z

# ╔═╡ 03bc2e40-9e19-11eb-0e36-e76407babc7c
conj(1 + 2im) # complex conjugate of z

# ╔═╡ 03bc2e4a-9e19-11eb-269a-35f6f5265735
abs(1 + 2im) # absolute value of z

# ╔═╡ 03bc2e4a-9e19-11eb-049b-d527f023b392
abs2(1 + 2im) # squared absolute value

# ╔═╡ 03bc2e5e-9e19-11eb-0c03-b7471180e887
angle(1 + 2im) # phase angle in radians

# ╔═╡ 03bc2e9a-9e19-11eb-2401-c78cb2ee488b
md"""
As usual, the absolute value ([`abs`](@ref)) of a complex number is its distance from zero. [`abs2`](@ref) gives the square of the absolute value, and is of particular use for complex numbers since it avoids taking a square root. [`angle`](@ref) returns the phase angle in radians (also known as the *argument* or *arg* function). The full gamut of other [Elementary Functions](@ref) is also defined for complex numbers:
"""

# ╔═╡ 03bc355c-9e19-11eb-04e2-151ece8d8eec
sqrt(1im)

# ╔═╡ 03bc3566-9e19-11eb-0fca-03c2d6ada2f7
sqrt(1 + 2im)

# ╔═╡ 03bc3570-9e19-11eb-1468-1db3aaa750ef
cos(1 + 2im)

# ╔═╡ 03bc357a-9e19-11eb-1cc3-83c63b99243a
exp(1 + 2im)

# ╔═╡ 03bc357a-9e19-11eb-1586-b5d91855e82c
sinh(1 + 2im)

# ╔═╡ 03bc35a2-9e19-11eb-2a52-d12655b0e845
md"""
Note that mathematical functions typically return real values when applied to real numbers and complex values when applied to complex numbers. For example, [`sqrt`](@ref) behaves differently when applied to `-1` versus `-1 + 0im` even though `-1 == -1 + 0im`:
"""

# ╔═╡ 03bc382c-9e19-11eb-00cd-bd17aba84e53
sqrt(-1)

# ╔═╡ 03bc382c-9e19-11eb-0a5a-05f0445495ca
sqrt(-1 + 0im)

# ╔═╡ 03bc384a-9e19-11eb-04ee-f1b5fc410356
md"""
The [literal numeric coefficient notation](@ref man-numeric-literal-coefficients) does not work when constructing a complex number from variables. Instead, the multiplication must be explicitly written out:
"""

# ╔═╡ 03bc3ade-9e19-11eb-3c3f-45a21e0db316
a = 1; b = 2; a + b*im

# ╔═╡ 03bc3b26-9e19-11eb-2ab4-d330adb564c8
md"""
However, this is *not* recommended. Instead, use the more efficient [`complex`](@ref) function to construct a complex value directly from its real and imaginary parts:
"""

# ╔═╡ 03bc3d92-9e19-11eb-3d1b-23e34213a8b6
a = 1; b = 2; complex(a, b)

# ╔═╡ 03bc3da4-9e19-11eb-3ae8-9189cbdc7dbb
md"""
This construction avoids the multiplication and addition operations.
"""

# ╔═╡ 03bc3dd6-9e19-11eb-1484-fda92d182df1
md"""
[`Inf`](@ref) and [`NaN`](@ref) propagate through complex numbers in the real and imaginary parts of a complex number as described in the [Special floating-point values](@ref) section:
"""

# ╔═╡ 03bc4038-9e19-11eb-1510-992b1f22e54c
1 + Inf*im

# ╔═╡ 03bc4038-9e19-11eb-3071-d9e0b1b4676b
1 + NaN*im

# ╔═╡ 03bc404c-9e19-11eb-3024-2d8e3e5c6bc2
md"""
## Rational Numbers
"""

# ╔═╡ 03bc406a-9e19-11eb-2032-0badf6b64ec5
md"""
Julia has a rational number type to represent exact ratios of integers. Rationals are constructed using the [`//`](@ref) operator:
"""

# ╔═╡ 03bc4178-9e19-11eb-10ff-d3f7f011b242
2//3

# ╔═╡ 03bc418c-9e19-11eb-2533-05ee9c50faa9
md"""
If the numerator and denominator of a rational have common factors, they are reduced to lowest terms such that the denominator is non-negative:
"""

# ╔═╡ 03bc44de-9e19-11eb-00c1-a955e9ffb090
6//9

# ╔═╡ 03bc44de-9e19-11eb-252f-d3f99fd47176
-4//8

# ╔═╡ 03bc44f2-9e19-11eb-14cd-33cca0603791
5//-15

# ╔═╡ 03bc44f2-9e19-11eb-0c7d-bbf5b8756e3e
-4//-12

# ╔═╡ 03bc451a-9e19-11eb-3fa7-fb95ebcb3e9e
md"""
This normalized form for a ratio of integers is unique, so equality of rational values can be tested by checking for equality of the numerator and denominator. The standardized numerator and denominator of a rational value can be extracted using the [`numerator`](@ref) and [`denominator`](@ref) functions:
"""

# ╔═╡ 03bc4876-9e19-11eb-3ad3-69e458f72e55
numerator(2//3)

# ╔═╡ 03bc4894-9e19-11eb-028a-3bb0f3cc188a
denominator(2//3)

# ╔═╡ 03bc48a0-9e19-11eb-1da3-71be7fcf90ab
md"""
Direct comparison of the numerator and denominator is generally not necessary, since the standard arithmetic and comparison operations are defined for rational values:
"""

# ╔═╡ 03bc5456-9e19-11eb-13af-e32c7904f38a
2//3 == 6//9

# ╔═╡ 03bc5456-9e19-11eb-3cc9-893de2740efc
2//3 == 9//27

# ╔═╡ 03bc546a-9e19-11eb-32a0-013e092b6740
3//7 < 1//2

# ╔═╡ 03bc546a-9e19-11eb-007f-3f1a1e2bbef7
3//4 > 2//3

# ╔═╡ 03bc5472-9e19-11eb-17c2-25b6c3a8b5ef
2//4 + 1//6

# ╔═╡ 03bc5472-9e19-11eb-3bad-1da11bb91781
5//12 - 1//4

# ╔═╡ 03bc547e-9e19-11eb-0b4f-4d075c2b4f51
5//8 * 3//12

# ╔═╡ 03bc5488-9e19-11eb-1e43-09bbf0d2ff73
6//5 / 10//7

# ╔═╡ 03bc549c-9e19-11eb-2b2e-67d8aa67035c
md"""
Rationals can easily be converted to floating-point numbers:
"""

# ╔═╡ 03bc567e-9e19-11eb-15e0-a97d43dc0db2
float(3//4)

# ╔═╡ 03bc56a4-9e19-11eb-2e3e-27deddceb25e
md"""
Conversion from rational to floating-point respects the following identity for any integral values of `a` and `b`, with the exception of the case `a == 0` and `b == 0`:
"""

# ╔═╡ 03bc5abe-9e19-11eb-03b7-39cd72163a25
a = 1; b = 2;

# ╔═╡ 03bc5abe-9e19-11eb-2c7f-f9ec0c305a06
isequal(float(a//b), a/b)

# ╔═╡ 03bc5ad2-9e19-11eb-0266-cbe74877340d
md"""
Constructing infinite rational values is acceptable:
"""

# ╔═╡ 03bc5dde-9e19-11eb-0e7d-cf8b5e3a5246
5//0

# ╔═╡ 03bc5df2-9e19-11eb-06b0-d7dda2c43b51
x = -3//0

# ╔═╡ 03bc5dfc-9e19-11eb-2589-9594f0cb6bb1
typeof(x)

# ╔═╡ 03bc5e1a-9e19-11eb-152f-0b68a4c8f31f
md"""
Trying to construct a [`NaN`](@ref) rational value, however, is invalid:
"""

# ╔═╡ 03bc5f00-9e19-11eb-0469-f71637c34cc7
0//0

# ╔═╡ 03bc5f1c-9e19-11eb-0217-adf93ef1706c
md"""
As usual, the promotion system makes interactions with other numeric types effortless:
"""

# ╔═╡ 03bc71a4-9e19-11eb-29b7-ad1e4d4ab203
3//5 + 1

# ╔═╡ 03bc71ac-9e19-11eb-3e16-c1d27af3f257
3//5 - 0.5

# ╔═╡ 03bc71ac-9e19-11eb-0618-671f3d08bcc0
2//7 * (1 + 2im)

# ╔═╡ 03bc71ac-9e19-11eb-2791-3f8708c250d6
2//7 * (1.5 + 2im)

# ╔═╡ 03bc71ca-9e19-11eb-283c-2f9f66f7acb2
3//2 / (1 + 2im)

# ╔═╡ 03bc71ca-9e19-11eb-1f95-f5299c2793c5
1//2 + 2im

# ╔═╡ 03bc71ca-9e19-11eb-1040-67646371c697
1 + 2//3im

# ╔═╡ 03bc71d6-9e19-11eb-28de-b73cbd916e2e
0.5 == 1//2

# ╔═╡ 03bc71d6-9e19-11eb-1f74-ef524c8d7a74
0.33 == 1//3

# ╔═╡ 03bc71e8-9e19-11eb-3c43-89f7681d9f16
0.33 < 1//3

# ╔═╡ 03bc71e8-9e19-11eb-044f-e9f13927d1c3
1//3 - 0.33

# ╔═╡ Cell order:
# ╟─03bbf8d0-9e19-11eb-0b7e-bd743b32338a
# ╟─03bbf97a-9e19-11eb-0b17-a9cd49b6a901
# ╟─03bbf9ac-9e19-11eb-0a15-0bfe310cf499
# ╟─03bbf9fc-9e19-11eb-3b52-732a2752c922
# ╠═03bbfe0c-9e19-11eb-06e5-1bdb18c8233d
# ╟─03bbfe20-9e19-11eb-0fa1-435975f956a7
# ╠═03bc1386-9e19-11eb-328b-811ac2d218e7
# ╠═03bc139c-9e19-11eb-0634-23d6d46ac9fa
# ╠═03bc13a6-9e19-11eb-13bd-b33d8b7dec2a
# ╠═03bc13a6-9e19-11eb-1d6a-43d31d9d92da
# ╠═03bc13a6-9e19-11eb-000e-e1c1e91290e0
# ╠═03bc13b0-9e19-11eb-2fd5-2966d051d49d
# ╠═03bc13ea-9e19-11eb-2912-ff9db056ddcc
# ╠═03bc13f6-9e19-11eb-0eb0-3dfae3ba605b
# ╠═03bc13f6-9e19-11eb-2ef2-19f1e08e85c3
# ╠═03bc13f6-9e19-11eb-2a8f-1f5cf9755d9e
# ╟─03bc141e-9e19-11eb-0449-6bca6a3e4971
# ╠═03bc2256-9e19-11eb-0460-87fe3735094f
# ╠═03bc2256-9e19-11eb-0ddf-5d55bbfd9081
# ╠═03bc2260-9e19-11eb-2d5b-5198e8b90810
# ╠═03bc2260-9e19-11eb-250b-09633d1806ec
# ╠═03bc2274-9e19-11eb-01ee-13394429533d
# ╠═03bc2274-9e19-11eb-2641-b1e6abf0f552
# ╠═03bc227e-9e19-11eb-3f03-35b89063436a
# ╠═03bc227e-9e19-11eb-17e4-0dec8c178bfc
# ╠═03bc227e-9e19-11eb-3587-ada1c8e4536b
# ╟─03bc22a6-9e19-11eb-2951-fbd8b037902c
# ╟─03bc22ba-9e19-11eb-1ae9-793a993a5e06
# ╠═03bc2e22-9e19-11eb-018d-9b4a8d5b7c7b
# ╠═03bc2e36-9e19-11eb-1868-bdac72d03e98
# ╠═03bc2e40-9e19-11eb-1bd4-5dacd96d012e
# ╠═03bc2e40-9e19-11eb-0e36-e76407babc7c
# ╠═03bc2e4a-9e19-11eb-269a-35f6f5265735
# ╠═03bc2e4a-9e19-11eb-049b-d527f023b392
# ╠═03bc2e5e-9e19-11eb-0c03-b7471180e887
# ╟─03bc2e9a-9e19-11eb-2401-c78cb2ee488b
# ╠═03bc355c-9e19-11eb-04e2-151ece8d8eec
# ╠═03bc3566-9e19-11eb-0fca-03c2d6ada2f7
# ╠═03bc3570-9e19-11eb-1468-1db3aaa750ef
# ╠═03bc357a-9e19-11eb-1cc3-83c63b99243a
# ╠═03bc357a-9e19-11eb-1586-b5d91855e82c
# ╟─03bc35a2-9e19-11eb-2a52-d12655b0e845
# ╠═03bc382c-9e19-11eb-00cd-bd17aba84e53
# ╠═03bc382c-9e19-11eb-0a5a-05f0445495ca
# ╟─03bc384a-9e19-11eb-04ee-f1b5fc410356
# ╠═03bc3ade-9e19-11eb-3c3f-45a21e0db316
# ╟─03bc3b26-9e19-11eb-2ab4-d330adb564c8
# ╠═03bc3d92-9e19-11eb-3d1b-23e34213a8b6
# ╟─03bc3da4-9e19-11eb-3ae8-9189cbdc7dbb
# ╟─03bc3dd6-9e19-11eb-1484-fda92d182df1
# ╠═03bc4038-9e19-11eb-1510-992b1f22e54c
# ╠═03bc4038-9e19-11eb-3071-d9e0b1b4676b
# ╟─03bc404c-9e19-11eb-3024-2d8e3e5c6bc2
# ╟─03bc406a-9e19-11eb-2032-0badf6b64ec5
# ╠═03bc4178-9e19-11eb-10ff-d3f7f011b242
# ╟─03bc418c-9e19-11eb-2533-05ee9c50faa9
# ╠═03bc44de-9e19-11eb-00c1-a955e9ffb090
# ╠═03bc44de-9e19-11eb-252f-d3f99fd47176
# ╠═03bc44f2-9e19-11eb-14cd-33cca0603791
# ╠═03bc44f2-9e19-11eb-0c7d-bbf5b8756e3e
# ╟─03bc451a-9e19-11eb-3fa7-fb95ebcb3e9e
# ╠═03bc4876-9e19-11eb-3ad3-69e458f72e55
# ╠═03bc4894-9e19-11eb-028a-3bb0f3cc188a
# ╟─03bc48a0-9e19-11eb-1da3-71be7fcf90ab
# ╠═03bc5456-9e19-11eb-13af-e32c7904f38a
# ╠═03bc5456-9e19-11eb-3cc9-893de2740efc
# ╠═03bc546a-9e19-11eb-32a0-013e092b6740
# ╠═03bc546a-9e19-11eb-007f-3f1a1e2bbef7
# ╠═03bc5472-9e19-11eb-17c2-25b6c3a8b5ef
# ╠═03bc5472-9e19-11eb-3bad-1da11bb91781
# ╠═03bc547e-9e19-11eb-0b4f-4d075c2b4f51
# ╠═03bc5488-9e19-11eb-1e43-09bbf0d2ff73
# ╟─03bc549c-9e19-11eb-2b2e-67d8aa67035c
# ╠═03bc567e-9e19-11eb-15e0-a97d43dc0db2
# ╟─03bc56a4-9e19-11eb-2e3e-27deddceb25e
# ╠═03bc5abe-9e19-11eb-03b7-39cd72163a25
# ╠═03bc5abe-9e19-11eb-2c7f-f9ec0c305a06
# ╟─03bc5ad2-9e19-11eb-0266-cbe74877340d
# ╠═03bc5dde-9e19-11eb-0e7d-cf8b5e3a5246
# ╠═03bc5df2-9e19-11eb-06b0-d7dda2c43b51
# ╠═03bc5dfc-9e19-11eb-2589-9594f0cb6bb1
# ╟─03bc5e1a-9e19-11eb-152f-0b68a4c8f31f
# ╠═03bc5f00-9e19-11eb-0469-f71637c34cc7
# ╟─03bc5f1c-9e19-11eb-0217-adf93ef1706c
# ╠═03bc71a4-9e19-11eb-29b7-ad1e4d4ab203
# ╠═03bc71ac-9e19-11eb-3e16-c1d27af3f257
# ╠═03bc71ac-9e19-11eb-0618-671f3d08bcc0
# ╠═03bc71ac-9e19-11eb-2791-3f8708c250d6
# ╠═03bc71ca-9e19-11eb-283c-2f9f66f7acb2
# ╠═03bc71ca-9e19-11eb-1f95-f5299c2793c5
# ╠═03bc71ca-9e19-11eb-1040-67646371c697
# ╠═03bc71d6-9e19-11eb-28de-b73cbd916e2e
# ╠═03bc71d6-9e19-11eb-1f74-ef524c8d7a74
# ╠═03bc71e8-9e19-11eb-3c43-89f7681d9f16
# ╠═03bc71e8-9e19-11eb-044f-e9f13927d1c3
