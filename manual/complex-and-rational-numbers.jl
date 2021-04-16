### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ d4f10538-c40f-4ebb-ae7b-716227cfcced
md"""
# Complex and Rational Numbers
"""

# ╔═╡ 256f4522-2e76-46e9-b925-c1e2c8a63ddc
md"""
Julia includes predefined types for both complex and rational numbers, and supports all the standard [Mathematical Operations and Elementary Functions](@ref) on them. [Conversion and Promotion](@ref conversion-and-promotion) are defined so that operations on any combination of predefined numeric types, whether primitive or composite, behave as expected.
"""

# ╔═╡ c73d34cd-fce2-48e9-ad0c-9870317ff704
md"""
## Complex Numbers
"""

# ╔═╡ a09b2455-d02a-4f92-9bca-0b55341020a0
md"""
The global constant [`im`](@ref) is bound to the complex number *i*, representing the principal square root of -1. (Using mathematicians' `i` or engineers' `j` for this global constant were rejected since they are such popular index variable names.) Since Julia allows numeric literals to be [juxtaposed with identifiers as coefficients](@ref man-numeric-literal-coefficients), this binding suffices to provide convenient syntax for complex numbers, similar to the traditional mathematical notation:
"""

# ╔═╡ 75aa2e30-4617-4f80-a46b-d714fbe787dc
1+2im

# ╔═╡ 7aa4f72d-e827-4796-9b07-3d2c426a57ad
md"""
You can perform all the standard arithmetic operations with complex numbers:
"""

# ╔═╡ bf9c805c-2f3b-4834-807d-c8d8d5ee6d04
(1 + 2im)*(2 - 3im)

# ╔═╡ b4559c2f-7865-4343-b158-67779c36d9dc
(1 + 2im)/(1 - 2im)

# ╔═╡ 3c675dbc-cc6a-4dfa-9b7e-39224119bf8c
(1 + 2im) + (1 - 2im)

# ╔═╡ 9b607cc5-4507-4589-8cdf-c7df402c79d9
(-3 + 2im) - (5 - 1im)

# ╔═╡ e97f29ac-b70f-4ed9-9620-35aa987c5311
(-1 + 2im)^2

# ╔═╡ 8681c9a7-097c-4511-813c-27cafb811d4d
(-1 + 2im)^2.5

# ╔═╡ fae6fd36-3e98-4642-b0ab-b97cb1338b1e
(-1 + 2im)^(1 + 1im)

# ╔═╡ 1d265700-2c67-4d2c-858a-ac5a0f055608
3(2 - 5im)

# ╔═╡ d4fa6055-4cad-4c75-9d82-845db79620b1
3(2 - 5im)^2

# ╔═╡ b7f4fa56-88f5-41b0-b6f2-13e4f8faf978
3(2 - 5im)^-1.0

# ╔═╡ 5d6f2b79-7e83-46e1-8ef5-3163fbdc2407
md"""
The promotion mechanism ensures that combinations of operands of different types just work:
"""

# ╔═╡ 626b3c7c-9bb6-4bd3-87b4-0b2a4b88ae1d
2(1 - 1im)

# ╔═╡ 596bbd56-f737-4215-b22c-36cc7cdaa5b7
(2 + 3im) - 1

# ╔═╡ d194f1ff-39bc-4cb8-a802-83f605b20f2a
(1 + 2im) + 0.5

# ╔═╡ d48f1692-ddc8-43d3-8035-ec3803fa1d01
(2 + 3im) - 0.5im

# ╔═╡ 6c0d1359-2d97-4048-84ae-db4568c6f0f4
0.75(1 + 2im)

# ╔═╡ 0e8538ab-2fa4-42a8-9d4d-263b17750bab
(2 + 3im) / 2

# ╔═╡ bd303d0a-e21c-49d7-ba9b-5d3f022fc8f8
(1 - 3im) / (2 + 2im)

# ╔═╡ 2faae5dd-a3ed-47f2-9a31-0d6ca8b4809b
2im^2

# ╔═╡ 0ea28097-7547-4f29-9732-21beb521f49a
1 + 3/4im

# ╔═╡ 8bb203bf-2879-4356-9146-50270924ee1e
md"""
Note that `3/4im == 3/(4*im) == -(3/4*im)`, since a literal coefficient binds more tightly than division.
"""

# ╔═╡ b8b21fb9-7f19-4e75-8108-02ac9c34bf6e
md"""
Standard functions to manipulate complex values are provided:
"""

# ╔═╡ 2e8c7109-f81f-40b9-b244-39ce9ba5cdcd
z = 1 + 2im

# ╔═╡ 786d88ab-a160-4f5a-acfe-d4dfa4656ac1
real(1 + 2im) # real part of z

# ╔═╡ 0f4abaa4-e212-4c5a-8119-e51de8d931ec
imag(1 + 2im) # imaginary part of z

# ╔═╡ a3e1c662-f14e-4ee4-98da-4ff86a4725bb
conj(1 + 2im) # complex conjugate of z

# ╔═╡ c6855bf6-c176-4582-985b-eb7bd3809464
abs(1 + 2im) # absolute value of z

# ╔═╡ a5ac901c-00df-4a06-9465-47968b48208f
abs2(1 + 2im) # squared absolute value

# ╔═╡ 171e9cbd-e46f-41e2-80fb-c9d511d4cfdd
angle(1 + 2im) # phase angle in radians

# ╔═╡ bdfe0842-8e8f-4e8b-b35d-51c99c73925e
md"""
As usual, the absolute value ([`abs`](@ref)) of a complex number is its distance from zero. [`abs2`](@ref) gives the square of the absolute value, and is of particular use for complex numbers since it avoids taking a square root. [`angle`](@ref) returns the phase angle in radians (also known as the *argument* or *arg* function). The full gamut of other [Elementary Functions](@ref) is also defined for complex numbers:
"""

# ╔═╡ 3086b975-24c9-48b3-a976-2dce16a8a0c0
sqrt(1im)

# ╔═╡ e9438722-4079-4ecb-994a-9f590410b40f
sqrt(1 + 2im)

# ╔═╡ 42a14643-3fe0-4482-9a38-230ec06812a2
cos(1 + 2im)

# ╔═╡ bd9eb37e-3614-477b-9a85-63de20072b4e
exp(1 + 2im)

# ╔═╡ a0dfa4e3-e044-4d24-8d75-ae3040557825
sinh(1 + 2im)

# ╔═╡ 60d447f6-d0cf-47b8-8248-2167317f4237
md"""
Note that mathematical functions typically return real values when applied to real numbers and complex values when applied to complex numbers. For example, [`sqrt`](@ref) behaves differently when applied to `-1` versus `-1 + 0im` even though `-1 == -1 + 0im`:
"""

# ╔═╡ 99a018b0-9dc9-4c7b-be04-c749f70c9342
sqrt(-1)

# ╔═╡ b221dc30-6e63-4dd9-b6ed-3684c894622d
sqrt(-1 + 0im)

# ╔═╡ 544833bb-d022-40bb-b824-c8350b1c9a3b
md"""
The [literal numeric coefficient notation](@ref man-numeric-literal-coefficients) does not work when constructing a complex number from variables. Instead, the multiplication must be explicitly written out:
"""

# ╔═╡ da244250-40e7-4065-b88d-871624165eae
a = 1; b = 2; a + b*im

# ╔═╡ 3ae6ce47-e928-4136-ab6c-ad14a1b60aec
md"""
However, this is *not* recommended. Instead, use the more efficient [`complex`](@ref) function to construct a complex value directly from its real and imaginary parts:
"""

# ╔═╡ 5d62c504-b253-473e-ad2c-ff4dee654df8
a = 1; b = 2; complex(a, b)

# ╔═╡ b2c2765a-8f91-4c2f-8d60-8e114c75851e
md"""
This construction avoids the multiplication and addition operations.
"""

# ╔═╡ c93aa8b2-32ff-465d-a812-8741103dbc7e
md"""
[`Inf`](@ref) and [`NaN`](@ref) propagate through complex numbers in the real and imaginary parts of a complex number as described in the [Special floating-point values](@ref) section:
"""

# ╔═╡ ad6f2591-a2f4-442d-ae39-c487dd36135f
1 + Inf*im

# ╔═╡ e0e365fb-dee9-4947-9c5e-db44a92931d7
1 + NaN*im

# ╔═╡ b0df2597-481a-4119-a6a0-531e10d4fa26
md"""
## Rational Numbers
"""

# ╔═╡ b56399f3-c91b-4556-aa30-2ccf9b5878d2
md"""
Julia has a rational number type to represent exact ratios of integers. Rationals are constructed using the [`//`](@ref) operator:
"""

# ╔═╡ ad55045c-9654-4fd5-8cb3-8a47dfe805f9
2//3

# ╔═╡ 7d495c46-104a-4a94-ab37-0829b3251816
md"""
If the numerator and denominator of a rational have common factors, they are reduced to lowest terms such that the denominator is non-negative:
"""

# ╔═╡ 4a92ffda-6c59-49c5-8f51-77960451440d
6//9

# ╔═╡ 92a973f8-e722-41bc-a0d8-d03775bc6685
-4//8

# ╔═╡ b1786e09-b46d-4c81-9f42-fa08a334ff17
5//-15

# ╔═╡ 1e68a93e-788a-46be-ba2c-d4ff084e00b2
-4//-12

# ╔═╡ 7c582331-9a1e-47df-9370-a239bfdee713
md"""
This normalized form for a ratio of integers is unique, so equality of rational values can be tested by checking for equality of the numerator and denominator. The standardized numerator and denominator of a rational value can be extracted using the [`numerator`](@ref) and [`denominator`](@ref) functions:
"""

# ╔═╡ 4b7861bb-580e-4ba2-995c-9dc0f5e3fcc9
numerator(2//3)

# ╔═╡ 1df2dac9-fa73-4a33-804c-d2065afd24de
denominator(2//3)

# ╔═╡ 449620a0-dad5-4a7d-baf2-85774cc4dfc5
md"""
Direct comparison of the numerator and denominator is generally not necessary, since the standard arithmetic and comparison operations are defined for rational values:
"""

# ╔═╡ 802109f8-6fae-4ace-b6f2-3f8a0ff290a1
2//3 == 6//9

# ╔═╡ 99a986bb-c552-45d0-b5e7-319ae8f953a0
2//3 == 9//27

# ╔═╡ 31bf0187-0b09-4865-bc81-68eb0378526c
3//7 < 1//2

# ╔═╡ 496fd943-c873-4fcf-bedc-0beb368380de
3//4 > 2//3

# ╔═╡ 644584f2-eff6-476c-ac00-ea8d54aac224
2//4 + 1//6

# ╔═╡ 6e532ad5-cb09-4ba7-b752-5d0933a388b1
5//12 - 1//4

# ╔═╡ 4b3ff3cf-36ec-4c9a-bd30-5e522b106932
5//8 * 3//12

# ╔═╡ f28c85a9-9192-4b90-962b-db2fbe287e13
6//5 / 10//7

# ╔═╡ 16212a91-ee45-41db-84e9-c10660022781
md"""
Rationals can easily be converted to floating-point numbers:
"""

# ╔═╡ 0d965eb5-7569-47e8-9a27-e999c1a526ab
float(3//4)

# ╔═╡ ae52247c-2e70-4748-b0a1-84920076e5ed
md"""
Conversion from rational to floating-point respects the following identity for any integral values of `a` and `b`, with the exception of the case `a == 0` and `b == 0`:
"""

# ╔═╡ 4e6da2c9-eb6e-4c27-adf9-de2d7e2eebb5
a = 1; b = 2;

# ╔═╡ f33b8932-b191-4ba6-83fc-3592b02819ea
isequal(float(a//b), a/b)

# ╔═╡ be4178e5-c2c3-4fee-9fc1-fd42dafffee3
md"""
Constructing infinite rational values is acceptable:
"""

# ╔═╡ 889a9cf9-2b8e-495e-902d-d528d20eca5a
5//0

# ╔═╡ 83c85861-a411-49ac-85ca-e6bc5ec73c11
x = -3//0

# ╔═╡ 7f935e24-7cbb-402b-9988-0386eadf50fb
typeof(x)

# ╔═╡ 29803385-5e5b-452d-86bc-8d7f82db4c9f
md"""
Trying to construct a [`NaN`](@ref) rational value, however, is invalid:
"""

# ╔═╡ f1e536e5-08c1-40a7-97e3-ba1e18156de3
0//0

# ╔═╡ 1f39f3eb-aab5-4d51-a034-5c0c4dd87251
md"""
As usual, the promotion system makes interactions with other numeric types effortless:
"""

# ╔═╡ b02960bb-f166-46ef-8379-13292826d938
3//5 + 1

# ╔═╡ 3d1e7911-15a5-4fac-847d-a0d17b4eacc8
3//5 - 0.5

# ╔═╡ ccfb4074-ec3e-4e30-8442-0d17c2ac4dd6
2//7 * (1 + 2im)

# ╔═╡ 2e3c766a-0184-4f96-a8ef-d9e3d146c955
2//7 * (1.5 + 2im)

# ╔═╡ cce1fb77-ffec-4974-9b62-5235ed36b751
3//2 / (1 + 2im)

# ╔═╡ 51094475-f297-498e-b011-493908c42107
1//2 + 2im

# ╔═╡ 3961765d-22c4-4b93-b14c-c5ca2aef1ce4
1 + 2//3im

# ╔═╡ 23450657-d2bc-46d9-8ab3-948093ad7e62
0.5 == 1//2

# ╔═╡ fec696bc-0d3d-49f1-9795-3f685deb0924
0.33 == 1//3

# ╔═╡ 7d7bc102-fe86-4f76-9d89-aa2dc195ca16
0.33 < 1//3

# ╔═╡ 1d42e8c4-a545-4588-a603-13f6255e209f
1//3 - 0.33

# ╔═╡ Cell order:
# ╟─d4f10538-c40f-4ebb-ae7b-716227cfcced
# ╟─256f4522-2e76-46e9-b925-c1e2c8a63ddc
# ╟─c73d34cd-fce2-48e9-ad0c-9870317ff704
# ╟─a09b2455-d02a-4f92-9bca-0b55341020a0
# ╠═75aa2e30-4617-4f80-a46b-d714fbe787dc
# ╟─7aa4f72d-e827-4796-9b07-3d2c426a57ad
# ╠═bf9c805c-2f3b-4834-807d-c8d8d5ee6d04
# ╠═b4559c2f-7865-4343-b158-67779c36d9dc
# ╠═3c675dbc-cc6a-4dfa-9b7e-39224119bf8c
# ╠═9b607cc5-4507-4589-8cdf-c7df402c79d9
# ╠═e97f29ac-b70f-4ed9-9620-35aa987c5311
# ╠═8681c9a7-097c-4511-813c-27cafb811d4d
# ╠═fae6fd36-3e98-4642-b0ab-b97cb1338b1e
# ╠═1d265700-2c67-4d2c-858a-ac5a0f055608
# ╠═d4fa6055-4cad-4c75-9d82-845db79620b1
# ╠═b7f4fa56-88f5-41b0-b6f2-13e4f8faf978
# ╟─5d6f2b79-7e83-46e1-8ef5-3163fbdc2407
# ╠═626b3c7c-9bb6-4bd3-87b4-0b2a4b88ae1d
# ╠═596bbd56-f737-4215-b22c-36cc7cdaa5b7
# ╠═d194f1ff-39bc-4cb8-a802-83f605b20f2a
# ╠═d48f1692-ddc8-43d3-8035-ec3803fa1d01
# ╠═6c0d1359-2d97-4048-84ae-db4568c6f0f4
# ╠═0e8538ab-2fa4-42a8-9d4d-263b17750bab
# ╠═bd303d0a-e21c-49d7-ba9b-5d3f022fc8f8
# ╠═2faae5dd-a3ed-47f2-9a31-0d6ca8b4809b
# ╠═0ea28097-7547-4f29-9732-21beb521f49a
# ╟─8bb203bf-2879-4356-9146-50270924ee1e
# ╟─b8b21fb9-7f19-4e75-8108-02ac9c34bf6e
# ╠═2e8c7109-f81f-40b9-b244-39ce9ba5cdcd
# ╠═786d88ab-a160-4f5a-acfe-d4dfa4656ac1
# ╠═0f4abaa4-e212-4c5a-8119-e51de8d931ec
# ╠═a3e1c662-f14e-4ee4-98da-4ff86a4725bb
# ╠═c6855bf6-c176-4582-985b-eb7bd3809464
# ╠═a5ac901c-00df-4a06-9465-47968b48208f
# ╠═171e9cbd-e46f-41e2-80fb-c9d511d4cfdd
# ╟─bdfe0842-8e8f-4e8b-b35d-51c99c73925e
# ╠═3086b975-24c9-48b3-a976-2dce16a8a0c0
# ╠═e9438722-4079-4ecb-994a-9f590410b40f
# ╠═42a14643-3fe0-4482-9a38-230ec06812a2
# ╠═bd9eb37e-3614-477b-9a85-63de20072b4e
# ╠═a0dfa4e3-e044-4d24-8d75-ae3040557825
# ╟─60d447f6-d0cf-47b8-8248-2167317f4237
# ╠═99a018b0-9dc9-4c7b-be04-c749f70c9342
# ╠═b221dc30-6e63-4dd9-b6ed-3684c894622d
# ╟─544833bb-d022-40bb-b824-c8350b1c9a3b
# ╠═da244250-40e7-4065-b88d-871624165eae
# ╟─3ae6ce47-e928-4136-ab6c-ad14a1b60aec
# ╠═5d62c504-b253-473e-ad2c-ff4dee654df8
# ╟─b2c2765a-8f91-4c2f-8d60-8e114c75851e
# ╟─c93aa8b2-32ff-465d-a812-8741103dbc7e
# ╠═ad6f2591-a2f4-442d-ae39-c487dd36135f
# ╠═e0e365fb-dee9-4947-9c5e-db44a92931d7
# ╟─b0df2597-481a-4119-a6a0-531e10d4fa26
# ╟─b56399f3-c91b-4556-aa30-2ccf9b5878d2
# ╠═ad55045c-9654-4fd5-8cb3-8a47dfe805f9
# ╟─7d495c46-104a-4a94-ab37-0829b3251816
# ╠═4a92ffda-6c59-49c5-8f51-77960451440d
# ╠═92a973f8-e722-41bc-a0d8-d03775bc6685
# ╠═b1786e09-b46d-4c81-9f42-fa08a334ff17
# ╠═1e68a93e-788a-46be-ba2c-d4ff084e00b2
# ╟─7c582331-9a1e-47df-9370-a239bfdee713
# ╠═4b7861bb-580e-4ba2-995c-9dc0f5e3fcc9
# ╠═1df2dac9-fa73-4a33-804c-d2065afd24de
# ╟─449620a0-dad5-4a7d-baf2-85774cc4dfc5
# ╠═802109f8-6fae-4ace-b6f2-3f8a0ff290a1
# ╠═99a986bb-c552-45d0-b5e7-319ae8f953a0
# ╠═31bf0187-0b09-4865-bc81-68eb0378526c
# ╠═496fd943-c873-4fcf-bedc-0beb368380de
# ╠═644584f2-eff6-476c-ac00-ea8d54aac224
# ╠═6e532ad5-cb09-4ba7-b752-5d0933a388b1
# ╠═4b3ff3cf-36ec-4c9a-bd30-5e522b106932
# ╠═f28c85a9-9192-4b90-962b-db2fbe287e13
# ╟─16212a91-ee45-41db-84e9-c10660022781
# ╠═0d965eb5-7569-47e8-9a27-e999c1a526ab
# ╟─ae52247c-2e70-4748-b0a1-84920076e5ed
# ╠═4e6da2c9-eb6e-4c27-adf9-de2d7e2eebb5
# ╠═f33b8932-b191-4ba6-83fc-3592b02819ea
# ╟─be4178e5-c2c3-4fee-9fc1-fd42dafffee3
# ╠═889a9cf9-2b8e-495e-902d-d528d20eca5a
# ╠═83c85861-a411-49ac-85ca-e6bc5ec73c11
# ╠═7f935e24-7cbb-402b-9988-0386eadf50fb
# ╟─29803385-5e5b-452d-86bc-8d7f82db4c9f
# ╠═f1e536e5-08c1-40a7-97e3-ba1e18156de3
# ╟─1f39f3eb-aab5-4d51-a034-5c0c4dd87251
# ╠═b02960bb-f166-46ef-8379-13292826d938
# ╠═3d1e7911-15a5-4fac-847d-a0d17b4eacc8
# ╠═ccfb4074-ec3e-4e30-8442-0d17c2ac4dd6
# ╠═2e3c766a-0184-4f96-a8ef-d9e3d146c955
# ╠═cce1fb77-ffec-4974-9b62-5235ed36b751
# ╠═51094475-f297-498e-b011-493908c42107
# ╠═3961765d-22c4-4b93-b14c-c5ca2aef1ce4
# ╠═23450657-d2bc-46d9-8ab3-948093ad7e62
# ╠═fec696bc-0d3d-49f1-9795-3f685deb0924
# ╠═7d7bc102-fe86-4f76-9d89-aa2dc195ca16
# ╠═1d42e8c4-a545-4588-a603-13f6255e209f
