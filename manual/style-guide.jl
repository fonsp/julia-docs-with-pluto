### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ 2c542b0e-73b3-4cfc-a13b-1d2112946b2e
md"""
# Style Guide
"""

# ╔═╡ d8c9936d-4b87-4ce1-9e52-3bfe413e3a5c
md"""
The following sections explain a few aspects of idiomatic Julia coding style. None of these rules are absolute; they are only suggestions to help familiarize you with the language and to help you choose among alternative designs.
"""

# ╔═╡ 801e96e2-4e85-45f7-a2ff-65878c45449e
md"""
## Indentation
"""

# ╔═╡ 856ac9f8-ee7e-44bc-be12-da62ff58023f
md"""
Use 4 spaces per indentation level.
"""

# ╔═╡ 2f3cc511-23b5-49eb-a75f-a26fd4b8deca
md"""
## Write functions, not just scripts
"""

# ╔═╡ 15d68018-252e-4dba-acf1-e4db08cffec7
md"""
Writing code as a series of steps at the top level is a quick way to get started solving a problem, but you should try to divide a program into functions as soon as possible. Functions are more reusable and testable, and clarify what steps are being done and what their inputs and outputs are. Furthermore, code inside functions tends to run much faster than top level code, due to how Julia's compiler works.
"""

# ╔═╡ 4b66bf53-bb76-4a13-a069-b0a7f1242d09
md"""
It is also worth emphasizing that functions should take arguments, instead of operating directly on global variables (aside from constants like [`pi`](@ref)).
"""

# ╔═╡ f7e89dcb-6618-43fe-becd-fa99ab8f349d
md"""
## Avoid writing overly-specific types
"""

# ╔═╡ ddfb2448-0067-4548-9604-6999a98d5081
md"""
Code should be as generic as possible. Instead of writing:
"""

# ╔═╡ 32291f55-6e1f-4e41-acf9-3ba3e6ecb073
md"""
```julia
Complex{Float64}(x)
```
"""

# ╔═╡ 13da56cf-7d7d-4999-91ff-aa19cc20a3ee
md"""
it's better to use available generic functions:
"""

# ╔═╡ d7702945-0ba9-4b7a-9e0f-3e13d1ac2a48
md"""
```julia
complex(float(x))
```
"""

# ╔═╡ ed1c5f7b-2401-45ed-bd1d-03a80af181a7
md"""
The second version will convert `x` to an appropriate type, instead of always the same type.
"""

# ╔═╡ 24d072bf-c5af-4464-a035-5e8c294828c9
md"""
This style point is especially relevant to function arguments. For example, don't declare an argument to be of type `Int` or [`Int32`](@ref) if it really could be any integer, expressed with the abstract type [`Integer`](@ref). In fact, in many cases you can omit the argument type altogether, unless it is needed to disambiguate from other method definitions, since a [`MethodError`](@ref) will be thrown anyway if a type is passed that does not support any of the requisite operations. (This is known as [duck typing](https://en.wikipedia.org/wiki/Duck_typing).)
"""

# ╔═╡ b196d9d0-d3a2-496f-a4f7-4971513a2c78
md"""
For example, consider the following definitions of a function `addone` that returns one plus its argument:
"""

# ╔═╡ 16487cf3-daea-422e-a08b-46fdd3d6360c
md"""
```julia
addone(x::Int) = x + 1                 # works only for Int
addone(x::Integer) = x + oneunit(x)    # any integer type
addone(x::Number) = x + oneunit(x)     # any numeric type
addone(x) = x + oneunit(x)             # any type supporting + and oneunit
```
"""

# ╔═╡ 8d40396c-f6a5-43b6-b66c-5e7469b9cdb6
md"""
The last definition of `addone` handles any type supporting [`oneunit`](@ref) (which returns 1 in the same type as `x`, which avoids unwanted type promotion) and the [`+`](@ref) function with those arguments. The key thing to realize is that there is *no performance penalty* to defining *only* the general `addone(x) = x + oneunit(x)`, because Julia will automatically compile specialized versions as needed. For example, the first time you call `addone(12)`, Julia will automatically compile a specialized `addone` function for `x::Int` arguments, with the call to `oneunit` replaced by its inlined value `1`. Therefore, the first three definitions of `addone` above are completely redundant with the fourth definition.
"""

# ╔═╡ 667a294a-aac9-4c87-be17-8f6d7c71b570
md"""
## Handle excess argument diversity in the caller
"""

# ╔═╡ cd639355-b7c2-4854-8ddf-5543290ecb96
md"""
Instead of:
"""

# ╔═╡ b9497ed0-3f6f-4f35-9043-366fbd3bf811
md"""
```julia
function foo(x, y)
    x = Int(x); y = Int(y)
    ...
end
foo(x, y)
```
"""

# ╔═╡ 47156372-e007-44f0-a64b-5e485d4ace7f
md"""
use:
"""

# ╔═╡ 619e451c-f9b4-429e-b871-0c22037a728e
md"""
```julia
function foo(x::Int, y::Int)
    ...
end
foo(Int(x), Int(y))
```
"""

# ╔═╡ 43c47de1-1bc9-44d3-85c7-6c45418d3616
md"""
This is better style because `foo` does not really accept numbers of all types; it really needs `Int` s.
"""

# ╔═╡ df903daf-245d-4794-b450-228061ccce35
md"""
One issue here is that if a function inherently requires integers, it might be better to force the caller to decide how non-integers should be converted (e.g. floor or ceiling). Another issue is that declaring more specific types leaves more \"space\" for future method definitions.
"""

# ╔═╡ 9b0cd14d-ac2f-4071-b393-57802bac949a
md"""
## [Append `!` to names of functions that modify their arguments](@id bang-convention)
"""

# ╔═╡ 7f53fd46-1dcb-479f-ace7-cd24e3997245
md"""
Instead of:
"""

# ╔═╡ 4830d04c-b01e-4184-bf42-60d0c8dc951a
md"""
```julia
function double(a::AbstractArray{<:Number})
    for i = firstindex(a):lastindex(a)
        a[i] *= 2
    end
    return a
end
```
"""

# ╔═╡ 0f3adcef-f05d-4df5-b5b1-0b88c564631e
md"""
use:
"""

# ╔═╡ 45bae830-9283-4bd5-8a71-68e2de47309e
md"""
```julia
function double!(a::AbstractArray{<:Number})
    for i = firstindex(a):lastindex(a)
        a[i] *= 2
    end
    return a
end
```
"""

# ╔═╡ 40dbc086-9c03-4d7c-9482-6321d4115605
md"""
Julia Base uses this convention throughout and contains examples of functions with both copying and modifying forms (e.g., [`sort`](@ref) and [`sort!`](@ref)), and others which are just modifying (e.g., [`push!`](@ref), [`pop!`](@ref), [`splice!`](@ref)).  It is typical for such functions to also return the modified array for convenience.
"""

# ╔═╡ a1d7494f-3e7c-4975-82ec-c69c0b5de3fe
md"""
## Avoid strange type `Union`s
"""

# ╔═╡ 166ddff8-5fd3-44a4-b3c2-126c917cf5f7
md"""
Types such as `Union{Function,AbstractString}` are often a sign that some design could be cleaner.
"""

# ╔═╡ f6200426-cd52-4c68-9ff6-978197813460
md"""
## Avoid elaborate container types
"""

# ╔═╡ 5ab4f42a-5c54-4b3c-9b33-072e353dff60
md"""
It is usually not much help to construct arrays like the following:
"""

# ╔═╡ df7407a6-ce7f-4890-936b-a15cd73fdb6c
md"""
```julia
a = Vector{Union{Int,AbstractString,Tuple,Array}}(undef, n)
```
"""

# ╔═╡ b0cc9edd-d538-492c-a3d8-91025146d375
md"""
In this case `Vector{Any}(undef, n)` is better. It is also more helpful to the compiler to annotate specific uses (e.g. `a[i]::Int`) than to try to pack many alternatives into one type.
"""

# ╔═╡ 9743208d-61af-4eff-835d-2129bf5f507b
md"""
## Use naming conventions consistent with Julia `base/`
"""

# ╔═╡ 110dd8d3-7ca6-4e36-96ec-816442fa7e14
md"""
  * modules and type names use capitalization and camel case: `module SparseArrays`, `struct UnitRange`.
  * functions are lowercase ([`maximum`](@ref), [`convert`](@ref)) and, when readable, with multiple words squashed together ([`isequal`](@ref), [`haskey`](@ref)). When necessary, use underscores as word separators. Underscores are also used to indicate a combination of concepts ([`remotecall_fetch`](@ref) as a more efficient implementation of `fetch(remotecall(...))`) or as modifiers.
  * conciseness is valued, but avoid abbreviation ([`indexin`](@ref) rather than `indxin`) as it becomes difficult to remember whether and how particular words are abbreviated.
"""

# ╔═╡ 1518e393-a902-45f1-97cf-bbda69cd8614
md"""
If a function name requires multiple words, consider whether it might represent more than one concept and might be better split into pieces.
"""

# ╔═╡ 5bf4c7e3-9e26-4a93-87d7-7d55186ebe87
md"""
## Write functions with argument ordering similar to Julia Base
"""

# ╔═╡ a94b16a4-0abc-406f-a0fc-fb3657bba746
md"""
As a general rule, the Base library uses the following order of arguments to functions, as applicable:
"""

# ╔═╡ 3cacb1ae-bb65-40dc-b780-50d0945e267b
md"""
1. **Function argument**. Putting a function argument first permits the use of [`do`](@ref) blocks for passing multiline anonymous functions.
2. **I/O stream**. Specifying the `IO` object first permits passing the function to functions such as [`sprint`](@ref), e.g. `sprint(show, x)`.
3. **Input being mutated**. For example, in [`fill!(x, v)`](@ref fill!), `x` is the object being mutated and it appears before the value to be inserted into `x`.
4. **Type**. Passing a type typically means that the output will have the given type. In [`parse(Int, \"1\")`](@ref parse), the type comes before the string to parse. There are many such examples where the type appears first, but it's useful to note that in [`read(io, String)`](@ref read), the `IO` argument appears before the type, which is in keeping with the order outlined here.
5. **Input not being mutated**. In `fill!(x, v)`, `v` is *not* being mutated and it comes after `x`.
6. **Key**. For associative collections, this is the key of the key-value pair(s). For other indexed collections, this is the index.
7. **Value**. For associative collections, this is the value of the key-value pair(s). In cases like [`fill!(x, v)`](@ref fill!), this is `v`.
8. **Everything else**. Any other arguments.
9. **Varargs**. This refers to arguments that can be listed indefinitely at the end of a function call. For example, in `Matrix{T}(undef, dims)`, the dimensions can be given as a [`Tuple`](@ref), e.g. `Matrix{T}(undef, (1,2))`, or as [`Vararg`](@ref)s, e.g. `Matrix{T}(undef, 1, 2)`.
10. **Keyword arguments**. In Julia keyword arguments have to come last anyway in function definitions; they're listed here for the sake of completeness.
"""

# ╔═╡ 438b4441-2f4f-447a-b6bd-504f13788887
md"""
The vast majority of functions will not take every kind of argument listed above; the numbers merely denote the precedence that should be used for any applicable arguments to a function.
"""

# ╔═╡ 06377d98-d15d-4db3-9ac8-74c310c36a71
md"""
There are of course a few exceptions. For example, in [`convert`](@ref), the type should always come first. In [`setindex!`](@ref), the value comes before the indices so that the indices can be provided as varargs.
"""

# ╔═╡ 1b67f5e9-babc-4718-95a8-5684dc44f175
md"""
When designing APIs, adhering to this general order as much as possible is likely to give users of your functions a more consistent experience.
"""

# ╔═╡ 53287b2b-5cd0-4db5-8b8c-b489d40fb20f
md"""
## Don't overuse try-catch
"""

# ╔═╡ 061ade46-657c-421a-8b52-97316d117be0
md"""
It is better to avoid errors than to rely on catching them.
"""

# ╔═╡ 93cc5694-35e2-4f08-955a-5d36a2647f99
md"""
## Don't parenthesize conditions
"""

# ╔═╡ 6f688cfa-4d64-48ed-b996-d9b89e95ea67
md"""
Julia doesn't require parens around conditions in `if` and `while`. Write:
"""

# ╔═╡ 4816dd3e-aefd-4ccf-aa09-b2169f85793e
md"""
```julia
if a == b
```
"""

# ╔═╡ 00701911-311f-424e-8009-cd853868c122
md"""
instead of:
"""

# ╔═╡ 626edb3b-6ce9-408e-ae89-5cac58a63a01
md"""
```julia
if (a == b)
```
"""

# ╔═╡ 7eac555a-b910-4a25-8f14-4ed5ff634b55
md"""
## Don't overuse `...`
"""

# ╔═╡ f05000d1-95b7-4d8d-bc60-bc737c7ec9af
md"""
Splicing function arguments can be addictive. Instead of `[a..., b...]`, use simply `[a; b]`, which already concatenates arrays. [`collect(a)`](@ref) is better than `[a...]`, but since `a` is already iterable it is often even better to leave it alone, and not convert it to an array.
"""

# ╔═╡ 0aec7ddc-5528-4916-a1cf-311c470d47b8
md"""
## Don't use unnecessary static parameters
"""

# ╔═╡ 0bb5bcf0-0410-47e1-9c7e-05f080c8847b
md"""
A function signature:
"""

# ╔═╡ a3f9fdb7-2d9e-46d0-8061-15a727cbca04
md"""
```julia
foo(x::T) where {T<:Real} = ...
```
"""

# ╔═╡ 1f97c59d-db1a-45c3-8c37-7921329da965
md"""
should be written as:
"""

# ╔═╡ a3b76fa8-6f34-4176-a6b4-91122603bdfb
md"""
```julia
foo(x::Real) = ...
```
"""

# ╔═╡ 24684ee0-1a89-4b50-a325-d9736434229c
md"""
instead, especially if `T` is not used in the function body. Even if `T` is used, it can be replaced with [`typeof(x)`](@ref) if convenient. There is no performance difference. Note that this is not a general caution against static parameters, just against uses where they are not needed.
"""

# ╔═╡ b6a4d90d-93e6-4a23-a0c7-5bb0ca958653
md"""
Note also that container types, specifically may need type parameters in function calls. See the FAQ [Avoid fields with abstract containers](@ref) for more information.
"""

# ╔═╡ d6004b46-e9af-4c0a-9ab4-6d00e15ad0c8
md"""
## Avoid confusion about whether something is an instance or a type
"""

# ╔═╡ 3cebae74-fdaa-4b67-b6f2-1dc901b834f8
md"""
Sets of definitions like the following are confusing:
"""

# ╔═╡ 1343abe6-48a3-4343-940e-d871ce3e6fb6
md"""
```julia
foo(::Type{MyType}) = ...
foo(::MyType) = foo(MyType)
```
"""

# ╔═╡ 1cc459b8-e287-43e9-a6d9-a47977607434
md"""
Decide whether the concept in question will be written as `MyType` or `MyType()`, and stick to it.
"""

# ╔═╡ 46db09fd-72c5-47de-85d3-4d19ea15195a
md"""
The preferred style is to use instances by default, and only add methods involving `Type{MyType}` later if they become necessary to solve some problems.
"""

# ╔═╡ 1d5920fb-45a7-4a30-a24b-7ffd862688eb
md"""
If a type is effectively an enumeration, it should be defined as a single (ideally immutable struct or primitive) type, with the enumeration values being instances of it. Constructors and conversions can check whether values are valid. This design is preferred over making the enumeration an abstract type, with the \"values\" as subtypes.
"""

# ╔═╡ bb3b6ac0-350d-4027-b18d-f56163e0adeb
md"""
## Don't overuse macros
"""

# ╔═╡ 0e6740d0-bca7-4a5e-8a87-ee2d2b0e8ff9
md"""
Be aware of when a macro could really be a function instead.
"""

# ╔═╡ 4968afa5-8a42-4242-bcf0-a359bd554005
md"""
Calling [`eval`](@ref) inside a macro is a particularly dangerous warning sign; it means the macro will only work when called at the top level. If such a macro is written as a function instead, it will naturally have access to the run-time values it needs.
"""

# ╔═╡ b48f6fc5-5679-41e2-b807-2228c3c31828
md"""
## Don't expose unsafe operations at the interface level
"""

# ╔═╡ 8476202a-34c9-42f2-95c2-269ca871c8c0
md"""
If you have a type that uses a native pointer:
"""

# ╔═╡ 3895a131-a323-4c37-9d81-940930d3243e
md"""
```julia
mutable struct NativeType
    p::Ptr{UInt8}
    ...
end
```
"""

# ╔═╡ 3f7c0c95-97e9-49d5-950f-93b4d79f61c4
md"""
don't write definitions like the following:
"""

# ╔═╡ aa0923f9-63a8-4498-a33b-2d8dff3af61d
md"""
```julia
getindex(x::NativeType, i) = unsafe_load(x.p, i)
```
"""

# ╔═╡ 435a16d4-2f18-48c4-8851-d6a37d878dcb
md"""
The problem is that users of this type can write `x[i]` without realizing that the operation is unsafe, and then be susceptible to memory bugs.
"""

# ╔═╡ a1d475c0-de8e-4230-b442-d48c15a905b2
md"""
Such a function should either check the operation to ensure it is safe, or have `unsafe` somewhere in its name to alert callers.
"""

# ╔═╡ 120c57c1-9ff4-4806-81be-4017c67181b9
md"""
## Don't overload methods of base container types
"""

# ╔═╡ b474f3d1-cc19-4e4f-90fc-244d68fcd07a
md"""
It is possible to write definitions like the following:
"""

# ╔═╡ fcb91be1-d1f1-49e2-80de-f0b0f2c9ddec
md"""
```julia
show(io::IO, v::Vector{MyType}) = ...
```
"""

# ╔═╡ 91cac9c4-64e9-44a2-a1f7-0a4bf03763c4
md"""
This would provide custom showing of vectors with a specific new element type. While tempting, this should be avoided. The trouble is that users will expect a well-known type like `Vector()` to behave in a certain way, and overly customizing its behavior can make it harder to work with.
"""

# ╔═╡ bafeb10c-1112-44d4-b10d-b80547bd74a3
md"""
## Avoid type piracy
"""

# ╔═╡ 3dcda412-ea56-4979-a91b-a6e571a0740e
md"""
\"Type piracy\" refers to the practice of extending or redefining methods in Base or other packages on types that you have not defined. In some cases, you can get away with type piracy with little ill effect. In extreme cases, however, you can even crash Julia (e.g. if your method extension or redefinition causes invalid input to be passed to a `ccall`). Type piracy can complicate reasoning about code, and may introduce incompatibilities that are hard to predict and diagnose.
"""

# ╔═╡ b136cc6c-e116-4395-aa1e-64d2c8037f01
md"""
As an example, suppose you wanted to define multiplication on symbols in a module:
"""

# ╔═╡ c38fb3ba-c06c-48a6-95dd-7e2022d13d5d
md"""
```julia
module A
import Base.*
*(x::Symbol, y::Symbol) = Symbol(x,y)
end
```
"""

# ╔═╡ 7450fe18-a63f-414e-9a06-5c8a69ce4d21
md"""
The problem is that now any other module that uses `Base.*` will also see this definition. Since `Symbol` is defined in Base and is used by other modules, this can change the behavior of unrelated code unexpectedly. There are several alternatives here, including using a different function name, or wrapping the `Symbol`s in another type that you define.
"""

# ╔═╡ 3f612b8c-0d7a-47bb-bb19-8d88fc09e65d
md"""
Sometimes, coupled packages may engage in type piracy to separate features from definitions, especially when the packages were designed by collaborating authors, and when the definitions are reusable. For example, one package might provide some types useful for working with colors; another package could define methods for those types that enable conversions between color spaces. Another example might be a package that acts as a thin wrapper for some C code, which another package might then pirate to implement a higher-level, Julia-friendly API.
"""

# ╔═╡ f2f2c0fe-9c29-4b54-b67f-bd02b791537a
md"""
## Be careful with type equality
"""

# ╔═╡ c75232ab-bf9a-4e86-8aeb-86ac237144f7
md"""
You generally want to use [`isa`](@ref) and [`<:`](@ref) for testing types, not `==`. Checking types for exact equality typically only makes sense when comparing to a known concrete type (e.g. `T == Float64`), or if you *really, really* know what you're doing.
"""

# ╔═╡ 003a3a33-9328-44a4-8452-63a6b250822c
md"""
## Do not write `x->f(x)`
"""

# ╔═╡ 5d905b7c-6c07-454d-84a2-3dd7051201ea
md"""
Since higher-order functions are often called with anonymous functions, it is easy to conclude that this is desirable or even necessary. But any function can be passed directly, without being \"wrapped\" in an anonymous function. Instead of writing `map(x->f(x), a)`, write [`map(f, a)`](@ref).
"""

# ╔═╡ d01574e8-c3d1-4ad6-aaa3-35a307e1a0de
md"""
## Avoid using floats for numeric literals in generic code when possible
"""

# ╔═╡ 2b75fa8e-ef76-438a-bb8b-9e38949c1fc4
md"""
If you write generic code which handles numbers, and which can be expected to run with many different numeric type arguments, try using literals of a numeric type that will affect the arguments as little as possible through promotion.
"""

# ╔═╡ 4df432ce-0b5d-4e5c-88be-8b07597050d5
md"""
For example,
"""

# ╔═╡ 3b13edea-491a-4f5e-9a75-ae37f8a43964
f(x) = 2.0 * x

# ╔═╡ 60ab27c7-13fc-4ae9-8767-af38ebfce5e2
f(1//2)

# ╔═╡ 8a91af63-5161-4cae-bcce-a8b8312ef104
f(1/2)

# ╔═╡ e74668d1-e851-474e-b89c-fb71d32bd2e6
f(1)

# ╔═╡ 1d5fe2ec-48fd-446a-989d-43a534d8740d
md"""
while
"""

# ╔═╡ 2f77fdb3-a438-429b-ab46-579d3c6751bd
g(x) = 2 * x

# ╔═╡ 97394605-aaaa-43cc-a432-0aa2982e65da
g(1//2)

# ╔═╡ c179099f-7ef3-47ce-85ec-f4c6d8ac7410
g(1/2)

# ╔═╡ 1ee5ba71-e167-413d-b3e4-bb49e918efe4
g(1)

# ╔═╡ 77374ce4-4bf7-4b6b-b933-b63f4c5524aa
md"""
As you can see, the second version, where we used an `Int` literal, preserved the type of the input argument, while the first didn't. This is because e.g. `promote_type(Int, Float64) == Float64`, and promotion happens with the multiplication. Similarly, [`Rational`](@ref) literals are less type disruptive than [`Float64`](@ref) literals, but more disruptive than `Int`s:
"""

# ╔═╡ 3cb6886c-f39e-4cdd-9cde-88c4e534e937
h(x) = 2//1 * x

# ╔═╡ 0ada0195-a6a6-42e4-8833-a8cd538714f7
h(1//2)

# ╔═╡ 9b71b43f-b922-43fb-abac-50eebfa715cb
h(1/2)

# ╔═╡ 2d506d29-12a2-4bca-b238-fdc1ea3aef80
h(1)

# ╔═╡ 1dea85e6-2261-4af6-bb53-d09b1acfa990
md"""
Thus, use `Int` literals when possible, with `Rational{Int}` for literal non-integer numbers, in order to make it easier to use your code.
"""

# ╔═╡ Cell order:
# ╟─2c542b0e-73b3-4cfc-a13b-1d2112946b2e
# ╟─d8c9936d-4b87-4ce1-9e52-3bfe413e3a5c
# ╟─801e96e2-4e85-45f7-a2ff-65878c45449e
# ╟─856ac9f8-ee7e-44bc-be12-da62ff58023f
# ╟─2f3cc511-23b5-49eb-a75f-a26fd4b8deca
# ╟─15d68018-252e-4dba-acf1-e4db08cffec7
# ╟─4b66bf53-bb76-4a13-a069-b0a7f1242d09
# ╟─f7e89dcb-6618-43fe-becd-fa99ab8f349d
# ╟─ddfb2448-0067-4548-9604-6999a98d5081
# ╟─32291f55-6e1f-4e41-acf9-3ba3e6ecb073
# ╟─13da56cf-7d7d-4999-91ff-aa19cc20a3ee
# ╟─d7702945-0ba9-4b7a-9e0f-3e13d1ac2a48
# ╟─ed1c5f7b-2401-45ed-bd1d-03a80af181a7
# ╟─24d072bf-c5af-4464-a035-5e8c294828c9
# ╟─b196d9d0-d3a2-496f-a4f7-4971513a2c78
# ╟─16487cf3-daea-422e-a08b-46fdd3d6360c
# ╟─8d40396c-f6a5-43b6-b66c-5e7469b9cdb6
# ╟─667a294a-aac9-4c87-be17-8f6d7c71b570
# ╟─cd639355-b7c2-4854-8ddf-5543290ecb96
# ╟─b9497ed0-3f6f-4f35-9043-366fbd3bf811
# ╟─47156372-e007-44f0-a64b-5e485d4ace7f
# ╟─619e451c-f9b4-429e-b871-0c22037a728e
# ╟─43c47de1-1bc9-44d3-85c7-6c45418d3616
# ╟─df903daf-245d-4794-b450-228061ccce35
# ╟─9b0cd14d-ac2f-4071-b393-57802bac949a
# ╟─7f53fd46-1dcb-479f-ace7-cd24e3997245
# ╟─4830d04c-b01e-4184-bf42-60d0c8dc951a
# ╟─0f3adcef-f05d-4df5-b5b1-0b88c564631e
# ╟─45bae830-9283-4bd5-8a71-68e2de47309e
# ╟─40dbc086-9c03-4d7c-9482-6321d4115605
# ╟─a1d7494f-3e7c-4975-82ec-c69c0b5de3fe
# ╟─166ddff8-5fd3-44a4-b3c2-126c917cf5f7
# ╟─f6200426-cd52-4c68-9ff6-978197813460
# ╟─5ab4f42a-5c54-4b3c-9b33-072e353dff60
# ╟─df7407a6-ce7f-4890-936b-a15cd73fdb6c
# ╟─b0cc9edd-d538-492c-a3d8-91025146d375
# ╟─9743208d-61af-4eff-835d-2129bf5f507b
# ╟─110dd8d3-7ca6-4e36-96ec-816442fa7e14
# ╟─1518e393-a902-45f1-97cf-bbda69cd8614
# ╟─5bf4c7e3-9e26-4a93-87d7-7d55186ebe87
# ╟─a94b16a4-0abc-406f-a0fc-fb3657bba746
# ╟─3cacb1ae-bb65-40dc-b780-50d0945e267b
# ╟─438b4441-2f4f-447a-b6bd-504f13788887
# ╟─06377d98-d15d-4db3-9ac8-74c310c36a71
# ╟─1b67f5e9-babc-4718-95a8-5684dc44f175
# ╟─53287b2b-5cd0-4db5-8b8c-b489d40fb20f
# ╟─061ade46-657c-421a-8b52-97316d117be0
# ╟─93cc5694-35e2-4f08-955a-5d36a2647f99
# ╟─6f688cfa-4d64-48ed-b996-d9b89e95ea67
# ╟─4816dd3e-aefd-4ccf-aa09-b2169f85793e
# ╟─00701911-311f-424e-8009-cd853868c122
# ╟─626edb3b-6ce9-408e-ae89-5cac58a63a01
# ╟─7eac555a-b910-4a25-8f14-4ed5ff634b55
# ╟─f05000d1-95b7-4d8d-bc60-bc737c7ec9af
# ╟─0aec7ddc-5528-4916-a1cf-311c470d47b8
# ╟─0bb5bcf0-0410-47e1-9c7e-05f080c8847b
# ╟─a3f9fdb7-2d9e-46d0-8061-15a727cbca04
# ╟─1f97c59d-db1a-45c3-8c37-7921329da965
# ╟─a3b76fa8-6f34-4176-a6b4-91122603bdfb
# ╟─24684ee0-1a89-4b50-a325-d9736434229c
# ╟─b6a4d90d-93e6-4a23-a0c7-5bb0ca958653
# ╟─d6004b46-e9af-4c0a-9ab4-6d00e15ad0c8
# ╟─3cebae74-fdaa-4b67-b6f2-1dc901b834f8
# ╟─1343abe6-48a3-4343-940e-d871ce3e6fb6
# ╟─1cc459b8-e287-43e9-a6d9-a47977607434
# ╟─46db09fd-72c5-47de-85d3-4d19ea15195a
# ╟─1d5920fb-45a7-4a30-a24b-7ffd862688eb
# ╟─bb3b6ac0-350d-4027-b18d-f56163e0adeb
# ╟─0e6740d0-bca7-4a5e-8a87-ee2d2b0e8ff9
# ╟─4968afa5-8a42-4242-bcf0-a359bd554005
# ╟─b48f6fc5-5679-41e2-b807-2228c3c31828
# ╟─8476202a-34c9-42f2-95c2-269ca871c8c0
# ╟─3895a131-a323-4c37-9d81-940930d3243e
# ╟─3f7c0c95-97e9-49d5-950f-93b4d79f61c4
# ╟─aa0923f9-63a8-4498-a33b-2d8dff3af61d
# ╟─435a16d4-2f18-48c4-8851-d6a37d878dcb
# ╟─a1d475c0-de8e-4230-b442-d48c15a905b2
# ╟─120c57c1-9ff4-4806-81be-4017c67181b9
# ╟─b474f3d1-cc19-4e4f-90fc-244d68fcd07a
# ╟─fcb91be1-d1f1-49e2-80de-f0b0f2c9ddec
# ╟─91cac9c4-64e9-44a2-a1f7-0a4bf03763c4
# ╟─bafeb10c-1112-44d4-b10d-b80547bd74a3
# ╟─3dcda412-ea56-4979-a91b-a6e571a0740e
# ╟─b136cc6c-e116-4395-aa1e-64d2c8037f01
# ╟─c38fb3ba-c06c-48a6-95dd-7e2022d13d5d
# ╟─7450fe18-a63f-414e-9a06-5c8a69ce4d21
# ╟─3f612b8c-0d7a-47bb-bb19-8d88fc09e65d
# ╟─f2f2c0fe-9c29-4b54-b67f-bd02b791537a
# ╟─c75232ab-bf9a-4e86-8aeb-86ac237144f7
# ╟─003a3a33-9328-44a4-8452-63a6b250822c
# ╟─5d905b7c-6c07-454d-84a2-3dd7051201ea
# ╟─d01574e8-c3d1-4ad6-aaa3-35a307e1a0de
# ╟─2b75fa8e-ef76-438a-bb8b-9e38949c1fc4
# ╟─4df432ce-0b5d-4e5c-88be-8b07597050d5
# ╠═3b13edea-491a-4f5e-9a75-ae37f8a43964
# ╠═60ab27c7-13fc-4ae9-8767-af38ebfce5e2
# ╠═8a91af63-5161-4cae-bcce-a8b8312ef104
# ╠═e74668d1-e851-474e-b89c-fb71d32bd2e6
# ╟─1d5fe2ec-48fd-446a-989d-43a534d8740d
# ╠═2f77fdb3-a438-429b-ab46-579d3c6751bd
# ╠═97394605-aaaa-43cc-a432-0aa2982e65da
# ╠═c179099f-7ef3-47ce-85ec-f4c6d8ac7410
# ╠═1ee5ba71-e167-413d-b3e4-bb49e918efe4
# ╟─77374ce4-4bf7-4b6b-b933-b63f4c5524aa
# ╠═3cb6886c-f39e-4cdd-9cde-88c4e534e937
# ╠═0ada0195-a6a6-42e4-8833-a8cd538714f7
# ╠═9b71b43f-b922-43fb-abac-50eebfa715cb
# ╠═2d506d29-12a2-4bca-b238-fdc1ea3aef80
# ╟─1dea85e6-2261-4af6-bb53-d09b1acfa990
