### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ dcf4c450-fd26-4347-a94a-5de8c0dc249e
md"""
# [Missing Values](@id missing)
"""

# ╔═╡ abfe2c05-c96d-485e-84d1-f55b547a0efb
md"""
Julia provides support for representing missing values in the statistical sense, that is for situations where no value is available for a variable in an observation, but a valid value theoretically exists. Missing values are represented via the [`missing`](@ref) object, which is the singleton instance of the type [`Missing`](@ref). `missing` is equivalent to [`NULL` in SQL](https://en.wikipedia.org/wiki/NULL_(SQL)) and [`NA` in R](https://cran.r-project.org/doc/manuals/r-release/R-lang.html#NA-handling), and behaves like them in most situations.
"""

# ╔═╡ b8a4243a-9b89-48d1-9274-c8be927436fb
md"""
## Propagation of Missing Values
"""

# ╔═╡ 51297cb0-cbeb-46b1-a094-efb53b77febd
md"""
`missing` values *propagate* automatically when passed to standard mathematical operators and functions. For these functions, uncertainty about the value of one of the operands induces uncertainty about the result. In practice, this means a math operation involving a `missing` value generally returns `missing`
"""

# ╔═╡ 75a1c019-ac0a-4bc1-aa3a-aa46cd3ab365
missing + 1

# ╔═╡ 6bc9d547-9e28-48f2-8088-80d282ae04b2
"a" * missing

# ╔═╡ 2a33ab22-c71a-4ba5-a102-5a87760218ad
abs(missing)

# ╔═╡ 83fb82cb-9c1b-4330-b7b9-fa097f9ccc4e
md"""
As `missing` is a normal Julia object, this propagation rule only works for functions which have opted in to implement this behavior. This can be achieved either via a specific method defined for arguments of type `Missing`, or simply by accepting arguments of this type, and passing them to functions which propagate them (like standard math operators). Packages should consider whether it makes sense to propagate missing values when defining new functions, and define methods appropriately if that is the case. Passing a `missing` value to a function for which no method accepting arguments of type `Missing` is defined throws a [`MethodError`](@ref), just like for any other type.
"""

# ╔═╡ 3c67b75c-2414-4206-95b3-647bcd25dbbc
md"""
Functions that do not propagate `missing` values can be made to do so by wrapping them in the `passmissing` function provided by the [Missings.jl](https://github.com/JuliaData/Missings.jl) package. For example, `f(x)` becomes `passmissing(f)(x)`.
"""

# ╔═╡ bc68fbb8-89e7-41e3-b27c-0dd7aa0535d0
md"""
## Equality and Comparison Operators
"""

# ╔═╡ 410c40e0-579a-4e19-903d-fe5541c6c1ae
md"""
Standard equality and comparison operators follow the propagation rule presented above: if any of the operands is `missing`, the result is `missing`. Here are a few examples
"""

# ╔═╡ 8a42c9f2-f79c-453a-a739-a22f58b11dd2
missing == 1

# ╔═╡ f893649c-f8d6-4071-95a2-87688d9c7fbb
missing == missing

# ╔═╡ f24edd45-28f2-41cd-bcfb-31b9b4be0273
missing < 1

# ╔═╡ 668b6994-76e8-47e5-a5d5-d0128f0c85b7
2 >= missing

# ╔═╡ 188e028a-1d08-47f7-8a2f-207c01c9be43
md"""
In particular, note that `missing == missing` returns `missing`, so `==` cannot be used to test whether a value is missing. To test whether `x` is `missing`, use [`ismissing(x)`](@ref).
"""

# ╔═╡ f43ec5ec-0599-47a0-b875-a65da2ada2ad
md"""
Special comparison operators [`isequal`](@ref) and [`===`](@ref) are exceptions to the propagation rule: they always return a `Bool` value, even in the presence of `missing` values, considering `missing` as equal to `missing` and as different from any other value. They can therefore be used to test whether a value is `missing`
"""

# ╔═╡ 91f7745b-7968-455d-b43b-4c35e2457954
missing === 1

# ╔═╡ fcd95dc4-b2cd-4415-8a3f-3b77a31a5e96
isequal(missing, 1)

# ╔═╡ 66d41f11-3a34-488a-9d41-24a471d70582
missing === missing

# ╔═╡ 9a710b1f-689c-40fd-a9d5-ede676450a16
isequal(missing, missing)

# ╔═╡ ea83cf1a-6251-46d2-80f6-949cf5b7f31e
md"""
The [`isless`](@ref) operator is another exception: `missing` is considered as greater than any other value. This operator is used by [`sort`](@ref), which therefore places `missing` values after all other values.
"""

# ╔═╡ 1f9245e6-a4a4-4d9a-8210-233a1c467560
isless(1, missing)

# ╔═╡ 801b300e-6618-4945-8175-7ef0123db517
isless(missing, Inf)

# ╔═╡ 887e6683-964d-4699-9eaf-b6f24b5d5c80
isless(missing, missing)

# ╔═╡ c10fc2e7-16c3-4f19-9014-82d5fc8b03d7
md"""
## Logical operators
"""

# ╔═╡ 4280e789-0f53-41e1-9c5a-c94f3e9818e0
md"""
Logical (or boolean) operators [`|`](@ref), [`&`](@ref) and [`xor`](@ref) are another special case, as they only propagate `missing` values when it is logically required. For these operators, whether or not the result is uncertain depends on the particular operation, following the well-established rules of [*three-valued logic*](https://en.wikipedia.org/wiki/Three-valued_logic) which are also implemented by `NULL` in SQL and `NA` in R. This abstract definition actually corresponds to a relatively natural behavior which is best explained via concrete examples.
"""

# ╔═╡ 20bd6fe3-e3e0-452a-98a9-eefb22a1e983
md"""
Let us illustrate this principle with the logical \"or\" operator [`|`](@ref). Following the rules of boolean logic, if one of the operands is `true`, the value of the other operand does not have an influence on the result, which will always be `true`
"""

# ╔═╡ f62e22b8-4db3-4aa7-bce6-bac2d0cd182f
true | true

# ╔═╡ a357b28c-76a3-472a-a9ac-30fb036b50c5
true | false

# ╔═╡ 4256e75b-fb47-4581-8144-6e91d43a742c
false | true

# ╔═╡ f74f969a-cadf-486e-bb25-ac4b8e44615c
md"""
Based on this observation, we can conclude that if one of the operands is `true` and the other `missing`, we know that the result is `true` in spite of the uncertainty about the actual value of one of the operands. If we had been able to observe the actual value of the second operand, it could only be `true` or `false`, and in both cases the result would be `true`. Therefore, in this particular case, missingness does *not* propagate
"""

# ╔═╡ 00aa2a9d-b0e3-44ba-aaec-a4154fe45e99
true | missing

# ╔═╡ a8884900-3d23-49a3-b9fd-cb639f613f03
missing | true

# ╔═╡ 5bf90be1-8563-457f-a1bc-6db111914c11
md"""
On the contrary, if one of the operands is `false`, the result could be either `true` or `false` depending on the value of the other operand. Therefore, if that operand is `missing`, the result has to be `missing` too
"""

# ╔═╡ 1ae80d8b-2a44-4b0a-923f-024b9e9d954d
false | true

# ╔═╡ 081bc662-8c3c-43e7-b726-65a266d705f9
true | false

# ╔═╡ 7130525c-2aa4-4982-ade2-a50e0afc5242
false | false

# ╔═╡ cc89d77f-cc44-4892-97aa-7a73b82c3d4d
false | missing

# ╔═╡ d49318cc-fe4c-4c01-8a56-753600b313f5
missing | false

# ╔═╡ 1bb027c6-51c7-46bc-8be6-52b590065e96
md"""
The behavior of the logical \"and\" operator [`&`](@ref) is similar to that of the `|` operator, with the difference that missingness does not propagate when one of the operands is `false`. For example, when that is the case of the first operand
"""

# ╔═╡ 7e4d90a5-8863-4561-88d7-7ba9ba8845f4
false & false

# ╔═╡ 31435f4d-5aa9-49d6-ad9a-5dfa221e69c7
false & true

# ╔═╡ 7e30f00a-efa9-4e7f-a3fb-96cfe10eb696
false & missing

# ╔═╡ a11505af-7fec-4015-a657-90567ed25e92
md"""
On the other hand, missingness propagates when one of the operands is `true`, for example the first one
"""

# ╔═╡ 036b81ae-f1c0-4e07-8a6a-23f42784ec56
true & true

# ╔═╡ b4be7f27-b41f-4d1b-81db-30c8515c1519
true & false

# ╔═╡ dda15055-022a-4088-8c2e-3405200e46f0
true & missing

# ╔═╡ 59427303-038d-4c79-841d-6680ffd98802
md"""
Finally, the \"exclusive or\" logical operator [`xor`](@ref) always propagates `missing` values, since both operands always have an effect on the result. Also note that the negation operator [`!`](@ref) returns `missing` when the operand is `missing` just like other unary operators.
"""

# ╔═╡ 79f485e1-2ff5-46ef-9cad-a3d22edb335f
md"""
## Control Flow and Short-Circuiting Operators
"""

# ╔═╡ f0dc87d0-5b68-4393-a589-e1ba6bc9669e
md"""
Control flow operators including [`if`](@ref), [`while`](@ref) and the [ternary operator](@ref man-conditional-evaluation) `x ? y : z` do not allow for missing values. This is because of the uncertainty about whether the actual value would be `true` or `false` if we could observe it, which implies that we do not know how the program should behave. A [`TypeError`](@ref) is thrown as soon as a `missing` value is encountered in this context
"""

# ╔═╡ e90ed03b-1ed6-4e57-8f89-9aaf47a54351
if missing
     println("here")
 end

# ╔═╡ c3d2ebcc-08c2-485b-8436-c73d609c46dc
md"""
For the same reason, contrary to logical operators presented above, the short-circuiting boolean operators [`&&`](@ref) and [`||`](@ref) do not allow for `missing` values in situations where the value of the operand determines whether the next operand is evaluated or not. For example
"""

# ╔═╡ 027786af-cb83-4483-8594-3d64cad46db1
missing || false

# ╔═╡ 5c5fa5e5-2d99-439f-b522-fe5e9a23681b
missing && false

# ╔═╡ b1500162-4fc5-4089-a7d9-b19bb7cde4e1
true && missing && false

# ╔═╡ 695fb15c-5b67-445b-9729-14562a8bce5b
md"""
On the other hand, no error is thrown when the result can be determined without the `missing` values. This is the case when the code short-circuits before evaluating the `missing` operand, and when the `missing` operand is the last one
"""

# ╔═╡ ccc65384-6966-4b43-a927-52c1f8f80240
true && missing

# ╔═╡ a728e6d7-8885-4de0-8638-586a22d92368
false && missing

# ╔═╡ 702a040a-5f1b-47e1-88d4-8b9317b3fbe5
md"""
## Arrays With Missing Values
"""

# ╔═╡ efd751f8-5c41-4df7-b819-af4e7754eccd
md"""
Arrays containing missing values can be created like other arrays
"""

# ╔═╡ 556a5791-86aa-485b-aaca-9fc43b497df8
[1, missing]

# ╔═╡ 303ecf8f-8add-43c5-97ef-14e01f3389bf
md"""
As this example shows, the element type of such arrays is `Union{Missing, T}`, with `T` the type of the non-missing values. This simply reflects the fact that array entries can be either of type `T` (here, `Int64`) or of type `Missing`. This kind of array uses an efficient memory storage equivalent to an `Array{T}` holding the actual values combined with an `Array{UInt8}` indicating the type of the entry (i.e. whether it is `Missing` or `T`).
"""

# ╔═╡ 9e89e623-6210-471c-8561-0dece18c4383
md"""
Arrays allowing for missing values can be constructed with the standard syntax. Use `Array{Union{Missing, T}}(missing, dims)` to create arrays filled with missing values:
"""

# ╔═╡ 26a4146d-4773-4b83-bd63-6123480138e7
Array{Union{Missing, String}}(missing, 2, 3)

# ╔═╡ 7c5abc10-0d96-4fb7-99ff-f1481854ffe2
md"""
!!! note
    Using `undef` or `similar` may currently give an array filled with `missing`, but this is not the correct way to obtain such an array. Use a `missing` constructor as shown above instead.
"""

# ╔═╡ d759cb75-b14c-4b5f-ba68-9306110573b4
md"""
An array allowing for `missing` values but which does not contain any such value can be converted back to an array which does not allow for missing values using [`convert`](@ref). If the array contains `missing` values, a `MethodError` is thrown during conversion
"""

# ╔═╡ ed662f9e-5b49-4a9f-b8d9-e6ce2a9ddf35
x = Union{Missing, String}["a", "b"]

# ╔═╡ 5f43dd97-49da-4640-ae93-c0f895d29e57
convert(Array{String}, x)

# ╔═╡ 5616942a-5d6b-4de3-b79c-97d4f3f16b7b
y = Union{Missing, String}[missing, "b"]

# ╔═╡ 5d663e79-2265-4a17-b888-f1209f8f994f
convert(Array{String}, y)

# ╔═╡ 29d93a72-15e5-416a-8dea-0c4b0022c9d9
md"""
## Skipping Missing Values
"""

# ╔═╡ 6cbe4881-796a-4c04-8de3-b4e885718eef
md"""
Since `missing` values propagate with standard mathematical operators, reduction functions return `missing` when called on arrays which contain missing values
"""

# ╔═╡ e503e790-e3ee-436c-9cf7-8ce92082b2eb
sum([1, missing])

# ╔═╡ ff0f6d08-5639-44fd-ba4c-1078bd7b46df
md"""
In this situation, use the [`skipmissing`](@ref) function to skip missing values
"""

# ╔═╡ c18c3dad-ff78-4670-9379-d30e9612994e
sum(skipmissing([1, missing]))

# ╔═╡ 89562ed2-cc92-4c16-8478-179e423e715d
md"""
This convenience function returns an iterator which filters out `missing` values efficiently. It can therefore be used with any function which supports iterators
"""

# ╔═╡ aee3d37f-ac4a-4e54-8c6c-ab4c0b2fda7b
x = skipmissing([3, missing, 2, 1])

# ╔═╡ 972d7e79-e764-4c4f-a693-731b3a7b1905
maximum(x)

# ╔═╡ 79d4b573-81b3-47ab-94f6-9fe69c3bdd78
mean(x)

# ╔═╡ b233d7fc-3f35-445f-9644-a376c14bde3e
mapreduce(sqrt, +, x)

# ╔═╡ 93d9aef7-faa4-4a01-8a60-2bc0edce4945
md"""
Objects created by calling `skipmissing` on an array can be indexed using indices from the parent array. Indices corresponding to missing values are not valid for these objects and an error is thrown when trying to use them (they are also skipped by `keys` and `eachindex`)
"""

# ╔═╡ 9a45b934-a885-45a3-8deb-e83ff2130316
x[1]

# ╔═╡ 34c3c157-5bc7-4247-a704-90e6cf186d2f
x[2]

# ╔═╡ 930fd5b4-6440-4a89-97d7-cb449b665dcf
md"""
This allows functions which operate on indices to work in combination with `skipmissing`. This is notably the case for search and find functions, which return indices valid for the object returned by `skipmissing` which are also the indices of the matching entries *in the parent array*
"""

# ╔═╡ 844dfa05-5239-487e-8ade-3b8d700973fa
findall(==(1), x)

# ╔═╡ 0955f9af-2910-403d-9687-b6d36e21088b
findfirst(!iszero, x)

# ╔═╡ a7100726-dd5c-47e2-844e-0c017ee2cc11
argmax(x)

# ╔═╡ 02a14a22-7e59-4268-a27d-9be02c3a0092
md"""
Use [`collect`](@ref) to extract non-`missing` values and store them in an array
"""

# ╔═╡ 30645dc2-aa6b-44b3-a283-f8001bb087a7
collect(x)

# ╔═╡ 39ab9fb9-5cbd-4ee7-9a81-30ba3f0e5444
md"""
## Logical Operations on Arrays
"""

# ╔═╡ 0ed47405-6a13-47ec-9c3d-eae3daef848e
md"""
The three-valued logic described above for logical operators is also used by logical functions applied to arrays. Thus, array equality tests using the [`==`](@ref) operator return `missing` whenever the result cannot be determined without knowing the actual value of the `missing` entry. In practice, this means that `missing` is returned if all non-missing values of the compared arrays are equal, but one or both arrays contain missing values (possibly at different positions)
"""

# ╔═╡ 472f3d1f-ac83-4ded-b4eb-697a3a8ff57c
[1, missing] == [2, missing]

# ╔═╡ ee2d4962-3da9-4e58-a34d-2ef90a1c6b94
[1, missing] == [1, missing]

# ╔═╡ d7256341-8074-45db-9ee7-c6b7812dda2a
[1, 2, missing] == [1, missing, 2]

# ╔═╡ cfddddaf-9cd3-4dcd-8bff-e9b1849656f0
md"""
As for single values, use [`isequal`](@ref) to treat `missing` values as equal to other `missing` values but different from non-missing values
"""

# ╔═╡ e177c0a6-408f-4eb9-9aec-04bd94dcca5c
isequal([1, missing], [1, missing])

# ╔═╡ e9cc0be2-85cf-4df3-9489-d0102d7e75c7
isequal([1, 2, missing], [1, missing, 2])

# ╔═╡ 5b72d828-0f6c-4317-bd77-55f3477e6c41
md"""
Functions [`any`](@ref) and [`all`](@ref) also follow the rules of three-valued logic, returning `missing` when the result cannot be determined
"""

# ╔═╡ 49c649c3-f4d3-497f-a17a-1dc342c6572e
all([true, missing])

# ╔═╡ 3bf7e9ca-27bb-4d22-9315-1e729e8312ec
all([false, missing])

# ╔═╡ dbca7ab2-81ce-428f-8940-dc0742f6700a
any([true, missing])

# ╔═╡ 827a5087-116e-4bb2-9073-e57d418c37ce
any([false, missing])

# ╔═╡ Cell order:
# ╟─dcf4c450-fd26-4347-a94a-5de8c0dc249e
# ╟─abfe2c05-c96d-485e-84d1-f55b547a0efb
# ╟─b8a4243a-9b89-48d1-9274-c8be927436fb
# ╟─51297cb0-cbeb-46b1-a094-efb53b77febd
# ╠═75a1c019-ac0a-4bc1-aa3a-aa46cd3ab365
# ╠═6bc9d547-9e28-48f2-8088-80d282ae04b2
# ╠═2a33ab22-c71a-4ba5-a102-5a87760218ad
# ╟─83fb82cb-9c1b-4330-b7b9-fa097f9ccc4e
# ╟─3c67b75c-2414-4206-95b3-647bcd25dbbc
# ╟─bc68fbb8-89e7-41e3-b27c-0dd7aa0535d0
# ╟─410c40e0-579a-4e19-903d-fe5541c6c1ae
# ╠═8a42c9f2-f79c-453a-a739-a22f58b11dd2
# ╠═f893649c-f8d6-4071-95a2-87688d9c7fbb
# ╠═f24edd45-28f2-41cd-bcfb-31b9b4be0273
# ╠═668b6994-76e8-47e5-a5d5-d0128f0c85b7
# ╟─188e028a-1d08-47f7-8a2f-207c01c9be43
# ╟─f43ec5ec-0599-47a0-b875-a65da2ada2ad
# ╠═91f7745b-7968-455d-b43b-4c35e2457954
# ╠═fcd95dc4-b2cd-4415-8a3f-3b77a31a5e96
# ╠═66d41f11-3a34-488a-9d41-24a471d70582
# ╠═9a710b1f-689c-40fd-a9d5-ede676450a16
# ╟─ea83cf1a-6251-46d2-80f6-949cf5b7f31e
# ╠═1f9245e6-a4a4-4d9a-8210-233a1c467560
# ╠═801b300e-6618-4945-8175-7ef0123db517
# ╠═887e6683-964d-4699-9eaf-b6f24b5d5c80
# ╟─c10fc2e7-16c3-4f19-9014-82d5fc8b03d7
# ╟─4280e789-0f53-41e1-9c5a-c94f3e9818e0
# ╟─20bd6fe3-e3e0-452a-98a9-eefb22a1e983
# ╠═f62e22b8-4db3-4aa7-bce6-bac2d0cd182f
# ╠═a357b28c-76a3-472a-a9ac-30fb036b50c5
# ╠═4256e75b-fb47-4581-8144-6e91d43a742c
# ╟─f74f969a-cadf-486e-bb25-ac4b8e44615c
# ╠═00aa2a9d-b0e3-44ba-aaec-a4154fe45e99
# ╠═a8884900-3d23-49a3-b9fd-cb639f613f03
# ╟─5bf90be1-8563-457f-a1bc-6db111914c11
# ╠═1ae80d8b-2a44-4b0a-923f-024b9e9d954d
# ╠═081bc662-8c3c-43e7-b726-65a266d705f9
# ╠═7130525c-2aa4-4982-ade2-a50e0afc5242
# ╠═cc89d77f-cc44-4892-97aa-7a73b82c3d4d
# ╠═d49318cc-fe4c-4c01-8a56-753600b313f5
# ╟─1bb027c6-51c7-46bc-8be6-52b590065e96
# ╠═7e4d90a5-8863-4561-88d7-7ba9ba8845f4
# ╠═31435f4d-5aa9-49d6-ad9a-5dfa221e69c7
# ╠═7e30f00a-efa9-4e7f-a3fb-96cfe10eb696
# ╟─a11505af-7fec-4015-a657-90567ed25e92
# ╠═036b81ae-f1c0-4e07-8a6a-23f42784ec56
# ╠═b4be7f27-b41f-4d1b-81db-30c8515c1519
# ╠═dda15055-022a-4088-8c2e-3405200e46f0
# ╟─59427303-038d-4c79-841d-6680ffd98802
# ╟─79f485e1-2ff5-46ef-9cad-a3d22edb335f
# ╟─f0dc87d0-5b68-4393-a589-e1ba6bc9669e
# ╠═e90ed03b-1ed6-4e57-8f89-9aaf47a54351
# ╟─c3d2ebcc-08c2-485b-8436-c73d609c46dc
# ╠═027786af-cb83-4483-8594-3d64cad46db1
# ╠═5c5fa5e5-2d99-439f-b522-fe5e9a23681b
# ╠═b1500162-4fc5-4089-a7d9-b19bb7cde4e1
# ╟─695fb15c-5b67-445b-9729-14562a8bce5b
# ╠═ccc65384-6966-4b43-a927-52c1f8f80240
# ╠═a728e6d7-8885-4de0-8638-586a22d92368
# ╟─702a040a-5f1b-47e1-88d4-8b9317b3fbe5
# ╟─efd751f8-5c41-4df7-b819-af4e7754eccd
# ╠═556a5791-86aa-485b-aaca-9fc43b497df8
# ╟─303ecf8f-8add-43c5-97ef-14e01f3389bf
# ╟─9e89e623-6210-471c-8561-0dece18c4383
# ╠═26a4146d-4773-4b83-bd63-6123480138e7
# ╟─7c5abc10-0d96-4fb7-99ff-f1481854ffe2
# ╟─d759cb75-b14c-4b5f-ba68-9306110573b4
# ╠═ed662f9e-5b49-4a9f-b8d9-e6ce2a9ddf35
# ╠═5f43dd97-49da-4640-ae93-c0f895d29e57
# ╠═5616942a-5d6b-4de3-b79c-97d4f3f16b7b
# ╠═5d663e79-2265-4a17-b888-f1209f8f994f
# ╟─29d93a72-15e5-416a-8dea-0c4b0022c9d9
# ╟─6cbe4881-796a-4c04-8de3-b4e885718eef
# ╠═e503e790-e3ee-436c-9cf7-8ce92082b2eb
# ╟─ff0f6d08-5639-44fd-ba4c-1078bd7b46df
# ╠═c18c3dad-ff78-4670-9379-d30e9612994e
# ╟─89562ed2-cc92-4c16-8478-179e423e715d
# ╠═aee3d37f-ac4a-4e54-8c6c-ab4c0b2fda7b
# ╠═972d7e79-e764-4c4f-a693-731b3a7b1905
# ╠═79d4b573-81b3-47ab-94f6-9fe69c3bdd78
# ╠═b233d7fc-3f35-445f-9644-a376c14bde3e
# ╟─93d9aef7-faa4-4a01-8a60-2bc0edce4945
# ╠═9a45b934-a885-45a3-8deb-e83ff2130316
# ╠═34c3c157-5bc7-4247-a704-90e6cf186d2f
# ╟─930fd5b4-6440-4a89-97d7-cb449b665dcf
# ╠═844dfa05-5239-487e-8ade-3b8d700973fa
# ╠═0955f9af-2910-403d-9687-b6d36e21088b
# ╠═a7100726-dd5c-47e2-844e-0c017ee2cc11
# ╟─02a14a22-7e59-4268-a27d-9be02c3a0092
# ╠═30645dc2-aa6b-44b3-a283-f8001bb087a7
# ╟─39ab9fb9-5cbd-4ee7-9a81-30ba3f0e5444
# ╟─0ed47405-6a13-47ec-9c3d-eae3daef848e
# ╠═472f3d1f-ac83-4ded-b4eb-697a3a8ff57c
# ╠═ee2d4962-3da9-4e58-a34d-2ef90a1c6b94
# ╠═d7256341-8074-45db-9ee7-c6b7812dda2a
# ╟─cfddddaf-9cd3-4dcd-8bff-e9b1849656f0
# ╠═e177c0a6-408f-4eb9-9aec-04bd94dcca5c
# ╠═e9cc0be2-85cf-4df3-9489-d0102d7e75c7
# ╟─5b72d828-0f6c-4317-bd77-55f3477e6c41
# ╠═49c649c3-f4d3-497f-a17a-1dc342c6572e
# ╠═3bf7e9ca-27bb-4d22-9315-1e729e8312ec
# ╠═dbca7ab2-81ce-428f-8940-dc0742f6700a
# ╠═827a5087-116e-4bb2-9073-e57d418c37ce
