### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ 03cfa2b8-9e19-11eb-184e-8bdf1457b50d
md"""
# [Missing Values](@id missing)
"""

# ╔═╡ 03cfa308-9e19-11eb-0e81-0597d5b3133b
md"""
Julia provides support for representing missing values in the statistical sense, that is for situations where no value is available for a variable in an observation, but a valid value theoretically exists. Missing values are represented via the [`missing`](@ref) object, which is the singleton instance of the type [`Missing`](@ref). `missing` is equivalent to [`NULL` in SQL](https://en.wikipedia.org/wiki/NULL_(SQL)) and [`NA` in R](https://cran.r-project.org/doc/manuals/r-release/R-lang.html#NA-handling), and behaves like them in most situations.
"""

# ╔═╡ 03cfa326-9e19-11eb-32b7-f7dcbfda70c0
md"""
## Propagation of Missing Values
"""

# ╔═╡ 03cfa36c-9e19-11eb-0967-ef6cb8d984d5
md"""
`missing` values *propagate* automatically when passed to standard mathematical operators and functions. For these functions, uncertainty about the value of one of the operands induces uncertainty about the result. In practice, this means a math operation involving a `missing` value generally returns `missing`
"""

# ╔═╡ 03cfa740-9e19-11eb-15b4-0125f1fb5373
missing + 1

# ╔═╡ 03cfa74a-9e19-11eb-1e21-7b3be4cbb379
"a" * missing

# ╔═╡ 03cfa74a-9e19-11eb-356b-55ab59455957
abs(missing)

# ╔═╡ 03cfa790-9e19-11eb-1948-73d21d51801a
md"""
As `missing` is a normal Julia object, this propagation rule only works for functions which have opted in to implement this behavior. This can be achieved either via a specific method defined for arguments of type `Missing`, or simply by accepting arguments of this type, and passing them to functions which propagate them (like standard math operators). Packages should consider whether it makes sense to propagate missing values when defining new functions, and define methods appropriately if that is the case. Passing a `missing` value to a function for which no method accepting arguments of type `Missing` is defined throws a [`MethodError`](@ref), just like for any other type.
"""

# ╔═╡ 03cfa7ae-9e19-11eb-1848-a52aa664093b
md"""
Functions that do not propagate `missing` values can be made to do so by wrapping them in the `passmissing` function provided by the [Missings.jl](https://github.com/JuliaData/Missings.jl) package. For example, `f(x)` becomes `passmissing(f)(x)`.
"""

# ╔═╡ 03cfa7c2-9e19-11eb-10e2-ada8fad58fe9
md"""
## Equality and Comparison Operators
"""

# ╔═╡ 03cfa7ea-9e19-11eb-1529-bf07fa9db6c5
md"""
Standard equality and comparison operators follow the propagation rule presented above: if any of the operands is `missing`, the result is `missing`. Here are a few examples
"""

# ╔═╡ 03cfabd0-9e19-11eb-14c5-1f1089ce6367
missing == 1

# ╔═╡ 03cfabdc-9e19-11eb-35f4-e331b458ac81
missing == missing

# ╔═╡ 03cfabe6-9e19-11eb-2be1-81e4f4bfe48b
missing < 1

# ╔═╡ 03cfabe6-9e19-11eb-10ee-e38710a1675c
2 >= missing

# ╔═╡ 03cfac36-9e19-11eb-2abf-5f5df2ecbb12
md"""
In particular, note that `missing == missing` returns `missing`, so `==` cannot be used to test whether a value is missing. To test whether `x` is `missing`, use [`ismissing(x)`](@ref).
"""

# ╔═╡ 03cfac5e-9e19-11eb-3d96-772e2834e33c
md"""
Special comparison operators [`isequal`](@ref) and [`===`](@ref) are exceptions to the propagation rule: they always return a `Bool` value, even in the presence of `missing` values, considering `missing` as equal to `missing` and as different from any other value. They can therefore be used to test whether a value is `missing`
"""

# ╔═╡ 03cfafec-9e19-11eb-15c2-21353b811739
missing === 1

# ╔═╡ 03cfb000-9e19-11eb-2029-e11c89075f08
isequal(missing, 1)

# ╔═╡ 03cfb00a-9e19-11eb-1b3f-93840bb4c6e9
missing === missing

# ╔═╡ 03cfb00a-9e19-11eb-161f-d128735c0dce
isequal(missing, missing)

# ╔═╡ 03cfb03c-9e19-11eb-1910-9d6c9883a05c
md"""
The [`isless`](@ref) operator is another exception: `missing` is considered as greater than any other value. This operator is used by [`sort`](@ref), which therefore places `missing` values after all other values.
"""

# ╔═╡ 03cfb280-9e19-11eb-102a-7f6a3df1bbc6
isless(1, missing)

# ╔═╡ 03cfb28a-9e19-11eb-28a0-872263970d44
isless(missing, Inf)

# ╔═╡ 03cfb294-9e19-11eb-2251-e16abab09249
isless(missing, missing)

# ╔═╡ 03cfb29e-9e19-11eb-07c0-45d6bcb264ba
md"""
## Logical operators
"""

# ╔═╡ 03cfb2e4-9e19-11eb-37b3-efe30d865069
md"""
Logical (or boolean) operators [`|`](@ref), [`&`](@ref) and [`xor`](@ref) are another special case, as they only propagate `missing` values when it is logically required. For these operators, whether or not the result is uncertain depends on the particular operation, following the well-established rules of [*three-valued logic*](https://en.wikipedia.org/wiki/Three-valued_logic) which are also implemented by `NULL` in SQL and `NA` in R. This abstract definition actually corresponds to a relatively natural behavior which is best explained via concrete examples.
"""

# ╔═╡ 03cfb30c-9e19-11eb-2e2b-b7a91fc14d4a
md"""
Let us illustrate this principle with the logical "or" operator [`|`](@ref). Following the rules of boolean logic, if one of the operands is `true`, the value of the other operand does not have an influence on the result, which will always be `true`
"""

# ╔═╡ 03cfb51e-9e19-11eb-0649-bb946ab101b1
true | true

# ╔═╡ 03cfb51e-9e19-11eb-1679-c99a7c093829
true | false

# ╔═╡ 03cfb528-9e19-11eb-215c-4f4054320752
false | true

# ╔═╡ 03cfb56e-9e19-11eb-10bb-19c288897f0d
md"""
Based on this observation, we can conclude that if one of the operands is `true` and the other `missing`, we know that the result is `true` in spite of the uncertainty about the actual value of one of the operands. If we had been able to observe the actual value of the second operand, it could only be `true` or `false`, and in both cases the result would be `true`. Therefore, in this particular case, missingness does *not* propagate
"""

# ╔═╡ 03cfb6ac-9e19-11eb-11ff-5d9b5bd6404e
true | missing

# ╔═╡ 03cfb6b8-9e19-11eb-356a-35d88039776f
missing | true

# ╔═╡ 03cfb6d6-9e19-11eb-148a-3171303e7aea
md"""
On the contrary, if one of the operands is `false`, the result could be either `true` or `false` depending on the value of the other operand. Therefore, if that operand is `missing`, the result has to be `missing` too
"""

# ╔═╡ 03cfb9d8-9e19-11eb-15ab-e988392a0e81
false | true

# ╔═╡ 03cfb9e2-9e19-11eb-17da-a17462a38095
true | false

# ╔═╡ 03cfb9e2-9e19-11eb-32fd-f54c373e0dda
false | false

# ╔═╡ 03cfb9e2-9e19-11eb-2d69-a315acf78bf2
false | missing

# ╔═╡ 03cfba0a-9e19-11eb-32fa-e1b8a1a0f084
missing | false

# ╔═╡ 03cfba32-9e19-11eb-05ae-65e1ccc207a3
md"""
The behavior of the logical "and" operator [`&`](@ref) is similar to that of the `|` operator, with the difference that missingness does not propagate when one of the operands is `false`. For example, when that is the case of the first operand
"""

# ╔═╡ 03cfbc08-9e19-11eb-0c72-db81789b418c
false & false

# ╔═╡ 03cfbc08-9e19-11eb-127d-3124793a1156
false & true

# ╔═╡ 03cfbc12-9e19-11eb-3ec2-2f0235f7721f
false & missing

# ╔═╡ 03cfbc30-9e19-11eb-26cb-2bb50fa17e04
md"""
On the other hand, missingness propagates when one of the operands is `true`, for example the first one
"""

# ╔═╡ 03cfbdfc-9e19-11eb-0d21-a553f36aa0af
true & true

# ╔═╡ 03cfbdfc-9e19-11eb-375b-d3c69158c34d
true & false

# ╔═╡ 03cfbdfc-9e19-11eb-1b79-2b09e13802ec
true & missing

# ╔═╡ 03cfbe42-9e19-11eb-35e3-5fcc5a21b856
md"""
Finally, the "exclusive or" logical operator [`xor`](@ref) always propagates `missing` values, since both operands always have an effect on the result. Also note that the negation operator [`!`](@ref) returns `missing` when the operand is `missing` just like other unary operators.
"""

# ╔═╡ 03cfbe4c-9e19-11eb-1acd-29baabdc9e84
md"""
## Control Flow and Short-Circuiting Operators
"""

# ╔═╡ 03cfbe86-9e19-11eb-2c4d-59c0721797ea
md"""
Control flow operators including [`if`](@ref), [`while`](@ref) and the [ternary operator](@ref man-conditional-evaluation) `x ? y : z` do not allow for missing values. This is because of the uncertainty about whether the actual value would be `true` or `false` if we could observe it, which implies that we do not know how the program should behave. A [`TypeError`](@ref) is thrown as soon as a `missing` value is encountered in this context
"""

# ╔═╡ 03cfc09a-9e19-11eb-399b-bf6a3d33527d
if missing
           println("here")
       end

# ╔═╡ 03cfc0c4-9e19-11eb-06fd-6f333958aa64
md"""
For the same reason, contrary to logical operators presented above, the short-circuiting boolean operators [`&&`](@ref) and [`||`](@ref) do not allow for `missing` values in situations where the value of the operand determines whether the next operand is evaluated or not. For example
"""

# ╔═╡ 03cfc360-9e19-11eb-2c19-196e265f1664
missing || false

# ╔═╡ 03cfc36a-9e19-11eb-06f6-69dcdf6ab2fd
missing && false

# ╔═╡ 03cfc394-9e19-11eb-2e94-77c09d9813a6
true && missing && false

# ╔═╡ 03cfc3b0-9e19-11eb-31a9-e7efb9a45d4d
md"""
On the other hand, no error is thrown when the result can be determined without the `missing` values. This is the case when the code short-circuits before evaluating the `missing` operand, and when the `missing` operand is the last one
"""

# ╔═╡ 03cfc518-9e19-11eb-259b-b540de142be1
true && missing

# ╔═╡ 03cfc518-9e19-11eb-2ff0-479ae31808c1
false && missing

# ╔═╡ 03cfc536-9e19-11eb-34f3-7d4936a71832
md"""
## Arrays With Missing Values
"""

# ╔═╡ 03cfc54a-9e19-11eb-2fb8-a9760f008261
md"""
Arrays containing missing values can be created like other arrays
"""

# ╔═╡ 03cfc64e-9e19-11eb-0258-c54ac2490f44
[1, missing]

# ╔═╡ 03cfc676-9e19-11eb-0a3d-cb8421272eb8
md"""
As this example shows, the element type of such arrays is `Union{Missing, T}`, with `T` the type of the non-missing values. This simply reflects the fact that array entries can be either of type `T` (here, `Int64`) or of type `Missing`. This kind of array uses an efficient memory storage equivalent to an `Array{T}` holding the actual values combined with an `Array{UInt8}` indicating the type of the entry (i.e. whether it is `Missing` or `T`).
"""

# ╔═╡ 03cfc69e-9e19-11eb-1d29-87afd2e005ba
md"""
Arrays allowing for missing values can be constructed with the standard syntax. Use `Array{Union{Missing, T}}(missing, dims)` to create arrays filled with missing values:
"""

# ╔═╡ 03cfc87e-9e19-11eb-08ab-87715e2a7740
Array{Union{Missing, String}}(missing, 2, 3)

# ╔═╡ 03cfc934-9e19-11eb-1c15-f71c05bf7a0d
md"""
!!! note
    Using `undef` or `similar` may currently give an array filled with `missing`, but this is not the correct way to obtain such an array. Use a `missing` constructor as shown above instead.
"""

# ╔═╡ 03cfc95a-9e19-11eb-206a-492fcedb30a3
md"""
An array allowing for `missing` values but which does not contain any such value can be converted back to an array which does not allow for missing values using [`convert`](@ref). If the array contains `missing` values, a `MethodError` is thrown during conversion
"""

# ╔═╡ 03cfcf72-9e19-11eb-3c8c-a17e7f037e53
x = Union{Missing, String}["a", "b"]

# ╔═╡ 03cfcf7c-9e19-11eb-1850-255f01dc0438
convert(Array{String}, x)

# ╔═╡ 03cfcf7c-9e19-11eb-1542-4bad8f525443
y = Union{Missing, String}[missing, "b"]

# ╔═╡ 03cfcf86-9e19-11eb-0659-279c5bf63817
convert(Array{String}, y)

# ╔═╡ 03cfcfa4-9e19-11eb-1104-996a1940660f
md"""
## Skipping Missing Values
"""

# ╔═╡ 03cfcfb8-9e19-11eb-0fc7-6f0c1c04c480
md"""
Since `missing` values propagate with standard mathematical operators, reduction functions return `missing` when called on arrays which contain missing values
"""

# ╔═╡ 03cfd12a-9e19-11eb-028d-292bfe825d09
sum([1, missing])

# ╔═╡ 03cfd140-9e19-11eb-2738-1f463c828d7a
md"""
In this situation, use the [`skipmissing`](@ref) function to skip missing values
"""

# ╔═╡ 03cfd2ec-9e19-11eb-15f5-d3bef94b805d
sum(skipmissing([1, missing]))

# ╔═╡ 03cfd30c-9e19-11eb-3ea5-e547f42be464
md"""
This convenience function returns an iterator which filters out `missing` values efficiently. It can therefore be used with any function which supports iterators
"""

# ╔═╡ 03cfd760-9e19-11eb-3273-b73fd86e37d7
x = skipmissing([3, missing, 2, 1])

# ╔═╡ 03cfd760-9e19-11eb-0ac4-c3e69e82a4b2
maximum(x)

# ╔═╡ 03cfd77e-9e19-11eb-16bc-0ddd774e18e4
mean(x)

# ╔═╡ 03cfd77e-9e19-11eb-21c9-5908763d250b
mapreduce(sqrt, +, x)

# ╔═╡ 03cfd79c-9e19-11eb-0b45-63d3375a2573
md"""
Objects created by calling `skipmissing` on an array can be indexed using indices from the parent array. Indices corresponding to missing values are not valid for these objects and an error is thrown when trying to use them (they are also skipped by `keys` and `eachindex`)
"""

# ╔═╡ 03cfd918-9e19-11eb-1ec0-e18ed15b165c
x[1]

# ╔═╡ 03cfd92c-9e19-11eb-2c72-dff2fe16245a
x[2]

# ╔═╡ 03cfd94a-9e19-11eb-27e1-135008aca68e
md"""
This allows functions which operate on indices to work in combination with `skipmissing`. This is notably the case for search and find functions, which return indices valid for the object returned by `skipmissing` which are also the indices of the matching entries *in the parent array*
"""

# ╔═╡ 03cfdca6-9e19-11eb-0bc5-2ffdf8b07f7d
findall(==(1), x)

# ╔═╡ 03cfdca6-9e19-11eb-12c1-156d3dcebc7c
findfirst(!iszero, x)

# ╔═╡ 03cfdcae-9e19-11eb-3d38-8f1f6b55ebb8
argmax(x)

# ╔═╡ 03cfdcd8-9e19-11eb-0d88-83f682065aea
md"""
Use [`collect`](@ref) to extract non-`missing` values and store them in an array
"""

# ╔═╡ 03cfdd84-9e19-11eb-358a-d76f86efb340
collect(x)

# ╔═╡ 03cfdd96-9e19-11eb-3ed2-2bd05dd0b7f6
md"""
## Logical Operations on Arrays
"""

# ╔═╡ 03cfddbe-9e19-11eb-2afd-efdd89d1f3f6
md"""
The three-valued logic described above for logical operators is also used by logical functions applied to arrays. Thus, array equality tests using the [`==`](@ref) operator return `missing` whenever the result cannot be determined without knowing the actual value of the `missing` entry. In practice, this means that `missing` is returned if all non-missing values of the compared arrays are equal, but one or both arrays contain missing values (possibly at different positions)
"""

# ╔═╡ 03cfe220-9e19-11eb-3051-251d0dcc8eca
[1, missing] == [2, missing]

# ╔═╡ 03cfe228-9e19-11eb-3384-63bd45e7c34d
[1, missing] == [1, missing]

# ╔═╡ 03cfe228-9e19-11eb-2d96-ff9c8448c524
[1, 2, missing] == [1, missing, 2]

# ╔═╡ 03cfe264-9e19-11eb-1bd2-bf408d1ff0b6
md"""
As for single values, use [`isequal`](@ref) to treat `missing` values as equal to other `missing` values but different from non-missing values
"""

# ╔═╡ 03cfe62e-9e19-11eb-29df-4f79dbdf8fbc
isequal([1, missing], [1, missing])

# ╔═╡ 03cfe638-9e19-11eb-3907-c13b5ba15126
isequal([1, 2, missing], [1, missing, 2])

# ╔═╡ 03cfe654-9e19-11eb-1598-81a859ed9c84
md"""
Functions [`any`](@ref) and [`all`](@ref) also follow the rules of three-valued logic, returning `missing` when the result cannot be determined
"""

# ╔═╡ 03cfeb10-9e19-11eb-3a85-9f49f92fbc49
all([true, missing])

# ╔═╡ 03cfeb24-9e19-11eb-20c9-0933517674da
all([false, missing])

# ╔═╡ 03cfeb24-9e19-11eb-299d-abcedafccd2c
any([true, missing])

# ╔═╡ 03cfeb24-9e19-11eb-0f8c-ab38c567e760
any([false, missing])

# ╔═╡ Cell order:
# ╟─03cfa2b8-9e19-11eb-184e-8bdf1457b50d
# ╟─03cfa308-9e19-11eb-0e81-0597d5b3133b
# ╟─03cfa326-9e19-11eb-32b7-f7dcbfda70c0
# ╟─03cfa36c-9e19-11eb-0967-ef6cb8d984d5
# ╠═03cfa740-9e19-11eb-15b4-0125f1fb5373
# ╠═03cfa74a-9e19-11eb-1e21-7b3be4cbb379
# ╠═03cfa74a-9e19-11eb-356b-55ab59455957
# ╟─03cfa790-9e19-11eb-1948-73d21d51801a
# ╟─03cfa7ae-9e19-11eb-1848-a52aa664093b
# ╟─03cfa7c2-9e19-11eb-10e2-ada8fad58fe9
# ╟─03cfa7ea-9e19-11eb-1529-bf07fa9db6c5
# ╠═03cfabd0-9e19-11eb-14c5-1f1089ce6367
# ╠═03cfabdc-9e19-11eb-35f4-e331b458ac81
# ╠═03cfabe6-9e19-11eb-2be1-81e4f4bfe48b
# ╠═03cfabe6-9e19-11eb-10ee-e38710a1675c
# ╟─03cfac36-9e19-11eb-2abf-5f5df2ecbb12
# ╟─03cfac5e-9e19-11eb-3d96-772e2834e33c
# ╠═03cfafec-9e19-11eb-15c2-21353b811739
# ╠═03cfb000-9e19-11eb-2029-e11c89075f08
# ╠═03cfb00a-9e19-11eb-1b3f-93840bb4c6e9
# ╠═03cfb00a-9e19-11eb-161f-d128735c0dce
# ╟─03cfb03c-9e19-11eb-1910-9d6c9883a05c
# ╠═03cfb280-9e19-11eb-102a-7f6a3df1bbc6
# ╠═03cfb28a-9e19-11eb-28a0-872263970d44
# ╠═03cfb294-9e19-11eb-2251-e16abab09249
# ╟─03cfb29e-9e19-11eb-07c0-45d6bcb264ba
# ╟─03cfb2e4-9e19-11eb-37b3-efe30d865069
# ╟─03cfb30c-9e19-11eb-2e2b-b7a91fc14d4a
# ╠═03cfb51e-9e19-11eb-0649-bb946ab101b1
# ╠═03cfb51e-9e19-11eb-1679-c99a7c093829
# ╠═03cfb528-9e19-11eb-215c-4f4054320752
# ╟─03cfb56e-9e19-11eb-10bb-19c288897f0d
# ╠═03cfb6ac-9e19-11eb-11ff-5d9b5bd6404e
# ╠═03cfb6b8-9e19-11eb-356a-35d88039776f
# ╟─03cfb6d6-9e19-11eb-148a-3171303e7aea
# ╠═03cfb9d8-9e19-11eb-15ab-e988392a0e81
# ╠═03cfb9e2-9e19-11eb-17da-a17462a38095
# ╠═03cfb9e2-9e19-11eb-32fd-f54c373e0dda
# ╠═03cfb9e2-9e19-11eb-2d69-a315acf78bf2
# ╠═03cfba0a-9e19-11eb-32fa-e1b8a1a0f084
# ╟─03cfba32-9e19-11eb-05ae-65e1ccc207a3
# ╠═03cfbc08-9e19-11eb-0c72-db81789b418c
# ╠═03cfbc08-9e19-11eb-127d-3124793a1156
# ╠═03cfbc12-9e19-11eb-3ec2-2f0235f7721f
# ╟─03cfbc30-9e19-11eb-26cb-2bb50fa17e04
# ╠═03cfbdfc-9e19-11eb-0d21-a553f36aa0af
# ╠═03cfbdfc-9e19-11eb-375b-d3c69158c34d
# ╠═03cfbdfc-9e19-11eb-1b79-2b09e13802ec
# ╟─03cfbe42-9e19-11eb-35e3-5fcc5a21b856
# ╟─03cfbe4c-9e19-11eb-1acd-29baabdc9e84
# ╟─03cfbe86-9e19-11eb-2c4d-59c0721797ea
# ╠═03cfc09a-9e19-11eb-399b-bf6a3d33527d
# ╟─03cfc0c4-9e19-11eb-06fd-6f333958aa64
# ╠═03cfc360-9e19-11eb-2c19-196e265f1664
# ╠═03cfc36a-9e19-11eb-06f6-69dcdf6ab2fd
# ╠═03cfc394-9e19-11eb-2e94-77c09d9813a6
# ╟─03cfc3b0-9e19-11eb-31a9-e7efb9a45d4d
# ╠═03cfc518-9e19-11eb-259b-b540de142be1
# ╠═03cfc518-9e19-11eb-2ff0-479ae31808c1
# ╟─03cfc536-9e19-11eb-34f3-7d4936a71832
# ╟─03cfc54a-9e19-11eb-2fb8-a9760f008261
# ╠═03cfc64e-9e19-11eb-0258-c54ac2490f44
# ╟─03cfc676-9e19-11eb-0a3d-cb8421272eb8
# ╟─03cfc69e-9e19-11eb-1d29-87afd2e005ba
# ╠═03cfc87e-9e19-11eb-08ab-87715e2a7740
# ╟─03cfc934-9e19-11eb-1c15-f71c05bf7a0d
# ╟─03cfc95a-9e19-11eb-206a-492fcedb30a3
# ╠═03cfcf72-9e19-11eb-3c8c-a17e7f037e53
# ╠═03cfcf7c-9e19-11eb-1850-255f01dc0438
# ╠═03cfcf7c-9e19-11eb-1542-4bad8f525443
# ╠═03cfcf86-9e19-11eb-0659-279c5bf63817
# ╟─03cfcfa4-9e19-11eb-1104-996a1940660f
# ╟─03cfcfb8-9e19-11eb-0fc7-6f0c1c04c480
# ╠═03cfd12a-9e19-11eb-028d-292bfe825d09
# ╟─03cfd140-9e19-11eb-2738-1f463c828d7a
# ╠═03cfd2ec-9e19-11eb-15f5-d3bef94b805d
# ╟─03cfd30c-9e19-11eb-3ea5-e547f42be464
# ╠═03cfd760-9e19-11eb-3273-b73fd86e37d7
# ╠═03cfd760-9e19-11eb-0ac4-c3e69e82a4b2
# ╠═03cfd77e-9e19-11eb-16bc-0ddd774e18e4
# ╠═03cfd77e-9e19-11eb-21c9-5908763d250b
# ╟─03cfd79c-9e19-11eb-0b45-63d3375a2573
# ╠═03cfd918-9e19-11eb-1ec0-e18ed15b165c
# ╠═03cfd92c-9e19-11eb-2c72-dff2fe16245a
# ╟─03cfd94a-9e19-11eb-27e1-135008aca68e
# ╠═03cfdca6-9e19-11eb-0bc5-2ffdf8b07f7d
# ╠═03cfdca6-9e19-11eb-12c1-156d3dcebc7c
# ╠═03cfdcae-9e19-11eb-3d38-8f1f6b55ebb8
# ╟─03cfdcd8-9e19-11eb-0d88-83f682065aea
# ╠═03cfdd84-9e19-11eb-358a-d76f86efb340
# ╟─03cfdd96-9e19-11eb-3ed2-2bd05dd0b7f6
# ╟─03cfddbe-9e19-11eb-2afd-efdd89d1f3f6
# ╠═03cfe220-9e19-11eb-3051-251d0dcc8eca
# ╠═03cfe228-9e19-11eb-3384-63bd45e7c34d
# ╠═03cfe228-9e19-11eb-2d96-ff9c8448c524
# ╟─03cfe264-9e19-11eb-1bd2-bf408d1ff0b6
# ╠═03cfe62e-9e19-11eb-29df-4f79dbdf8fbc
# ╠═03cfe638-9e19-11eb-3907-c13b5ba15126
# ╟─03cfe654-9e19-11eb-1598-81a859ed9c84
# ╠═03cfeb10-9e19-11eb-3a85-9f49f92fbc49
# ╠═03cfeb24-9e19-11eb-20c9-0933517674da
# ╠═03cfeb24-9e19-11eb-299d-abcedafccd2c
# ╠═03cfeb24-9e19-11eb-0f8c-ab38c567e760
