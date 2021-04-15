### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ 03b7899e-9e19-11eb-3873-5940a199e477
md"""
# [Multi-dimensional Arrays](@id man-multi-dim-arrays)
"""

# ╔═╡ 03b78a70-9e19-11eb-2eb0-49a69a43d096
md"""
Julia, like most technical computing languages, provides a first-class array implementation. Most technical computing languages pay a lot of attention to their array implementation at the expense of other containers. Julia does not treat arrays in any special way. The array library is implemented almost completely in Julia itself, and derives its performance from the compiler, just like any other code written in Julia. As such, it's also possible to define custom array types by inheriting from [`AbstractArray`](@ref). See the [manual section on the AbstractArray interface](@ref man-interface-array) for more details on implementing a custom array type.
"""

# ╔═╡ 03b78aac-9e19-11eb-0dfd-e539fb5f45f4
md"""
An array is a collection of objects stored in a multi-dimensional grid. In the most general case, an array may contain objects of type [`Any`](@ref). For most computational purposes, arrays should contain objects of a more specific type, such as [`Float64`](@ref) or [`Int32`](@ref).
"""

# ╔═╡ 03b78ac2-9e19-11eb-30de-41506bb68584
md"""
In general, unlike many other technical computing languages, Julia does not expect programs to be written in a vectorized style for performance. Julia's compiler uses type inference and generates optimized code for scalar array indexing, allowing programs to be written in a style that is convenient and readable, without sacrificing performance, and using less memory at times.
"""

# ╔═╡ 03b78b1a-9e19-11eb-1a29-6534f01605c3
md"""
In Julia, all arguments to functions are [passed by sharing](https://en.wikipedia.org/wiki/Evaluation_strategy#Call_by_sharing) (i.e. by pointers). Some technical computing languages pass arrays by value, and while this prevents accidental modification by callees of a value in the caller, it makes avoiding unwanted copying of arrays difficult. By convention, a function name ending with a `!` indicates that it will mutate or destroy the value of one or more of its arguments (compare, for example, [`sort`](@ref) and [`sort!`](@ref)). Callees must make explicit copies to ensure that they don't modify inputs that they don't intend to change. Many non- mutating functions are implemented by calling a function of the same name with an added `!` at the end on an explicit copy of the input, and returning that copy.
"""

# ╔═╡ 03b78b60-9e19-11eb-249f-8554bd6fc43d
md"""
## Basic Functions
"""

# ╔═╡ 03b78f16-9e19-11eb-1fac-2bf7305db958
md"""
| Function               | Description                                                                      |
|:---------------------- |:-------------------------------------------------------------------------------- |
| [`eltype(A)`](@ref)    | the type of the elements contained in `A`                                        |
| [`length(A)`](@ref)    | the number of elements in `A`                                                    |
| [`ndims(A)`](@ref)     | the number of dimensions of `A`                                                  |
| [`size(A)`](@ref)      | a tuple containing the dimensions of `A`                                         |
| [`size(A,n)`](@ref)    | the size of `A` along dimension `n`                                              |
| [`axes(A)`](@ref)      | a tuple containing the valid indices of `A`                                      |
| [`axes(A,n)`](@ref)    | a range expressing the valid indices along dimension `n`                         |
| [`eachindex(A)`](@ref) | an efficient iterator for visiting each position in `A`                          |
| [`stride(A,k)`](@ref)  | the stride (linear index distance between adjacent elements) along dimension `k` |
| [`strides(A)`](@ref)   | a tuple of the strides in each dimension                                         |
"""

# ╔═╡ 03b78f2c-9e19-11eb-3a51-69d250a0b974
md"""
## Construction and Initialization
"""

# ╔═╡ 03b78f66-9e19-11eb-1f98-979c64fa5537
md"""
Many functions for constructing and initializing arrays are provided. In the following list of such functions, calls with a `dims...` argument can either take a single tuple of dimension sizes or a series of dimension sizes passed as a variable number of arguments. Most of these functions also accept a first input `T`, which is the element type of the array. If the type `T` is omitted it will default to [`Float64`](@ref).
"""

# ╔═╡ 03b792f4-9e19-11eb-0c21-997a1ddd2244
md"""
| Function                                    | Description                                                                                                                                                                                                                                  |
|:------------------------------------------- |:-------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| [`Array{T}(undef, dims...)`](@ref)          | an uninitialized dense [`Array`](@ref)                                                                                                                                                                                                       |
| [`zeros(T, dims...)`](@ref)                 | an `Array` of all zeros                                                                                                                                                                                                                      |
| [`ones(T, dims...)`](@ref)                  | an `Array` of all ones                                                                                                                                                                                                                       |
| [`trues(dims...)`](@ref)                    | a [`BitArray`](@ref) with all values `true`                                                                                                                                                                                                  |
| [`falses(dims...)`](@ref)                   | a `BitArray` with all values `false`                                                                                                                                                                                                         |
| [`reshape(A, dims...)`](@ref)               | an array containing the same data as `A`, but with different dimensions                                                                                                                                                                      |
| [`copy(A)`](@ref)                           | copy `A`                                                                                                                                                                                                                                     |
| [`deepcopy(A)`](@ref)                       | copy `A`, recursively copying its elements                                                                                                                                                                                                   |
| [`similar(A, T, dims...)`](@ref)            | an uninitialized array of the same type as `A` (dense, sparse, etc.), but with the specified element type and dimensions. The second and third arguments are both optional, defaulting to the element type and dimensions of `A` if omitted. |
| [`reinterpret(T, A)`](@ref)                 | an array with the same binary data as `A`, but with element type `T`                                                                                                                                                                         |
| [`rand(T, dims...)`](@ref)                  | an `Array` with random, iid [^1] and uniformly distributed values in the half-open interval $[0, 1)$                                                                                                                                         |
| [`randn(T, dims...)`](@ref)                 | an `Array` with random, iid and standard normally distributed values                                                                                                                                                                         |
| [`Matrix{T}(I, m, n)`](@ref)                | `m`-by-`n` identity matrix. Requires `using LinearAlgebra` for [`I`](@ref).                                                                                                                                                                  |
| [`range(start, stop=stop, length=n)`](@ref) | range of `n` linearly spaced elements from `start` to `stop`                                                                                                                                                                                 |
| [`fill!(A, x)`](@ref)                       | fill the array `A` with the value `x`                                                                                                                                                                                                        |
| [`fill(x, dims...)`](@ref)                  | an `Array` filled with the value `x`                                                                                                                                                                                                         |
"""

# ╔═╡ 03b79420-9e19-11eb-0df0-3b19b7704355
md"""
[^1]: *iid*, independently and identically distributed.
"""

# ╔═╡ 03b7943e-9e19-11eb-3552-bb1a170af3d9
md"""
To see the various ways we can pass dimensions to these functions, consider the following examples:
"""

# ╔═╡ 03b79d9e-9e19-11eb-07a8-37c0e578a521
zeros(Int8, 2, 3)

# ╔═╡ 03b79da8-9e19-11eb-2fe9-5b7ab1de3983
zeros(Int8, (2, 3))

# ╔═╡ 03b79da8-9e19-11eb-38fe-836f432f5793
zeros((2, 3))

# ╔═╡ 03b79e20-9e19-11eb-0826-1f4698a4a50b
md"""
Here, `(2, 3)` is a [`Tuple`](@ref) and the first argument — the element type — is optional, defaulting to `Float64`.
"""

# ╔═╡ 03b79e40-9e19-11eb-33ca-598f5a9044f4
md"""
## [Array literals](@id man-array-literals)
"""

# ╔═╡ 03b79eb6-9e19-11eb-1a8f-f92d78fa8063
md"""
Arrays can also be directly constructed with square braces; the syntax `[A, B, C, ...]` creates a one dimensional array (i.e., a vector) containing the comma-separated arguments as its elements. The element type ([`eltype`](@ref)) of the resulting array is automatically determined by the types of the arguments inside the braces. If all the arguments are the same type, then that is its `eltype`. If they all have a common [promotion type](@ref conversion-and-promotion) then they get converted to that type using [`convert`](@ref) and that type is the array's `eltype`. Otherwise, a heterogeneous array that can hold anything — a `Vector{Any}` — is constructed; this includes the literal `[]` where no arguments are given.
"""

# ╔═╡ 03b7a596-9e19-11eb-2df7-496e802a66e5
[1,2,3] # An array of `Int`s

# ╔═╡ 03b7a5a0-9e19-11eb-35a6-ed58391d5d8c
promote(1, 2.3, 4//5) # This combination of Int, Float64 and Rational promotes to Float64

# ╔═╡ 03b7a5a8-9e19-11eb-1fbb-f71c18d96d8f
[1, 2.3, 4//5] # Thus that's the element type of this Array

# ╔═╡ 03b7a5a8-9e19-11eb-31ad-f936d785e157
[]

# ╔═╡ 03b7a5f0-9e19-11eb-318c-65285c67da41
md"""
### [Concatenation](@id man-array-concatenation)
"""

# ╔═╡ 03b7a622-9e19-11eb-0166-2921d3086b87
md"""
If the arguments inside the square brackets are separated by semicolons (`;`) or newlines instead of commas, then their contents are *vertically concatenated* together instead of the arguments being used as elements themselves.
"""

# ╔═╡ 03b7ad54-9e19-11eb-2e82-fd75769df6cb
[1:2, 4:5] # Has a comma, so no concatenation occurs. The ranges are themselves the elements

# ╔═╡ 03b7ad5c-9e19-11eb-2cfe-33b7de885696
[1:2; 4:5]

# ╔═╡ 03b7ad66-9e19-11eb-1d08-55054f7b5cac
[1:2
        4:5
        6]

# ╔═╡ 03b7ad98-9e19-11eb-01ae-95b6df8b2bfb
md"""
Similarly, if the arguments are separated by tabs or spaces, then their contents are *horizontally concatenated* together.
"""

# ╔═╡ 03b7b4bc-9e19-11eb-0c69-e563e8ce9329
[1:2  4:5  7:8]

# ╔═╡ 03b7b4c8-9e19-11eb-25c8-eb6ad3f85c33
[[1,2]  [4,5]  [7,8]]

# ╔═╡ 03b7b4c8-9e19-11eb-0c98-9dd7a119640b
[1 2 3] # Numbers can also be horizontally concatenated

# ╔═╡ 03b7b4fa-9e19-11eb-29ed-d357b64cbe61
md"""
Using semicolons (or newlines) and spaces (or tabs) can be combined to concatenate both horizontally and vertically at the same time.
"""

# ╔═╡ 03b7baae-9e19-11eb-3644-fd00e1f45e25
[1 2
        3 4]

# ╔═╡ 03b7bac2-9e19-11eb-0774-1fcbefa728cd
[zeros(Int, 2, 2) [1; 2]
        [3 4]            5]

# ╔═╡ 03b7bb00-9e19-11eb-1060-156c1a0fb586
md"""
More generally, concatenation can be accomplished through the [`cat`](@ref) function. These syntaxes are shorthands for function calls that themselves are convenience functions:
"""

# ╔═╡ 03b7bc5c-9e19-11eb-0f2d-497d5b1ba179
md"""
| Syntax            | Function        | Description                                        |
|:----------------- |:--------------- |:-------------------------------------------------- |
|                   | [`cat`](@ref)   | concatenate input arrays along dimension(s) `k`    |
| `[A; B; C; ...]`  | [`vcat`](@ref)  | shorthand for `cat(A...; dims=1)                   |
| `[A B C ...]`     | [`hcat`](@ref)  | shorthand for `cat(A...; dims=2)                   |
| `[A B; C D; ...]` | [`hvcat`](@ref) | simultaneous vertical and horizontal concatenation |
"""

# ╔═╡ 03b7bc7a-9e19-11eb-0c2c-e9fa29a33f5b
md"""
### Typed array literals
"""

# ╔═╡ 03b7bcb6-9e19-11eb-1aa5-5fd56c351e35
md"""
An array with a specific element type can be constructed using the syntax `T[A, B, C, ...]`. This will construct a 1-d array with element type `T`, initialized to contain elements `A`, `B`, `C`, etc. For example, `Any[x, y, z]` constructs a heterogeneous array that can contain any values.
"""

# ╔═╡ 03b7bcde-9e19-11eb-05d7-39fbe91db11c
md"""
Concatenation syntax can similarly be prefixed with a type to specify the element type of the result.
"""

# ╔═╡ 03b7c210-9e19-11eb-0fcd-b369423a03bf
[[1 2] [3 4]]

# ╔═╡ 03b7c21a-9e19-11eb-2d9b-fd2257c24b72
Int8[[1 2] [3 4]]

# ╔═╡ 03b7c242-9e19-11eb-062c-e5b9ebd370fc
md"""
## [Comprehensions](@id man-comprehensions)
"""

# ╔═╡ 03b7c260-9e19-11eb-33a7-21c2a2aa0697
md"""
Comprehensions provide a general and powerful way to construct arrays. Comprehension syntax is similar to set construction notation in mathematics:
"""

# ╔═╡ 03b7c42c-9e19-11eb-171d-8dd9ef515859
A = [ F(x,y,...

# ╔═╡ 03b7c474-9e19-11eb-21c3-f373fc64b4a4
md"""
The meaning of this form is that `F(x,y,...)` is evaluated with the variables `x`, `y`, etc. taking on each value in their given list of values. Values can be specified as any iterable object, but will commonly be ranges like `1:n` or `2:(n-1)`, or explicit arrays of values like `[1.2, 3.4, 5.7]`. The result is an N-d dense array with dimensions that are the concatenation of the dimensions of the variable ranges `rx`, `ry`, etc. and each `F(x,y,...)` evaluation returns a scalar.
"""

# ╔═╡ 03b7c47c-9e19-11eb-0476-1380a895417e
md"""
The following example computes a weighted average of the current element and its left and right neighbor along a 1-d grid. :
"""

# ╔═╡ 03b7ce90-9e19-11eb-0a2b-8137ef8a1789
x = rand(8)

# ╔═╡ 03b7cea4-9e19-11eb-1e7c-4b8c5a498dc2
[ 0.25*x[i-1] + 0.5*x[i] + 0.25*x[i+1] for i=2:length(x)-1 ]

# ╔═╡ 03b7cf30-9e19-11eb-29f9-4536de362c19
md"""
The resulting array type depends on the types of the computed elements just like [array literals](@ref man-array-literals) do. In order to control the type explicitly, a type can be prepended to the comprehension. For example, we could have requested the result in single precision by writing:
"""

# ╔═╡ 03b7cfda-9e19-11eb-3c08-cbe4242f01a0
md"""
```julia
Float32[ 0.25*x[i-1] + 0.5*x[i] + 0.25*x[i+1] for i=2:length(x)-1 ]
```
"""

# ╔═╡ 03b7d014-9e19-11eb-229e-039fd38da137
md"""
## Generator Expressions
"""

# ╔═╡ 03b7d034-9e19-11eb-1635-eb54eb64f284
md"""
Comprehensions can also be written without the enclosing square brackets, producing an object known as a generator. This object can be iterated to produce values on demand, instead of allocating an array and storing them in advance (see [Iteration](@ref)). For example, the following expression sums a series without allocating memory:
"""

# ╔═╡ 03b7d4f8-9e19-11eb-3c87-810caba980ed
sum(1/n^2 for n=1:1000)

# ╔═╡ 03b7d516-9e19-11eb-3964-b78783549368
md"""
When writing a generator expression with multiple dimensions inside an argument list, parentheses are needed to separate the generator from subsequent arguments:
"""

# ╔═╡ 03b7da66-9e19-11eb-39da-195b527491e9
map(tuple, 1/(i+j) for i=1:2, j=1:2, [1:4;])

# ╔═╡ 03b7dab6-9e19-11eb-0f65-e303e4f2320d
md"""
All comma-separated expressions after `for` are interpreted as ranges. Adding parentheses lets us add a third argument to [`map`](@ref):
"""

# ╔═╡ 03b7e5a6-9e19-11eb-3b16-47e4f32570e6
map(tuple, (1/(i+j) for i=1:2, j=1:2), [1 3; 2 4])

# ╔═╡ 03b7e5fe-9e19-11eb-0dd8-5b4a108f0d2d
md"""
Generators are implemented via inner functions. Just like inner functions used elsewhere in the language, variables from the enclosing scope can be "captured" in the inner function.  For example, `sum(p[i] - q[i] for i=1:n)` captures the three variables `p`, `q` and `n` from the enclosing scope. Captured variables can present performance challenges; see [performance tips](@ref man-performance-captured).
"""

# ╔═╡ 03b7e61e-9e19-11eb-0930-7f15840e19f0
md"""
Ranges in generators and comprehensions can depend on previous ranges by writing multiple `for` keywords:
"""

# ╔═╡ 03b7ed62-9e19-11eb-3d8c-bd46978e6038
[(i,j) for i=1:3 for j=1:i]

# ╔═╡ 03b7ed9e-9e19-11eb-08bd-23e1bbf47cf5
md"""
In such cases, the result is always 1-d.
"""

# ╔═╡ 03b7edf8-9e19-11eb-27bd-1f2d72c7523a
md"""
Generated values can be filtered using the `if` keyword:
"""

# ╔═╡ 03b7f2f8-9e19-11eb-3166-b9795a77418a
[(i,j) for i=1:3 for j=1:i if i+j == 4]

# ╔═╡ 03b7f32a-9e19-11eb-0941-a33ac108edf8
md"""
## [Indexing](@id man-array-indexing)
"""

# ╔═╡ 03b7f35c-9e19-11eb-1129-c5046be48dbb
md"""
The general syntax for indexing into an n-dimensional array `A` is:
"""

# ╔═╡ 03b7f67a-9e19-11eb-02ee-ff95cb81578b
X = A[I_1, I_2, ...

# ╔═╡ 03b7f6cc-9e19-11eb-3bda-5f1e35e01911
md"""
where each `I_k` may be a scalar integer, an array of integers, or any other [supported index](@ref man-supported-index-types). This includes [`Colon`](@ref) (`:`) to select all indices within the entire dimension, ranges of the form `a:c` or `a:b:c` to select contiguous or strided subsections, and arrays of booleans to select elements at their `true` indices.
"""

# ╔═╡ 03b7f6ec-9e19-11eb-20ca-47baf524386d
md"""
If all the indices are scalars, then the result `X` is a single element from the array `A`. Otherwise, `X` is an array with the same number of dimensions as the sum of the dimensionalities of all the indices.
"""

# ╔═╡ 03b7f726-9e19-11eb-3f9d-cd70d6317822
md"""
If all indices `I_k` are vectors, for example, then the shape of `X` would be `(length(I_1), length(I_2), ..., length(I_n))`, with location `i_1, i_2, ..., i_n` of `X` containing the value `A[I_1[i_1], I_2[i_2], ..., I_n[i_n]]`.
"""

# ╔═╡ 03b7f73a-9e19-11eb-289f-2dc24df2b32c
md"""
Example:
"""

# ╔═╡ 03b805a4-9e19-11eb-0774-bd1cb0f5e57d
A = reshape(collect(1:16), (2, 2, 2, 2))

# ╔═╡ 03b805ae-9e19-11eb-2142-f97cd8474981
A[1, 2, 1, 1] # all scalar indices

# ╔═╡ 03b805c2-9e19-11eb-04ed-bd06c1d67285
A[[1, 2], [1], [1, 2], [1]] # all vector indices

# ╔═╡ 03b805cc-9e19-11eb-1c26-536ab65f9799
A[[1, 2], [1], [1, 2], 1] # a mix of index types

# ╔═╡ 03b80600-9e19-11eb-26b3-410425d20eec
md"""
Note how the size of the resulting array is different in the last two cases.
"""

# ╔═╡ 03b80644-9e19-11eb-26e5-179cd3adf20e
md"""
If `I_1` is changed to a two-dimensional matrix, then `X` becomes an `n+1`-dimensional array of shape `(size(I_1, 1), size(I_1, 2), length(I_2), ..., length(I_n))`. The matrix adds a dimension.
"""

# ╔═╡ 03b80658-9e19-11eb-2d9c-a3ba6cf652d4
md"""
Example:
"""

# ╔═╡ 03b81080-9e19-11eb-0dc9-5539cfe49250
A = reshape(collect(1:16), (2, 2, 2, 2));

# ╔═╡ 03b81080-9e19-11eb-2033-a9af622ce675
A[[1 2; 1 2]]

# ╔═╡ 03b8108a-9e19-11eb-1cdf-8f0ede6fbd36
A[[1 2; 1 2], 1, 2, 1]

# ╔═╡ 03b810d0-9e19-11eb-1b5b-83a5d9af3c16
md"""
The location `i_1, i_2, i_3, ..., i_{n+1}` contains the value at `A[I_1[i_1, i_2], I_2[i_3], ..., I_n[i_{n+1}]]`. All dimensions indexed with scalars are dropped. For example, if `J` is an array of indices, then the result of `A[2, J, 3]` is an array with size `size(J)`. Its `j`th element is populated by `A[2, J[j], 3]`.
"""

# ╔═╡ 03b810f8-9e19-11eb-073f-1bd3bbb9de49
md"""
As a special part of this syntax, the `end` keyword may be used to represent the last index of each dimension within the indexing brackets, as determined by the size of the innermost array being indexed. Indexing syntax without the `end` keyword is equivalent to a call to [`getindex`](@ref):
"""

# ╔═╡ 03b81260-9e19-11eb-34e1-5d18876d0dac
X = getindex(A, I_1, I_2, ...

# ╔═╡ 03b8127e-9e19-11eb-11a9-91acafbf24cb
md"""
Example:
"""

# ╔═╡ 03b819ea-9e19-11eb-3df8-5b0391e28063
x = reshape(1:16, 4, 4)

# ╔═╡ 03b819ea-9e19-11eb-04d3-1d0605820565
x[2:3, 2:end-1]

# ╔═╡ 03b819f4-9e19-11eb-28e8-4fed261aa2bc
x[1, [2 3; 4 1]]

# ╔═╡ 03b81a1c-9e19-11eb-1bdc-2bad0deb4a48
md"""
## [Indexed Assignment](@id man-indexed-assignment)
"""

# ╔═╡ 03b81a3a-9e19-11eb-2410-c5758be6385c
md"""
The general syntax for assigning values in an n-dimensional array `A` is:
"""

# ╔═╡ 03b81b20-9e19-11eb-3ca0-49817aff5f7d
A[I_1, I_2, ...

# ╔═╡ 03b81b5c-9e19-11eb-3974-b5c98ed9a5c6
md"""
where each `I_k` may be a scalar integer, an array of integers, or any other [supported index](@ref man-supported-index-types). This includes [`Colon`](@ref) (`:`) to select all indices within the entire dimension, ranges of the form `a:c` or `a:b:c` to select contiguous or strided subsections, and arrays of booleans to select elements at their `true` indices.
"""

# ╔═╡ 03b81b98-9e19-11eb-386c-937370a66509
md"""
If all indices `I_k` are integers, then the value in location `I_1, I_2, ..., I_n` of `A` is overwritten with the value of `X`, [`convert`](@ref)ing to the [`eltype`](@ref) of `A` if necessary.
"""

# ╔═╡ 03b81bca-9e19-11eb-2937-71e818622059
md"""
If any index `I_k` selects more than one location, then the right hand side `X` must be an array with the same shape as the result of indexing `A[I_1, I_2, ..., I_n]` or a vector with the same number of elements. The value in location `I_1[i_1], I_2[i_2], ..., I_n[i_n]` of `A` is overwritten with the value `X[I_1, I_2, ..., I_n]`, converting if necessary. The element-wise assignment operator `.=` may be used to [broadcast](@ref Broadcasting) `X` across the selected locations:
"""

# ╔═╡ 03b81c92-9e19-11eb-051d-79b59160e618
A[I_1, I_2, ...

# ╔═╡ 03b81cce-9e19-11eb-2f62-5d99e0816d1b
md"""
Just as in [Indexing](@ref man-array-indexing), the `end` keyword may be used to represent the last index of each dimension within the indexing brackets, as determined by the size of the array being assigned into. Indexed assignment syntax without the `end` keyword is equivalent to a call to [`setindex!`](@ref):
"""

# ╔═╡ 03b81daa-9e19-11eb-13c6-e302c7c03240
setindex!(A, X, I_1, I_2, ...

# ╔═╡ 03b81dbe-9e19-11eb-0e24-2fa9b9536ed0
md"""
Example:
"""

# ╔═╡ 03b826ec-9e19-11eb-1aae-e728877640e8
x = collect(reshape(1:9, 3, 3))

# ╔═╡ 03b826f8-9e19-11eb-23d0-afdf246db73b
x[3, 3] = -9;

# ╔═╡ 03b82700-9e19-11eb-3c32-ff08a02ae9bf
x[1:2, 1:2] = [-1 -4; -2 -5];

# ╔═╡ 03b82700-9e19-11eb-0327-53c91ef4df0c
x

# ╔═╡ 03b8272a-9e19-11eb-09d5-87ddf5654acc
md"""
## [Supported index types](@id man-supported-index-types)
"""

# ╔═╡ 03b82746-9e19-11eb-0b34-e70f6a10fd5d
md"""
In the expression `A[I_1, I_2, ..., I_n]`, each `I_k` may be a scalar index, an array of scalar indices, or an object that represents an array of scalar indices and can be converted to such by [`to_indices`](@ref):
"""

# ╔═╡ 03b82a48-9e19-11eb-34a0-f96e7274f9b7
md"""
1. A scalar index. By default this includes:

      * Non-boolean integers
      * [`CartesianIndex{N}`](@ref)s, which behave like an `N`-tuple of integers spanning multiple dimensions (see below for more details)
2. An array of scalar indices. This includes:

      * Vectors and multidimensional arrays of integers
      * Empty arrays like `[]`, which select no elements
      * Ranges like `a:c` or `a:b:c`, which select contiguous or strided subsections from `a` to `c` (inclusive)
      * Any custom array of scalar indices that is a subtype of `AbstractArray`
      * Arrays of `CartesianIndex{N}` (see below for more details)
3. An object that represents an array of scalar indices and can be converted to such by [`to_indices`](@ref). By default this includes:

      * [`Colon()`](@ref) (`:`), which represents all indices within an entire dimension or across the entire array
      * Arrays of booleans, which select elements at their `true` indices (see below for more details)
"""

# ╔═╡ 03b82a52-9e19-11eb-2348-45f3927f5ee7
md"""
Some examples:
"""

# ╔═╡ 03b83718-9e19-11eb-080b-e3f7340ff031
A = reshape(collect(1:2:18), (3, 3))

# ╔═╡ 03b83736-9e19-11eb-0493-c5f6bc2a3032
A[4]

# ╔═╡ 03b83736-9e19-11eb-30e0-2ffb8f647646
A[[2, 5, 8]]

# ╔═╡ 03b83736-9e19-11eb-06eb-25d07b3e54df
A[[1 4; 3 8]]

# ╔═╡ 03b83740-9e19-11eb-22c0-ff34c87398b1
A[[]]

# ╔═╡ 03b83740-9e19-11eb-1aba-8fffe45f079a
A[1:2:5]

# ╔═╡ 03b8374a-9e19-11eb-16d7-1bba270221de
A[2, :]

# ╔═╡ 03b83754-9e19-11eb-2ac5-b59f7719514d
A[:, 3]

# ╔═╡ 03b8377c-9e19-11eb-0723-11d96d4719eb
md"""
### Cartesian indices
"""

# ╔═╡ 03b8379a-9e19-11eb-2871-a5edd14e62d7
md"""
The special `CartesianIndex{N}` object represents a scalar index that behaves like an `N`-tuple of integers spanning multiple dimensions.  For example:
"""

# ╔═╡ 03b83e0c-9e19-11eb-1b3d-0dc6908bb4bd
A = reshape(1:32, 4, 4, 2);

# ╔═╡ 03b83e16-9e19-11eb-1663-b315690ba11a
A[3, 2, 1]

# ╔═╡ 03b83e16-9e19-11eb-3f1a-e74e3c891565
A[CartesianIndex(3, 2, 1)] == A[3, 2, 1] == 7

# ╔═╡ 03b83e4a-9e19-11eb-03c9-2d66f081c0b8
md"""
Considered alone, this may seem relatively trivial; `CartesianIndex` simply gathers multiple integers together into one object that represents a single multidimensional index. When combined with other indexing forms and iterators that yield `CartesianIndex`es, however, this can produce very elegant and efficient code. See [Iteration](@ref) below, and for some more advanced examples, see [this blog post on multidimensional algorithms and iteration](https://julialang.org/blog/2016/02/iteration).
"""

# ╔═╡ 03b83e70-9e19-11eb-3540-2b1425725c17
md"""
Arrays of `CartesianIndex{N}` are also supported. They represent a collection of scalar indices that each span `N` dimensions, enabling a form of indexing that is sometimes referred to as pointwise indexing. For example, it enables accessing the diagonal elements from the first "page" of `A` from above:
"""

# ╔═╡ 03b84460-9e19-11eb-0e5c-478094e90bb4
page = A[:,:,1]

# ╔═╡ 03b8446a-9e19-11eb-091d-71b07e0ded46
page[[CartesianIndex(1,1),
             CartesianIndex(2,2),
             CartesianIndex(3,3),
             CartesianIndex(4,4)]]

# ╔═╡ 03b84488-9e19-11eb-1bd9-21f419e2ef79
md"""
This can be expressed much more simply with [dot broadcasting](@ref man-vectorized) and by combining it with a normal integer index (instead of extracting the first `page` from `A` as a separate step). It can even be combined with a `:` to extract both diagonals from the two pages at the same time:
"""

# ╔═╡ 03b849e2-9e19-11eb-2e41-c1a4f31f988a
A[CartesianIndex.(axes(A, 1), axes(A, 2)), 1]

# ╔═╡ 03b849e2-9e19-11eb-1e46-1389d8c4991b
A[CartesianIndex.(axes(A, 1), axes(A, 2)), :]

# ╔═╡ 03b84aa0-9e19-11eb-066c-298173377438
md"""
!!! warning
    `CartesianIndex` and arrays of `CartesianIndex` are not compatible with the `end` keyword to represent the last index of a dimension. Do not use `end` in indexing expressions that may contain either `CartesianIndex` or arrays thereof.
"""

# ╔═╡ 03b84ac0-9e19-11eb-1bf0-19853e21d0cb
md"""
### Logical indexing
"""

# ╔═╡ 03b84b0e-9e19-11eb-1ef5-9795ed8736ad
md"""
Often referred to as logical indexing or indexing with a logical mask, indexing by a boolean array selects elements at the indices where its values are `true`. Indexing by a boolean vector `B` is effectively the same as indexing by the vector of integers that is returned by [`findall(B)`](@ref). Similarly, indexing by a `N`-dimensional boolean array is effectively the same as indexing by the vector of `CartesianIndex{N}`s where its values are `true`. A logical index must be a vector of the same length as the dimension it indexes into, or it must be the only index provided and match the size and dimensionality of the array it indexes into. It is generally more efficient to use boolean arrays as indices directly instead of first calling [`findall`](@ref).
"""

# ╔═╡ 03b85196-9e19-11eb-300b-8f40c40e626d
x = reshape(1:16, 4, 4)

# ╔═╡ 03b85196-9e19-11eb-3b6f-4fa1c5ce9457
x[[false, true, true, false], :]

# ╔═╡ 03b8519e-9e19-11eb-3861-17450351f11e
mask = map(ispow2, x)

# ╔═╡ 03b851a8-9e19-11eb-3a60-8561a1e073fb
x[mask]

# ╔═╡ 03b851bc-9e19-11eb-3514-cb35f077f3e5
md"""
### Number of indices
"""

# ╔═╡ 03b851fa-9e19-11eb-00b7-a799a45fda7c
md"""
#### Cartesian indexing
"""

# ╔═╡ 03b85228-9e19-11eb-1b8d-ffafb65797b9
md"""
The ordinary way to index into an `N`-dimensional array is to use exactly `N` indices; each index selects the position(s) in its particular dimension. For example, in the three-dimensional array `A = rand(4, 3, 2)`, `A[2, 3, 1]` will select the number in the second row of the third column in the first "page" of the array. This is often referred to as *cartesian indexing*.
"""

# ╔═╡ 03b85248-9e19-11eb-3357-6d3e959c2d50
md"""
#### Linear indexing
"""

# ╔═╡ 03b85270-9e19-11eb-232f-87c8482c4c4b
md"""
When exactly one index `i` is provided, that index no longer represents a location in a particular dimension of the array. Instead, it selects the `i`th element using the column-major iteration order that linearly spans the entire array. This is known as *linear indexing*. It essentially treats the array as though it had been reshaped into a one-dimensional vector with [`vec`](@ref).
"""

# ╔═╡ 03b857ac-9e19-11eb-0204-e79254f838f3
A = [2 6; 4 7; 3 1]

# ╔═╡ 03b857b6-9e19-11eb-31cb-5df3201c0ba3
A[5]

# ╔═╡ 03b857c8-9e19-11eb-2860-219abe38b984
vec(A)[5]

# ╔═╡ 03b85806-9e19-11eb-3c32-514c65402e09
md"""
A linear index into the array `A` can be converted to a `CartesianIndex` for cartesian indexing with `CartesianIndices(A)[i]` (see [`CartesianIndices`](@ref)), and a set of `N` cartesian indices can be converted to a linear index with `LinearIndices(A)[i_1, i_2, ..., i_N]` (see [`LinearIndices`](@ref)).
"""

# ╔═╡ 03b85a18-9e19-11eb-24b4-4756f1469c3d
CartesianIndices(A)[5]

# ╔═╡ 03b85a18-9e19-11eb-090b-e385c8388918
LinearIndices(A)[2, 2]

# ╔═╡ 03b85a66-9e19-11eb-2d96-53ccd3cb8f34
md"""
It's important to note that there's a very large assymmetry in the performance of these conversions. Converting a linear index to a set of cartesian indices requires dividing and taking the remainder, whereas going the other way is just multiplies and adds. In modern processors, integer division can be 10-50 times slower than multiplication. While some arrays — like [`Array`](@ref) itself — are implemented using a linear chunk of memory and directly use a linear index in their implementations, other arrays — like [`Diagonal`](@ref) — need the full set of cartesian indices to do their lookup (see [`IndexStyle`](@ref) to introspect which is which). As such, when iterating over an entire array, it's much better to iterate over [`eachindex(A)`](@ref) instead of `1:length(A)`. Not only will the former be much faster in cases where `A` is `IndexCartesian`, but it will also support OffsetArrays, too.
"""

# ╔═╡ 03b85a7c-9e19-11eb-18ca-751307178b02
md"""
#### Omitted and extra indices
"""

# ╔═╡ 03b85a90-9e19-11eb-1971-2b9d15bf916d
md"""
In addition to linear indexing, an `N`-dimensional array may be indexed with fewer or more than `N` indices in certain situations.
"""

# ╔═╡ 03b85aae-9e19-11eb-2f18-7534a3f61611
md"""
Indices may be omitted if the trailing dimensions that are not indexed into are all length one. In other words, trailing indices can be omitted only if there is only one possible value that those omitted indices could be for an in-bounds indexing expression. For example, a four-dimensional array with size `(3, 4, 2, 1)` may be indexed with only three indices as the dimension that gets skipped (the fourth dimension) has length one. Note that linear indexing takes precedence over this rule.
"""

# ╔═╡ 03b860aa-9e19-11eb-22fc-aba4ecb8227d
A = reshape(1:24, 3, 4, 2, 1)

# ╔═╡ 03b860aa-9e19-11eb-1ecb-7f378ceb99f2
A[1, 3, 2] # Omits the fourth dimension (length 1)

# ╔═╡ 03b860aa-9e19-11eb-135c-a551f145ccd1
A[1, 3] # Attempts to omit dimensions 3 & 4 (lengths 2 and 1)

# ╔═╡ 03b860b2-9e19-11eb-23d2-07938c3e1431
A[19] # Linear indexing

# ╔═╡ 03b860e4-9e19-11eb-3d48-b58974045ce2
md"""
When omitting *all* indices with `A[]`, this semantic provides a simple idiom to retrieve the only element in an array and simultaneously ensure that there was only one element.
"""

# ╔═╡ 03b86102-9e19-11eb-265e-c51116abb103
md"""
Similarly, more than `N` indices may be provided if all the indices beyond the dimensionality of the array are `1` (or more generally are the first and only element of `axes(A, d)` where `d` is that particular dimension number). This allows vectors to be indexed like one-column matrices, for example:
"""

# ╔═╡ 03b86328-9e19-11eb-0748-098886df08db
A = [8,6,7]

# ╔═╡ 03b875de-9e19-11eb-0c85-e5e1673fcf0d
A[2,1]

# ╔═╡ 03b87638-9e19-11eb-0237-d31d1b7ff49d
md"""
## Iteration
"""

# ╔═╡ 03b8764c-9e19-11eb-3dae-7b27e7feb30e
md"""
The recommended ways to iterate over a whole array are
"""

# ╔═╡ 03b87694-9e19-11eb-3b48-0fc5e93a4467
md"""
```julia
for a in A
    # Do something with the element a
end

for i in eachindex(A)
    # Do something with i and/or A[i]
end
```
"""

# ╔═╡ 03b876ba-9e19-11eb-2be4-ab4c88b9118c
md"""
The first construct is used when you need the value, but not index, of each element. In the second construct, `i` will be an `Int` if `A` is an array type with fast linear indexing; otherwise, it will be a `CartesianIndex`:
"""

# ╔═╡ 03b87e2e-9e19-11eb-3a20-4b48c254e5d0
A = rand(4,3);

# ╔═╡ 03b87e2e-9e19-11eb-327c-fd451c8b427b
B = view(A, 1:3, 2:3);

# ╔═╡ 03b87e3a-9e19-11eb-0081-05e07babfcf4
for i in eachindex(B)
           @show i
       end

# ╔═╡ 03b87e6c-9e19-11eb-1c60-13960b3c7a60
md"""
In contrast with `for i = 1:length(A)`, iterating with [`eachindex`](@ref) provides an efficient way to iterate over any array type.
"""

# ╔═╡ 03b87e80-9e19-11eb-2d69-c94231dfd0a3
md"""
## Array traits
"""

# ╔═╡ 03b87e9e-9e19-11eb-042c-0789f7200cf6
md"""
If you write a custom [`AbstractArray`](@ref) type, you can specify that it has fast linear indexing using
"""

# ╔═╡ 03b87ebc-9e19-11eb-3000-6f4f39e88f2d
md"""
```julia
Base.IndexStyle(::Type{<:MyArray}) = IndexLinear()
```
"""

# ╔═╡ 03b87eda-9e19-11eb-2013-1917e4b5d217
md"""
This setting will cause `eachindex` iteration over a `MyArray` to use integers. If you don't specify this trait, the default value `IndexCartesian()` is used.
"""

# ╔═╡ 03b87eee-9e19-11eb-08b1-99f8578dd5f1
md"""
## [Array and Vectorized Operators and Functions](@id man-array-and-vectorized-operators-and-functions)
"""

# ╔═╡ 03b87f16-9e19-11eb-1413-8f423e4fa961
md"""
The following operators are supported for arrays:
"""

# ╔═╡ 03b87fe8-9e19-11eb-1641-730b65c0037c
md"""
1. Unary arithmetic – `-`, `+`
2. Binary arithmetic – `-`, `+`, `*`, `/`, `\`, `^`
3. Comparison – `==`, `!=`, `≈` ([`isapprox`](@ref)), `≉`
"""

# ╔═╡ 03b88024-9e19-11eb-12c8-6dd5d48da637
md"""
To enable convenient vectorization of mathematical and other operations, Julia [provides the dot syntax](@ref man-vectorized) `f.(args...)`, e.g. `sin.(x)` or `min.(x,y)`, for elementwise operations over arrays or mixtures of arrays and scalars (a [Broadcasting](@ref) operation); these have the additional advantage of "fusing" into a single loop when combined with other dot calls, e.g. `sin.(cos.(x))`.
"""

# ╔═╡ 03b88056-9e19-11eb-24da-4774a291a4e1
md"""
Also, *every* binary operator supports a [dot version](@ref man-dot-operators) that can be applied to arrays (and combinations of arrays and scalars) in such [fused broadcasting operations](@ref man-vectorized), e.g. `z .== sin.(x .* y)`.
"""

# ╔═╡ 03b8807e-9e19-11eb-1193-db9ed058e814
md"""
Note that comparisons such as `==` operate on whole arrays, giving a single boolean answer. Use dot operators like `.==` for elementwise comparisons. (For comparison operations like `<`, *only* the elementwise `.<` version is applicable to arrays.)
"""

# ╔═╡ 03b880b0-9e19-11eb-2d1a-df62e73b5de6
md"""
Also notice the difference between `max.(a,b)`, which [`broadcast`](@ref)s [`max`](@ref) elementwise over `a` and `b`, and [`maximum(a)`](@ref), which finds the largest value within `a`. The same relationship holds for `min.(a,b)` and `minimum(a)`.
"""

# ╔═╡ 03b880c4-9e19-11eb-3014-f50af7e06638
md"""
## Broadcasting
"""

# ╔═╡ 03b880d8-9e19-11eb-202f-fb0f67f3a2dc
md"""
It is sometimes useful to perform element-by-element binary operations on arrays of different sizes, such as adding a vector to each column of a matrix. An inefficient way to do this would be to replicate the vector to the size of the matrix:
"""

# ╔═╡ 03b8851a-9e19-11eb-2f62-df96a898e95a
a = rand(2,1); A = rand(2,3);

# ╔═╡ 03b8851a-9e19-11eb-093e-a501726ab8c1
repeat(a,1,3)+A

# ╔═╡ 03b8854c-9e19-11eb-2127-b3b78d17a715
md"""
This is wasteful when dimensions get large, so Julia provides [`broadcast`](@ref), which expands singleton dimensions in array arguments to match the corresponding dimension in the other array without using extra memory, and applies the given function elementwise:
"""

# ╔═╡ 03b888bc-9e19-11eb-198f-2572d9e0cbfa
broadcast(+, a, A)

# ╔═╡ 03b888c6-9e19-11eb-1904-1946eaf6e70c
b = rand(1,2)

# ╔═╡ 03b888c6-9e19-11eb-3e90-e368aa1f9f8f
broadcast(+, a, b)

# ╔═╡ 03b88920-9e19-11eb-1f3c-adb859a8c895
md"""
[Dotted operators](@ref man-dot-operators) such as `.+` and `.*` are equivalent to `broadcast` calls (except that they fuse, as [described above](@ref man-array-and-vectorized-operators-and-functions)). There is also a [`broadcast!`](@ref) function to specify an explicit destination (which can also be accessed in a fusing fashion by `.=` assignment). In fact, `f.(args...)` is equivalent to `broadcast(f, args...)`, providing a convenient syntax to broadcast any function ([dot syntax](@ref man-vectorized)). Nested "dot calls" `f.(...)` (including calls to `.+` etcetera) [automatically fuse](@ref man-dot-operators) into a single `broadcast` call.
"""

# ╔═╡ 03b88966-9e19-11eb-02fd-6bed3ffed2d1
md"""
Additionally, [`broadcast`](@ref) is not limited to arrays (see the function documentation); it also handles scalars, tuples and other collections.  By default, only some argument types are considered scalars, including (but not limited to) `Number`s, `String`s, `Symbol`s, `Type`s, `Function`s and some common singletons like `missing` and `nothing`. All other arguments are iterated over or indexed into elementwise.
"""

# ╔═╡ 03b891b8-9e19-11eb-32d1-431651d4b045
convert.(Float32, [1, 2])

# ╔═╡ 03b891c2-9e19-11eb-3d4a-a3456fabe4d8
ceil.(UInt8, [1.2 3.4; 5.6 6.7])

# ╔═╡ 03b891c2-9e19-11eb-2bd0-07bc352ecd9c
string.(1:3, ". ", ["First", "Second", "Third"])

# ╔═╡ 03b891f4-9e19-11eb-283d-4bb429420cd0
md"""
Sometimes, you want a container (like an array) that would normally participate in broadcast to be "protected" from broadcast's behavior of iterating over all of its elements. By placing it inside another container (like a single element [`Tuple`](@ref)) broadcast will treat it as a single value.
"""

# ╔═╡ 03b89938-9e19-11eb-28f4-2f04e93207b9
([1, 2, 3], [4, 5, 6]) .+ ([1, 2, 3],)

# ╔═╡ 03b89938-9e19-11eb-1bd2-df5580757d2e
([1, 2, 3], [4, 5, 6]) .+ tuple([1, 2, 3])

# ╔═╡ 03b8994c-9e19-11eb-28ee-a1db95a1569e
md"""
## Implementation
"""

# ╔═╡ 03b89986-9e19-11eb-1046-b184bcfa7281
md"""
The base array type in Julia is the abstract type [`AbstractArray{T,N}`](@ref). It is parameterized by the number of dimensions `N` and the element type `T`. [`AbstractVector`](@ref) and [`AbstractMatrix`](@ref) are aliases for the 1-d and 2-d cases. Operations on `AbstractArray` objects are defined using higher level operators and functions, in a way that is independent of the underlying storage. These operations generally work correctly as a fallback for any specific array implementation.
"""

# ╔═╡ 03b89a14-9e19-11eb-1ce7-358b7a1570f1
md"""
The `AbstractArray` type includes anything vaguely array-like, and implementations of it might be quite different from conventional arrays. For example, elements might be computed on request rather than stored. However, any concrete `AbstractArray{T,N}` type should generally implement at least [`size(A)`](@ref) (returning an `Int` tuple), [`getindex(A,i)`](@ref) and [`getindex(A,i1,...,iN)`](@ref getindex); mutable arrays should also implement [`setindex!`](@ref). It is recommended that these operations have nearly constant time complexity, as otherwise some array functions may be unexpectedly slow. Concrete types should also typically provide a [`similar(A,T=eltype(A),dims=size(A))`](@ref) method, which is used to allocate a similar array for [`copy`](@ref) and other out-of-place operations. No matter how an `AbstractArray{T,N}` is represented internally, `T` is the type of object returned by *integer* indexing (`A[1, ..., 1]`, when `A` is not empty) and `N` should be the length of the tuple returned by [`size`](@ref). For more details on defining custom `AbstractArray` implementations, see the [array interface guide in the interfaces chapter](@ref man-interface-array).
"""

# ╔═╡ 03b89a50-9e19-11eb-19f5-c37a663b7039
md"""
`DenseArray` is an abstract subtype of `AbstractArray` intended to include all arrays where elements are stored contiguously in column-major order (see [additional notes in Performance Tips](@ref man-performance-column-major)). The [`Array`](@ref) type is a specific instance of `DenseArray`;  [`Vector`](@ref) and [`Matrix`](@ref) are aliases for the 1-d and 2-d cases. Very few operations are implemented specifically for `Array` beyond those that are required for all `AbstractArray`s; much of the array library is implemented in a generic manner that allows all custom arrays to behave similarly.
"""

# ╔═╡ 03b89aa0-9e19-11eb-1915-7ff7e95240eb
md"""
`SubArray` is a specialization of `AbstractArray` that performs indexing by sharing memory with the original array rather than by copying it. A `SubArray` is created with the [`view`](@ref) function, which is called the same way as [`getindex`](@ref) (with an array and a series of index arguments). The result of [`view`](@ref) looks the same as the result of [`getindex`](@ref), except the data is left in place. [`view`](@ref) stores the input index vectors in a `SubArray` object, which can later be used to index the original array indirectly.  By putting the [`@views`](@ref) macro in front of an expression or block of code, any `array[...]` slice in that expression will be converted to create a `SubArray` view instead.
"""

# ╔═╡ 03b89abc-9e19-11eb-1801-379bd9c3a99e
md"""
[`BitArray`](@ref)s are space-efficient "packed" boolean arrays, which store one bit per boolean value. They can be used similarly to `Array{Bool}` arrays (which store one byte per boolean value), and can be converted to/from the latter via `Array(bitarray)` and `BitArray(array)`, respectively.
"""

# ╔═╡ 03b89ae6-9e19-11eb-2dcb-dfbda63c010f
md"""
An array is "strided" if it is stored in memory with well-defined spacings (strides) between its elements. A strided array with a supported element type may be passed to an external (non-Julia) library like BLAS or LAPACK by simply passing its [`pointer`](@ref) and the stride for each dimension. The [`stride(A, d)`](@ref) is the distance between elements along dimension `d`. For example, the builtin `Array` returned by `rand(5,7,2)` has its elements arranged contiguously in column major order. This means that the stride of the first dimension — the spacing between elements in the same column — is `1`:
"""

# ╔═╡ 03b8bb8e-9e19-11eb-3a6b-ff07a424f338
A = rand(5,7,2);

# ╔═╡ 03b8bbb4-9e19-11eb-1b8f-572bc270a667
stride(A,1)

# ╔═╡ 03b8bbe6-9e19-11eb-3fe4-c30d1ad27dce
md"""
The stride of the second dimension is the spacing between elements in the same row, skipping as many elements as there are in a single column (`5`). Similarly, jumping between the two "pages" (in the third dimension) requires skipping `5*7 == 35` elements.  The [`strides`](@ref) of this array is the tuple of these three numbers together:
"""

# ╔═╡ 03b8bcbc-9e19-11eb-32c9-adeaeeb8d342
strides(A)

# ╔═╡ 03b8bd0a-9e19-11eb-1be0-ebd23d0ebe67
md"""
In this particular case, the number of elements skipped *in memory* matches the number of *linear indices* skipped. This is only the case for contiguous arrays like `Array` (and other `DenseArray` subtypes) and is not true in general. Views with range indices are a good example of *non-contiguous* strided arrays; consider `V = @view A[1:3:4, 2:2:6, 2:-1:1]`. This view `V` refers to the same memory as `A` but is skipping and re-arranging some of its elements. The stride of the first dimension of `V` is `3` because we're only selecting every third row from our original array:
"""

# ╔═╡ 03b8c336-9e19-11eb-2fb0-776cfd668830
V = @view A[1:3:4, 2:2:6, 2:-1:1];

# ╔═╡ 03b8c336-9e19-11eb-3019-d7128632a4a5
stride(V, 1)

# ╔═╡ 03b8c354-9e19-11eb-1924-c198c01918a9
md"""
This view is similarly selecting every other column from our original `A` — and thus it needs to skip the equivalent of two five-element columns when moving between indices in the second dimension:
"""

# ╔═╡ 03b8c43a-9e19-11eb-303b-7598a2b34a7e
stride(V, 2)

# ╔═╡ 03b8c462-9e19-11eb-0e0b-51547a000414
md"""
The third dimension is interesting because its order is reversed! Thus to get from the first "page" to the second one it must go *backwards* in memory, and so its stride in this dimension is negative!
"""

# ╔═╡ 03b8c534-9e19-11eb-0a48-0b6b5b3c9cca
stride(V, 3)

# ╔═╡ 03b8c598-9e19-11eb-2751-6946158b7acd
md"""
This means that the `pointer` for `V` is actually pointing into the middle of `A`'s memory block, and it refers to elements both backwards and forwards in memory. See the [interface guide for strided arrays](@ref man-interface-strided-arrays) for more details on defining your own strided arrays. [`StridedVector`](@ref) and [`StridedMatrix`](@ref) are convenient aliases for many of the builtin array types that are considered strided arrays, allowing them to dispatch to select specialized implementations that call highly tuned and optimized BLAS and LAPACK functions using just the pointer and strides.
"""

# ╔═╡ 03b8c5c0-9e19-11eb-3cec-4f4a6a9b7833
md"""
It is worth emphasizing that strides are about offsets in memory rather than indexing. If you are looking to convert between linear (single-index) indexing and cartesian (multi-index) indexing, see [`LinearIndices`](@ref) and [`CartesianIndices`](@ref).
"""

# ╔═╡ Cell order:
# ╟─03b7899e-9e19-11eb-3873-5940a199e477
# ╟─03b78a70-9e19-11eb-2eb0-49a69a43d096
# ╟─03b78aac-9e19-11eb-0dfd-e539fb5f45f4
# ╟─03b78ac2-9e19-11eb-30de-41506bb68584
# ╟─03b78b1a-9e19-11eb-1a29-6534f01605c3
# ╟─03b78b60-9e19-11eb-249f-8554bd6fc43d
# ╟─03b78f16-9e19-11eb-1fac-2bf7305db958
# ╟─03b78f2c-9e19-11eb-3a51-69d250a0b974
# ╟─03b78f66-9e19-11eb-1f98-979c64fa5537
# ╟─03b792f4-9e19-11eb-0c21-997a1ddd2244
# ╟─03b79420-9e19-11eb-0df0-3b19b7704355
# ╟─03b7943e-9e19-11eb-3552-bb1a170af3d9
# ╠═03b79d9e-9e19-11eb-07a8-37c0e578a521
# ╠═03b79da8-9e19-11eb-2fe9-5b7ab1de3983
# ╠═03b79da8-9e19-11eb-38fe-836f432f5793
# ╟─03b79e20-9e19-11eb-0826-1f4698a4a50b
# ╟─03b79e40-9e19-11eb-33ca-598f5a9044f4
# ╟─03b79eb6-9e19-11eb-1a8f-f92d78fa8063
# ╠═03b7a596-9e19-11eb-2df7-496e802a66e5
# ╠═03b7a5a0-9e19-11eb-35a6-ed58391d5d8c
# ╠═03b7a5a8-9e19-11eb-1fbb-f71c18d96d8f
# ╠═03b7a5a8-9e19-11eb-31ad-f936d785e157
# ╟─03b7a5f0-9e19-11eb-318c-65285c67da41
# ╟─03b7a622-9e19-11eb-0166-2921d3086b87
# ╠═03b7ad54-9e19-11eb-2e82-fd75769df6cb
# ╠═03b7ad5c-9e19-11eb-2cfe-33b7de885696
# ╠═03b7ad66-9e19-11eb-1d08-55054f7b5cac
# ╟─03b7ad98-9e19-11eb-01ae-95b6df8b2bfb
# ╠═03b7b4bc-9e19-11eb-0c69-e563e8ce9329
# ╠═03b7b4c8-9e19-11eb-25c8-eb6ad3f85c33
# ╠═03b7b4c8-9e19-11eb-0c98-9dd7a119640b
# ╟─03b7b4fa-9e19-11eb-29ed-d357b64cbe61
# ╠═03b7baae-9e19-11eb-3644-fd00e1f45e25
# ╠═03b7bac2-9e19-11eb-0774-1fcbefa728cd
# ╟─03b7bb00-9e19-11eb-1060-156c1a0fb586
# ╟─03b7bc5c-9e19-11eb-0f2d-497d5b1ba179
# ╟─03b7bc7a-9e19-11eb-0c2c-e9fa29a33f5b
# ╟─03b7bcb6-9e19-11eb-1aa5-5fd56c351e35
# ╟─03b7bcde-9e19-11eb-05d7-39fbe91db11c
# ╠═03b7c210-9e19-11eb-0fcd-b369423a03bf
# ╠═03b7c21a-9e19-11eb-2d9b-fd2257c24b72
# ╟─03b7c242-9e19-11eb-062c-e5b9ebd370fc
# ╟─03b7c260-9e19-11eb-33a7-21c2a2aa0697
# ╠═03b7c42c-9e19-11eb-171d-8dd9ef515859
# ╟─03b7c474-9e19-11eb-21c3-f373fc64b4a4
# ╟─03b7c47c-9e19-11eb-0476-1380a895417e
# ╠═03b7ce90-9e19-11eb-0a2b-8137ef8a1789
# ╠═03b7cea4-9e19-11eb-1e7c-4b8c5a498dc2
# ╟─03b7cf30-9e19-11eb-29f9-4536de362c19
# ╟─03b7cfda-9e19-11eb-3c08-cbe4242f01a0
# ╟─03b7d014-9e19-11eb-229e-039fd38da137
# ╟─03b7d034-9e19-11eb-1635-eb54eb64f284
# ╠═03b7d4f8-9e19-11eb-3c87-810caba980ed
# ╟─03b7d516-9e19-11eb-3964-b78783549368
# ╠═03b7da66-9e19-11eb-39da-195b527491e9
# ╟─03b7dab6-9e19-11eb-0f65-e303e4f2320d
# ╠═03b7e5a6-9e19-11eb-3b16-47e4f32570e6
# ╟─03b7e5fe-9e19-11eb-0dd8-5b4a108f0d2d
# ╟─03b7e61e-9e19-11eb-0930-7f15840e19f0
# ╠═03b7ed62-9e19-11eb-3d8c-bd46978e6038
# ╟─03b7ed9e-9e19-11eb-08bd-23e1bbf47cf5
# ╟─03b7edf8-9e19-11eb-27bd-1f2d72c7523a
# ╠═03b7f2f8-9e19-11eb-3166-b9795a77418a
# ╟─03b7f32a-9e19-11eb-0941-a33ac108edf8
# ╟─03b7f35c-9e19-11eb-1129-c5046be48dbb
# ╠═03b7f67a-9e19-11eb-02ee-ff95cb81578b
# ╟─03b7f6cc-9e19-11eb-3bda-5f1e35e01911
# ╟─03b7f6ec-9e19-11eb-20ca-47baf524386d
# ╟─03b7f726-9e19-11eb-3f9d-cd70d6317822
# ╟─03b7f73a-9e19-11eb-289f-2dc24df2b32c
# ╠═03b805a4-9e19-11eb-0774-bd1cb0f5e57d
# ╠═03b805ae-9e19-11eb-2142-f97cd8474981
# ╠═03b805c2-9e19-11eb-04ed-bd06c1d67285
# ╠═03b805cc-9e19-11eb-1c26-536ab65f9799
# ╟─03b80600-9e19-11eb-26b3-410425d20eec
# ╟─03b80644-9e19-11eb-26e5-179cd3adf20e
# ╟─03b80658-9e19-11eb-2d9c-a3ba6cf652d4
# ╠═03b81080-9e19-11eb-0dc9-5539cfe49250
# ╠═03b81080-9e19-11eb-2033-a9af622ce675
# ╠═03b8108a-9e19-11eb-1cdf-8f0ede6fbd36
# ╟─03b810d0-9e19-11eb-1b5b-83a5d9af3c16
# ╟─03b810f8-9e19-11eb-073f-1bd3bbb9de49
# ╠═03b81260-9e19-11eb-34e1-5d18876d0dac
# ╟─03b8127e-9e19-11eb-11a9-91acafbf24cb
# ╠═03b819ea-9e19-11eb-3df8-5b0391e28063
# ╠═03b819ea-9e19-11eb-04d3-1d0605820565
# ╠═03b819f4-9e19-11eb-28e8-4fed261aa2bc
# ╟─03b81a1c-9e19-11eb-1bdc-2bad0deb4a48
# ╟─03b81a3a-9e19-11eb-2410-c5758be6385c
# ╠═03b81b20-9e19-11eb-3ca0-49817aff5f7d
# ╟─03b81b5c-9e19-11eb-3974-b5c98ed9a5c6
# ╟─03b81b98-9e19-11eb-386c-937370a66509
# ╟─03b81bca-9e19-11eb-2937-71e818622059
# ╠═03b81c92-9e19-11eb-051d-79b59160e618
# ╟─03b81cce-9e19-11eb-2f62-5d99e0816d1b
# ╠═03b81daa-9e19-11eb-13c6-e302c7c03240
# ╟─03b81dbe-9e19-11eb-0e24-2fa9b9536ed0
# ╠═03b826ec-9e19-11eb-1aae-e728877640e8
# ╠═03b826f8-9e19-11eb-23d0-afdf246db73b
# ╠═03b82700-9e19-11eb-3c32-ff08a02ae9bf
# ╠═03b82700-9e19-11eb-0327-53c91ef4df0c
# ╟─03b8272a-9e19-11eb-09d5-87ddf5654acc
# ╟─03b82746-9e19-11eb-0b34-e70f6a10fd5d
# ╟─03b82a48-9e19-11eb-34a0-f96e7274f9b7
# ╟─03b82a52-9e19-11eb-2348-45f3927f5ee7
# ╠═03b83718-9e19-11eb-080b-e3f7340ff031
# ╠═03b83736-9e19-11eb-0493-c5f6bc2a3032
# ╠═03b83736-9e19-11eb-30e0-2ffb8f647646
# ╠═03b83736-9e19-11eb-06eb-25d07b3e54df
# ╠═03b83740-9e19-11eb-22c0-ff34c87398b1
# ╠═03b83740-9e19-11eb-1aba-8fffe45f079a
# ╠═03b8374a-9e19-11eb-16d7-1bba270221de
# ╠═03b83754-9e19-11eb-2ac5-b59f7719514d
# ╟─03b8377c-9e19-11eb-0723-11d96d4719eb
# ╟─03b8379a-9e19-11eb-2871-a5edd14e62d7
# ╠═03b83e0c-9e19-11eb-1b3d-0dc6908bb4bd
# ╠═03b83e16-9e19-11eb-1663-b315690ba11a
# ╠═03b83e16-9e19-11eb-3f1a-e74e3c891565
# ╟─03b83e4a-9e19-11eb-03c9-2d66f081c0b8
# ╟─03b83e70-9e19-11eb-3540-2b1425725c17
# ╠═03b84460-9e19-11eb-0e5c-478094e90bb4
# ╠═03b8446a-9e19-11eb-091d-71b07e0ded46
# ╟─03b84488-9e19-11eb-1bd9-21f419e2ef79
# ╠═03b849e2-9e19-11eb-2e41-c1a4f31f988a
# ╠═03b849e2-9e19-11eb-1e46-1389d8c4991b
# ╟─03b84aa0-9e19-11eb-066c-298173377438
# ╟─03b84ac0-9e19-11eb-1bf0-19853e21d0cb
# ╟─03b84b0e-9e19-11eb-1ef5-9795ed8736ad
# ╠═03b85196-9e19-11eb-300b-8f40c40e626d
# ╠═03b85196-9e19-11eb-3b6f-4fa1c5ce9457
# ╠═03b8519e-9e19-11eb-3861-17450351f11e
# ╠═03b851a8-9e19-11eb-3a60-8561a1e073fb
# ╟─03b851bc-9e19-11eb-3514-cb35f077f3e5
# ╟─03b851fa-9e19-11eb-00b7-a799a45fda7c
# ╟─03b85228-9e19-11eb-1b8d-ffafb65797b9
# ╟─03b85248-9e19-11eb-3357-6d3e959c2d50
# ╟─03b85270-9e19-11eb-232f-87c8482c4c4b
# ╠═03b857ac-9e19-11eb-0204-e79254f838f3
# ╠═03b857b6-9e19-11eb-31cb-5df3201c0ba3
# ╠═03b857c8-9e19-11eb-2860-219abe38b984
# ╟─03b85806-9e19-11eb-3c32-514c65402e09
# ╠═03b85a18-9e19-11eb-24b4-4756f1469c3d
# ╠═03b85a18-9e19-11eb-090b-e385c8388918
# ╟─03b85a66-9e19-11eb-2d96-53ccd3cb8f34
# ╟─03b85a7c-9e19-11eb-18ca-751307178b02
# ╟─03b85a90-9e19-11eb-1971-2b9d15bf916d
# ╟─03b85aae-9e19-11eb-2f18-7534a3f61611
# ╠═03b860aa-9e19-11eb-22fc-aba4ecb8227d
# ╠═03b860aa-9e19-11eb-1ecb-7f378ceb99f2
# ╠═03b860aa-9e19-11eb-135c-a551f145ccd1
# ╠═03b860b2-9e19-11eb-23d2-07938c3e1431
# ╟─03b860e4-9e19-11eb-3d48-b58974045ce2
# ╟─03b86102-9e19-11eb-265e-c51116abb103
# ╠═03b86328-9e19-11eb-0748-098886df08db
# ╠═03b875de-9e19-11eb-0c85-e5e1673fcf0d
# ╟─03b87638-9e19-11eb-0237-d31d1b7ff49d
# ╟─03b8764c-9e19-11eb-3dae-7b27e7feb30e
# ╟─03b87694-9e19-11eb-3b48-0fc5e93a4467
# ╟─03b876ba-9e19-11eb-2be4-ab4c88b9118c
# ╠═03b87e2e-9e19-11eb-3a20-4b48c254e5d0
# ╠═03b87e2e-9e19-11eb-327c-fd451c8b427b
# ╠═03b87e3a-9e19-11eb-0081-05e07babfcf4
# ╟─03b87e6c-9e19-11eb-1c60-13960b3c7a60
# ╟─03b87e80-9e19-11eb-2d69-c94231dfd0a3
# ╟─03b87e9e-9e19-11eb-042c-0789f7200cf6
# ╟─03b87ebc-9e19-11eb-3000-6f4f39e88f2d
# ╟─03b87eda-9e19-11eb-2013-1917e4b5d217
# ╟─03b87eee-9e19-11eb-08b1-99f8578dd5f1
# ╟─03b87f16-9e19-11eb-1413-8f423e4fa961
# ╟─03b87fe8-9e19-11eb-1641-730b65c0037c
# ╟─03b88024-9e19-11eb-12c8-6dd5d48da637
# ╟─03b88056-9e19-11eb-24da-4774a291a4e1
# ╟─03b8807e-9e19-11eb-1193-db9ed058e814
# ╟─03b880b0-9e19-11eb-2d1a-df62e73b5de6
# ╟─03b880c4-9e19-11eb-3014-f50af7e06638
# ╟─03b880d8-9e19-11eb-202f-fb0f67f3a2dc
# ╠═03b8851a-9e19-11eb-2f62-df96a898e95a
# ╠═03b8851a-9e19-11eb-093e-a501726ab8c1
# ╟─03b8854c-9e19-11eb-2127-b3b78d17a715
# ╠═03b888bc-9e19-11eb-198f-2572d9e0cbfa
# ╠═03b888c6-9e19-11eb-1904-1946eaf6e70c
# ╠═03b888c6-9e19-11eb-3e90-e368aa1f9f8f
# ╟─03b88920-9e19-11eb-1f3c-adb859a8c895
# ╟─03b88966-9e19-11eb-02fd-6bed3ffed2d1
# ╠═03b891b8-9e19-11eb-32d1-431651d4b045
# ╠═03b891c2-9e19-11eb-3d4a-a3456fabe4d8
# ╠═03b891c2-9e19-11eb-2bd0-07bc352ecd9c
# ╟─03b891f4-9e19-11eb-283d-4bb429420cd0
# ╠═03b89938-9e19-11eb-28f4-2f04e93207b9
# ╠═03b89938-9e19-11eb-1bd2-df5580757d2e
# ╟─03b8994c-9e19-11eb-28ee-a1db95a1569e
# ╟─03b89986-9e19-11eb-1046-b184bcfa7281
# ╟─03b89a14-9e19-11eb-1ce7-358b7a1570f1
# ╟─03b89a50-9e19-11eb-19f5-c37a663b7039
# ╟─03b89aa0-9e19-11eb-1915-7ff7e95240eb
# ╟─03b89abc-9e19-11eb-1801-379bd9c3a99e
# ╟─03b89ae6-9e19-11eb-2dcb-dfbda63c010f
# ╠═03b8bb8e-9e19-11eb-3a6b-ff07a424f338
# ╠═03b8bbb4-9e19-11eb-1b8f-572bc270a667
# ╟─03b8bbe6-9e19-11eb-3fe4-c30d1ad27dce
# ╠═03b8bcbc-9e19-11eb-32c9-adeaeeb8d342
# ╟─03b8bd0a-9e19-11eb-1be0-ebd23d0ebe67
# ╠═03b8c336-9e19-11eb-2fb0-776cfd668830
# ╠═03b8c336-9e19-11eb-3019-d7128632a4a5
# ╟─03b8c354-9e19-11eb-1924-c198c01918a9
# ╠═03b8c43a-9e19-11eb-303b-7598a2b34a7e
# ╟─03b8c462-9e19-11eb-0e0b-51547a000414
# ╠═03b8c534-9e19-11eb-0a48-0b6b5b3c9cca
# ╟─03b8c598-9e19-11eb-2751-6946158b7acd
# ╟─03b8c5c0-9e19-11eb-3cec-4f4a6a9b7833
