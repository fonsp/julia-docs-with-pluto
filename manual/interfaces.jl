### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ 03c9d69e-9e19-11eb-0652-ab0742f482cc
md"""
# Interfaces
"""

# ╔═╡ 03c9d6d0-9e19-11eb-216f-97e2dc5d1b6d
md"""
A lot of the power and extensibility in Julia comes from a collection of informal interfaces.  By extending a few specific methods to work for a custom type, objects of that type not only receive those functionalities, but they are also able to be used in other methods that are written to generically build upon those behaviors.
"""

# ╔═╡ 03c9d748-9e19-11eb-003e-2b2bd9a6a3d0
md"""
## [Iteration](@id man-interface-iteration)
"""

# ╔═╡ 03c9daa4-9e19-11eb-1e17-013e8781682a
md"""
| Required methods               |                        | Brief description                                                                        |
|:------------------------------ |:---------------------- |:---------------------------------------------------------------------------------------- |
| `iterate(iter)`                |                        | Returns either a tuple of the first item and initial state or [`nothing`](@ref) if empty |
| `iterate(iter, state)`         |                        | Returns either a tuple of the next item and next state or `nothing` if no items remain   |
| **Important optional methods** | **Default definition** | **Brief description**                                                                    |
| `IteratorSize(IterType)`       | `HasLength()`          | One of `HasLength()`, `HasShape{N}()`, `IsInfinite()`, or `SizeUnknown()` as appropriate |
| `IteratorEltype(IterType)`     | `HasEltype()`          | Either `EltypeUnknown()` or `HasEltype()` as appropriate                                 |
| `eltype(IterType)`             | `Any`                  | The type of the first entry of the tuple returned by `iterate()`                         |
| `length(iter)`                 | (*undefined*)          | The number of items, if known                                                            |
| `size(iter, [dim])`            | (*undefined*)          | The number of items in each dimension, if known                                          |
"""

# ╔═╡ 03c9db76-9e19-11eb-38d6-43c211741e97
md"""
| Value returned by `IteratorSize(IterType)` | Required Methods                        |
|:------------------------------------------ |:--------------------------------------- |
| `HasLength()`                              | [`length(iter)`](@ref)                  |
| `HasShape{N}()`                            | `length(iter)`  and `size(iter, [dim])` |
| `IsInfinite()`                             | (*none*)                                |
| `SizeUnknown()`                            | (*none*)                                |
"""

# ╔═╡ 03c9dbe4-9e19-11eb-2fa8-3b6eff6ea63a
md"""
| Value returned by `IteratorEltype(IterType)` | Required Methods   |
|:-------------------------------------------- |:------------------ |
| `HasEltype()`                                | `eltype(IterType)` |
| `EltypeUnknown()`                            | (*none*)           |
"""

# ╔═╡ 03c9dc0c-9e19-11eb-2c29-13e64d504629
md"""
Sequential iteration is implemented by the [`iterate`](@ref) function. Instead of mutating objects as they are iterated over, Julia iterators may keep track of the iteration state externally from the object. The return value from iterate is always either a tuple of a value and a state, or `nothing` if no elements remain. The state object will be passed back to the iterate function on the next iteration and is generally considered an implementation detail private to the iterable object.
"""

# ╔═╡ 03c9dc34-9e19-11eb-1540-adb237e1dfd6
md"""
Any object that defines this function is iterable and can be used in the [many functions that rely upon iteration](@ref lib-collections-iteration). It can also be used directly in a [`for`](@ref) loop since the syntax:
"""

# ╔═╡ 03c9dc84-9e19-11eb-2f07-fb996b08e60c
md"""
```julia
for item in iter   # or  "for item = iter"
    # body
end
```
"""

# ╔═╡ 03c9dc8c-9e19-11eb-2f7d-c93ab42397fc
md"""
is translated into:
"""

# ╔═╡ 03c9dcac-9e19-11eb-2b8d-d1687b77e68f
md"""
```julia
next = iterate(iter)
while next !== nothing
    (item, state) = next
    # body
    next = iterate(iter, state)
end
```
"""

# ╔═╡ 03c9dcbe-9e19-11eb-1f62-d9acae53fbc7
md"""
A simple example is an iterable sequence of square numbers with a defined length:
"""

# ╔═╡ 03c9e73a-9e19-11eb-18ca-8d7ab5f74809
struct Squares
           count::Int
       end

# ╔═╡ 03c9e742-9e19-11eb-113e-ab4f26fa446a
Base.iterate(S::Squares, state=1) = state > S.count ? nothing : (state*state, state+1)

# ╔═╡ 03c9e774-9e19-11eb-0488-afa40c2f6e96
md"""
With only [`iterate`](@ref) definition, the `Squares` type is already pretty powerful. We can iterate over all the elements:
"""

# ╔═╡ 03c9e9f4-9e19-11eb-33f0-293c41d69bfb
for item in Squares(7)
           println(item)
       end

# ╔═╡ 03c9ea26-9e19-11eb-2301-2fc187f548fa
md"""
We can use many of the builtin methods that work with iterables, like [`in`](@ref), or [`mean`](@ref) and [`std`](@ref) from the `Statistics` standard library module:
"""

# ╔═╡ 03c9ef62-9e19-11eb-19e6-99811c701f45
25 in Squares(10)

# ╔═╡ 03c9ef6c-9e19-11eb-17d9-258bffd7111b
using Statistics

# ╔═╡ 03c9ef78-9e19-11eb-0264-53b589abbfc9
mean(Squares(100))

# ╔═╡ 03c9ef80-9e19-11eb-2e33-b134dcf2ef0f
std(Squares(100))

# ╔═╡ 03c9efbc-9e19-11eb-2cf0-5729f812e057
md"""
There are a few more methods we can extend to give Julia more information about this iterable collection.  We know that the elements in a `Squares` sequence will always be `Int`. By extending the [`eltype`](@ref) method, we can give that information to Julia and help it make more specialized code in the more complicated methods. We also know the number of elements in our sequence, so we can extend [`length`](@ref), too:
"""

# ╔═╡ 03c9f3f4-9e19-11eb-37e7-5538caf505c2
Base.eltype(::Type{Squares}) = Int # Note that this is defined for the type

# ╔═╡ 03c9f3fe-9e19-11eb-35c0-fb5f2ccb480d
Base.length(S::Squares) = S.count

# ╔═╡ 03c9f426-9e19-11eb-2a58-1be786316f7d
md"""
Now, when we ask Julia to [`collect`](@ref) all the elements into an array it can preallocate a `Vector{Int}` of the right size instead of naively [`push!`](@ref)ing each element into a `Vector{Any}`:
"""

# ╔═╡ 03c9f598-9e19-11eb-3372-611d37949eea
collect(Squares(4))

# ╔═╡ 03c9f5aa-9e19-11eb-027f-b5e8d33f1383
md"""
While we can rely upon generic implementations, we can also extend specific methods where we know there is a simpler algorithm. For example, there's a formula to compute the sum of squares, so we can override the generic iterative version with a more performant solution:
"""

# ╔═╡ 03c9fd18-9e19-11eb-2578-c11d44d61b4b
Base.sum(S::Squares) = (n = S.count; return n*(n+1)*(2n+1)÷6)

# ╔═╡ 03c9fd18-9e19-11eb-3315-35b7103e7d2c
sum(Squares(1803))

# ╔═╡ 03c9fd2c-9e19-11eb-1948-1168bdfab53b
md"""
This is a very common pattern throughout Julia Base: a small set of required methods define an informal interface that enable many fancier behaviors. In some cases, types will want to additionally specialize those extra behaviors when they know a more efficient algorithm can be used in their specific case.
"""

# ╔═╡ 03c9ffac-9e19-11eb-298c-a147460f6979
md"""
It is also often useful to allow iteration over a collection in *reverse order* by iterating over [`Iterators.reverse(iterator)`](@ref).  To actually support reverse-order iteration, however, an iterator type `T` needs to implement `iterate` for `Iterators.Reverse{T}`. (Given `r::Iterators.Reverse{T}`, the underling iterator of type `T` is `r.itr`.) In our `Squares` example, we would implement `Iterators.Reverse{Squares}` methods:
"""

# ╔═╡ 03ca075c-9e19-11eb-0df4-e55aacdcd941
Base.iterate(rS::Iterators.Reverse{Squares}, state=rS.itr.count) = state < 1 ? nothing : (state*state, state-1)

# ╔═╡ 03ca0768-9e19-11eb-04e4-0727a189b02c
collect(Iterators.reverse(Squares(4)))

# ╔═╡ 03ca0786-9e19-11eb-3fda-47d10ab34bc5
md"""
## Indexing
"""

# ╔═╡ 03ca0858-9e19-11eb-074a-2dc18631f414
md"""
| Methods to implement | Brief description                   |
|:-------------------- |:----------------------------------- |
| `getindex(X, i)`     | `X[i]`, indexed element access      |
| `setindex!(X, v, i)` | `X[i] = v`, indexed assignment      |
| `firstindex(X)`      | The first index, used in `X[begin]` |
| `lastindex(X)`       | The last index, used in `X[end]`    |
"""

# ╔═╡ 03ca088a-9e19-11eb-14a2-87d07eada88c
md"""
For the `Squares` iterable above, we can easily compute the `i`th element of the sequence by squaring it.  We can expose this as an indexing expression `S[i]`. To opt into this behavior, `Squares` simply needs to define [`getindex`](@ref):
"""

# ╔═╡ 03ca0fa6-9e19-11eb-1fba-0383d780765f
function Base.getindex(S::Squares, i::Int)
           1 <= i <= S.count || throw(BoundsError(S, i))
           return i*i
       end

# ╔═╡ 03ca0fa6-9e19-11eb-1d85-7b3273d64271
Squares(100)[23]

# ╔═╡ 03ca0fe2-9e19-11eb-3583-c5954c1d5c77
md"""
Additionally, to support the syntax `S[begin]` and `S[end]`, we must define [`firstindex`](@ref) and [`lastindex`](@ref) to specify the first and last valid indices, respectively:
"""

# ╔═╡ 03ca14ce-9e19-11eb-3005-e15cf7234d44
Base.firstindex(S::Squares) = 1

# ╔═╡ 03ca14ce-9e19-11eb-2a10-bf23bfe71483
Base.lastindex(S::Squares) = length(S)

# ╔═╡ 03ca14d6-9e19-11eb-3f0c-5566186ca214
Squares(23)[end]

# ╔═╡ 03ca1500-9e19-11eb-38e0-65a91c0465b8
md"""
For multi-dimensional `begin`/`end` indexing as in `a[3, begin, 7]`, for example, you should define `firstindex(a, dim)` and `lastindex(a, dim)` (which default to calling `first` and `last` on `axes(a, dim)`, respectively).
"""

# ╔═╡ 03ca153a-9e19-11eb-129f-53c5efbca630
md"""
Note, though, that the above *only* defines [`getindex`](@ref) with one integer index. Indexing with anything other than an `Int` will throw a [`MethodError`](@ref) saying that there was no matching method. In order to support indexing with ranges or vectors of `Int`s, separate methods must be written:
"""

# ╔═╡ 03ca1cf8-9e19-11eb-04a7-5d5930a3eb3a
Base.getindex(S::Squares, i::Number) = S[convert(Int, i)]

# ╔═╡ 03ca1d02-9e19-11eb-0d87-77f680a2608b
Base.getindex(S::Squares, I) = [S[i] for i in I]

# ╔═╡ 03ca1d02-9e19-11eb-02c8-73cc38959017
Squares(10)[[3,4.,5]]

# ╔═╡ 03ca1d34-9e19-11eb-1f21-7307b57141a8
md"""
While this is starting to support more of the [indexing operations supported by some of the builtin types](@ref man-array-indexing), there's still quite a number of behaviors missing. This `Squares` sequence is starting to look more and more like a vector as we've added behaviors to it. Instead of defining all these behaviors ourselves, we can officially define it as a subtype of an [`AbstractArray`](@ref).
"""

# ╔═╡ 03ca1d52-9e19-11eb-1fa8-8dfecd91c026
md"""
## [Abstract Arrays](@id man-interface-array)
"""

# ╔═╡ 03ca204a-9e19-11eb-31f1-8929954fb0c5
md"""
| Methods to implement                     |                                        | Brief description                                                                   |
|:---------------------------------------- |:-------------------------------------- |:----------------------------------------------------------------------------------- |
| `size(A)`                                |                                        | Returns a tuple containing the dimensions of `A`                                    |
| `getindex(A, i::Int)`                    |                                        | (if `IndexLinear`) Linear scalar indexing                                           |
| `getindex(A, I::Vararg{Int, N})`         |                                        | (if `IndexCartesian`, where `N = ndims(A)`) N-dimensional scalar indexing           |
| `setindex!(A, v, i::Int)`                |                                        | (if `IndexLinear`) Scalar indexed assignment                                        |
| `setindex!(A, v, I::Vararg{Int, N})`     |                                        | (if `IndexCartesian`, where `N = ndims(A)`) N-dimensional scalar indexed assignment |
| **Optional methods**                     | **Default definition**                 | **Brief description**                                                               |
| `IndexStyle(::Type)`                     | `IndexCartesian()`                     | Returns either `IndexLinear()` or `IndexCartesian()`. See the description below.    |
| `getindex(A, I...)`                      | defined in terms of scalar `getindex`  | [Multidimensional and nonscalar indexing](@ref man-array-indexing)                  |
| `setindex!(A, X, I...)`                  | defined in terms of scalar `setindex!` | [Multidimensional and nonscalar indexed assignment](@ref man-array-indexing)        |
| `iterate`                                | defined in terms of scalar `getindex`  | Iteration                                                                           |
| `length(A)`                              | `prod(size(A))`                        | Number of elements                                                                  |
| `similar(A)`                             | `similar(A, eltype(A), size(A))`       | Return a mutable array with the same shape and element type                         |
| `similar(A, ::Type{S})`                  | `similar(A, S, size(A))`               | Return a mutable array with the same shape and the specified element type           |
| `similar(A, dims::Dims)`                 | `similar(A, eltype(A), dims)`          | Return a mutable array with the same element type and size *dims*                   |
| `similar(A, ::Type{S}, dims::Dims)`      | `Array{S}(undef, dims)`                | Return a mutable array with the specified element type and size                     |
| **Non-traditional indices**              | **Default definition**                 | **Brief description**                                                               |
| `axes(A)`                                | `map(OneTo, size(A))`                  | Return the a tuple of `AbstractUnitRange{<:Integer}` of valid indices               |
| `similar(A, ::Type{S}, inds)`            | `similar(A, S, Base.to_shape(inds))`   | Return a mutable array with the specified indices `inds` (see below)                |
| `similar(T::Union{Type,Function}, inds)` | `T(Base.to_shape(inds))`               | Return an array similar to `T` with the specified indices `inds` (see below)        |
"""

# ╔═╡ 03ca2072-9e19-11eb-2b53-ff01a06ffc13
md"""
If a type is defined as a subtype of `AbstractArray`, it inherits a very large set of rich behaviors including iteration and multidimensional indexing built on top of single-element access.  See the [arrays manual page](@ref man-multi-dim-arrays) and the [Julia Base section](@ref lib-arrays) for more supported methods.
"""

# ╔═╡ 03ca20a4-9e19-11eb-10a8-39937c96b7fe
md"""
A key part in defining an `AbstractArray` subtype is [`IndexStyle`](@ref). Since indexing is such an important part of an array and often occurs in hot loops, it's important to make both indexing and indexed assignment as efficient as possible.  Array data structures are typically defined in one of two ways: either it most efficiently accesses its elements using just one index (linear indexing) or it intrinsically accesses the elements with indices specified for every dimension.  These two modalities are identified by Julia as `IndexLinear()` and `IndexCartesian()`.  Converting a linear index to multiple indexing subscripts is typically very expensive, so this provides a traits-based mechanism to enable efficient generic code for all array types.
"""

# ╔═╡ 03ca20e0-9e19-11eb-2e9d-c76ea7e6e53b
md"""
This distinction determines which scalar indexing methods the type must define. `IndexLinear()` arrays are simple: just define `getindex(A::ArrayType, i::Int)`.  When the array is subsequently indexed with a multidimensional set of indices, the fallback `getindex(A::AbstractArray, I...)()` efficiently converts the indices into one linear index and then calls the above method. `IndexCartesian()` arrays, on the other hand, require methods to be defined for each supported dimensionality with `ndims(A)` `Int` indices. For example, [`SparseMatrixCSC`](@ref) from the `SparseArrays` standard library module, only supports two dimensions, so it just defines `getindex(A::SparseMatrixCSC, i::Int, j::Int)`. The same holds for [`setindex!`](@ref).
"""

# ╔═╡ 03ca20f4-9e19-11eb-10f7-d5f0732e344a
md"""
Returning to the sequence of squares from above, we could instead define it as a subtype of an `AbstractArray{Int, 1}`:
"""

# ╔═╡ 03ca2a92-9e19-11eb-2405-d78d37186ee1
struct SquaresVector <: AbstractArray{Int, 1}
           count::Int
       end

# ╔═╡ 03ca2a9a-9e19-11eb-21ab-d5c0cebc5bd0
Base.size(S::SquaresVector) = (S.count,)

# ╔═╡ 03ca2a9a-9e19-11eb-11b2-a3733dc69313
Base.IndexStyle(::Type{<:SquaresVector}) = IndexLinear()

# ╔═╡ 03ca2aa4-9e19-11eb-07c6-056518a17153
Base.getindex(S::SquaresVector, i::Int) = i*i

# ╔═╡ 03ca2ad6-9e19-11eb-0cf9-71985e508d3f
md"""
Note that it's very important to specify the two parameters of the `AbstractArray`; the first defines the [`eltype`](@ref), and the second defines the [`ndims`](@ref). That supertype and those three methods are all it takes for `SquaresVector` to be an iterable, indexable, and completely functional array:
"""

# ╔═╡ 03ca2f22-9e19-11eb-2946-3b5d5be2385b
s = SquaresVector(4)

# ╔═╡ 03ca2f2a-9e19-11eb-0c01-4b4a91bef4a1
s[s .> 8]

# ╔═╡ 03ca2f36-9e19-11eb-0e30-7501ff75701b
s + s

# ╔═╡ 03ca2f36-9e19-11eb-256f-e39ad771de6a
sin.(s)

# ╔═╡ 03ca2f5e-9e19-11eb-1397-1fad9df8445c
md"""
As a more complicated example, let's define our own toy N-dimensional sparse-like array type built on top of [`Dict`](@ref):
"""

# ╔═╡ 03ca47e4-9e19-11eb-1818-2f898817de5a
struct SparseArray{T,N} <: AbstractArray{T,N}
           data::Dict{NTuple{N,Int}, T}
           dims::NTuple{N,Int}
       end

# ╔═╡ 03ca47fa-9e19-11eb-0170-7587a45b1681
SparseArray(::Type{T}, dims::Int...) where {T} = SparseArray(T, dims);

# ╔═╡ 03ca4804-9e19-11eb-3ee1-5f1b3fb08e28
SparseArray(::Type{T}, dims::NTuple{N,Int}) where {T,N} = SparseArray{T,N}(Dict{NTuple{N,Int}, T}(), dims);

# ╔═╡ 03ca480e-9e19-11eb-05c7-41ffccb42b6b
Base.size(A::SparseArray) = A.dims

# ╔═╡ 03ca4818-9e19-11eb-3468-c1b92a8bd2ec
Base.similar(A::SparseArray, ::Type{T}, dims::Dims) where {T} = SparseArray(T, dims)

# ╔═╡ 03ca4818-9e19-11eb-3790-ab17f1bfebe4
Base.getindex(A::SparseArray{T,N}, I::Vararg{Int,N}) where {T,N} = get(A.data, I, zero(T))

# ╔═╡ 03ca4818-9e19-11eb-0974-05b532834063
Base.setindex!(A::SparseArray{T,N}, v, I::Vararg{Int,N}) where {T,N} = (A.data[I] = v)

# ╔═╡ 03ca487c-9e19-11eb-1555-5f98e3692ca1
md"""
Notice that this is an `IndexCartesian` array, so we must manually define [`getindex`](@ref) and [`setindex!`](@ref) at the dimensionality of the array. Unlike the `SquaresVector`, we are able to define [`setindex!`](@ref), and so we can mutate the array:
"""

# ╔═╡ 03ca4dcc-9e19-11eb-191c-abc058934b5e
A = SparseArray(Float64, 3, 3)

# ╔═╡ 03ca4dd6-9e19-11eb-280b-93cbd660cfcf
fill!(A, 2)

# ╔═╡ 03ca4de0-9e19-11eb-21f1-638989ba90aa
A[:] = 1:length(A); A

# ╔═╡ 03ca4e1c-9e19-11eb-341d-e10cb5c8eacd
md"""
The result of indexing an `AbstractArray` can itself be an array (for instance when indexing by an `AbstractRange`). The `AbstractArray` fallback methods use [`similar`](@ref) to allocate an `Array` of the appropriate size and element type, which is filled in using the basic indexing method described above. However, when implementing an array wrapper you often want the result to be wrapped as well:
"""

# ╔═╡ 03ca502e-9e19-11eb-1f2d-cb573bf7b7fc
A[1:2,:]

# ╔═╡ 03ca5074-9e19-11eb-245a-dd0e11f00ba8
md"""
In this example it is accomplished by defining `Base.similar{T}(A::SparseArray, ::Type{T}, dims::Dims)` to create the appropriate wrapped array. (Note that while `similar` supports 1- and 2-argument forms, in most case you only need to specialize the 3-argument form.) For this to work it's important that `SparseArray` is mutable (supports `setindex!`). Defining `similar`, `getindex` and `setindex!` for `SparseArray` also makes it possible to [`copy`](@ref) the array:
"""

# ╔═╡ 03ca5146-9e19-11eb-0eeb-53bc762d6c41
copy(A)

# ╔═╡ 03ca516e-9e19-11eb-242a-e501eb8b38de
md"""
In addition to all the iterable and indexable methods from above, these types can also interact with each other and use most of the methods defined in Julia Base for `AbstractArrays`:
"""

# ╔═╡ 03ca5380-9e19-11eb-3f0e-d1de9cf4689d
A[SquaresVector(3)]

# ╔═╡ 03ca538a-9e19-11eb-3a39-69874021597f
sum(A)

# ╔═╡ 03ca53da-9e19-11eb-303b-afed202f10e7
md"""
If you are defining an array type that allows non-traditional indexing (indices that start at something other than 1), you should specialize [`axes`](@ref). You should also specialize [`similar`](@ref) so that the `dims` argument (ordinarily a `Dims` size-tuple) can accept `AbstractUnitRange` objects, perhaps range-types `Ind` of your own design. For more information, see [Arrays with custom indices](@ref man-custom-indices).
"""

# ╔═╡ 03ca540c-9e19-11eb-125f-1fc302bf555a
md"""
## [Strided Arrays](@id man-interface-strided-arrays)
"""

# ╔═╡ 03ca5628-9e19-11eb-3698-73b0c2d85218
md"""
| Methods to implement                     |                        | Brief description                                                                                                                                                                   |
|:---------------------------------------- |:---------------------- |:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `strides(A)`                             |                        | Return the distance in memory (in number of elements) between adjacent elements in each dimension as a tuple. If `A` is an `AbstractArray{T,0}`, this should return an empty tuple. |
| `Base.unsafe_convert(::Type{Ptr{T}}, A)` |                        | Return the native address of an array.                                                                                                                                              |
| `Base.elsize(::Type{<:A})`               |                        | Return the stride between consecutive elements in the array.                                                                                                                        |
| **Optional methods**                     | **Default definition** | **Brief description**                                                                                                                                                               |
| `stride(A, i::Int)`                      | `strides(A)[i]`        | Return the distance in memory (in number of elements) between adjacent elements in dimension k.                                                                                     |
"""

# ╔═╡ 03ca5646-9e19-11eb-1267-abe280d87f09
md"""
A strided array is a subtype of `AbstractArray` whose entries are stored in memory with fixed strides. Provided the element type of the array is compatible with BLAS, a strided array can utilize BLAS and LAPACK routines for more efficient linear algebra routines.  A typical example of a user-defined strided array is one that wraps a standard `Array` with additional structure.
"""

# ╔═╡ 03ca5666-9e19-11eb-2aa4-89fe8a831ec9
md"""
Warning: do not implement these methods if the underlying storage is not actually strided, as it may lead to incorrect results or segmentation faults.
"""

# ╔═╡ 03ca5678-9e19-11eb-3077-e7ee7f91e38c
md"""
Here are some examples to demonstrate which type of arrays are strided and which are not:
"""

# ╔═╡ 03ca56f0-9e19-11eb-351d-352d89d2323f
md"""
```julia
1:5   # not strided (there is no storage associated with this array.)
Vector(1:5)  # is strided with strides (1,)
A = [1 5; 2 6; 3 7; 4 8]  # is strided with strides (1,4)
V = view(A, 1:2, :)   # is strided with strides (1,4)
V = view(A, 1:2:3, 1:2)   # is strided with strides (2,4)
V = view(A, [1,2,4], :)   # is not strided, as the spacing between rows is not fixed.
```
"""

# ╔═╡ 03ca5704-9e19-11eb-312b-3732aba99b39
md"""
## [Customizing broadcasting](@id man-interfaces-broadcasting)
"""

# ╔═╡ 03ca58a8-9e19-11eb-23eb-0f9c1e6a84a1
md"""
| Methods to implement                                       | Brief description                                                  |
|:---------------------------------------------------------- |:------------------------------------------------------------------ |
| `Base.BroadcastStyle(::Type{SrcType}) = SrcStyle()`        | Broadcasting behavior of `SrcType`                                 |
| `Base.similar(bc::Broadcasted{DestStyle}, ::Type{ElType})` | Allocation of output container                                     |
| **Optional methods**                                       |                                                                    |
| `Base.BroadcastStyle(::Style1, ::Style2) = Style12()`      | Precedence rules for mixing styles                                 |
| `Base.axes(x)`                                             | Declaration of the indices of `x`, as per [`axes(x)`](@ref).       |
| `Base.broadcastable(x)`                                    | Convert `x` to an object that has `axes` and supports indexing     |
| **Bypassing default machinery**                            |                                                                    |
| `Base.copy(bc::Broadcasted{DestStyle})`                    | Custom implementation of `broadcast`                               |
| `Base.copyto!(dest, bc::Broadcasted{DestStyle})`           | Custom implementation of `broadcast!`, specializing on `DestStyle` |
| `Base.copyto!(dest::DestType, bc::Broadcasted{Nothing})`   | Custom implementation of `broadcast!`, specializing on `DestType`  |
| `Base.Broadcast.broadcasted(f, args...)`                   | Override the default lazy behavior within a fused expression       |
| `Base.Broadcast.instantiate(bc::Broadcasted{DestStyle})`   | Override the computation of the lazy broadcast's axes              |
"""

# ╔═╡ 03ca58f8-9e19-11eb-2e97-d506b3282573
md"""
[Broadcasting](@ref) is triggered by an explicit call to `broadcast` or `broadcast!`, or implicitly by "dot" operations like `A .+ b` or `f.(x, y)`. Any object that has [`axes`](@ref) and supports indexing can participate as an argument in broadcasting, and by default the result is stored in an `Array`. This basic framework is extensible in three major ways:
"""

# ╔═╡ 03ca5a42-9e19-11eb-01cf-a915749ce719
md"""
  * Ensuring that all arguments support broadcast
  * Selecting an appropriate output array for the given set of arguments
  * Selecting an efficient implementation for the given set of arguments
"""

# ╔═╡ 03ca5ab0-9e19-11eb-30ab-f18401517534
md"""
Not all types support `axes` and indexing, but many are convenient to allow in broadcast. The [`Base.broadcastable`](@ref) function is called on each argument to broadcast, allowing it to return something different that supports `axes` and indexing. By default, this is the identity function for all `AbstractArray`s and `Number`s — they already support `axes` and indexing. For a handful of other types (including but not limited to types themselves, functions, special singletons like [`missing`](@ref) and [`nothing`](@ref), and dates), `Base.broadcastable` returns the argument wrapped in a `Ref` to act as a 0-dimensional "scalar" for the purposes of broadcasting. Custom types can similarly specialize `Base.broadcastable` to define their shape, but they should follow the convention that `collect(Base.broadcastable(x)) == collect(x)`. A notable exception is `AbstractString`; strings are special-cased to behave as scalars for the purposes of broadcast even though they are iterable collections of their characters (see [Strings](@ref) for more).
"""

# ╔═╡ 03ca5acc-9e19-11eb-3961-1bbec86cd1bb
md"""
The next two steps (selecting the output array and implementation) are dependent upon determining a single answer for a given set of arguments. Broadcast must take all the varied types of its arguments and collapse them down to just one output array and one implementation. Broadcast calls this single answer a "style." Every broadcastable object each has its own preferred style, and a promotion-like system is used to combine these styles into a single answer — the "destination style".
"""

# ╔═╡ 03ca5b1e-9e19-11eb-0eaa-a782b32290ba
md"""
### Broadcast Styles
"""

# ╔═╡ 03ca5b50-9e19-11eb-1e86-65724bfcd708
md"""
`Base.BroadcastStyle` is the abstract type from which all broadcast styles are derived. When used as a function it has two possible forms, unary (single-argument) and binary. The unary variant states that you intend to implement specific broadcasting behavior and/or output type, and do not wish to rely on the default fallback [`Broadcast.DefaultArrayStyle`](@ref).
"""

# ╔═╡ 03ca5b6e-9e19-11eb-1162-af3d738e8e93
md"""
To override these defaults, you can define a custom `BroadcastStyle` for your object:
"""

# ╔═╡ 03ca5ba2-9e19-11eb-21f0-fb22105a2590
md"""
```julia
struct MyStyle <: Broadcast.BroadcastStyle end
Base.BroadcastStyle(::Type{<:MyType}) = MyStyle()
```
"""

# ╔═╡ 03ca5bbe-9e19-11eb-0db2-dbb9494dc81a
md"""
In some cases it might be convenient not to have to define `MyStyle`, in which case you can leverage one of the general broadcast wrappers:
"""

# ╔═╡ 03ca5c54-9e19-11eb-067c-a95ea0baa17c
md"""
  * `Base.BroadcastStyle(::Type{<:MyType}) = Broadcast.Style{MyType}()` can be used for arbitrary types.
  * `Base.BroadcastStyle(::Type{<:MyType}) = Broadcast.ArrayStyle{MyType}()` is preferred if `MyType` is an `AbstractArray`.
  * For `AbstractArrays` that only support a certain dimensionality, create a subtype of `Broadcast.AbstractArrayStyle{N}` (see below).
"""

# ╔═╡ 03ca5c72-9e19-11eb-3283-ef38314d6924
md"""
When your broadcast operation involves several arguments, individual argument styles get combined to determine a single `DestStyle` that controls the type of the output container. For more details, see [below](@ref writing-binary-broadcasting-rules).
"""

# ╔═╡ 03ca5c86-9e19-11eb-05d9-6f1df9581b2d
md"""
### Selecting an appropriate output array
"""

# ╔═╡ 03ca5ca4-9e19-11eb-1b40-f501086b92ca
md"""
The broadcast style is computed for every broadcasting operation to allow for dispatch and specialization. The actual allocation of the result array is handled by `similar`, using the Broadcasted object as its first argument.
"""

# ╔═╡ 03ca5cb8-9e19-11eb-16f7-93010b46f251
md"""
```julia
Base.similar(bc::Broadcasted{DestStyle}, ::Type{ElType})
```
"""

# ╔═╡ 03ca5ccc-9e19-11eb-1d7f-852d17de21ae
md"""
The fallback definition is
"""

# ╔═╡ 03ca5ce0-9e19-11eb-1d97-850d2031bd43
md"""
```julia
similar(bc::Broadcasted{DefaultArrayStyle{N}}, ::Type{ElType}) where {N,ElType} =
    similar(Array{ElType}, axes(bc))
```
"""

# ╔═╡ 03ca5d0a-9e19-11eb-2269-c3af6d93f97b
md"""
However, if needed you can specialize on any or all of these arguments. The final argument `bc` is a lazy representation of a (potentially fused) broadcast operation, a `Broadcasted` object.  For these purposes, the most important fields of the wrapper are `f` and `args`, describing the function and argument list, respectively.  Note that the argument list can — and often does — include other nested `Broadcasted` wrappers.
"""

# ╔═╡ 03ca5d1c-9e19-11eb-13f5-09829395a485
md"""
For a complete example, let's say you have created a type, `ArrayAndChar`, that stores an array and a single character:
"""

# ╔═╡ 03ca61a2-9e19-11eb-26f0-55381be564d0
struct ArrayAndChar{T,N} <: AbstractArray{T,N}
    data::Array{T,N}
    char::Char
end

# ╔═╡ 03ca61cc-9e19-11eb-3230-4d532da13a1c
md"""
You might want broadcasting to preserve the `char` "metadata." First we define
"""

# ╔═╡ 03ca64ec-9e19-11eb-3314-ef39a6dcc841
Base.BroadcastStyle(::Type{<:ArrayAndChar}) = Broadcast.ArrayStyle{ArrayAndChar}()

# ╔═╡ 03ca650a-9e19-11eb-2108-2d0f13872db3
md"""
This means we must also define a corresponding `similar` method:
"""

# ╔═╡ 03ca6cbc-9e19-11eb-0983-87c48e23d34a
function Base.similar(bc::Broadcast.Broadcasted{Broadcast.ArrayStyle{ArrayAndChar}}, ::Type{ElType}) where ElType
    # Scan the inputs for the ArrayAndChar:
    A = find_aac(bc)
    # Use the char field of A to create the output
    ArrayAndChar(similar(Array{ElType}, axes(bc)), A.char)
end

# ╔═╡ 03ca6cda-9e19-11eb-03cf-33a6bc9b7be3
md"""
From these definitions, one obtains the following behavior:
"""

# ╔═╡ 03ca734c-9e19-11eb-14bb-ed53206d134e
a = ArrayAndChar([1 2; 3 4], 'x')

# ╔═╡ 03ca7358-9e19-11eb-32d4-07cda2c25a93
a .+ 1

# ╔═╡ 03ca7358-9e19-11eb-172a-495682e3c9a2
a .+ [5,10]

# ╔═╡ 03ca73a6-9e19-11eb-30d4-a96987e8c8a7
md"""
### [Extending broadcast with custom implementations](@id extending-in-place-broadcast)
"""

# ╔═╡ 03ca7400-9e19-11eb-260f-bf335bdcbf8b
md"""
In general, a broadcast operation is represented by a lazy `Broadcasted` container that holds onto the function to be applied alongside its arguments. Those arguments may themselves be more nested `Broadcasted` containers, forming a large expression tree to be evaluated. A nested tree of `Broadcasted` containers is directly constructed by the implicit dot syntax; `5 .+ 2.*x` is transiently represented by `Broadcasted(+, 5, Broadcasted(*, 2, x))`, for example. This is invisible to users as it is immediately realized through a call to `copy`, but it is this container that provides the basis for broadcast's extensibility for authors of custom types. The built-in broadcast machinery will then determine the result type and size based upon the arguments, allocate it, and then finally copy the realization of the `Broadcasted` object into it with a default `copyto!(::AbstractArray, ::Broadcasted)` method. The built-in fallback `broadcast` and `broadcast!` methods similarly construct a transient `Broadcasted` representation of the operation so they can follow the same codepath. This allows custom array implementations to provide their own `copyto!` specialization to customize and optimize broadcasting. This is again determined by the computed broadcast style. This is such an important part of the operation that it is stored as the first type parameter of the `Broadcasted` type, allowing for dispatch and specialization.
"""

# ╔═╡ 03ca743c-9e19-11eb-0b3b-7df452b7bbb7
md"""
For some types, the machinery to "fuse" operations across nested levels of broadcasting is not available or could be done more efficiently incrementally. In such cases, you may need or want to evaluate `x .* (x .+ 1)` as if it had been written `broadcast(*, x, broadcast(+, x, 1))`, where the inner operation is evaluated before tackling the outer operation. This sort of eager operation is directly supported by a bit of indirection; instead of directly constructing `Broadcasted` objects, Julia lowers the fused expression `x .* (x .+ 1)` to `Broadcast.broadcasted(*, x, Broadcast.broadcasted(+, x, 1))`. Now, by default, `broadcasted` just calls the `Broadcasted` constructor to create the lazy representation of the fused expression tree, but you can choose to override it for a particular combination of function and arguments.
"""

# ╔═╡ 03ca746e-9e19-11eb-1870-2bcddc5d3841
md"""
As an example, the builtin `AbstractRange` objects use this machinery to optimize pieces of broadcasted expressions that can be eagerly evaluated purely in terms of the start, step, and length (or stop) instead of computing every single element. Just like all the other machinery, `broadcasted` also computes and exposes the combined broadcast style of its arguments, so instead of specializing on `broadcasted(f, args...)`, you can specialize on `broadcasted(::DestStyle, f, args...)` for any combination of style, function, and arguments.
"""

# ╔═╡ 03ca7482-9e19-11eb-0a1e-eddfc9750922
md"""
For example, the following definition supports the negation of ranges:
"""

# ╔═╡ 03ca74a0-9e19-11eb-23b1-3191e6f37063
md"""
```julia
broadcasted(::DefaultArrayStyle{1}, ::typeof(-), r::OrdinalRange) = range(-first(r), step=-step(r), length=length(r))
```
"""

# ╔═╡ 03ca74c0-9e19-11eb-032c-9f986ddf3ea7
md"""
### [Extending in-place broadcasting](@id extending-in-place-broadcast)
"""

# ╔═╡ 03ca74dc-9e19-11eb-3b95-cfc10b19b08a
md"""
In-place broadcasting can be supported by defining the appropriate `copyto!(dest, bc::Broadcasted)` method. Because you might want to specialize either on `dest` or the specific subtype of `bc`, to avoid ambiguities between packages we recommend the following convention.
"""

# ╔═╡ 03ca74ee-9e19-11eb-3c75-c94929261205
md"""
If you wish to specialize on a particular style `DestStyle`, define a method for
"""

# ╔═╡ 03ca7504-9e19-11eb-1d96-174a8855ba8a
md"""
```julia
copyto!(dest, bc::Broadcasted{DestStyle})
```
"""

# ╔═╡ 03ca7518-9e19-11eb-2b08-5b0a83f5ee36
md"""
Optionally, with this form you can also specialize on the type of `dest`.
"""

# ╔═╡ 03ca752c-9e19-11eb-3bfe-3bae6edad1cf
md"""
If instead you want to specialize on the destination type `DestType` without specializing on `DestStyle`, then you should define a method with the following signature:
"""

# ╔═╡ 03ca7540-9e19-11eb-1cb4-abd4d55dc296
md"""
```julia
copyto!(dest::DestType, bc::Broadcasted{Nothing})
```
"""

# ╔═╡ 03ca755e-9e19-11eb-38a6-7fce6e95c3ed
md"""
This leverages a fallback implementation of `copyto!` that converts the wrapper into a `Broadcasted{Nothing}`. Consequently, specializing on `DestType` has lower precedence than methods that specialize on `DestStyle`.
"""

# ╔═╡ 03ca757c-9e19-11eb-1c15-e1e4dcf7a484
md"""
Similarly, you can completely override out-of-place broadcasting with a `copy(::Broadcasted)` method.
"""

# ╔═╡ 03ca75cc-9e19-11eb-2e31-c5af8cf42c3f
md"""
#### Working with `Broadcasted` objects
"""

# ╔═╡ 03ca75f6-9e19-11eb-14df-118f54997103
md"""
In order to implement such a `copy` or `copyto!`, method, of course, you must work with the `Broadcasted` wrapper to compute each element. There are two main ways of doing so:
"""

# ╔═╡ 03ca76c6-9e19-11eb-2da5-c1fbf51869f5
md"""
  * `Broadcast.flatten` recomputes the potentially nested operation into a single function and flat list of arguments. You are responsible for implementing the broadcasting shape rules yourself, but this may be helpful in limited situations.
  * Iterating over the `CartesianIndices` of the `axes(::Broadcasted)` and using indexing with the resulting `CartesianIndex` object to compute the result.
"""

# ╔═╡ 03ca76e4-9e19-11eb-2d3e-8bc1bea2b0d9
md"""
### [Writing binary broadcasting rules](@id writing-binary-broadcasting-rules)
"""

# ╔═╡ 03ca76fa-9e19-11eb-029d-5154c59b554f
md"""
The precedence rules are defined by binary `BroadcastStyle` calls:
"""

# ╔═╡ 03ca7716-9e19-11eb-3b33-ff0c8a9f9019
md"""
```julia
Base.BroadcastStyle(::Style1, ::Style2) = Style12()
```
"""

# ╔═╡ 03ca7734-9e19-11eb-25d1-43788727e7fc
md"""
where `Style12` is the `BroadcastStyle` you want to choose for outputs involving arguments of `Style1` and `Style2`. For example,
"""

# ╔═╡ 03ca7748-9e19-11eb-343c-0df66e7af5a9
md"""
```julia
Base.BroadcastStyle(::Broadcast.Style{Tuple}, ::Broadcast.AbstractArrayStyle{0}) = Broadcast.Style{Tuple}()
```
"""

# ╔═╡ 03ca7766-9e19-11eb-2a11-c574278856a8
md"""
indicates that `Tuple` "wins" over zero-dimensional arrays (the output container will be a tuple). It is worth noting that you do not need to (and should not) define both argument orders of this call; defining one is sufficient no matter what order the user supplies the arguments in.
"""

# ╔═╡ 03ca7798-9e19-11eb-3d63-cd058418baa2
md"""
For `AbstractArray` types, defining a `BroadcastStyle` supersedes the fallback choice, [`Broadcast.DefaultArrayStyle`](@ref). `DefaultArrayStyle` and the abstract supertype, `AbstractArrayStyle`, store the dimensionality as a type parameter to support specialized array types that have fixed dimensionality requirements.
"""

# ╔═╡ 03ca77ac-9e19-11eb-2d25-650e8b7c695e
md"""
`DefaultArrayStyle` "loses" to any other `AbstractArrayStyle` that has been defined because of the following methods:
"""

# ╔═╡ 03ca77ca-9e19-11eb-0373-a31b4646e338
md"""
```julia
BroadcastStyle(a::AbstractArrayStyle{Any}, ::DefaultArrayStyle) = a
BroadcastStyle(a::AbstractArrayStyle{N}, ::DefaultArrayStyle{N}) where N = a
BroadcastStyle(a::AbstractArrayStyle{M}, ::DefaultArrayStyle{N}) where {M,N} =
    typeof(a)(_max(Val(M),Val(N)))
```
"""

# ╔═╡ 03ca77de-9e19-11eb-2644-01b19bb14e22
md"""
You do not need to write binary `BroadcastStyle` rules unless you want to establish precedence for two or more non-`DefaultArrayStyle` types.
"""

# ╔═╡ 03ca77fc-9e19-11eb-378b-7dfc40e0efed
md"""
If your array type does have fixed dimensionality requirements, then you should subtype `AbstractArrayStyle`. For example, the sparse array code has the following definitions:
"""

# ╔═╡ 03ca7810-9e19-11eb-1071-29a83e1581bb
md"""
```julia
struct SparseVecStyle <: Broadcast.AbstractArrayStyle{1} end
struct SparseMatStyle <: Broadcast.AbstractArrayStyle{2} end
Base.BroadcastStyle(::Type{<:SparseVector}) = SparseVecStyle()
Base.BroadcastStyle(::Type{<:SparseMatrixCSC}) = SparseMatStyle()
```
"""

# ╔═╡ 03ca782e-9e19-11eb-2843-215c2ca42022
md"""
Whenever you subtype `AbstractArrayStyle`, you also need to define rules for combining dimensionalities, by creating a constructor for your style that takes a `Val(N)` argument. For example:
"""

# ╔═╡ 03ca7842-9e19-11eb-0ff9-75bbd1ebe1c2
md"""
```julia
SparseVecStyle(::Val{0}) = SparseVecStyle()
SparseVecStyle(::Val{1}) = SparseVecStyle()
SparseVecStyle(::Val{2}) = SparseMatStyle()
SparseVecStyle(::Val{N}) where N = Broadcast.DefaultArrayStyle{N}()
```
"""

# ╔═╡ 03ca786a-9e19-11eb-28f1-891324c8c332
md"""
These rules indicate that the combination of a `SparseVecStyle` with 0- or 1-dimensional arrays yields another `SparseVecStyle`, that its combination with a 2-dimensional array yields a `SparseMatStyle`, and anything of higher dimensionality falls back to the dense arbitrary-dimensional framework. These rules allow broadcasting to keep the sparse representation for operations that result in one or two dimensional outputs, but produce an `Array` for any other dimensionality.
"""

# ╔═╡ Cell order:
# ╟─03c9d69e-9e19-11eb-0652-ab0742f482cc
# ╟─03c9d6d0-9e19-11eb-216f-97e2dc5d1b6d
# ╟─03c9d748-9e19-11eb-003e-2b2bd9a6a3d0
# ╟─03c9daa4-9e19-11eb-1e17-013e8781682a
# ╟─03c9db76-9e19-11eb-38d6-43c211741e97
# ╟─03c9dbe4-9e19-11eb-2fa8-3b6eff6ea63a
# ╟─03c9dc0c-9e19-11eb-2c29-13e64d504629
# ╟─03c9dc34-9e19-11eb-1540-adb237e1dfd6
# ╟─03c9dc84-9e19-11eb-2f07-fb996b08e60c
# ╟─03c9dc8c-9e19-11eb-2f7d-c93ab42397fc
# ╟─03c9dcac-9e19-11eb-2b8d-d1687b77e68f
# ╟─03c9dcbe-9e19-11eb-1f62-d9acae53fbc7
# ╠═03c9e73a-9e19-11eb-18ca-8d7ab5f74809
# ╠═03c9e742-9e19-11eb-113e-ab4f26fa446a
# ╟─03c9e774-9e19-11eb-0488-afa40c2f6e96
# ╠═03c9e9f4-9e19-11eb-33f0-293c41d69bfb
# ╟─03c9ea26-9e19-11eb-2301-2fc187f548fa
# ╠═03c9ef62-9e19-11eb-19e6-99811c701f45
# ╠═03c9ef6c-9e19-11eb-17d9-258bffd7111b
# ╠═03c9ef78-9e19-11eb-0264-53b589abbfc9
# ╠═03c9ef80-9e19-11eb-2e33-b134dcf2ef0f
# ╟─03c9efbc-9e19-11eb-2cf0-5729f812e057
# ╠═03c9f3f4-9e19-11eb-37e7-5538caf505c2
# ╠═03c9f3fe-9e19-11eb-35c0-fb5f2ccb480d
# ╟─03c9f426-9e19-11eb-2a58-1be786316f7d
# ╠═03c9f598-9e19-11eb-3372-611d37949eea
# ╟─03c9f5aa-9e19-11eb-027f-b5e8d33f1383
# ╠═03c9fd18-9e19-11eb-2578-c11d44d61b4b
# ╠═03c9fd18-9e19-11eb-3315-35b7103e7d2c
# ╟─03c9fd2c-9e19-11eb-1948-1168bdfab53b
# ╟─03c9ffac-9e19-11eb-298c-a147460f6979
# ╠═03ca075c-9e19-11eb-0df4-e55aacdcd941
# ╠═03ca0768-9e19-11eb-04e4-0727a189b02c
# ╟─03ca0786-9e19-11eb-3fda-47d10ab34bc5
# ╟─03ca0858-9e19-11eb-074a-2dc18631f414
# ╟─03ca088a-9e19-11eb-14a2-87d07eada88c
# ╠═03ca0fa6-9e19-11eb-1fba-0383d780765f
# ╠═03ca0fa6-9e19-11eb-1d85-7b3273d64271
# ╟─03ca0fe2-9e19-11eb-3583-c5954c1d5c77
# ╠═03ca14ce-9e19-11eb-3005-e15cf7234d44
# ╠═03ca14ce-9e19-11eb-2a10-bf23bfe71483
# ╠═03ca14d6-9e19-11eb-3f0c-5566186ca214
# ╟─03ca1500-9e19-11eb-38e0-65a91c0465b8
# ╟─03ca153a-9e19-11eb-129f-53c5efbca630
# ╠═03ca1cf8-9e19-11eb-04a7-5d5930a3eb3a
# ╠═03ca1d02-9e19-11eb-0d87-77f680a2608b
# ╠═03ca1d02-9e19-11eb-02c8-73cc38959017
# ╟─03ca1d34-9e19-11eb-1f21-7307b57141a8
# ╟─03ca1d52-9e19-11eb-1fa8-8dfecd91c026
# ╟─03ca204a-9e19-11eb-31f1-8929954fb0c5
# ╟─03ca2072-9e19-11eb-2b53-ff01a06ffc13
# ╟─03ca20a4-9e19-11eb-10a8-39937c96b7fe
# ╟─03ca20e0-9e19-11eb-2e9d-c76ea7e6e53b
# ╟─03ca20f4-9e19-11eb-10f7-d5f0732e344a
# ╠═03ca2a92-9e19-11eb-2405-d78d37186ee1
# ╠═03ca2a9a-9e19-11eb-21ab-d5c0cebc5bd0
# ╠═03ca2a9a-9e19-11eb-11b2-a3733dc69313
# ╠═03ca2aa4-9e19-11eb-07c6-056518a17153
# ╟─03ca2ad6-9e19-11eb-0cf9-71985e508d3f
# ╠═03ca2f22-9e19-11eb-2946-3b5d5be2385b
# ╠═03ca2f2a-9e19-11eb-0c01-4b4a91bef4a1
# ╠═03ca2f36-9e19-11eb-0e30-7501ff75701b
# ╠═03ca2f36-9e19-11eb-256f-e39ad771de6a
# ╟─03ca2f5e-9e19-11eb-1397-1fad9df8445c
# ╠═03ca47e4-9e19-11eb-1818-2f898817de5a
# ╠═03ca47fa-9e19-11eb-0170-7587a45b1681
# ╠═03ca4804-9e19-11eb-3ee1-5f1b3fb08e28
# ╠═03ca480e-9e19-11eb-05c7-41ffccb42b6b
# ╠═03ca4818-9e19-11eb-3468-c1b92a8bd2ec
# ╠═03ca4818-9e19-11eb-3790-ab17f1bfebe4
# ╠═03ca4818-9e19-11eb-0974-05b532834063
# ╟─03ca487c-9e19-11eb-1555-5f98e3692ca1
# ╠═03ca4dcc-9e19-11eb-191c-abc058934b5e
# ╠═03ca4dd6-9e19-11eb-280b-93cbd660cfcf
# ╠═03ca4de0-9e19-11eb-21f1-638989ba90aa
# ╟─03ca4e1c-9e19-11eb-341d-e10cb5c8eacd
# ╠═03ca502e-9e19-11eb-1f2d-cb573bf7b7fc
# ╟─03ca5074-9e19-11eb-245a-dd0e11f00ba8
# ╠═03ca5146-9e19-11eb-0eeb-53bc762d6c41
# ╟─03ca516e-9e19-11eb-242a-e501eb8b38de
# ╠═03ca5380-9e19-11eb-3f0e-d1de9cf4689d
# ╠═03ca538a-9e19-11eb-3a39-69874021597f
# ╟─03ca53da-9e19-11eb-303b-afed202f10e7
# ╟─03ca540c-9e19-11eb-125f-1fc302bf555a
# ╟─03ca5628-9e19-11eb-3698-73b0c2d85218
# ╟─03ca5646-9e19-11eb-1267-abe280d87f09
# ╟─03ca5666-9e19-11eb-2aa4-89fe8a831ec9
# ╟─03ca5678-9e19-11eb-3077-e7ee7f91e38c
# ╟─03ca56f0-9e19-11eb-351d-352d89d2323f
# ╟─03ca5704-9e19-11eb-312b-3732aba99b39
# ╟─03ca58a8-9e19-11eb-23eb-0f9c1e6a84a1
# ╟─03ca58f8-9e19-11eb-2e97-d506b3282573
# ╟─03ca5a42-9e19-11eb-01cf-a915749ce719
# ╟─03ca5ab0-9e19-11eb-30ab-f18401517534
# ╟─03ca5acc-9e19-11eb-3961-1bbec86cd1bb
# ╟─03ca5b1e-9e19-11eb-0eaa-a782b32290ba
# ╟─03ca5b50-9e19-11eb-1e86-65724bfcd708
# ╟─03ca5b6e-9e19-11eb-1162-af3d738e8e93
# ╟─03ca5ba2-9e19-11eb-21f0-fb22105a2590
# ╟─03ca5bbe-9e19-11eb-0db2-dbb9494dc81a
# ╟─03ca5c54-9e19-11eb-067c-a95ea0baa17c
# ╟─03ca5c72-9e19-11eb-3283-ef38314d6924
# ╟─03ca5c86-9e19-11eb-05d9-6f1df9581b2d
# ╟─03ca5ca4-9e19-11eb-1b40-f501086b92ca
# ╟─03ca5cb8-9e19-11eb-16f7-93010b46f251
# ╟─03ca5ccc-9e19-11eb-1d7f-852d17de21ae
# ╟─03ca5ce0-9e19-11eb-1d97-850d2031bd43
# ╟─03ca5d0a-9e19-11eb-2269-c3af6d93f97b
# ╟─03ca5d1c-9e19-11eb-13f5-09829395a485
# ╠═03ca61a2-9e19-11eb-26f0-55381be564d0
# ╟─03ca61cc-9e19-11eb-3230-4d532da13a1c
# ╠═03ca64ec-9e19-11eb-3314-ef39a6dcc841
# ╟─03ca650a-9e19-11eb-2108-2d0f13872db3
# ╠═03ca6cbc-9e19-11eb-0983-87c48e23d34a
# ╟─03ca6cda-9e19-11eb-03cf-33a6bc9b7be3
# ╠═03ca734c-9e19-11eb-14bb-ed53206d134e
# ╠═03ca7358-9e19-11eb-32d4-07cda2c25a93
# ╠═03ca7358-9e19-11eb-172a-495682e3c9a2
# ╟─03ca73a6-9e19-11eb-30d4-a96987e8c8a7
# ╟─03ca7400-9e19-11eb-260f-bf335bdcbf8b
# ╟─03ca743c-9e19-11eb-0b3b-7df452b7bbb7
# ╟─03ca746e-9e19-11eb-1870-2bcddc5d3841
# ╟─03ca7482-9e19-11eb-0a1e-eddfc9750922
# ╟─03ca74a0-9e19-11eb-23b1-3191e6f37063
# ╟─03ca74c0-9e19-11eb-032c-9f986ddf3ea7
# ╟─03ca74dc-9e19-11eb-3b95-cfc10b19b08a
# ╟─03ca74ee-9e19-11eb-3c75-c94929261205
# ╟─03ca7504-9e19-11eb-1d96-174a8855ba8a
# ╟─03ca7518-9e19-11eb-2b08-5b0a83f5ee36
# ╟─03ca752c-9e19-11eb-3bfe-3bae6edad1cf
# ╟─03ca7540-9e19-11eb-1cb4-abd4d55dc296
# ╟─03ca755e-9e19-11eb-38a6-7fce6e95c3ed
# ╟─03ca757c-9e19-11eb-1c15-e1e4dcf7a484
# ╟─03ca75cc-9e19-11eb-2e31-c5af8cf42c3f
# ╟─03ca75f6-9e19-11eb-14df-118f54997103
# ╟─03ca76c6-9e19-11eb-2da5-c1fbf51869f5
# ╟─03ca76e4-9e19-11eb-2d3e-8bc1bea2b0d9
# ╟─03ca76fa-9e19-11eb-029d-5154c59b554f
# ╟─03ca7716-9e19-11eb-3b33-ff0c8a9f9019
# ╟─03ca7734-9e19-11eb-25d1-43788727e7fc
# ╟─03ca7748-9e19-11eb-343c-0df66e7af5a9
# ╟─03ca7766-9e19-11eb-2a11-c574278856a8
# ╟─03ca7798-9e19-11eb-3d63-cd058418baa2
# ╟─03ca77ac-9e19-11eb-2d25-650e8b7c695e
# ╟─03ca77ca-9e19-11eb-0373-a31b4646e338
# ╟─03ca77de-9e19-11eb-2644-01b19bb14e22
# ╟─03ca77fc-9e19-11eb-378b-7dfc40e0efed
# ╟─03ca7810-9e19-11eb-1071-29a83e1581bb
# ╟─03ca782e-9e19-11eb-2843-215c2ca42022
# ╟─03ca7842-9e19-11eb-0ff9-75bbd1ebe1c2
# ╟─03ca786a-9e19-11eb-28f1-891324c8c332
