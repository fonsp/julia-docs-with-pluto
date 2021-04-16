### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ 4ecd645b-87fc-4ea8-baef-b036c59a3ad7
md"""
# [Multi-dimensional Arrays](@id man-multi-dim-arrays)
"""

# ╔═╡ 106d052f-9b3b-4f5f-b1ac-18c459de4dc8
md"""
Julia, like most technical computing languages, provides a first-class array implementation. Most technical computing languages pay a lot of attention to their array implementation at the expense of other containers. Julia does not treat arrays in any special way. The array library is implemented almost completely in Julia itself, and derives its performance from the compiler, just like any other code written in Julia. As such, it's also possible to define custom array types by inheriting from [`AbstractArray`](@ref). See the [manual section on the AbstractArray interface](@ref man-interface-array) for more details on implementing a custom array type.
"""

# ╔═╡ e5fc64ee-5225-4b23-8539-17eb066c85a5
md"""
An array is a collection of objects stored in a multi-dimensional grid. In the most general case, an array may contain objects of type [`Any`](@ref). For most computational purposes, arrays should contain objects of a more specific type, such as [`Float64`](@ref) or [`Int32`](@ref).
"""

# ╔═╡ dccef62e-f8a9-4c94-8aa4-50b548586f25
md"""
In general, unlike many other technical computing languages, Julia does not expect programs to be written in a vectorized style for performance. Julia's compiler uses type inference and generates optimized code for scalar array indexing, allowing programs to be written in a style that is convenient and readable, without sacrificing performance, and using less memory at times.
"""

# ╔═╡ b401d76b-d207-4542-bdb8-6d9890594907
md"""
In Julia, all arguments to functions are [passed by sharing](https://en.wikipedia.org/wiki/Evaluation_strategy#Call_by_sharing) (i.e. by pointers). Some technical computing languages pass arrays by value, and while this prevents accidental modification by callees of a value in the caller, it makes avoiding unwanted copying of arrays difficult. By convention, a function name ending with a `!` indicates that it will mutate or destroy the value of one or more of its arguments (compare, for example, [`sort`](@ref) and [`sort!`](@ref)). Callees must make explicit copies to ensure that they don't modify inputs that they don't intend to change. Many non- mutating functions are implemented by calling a function of the same name with an added `!` at the end on an explicit copy of the input, and returning that copy.
"""

# ╔═╡ 58421ce7-b18e-4e89-bb1e-501d9b9f6273
md"""
## Basic Functions
"""

# ╔═╡ 488b30ab-7802-43eb-8772-e6bc4af618e2
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

# ╔═╡ 53dd35d0-bfb0-4fd8-81f1-823036851aad
md"""
## Construction and Initialization
"""

# ╔═╡ 0b055621-0a2c-4500-a9a3-7cd0fc0a3cd0
md"""
Many functions for constructing and initializing arrays are provided. In the following list of such functions, calls with a `dims...` argument can either take a single tuple of dimension sizes or a series of dimension sizes passed as a variable number of arguments. Most of these functions also accept a first input `T`, which is the element type of the array. If the type `T` is omitted it will default to [`Float64`](@ref).
"""

# ╔═╡ d0d74efc-fae1-46f5-9d62-e1217e7ea7c4
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

# ╔═╡ 80ce151e-a948-4192-9ce0-2b1de9001110
md"""
[^1]: *iid*, independently and identically distributed.
"""

# ╔═╡ 3d6b0432-f39d-41bc-8e25-148bf901e704
md"""
To see the various ways we can pass dimensions to these functions, consider the following examples:
"""

# ╔═╡ 4924e5a9-e741-45a8-a476-75d58dc70eff
zeros(Int8, 2, 3)

# ╔═╡ 4f77fe6e-0106-4e8c-af1d-01f5d68390af
zeros(Int8, (2, 3))

# ╔═╡ 66f17114-3bc9-4dc8-8593-7a9183344ded
zeros((2, 3))

# ╔═╡ 17f535be-4952-4b13-9b46-71a444780aa8
md"""
Here, `(2, 3)` is a [`Tuple`](@ref) and the first argument — the element type — is optional, defaulting to `Float64`.
"""

# ╔═╡ 8a6c0149-d0b2-48d5-b6e9-de46d16a8eac
md"""
## [Array literals](@id man-array-literals)
"""

# ╔═╡ 81dc1290-42bf-4cc7-a4f6-3538b8491375
md"""
Arrays can also be directly constructed with square braces; the syntax `[A, B, C, ...]` creates a one dimensional array (i.e., a vector) containing the comma-separated arguments as its elements. The element type ([`eltype`](@ref)) of the resulting array is automatically determined by the types of the arguments inside the braces. If all the arguments are the same type, then that is its `eltype`. If they all have a common [promotion type](@ref conversion-and-promotion) then they get converted to that type using [`convert`](@ref) and that type is the array's `eltype`. Otherwise, a heterogeneous array that can hold anything — a `Vector{Any}` — is constructed; this includes the literal `[]` where no arguments are given.
"""

# ╔═╡ d331d9ae-87dc-4774-a5ee-1c4e49f94df4
[1,2,3] # An array of `Int`s

# ╔═╡ cbfc0994-f3f4-456c-878d-3d6f9d353c0d
promote(1, 2.3, 4//5) # This combination of Int, Float64 and Rational promotes to Float64

# ╔═╡ 214c4313-c411-45a8-9192-79c3d7fd7cae
[1, 2.3, 4//5] # Thus that's the element type of this Array

# ╔═╡ 4bf010b2-78ac-48fa-b4f7-4e1f5a01e46e
[]

# ╔═╡ 3db4f742-0758-450d-8627-3d9313f3619c
md"""
### [Concatenation](@id man-array-concatenation)
"""

# ╔═╡ 318cc6c0-7ade-49c5-b961-76946635a253
md"""
If the arguments inside the square brackets are separated by semicolons (`;`) or newlines instead of commas, then their contents are *vertically concatenated* together instead of the arguments being used as elements themselves.
"""

# ╔═╡ 5b1b5964-6df7-417a-9229-6195aca908d1
[1:2, 4:5] # Has a comma, so no concatenation occurs. The ranges are themselves the elements

# ╔═╡ 56b46978-76aa-4c31-b40a-500ff9f28e94
[1:2; 4:5]

# ╔═╡ 3ff7a6b5-0a76-4701-99b2-2954c45d931a
[1:2
  4:5
  6]

# ╔═╡ 179dbbf7-1d5e-4903-a2be-6011e4855a71
md"""
Similarly, if the arguments are separated by tabs or spaces, then their contents are *horizontally concatenated* together.
"""

# ╔═╡ 9d1da54b-5d6f-4c2b-bcff-7848ed7dc5c5
[1:2  4:5  7:8]

# ╔═╡ 139adac1-8cf1-4755-b0ca-a6c342681951
[[1,2]  [4,5]  [7,8]]

# ╔═╡ bc1855fe-8ada-48d5-b66f-3178c87c2a73
[1 2 3] # Numbers can also be horizontally concatenated

# ╔═╡ bbabd66a-8619-4d06-ac3c-92ba3717242a
md"""
Using semicolons (or newlines) and spaces (or tabs) can be combined to concatenate both horizontally and vertically at the same time.
"""

# ╔═╡ 9c61f57b-79ef-470b-81e0-808079ee1b28
[1 2
  3 4]

# ╔═╡ 4f69452a-c6ac-469e-8150-7148e9cb0113
[zeros(Int, 2, 2) [1; 2]
  [3 4]            5]

# ╔═╡ ce212505-529c-4415-9542-59c851b0e4c8
md"""
More generally, concatenation can be accomplished through the [`cat`](@ref) function. These syntaxes are shorthands for function calls that themselves are convenience functions:
"""

# ╔═╡ 227edcfd-6d5e-4b1e-aa26-a831d49042f0
md"""
| Syntax            | Function        | Description                                        |
|:----------------- |:--------------- |:-------------------------------------------------- |
|                   | [`cat`](@ref)   | concatenate input arrays along dimension(s) `k`    |
| `[A; B; C; ...]`  | [`vcat`](@ref)  | shorthand for `cat(A...; dims=1)                   |
| `[A B C ...]`     | [`hcat`](@ref)  | shorthand for `cat(A...; dims=2)                   |
| `[A B; C D; ...]` | [`hvcat`](@ref) | simultaneous vertical and horizontal concatenation |
"""

# ╔═╡ df8ceab5-12a7-4e1e-8375-fd8e0b84b970
md"""
### Typed array literals
"""

# ╔═╡ a4fed56d-055a-4154-9572-912a790677cf
md"""
An array with a specific element type can be constructed using the syntax `T[A, B, C, ...]`. This will construct a 1-d array with element type `T`, initialized to contain elements `A`, `B`, `C`, etc. For example, `Any[x, y, z]` constructs a heterogeneous array that can contain any values.
"""

# ╔═╡ 71c0a0ba-736c-40f6-af8c-0777b1f602b3
md"""
Concatenation syntax can similarly be prefixed with a type to specify the element type of the result.
"""

# ╔═╡ ca9f5f95-6171-4e4f-849c-7f284be33de1
[[1 2] [3 4]]

# ╔═╡ 831c5493-280f-447d-ac46-42391b7bc836
Int8[[1 2] [3 4]]

# ╔═╡ 00034a75-cb6f-48a7-ac77-c64e43fc3b79
md"""
## [Comprehensions](@id man-comprehensions)
"""

# ╔═╡ 70cceb0a-ef3d-4048-93a5-7b0820aa3ebb
md"""
Comprehensions provide a general and powerful way to construct arrays. Comprehension syntax is similar to set construction notation in mathematics:
"""

# ╔═╡ c63896d9-16a5-4104-bc80-5eec3d6b49b1
md"""
```
A = [ F(x,y,...) for x=rx, y=ry, ... ]
```
"""

# ╔═╡ 13f19993-1b3c-48e5-8db5-ebb8a0cd7be9
md"""
The meaning of this form is that `F(x,y,...)` is evaluated with the variables `x`, `y`, etc. taking on each value in their given list of values. Values can be specified as any iterable object, but will commonly be ranges like `1:n` or `2:(n-1)`, or explicit arrays of values like `[1.2, 3.4, 5.7]`. The result is an N-d dense array with dimensions that are the concatenation of the dimensions of the variable ranges `rx`, `ry`, etc. and each `F(x,y,...)` evaluation returns a scalar.
"""

# ╔═╡ 21547949-e034-47df-9c57-752037cd3278
md"""
The following example computes a weighted average of the current element and its left and right neighbor along a 1-d grid. :
"""

# ╔═╡ 0c77a2b9-3f06-473e-af96-41046bfc9027
x = rand(8)

# ╔═╡ f665a7d3-f9df-4a1f-97ab-86d7cee262e4
[ 0.25*x[i-1] + 0.5*x[i] + 0.25*x[i+1] for i=2:length(x)-1 ]

# ╔═╡ 13533cfd-9a10-4613-988f-2897609b3511
md"""
The resulting array type depends on the types of the computed elements just like [array literals](@ref man-array-literals) do. In order to control the type explicitly, a type can be prepended to the comprehension. For example, we could have requested the result in single precision by writing:
"""

# ╔═╡ e458f64c-6f6f-4b9a-89b7-ca7cb5684fd6
md"""
```julia
Float32[ 0.25*x[i-1] + 0.5*x[i] + 0.25*x[i+1] for i=2:length(x)-1 ]
```
"""

# ╔═╡ 7f56d799-63f1-4dc3-a763-f7b3b4539f00
md"""
## Generator Expressions
"""

# ╔═╡ abe26a54-74a9-4e8b-983a-8829f40d3478
md"""
Comprehensions can also be written without the enclosing square brackets, producing an object known as a generator. This object can be iterated to produce values on demand, instead of allocating an array and storing them in advance (see [Iteration](@ref)). For example, the following expression sums a series without allocating memory:
"""

# ╔═╡ 58841c1b-a14d-433d-aa5c-57f1fdfdaa1a
sum(1/n^2 for n=1:1000)

# ╔═╡ 00ac906f-57ca-4916-ad80-8fa324ae2ada
md"""
When writing a generator expression with multiple dimensions inside an argument list, parentheses are needed to separate the generator from subsequent arguments:
"""

# ╔═╡ e11e9258-9e52-4bc7-872f-503717a842c3
map(tuple, 1/(i+j) for i=1:2, j=1:2, [1:4;])

# ╔═╡ cf03452a-38bf-46b0-9646-37433fc85b79
md"""
All comma-separated expressions after `for` are interpreted as ranges. Adding parentheses lets us add a third argument to [`map`](@ref):
"""

# ╔═╡ 59ed9488-f857-4d81-963c-6735658825f2
map(tuple, (1/(i+j) for i=1:2, j=1:2), [1 3; 2 4])

# ╔═╡ 2054cbd4-6961-4fdd-9c33-2625017841a8
md"""
Generators are implemented via inner functions. Just like inner functions used elsewhere in the language, variables from the enclosing scope can be \"captured\" in the inner function.  For example, `sum(p[i] - q[i] for i=1:n)` captures the three variables `p`, `q` and `n` from the enclosing scope. Captured variables can present performance challenges; see [performance tips](@ref man-performance-captured).
"""

# ╔═╡ 8e65f8d3-2e01-4f16-944f-8e727597c009
md"""
Ranges in generators and comprehensions can depend on previous ranges by writing multiple `for` keywords:
"""

# ╔═╡ f4addce8-73da-4805-be72-3d38ca2ab843
[(i,j) for i=1:3 for j=1:i]

# ╔═╡ 099b7b37-91a5-4221-9280-86c4079bbca3
md"""
In such cases, the result is always 1-d.
"""

# ╔═╡ 2a50f80e-03f7-44cd-b110-452a87a21f15
md"""
Generated values can be filtered using the `if` keyword:
"""

# ╔═╡ b37e20b3-c2ef-4958-8d6a-77d667ae14c2
[(i,j) for i=1:3 for j=1:i if i+j == 4]

# ╔═╡ ba74767e-33b0-41a7-a960-1ca17c95b6a4
md"""
## [Indexing](@id man-array-indexing)
"""

# ╔═╡ bf2cca86-8556-4bdd-a349-c7838b73a04a
md"""
The general syntax for indexing into an n-dimensional array `A` is:
"""

# ╔═╡ eeca6b8b-6b1a-43ba-a069-1980596a1a6b
md"""
```
X = A[I_1, I_2, ..., I_n]
```
"""

# ╔═╡ 2a95917a-ef73-43f1-a598-166c44102616
md"""
where each `I_k` may be a scalar integer, an array of integers, or any other [supported index](@ref man-supported-index-types). This includes [`Colon`](@ref) (`:`) to select all indices within the entire dimension, ranges of the form `a:c` or `a:b:c` to select contiguous or strided subsections, and arrays of booleans to select elements at their `true` indices.
"""

# ╔═╡ 8db7b148-e958-45fc-a978-285dc71064f0
md"""
If all the indices are scalars, then the result `X` is a single element from the array `A`. Otherwise, `X` is an array with the same number of dimensions as the sum of the dimensionalities of all the indices.
"""

# ╔═╡ 05de6973-b6b8-4803-b055-ea7588533bae
md"""
If all indices `I_k` are vectors, for example, then the shape of `X` would be `(length(I_1), length(I_2), ..., length(I_n))`, with location `i_1, i_2, ..., i_n` of `X` containing the value `A[I_1[i_1], I_2[i_2], ..., I_n[i_n]]`.
"""

# ╔═╡ 975e0843-37c4-43a1-afe8-fc9ffcc0766c
md"""
Example:
"""

# ╔═╡ 1f7ed869-7bc2-4258-8f80-a96b2dceeff2
A = reshape(collect(1:16), (2, 2, 2, 2))

# ╔═╡ 1ec9d31a-64c4-4058-9c9d-d0302ee20588
A[1, 2, 1, 1] # all scalar indices

# ╔═╡ d4f9a040-381c-4efa-928d-869005556c49
A[[1, 2], [1], [1, 2], [1]] # all vector indices

# ╔═╡ b0251cc5-8c76-4e97-a792-52212dc3a946
A[[1, 2], [1], [1, 2], 1] # a mix of index types

# ╔═╡ e67fcb97-2228-4e7c-a6fa-73a1b21b7d9c
md"""
Note how the size of the resulting array is different in the last two cases.
"""

# ╔═╡ 92d0e29d-5052-4be0-bc0b-0026ef0050e9
md"""
If `I_1` is changed to a two-dimensional matrix, then `X` becomes an `n+1`-dimensional array of shape `(size(I_1, 1), size(I_1, 2), length(I_2), ..., length(I_n))`. The matrix adds a dimension.
"""

# ╔═╡ 5802e226-39b5-4c3d-a1fb-3aa99ee0512f
md"""
Example:
"""

# ╔═╡ f77d5ac9-79f8-453c-8594-6d387895f74f
A = reshape(collect(1:16), (2, 2, 2, 2));

# ╔═╡ bd86dd4b-7920-4738-b22b-969af2afe7ab
A[[1 2; 1 2]]

# ╔═╡ 6ed4874d-22be-4436-9db5-e12c90b58c1e
A[[1 2; 1 2], 1, 2, 1]

# ╔═╡ 5dfa633f-94df-4673-abd5-1eb574f137fc
md"""
The location `i_1, i_2, i_3, ..., i_{n+1}` contains the value at `A[I_1[i_1, i_2], I_2[i_3], ..., I_n[i_{n+1}]]`. All dimensions indexed with scalars are dropped. For example, if `J` is an array of indices, then the result of `A[2, J, 3]` is an array with size `size(J)`. Its `j`th element is populated by `A[2, J[j], 3]`.
"""

# ╔═╡ c105eda8-77ad-4db7-9690-699c356dd492
md"""
As a special part of this syntax, the `end` keyword may be used to represent the last index of each dimension within the indexing brackets, as determined by the size of the innermost array being indexed. Indexing syntax without the `end` keyword is equivalent to a call to [`getindex`](@ref):
"""

# ╔═╡ 98b279a8-771d-4802-85d8-e1e3d1ab7de1
md"""
```
X = getindex(A, I_1, I_2, ..., I_n)
```
"""

# ╔═╡ 39bab95f-0edc-4201-9822-6d309d8bd631
md"""
Example:
"""

# ╔═╡ 3794f845-14c9-489d-948f-a44ae76be934
x = reshape(1:16, 4, 4)

# ╔═╡ f4eae434-0aa6-41c2-9a67-bb0903cf9299
x[2:3, 2:end-1]

# ╔═╡ 666cc4bf-8f44-4e5c-bfef-0951b7eebd9d
x[1, [2 3; 4 1]]

# ╔═╡ d5bf317b-2a52-4b51-afce-c80bc2e1ab13
md"""
## [Indexed Assignment](@id man-indexed-assignment)
"""

# ╔═╡ d23e497b-9e6a-4ab1-b8f9-9ef71ec0bced
md"""
The general syntax for assigning values in an n-dimensional array `A` is:
"""

# ╔═╡ e7a8cb0a-a151-4155-97b3-9a4815577214
md"""
```
A[I_1, I_2, ..., I_n] = X
```
"""

# ╔═╡ 76764ca5-2c60-4afd-989f-ad95f077efe1
md"""
where each `I_k` may be a scalar integer, an array of integers, or any other [supported index](@ref man-supported-index-types). This includes [`Colon`](@ref) (`:`) to select all indices within the entire dimension, ranges of the form `a:c` or `a:b:c` to select contiguous or strided subsections, and arrays of booleans to select elements at their `true` indices.
"""

# ╔═╡ 10316feb-f82f-4999-ac88-d8095f122e92
md"""
If all indices `I_k` are integers, then the value in location `I_1, I_2, ..., I_n` of `A` is overwritten with the value of `X`, [`convert`](@ref)ing to the [`eltype`](@ref) of `A` if necessary.
"""

# ╔═╡ 81f3b529-1e2a-4917-93d8-c76c729ddc22
md"""
If any index `I_k` selects more than one location, then the right hand side `X` must be an array with the same shape as the result of indexing `A[I_1, I_2, ..., I_n]` or a vector with the same number of elements. The value in location `I_1[i_1], I_2[i_2], ..., I_n[i_n]` of `A` is overwritten with the value `X[I_1, I_2, ..., I_n]`, converting if necessary. The element-wise assignment operator `.=` may be used to [broadcast](@ref Broadcasting) `X` across the selected locations:
"""

# ╔═╡ 71df007e-1618-4ac8-a3df-c375fc017649
md"""
```
A[I_1, I_2, ..., I_n] .= X
```
"""

# ╔═╡ e24f6041-1f76-4527-8e60-57623c1cb97c
md"""
Just as in [Indexing](@ref man-array-indexing), the `end` keyword may be used to represent the last index of each dimension within the indexing brackets, as determined by the size of the array being assigned into. Indexed assignment syntax without the `end` keyword is equivalent to a call to [`setindex!`](@ref):
"""

# ╔═╡ d9c6c20e-4529-4b0d-811e-2bef197c6cd5
md"""
```
setindex!(A, X, I_1, I_2, ..., I_n)
```
"""

# ╔═╡ 1884b924-4691-4aa8-8221-320f2d25423b
md"""
Example:
"""

# ╔═╡ 8b1478af-bde0-4033-80d9-3a2f3dc85d94
x = collect(reshape(1:9, 3, 3))

# ╔═╡ 4be93139-d942-47f9-82d4-dde69c684839
x[3, 3] = -9;

# ╔═╡ f6390d52-5f86-4a24-b808-3ca22b7d274b
x[1:2, 1:2] = [-1 -4; -2 -5];

# ╔═╡ 480a459f-a278-4bdc-b378-a1d2a74f0952
x

# ╔═╡ 3833df37-0cea-4067-8812-b7a5d2973419
md"""
## [Supported index types](@id man-supported-index-types)
"""

# ╔═╡ a08a845c-cff1-4e85-8eae-75c430faf6a2
md"""
In the expression `A[I_1, I_2, ..., I_n]`, each `I_k` may be a scalar index, an array of scalar indices, or an object that represents an array of scalar indices and can be converted to such by [`to_indices`](@ref):
"""

# ╔═╡ 171d2ee9-5afb-407e-a87c-86b11958ec65
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

# ╔═╡ e51ada19-e238-4a47-8ef7-7e711136fb30
md"""
Some examples:
"""

# ╔═╡ 5671280c-7992-4051-9260-aa592bca4009
A = reshape(collect(1:2:18), (3, 3))

# ╔═╡ ddb41d1a-0151-46a6-b9a0-ba4f53730b6e
A[4]

# ╔═╡ 33d40760-88b7-44f5-834c-b92fe4f0a065
A[[2, 5, 8]]

# ╔═╡ 93e88157-f110-424d-9630-efe8263903e0
A[[1 4; 3 8]]

# ╔═╡ ae1688bf-0923-465c-a03a-8d48566eae70
A[[]]

# ╔═╡ fa53e253-b643-459e-83f1-ca6d73de5d2e
A[1:2:5]

# ╔═╡ 58396e07-32f4-4097-987a-c034cea13b09
A[2, :]

# ╔═╡ c4da6925-92c5-4dc9-b802-3cc51c24ebb5
A[:, 3]

# ╔═╡ 2962d73b-e02a-428c-8981-0750f73fd0bc
md"""
### Cartesian indices
"""

# ╔═╡ 0986fc00-3046-4537-ba5e-ac8bb2c7f8c0
md"""
The special `CartesianIndex{N}` object represents a scalar index that behaves like an `N`-tuple of integers spanning multiple dimensions.  For example:
"""

# ╔═╡ 4b3a90d6-30ac-4d01-9000-e6f4560c1765
A = reshape(1:32, 4, 4, 2);

# ╔═╡ 63a793ae-86ca-4a2a-887a-cd38a0ad905b
A[3, 2, 1]

# ╔═╡ 918e42b7-88ac-4a43-a6c8-2216b7160423
A[CartesianIndex(3, 2, 1)] == A[3, 2, 1] == 7

# ╔═╡ be49dcb9-c22b-46a3-a63e-7d2712a53080
md"""
Considered alone, this may seem relatively trivial; `CartesianIndex` simply gathers multiple integers together into one object that represents a single multidimensional index. When combined with other indexing forms and iterators that yield `CartesianIndex`es, however, this can produce very elegant and efficient code. See [Iteration](@ref) below, and for some more advanced examples, see [this blog post on multidimensional algorithms and iteration](https://julialang.org/blog/2016/02/iteration).
"""

# ╔═╡ f229c284-1d59-4c29-b183-445ece5a368c
md"""
Arrays of `CartesianIndex{N}` are also supported. They represent a collection of scalar indices that each span `N` dimensions, enabling a form of indexing that is sometimes referred to as pointwise indexing. For example, it enables accessing the diagonal elements from the first \"page\" of `A` from above:
"""

# ╔═╡ ba8a9f8b-074f-43c0-8063-546f3e45f37a
page = A[:,:,1]

# ╔═╡ 09b949b8-02ce-41fe-aace-69329dd9e0a4
page[[CartesianIndex(1,1),
       CartesianIndex(2,2),
       CartesianIndex(3,3),
       CartesianIndex(4,4)]]

# ╔═╡ d4a5336e-2eef-4a53-9c35-435921a8f007
md"""
This can be expressed much more simply with [dot broadcasting](@ref man-vectorized) and by combining it with a normal integer index (instead of extracting the first `page` from `A` as a separate step). It can even be combined with a `:` to extract both diagonals from the two pages at the same time:
"""

# ╔═╡ 9798a995-76ba-4e5d-9050-65e827623754
A[CartesianIndex.(axes(A, 1), axes(A, 2)), 1]

# ╔═╡ e5434597-2f44-4636-8d93-4a0cc8435663
A[CartesianIndex.(axes(A, 1), axes(A, 2)), :]

# ╔═╡ f90d16d2-d5f8-4fc7-83f6-60fc6f795ecd
md"""
!!! warning
    `CartesianIndex` and arrays of `CartesianIndex` are not compatible with the `end` keyword to represent the last index of a dimension. Do not use `end` in indexing expressions that may contain either `CartesianIndex` or arrays thereof.
"""

# ╔═╡ 26da36a5-04b8-4820-81b3-e729e3bdf860
md"""
### Logical indexing
"""

# ╔═╡ 00ed481a-cf6c-47ae-b7cd-db33f4a31c98
md"""
Often referred to as logical indexing or indexing with a logical mask, indexing by a boolean array selects elements at the indices where its values are `true`. Indexing by a boolean vector `B` is effectively the same as indexing by the vector of integers that is returned by [`findall(B)`](@ref). Similarly, indexing by a `N`-dimensional boolean array is effectively the same as indexing by the vector of `CartesianIndex{N}`s where its values are `true`. A logical index must be a vector of the same length as the dimension it indexes into, or it must be the only index provided and match the size and dimensionality of the array it indexes into. It is generally more efficient to use boolean arrays as indices directly instead of first calling [`findall`](@ref).
"""

# ╔═╡ 9f37875c-463f-440f-b7a0-c3f52cc70498
x = reshape(1:16, 4, 4)

# ╔═╡ 1c4d9240-8a90-410e-afb5-e785740eb09f
x[[false, true, true, false], :]

# ╔═╡ b5ef7ef2-9ae7-4c72-9aee-703078d45612
mask = map(ispow2, x)

# ╔═╡ c16cfbfa-96e0-44a9-adbc-f1789b64cb68
x[mask]

# ╔═╡ d21f9244-700d-4828-8547-bb3283e34dc5
md"""
### Number of indices
"""

# ╔═╡ 079ea006-8f6a-4938-8e86-8fe1ae4336e4
md"""
#### Cartesian indexing
"""

# ╔═╡ 80a60781-f150-480b-8ee2-80e12abea3a3
md"""
The ordinary way to index into an `N`-dimensional array is to use exactly `N` indices; each index selects the position(s) in its particular dimension. For example, in the three-dimensional array `A = rand(4, 3, 2)`, `A[2, 3, 1]` will select the number in the second row of the third column in the first \"page\" of the array. This is often referred to as *cartesian indexing*.
"""

# ╔═╡ efa59260-bc89-42e7-b1da-dc5445f4327e
md"""
#### Linear indexing
"""

# ╔═╡ 6a0200b6-bd1d-4df8-aaac-baeda2e6cf0f
md"""
When exactly one index `i` is provided, that index no longer represents a location in a particular dimension of the array. Instead, it selects the `i`th element using the column-major iteration order that linearly spans the entire array. This is known as *linear indexing*. It essentially treats the array as though it had been reshaped into a one-dimensional vector with [`vec`](@ref).
"""

# ╔═╡ 621012fc-a7ef-46ac-bfc4-0b3319a4b9f4
A = [2 6; 4 7; 3 1]

# ╔═╡ 4b1e70be-98e6-46a3-b132-84ffe9ff95be
A[5]

# ╔═╡ 2f97c058-ffc1-4cc8-a93b-6cc81121ff16
vec(A)[5]

# ╔═╡ 416c878c-e2ce-49b3-b485-e2e965724fcb
md"""
A linear index into the array `A` can be converted to a `CartesianIndex` for cartesian indexing with `CartesianIndices(A)[i]` (see [`CartesianIndices`](@ref)), and a set of `N` cartesian indices can be converted to a linear index with `LinearIndices(A)[i_1, i_2, ..., i_N]` (see [`LinearIndices`](@ref)).
"""

# ╔═╡ 398c0eaa-f7fb-4204-8489-c2c6fcf66a23
CartesianIndices(A)[5]

# ╔═╡ c37ef0c9-8697-417c-812b-ed7fa66cb5c8
LinearIndices(A)[2, 2]

# ╔═╡ 876037ed-914f-43b7-80f4-f6662afc846f
md"""
It's important to note that there's a very large assymmetry in the performance of these conversions. Converting a linear index to a set of cartesian indices requires dividing and taking the remainder, whereas going the other way is just multiplies and adds. In modern processors, integer division can be 10-50 times slower than multiplication. While some arrays — like [`Array`](@ref) itself — are implemented using a linear chunk of memory and directly use a linear index in their implementations, other arrays — like [`Diagonal`](@ref) — need the full set of cartesian indices to do their lookup (see [`IndexStyle`](@ref) to introspect which is which). As such, when iterating over an entire array, it's much better to iterate over [`eachindex(A)`](@ref) instead of `1:length(A)`. Not only will the former be much faster in cases where `A` is `IndexCartesian`, but it will also support OffsetArrays, too.
"""

# ╔═╡ 414b5ba6-88ac-4059-9355-519bfb31b457
md"""
#### Omitted and extra indices
"""

# ╔═╡ 06dfea23-248c-4caf-b918-50dcb6a7a008
md"""
In addition to linear indexing, an `N`-dimensional array may be indexed with fewer or more than `N` indices in certain situations.
"""

# ╔═╡ 77e1d1a7-b7d7-4306-8ee6-ce3311b662f2
md"""
Indices may be omitted if the trailing dimensions that are not indexed into are all length one. In other words, trailing indices can be omitted only if there is only one possible value that those omitted indices could be for an in-bounds indexing expression. For example, a four-dimensional array with size `(3, 4, 2, 1)` may be indexed with only three indices as the dimension that gets skipped (the fourth dimension) has length one. Note that linear indexing takes precedence over this rule.
"""

# ╔═╡ efc5503b-a18e-42ac-b03f-7f0057d6853a
A = reshape(1:24, 3, 4, 2, 1)

# ╔═╡ a5e30da5-96f2-4119-9568-bd78dd1c9b41
A[1, 3, 2] # Omits the fourth dimension (length 1)

# ╔═╡ e79672d8-8e23-47b1-bf91-4cc9cbed1379
A[1, 3] # Attempts to omit dimensions 3 & 4 (lengths 2 and 1)

# ╔═╡ 9ec08e35-e7f9-40d9-be27-2ef6de0cc3a0
A[19] # Linear indexing

# ╔═╡ 5d7eba4d-663e-423e-9e38-7e421216b90f
md"""
When omitting *all* indices with `A[]`, this semantic provides a simple idiom to retrieve the only element in an array and simultaneously ensure that there was only one element.
"""

# ╔═╡ cb46c602-3204-420c-b36a-6e190b7ce709
md"""
Similarly, more than `N` indices may be provided if all the indices beyond the dimensionality of the array are `1` (or more generally are the first and only element of `axes(A, d)` where `d` is that particular dimension number). This allows vectors to be indexed like one-column matrices, for example:
"""

# ╔═╡ d22fc7af-421b-4c47-8e82-881d14e6e0e8
A = [8,6,7]

# ╔═╡ 22a03864-f2c5-4ab3-9b27-a8847dbca26b
A[2,1]

# ╔═╡ 6625ed75-4d82-4dd6-b198-937184b69270
md"""
## Iteration
"""

# ╔═╡ 04511c11-e5e6-437d-bef6-cce9dcb11ca1
md"""
The recommended ways to iterate over a whole array are
"""

# ╔═╡ 70ae4b62-581d-46a2-beca-6bdcf65fa91b
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

# ╔═╡ 43f2ef81-5877-4bf0-ad6e-348969e788bf
md"""
The first construct is used when you need the value, but not index, of each element. In the second construct, `i` will be an `Int` if `A` is an array type with fast linear indexing; otherwise, it will be a `CartesianIndex`:
"""

# ╔═╡ 9ae092a5-2653-48ff-83a5-cac37b1b34d5
A = rand(4,3);

# ╔═╡ d4d05517-5eee-4d9b-85f6-ae790f124e92
B = view(A, 1:3, 2:3);

# ╔═╡ 34929f5a-e162-4f47-b905-a6a483c6e56e
for i in eachindex(B)
     @show i
 end

# ╔═╡ 00fb3441-74e7-49bb-b1d9-03cd64ae5cbc
md"""
In contrast with `for i = 1:length(A)`, iterating with [`eachindex`](@ref) provides an efficient way to iterate over any array type.
"""

# ╔═╡ 4ccdeab7-b56c-4eb5-ade6-67ef8fd77aa1
md"""
## Array traits
"""

# ╔═╡ bbf9fa3e-a81a-44f0-a733-c4326ea20b22
md"""
If you write a custom [`AbstractArray`](@ref) type, you can specify that it has fast linear indexing using
"""

# ╔═╡ 7072be0a-2aa2-499d-8d91-ad4037fe0cc6
md"""
```julia
Base.IndexStyle(::Type{<:MyArray}) = IndexLinear()
```
"""

# ╔═╡ 978de581-cf16-4e6e-8fa6-3c4066963c34
md"""
This setting will cause `eachindex` iteration over a `MyArray` to use integers. If you don't specify this trait, the default value `IndexCartesian()` is used.
"""

# ╔═╡ 3ed102b5-4c52-46b9-9786-7e8d378d7f12
md"""
## [Array and Vectorized Operators and Functions](@id man-array-and-vectorized-operators-and-functions)
"""

# ╔═╡ ff652d09-8481-4605-9494-61fe63b77694
md"""
The following operators are supported for arrays:
"""

# ╔═╡ b4d36738-0196-4245-aa02-cf3af6436dc0
md"""
1. Unary arithmetic – `-`, `+`
2. Binary arithmetic – `-`, `+`, `*`, `/`, `\`, `^`
3. Comparison – `==`, `!=`, `≈` ([`isapprox`](@ref)), `≉`
"""

# ╔═╡ a23f43fc-68d7-45ce-aabb-61281a7479e7
md"""
To enable convenient vectorization of mathematical and other operations, Julia [provides the dot syntax](@ref man-vectorized) `f.(args...)`, e.g. `sin.(x)` or `min.(x,y)`, for elementwise operations over arrays or mixtures of arrays and scalars (a [Broadcasting](@ref) operation); these have the additional advantage of \"fusing\" into a single loop when combined with other dot calls, e.g. `sin.(cos.(x))`.
"""

# ╔═╡ 27f08f01-7953-47e8-a28f-d40a3fa5bee4
md"""
Also, *every* binary operator supports a [dot version](@ref man-dot-operators) that can be applied to arrays (and combinations of arrays and scalars) in such [fused broadcasting operations](@ref man-vectorized), e.g. `z .== sin.(x .* y)`.
"""

# ╔═╡ d7101c57-06cc-45c8-8fb9-e6ef433156f8
md"""
Note that comparisons such as `==` operate on whole arrays, giving a single boolean answer. Use dot operators like `.==` for elementwise comparisons. (For comparison operations like `<`, *only* the elementwise `.<` version is applicable to arrays.)
"""

# ╔═╡ e20144c7-bb74-423f-a16b-9972c6820d2e
md"""
Also notice the difference between `max.(a,b)`, which [`broadcast`](@ref)s [`max`](@ref) elementwise over `a` and `b`, and [`maximum(a)`](@ref), which finds the largest value within `a`. The same relationship holds for `min.(a,b)` and `minimum(a)`.
"""

# ╔═╡ c7cbf48b-3438-4d1a-b3ed-a9831d30c2d1
md"""
## Broadcasting
"""

# ╔═╡ 7fee9c03-fd77-4c3d-b3f4-b84fbab3ffea
md"""
It is sometimes useful to perform element-by-element binary operations on arrays of different sizes, such as adding a vector to each column of a matrix. An inefficient way to do this would be to replicate the vector to the size of the matrix:
"""

# ╔═╡ f2efdd8b-bc96-4a0d-9092-30218ef5c08a
a = rand(2,1); A = rand(2,3);

# ╔═╡ 5f41d6ae-649c-4ec4-8efc-35ab10e404c5
repeat(a,1,3)+A

# ╔═╡ 5b12baed-278b-4e9b-a349-13ba2c1743ff
md"""
This is wasteful when dimensions get large, so Julia provides [`broadcast`](@ref), which expands singleton dimensions in array arguments to match the corresponding dimension in the other array without using extra memory, and applies the given function elementwise:
"""

# ╔═╡ 0183c94f-3ee0-404a-9485-b6e423f239a6
broadcast(+, a, A)

# ╔═╡ c7e7f458-8187-4e1f-9905-4769e2639c72
b = rand(1,2)

# ╔═╡ 9ee64687-31a9-46e7-aa98-af1b626481ae
broadcast(+, a, b)

# ╔═╡ 36aee38a-88fd-4133-a970-83ce12834c94
md"""
[Dotted operators](@ref man-dot-operators) such as `.+` and `.*` are equivalent to `broadcast` calls (except that they fuse, as [described above](@ref man-array-and-vectorized-operators-and-functions)). There is also a [`broadcast!`](@ref) function to specify an explicit destination (which can also be accessed in a fusing fashion by `.=` assignment). In fact, `f.(args...)` is equivalent to `broadcast(f, args...)`, providing a convenient syntax to broadcast any function ([dot syntax](@ref man-vectorized)). Nested \"dot calls\" `f.(...)` (including calls to `.+` etcetera) [automatically fuse](@ref man-dot-operators) into a single `broadcast` call.
"""

# ╔═╡ cdffb2f0-22a7-4fe4-afe3-91616415a18d
md"""
Additionally, [`broadcast`](@ref) is not limited to arrays (see the function documentation); it also handles scalars, tuples and other collections.  By default, only some argument types are considered scalars, including (but not limited to) `Number`s, `String`s, `Symbol`s, `Type`s, `Function`s and some common singletons like `missing` and `nothing`. All other arguments are iterated over or indexed into elementwise.
"""

# ╔═╡ 60509ecb-acf2-4449-9ca5-356eac8ba355
convert.(Float32, [1, 2])

# ╔═╡ d1f65443-b9a6-459d-8ee5-b0593a64cc2b
ceil.(UInt8, [1.2 3.4; 5.6 6.7])

# ╔═╡ 4533a5a9-0c3e-4c4e-9826-f38a3d9b5078
string.(1:3, ". ", ["First", "Second", "Third"])

# ╔═╡ 8bc1eb6c-17ec-49f5-bd72-a589223c47f9
md"""
Sometimes, you want a container (like an array) that would normally participate in broadcast to be \"protected\" from broadcast's behavior of iterating over all of its elements. By placing it inside another container (like a single element [`Tuple`](@ref)) broadcast will treat it as a single value.
"""

# ╔═╡ a86710ed-37ee-4875-8702-5ff041407079
([1, 2, 3], [4, 5, 6]) .+ ([1, 2, 3],)

# ╔═╡ 7c8641c4-f621-49f7-b675-a6ca77c98b94
([1, 2, 3], [4, 5, 6]) .+ tuple([1, 2, 3])

# ╔═╡ 03f3906e-30d1-444a-813f-0f69c5f5ba59
md"""
## Implementation
"""

# ╔═╡ c231c202-4e9f-43dc-8584-a91790c381a2
md"""
The base array type in Julia is the abstract type [`AbstractArray{T,N}`](@ref). It is parameterized by the number of dimensions `N` and the element type `T`. [`AbstractVector`](@ref) and [`AbstractMatrix`](@ref) are aliases for the 1-d and 2-d cases. Operations on `AbstractArray` objects are defined using higher level operators and functions, in a way that is independent of the underlying storage. These operations generally work correctly as a fallback for any specific array implementation.
"""

# ╔═╡ e7b07ea6-c2fa-42cb-90c3-d994522526fb
md"""
The `AbstractArray` type includes anything vaguely array-like, and implementations of it might be quite different from conventional arrays. For example, elements might be computed on request rather than stored. However, any concrete `AbstractArray{T,N}` type should generally implement at least [`size(A)`](@ref) (returning an `Int` tuple), [`getindex(A,i)`](@ref) and [`getindex(A,i1,...,iN)`](@ref getindex); mutable arrays should also implement [`setindex!`](@ref). It is recommended that these operations have nearly constant time complexity, as otherwise some array functions may be unexpectedly slow. Concrete types should also typically provide a [`similar(A,T=eltype(A),dims=size(A))`](@ref) method, which is used to allocate a similar array for [`copy`](@ref) and other out-of-place operations. No matter how an `AbstractArray{T,N}` is represented internally, `T` is the type of object returned by *integer* indexing (`A[1, ..., 1]`, when `A` is not empty) and `N` should be the length of the tuple returned by [`size`](@ref). For more details on defining custom `AbstractArray` implementations, see the [array interface guide in the interfaces chapter](@ref man-interface-array).
"""

# ╔═╡ 9cb601c2-d7a0-4d84-8814-ae35cf3f5a14
md"""
`DenseArray` is an abstract subtype of `AbstractArray` intended to include all arrays where elements are stored contiguously in column-major order (see [additional notes in Performance Tips](@ref man-performance-column-major)). The [`Array`](@ref) type is a specific instance of `DenseArray`;  [`Vector`](@ref) and [`Matrix`](@ref) are aliases for the 1-d and 2-d cases. Very few operations are implemented specifically for `Array` beyond those that are required for all `AbstractArray`s; much of the array library is implemented in a generic manner that allows all custom arrays to behave similarly.
"""

# ╔═╡ d4bf8e96-5d48-498c-8ab5-262550a4437c
md"""
`SubArray` is a specialization of `AbstractArray` that performs indexing by sharing memory with the original array rather than by copying it. A `SubArray` is created with the [`view`](@ref) function, which is called the same way as [`getindex`](@ref) (with an array and a series of index arguments). The result of [`view`](@ref) looks the same as the result of [`getindex`](@ref), except the data is left in place. [`view`](@ref) stores the input index vectors in a `SubArray` object, which can later be used to index the original array indirectly.  By putting the [`@views`](@ref) macro in front of an expression or block of code, any `array[...]` slice in that expression will be converted to create a `SubArray` view instead.
"""

# ╔═╡ 072ab283-bc66-49c6-be21-43325744d5e2
md"""
[`BitArray`](@ref)s are space-efficient \"packed\" boolean arrays, which store one bit per boolean value. They can be used similarly to `Array{Bool}` arrays (which store one byte per boolean value), and can be converted to/from the latter via `Array(bitarray)` and `BitArray(array)`, respectively.
"""

# ╔═╡ 6fbb10c4-c1be-4cfb-8a23-288fa22a8a6b
md"""
An array is \"strided\" if it is stored in memory with well-defined spacings (strides) between its elements. A strided array with a supported element type may be passed to an external (non-Julia) library like BLAS or LAPACK by simply passing its [`pointer`](@ref) and the stride for each dimension. The [`stride(A, d)`](@ref) is the distance between elements along dimension `d`. For example, the builtin `Array` returned by `rand(5,7,2)` has its elements arranged contiguously in column major order. This means that the stride of the first dimension — the spacing between elements in the same column — is `1`:
"""

# ╔═╡ 932f2dc8-55a5-4af5-960b-f1eed88f9711
A = rand(5,7,2);

# ╔═╡ 0fa56dac-5a37-4427-a6a8-0ae6e7bac3f6
stride(A,1)

# ╔═╡ b61569c9-a834-4530-860a-d1380921468d
md"""
The stride of the second dimension is the spacing between elements in the same row, skipping as many elements as there are in a single column (`5`). Similarly, jumping between the two \"pages\" (in the third dimension) requires skipping `5*7 == 35` elements.  The [`strides`](@ref) of this array is the tuple of these three numbers together:
"""

# ╔═╡ 6c0a2bcb-b7cf-42e2-b383-b8297c24b92e
strides(A)

# ╔═╡ 26462f29-c185-4029-95cd-c1f27a171251
md"""
In this particular case, the number of elements skipped *in memory* matches the number of *linear indices* skipped. This is only the case for contiguous arrays like `Array` (and other `DenseArray` subtypes) and is not true in general. Views with range indices are a good example of *non-contiguous* strided arrays; consider `V = @view A[1:3:4, 2:2:6, 2:-1:1]`. This view `V` refers to the same memory as `A` but is skipping and re-arranging some of its elements. The stride of the first dimension of `V` is `3` because we're only selecting every third row from our original array:
"""

# ╔═╡ 74b59836-a843-49b0-8745-a1370ccd55a6
V = @view A[1:3:4, 2:2:6, 2:-1:1];

# ╔═╡ d8c2f78c-5efc-4e26-809c-306b5b4f3a15
stride(V, 1)

# ╔═╡ b38f4c2c-22ba-48ab-9439-6cf7743ca035
md"""
This view is similarly selecting every other column from our original `A` — and thus it needs to skip the equivalent of two five-element columns when moving between indices in the second dimension:
"""

# ╔═╡ 3a863dd5-a616-4482-bb04-bf17b1013513
stride(V, 2)

# ╔═╡ db842f3e-c371-4c93-8b97-cdf975b57006
md"""
The third dimension is interesting because its order is reversed! Thus to get from the first \"page\" to the second one it must go *backwards* in memory, and so its stride in this dimension is negative!
"""

# ╔═╡ 58bfd964-ffd5-4ab7-b0be-8a02b17a5fcf
stride(V, 3)

# ╔═╡ 14e49f20-bd0f-47c2-add4-1a281c12874c
md"""
This means that the `pointer` for `V` is actually pointing into the middle of `A`'s memory block, and it refers to elements both backwards and forwards in memory. See the [interface guide for strided arrays](@ref man-interface-strided-arrays) for more details on defining your own strided arrays. [`StridedVector`](@ref) and [`StridedMatrix`](@ref) are convenient aliases for many of the builtin array types that are considered strided arrays, allowing them to dispatch to select specialized implementations that call highly tuned and optimized BLAS and LAPACK functions using just the pointer and strides.
"""

# ╔═╡ 17a3bb01-86fc-4e41-a46d-2c902091cc8c
md"""
It is worth emphasizing that strides are about offsets in memory rather than indexing. If you are looking to convert between linear (single-index) indexing and cartesian (multi-index) indexing, see [`LinearIndices`](@ref) and [`CartesianIndices`](@ref).
"""

# ╔═╡ Cell order:
# ╟─4ecd645b-87fc-4ea8-baef-b036c59a3ad7
# ╟─106d052f-9b3b-4f5f-b1ac-18c459de4dc8
# ╟─e5fc64ee-5225-4b23-8539-17eb066c85a5
# ╟─dccef62e-f8a9-4c94-8aa4-50b548586f25
# ╟─b401d76b-d207-4542-bdb8-6d9890594907
# ╟─58421ce7-b18e-4e89-bb1e-501d9b9f6273
# ╟─488b30ab-7802-43eb-8772-e6bc4af618e2
# ╟─53dd35d0-bfb0-4fd8-81f1-823036851aad
# ╟─0b055621-0a2c-4500-a9a3-7cd0fc0a3cd0
# ╟─d0d74efc-fae1-46f5-9d62-e1217e7ea7c4
# ╟─80ce151e-a948-4192-9ce0-2b1de9001110
# ╟─3d6b0432-f39d-41bc-8e25-148bf901e704
# ╠═4924e5a9-e741-45a8-a476-75d58dc70eff
# ╠═4f77fe6e-0106-4e8c-af1d-01f5d68390af
# ╠═66f17114-3bc9-4dc8-8593-7a9183344ded
# ╟─17f535be-4952-4b13-9b46-71a444780aa8
# ╟─8a6c0149-d0b2-48d5-b6e9-de46d16a8eac
# ╟─81dc1290-42bf-4cc7-a4f6-3538b8491375
# ╠═d331d9ae-87dc-4774-a5ee-1c4e49f94df4
# ╠═cbfc0994-f3f4-456c-878d-3d6f9d353c0d
# ╠═214c4313-c411-45a8-9192-79c3d7fd7cae
# ╠═4bf010b2-78ac-48fa-b4f7-4e1f5a01e46e
# ╟─3db4f742-0758-450d-8627-3d9313f3619c
# ╟─318cc6c0-7ade-49c5-b961-76946635a253
# ╠═5b1b5964-6df7-417a-9229-6195aca908d1
# ╠═56b46978-76aa-4c31-b40a-500ff9f28e94
# ╠═3ff7a6b5-0a76-4701-99b2-2954c45d931a
# ╟─179dbbf7-1d5e-4903-a2be-6011e4855a71
# ╠═9d1da54b-5d6f-4c2b-bcff-7848ed7dc5c5
# ╠═139adac1-8cf1-4755-b0ca-a6c342681951
# ╠═bc1855fe-8ada-48d5-b66f-3178c87c2a73
# ╟─bbabd66a-8619-4d06-ac3c-92ba3717242a
# ╠═9c61f57b-79ef-470b-81e0-808079ee1b28
# ╠═4f69452a-c6ac-469e-8150-7148e9cb0113
# ╟─ce212505-529c-4415-9542-59c851b0e4c8
# ╟─227edcfd-6d5e-4b1e-aa26-a831d49042f0
# ╟─df8ceab5-12a7-4e1e-8375-fd8e0b84b970
# ╟─a4fed56d-055a-4154-9572-912a790677cf
# ╟─71c0a0ba-736c-40f6-af8c-0777b1f602b3
# ╠═ca9f5f95-6171-4e4f-849c-7f284be33de1
# ╠═831c5493-280f-447d-ac46-42391b7bc836
# ╟─00034a75-cb6f-48a7-ac77-c64e43fc3b79
# ╟─70cceb0a-ef3d-4048-93a5-7b0820aa3ebb
# ╟─c63896d9-16a5-4104-bc80-5eec3d6b49b1
# ╟─13f19993-1b3c-48e5-8db5-ebb8a0cd7be9
# ╟─21547949-e034-47df-9c57-752037cd3278
# ╠═0c77a2b9-3f06-473e-af96-41046bfc9027
# ╠═f665a7d3-f9df-4a1f-97ab-86d7cee262e4
# ╟─13533cfd-9a10-4613-988f-2897609b3511
# ╟─e458f64c-6f6f-4b9a-89b7-ca7cb5684fd6
# ╟─7f56d799-63f1-4dc3-a763-f7b3b4539f00
# ╟─abe26a54-74a9-4e8b-983a-8829f40d3478
# ╠═58841c1b-a14d-433d-aa5c-57f1fdfdaa1a
# ╟─00ac906f-57ca-4916-ad80-8fa324ae2ada
# ╠═e11e9258-9e52-4bc7-872f-503717a842c3
# ╟─cf03452a-38bf-46b0-9646-37433fc85b79
# ╠═59ed9488-f857-4d81-963c-6735658825f2
# ╟─2054cbd4-6961-4fdd-9c33-2625017841a8
# ╟─8e65f8d3-2e01-4f16-944f-8e727597c009
# ╠═f4addce8-73da-4805-be72-3d38ca2ab843
# ╟─099b7b37-91a5-4221-9280-86c4079bbca3
# ╟─2a50f80e-03f7-44cd-b110-452a87a21f15
# ╠═b37e20b3-c2ef-4958-8d6a-77d667ae14c2
# ╟─ba74767e-33b0-41a7-a960-1ca17c95b6a4
# ╟─bf2cca86-8556-4bdd-a349-c7838b73a04a
# ╟─eeca6b8b-6b1a-43ba-a069-1980596a1a6b
# ╟─2a95917a-ef73-43f1-a598-166c44102616
# ╟─8db7b148-e958-45fc-a978-285dc71064f0
# ╟─05de6973-b6b8-4803-b055-ea7588533bae
# ╟─975e0843-37c4-43a1-afe8-fc9ffcc0766c
# ╠═1f7ed869-7bc2-4258-8f80-a96b2dceeff2
# ╠═1ec9d31a-64c4-4058-9c9d-d0302ee20588
# ╠═d4f9a040-381c-4efa-928d-869005556c49
# ╠═b0251cc5-8c76-4e97-a792-52212dc3a946
# ╟─e67fcb97-2228-4e7c-a6fa-73a1b21b7d9c
# ╟─92d0e29d-5052-4be0-bc0b-0026ef0050e9
# ╟─5802e226-39b5-4c3d-a1fb-3aa99ee0512f
# ╠═f77d5ac9-79f8-453c-8594-6d387895f74f
# ╠═bd86dd4b-7920-4738-b22b-969af2afe7ab
# ╠═6ed4874d-22be-4436-9db5-e12c90b58c1e
# ╟─5dfa633f-94df-4673-abd5-1eb574f137fc
# ╟─c105eda8-77ad-4db7-9690-699c356dd492
# ╟─98b279a8-771d-4802-85d8-e1e3d1ab7de1
# ╟─39bab95f-0edc-4201-9822-6d309d8bd631
# ╠═3794f845-14c9-489d-948f-a44ae76be934
# ╠═f4eae434-0aa6-41c2-9a67-bb0903cf9299
# ╠═666cc4bf-8f44-4e5c-bfef-0951b7eebd9d
# ╟─d5bf317b-2a52-4b51-afce-c80bc2e1ab13
# ╟─d23e497b-9e6a-4ab1-b8f9-9ef71ec0bced
# ╟─e7a8cb0a-a151-4155-97b3-9a4815577214
# ╟─76764ca5-2c60-4afd-989f-ad95f077efe1
# ╟─10316feb-f82f-4999-ac88-d8095f122e92
# ╟─81f3b529-1e2a-4917-93d8-c76c729ddc22
# ╟─71df007e-1618-4ac8-a3df-c375fc017649
# ╟─e24f6041-1f76-4527-8e60-57623c1cb97c
# ╟─d9c6c20e-4529-4b0d-811e-2bef197c6cd5
# ╟─1884b924-4691-4aa8-8221-320f2d25423b
# ╠═8b1478af-bde0-4033-80d9-3a2f3dc85d94
# ╠═4be93139-d942-47f9-82d4-dde69c684839
# ╠═f6390d52-5f86-4a24-b808-3ca22b7d274b
# ╠═480a459f-a278-4bdc-b378-a1d2a74f0952
# ╟─3833df37-0cea-4067-8812-b7a5d2973419
# ╟─a08a845c-cff1-4e85-8eae-75c430faf6a2
# ╟─171d2ee9-5afb-407e-a87c-86b11958ec65
# ╟─e51ada19-e238-4a47-8ef7-7e711136fb30
# ╠═5671280c-7992-4051-9260-aa592bca4009
# ╠═ddb41d1a-0151-46a6-b9a0-ba4f53730b6e
# ╠═33d40760-88b7-44f5-834c-b92fe4f0a065
# ╠═93e88157-f110-424d-9630-efe8263903e0
# ╠═ae1688bf-0923-465c-a03a-8d48566eae70
# ╠═fa53e253-b643-459e-83f1-ca6d73de5d2e
# ╠═58396e07-32f4-4097-987a-c034cea13b09
# ╠═c4da6925-92c5-4dc9-b802-3cc51c24ebb5
# ╟─2962d73b-e02a-428c-8981-0750f73fd0bc
# ╟─0986fc00-3046-4537-ba5e-ac8bb2c7f8c0
# ╠═4b3a90d6-30ac-4d01-9000-e6f4560c1765
# ╠═63a793ae-86ca-4a2a-887a-cd38a0ad905b
# ╠═918e42b7-88ac-4a43-a6c8-2216b7160423
# ╟─be49dcb9-c22b-46a3-a63e-7d2712a53080
# ╟─f229c284-1d59-4c29-b183-445ece5a368c
# ╠═ba8a9f8b-074f-43c0-8063-546f3e45f37a
# ╠═09b949b8-02ce-41fe-aace-69329dd9e0a4
# ╟─d4a5336e-2eef-4a53-9c35-435921a8f007
# ╠═9798a995-76ba-4e5d-9050-65e827623754
# ╠═e5434597-2f44-4636-8d93-4a0cc8435663
# ╟─f90d16d2-d5f8-4fc7-83f6-60fc6f795ecd
# ╟─26da36a5-04b8-4820-81b3-e729e3bdf860
# ╟─00ed481a-cf6c-47ae-b7cd-db33f4a31c98
# ╠═9f37875c-463f-440f-b7a0-c3f52cc70498
# ╠═1c4d9240-8a90-410e-afb5-e785740eb09f
# ╠═b5ef7ef2-9ae7-4c72-9aee-703078d45612
# ╠═c16cfbfa-96e0-44a9-adbc-f1789b64cb68
# ╟─d21f9244-700d-4828-8547-bb3283e34dc5
# ╟─079ea006-8f6a-4938-8e86-8fe1ae4336e4
# ╟─80a60781-f150-480b-8ee2-80e12abea3a3
# ╟─efa59260-bc89-42e7-b1da-dc5445f4327e
# ╟─6a0200b6-bd1d-4df8-aaac-baeda2e6cf0f
# ╠═621012fc-a7ef-46ac-bfc4-0b3319a4b9f4
# ╠═4b1e70be-98e6-46a3-b132-84ffe9ff95be
# ╠═2f97c058-ffc1-4cc8-a93b-6cc81121ff16
# ╟─416c878c-e2ce-49b3-b485-e2e965724fcb
# ╠═398c0eaa-f7fb-4204-8489-c2c6fcf66a23
# ╠═c37ef0c9-8697-417c-812b-ed7fa66cb5c8
# ╟─876037ed-914f-43b7-80f4-f6662afc846f
# ╟─414b5ba6-88ac-4059-9355-519bfb31b457
# ╟─06dfea23-248c-4caf-b918-50dcb6a7a008
# ╟─77e1d1a7-b7d7-4306-8ee6-ce3311b662f2
# ╠═efc5503b-a18e-42ac-b03f-7f0057d6853a
# ╠═a5e30da5-96f2-4119-9568-bd78dd1c9b41
# ╠═e79672d8-8e23-47b1-bf91-4cc9cbed1379
# ╠═9ec08e35-e7f9-40d9-be27-2ef6de0cc3a0
# ╟─5d7eba4d-663e-423e-9e38-7e421216b90f
# ╟─cb46c602-3204-420c-b36a-6e190b7ce709
# ╠═d22fc7af-421b-4c47-8e82-881d14e6e0e8
# ╠═22a03864-f2c5-4ab3-9b27-a8847dbca26b
# ╟─6625ed75-4d82-4dd6-b198-937184b69270
# ╟─04511c11-e5e6-437d-bef6-cce9dcb11ca1
# ╟─70ae4b62-581d-46a2-beca-6bdcf65fa91b
# ╟─43f2ef81-5877-4bf0-ad6e-348969e788bf
# ╠═9ae092a5-2653-48ff-83a5-cac37b1b34d5
# ╠═d4d05517-5eee-4d9b-85f6-ae790f124e92
# ╠═34929f5a-e162-4f47-b905-a6a483c6e56e
# ╟─00fb3441-74e7-49bb-b1d9-03cd64ae5cbc
# ╟─4ccdeab7-b56c-4eb5-ade6-67ef8fd77aa1
# ╟─bbf9fa3e-a81a-44f0-a733-c4326ea20b22
# ╟─7072be0a-2aa2-499d-8d91-ad4037fe0cc6
# ╟─978de581-cf16-4e6e-8fa6-3c4066963c34
# ╟─3ed102b5-4c52-46b9-9786-7e8d378d7f12
# ╟─ff652d09-8481-4605-9494-61fe63b77694
# ╟─b4d36738-0196-4245-aa02-cf3af6436dc0
# ╟─a23f43fc-68d7-45ce-aabb-61281a7479e7
# ╟─27f08f01-7953-47e8-a28f-d40a3fa5bee4
# ╟─d7101c57-06cc-45c8-8fb9-e6ef433156f8
# ╟─e20144c7-bb74-423f-a16b-9972c6820d2e
# ╟─c7cbf48b-3438-4d1a-b3ed-a9831d30c2d1
# ╟─7fee9c03-fd77-4c3d-b3f4-b84fbab3ffea
# ╠═f2efdd8b-bc96-4a0d-9092-30218ef5c08a
# ╠═5f41d6ae-649c-4ec4-8efc-35ab10e404c5
# ╟─5b12baed-278b-4e9b-a349-13ba2c1743ff
# ╠═0183c94f-3ee0-404a-9485-b6e423f239a6
# ╠═c7e7f458-8187-4e1f-9905-4769e2639c72
# ╠═9ee64687-31a9-46e7-aa98-af1b626481ae
# ╟─36aee38a-88fd-4133-a970-83ce12834c94
# ╟─cdffb2f0-22a7-4fe4-afe3-91616415a18d
# ╠═60509ecb-acf2-4449-9ca5-356eac8ba355
# ╠═d1f65443-b9a6-459d-8ee5-b0593a64cc2b
# ╠═4533a5a9-0c3e-4c4e-9826-f38a3d9b5078
# ╟─8bc1eb6c-17ec-49f5-bd72-a589223c47f9
# ╠═a86710ed-37ee-4875-8702-5ff041407079
# ╠═7c8641c4-f621-49f7-b675-a6ca77c98b94
# ╟─03f3906e-30d1-444a-813f-0f69c5f5ba59
# ╟─c231c202-4e9f-43dc-8584-a91790c381a2
# ╟─e7b07ea6-c2fa-42cb-90c3-d994522526fb
# ╟─9cb601c2-d7a0-4d84-8814-ae35cf3f5a14
# ╟─d4bf8e96-5d48-498c-8ab5-262550a4437c
# ╟─072ab283-bc66-49c6-be21-43325744d5e2
# ╟─6fbb10c4-c1be-4cfb-8a23-288fa22a8a6b
# ╠═932f2dc8-55a5-4af5-960b-f1eed88f9711
# ╠═0fa56dac-5a37-4427-a6a8-0ae6e7bac3f6
# ╟─b61569c9-a834-4530-860a-d1380921468d
# ╠═6c0a2bcb-b7cf-42e2-b383-b8297c24b92e
# ╟─26462f29-c185-4029-95cd-c1f27a171251
# ╠═74b59836-a843-49b0-8745-a1370ccd55a6
# ╠═d8c2f78c-5efc-4e26-809c-306b5b4f3a15
# ╟─b38f4c2c-22ba-48ab-9439-6cf7743ca035
# ╠═3a863dd5-a616-4482-bb04-bf17b1013513
# ╟─db842f3e-c371-4c93-8b97-cdf975b57006
# ╠═58bfd964-ffd5-4ab7-b0be-8a02b17a5fcf
# ╟─14e49f20-bd0f-47c2-add4-1a281c12874c
# ╟─17a3bb01-86fc-4e41-a46d-2c902091cc8c
