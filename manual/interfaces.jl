### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ 3d5e1ea7-0410-46e5-8a2a-1f29b592248b
md"""
# Interfaces
"""

# ╔═╡ aaf8e89e-633f-4059-a6b7-94848e06b02d
md"""
A lot of the power and extensibility in Julia comes from a collection of informal interfaces.  By extending a few specific methods to work for a custom type, objects of that type not only receive those functionalities, but they are also able to be used in other methods that are written to generically build upon those behaviors.
"""

# ╔═╡ f3f6b921-f62c-4305-8fe3-6fddc5f0661b
md"""
## [Iteration](@id man-interface-iteration)
"""

# ╔═╡ 1e0c4ba3-ee66-4468-9df7-a8116366f2ed
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

# ╔═╡ c0391c84-97f8-4e4e-afd9-bf859d695c16
md"""
| Value returned by `IteratorSize(IterType)` | Required Methods                        |
|:------------------------------------------ |:--------------------------------------- |
| `HasLength()`                              | [`length(iter)`](@ref)                  |
| `HasShape{N}()`                            | `length(iter)`  and `size(iter, [dim])` |
| `IsInfinite()`                             | (*none*)                                |
| `SizeUnknown()`                            | (*none*)                                |
"""

# ╔═╡ 8367a575-4571-4842-83b6-4d980e044969
md"""
| Value returned by `IteratorEltype(IterType)` | Required Methods   |
|:-------------------------------------------- |:------------------ |
| `HasEltype()`                                | `eltype(IterType)` |
| `EltypeUnknown()`                            | (*none*)           |
"""

# ╔═╡ c7898056-9c8b-484d-b0cc-dc2f064c6b13
md"""
Sequential iteration is implemented by the [`iterate`](@ref) function. Instead of mutating objects as they are iterated over, Julia iterators may keep track of the iteration state externally from the object. The return value from iterate is always either a tuple of a value and a state, or `nothing` if no elements remain. The state object will be passed back to the iterate function on the next iteration and is generally considered an implementation detail private to the iterable object.
"""

# ╔═╡ a4725f8e-7f03-4c80-a6b1-6187d14db3dc
md"""
Any object that defines this function is iterable and can be used in the [many functions that rely upon iteration](@ref lib-collections-iteration). It can also be used directly in a [`for`](@ref) loop since the syntax:
"""

# ╔═╡ 1468bbaf-6f29-47b7-aa27-0a6d9ca42c56
md"""
```julia
for item in iter   # or  \"for item = iter\"
    # body
end
```
"""

# ╔═╡ 52526967-b8b8-4bf4-b8ca-e1413fb53e29
md"""
is translated into:
"""

# ╔═╡ c7941e0c-dffc-4fa9-9ed5-390f4a7fa7d7
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

# ╔═╡ 83d9e1e1-ab06-4a30-a8a0-61fe4c483d67
md"""
A simple example is an iterable sequence of square numbers with a defined length:
"""

# ╔═╡ 2b17d5bd-66dc-4f5e-9b98-943bddb20376
struct Squares
     count::Int
 end

# ╔═╡ 8e0ea772-cf25-4ba8-b68a-23a93e16ccd1
Base.iterate(S::Squares, state=1) = state > S.count ? nothing : (state*state, state+1)

# ╔═╡ 5c1933bd-e387-4401-a6aa-bc777eabed44
md"""
With only [`iterate`](@ref) definition, the `Squares` type is already pretty powerful. We can iterate over all the elements:
"""

# ╔═╡ 6cd0d300-c522-4a04-b326-ff8073930987
for item in Squares(7)
     println(item)
 end

# ╔═╡ d2baef86-8ae1-4de2-bcb5-32c7e43e5ab3
md"""
We can use many of the builtin methods that work with iterables, like [`in`](@ref), or [`mean`](@ref) and [`std`](@ref) from the `Statistics` standard library module:
"""

# ╔═╡ 2214ff06-2860-436b-af18-396b607f26ad
25 in Squares(10)

# ╔═╡ 11efe1b4-33eb-481b-af4a-ddc171c722b6
using Statistics

# ╔═╡ 76bb2c44-21d6-497b-a1fd-a6cecf417cc7
mean(Squares(100))

# ╔═╡ eba99879-0377-481a-87c2-b412594744d8
std(Squares(100))

# ╔═╡ 2f820f91-ef02-4f81-b636-24e701ac2af5
md"""
There are a few more methods we can extend to give Julia more information about this iterable collection.  We know that the elements in a `Squares` sequence will always be `Int`. By extending the [`eltype`](@ref) method, we can give that information to Julia and help it make more specialized code in the more complicated methods. We also know the number of elements in our sequence, so we can extend [`length`](@ref), too:
"""

# ╔═╡ 40f8678f-585e-42f6-acfd-59d1300cf688
Base.eltype(::Type{Squares}) = Int # Note that this is defined for the type

# ╔═╡ 7c519bcf-1144-430c-802c-a6e756583b0a
Base.length(S::Squares) = S.count

# ╔═╡ 0f2b7d51-0a12-413f-9226-6701a3f33430
md"""
Now, when we ask Julia to [`collect`](@ref) all the elements into an array it can preallocate a `Vector{Int}` of the right size instead of naively [`push!`](@ref)ing each element into a `Vector{Any}`:
"""

# ╔═╡ 43ae0220-d98a-44b9-8862-5f7275ab73b2
collect(Squares(4))

# ╔═╡ 57ba9bd4-7457-42be-9bfd-eba77f51fdee
md"""
While we can rely upon generic implementations, we can also extend specific methods where we know there is a simpler algorithm. For example, there's a formula to compute the sum of squares, so we can override the generic iterative version with a more performant solution:
"""

# ╔═╡ cfe5fa48-64cb-4cb7-95b3-69f072e83292
Base.sum(S::Squares) = (n = S.count; return n*(n+1)*(2n+1)÷6)

# ╔═╡ 11b62fbc-e914-48c6-beb8-51fb7af4b4b6
sum(Squares(1803))

# ╔═╡ ebcca04d-9b39-49a2-8e57-5c556bf08b6a
md"""
This is a very common pattern throughout Julia Base: a small set of required methods define an informal interface that enable many fancier behaviors. In some cases, types will want to additionally specialize those extra behaviors when they know a more efficient algorithm can be used in their specific case.
"""

# ╔═╡ 3e318161-6d3d-4b0c-926c-2441749ce994
md"""
It is also often useful to allow iteration over a collection in *reverse order* by iterating over [`Iterators.reverse(iterator)`](@ref).  To actually support reverse-order iteration, however, an iterator type `T` needs to implement `iterate` for `Iterators.Reverse{T}`. (Given `r::Iterators.Reverse{T}`, the underling iterator of type `T` is `r.itr`.) In our `Squares` example, we would implement `Iterators.Reverse{Squares}` methods:
"""

# ╔═╡ 65894874-7b98-4d40-98da-8711b092c475
Base.iterate(rS::Iterators.Reverse{Squares}, state=rS.itr.count) = state < 1 ? nothing : (state*state, state-1)

# ╔═╡ 9f3e1381-720d-4647-a533-b158d00f1d99
collect(Iterators.reverse(Squares(4)))

# ╔═╡ c51f44fe-702f-42b1-a8fd-390ecca9271d
md"""
## Indexing
"""

# ╔═╡ 1d03ac41-2f22-42d3-a0a3-41a5a93c5b09
md"""
| Methods to implement | Brief description                   |
|:-------------------- |:----------------------------------- |
| `getindex(X, i)`     | `X[i]`, indexed element access      |
| `setindex!(X, v, i)` | `X[i] = v`, indexed assignment      |
| `firstindex(X)`      | The first index, used in `X[begin]` |
| `lastindex(X)`       | The last index, used in `X[end]`    |
"""

# ╔═╡ 7350614f-fccb-4e28-ae52-7dc0e89e36cf
md"""
For the `Squares` iterable above, we can easily compute the `i`th element of the sequence by squaring it.  We can expose this as an indexing expression `S[i]`. To opt into this behavior, `Squares` simply needs to define [`getindex`](@ref):
"""

# ╔═╡ bcbd2c2c-af31-42f7-9347-4583110a5609
function Base.getindex(S::Squares, i::Int)
     1 <= i <= S.count || throw(BoundsError(S, i))
     return i*i
 end

# ╔═╡ b68cfcf3-1af6-4cbd-ae42-792a08cb6038
Squares(100)[23]

# ╔═╡ 1d412e61-68fc-495c-b741-e877c0726f62
md"""
Additionally, to support the syntax `S[begin]` and `S[end]`, we must define [`firstindex`](@ref) and [`lastindex`](@ref) to specify the first and last valid indices, respectively:
"""

# ╔═╡ ee6c5e3d-e61c-425c-b2e3-b4e6235badf6
Base.firstindex(S::Squares) = 1

# ╔═╡ 8bfb1e1a-b96a-410d-a6bb-60ab28f64ff4
Base.lastindex(S::Squares) = length(S)

# ╔═╡ 3047461d-9bde-4725-b9da-4b4f4af03f9c
Squares(23)[end]

# ╔═╡ fb7b97a7-ec56-46b3-bf2f-0c0cd7d5bb6b
md"""
For multi-dimensional `begin`/`end` indexing as in `a[3, begin, 7]`, for example, you should define `firstindex(a, dim)` and `lastindex(a, dim)` (which default to calling `first` and `last` on `axes(a, dim)`, respectively).
"""

# ╔═╡ d00f1353-fa32-4d6d-8a8f-2afff90bd1aa
md"""
Note, though, that the above *only* defines [`getindex`](@ref) with one integer index. Indexing with anything other than an `Int` will throw a [`MethodError`](@ref) saying that there was no matching method. In order to support indexing with ranges or vectors of `Int`s, separate methods must be written:
"""

# ╔═╡ 031357a1-bbc5-435d-8394-349b55155d3b
Base.getindex(S::Squares, i::Number) = S[convert(Int, i)]

# ╔═╡ 29d6b921-2678-448c-acd7-3437db56d2e9
Base.getindex(S::Squares, I) = [S[i] for i in I]

# ╔═╡ b813e4d0-b072-486c-ac2a-00f3f64a9388
Squares(10)[[3,4.,5]]

# ╔═╡ 1cf9b122-7695-4890-bca7-0346b94930eb
md"""
While this is starting to support more of the [indexing operations supported by some of the builtin types](@ref man-array-indexing), there's still quite a number of behaviors missing. This `Squares` sequence is starting to look more and more like a vector as we've added behaviors to it. Instead of defining all these behaviors ourselves, we can officially define it as a subtype of an [`AbstractArray`](@ref).
"""

# ╔═╡ cdc855d7-c107-4129-97d6-4d25fbe9a99a
md"""
## [Abstract Arrays](@id man-interface-array)
"""

# ╔═╡ 4d65d85d-cc4f-45e8-91aa-239910cbef62
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

# ╔═╡ 5a148875-3da2-4c53-8eb6-89b5f2490379
md"""
If a type is defined as a subtype of `AbstractArray`, it inherits a very large set of rich behaviors including iteration and multidimensional indexing built on top of single-element access.  See the [arrays manual page](@ref man-multi-dim-arrays) and the [Julia Base section](@ref lib-arrays) for more supported methods.
"""

# ╔═╡ 9192e6b7-d785-4ec6-99e4-50b252c04093
md"""
A key part in defining an `AbstractArray` subtype is [`IndexStyle`](@ref). Since indexing is such an important part of an array and often occurs in hot loops, it's important to make both indexing and indexed assignment as efficient as possible.  Array data structures are typically defined in one of two ways: either it most efficiently accesses its elements using just one index (linear indexing) or it intrinsically accesses the elements with indices specified for every dimension.  These two modalities are identified by Julia as `IndexLinear()` and `IndexCartesian()`.  Converting a linear index to multiple indexing subscripts is typically very expensive, so this provides a traits-based mechanism to enable efficient generic code for all array types.
"""

# ╔═╡ b333986d-5d7d-43a0-827e-066ca3472a02
md"""
This distinction determines which scalar indexing methods the type must define. `IndexLinear()` arrays are simple: just define `getindex(A::ArrayType, i::Int)`.  When the array is subsequently indexed with a multidimensional set of indices, the fallback `getindex(A::AbstractArray, I...)()` efficiently converts the indices into one linear index and then calls the above method. `IndexCartesian()` arrays, on the other hand, require methods to be defined for each supported dimensionality with `ndims(A)` `Int` indices. For example, [`SparseMatrixCSC`](@ref) from the `SparseArrays` standard library module, only supports two dimensions, so it just defines `getindex(A::SparseMatrixCSC, i::Int, j::Int)`. The same holds for [`setindex!`](@ref).
"""

# ╔═╡ ea07d920-fff3-4da5-a9ba-6577c25d7edf
md"""
Returning to the sequence of squares from above, we could instead define it as a subtype of an `AbstractArray{Int, 1}`:
"""

# ╔═╡ 5a96f7d2-dd0c-4b52-803b-2ed4d9307d8a
struct SquaresVector <: AbstractArray{Int, 1}
     count::Int
 end

# ╔═╡ 4902c8d4-172f-4a7f-a984-2975507f3e46
Base.size(S::SquaresVector) = (S.count,)

# ╔═╡ 9b4077c3-f835-48c0-b97d-63ddf2d4eb77
Base.IndexStyle(::Type{<:SquaresVector}) = IndexLinear()

# ╔═╡ f467d0f3-74a3-41b3-b585-98b87c02c837
Base.getindex(S::SquaresVector, i::Int) = i*i

# ╔═╡ 73dd6198-37da-4ab7-9874-c04823996742
md"""
Note that it's very important to specify the two parameters of the `AbstractArray`; the first defines the [`eltype`](@ref), and the second defines the [`ndims`](@ref). That supertype and those three methods are all it takes for `SquaresVector` to be an iterable, indexable, and completely functional array:
"""

# ╔═╡ e47173af-a9f2-46f7-be15-71f8400c79d1
s = SquaresVector(4)

# ╔═╡ f9652ffc-4088-46b9-95b1-6b6f3a687cab
s[s .> 8]

# ╔═╡ beccce8d-01ee-479e-a9ca-1d9430078443
s + s

# ╔═╡ e70ab91a-e8dd-4d8d-a0cd-f8b8307d2dea
sin.(s)

# ╔═╡ e24c862a-4ca4-4fba-b24d-440212348a35
md"""
As a more complicated example, let's define our own toy N-dimensional sparse-like array type built on top of [`Dict`](@ref):
"""

# ╔═╡ d795e7ed-bfc2-4e37-aa7b-4e63cc9ff395
struct SparseArray{T,N} <: AbstractArray{T,N}
     data::Dict{NTuple{N,Int}, T}
     dims::NTuple{N,Int}
 end

# ╔═╡ 2d84cf2d-f4b1-4a34-bae5-dbd5a5b5c328
SparseArray(::Type{T}, dims::Int...) where {T} = SparseArray(T, dims);

# ╔═╡ f091b821-070a-415d-982d-5edd5225c721
SparseArray(::Type{T}, dims::NTuple{N,Int}) where {T,N} = SparseArray{T,N}(Dict{NTuple{N,Int}, T}(), dims);

# ╔═╡ a90cdb7d-4e07-4dd3-8eac-4a1e9d4966d4
Base.size(A::SparseArray) = A.dims

# ╔═╡ 773e4797-5140-4d66-af1f-ca44fb67ed3c
Base.similar(A::SparseArray, ::Type{T}, dims::Dims) where {T} = SparseArray(T, dims)

# ╔═╡ 4917cff3-bc68-44f6-b2ed-dc1df4b6ea49
Base.getindex(A::SparseArray{T,N}, I::Vararg{Int,N}) where {T,N} = get(A.data, I, zero(T))

# ╔═╡ 8b45b477-8383-4901-bd31-b00efe351768
Base.setindex!(A::SparseArray{T,N}, v, I::Vararg{Int,N}) where {T,N} = (A.data[I] = v)

# ╔═╡ 23c22a63-dc69-4573-9685-da8e0aaca799
md"""
Notice that this is an `IndexCartesian` array, so we must manually define [`getindex`](@ref) and [`setindex!`](@ref) at the dimensionality of the array. Unlike the `SquaresVector`, we are able to define [`setindex!`](@ref), and so we can mutate the array:
"""

# ╔═╡ 41f9cb59-7976-4c47-8239-0d0649064faa
A = SparseArray(Float64, 3, 3)

# ╔═╡ 522174aa-c75a-451d-9e0b-c7093309d072
fill!(A, 2)

# ╔═╡ 27518cd8-6be7-4bed-9e06-1604b6efd035
A[:] = 1:length(A); A

# ╔═╡ 38bbf1e1-6eff-4e95-8bfc-193b9f3b50c6
md"""
The result of indexing an `AbstractArray` can itself be an array (for instance when indexing by an `AbstractRange`). The `AbstractArray` fallback methods use [`similar`](@ref) to allocate an `Array` of the appropriate size and element type, which is filled in using the basic indexing method described above. However, when implementing an array wrapper you often want the result to be wrapped as well:
"""

# ╔═╡ b1564c04-23b0-4213-ba45-a8994189faf6
A[1:2,:]

# ╔═╡ 337789b9-aaaf-4fd4-bb1d-0e1a431f0047
md"""
In this example it is accomplished by defining `Base.similar{T}(A::SparseArray, ::Type{T}, dims::Dims)` to create the appropriate wrapped array. (Note that while `similar` supports 1- and 2-argument forms, in most case you only need to specialize the 3-argument form.) For this to work it's important that `SparseArray` is mutable (supports `setindex!`). Defining `similar`, `getindex` and `setindex!` for `SparseArray` also makes it possible to [`copy`](@ref) the array:
"""

# ╔═╡ 6440c93b-e74a-4631-b734-aa6b0e1ab2bc
copy(A)

# ╔═╡ 6698cbe1-e4da-4708-944f-5c8470c23c22
md"""
In addition to all the iterable and indexable methods from above, these types can also interact with each other and use most of the methods defined in Julia Base for `AbstractArrays`:
"""

# ╔═╡ 9bad9faf-6e35-4104-a11a-64e6b22fcb20
A[SquaresVector(3)]

# ╔═╡ 65d3b021-1a37-464b-bba9-3b56a8c1d606
sum(A)

# ╔═╡ 1103d1f5-ac1b-4d6d-925a-a32d74747d03
md"""
If you are defining an array type that allows non-traditional indexing (indices that start at something other than 1), you should specialize [`axes`](@ref). You should also specialize [`similar`](@ref) so that the `dims` argument (ordinarily a `Dims` size-tuple) can accept `AbstractUnitRange` objects, perhaps range-types `Ind` of your own design. For more information, see [Arrays with custom indices](@ref man-custom-indices).
"""

# ╔═╡ eecb49ea-a179-4937-96fb-e88d609da611
md"""
## [Strided Arrays](@id man-interface-strided-arrays)
"""

# ╔═╡ 8a076012-7247-4d5f-964f-d3996a0eefb0
md"""
| Methods to implement                     |                        | Brief description                                                                                                                                                                   |
|:---------------------------------------- |:---------------------- |:----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- |
| `strides(A)`                             |                        | Return the distance in memory (in number of elements) between adjacent elements in each dimension as a tuple. If `A` is an `AbstractArray{T,0}`, this should return an empty tuple. |
| `Base.unsafe_convert(::Type{Ptr{T}}, A)` |                        | Return the native address of an array.                                                                                                                                              |
| `Base.elsize(::Type{<:A})`               |                        | Return the stride between consecutive elements in the array.                                                                                                                        |
| **Optional methods**                     | **Default definition** | **Brief description**                                                                                                                                                               |
| `stride(A, i::Int)`                      | `strides(A)[i]`        | Return the distance in memory (in number of elements) between adjacent elements in dimension k.                                                                                     |
"""

# ╔═╡ 1e7a008f-dac2-40d2-9086-bf267c68fd12
md"""
A strided array is a subtype of `AbstractArray` whose entries are stored in memory with fixed strides. Provided the element type of the array is compatible with BLAS, a strided array can utilize BLAS and LAPACK routines for more efficient linear algebra routines.  A typical example of a user-defined strided array is one that wraps a standard `Array` with additional structure.
"""

# ╔═╡ fa678509-fd51-4c6b-a549-9ffcc717c63d
md"""
Warning: do not implement these methods if the underlying storage is not actually strided, as it may lead to incorrect results or segmentation faults.
"""

# ╔═╡ f01381da-d10c-4b2d-b63b-c985f87af313
md"""
Here are some examples to demonstrate which type of arrays are strided and which are not:
"""

# ╔═╡ 9d36a06f-5da7-401f-ac9d-eeae3acc52f8
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

# ╔═╡ c46f4246-b646-4ee5-9367-09c92452d57d
md"""
## [Customizing broadcasting](@id man-interfaces-broadcasting)
"""

# ╔═╡ b526107e-8d8d-433c-b511-71bf3bb65143
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

# ╔═╡ f0c971af-b8e0-4a50-ac2e-d5bc6c800c28
md"""
[Broadcasting](@ref) is triggered by an explicit call to `broadcast` or `broadcast!`, or implicitly by \"dot\" operations like `A .+ b` or `f.(x, y)`. Any object that has [`axes`](@ref) and supports indexing can participate as an argument in broadcasting, and by default the result is stored in an `Array`. This basic framework is extensible in three major ways:
"""

# ╔═╡ 71b64fad-1917-4521-bfcb-503740e2b24b
md"""
  * Ensuring that all arguments support broadcast
  * Selecting an appropriate output array for the given set of arguments
  * Selecting an efficient implementation for the given set of arguments
"""

# ╔═╡ b1d234b8-45ec-47e1-943f-5726b7dbce5a
md"""
Not all types support `axes` and indexing, but many are convenient to allow in broadcast. The [`Base.broadcastable`](@ref) function is called on each argument to broadcast, allowing it to return something different that supports `axes` and indexing. By default, this is the identity function for all `AbstractArray`s and `Number`s — they already support `axes` and indexing. For a handful of other types (including but not limited to types themselves, functions, special singletons like [`missing`](@ref) and [`nothing`](@ref), and dates), `Base.broadcastable` returns the argument wrapped in a `Ref` to act as a 0-dimensional \"scalar\" for the purposes of broadcasting. Custom types can similarly specialize `Base.broadcastable` to define their shape, but they should follow the convention that `collect(Base.broadcastable(x)) == collect(x)`. A notable exception is `AbstractString`; strings are special-cased to behave as scalars for the purposes of broadcast even though they are iterable collections of their characters (see [Strings](@ref) for more).
"""

# ╔═╡ a2d16783-fd79-43d4-88b8-b69530a86ea6
md"""
The next two steps (selecting the output array and implementation) are dependent upon determining a single answer for a given set of arguments. Broadcast must take all the varied types of its arguments and collapse them down to just one output array and one implementation. Broadcast calls this single answer a \"style.\" Every broadcastable object each has its own preferred style, and a promotion-like system is used to combine these styles into a single answer — the \"destination style\".
"""

# ╔═╡ 2e4c48db-f82b-49e1-b198-2966f751eebc
md"""
### Broadcast Styles
"""

# ╔═╡ e1020054-b1b2-47d0-b5b3-ef147d93b9ff
md"""
`Base.BroadcastStyle` is the abstract type from which all broadcast styles are derived. When used as a function it has two possible forms, unary (single-argument) and binary. The unary variant states that you intend to implement specific broadcasting behavior and/or output type, and do not wish to rely on the default fallback [`Broadcast.DefaultArrayStyle`](@ref).
"""

# ╔═╡ fd1ebcc4-d1e6-4d90-bf9a-8b22fae5dcb1
md"""
To override these defaults, you can define a custom `BroadcastStyle` for your object:
"""

# ╔═╡ 4483cbd1-efc8-481c-8ff6-6491921da7c1
md"""
```julia
struct MyStyle <: Broadcast.BroadcastStyle end
Base.BroadcastStyle(::Type{<:MyType}) = MyStyle()
```
"""

# ╔═╡ e51f61fc-5189-4caf-be78-f65bc3d5d93a
md"""
In some cases it might be convenient not to have to define `MyStyle`, in which case you can leverage one of the general broadcast wrappers:
"""

# ╔═╡ 835a369e-32c8-4e08-90f6-9630aacd73dd
md"""
  * `Base.BroadcastStyle(::Type{<:MyType}) = Broadcast.Style{MyType}()` can be used for arbitrary types.
  * `Base.BroadcastStyle(::Type{<:MyType}) = Broadcast.ArrayStyle{MyType}()` is preferred if `MyType` is an `AbstractArray`.
  * For `AbstractArrays` that only support a certain dimensionality, create a subtype of `Broadcast.AbstractArrayStyle{N}` (see below).
"""

# ╔═╡ 775d3f7c-728b-436b-9b7d-3e42e4a6de7a
md"""
When your broadcast operation involves several arguments, individual argument styles get combined to determine a single `DestStyle` that controls the type of the output container. For more details, see [below](@ref writing-binary-broadcasting-rules).
"""

# ╔═╡ 45e1b91b-f3d6-453b-ae3b-23bcc0377d65
md"""
### Selecting an appropriate output array
"""

# ╔═╡ 7b2ba048-365e-4a57-a721-1fd4529105f2
md"""
The broadcast style is computed for every broadcasting operation to allow for dispatch and specialization. The actual allocation of the result array is handled by `similar`, using the Broadcasted object as its first argument.
"""

# ╔═╡ 6891840f-69c6-413f-9cd8-8fbcf743ce99
md"""
```julia
Base.similar(bc::Broadcasted{DestStyle}, ::Type{ElType})
```
"""

# ╔═╡ c7881ead-aba7-4547-b3cd-0fdb7e407795
md"""
The fallback definition is
"""

# ╔═╡ 049a5255-a77b-45f8-985b-306efcd08029
md"""
```julia
similar(bc::Broadcasted{DefaultArrayStyle{N}}, ::Type{ElType}) where {N,ElType} =
    similar(Array{ElType}, axes(bc))
```
"""

# ╔═╡ 9febe21f-ad91-4cb1-ada8-43a76201e1b7
md"""
However, if needed you can specialize on any or all of these arguments. The final argument `bc` is a lazy representation of a (potentially fused) broadcast operation, a `Broadcasted` object.  For these purposes, the most important fields of the wrapper are `f` and `args`, describing the function and argument list, respectively.  Note that the argument list can — and often does — include other nested `Broadcasted` wrappers.
"""

# ╔═╡ 89a22b4c-2fd1-4191-af81-1ff42a9ec1aa
md"""
For a complete example, let's say you have created a type, `ArrayAndChar`, that stores an array and a single character:
"""

# ╔═╡ a16c32e6-2d19-4478-ac67-d93c3b5bdbf7
struct ArrayAndChar{T,N} <: AbstractArray{T,N}
    data::Array{T,N}
    char::Char
end

# ╔═╡ ff44e621-f58e-49ba-ba24-86bef950912f
md"""
You might want broadcasting to preserve the `char` \"metadata.\" First we define
"""

# ╔═╡ 1a876eb8-5285-43c9-8380-b55b80cabc93
Base.BroadcastStyle(::Type{<:ArrayAndChar}) = Broadcast.ArrayStyle{ArrayAndChar}()

# ╔═╡ 0b35076c-b854-44ca-baba-3c58b7d087e6
md"""
This means we must also define a corresponding `similar` method:
"""

# ╔═╡ 5e6c77e5-ae0b-4f93-99e6-a4433de39e6b
function Base.similar(bc::Broadcast.Broadcasted{Broadcast.ArrayStyle{ArrayAndChar}}, ::Type{ElType}) where ElType
    # Scan the inputs for the ArrayAndChar:
    A = find_aac(bc)
    # Use the char field of A to create the output
    ArrayAndChar(similar(Array{ElType}, axes(bc)), A.char)
end

# ╔═╡ fa13c4cc-d24c-4247-aa26-ed8a59fc70a5
md"""
From these definitions, one obtains the following behavior:
"""

# ╔═╡ 9fa23fb8-3850-4b69-9816-c579007211fd
a = ArrayAndChar([1 2; 3 4], 'x')

# ╔═╡ e7fb599c-6b71-4b0a-84ff-84e6492b7c32
a .+ 1

# ╔═╡ b28284cc-bce8-44ca-81f0-67112abfb930
a .+ [5,10]

# ╔═╡ 443bb852-ecc7-4b24-9932-c664676601c3
md"""
### [Extending broadcast with custom implementations](@id extending-in-place-broadcast)
"""

# ╔═╡ 9acf0eb6-aa81-445e-87d6-fd047b92b61b
md"""
In general, a broadcast operation is represented by a lazy `Broadcasted` container that holds onto the function to be applied alongside its arguments. Those arguments may themselves be more nested `Broadcasted` containers, forming a large expression tree to be evaluated. A nested tree of `Broadcasted` containers is directly constructed by the implicit dot syntax; `5 .+ 2.*x` is transiently represented by `Broadcasted(+, 5, Broadcasted(*, 2, x))`, for example. This is invisible to users as it is immediately realized through a call to `copy`, but it is this container that provides the basis for broadcast's extensibility for authors of custom types. The built-in broadcast machinery will then determine the result type and size based upon the arguments, allocate it, and then finally copy the realization of the `Broadcasted` object into it with a default `copyto!(::AbstractArray, ::Broadcasted)` method. The built-in fallback `broadcast` and `broadcast!` methods similarly construct a transient `Broadcasted` representation of the operation so they can follow the same codepath. This allows custom array implementations to provide their own `copyto!` specialization to customize and optimize broadcasting. This is again determined by the computed broadcast style. This is such an important part of the operation that it is stored as the first type parameter of the `Broadcasted` type, allowing for dispatch and specialization.
"""

# ╔═╡ 5669c7d4-b751-4e51-a30d-1ca60df65ebc
md"""
For some types, the machinery to \"fuse\" operations across nested levels of broadcasting is not available or could be done more efficiently incrementally. In such cases, you may need or want to evaluate `x .* (x .+ 1)` as if it had been written `broadcast(*, x, broadcast(+, x, 1))`, where the inner operation is evaluated before tackling the outer operation. This sort of eager operation is directly supported by a bit of indirection; instead of directly constructing `Broadcasted` objects, Julia lowers the fused expression `x .* (x .+ 1)` to `Broadcast.broadcasted(*, x, Broadcast.broadcasted(+, x, 1))`. Now, by default, `broadcasted` just calls the `Broadcasted` constructor to create the lazy representation of the fused expression tree, but you can choose to override it for a particular combination of function and arguments.
"""

# ╔═╡ 09391bb2-dbcb-4a59-acda-437ba249c7a1
md"""
As an example, the builtin `AbstractRange` objects use this machinery to optimize pieces of broadcasted expressions that can be eagerly evaluated purely in terms of the start, step, and length (or stop) instead of computing every single element. Just like all the other machinery, `broadcasted` also computes and exposes the combined broadcast style of its arguments, so instead of specializing on `broadcasted(f, args...)`, you can specialize on `broadcasted(::DestStyle, f, args...)` for any combination of style, function, and arguments.
"""

# ╔═╡ 14810f59-6f99-4762-b888-0a271780229f
md"""
For example, the following definition supports the negation of ranges:
"""

# ╔═╡ 9095d2d7-6603-41d6-9dd2-da6f7effc236
md"""
```julia
broadcasted(::DefaultArrayStyle{1}, ::typeof(-), r::OrdinalRange) = range(-first(r), step=-step(r), length=length(r))
```
"""

# ╔═╡ 24854ff3-a0eb-472a-9202-c6bed14e6d97
md"""
### [Extending in-place broadcasting](@id extending-in-place-broadcast)
"""

# ╔═╡ 2f416576-c12f-4ac0-9c1f-feff621342ca
md"""
In-place broadcasting can be supported by defining the appropriate `copyto!(dest, bc::Broadcasted)` method. Because you might want to specialize either on `dest` or the specific subtype of `bc`, to avoid ambiguities between packages we recommend the following convention.
"""

# ╔═╡ f8e7f050-e6f1-4021-bb09-af31c6fa042e
md"""
If you wish to specialize on a particular style `DestStyle`, define a method for
"""

# ╔═╡ f4f2c581-e56e-4f1f-9ec7-d5975d9e241b
md"""
```julia
copyto!(dest, bc::Broadcasted{DestStyle})
```
"""

# ╔═╡ ccb68f78-a576-4271-be11-a8c7b19a1fea
md"""
Optionally, with this form you can also specialize on the type of `dest`.
"""

# ╔═╡ d59b444f-6986-41ee-9b12-5f64df35fa77
md"""
If instead you want to specialize on the destination type `DestType` without specializing on `DestStyle`, then you should define a method with the following signature:
"""

# ╔═╡ 84c6b5bf-af1d-4285-891c-e47cd1de99b3
md"""
```julia
copyto!(dest::DestType, bc::Broadcasted{Nothing})
```
"""

# ╔═╡ 9f530e47-c49b-4901-9519-d007cdf85a51
md"""
This leverages a fallback implementation of `copyto!` that converts the wrapper into a `Broadcasted{Nothing}`. Consequently, specializing on `DestType` has lower precedence than methods that specialize on `DestStyle`.
"""

# ╔═╡ f87d5a3d-cc6b-4478-8f99-a0ce9cd25dea
md"""
Similarly, you can completely override out-of-place broadcasting with a `copy(::Broadcasted)` method.
"""

# ╔═╡ 85858326-510a-40ed-ac1e-1245e4795dbb
md"""
#### Working with `Broadcasted` objects
"""

# ╔═╡ ae4c131f-b032-4583-a3e3-09473222e411
md"""
In order to implement such a `copy` or `copyto!`, method, of course, you must work with the `Broadcasted` wrapper to compute each element. There are two main ways of doing so:
"""

# ╔═╡ 74d13b45-8d7f-4270-9a2b-763bce4774f1
md"""
  * `Broadcast.flatten` recomputes the potentially nested operation into a single function and flat list of arguments. You are responsible for implementing the broadcasting shape rules yourself, but this may be helpful in limited situations.
  * Iterating over the `CartesianIndices` of the `axes(::Broadcasted)` and using indexing with the resulting `CartesianIndex` object to compute the result.
"""

# ╔═╡ 035a4da0-4e65-49ab-869d-b78f17ccb839
md"""
### [Writing binary broadcasting rules](@id writing-binary-broadcasting-rules)
"""

# ╔═╡ 57a7b6ad-90e0-46e7-bd29-5c3866eafcb1
md"""
The precedence rules are defined by binary `BroadcastStyle` calls:
"""

# ╔═╡ 494f9702-be9c-4cb2-b979-9c2ad319b92b
md"""
```julia
Base.BroadcastStyle(::Style1, ::Style2) = Style12()
```
"""

# ╔═╡ bd0fb463-d662-4563-a2d1-4b71465e5566
md"""
where `Style12` is the `BroadcastStyle` you want to choose for outputs involving arguments of `Style1` and `Style2`. For example,
"""

# ╔═╡ e8c2702e-3ac7-4894-82af-b6b7314a3f39
md"""
```julia
Base.BroadcastStyle(::Broadcast.Style{Tuple}, ::Broadcast.AbstractArrayStyle{0}) = Broadcast.Style{Tuple}()
```
"""

# ╔═╡ 08ec3394-5e5b-46c0-a16f-79a9142d9539
md"""
indicates that `Tuple` \"wins\" over zero-dimensional arrays (the output container will be a tuple). It is worth noting that you do not need to (and should not) define both argument orders of this call; defining one is sufficient no matter what order the user supplies the arguments in.
"""

# ╔═╡ 419277aa-1157-4b11-aef9-5512b27f2d3a
md"""
For `AbstractArray` types, defining a `BroadcastStyle` supersedes the fallback choice, [`Broadcast.DefaultArrayStyle`](@ref). `DefaultArrayStyle` and the abstract supertype, `AbstractArrayStyle`, store the dimensionality as a type parameter to support specialized array types that have fixed dimensionality requirements.
"""

# ╔═╡ f20d631b-750e-486a-8cb5-5447882abfba
md"""
`DefaultArrayStyle` \"loses\" to any other `AbstractArrayStyle` that has been defined because of the following methods:
"""

# ╔═╡ 4d1d0de7-bc39-4ff5-aeec-8bf0e5d9a67b
md"""
```julia
BroadcastStyle(a::AbstractArrayStyle{Any}, ::DefaultArrayStyle) = a
BroadcastStyle(a::AbstractArrayStyle{N}, ::DefaultArrayStyle{N}) where N = a
BroadcastStyle(a::AbstractArrayStyle{M}, ::DefaultArrayStyle{N}) where {M,N} =
    typeof(a)(_max(Val(M),Val(N)))
```
"""

# ╔═╡ 0521a4cf-6661-4311-8814-3bddb4b97c34
md"""
You do not need to write binary `BroadcastStyle` rules unless you want to establish precedence for two or more non-`DefaultArrayStyle` types.
"""

# ╔═╡ 6a9c5492-b8df-429d-989a-4b48de7e0f2e
md"""
If your array type does have fixed dimensionality requirements, then you should subtype `AbstractArrayStyle`. For example, the sparse array code has the following definitions:
"""

# ╔═╡ 081d6b2a-d713-4205-af08-e53760e229aa
md"""
```julia
struct SparseVecStyle <: Broadcast.AbstractArrayStyle{1} end
struct SparseMatStyle <: Broadcast.AbstractArrayStyle{2} end
Base.BroadcastStyle(::Type{<:SparseVector}) = SparseVecStyle()
Base.BroadcastStyle(::Type{<:SparseMatrixCSC}) = SparseMatStyle()
```
"""

# ╔═╡ 68a4a855-0f02-445b-aa40-d301a0b3a566
md"""
Whenever you subtype `AbstractArrayStyle`, you also need to define rules for combining dimensionalities, by creating a constructor for your style that takes a `Val(N)` argument. For example:
"""

# ╔═╡ 33fafada-dca8-4c8c-ab0e-bb95bad40e8d
md"""
```julia
SparseVecStyle(::Val{0}) = SparseVecStyle()
SparseVecStyle(::Val{1}) = SparseVecStyle()
SparseVecStyle(::Val{2}) = SparseMatStyle()
SparseVecStyle(::Val{N}) where N = Broadcast.DefaultArrayStyle{N}()
```
"""

# ╔═╡ c48fd963-e85b-4e00-93c8-99015860df9c
md"""
These rules indicate that the combination of a `SparseVecStyle` with 0- or 1-dimensional arrays yields another `SparseVecStyle`, that its combination with a 2-dimensional array yields a `SparseMatStyle`, and anything of higher dimensionality falls back to the dense arbitrary-dimensional framework. These rules allow broadcasting to keep the sparse representation for operations that result in one or two dimensional outputs, but produce an `Array` for any other dimensionality.
"""

# ╔═╡ Cell order:
# ╟─3d5e1ea7-0410-46e5-8a2a-1f29b592248b
# ╟─aaf8e89e-633f-4059-a6b7-94848e06b02d
# ╟─f3f6b921-f62c-4305-8fe3-6fddc5f0661b
# ╟─1e0c4ba3-ee66-4468-9df7-a8116366f2ed
# ╟─c0391c84-97f8-4e4e-afd9-bf859d695c16
# ╟─8367a575-4571-4842-83b6-4d980e044969
# ╟─c7898056-9c8b-484d-b0cc-dc2f064c6b13
# ╟─a4725f8e-7f03-4c80-a6b1-6187d14db3dc
# ╟─1468bbaf-6f29-47b7-aa27-0a6d9ca42c56
# ╟─52526967-b8b8-4bf4-b8ca-e1413fb53e29
# ╟─c7941e0c-dffc-4fa9-9ed5-390f4a7fa7d7
# ╟─83d9e1e1-ab06-4a30-a8a0-61fe4c483d67
# ╠═2b17d5bd-66dc-4f5e-9b98-943bddb20376
# ╠═8e0ea772-cf25-4ba8-b68a-23a93e16ccd1
# ╟─5c1933bd-e387-4401-a6aa-bc777eabed44
# ╠═6cd0d300-c522-4a04-b326-ff8073930987
# ╟─d2baef86-8ae1-4de2-bcb5-32c7e43e5ab3
# ╠═2214ff06-2860-436b-af18-396b607f26ad
# ╠═11efe1b4-33eb-481b-af4a-ddc171c722b6
# ╠═76bb2c44-21d6-497b-a1fd-a6cecf417cc7
# ╠═eba99879-0377-481a-87c2-b412594744d8
# ╟─2f820f91-ef02-4f81-b636-24e701ac2af5
# ╠═40f8678f-585e-42f6-acfd-59d1300cf688
# ╠═7c519bcf-1144-430c-802c-a6e756583b0a
# ╟─0f2b7d51-0a12-413f-9226-6701a3f33430
# ╠═43ae0220-d98a-44b9-8862-5f7275ab73b2
# ╟─57ba9bd4-7457-42be-9bfd-eba77f51fdee
# ╠═cfe5fa48-64cb-4cb7-95b3-69f072e83292
# ╠═11b62fbc-e914-48c6-beb8-51fb7af4b4b6
# ╟─ebcca04d-9b39-49a2-8e57-5c556bf08b6a
# ╟─3e318161-6d3d-4b0c-926c-2441749ce994
# ╠═65894874-7b98-4d40-98da-8711b092c475
# ╠═9f3e1381-720d-4647-a533-b158d00f1d99
# ╟─c51f44fe-702f-42b1-a8fd-390ecca9271d
# ╟─1d03ac41-2f22-42d3-a0a3-41a5a93c5b09
# ╟─7350614f-fccb-4e28-ae52-7dc0e89e36cf
# ╠═bcbd2c2c-af31-42f7-9347-4583110a5609
# ╠═b68cfcf3-1af6-4cbd-ae42-792a08cb6038
# ╟─1d412e61-68fc-495c-b741-e877c0726f62
# ╠═ee6c5e3d-e61c-425c-b2e3-b4e6235badf6
# ╠═8bfb1e1a-b96a-410d-a6bb-60ab28f64ff4
# ╠═3047461d-9bde-4725-b9da-4b4f4af03f9c
# ╟─fb7b97a7-ec56-46b3-bf2f-0c0cd7d5bb6b
# ╟─d00f1353-fa32-4d6d-8a8f-2afff90bd1aa
# ╠═031357a1-bbc5-435d-8394-349b55155d3b
# ╠═29d6b921-2678-448c-acd7-3437db56d2e9
# ╠═b813e4d0-b072-486c-ac2a-00f3f64a9388
# ╟─1cf9b122-7695-4890-bca7-0346b94930eb
# ╟─cdc855d7-c107-4129-97d6-4d25fbe9a99a
# ╟─4d65d85d-cc4f-45e8-91aa-239910cbef62
# ╟─5a148875-3da2-4c53-8eb6-89b5f2490379
# ╟─9192e6b7-d785-4ec6-99e4-50b252c04093
# ╟─b333986d-5d7d-43a0-827e-066ca3472a02
# ╟─ea07d920-fff3-4da5-a9ba-6577c25d7edf
# ╠═5a96f7d2-dd0c-4b52-803b-2ed4d9307d8a
# ╠═4902c8d4-172f-4a7f-a984-2975507f3e46
# ╠═9b4077c3-f835-48c0-b97d-63ddf2d4eb77
# ╠═f467d0f3-74a3-41b3-b585-98b87c02c837
# ╟─73dd6198-37da-4ab7-9874-c04823996742
# ╠═e47173af-a9f2-46f7-be15-71f8400c79d1
# ╠═f9652ffc-4088-46b9-95b1-6b6f3a687cab
# ╠═beccce8d-01ee-479e-a9ca-1d9430078443
# ╠═e70ab91a-e8dd-4d8d-a0cd-f8b8307d2dea
# ╟─e24c862a-4ca4-4fba-b24d-440212348a35
# ╠═d795e7ed-bfc2-4e37-aa7b-4e63cc9ff395
# ╠═2d84cf2d-f4b1-4a34-bae5-dbd5a5b5c328
# ╠═f091b821-070a-415d-982d-5edd5225c721
# ╠═a90cdb7d-4e07-4dd3-8eac-4a1e9d4966d4
# ╠═773e4797-5140-4d66-af1f-ca44fb67ed3c
# ╠═4917cff3-bc68-44f6-b2ed-dc1df4b6ea49
# ╠═8b45b477-8383-4901-bd31-b00efe351768
# ╟─23c22a63-dc69-4573-9685-da8e0aaca799
# ╠═41f9cb59-7976-4c47-8239-0d0649064faa
# ╠═522174aa-c75a-451d-9e0b-c7093309d072
# ╠═27518cd8-6be7-4bed-9e06-1604b6efd035
# ╟─38bbf1e1-6eff-4e95-8bfc-193b9f3b50c6
# ╠═b1564c04-23b0-4213-ba45-a8994189faf6
# ╟─337789b9-aaaf-4fd4-bb1d-0e1a431f0047
# ╠═6440c93b-e74a-4631-b734-aa6b0e1ab2bc
# ╟─6698cbe1-e4da-4708-944f-5c8470c23c22
# ╠═9bad9faf-6e35-4104-a11a-64e6b22fcb20
# ╠═65d3b021-1a37-464b-bba9-3b56a8c1d606
# ╟─1103d1f5-ac1b-4d6d-925a-a32d74747d03
# ╟─eecb49ea-a179-4937-96fb-e88d609da611
# ╟─8a076012-7247-4d5f-964f-d3996a0eefb0
# ╟─1e7a008f-dac2-40d2-9086-bf267c68fd12
# ╟─fa678509-fd51-4c6b-a549-9ffcc717c63d
# ╟─f01381da-d10c-4b2d-b63b-c985f87af313
# ╟─9d36a06f-5da7-401f-ac9d-eeae3acc52f8
# ╟─c46f4246-b646-4ee5-9367-09c92452d57d
# ╟─b526107e-8d8d-433c-b511-71bf3bb65143
# ╟─f0c971af-b8e0-4a50-ac2e-d5bc6c800c28
# ╟─71b64fad-1917-4521-bfcb-503740e2b24b
# ╟─b1d234b8-45ec-47e1-943f-5726b7dbce5a
# ╟─a2d16783-fd79-43d4-88b8-b69530a86ea6
# ╟─2e4c48db-f82b-49e1-b198-2966f751eebc
# ╟─e1020054-b1b2-47d0-b5b3-ef147d93b9ff
# ╟─fd1ebcc4-d1e6-4d90-bf9a-8b22fae5dcb1
# ╟─4483cbd1-efc8-481c-8ff6-6491921da7c1
# ╟─e51f61fc-5189-4caf-be78-f65bc3d5d93a
# ╟─835a369e-32c8-4e08-90f6-9630aacd73dd
# ╟─775d3f7c-728b-436b-9b7d-3e42e4a6de7a
# ╟─45e1b91b-f3d6-453b-ae3b-23bcc0377d65
# ╟─7b2ba048-365e-4a57-a721-1fd4529105f2
# ╟─6891840f-69c6-413f-9cd8-8fbcf743ce99
# ╟─c7881ead-aba7-4547-b3cd-0fdb7e407795
# ╟─049a5255-a77b-45f8-985b-306efcd08029
# ╟─9febe21f-ad91-4cb1-ada8-43a76201e1b7
# ╟─89a22b4c-2fd1-4191-af81-1ff42a9ec1aa
# ╠═a16c32e6-2d19-4478-ac67-d93c3b5bdbf7
# ╟─ff44e621-f58e-49ba-ba24-86bef950912f
# ╠═1a876eb8-5285-43c9-8380-b55b80cabc93
# ╟─0b35076c-b854-44ca-baba-3c58b7d087e6
# ╠═5e6c77e5-ae0b-4f93-99e6-a4433de39e6b
# ╟─fa13c4cc-d24c-4247-aa26-ed8a59fc70a5
# ╠═9fa23fb8-3850-4b69-9816-c579007211fd
# ╠═e7fb599c-6b71-4b0a-84ff-84e6492b7c32
# ╠═b28284cc-bce8-44ca-81f0-67112abfb930
# ╟─443bb852-ecc7-4b24-9932-c664676601c3
# ╟─9acf0eb6-aa81-445e-87d6-fd047b92b61b
# ╟─5669c7d4-b751-4e51-a30d-1ca60df65ebc
# ╟─09391bb2-dbcb-4a59-acda-437ba249c7a1
# ╟─14810f59-6f99-4762-b888-0a271780229f
# ╟─9095d2d7-6603-41d6-9dd2-da6f7effc236
# ╟─24854ff3-a0eb-472a-9202-c6bed14e6d97
# ╟─2f416576-c12f-4ac0-9c1f-feff621342ca
# ╟─f8e7f050-e6f1-4021-bb09-af31c6fa042e
# ╟─f4f2c581-e56e-4f1f-9ec7-d5975d9e241b
# ╟─ccb68f78-a576-4271-be11-a8c7b19a1fea
# ╟─d59b444f-6986-41ee-9b12-5f64df35fa77
# ╟─84c6b5bf-af1d-4285-891c-e47cd1de99b3
# ╟─9f530e47-c49b-4901-9519-d007cdf85a51
# ╟─f87d5a3d-cc6b-4478-8f99-a0ce9cd25dea
# ╟─85858326-510a-40ed-ac1e-1245e4795dbb
# ╟─ae4c131f-b032-4583-a3e3-09473222e411
# ╟─74d13b45-8d7f-4270-9a2b-763bce4774f1
# ╟─035a4da0-4e65-49ab-869d-b78f17ccb839
# ╟─57a7b6ad-90e0-46e7-bd29-5c3866eafcb1
# ╟─494f9702-be9c-4cb2-b979-9c2ad319b92b
# ╟─bd0fb463-d662-4563-a2d1-4b71465e5566
# ╟─e8c2702e-3ac7-4894-82af-b6b7314a3f39
# ╟─08ec3394-5e5b-46c0-a16f-79a9142d9539
# ╟─419277aa-1157-4b11-aef9-5512b27f2d3a
# ╟─f20d631b-750e-486a-8cb5-5447882abfba
# ╟─4d1d0de7-bc39-4ff5-aeec-8bf0e5d9a67b
# ╟─0521a4cf-6661-4311-8814-3bddb4b97c34
# ╟─6a9c5492-b8df-429d-989a-4b48de7e0f2e
# ╟─081d6b2a-d713-4205-af08-e53760e229aa
# ╟─68a4a855-0f02-445b-aa40-d301a0b3a566
# ╟─33fafada-dca8-4c8c-ab0e-bb95bad40e8d
# ╟─c48fd963-e85b-4e00-93c8-99015860df9c
