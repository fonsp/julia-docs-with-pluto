### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ 03d8188a-9e19-11eb-041c-c3fb955f8e69
md"""
# Style Guide
"""

# ╔═╡ 03d81ab0-9e19-11eb-0315-c379e35f7a5a
md"""
The following sections explain a few aspects of idiomatic Julia coding style. None of these rules are absolute; they are only suggestions to help familiarize you with the language and to help you choose among alternative designs.
"""

# ╔═╡ 03d81ad8-9e19-11eb-3eba-3124ef5535d2
md"""
## Indentation
"""

# ╔═╡ 03d81ae2-9e19-11eb-2173-25188b06260b
md"""
Use 4 spaces per indentation level.
"""

# ╔═╡ 03d81aec-9e19-11eb-30ab-71dc340bc16d
md"""
## Write functions, not just scripts
"""

# ╔═╡ 03d81b02-9e19-11eb-2e9b-eb77319cafb9
md"""
Writing code as a series of steps at the top level is a quick way to get started solving a problem, but you should try to divide a program into functions as soon as possible. Functions are more reusable and testable, and clarify what steps are being done and what their inputs and outputs are. Furthermore, code inside functions tends to run much faster than top level code, due to how Julia's compiler works.
"""

# ╔═╡ 03d81b28-9e19-11eb-0503-230cb8537d5b
md"""
It is also worth emphasizing that functions should take arguments, instead of operating directly on global variables (aside from constants like [`pi`](@ref)).
"""

# ╔═╡ 03d81b3c-9e19-11eb-2b71-53fc1d2d0e19
md"""
## Avoid writing overly-specific types
"""

# ╔═╡ 03d81b46-9e19-11eb-3f3b-b147559cb1be
md"""
Code should be as generic as possible. Instead of writing:
"""

# ╔═╡ 03d81b66-9e19-11eb-310f-75fe05e37af6
md"""
```julia
Complex{Float64}(x)
```
"""

# ╔═╡ 03d81b6e-9e19-11eb-3462-b1d6c720a203
md"""
it's better to use available generic functions:
"""

# ╔═╡ 03d81b82-9e19-11eb-3c51-1f2b34f3e2b8
md"""
```julia
complex(float(x))
```
"""

# ╔═╡ 03d81ba0-9e19-11eb-00cd-01291a403fad
md"""
The second version will convert `x` to an appropriate type, instead of always the same type.
"""

# ╔═╡ 03d81bdc-9e19-11eb-3057-bf574807c7dc
md"""
This style point is especially relevant to function arguments. For example, don't declare an argument to be of type `Int` or [`Int32`](@ref) if it really could be any integer, expressed with the abstract type [`Integer`](@ref). In fact, in many cases you can omit the argument type altogether, unless it is needed to disambiguate from other method definitions, since a [`MethodError`](@ref) will be thrown anyway if a type is passed that does not support any of the requisite operations. (This is known as [duck typing](https://en.wikipedia.org/wiki/Duck_typing).)
"""

# ╔═╡ 03d81be6-9e19-11eb-1993-bb7c99b46e24
md"""
For example, consider the following definitions of a function `addone` that returns one plus its argument:
"""

# ╔═╡ 03d81c04-9e19-11eb-3da0-75cae36c35d8
md"""
```julia
addone(x::Int) = x + 1                 # works only for Int
addone(x::Integer) = x + oneunit(x)    # any integer type
addone(x::Number) = x + oneunit(x)     # any numeric type
addone(x) = x + oneunit(x)             # any type supporting + and oneunit
```
"""

# ╔═╡ 03d81c40-9e19-11eb-37ff-9dff4667b08c
md"""
The last definition of `addone` handles any type supporting [`oneunit`](@ref) (which returns 1 in the same type as `x`, which avoids unwanted type promotion) and the [`+`](@ref) function with those arguments. The key thing to realize is that there is *no performance penalty* to defining *only* the general `addone(x) = x + oneunit(x)`, because Julia will automatically compile specialized versions as needed. For example, the first time you call `addone(12)`, Julia will automatically compile a specialized `addone` function for `x::Int` arguments, with the call to `oneunit` replaced by its inlined value `1`. Therefore, the first three definitions of `addone` above are completely redundant with the fourth definition.
"""

# ╔═╡ 03d81c4a-9e19-11eb-3852-4f554c57caaa
md"""
## Handle excess argument diversity in the caller
"""

# ╔═╡ 03d81c5e-9e19-11eb-2b37-b30e3c6a954f
md"""
Instead of:
"""

# ╔═╡ 03d81c72-9e19-11eb-3f77-e97a851d8d08
md"""
```julia
function foo(x, y)
    x = Int(x); y = Int(y)
    ...
end
foo(x, y)
```
"""

# ╔═╡ 03d81c7c-9e19-11eb-3871-3772f9ea4bda
md"""
use:
"""

# ╔═╡ 03d81c90-9e19-11eb-325f-756f1ff72d7d
md"""
```julia
function foo(x::Int, y::Int)
    ...
end
foo(Int(x), Int(y))
```
"""

# ╔═╡ 03d81cae-9e19-11eb-0f8c-e3a8264a5c48
md"""
This is better style because `foo` does not really accept numbers of all types; it really needs `Int` s.
"""

# ╔═╡ 03d81cb8-9e19-11eb-3d14-2d84eb8c676d
md"""
One issue here is that if a function inherently requires integers, it might be better to force the caller to decide how non-integers should be converted (e.g. floor or ceiling). Another issue is that declaring more specific types leaves more "space" for future method definitions.
"""

# ╔═╡ 03d81cd6-9e19-11eb-1078-add240e0138d
md"""
## [Append `!` to names of functions that modify their arguments](@id bang-convention)
"""

# ╔═╡ 03d81cf4-9e19-11eb-3e78-61e7c078fc98
md"""
Instead of:
"""

# ╔═╡ 03d81d08-9e19-11eb-241a-b3101c1f2ef1
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

# ╔═╡ 03d81d12-9e19-11eb-307c-d39d2cc2a3bd
md"""
use:
"""

# ╔═╡ 03d81d2e-9e19-11eb-0206-5dd408a631bb
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

# ╔═╡ 03d81d58-9e19-11eb-3f78-431536d4d99f
md"""
Julia Base uses this convention throughout and contains examples of functions with both copying and modifying forms (e.g., [`sort`](@ref) and [`sort!`](@ref)), and others which are just modifying (e.g., [`push!`](@ref), [`pop!`](@ref), [`splice!`](@ref)).  It is typical for such functions to also return the modified array for convenience.
"""

# ╔═╡ 03d81d6c-9e19-11eb-25d2-6568b003298f
md"""
## Avoid strange type `Union`s
"""

# ╔═╡ 03d81d8a-9e19-11eb-3aca-598418de19c0
md"""
Types such as `Union{Function,AbstractString}` are often a sign that some design could be cleaner.
"""

# ╔═╡ 03d81d94-9e19-11eb-253f-0db513605429
md"""
## Avoid elaborate container types
"""

# ╔═╡ 03d81d9e-9e19-11eb-0673-05dba70829ba
md"""
It is usually not much help to construct arrays like the following:
"""

# ╔═╡ 03d81db2-9e19-11eb-1a18-7b6b93322a84
md"""
```julia
a = Vector{Union{Int,AbstractString,Tuple,Array}}(undef, n)
```
"""

# ╔═╡ 03d81de4-9e19-11eb-3aa7-0bdf15b3c307
md"""
In this case `Vector{Any}(undef, n)` is better. It is also more helpful to the compiler to annotate specific uses (e.g. `a[i]::Int`) than to try to pack many alternatives into one type.
"""

# ╔═╡ 03d81df8-9e19-11eb-2e64-7dddbcb331a9
md"""
## Use naming conventions consistent with Julia `base/`
"""

# ╔═╡ 03d81ec0-9e19-11eb-3cb6-bd0e25e216ef
md"""
  * modules and type names use capitalization and camel case: `module SparseArrays`, `struct UnitRange`.
  * functions are lowercase ([`maximum`](@ref), [`convert`](@ref)) and, when readable, with multiple words squashed together ([`isequal`](@ref), [`haskey`](@ref)). When necessary, use underscores as word separators. Underscores are also used to indicate a combination of concepts ([`remotecall_fetch`](@ref) as a more efficient implementation of `fetch(remotecall(...))`) or as modifiers.
  * conciseness is valued, but avoid abbreviation ([`indexin`](@ref) rather than `indxin`) as it becomes difficult to remember whether and how particular words are abbreviated.
"""

# ╔═╡ 03d81ede-9e19-11eb-2b33-fd2f2a5c1fe9
md"""
If a function name requires multiple words, consider whether it might represent more than one concept and might be better split into pieces.
"""

# ╔═╡ 03d81ee8-9e19-11eb-26d0-734fbcf2d423
md"""
## Write functions with argument ordering similar to Julia Base
"""

# ╔═╡ 03d81efc-9e19-11eb-03c7-0b189fc12460
md"""
As a general rule, the Base library uses the following order of arguments to functions, as applicable:
"""

# ╔═╡ 03d82140-9e19-11eb-3a95-e1caf45813f5
md"""
1. **Function argument**. Putting a function argument first permits the use of [`do`](@ref) blocks for passing multiline anonymous functions.
2. **I/O stream**. Specifying the `IO` object first permits passing the function to functions such as [`sprint`](@ref), e.g. `sprint(show, x)`.
3. **Input being mutated**. For example, in [`fill!(x, v)`](@ref fill!), `x` is the object being mutated and it appears before the value to be inserted into `x`.
4. **Type**. Passing a type typically means that the output will have the given type. In [`parse(Int, "1")`](@ref parse), the type comes before the string to parse. There are many such examples where the type appears first, but it's useful to note that in [`read(io, String)`](@ref read), the `IO` argument appears before the type, which is in keeping with the order outlined here.
5. **Input not being mutated**. In `fill!(x, v)`, `v` is *not* being mutated and it comes after `x`.
6. **Key**. For associative collections, this is the key of the key-value pair(s). For other indexed collections, this is the index.
7. **Value**. For associative collections, this is the value of the key-value pair(s). In cases like [`fill!(x, v)`](@ref fill!), this is `v`.
8. **Everything else**. Any other arguments.
9. **Varargs**. This refers to arguments that can be listed indefinitely at the end of a function call. For example, in `Matrix{T}(undef, dims)`, the dimensions can be given as a [`Tuple`](@ref), e.g. `Matrix{T}(undef, (1,2))`, or as [`Vararg`](@ref)s, e.g. `Matrix{T}(undef, 1, 2)`.
10. **Keyword arguments**. In Julia keyword arguments have to come last anyway in function definitions; they're listed here for the sake of completeness.
"""

# ╔═╡ 03d8215e-9e19-11eb-3b2e-95cd53755ad1
md"""
The vast majority of functions will not take every kind of argument listed above; the numbers merely denote the precedence that should be used for any applicable arguments to a function.
"""

# ╔═╡ 03d8217c-9e19-11eb-32d6-89bd9ee14899
md"""
There are of course a few exceptions. For example, in [`convert`](@ref), the type should always come first. In [`setindex!`](@ref), the value comes before the indices so that the indices can be provided as varargs.
"""

# ╔═╡ 03d82190-9e19-11eb-2988-b308c8297101
md"""
When designing APIs, adhering to this general order as much as possible is likely to give users of your functions a more consistent experience.
"""

# ╔═╡ 03d821a4-9e19-11eb-2f30-1704cee3affd
md"""
## Don't overuse try-catch
"""

# ╔═╡ 03d821ae-9e19-11eb-22c1-21c7d5919fbd
md"""
It is better to avoid errors than to rely on catching them.
"""

# ╔═╡ 03d821c2-9e19-11eb-3303-dda88b12b387
md"""
## Don't parenthesize conditions
"""

# ╔═╡ 03d821d6-9e19-11eb-286e-9d381c90e3fd
md"""
Julia doesn't require parens around conditions in `if` and `while`. Write:
"""

# ╔═╡ 03d821ea-9e19-11eb-0972-a98140955dd9
md"""
```julia
if a == b
```
"""

# ╔═╡ 03d821f4-9e19-11eb-3f80-d999c649a9bf
md"""
instead of:
"""

# ╔═╡ 03d82212-9e19-11eb-3a6a-1bba19f2d489
md"""
```julia
if (a == b)
```
"""

# ╔═╡ 03d82226-9e19-11eb-1dc5-f31fa1dfc810
md"""
## Don't overuse `...`
"""

# ╔═╡ 03d82244-9e19-11eb-3406-afa2b7653ade
md"""
Splicing function arguments can be addictive. Instead of `[a..., b...]`, use simply `[a; b]`, which already concatenates arrays. [`collect(a)`](@ref) is better than `[a...]`, but since `a` is already iterable it is often even better to leave it alone, and not convert it to an array.
"""

# ╔═╡ 03d8226a-9e19-11eb-2481-67a73d8997df
md"""
## Don't use unnecessary static parameters
"""

# ╔═╡ 03d82276-9e19-11eb-0616-c549786306eb
md"""
A function signature:
"""

# ╔═╡ 03d82280-9e19-11eb-03d3-9b15c28d11ca
md"""
```julia
foo(x::T) where {T<:Real} = ...
```
"""

# ╔═╡ 03d8229c-9e19-11eb-32d8-0143e681c827
md"""
should be written as:
"""

# ╔═╡ 03d822b2-9e19-11eb-389f-c182f4b723a7
md"""
```julia
foo(x::Real) = ...
```
"""

# ╔═╡ 03d822ce-9e19-11eb-0a11-a904bbb2e3c0
md"""
instead, especially if `T` is not used in the function body. Even if `T` is used, it can be replaced with [`typeof(x)`](@ref) if convenient. There is no performance difference. Note that this is not a general caution against static parameters, just against uses where they are not needed.
"""

# ╔═╡ 03d822e4-9e19-11eb-1492-17817064247a
md"""
Note also that container types, specifically may need type parameters in function calls. See the FAQ [Avoid fields with abstract containers](@ref) for more information.
"""

# ╔═╡ 03d822f8-9e19-11eb-0d32-fdf49a35dfb4
md"""
## Avoid confusion about whether something is an instance or a type
"""

# ╔═╡ 03d82302-9e19-11eb-0342-ebd8d6fb8d7b
md"""
Sets of definitions like the following are confusing:
"""

# ╔═╡ 03d82320-9e19-11eb-15fc-85ecdf935152
md"""
```julia
foo(::Type{MyType}) = ...
foo(::MyType) = foo(MyType)
```
"""

# ╔═╡ 03d82334-9e19-11eb-04dc-09dc25406cf9
md"""
Decide whether the concept in question will be written as `MyType` or `MyType()`, and stick to it.
"""

# ╔═╡ 03d82348-9e19-11eb-3609-cd1bd71606b9
md"""
The preferred style is to use instances by default, and only add methods involving `Type{MyType}` later if they become necessary to solve some problems.
"""

# ╔═╡ 03d8235c-9e19-11eb-058a-9f1e1f76e8c9
md"""
If a type is effectively an enumeration, it should be defined as a single (ideally immutable struct or primitive) type, with the enumeration values being instances of it. Constructors and conversions can check whether values are valid. This design is preferred over making the enumeration an abstract type, with the "values" as subtypes.
"""

# ╔═╡ 03d82372-9e19-11eb-2d8c-fd88026a6a06
md"""
## Don't overuse macros
"""

# ╔═╡ 03d8237a-9e19-11eb-3d47-1d519818dd8b
md"""
Be aware of when a macro could really be a function instead.
"""

# ╔═╡ 03d8238e-9e19-11eb-00ca-c54707dda8ea
md"""
Calling [`eval`](@ref) inside a macro is a particularly dangerous warning sign; it means the macro will only work when called at the top level. If such a macro is written as a function instead, it will naturally have access to the run-time values it needs.
"""

# ╔═╡ 03d823ac-9e19-11eb-1316-6147abf1ed07
md"""
## Don't expose unsafe operations at the interface level
"""

# ╔═╡ 03d823b6-9e19-11eb-0fac-35f0cf7b0bbb
md"""
If you have a type that uses a native pointer:
"""

# ╔═╡ 03d823ca-9e19-11eb-222e-47297ca184e9
md"""
```julia
mutable struct NativeType
    p::Ptr{UInt8}
    ...
end
```
"""

# ╔═╡ 03d823de-9e19-11eb-0bbd-d3109bd0b37a
md"""
don't write definitions like the following:
"""

# ╔═╡ 03d823e8-9e19-11eb-1b95-e5bc5c98bb02
md"""
```julia
getindex(x::NativeType, i) = unsafe_load(x.p, i)
```
"""

# ╔═╡ 03d823fc-9e19-11eb-035d-73d69168bd1f
md"""
The problem is that users of this type can write `x[i]` without realizing that the operation is unsafe, and then be susceptible to memory bugs.
"""

# ╔═╡ 03d8244c-9e19-11eb-2286-e51dd16b8adc
md"""
Such a function should either check the operation to ensure it is safe, or have `unsafe` somewhere in its name to alert callers.
"""

# ╔═╡ 03d82456-9e19-11eb-30f0-43012595d674
md"""
## Don't overload methods of base container types
"""

# ╔═╡ 03d82460-9e19-11eb-23b7-95abf6587ceb
md"""
It is possible to write definitions like the following:
"""

# ╔═╡ 03d8247e-9e19-11eb-132c-41337cddb1b8
md"""
```julia
show(io::IO, v::Vector{MyType}) = ...
```
"""

# ╔═╡ 03d82492-9e19-11eb-2a91-5b7a98509674
md"""
This would provide custom showing of vectors with a specific new element type. While tempting, this should be avoided. The trouble is that users will expect a well-known type like `Vector()` to behave in a certain way, and overly customizing its behavior can make it harder to work with.
"""

# ╔═╡ 03d8249c-9e19-11eb-0d11-734fbfb1877e
md"""
## Avoid type piracy
"""

# ╔═╡ 03d824b0-9e19-11eb-1951-f1d7131ddc9c
md"""
"Type piracy" refers to the practice of extending or redefining methods in Base or other packages on types that you have not defined. In some cases, you can get away with type piracy with little ill effect. In extreme cases, however, you can even crash Julia (e.g. if your method extension or redefinition causes invalid input to be passed to a `ccall`). Type piracy can complicate reasoning about code, and may introduce incompatibilities that are hard to predict and diagnose.
"""

# ╔═╡ 03d824c4-9e19-11eb-2328-573f12962586
md"""
As an example, suppose you wanted to define multiplication on symbols in a module:
"""

# ╔═╡ 03d824e2-9e19-11eb-2d4d-df170634fb6a
md"""
```julia
module A
import Base.*
*(x::Symbol, y::Symbol) = Symbol(x,y)
end
```
"""

# ╔═╡ 03d824f6-9e19-11eb-29c4-b72a520c050d
md"""
The problem is that now any other module that uses `Base.*` will also see this definition. Since `Symbol` is defined in Base and is used by other modules, this can change the behavior of unrelated code unexpectedly. There are several alternatives here, including using a different function name, or wrapping the `Symbol`s in another type that you define.
"""

# ╔═╡ 03d82514-9e19-11eb-3bb1-ab68719f4e24
md"""
Sometimes, coupled packages may engage in type piracy to separate features from definitions, especially when the packages were designed by collaborating authors, and when the definitions are reusable. For example, one package might provide some types useful for working with colors; another package could define methods for those types that enable conversions between color spaces. Another example might be a package that acts as a thin wrapper for some C code, which another package might then pirate to implement a higher-level, Julia-friendly API.
"""

# ╔═╡ 03d82528-9e19-11eb-3d57-5567d6f438fd
md"""
## Be careful with type equality
"""

# ╔═╡ 03d82550-9e19-11eb-2b82-29f2fa64f0b2
md"""
You generally want to use [`isa`](@ref) and [`<:`](@ref) for testing types, not `==`. Checking types for exact equality typically only makes sense when comparing to a known concrete type (e.g. `T == Float64`), or if you *really, really* know what you're doing.
"""

# ╔═╡ 03d8256c-9e19-11eb-304f-a73017c8e074
md"""
## Do not write `x->f(x)`
"""

# ╔═╡ 03d82582-9e19-11eb-0e64-9fc3ac20b81b
md"""
Since higher-order functions are often called with anonymous functions, it is easy to conclude that this is desirable or even necessary. But any function can be passed directly, without being "wrapped" in an anonymous function. Instead of writing `map(x->f(x), a)`, write [`map(f, a)`](@ref).
"""

# ╔═╡ 03d82596-9e19-11eb-3d43-a5ae3a9fa107
md"""
## Avoid using floats for numeric literals in generic code when possible
"""

# ╔═╡ 03d825aa-9e19-11eb-1eee-f36900f864b7
md"""
If you write generic code which handles numbers, and which can be expected to run with many different numeric type arguments, try using literals of a numeric type that will affect the arguments as little as possible through promotion.
"""

# ╔═╡ 03d825b4-9e19-11eb-1298-79e571565c58
md"""
For example,
"""

# ╔═╡ 03d82bb0-9e19-11eb-0e96-e91aca2a1c9e
f(x) = 2.0 * x

# ╔═╡ 03d82bb8-9e19-11eb-236d-d149e1cf9c24
f(1//2)

# ╔═╡ 03d82bb8-9e19-11eb-0313-edd597426030
f(1/2)

# ╔═╡ 03d82bcc-9e19-11eb-35dd-73d425416fb2
f(1)

# ╔═╡ 03d82be2-9e19-11eb-220b-230ac7b3ce67
md"""
while
"""

# ╔═╡ 03d83144-9e19-11eb-0fce-9114b391fed8
g(x) = 2 * x

# ╔═╡ 03d83144-9e19-11eb-0827-bb10b031b238
g(1//2)

# ╔═╡ 03d83158-9e19-11eb-150e-71514dd35927
g(1/2)

# ╔═╡ 03d83162-9e19-11eb-0671-e39d398e5a94
g(1)

# ╔═╡ 03d83194-9e19-11eb-2d87-8732818e23a9
md"""
As you can see, the second version, where we used an `Int` literal, preserved the type of the input argument, while the first didn't. This is because e.g. `promote_type(Int, Float64) == Float64`, and promotion happens with the multiplication. Similarly, [`Rational`](@ref) literals are less type disruptive than [`Float64`](@ref) literals, but more disruptive than `Int`s:
"""

# ╔═╡ 03d83750-9e19-11eb-1445-c170ffa40d1d
h(x) = 2//1 * x

# ╔═╡ 03d83766-9e19-11eb-1859-73b92afa331a
h(1//2)

# ╔═╡ 03d83766-9e19-11eb-3663-7d3de191add0
h(1/2)

# ╔═╡ 03d83770-9e19-11eb-3281-8f8067b30f9d
h(1)

# ╔═╡ 03d8378e-9e19-11eb-2e2f-77decae1b1c7
md"""
Thus, use `Int` literals when possible, with `Rational{Int}` for literal non-integer numbers, in order to make it easier to use your code.
"""

# ╔═╡ Cell order:
# ╟─03d8188a-9e19-11eb-041c-c3fb955f8e69
# ╟─03d81ab0-9e19-11eb-0315-c379e35f7a5a
# ╟─03d81ad8-9e19-11eb-3eba-3124ef5535d2
# ╟─03d81ae2-9e19-11eb-2173-25188b06260b
# ╟─03d81aec-9e19-11eb-30ab-71dc340bc16d
# ╟─03d81b02-9e19-11eb-2e9b-eb77319cafb9
# ╟─03d81b28-9e19-11eb-0503-230cb8537d5b
# ╟─03d81b3c-9e19-11eb-2b71-53fc1d2d0e19
# ╟─03d81b46-9e19-11eb-3f3b-b147559cb1be
# ╟─03d81b66-9e19-11eb-310f-75fe05e37af6
# ╟─03d81b6e-9e19-11eb-3462-b1d6c720a203
# ╟─03d81b82-9e19-11eb-3c51-1f2b34f3e2b8
# ╟─03d81ba0-9e19-11eb-00cd-01291a403fad
# ╟─03d81bdc-9e19-11eb-3057-bf574807c7dc
# ╟─03d81be6-9e19-11eb-1993-bb7c99b46e24
# ╟─03d81c04-9e19-11eb-3da0-75cae36c35d8
# ╟─03d81c40-9e19-11eb-37ff-9dff4667b08c
# ╟─03d81c4a-9e19-11eb-3852-4f554c57caaa
# ╟─03d81c5e-9e19-11eb-2b37-b30e3c6a954f
# ╟─03d81c72-9e19-11eb-3f77-e97a851d8d08
# ╟─03d81c7c-9e19-11eb-3871-3772f9ea4bda
# ╟─03d81c90-9e19-11eb-325f-756f1ff72d7d
# ╟─03d81cae-9e19-11eb-0f8c-e3a8264a5c48
# ╟─03d81cb8-9e19-11eb-3d14-2d84eb8c676d
# ╟─03d81cd6-9e19-11eb-1078-add240e0138d
# ╟─03d81cf4-9e19-11eb-3e78-61e7c078fc98
# ╟─03d81d08-9e19-11eb-241a-b3101c1f2ef1
# ╟─03d81d12-9e19-11eb-307c-d39d2cc2a3bd
# ╟─03d81d2e-9e19-11eb-0206-5dd408a631bb
# ╟─03d81d58-9e19-11eb-3f78-431536d4d99f
# ╟─03d81d6c-9e19-11eb-25d2-6568b003298f
# ╟─03d81d8a-9e19-11eb-3aca-598418de19c0
# ╟─03d81d94-9e19-11eb-253f-0db513605429
# ╟─03d81d9e-9e19-11eb-0673-05dba70829ba
# ╟─03d81db2-9e19-11eb-1a18-7b6b93322a84
# ╟─03d81de4-9e19-11eb-3aa7-0bdf15b3c307
# ╟─03d81df8-9e19-11eb-2e64-7dddbcb331a9
# ╟─03d81ec0-9e19-11eb-3cb6-bd0e25e216ef
# ╟─03d81ede-9e19-11eb-2b33-fd2f2a5c1fe9
# ╟─03d81ee8-9e19-11eb-26d0-734fbcf2d423
# ╟─03d81efc-9e19-11eb-03c7-0b189fc12460
# ╟─03d82140-9e19-11eb-3a95-e1caf45813f5
# ╟─03d8215e-9e19-11eb-3b2e-95cd53755ad1
# ╟─03d8217c-9e19-11eb-32d6-89bd9ee14899
# ╟─03d82190-9e19-11eb-2988-b308c8297101
# ╟─03d821a4-9e19-11eb-2f30-1704cee3affd
# ╟─03d821ae-9e19-11eb-22c1-21c7d5919fbd
# ╟─03d821c2-9e19-11eb-3303-dda88b12b387
# ╟─03d821d6-9e19-11eb-286e-9d381c90e3fd
# ╟─03d821ea-9e19-11eb-0972-a98140955dd9
# ╟─03d821f4-9e19-11eb-3f80-d999c649a9bf
# ╟─03d82212-9e19-11eb-3a6a-1bba19f2d489
# ╟─03d82226-9e19-11eb-1dc5-f31fa1dfc810
# ╟─03d82244-9e19-11eb-3406-afa2b7653ade
# ╟─03d8226a-9e19-11eb-2481-67a73d8997df
# ╟─03d82276-9e19-11eb-0616-c549786306eb
# ╟─03d82280-9e19-11eb-03d3-9b15c28d11ca
# ╟─03d8229c-9e19-11eb-32d8-0143e681c827
# ╟─03d822b2-9e19-11eb-389f-c182f4b723a7
# ╟─03d822ce-9e19-11eb-0a11-a904bbb2e3c0
# ╟─03d822e4-9e19-11eb-1492-17817064247a
# ╟─03d822f8-9e19-11eb-0d32-fdf49a35dfb4
# ╟─03d82302-9e19-11eb-0342-ebd8d6fb8d7b
# ╟─03d82320-9e19-11eb-15fc-85ecdf935152
# ╟─03d82334-9e19-11eb-04dc-09dc25406cf9
# ╟─03d82348-9e19-11eb-3609-cd1bd71606b9
# ╟─03d8235c-9e19-11eb-058a-9f1e1f76e8c9
# ╟─03d82372-9e19-11eb-2d8c-fd88026a6a06
# ╟─03d8237a-9e19-11eb-3d47-1d519818dd8b
# ╟─03d8238e-9e19-11eb-00ca-c54707dda8ea
# ╟─03d823ac-9e19-11eb-1316-6147abf1ed07
# ╟─03d823b6-9e19-11eb-0fac-35f0cf7b0bbb
# ╟─03d823ca-9e19-11eb-222e-47297ca184e9
# ╟─03d823de-9e19-11eb-0bbd-d3109bd0b37a
# ╟─03d823e8-9e19-11eb-1b95-e5bc5c98bb02
# ╟─03d823fc-9e19-11eb-035d-73d69168bd1f
# ╟─03d8244c-9e19-11eb-2286-e51dd16b8adc
# ╟─03d82456-9e19-11eb-30f0-43012595d674
# ╟─03d82460-9e19-11eb-23b7-95abf6587ceb
# ╟─03d8247e-9e19-11eb-132c-41337cddb1b8
# ╟─03d82492-9e19-11eb-2a91-5b7a98509674
# ╟─03d8249c-9e19-11eb-0d11-734fbfb1877e
# ╟─03d824b0-9e19-11eb-1951-f1d7131ddc9c
# ╟─03d824c4-9e19-11eb-2328-573f12962586
# ╟─03d824e2-9e19-11eb-2d4d-df170634fb6a
# ╟─03d824f6-9e19-11eb-29c4-b72a520c050d
# ╟─03d82514-9e19-11eb-3bb1-ab68719f4e24
# ╟─03d82528-9e19-11eb-3d57-5567d6f438fd
# ╟─03d82550-9e19-11eb-2b82-29f2fa64f0b2
# ╟─03d8256c-9e19-11eb-304f-a73017c8e074
# ╟─03d82582-9e19-11eb-0e64-9fc3ac20b81b
# ╟─03d82596-9e19-11eb-3d43-a5ae3a9fa107
# ╟─03d825aa-9e19-11eb-1eee-f36900f864b7
# ╟─03d825b4-9e19-11eb-1298-79e571565c58
# ╠═03d82bb0-9e19-11eb-0e96-e91aca2a1c9e
# ╠═03d82bb8-9e19-11eb-236d-d149e1cf9c24
# ╠═03d82bb8-9e19-11eb-0313-edd597426030
# ╠═03d82bcc-9e19-11eb-35dd-73d425416fb2
# ╟─03d82be2-9e19-11eb-220b-230ac7b3ce67
# ╠═03d83144-9e19-11eb-0fce-9114b391fed8
# ╠═03d83144-9e19-11eb-0827-bb10b031b238
# ╠═03d83158-9e19-11eb-150e-71514dd35927
# ╠═03d83162-9e19-11eb-0671-e39d398e5a94
# ╟─03d83194-9e19-11eb-2d87-8732818e23a9
# ╠═03d83750-9e19-11eb-1445-c170ffa40d1d
# ╠═03d83766-9e19-11eb-1859-73b92afa331a
# ╠═03d83766-9e19-11eb-3663-7d3de191add0
# ╠═03d83770-9e19-11eb-3281-8f8067b30f9d
# ╟─03d8378e-9e19-11eb-2e2f-77decae1b1c7
