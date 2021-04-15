### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ 03bf8784-9e19-11eb-377c-ed436cdc225c
md"""
# [Conversion and Promotion](@id conversion-and-promotion)
"""

# ╔═╡ 03bf88c4-9e19-11eb-1c49-c5463c2b64c0
md"""
Julia has a system for promoting arguments of mathematical operators to a common type, which has been mentioned in various other sections, including [Integers and Floating-Point Numbers](@ref), [Mathematical Operations and Elementary Functions](@ref), [Types](@ref man-types), and [Methods](@ref). In this section, we explain how this promotion system works, as well as how to extend it to new types and apply it to functions besides built-in mathematical operators. Traditionally, programming languages fall into two camps with respect to promotion of arithmetic arguments:
"""

# ╔═╡ 03bf8d58-9e19-11eb-3468-b7ac5364b75a
md"""
  * **Automatic promotion for built-in arithmetic types and operators.** In most languages, built-in numeric types, when used as operands to arithmetic operators with infix syntax, such as `+`, `-`, `*`, and `/`, are automatically promoted to a common type to produce the expected results. C, Java, Perl, and Python, to name a few, all correctly compute the sum `1 + 1.5` as the floating-point value `2.5`, even though one of the operands to `+` is an integer. These systems are convenient and designed carefully enough that they are generally all-but-invisible to the programmer: hardly anyone consciously thinks of this promotion taking place when writing such an expression, but compilers and interpreters must perform conversion before addition since integers and floating-point values cannot be added as-is. Complex rules for such automatic conversions are thus inevitably part of specifications and implementations for such languages.
  * **No automatic promotion.** This camp includes Ada and ML – very "strict" statically typed languages. In these languages, every conversion must be explicitly specified by the programmer. Thus, the example expression `1 + 1.5` would be a compilation error in both Ada and ML. Instead one must write `real(1) + 1.5`, explicitly converting the integer `1` to a floating-point value before performing addition. Explicit conversion everywhere is so inconvenient, however, that even Ada has some degree of automatic conversion: integer literals are promoted to the expected integer type automatically, and floating-point literals are similarly promoted to appropriate floating-point types.
"""

# ╔═╡ 03bf8df6-9e19-11eb-16c7-b1159ffe5631
md"""
In a sense, Julia falls into the "no automatic promotion" category: mathematical operators are just functions with special syntax, and the arguments of functions are never automatically converted. However, one may observe that applying mathematical operations to a wide variety of mixed argument types is just an extreme case of polymorphic multiple dispatch – something which Julia's dispatch and type systems are particularly well-suited to handle. "Automatic" promotion of mathematical operands simply emerges as a special application: Julia comes with pre-defined catch-all dispatch rules for mathematical operators, invoked when no specific implementation exists for some combination of operand types. These catch-all rules first promote all operands to a common type using user-definable promotion rules, and then invoke a specialized implementation of the operator in question for the resulting values, now of the same type. User-defined types can easily participate in this promotion system by defining methods for conversion to and from other types, and providing a handful of promotion rules defining what types they should promote to when mixed with other types.
"""

# ╔═╡ 03bf8e46-9e19-11eb-2621-b706ec596cc5
md"""
## Conversion
"""

# ╔═╡ 03bf8eaa-9e19-11eb-0660-e921d49b0315
md"""
The standard way to obtain a value of a certain type `T` is to call the type's constructor, `T(x)`. However, there are cases where it's convenient to convert a value from one type to another without the programmer asking for it explicitly. One example is assigning a value into an array: if `A` is a `Vector{Float64}`, the expression `A[1] = 2` should work by automatically converting the `2` from `Int` to `Float64`, and storing the result in the array. This is done via the [`convert`](@ref) function.
"""

# ╔═╡ 03bf8ec8-9e19-11eb-0abb-7f49229e76bf
md"""
The `convert` function generally takes two arguments: the first is a type object and the second is a value to convert to that type. The returned value is the value converted to an instance of given type. The simplest way to understand this function is to see it in action:
"""

# ╔═╡ 03bfa62e-9e19-11eb-14a4-e5142e2763c8
x = 12

# ╔═╡ 03bfa656-9e19-11eb-24ba-33394d4e5267
typeof(x)

# ╔═╡ 03bfa656-9e19-11eb-02ba-05ef20b5bdab
xu = convert(UInt8, x)

# ╔═╡ 03bfa660-9e19-11eb-34fe-138522e50a59
typeof(xu)

# ╔═╡ 03bfa6b0-9e19-11eb-190d-e9372eff8d22
xf = convert(AbstractFloat, x)

# ╔═╡ 03bfa6b0-9e19-11eb-3317-6bda08fc4c81
typeof(xf)

# ╔═╡ 03bfa6ba-9e19-11eb-16bc-571fd682e9d2
a = Any[1 2 3; 4 5 6]

# ╔═╡ 03bfa6ba-9e19-11eb-303e-1f6f523561c9
convert(Array{Float64}, a)

# ╔═╡ 03bfa77a-9e19-11eb-3453-5f03aaa4d8dc
md"""
Conversion isn't always possible, in which case a [`MethodError`](@ref) is thrown indicating that `convert` doesn't know how to perform the requested conversion:
"""

# ╔═╡ 03bfab80-9e19-11eb-338b-ad6541ff025f
convert(AbstractFloat, "foo")

# ╔═╡ 03bfae3a-9e19-11eb-0e1c-7b3a69d1f6bd
md"""
Some languages consider parsing strings as numbers or formatting numbers as strings to be conversions (many dynamic languages will even perform conversion for you automatically). This is not the case in Julia. Even though some strings can be parsed as numbers, most strings are not valid representations of numbers, and only a very limited subset of them are. Therefore in Julia the dedicated [`parse`](@ref) function must be used to perform this operation, making it more explicit.
"""

# ╔═╡ 03bfaea8-9e19-11eb-3d7c-21f70112436b
md"""
### When is `convert` called?
"""

# ╔═╡ 03bfaed0-9e19-11eb-2eda-d792e20f5714
md"""
The following language constructs call `convert`:
"""

# ╔═╡ 03bfb790-9e19-11eb-202a-43ee05b65157
md"""
  * Assigning to an array converts to the array's element type.
  * Assigning to a field of an object converts to the declared type of the field.
  * Constructing an object with [`new`](@ref) converts to the object's declared field types.
  * Assigning to a variable with a declared type (e.g. `local x::T`) converts to that type.
  * A function with a declared return type converts its return value to that type.
  * Passing a value to [`ccall`](@ref) converts it to the corresponding argument type.
"""

# ╔═╡ 03bfb856-9e19-11eb-3699-35031ef3d66e
md"""
### Conversion vs. Construction
"""

# ╔═╡ 03bfb984-9e19-11eb-081e-fb9a624a464d
md"""
Note that the behavior of `convert(T, x)` appears to be nearly identical to `T(x)`. Indeed, it usually is. However, there is a key semantic difference: since `convert` can be called implicitly, its methods are restricted to cases that are considered "safe" or "unsurprising". `convert` will only convert between types that represent the same basic kind of thing (e.g. different representations of numbers, or different string encodings). It is also usually lossless; converting a value to a different type and back again should result in the exact same value.
"""

# ╔═╡ 03bfb9d4-9e19-11eb-36e6-fbcd7a558823
md"""
There are four general kinds of cases where constructors differ from `convert`:
"""

# ╔═╡ 03bfba24-9e19-11eb-1e1b-bbac97651e24
md"""
#### Constructors for types unrelated to their arguments
"""

# ╔═╡ 03bfba42-9e19-11eb-3767-9729ce4a479f
md"""
Some constructors don't implement the concept of "conversion". For example, `Timer(2)` creates a 2-second timer, which is not really a "conversion" from an integer to a timer.
"""

# ╔═╡ 03bfba7e-9e19-11eb-2fbf-115d996ead53
md"""
#### Mutable collections
"""

# ╔═╡ 03bfbac6-9e19-11eb-0fce-7bea489ac133
md"""
`convert(T, x)` is expected to return the original `x` if `x` is already of type `T`. In contrast, if `T` is a mutable collection type then `T(x)` should always make a new collection (copying elements from `x`).
"""

# ╔═╡ 03bfbace-9e19-11eb-3c33-e3373bb76b8e
md"""
#### Wrapper types
"""

# ╔═╡ 03bfbb00-9e19-11eb-34f9-496d08ccbc0f
md"""
For some types which "wrap" other values, the constructor may wrap its argument inside a new object even if it is already of the requested type. For example `Some(x)` wraps `x` to indicate that a value is present (in a context where the result might be a `Some` or `nothing`). However, `x` itself might be the object `Some(y)`, in which case the result is `Some(Some(y))`, with two levels of wrapping. `convert(Some, x)`, on the other hand, would just return `x` since it is already a `Some`.
"""

# ╔═╡ 03bfbb14-9e19-11eb-0f80-7183a49f0035
md"""
#### Constructors that don't return instances of their own type
"""

# ╔═╡ 03bfbb58-9e19-11eb-3d52-677ef1f6a74b
md"""
In *very rare* cases it might make sense for the constructor `T(x)` to return an object not of type `T`. This could happen if a wrapper type is its own inverse (e.g. `Flip(Flip(x)) === x`), or to support an old calling syntax for backwards compatibility when a library is restructured. But `convert(T, x)` should always return a value of type `T`.
"""

# ╔═╡ 03bfbb78-9e19-11eb-33f3-ddd76a4e9391
md"""
### Defining New Conversions
"""

# ╔═╡ 03bfbb8c-9e19-11eb-194c-c95d8108c1bb
md"""
When defining a new type, initially all ways of creating it should be defined as constructors. If it becomes clear that implicit conversion would be useful, and that some constructors meet the above "safety" criteria, then `convert` methods can be added. These methods are typically quite simple, as they only need to call the appropriate constructor. Such a definition might look like this:
"""

# ╔═╡ 03bfbbdc-9e19-11eb-29b1-290baae97ac5
md"""
```julia
convert(::Type{MyType}, x) = MyType(x)
```
"""

# ╔═╡ 03bfbc18-9e19-11eb-1276-974bf68d045e
md"""
The type of the first argument of this method is [`Type{MyType}`](@ref man-typet-type), the only instance of which is `MyType`. Thus, this method is only invoked when the first argument is the type value `MyType`. Notice the syntax used for the first argument: the argument name is omitted prior to the `::` symbol, and only the type is given. This is the syntax in Julia for a function argument whose type is specified but whose value does not need to be referenced by name.
"""

# ╔═╡ 03bfbc36-9e19-11eb-2fe8-0bc824c69ba7
md"""
All instances of some abstract types are by default considered "sufficiently similar" that a universal `convert` definition is provided in Julia Base. For example, this definition states that it's valid to `convert` any `Number` type to any other by calling a 1-argument constructor:
"""

# ╔═╡ 03bfbc4a-9e19-11eb-3f75-6bf3765e3a18
md"""
```julia
convert(::Type{T}, x::Number) where {T<:Number} = T(x)
```
"""

# ╔═╡ 03bfbc68-9e19-11eb-29e2-b525bc50e932
md"""
This means that new `Number` types only need to define constructors, since this definition will handle `convert` for them. An identity conversion is also provided to handle the case where the argument is already of the requested type:
"""

# ╔═╡ 03bfbc8e-9e19-11eb-2b6a-2f2a31f8d77a
md"""
```julia
convert(::Type{T}, x::T) where {T<:Number} = x
```
"""

# ╔═╡ 03bfbcae-9e19-11eb-1cf0-6f5a514d62ce
md"""
Similar definitions exist for `AbstractString`, [`AbstractArray`](@ref), and [`AbstractDict`](@ref).
"""

# ╔═╡ 03bfbcd6-9e19-11eb-3140-09c135d17fbb
md"""
## Promotion
"""

# ╔═╡ 03bfbd1c-9e19-11eb-0e13-1946116275ca
md"""
Promotion refers to converting values of mixed types to a single common type. Although it is not strictly necessary, it is generally implied that the common type to which the values are converted can faithfully represent all of the original values. In this sense, the term "promotion" is appropriate since the values are converted to a "greater" type – i.e. one which can represent all of the input values in a single common type. It is important, however, not to confuse this with object-oriented (structural) super-typing, or Julia's notion of abstract super-types: promotion has nothing to do with the type hierarchy, and everything to do with converting between alternate representations. For instance, although every [`Int32`](@ref) value can also be represented as a [`Float64`](@ref) value, `Int32` is not a subtype of `Float64`.
"""

# ╔═╡ 03bfbd3a-9e19-11eb-13b0-55aeb77697bc
md"""
Promotion to a common "greater" type is performed in Julia by the [`promote`](@ref) function, which takes any number of arguments, and returns a tuple of the same number of values, converted to a common type, or throws an exception if promotion is not possible. The most common use case for promotion is to convert numeric arguments to a common type:
"""

# ╔═╡ 03bfccf8-9e19-11eb-2390-a90aac58572e
promote(1, 2.5)

# ╔═╡ 03bfcd16-9e19-11eb-3702-434c75853115
promote(1, 2.5, 3)

# ╔═╡ 03bfcd2a-9e19-11eb-3f66-59d6328e8769
promote(2, 3//4)

# ╔═╡ 03bfcd2a-9e19-11eb-10b4-9f1a83065523
promote(1, 2.5, 3, 3//4)

# ╔═╡ 03bfcd34-9e19-11eb-06db-270423410e43
promote(1.5, im)

# ╔═╡ 03bfcd34-9e19-11eb-14ee-5b0c1225e493
promote(1 + 2im, 3//4)

# ╔═╡ 03bfcd7a-9e19-11eb-35fa-b38c22047df8
md"""
Floating-point values are promoted to the largest of the floating-point argument types. Integer values are promoted to the larger of either the native machine word size or the largest integer argument type. Mixtures of integers and floating-point values are promoted to a floating-point type big enough to hold all the values. Integers mixed with rationals are promoted to rationals. Rationals mixed with floats are promoted to floats. Complex values mixed with real values are promoted to the appropriate kind of complex value.
"""

# ╔═╡ 03bfcdca-9e19-11eb-2c4b-6320cd713a71
md"""
That is really all there is to using promotions. The rest is just a matter of clever application, the most typical "clever" application being the definition of catch-all methods for numeric operations like the arithmetic operators `+`, `-`, `*` and `/`. Here are some of the catch-all method definitions given in [`promotion.jl`](https://github.com/JuliaLang/julia/blob/master/base/promotion.jl):
"""

# ╔═╡ 03bfcdfc-9e19-11eb-346d-5dc261c70136
md"""
```julia
+(x::Number, y::Number) = +(promote(x,y)...)
-(x::Number, y::Number) = -(promote(x,y)...)
*(x::Number, y::Number) = *(promote(x,y)...)
/(x::Number, y::Number) = /(promote(x,y)...)
```
"""

# ╔═╡ 03bfce56-9e19-11eb-0b87-9fd3f240903c
md"""
These method definitions say that in the absence of more specific rules for adding, subtracting, multiplying and dividing pairs of numeric values, promote the values to a common type and then try again. That's all there is to it: nowhere else does one ever need to worry about promotion to a common numeric type for arithmetic operations – it just happens automatically. There are definitions of catch-all promotion methods for a number of other arithmetic and mathematical functions in [`promotion.jl`](https://github.com/JuliaLang/julia/blob/master/base/promotion.jl), but beyond that, there are hardly any calls to `promote` required in Julia Base. The most common usages of `promote` occur in outer constructors methods, provided for convenience, to allow constructor calls with mixed types to delegate to an inner type with fields promoted to an appropriate common type. For example, recall that [`rational.jl`](https://github.com/JuliaLang/julia/blob/master/base/rational.jl) provides the following outer constructor method:
"""

# ╔═╡ 03bfce6a-9e19-11eb-1a25-63cd77aaa78b
md"""
```julia
Rational(n::Integer, d::Integer) = Rational(promote(n,d)...)
```
"""

# ╔═╡ 03bfce72-9e19-11eb-10c4-ff20d7c8fd33
md"""
This allows calls like the following to work:
"""

# ╔═╡ 03bfd2a2-9e19-11eb-2290-2f697215044b
x = Rational(Int8(15),Int32(-5))

# ╔═╡ 03bfd2aa-9e19-11eb-37c5-d984d13edf3f
typeof(x)

# ╔═╡ 03bfd2ca-9e19-11eb-378d-afecff3f7ca0
md"""
For most user-defined types, it is better practice to require programmers to supply the expected types to constructor functions explicitly, but sometimes, especially for numeric problems, it can be convenient to do promotion automatically.
"""

# ╔═╡ 03bfd2f2-9e19-11eb-0327-6d95b2771fe9
md"""
### Defining Promotion Rules
"""

# ╔═╡ 03bfd324-9e19-11eb-1462-a9bac62c5ee5
md"""
Although one could, in principle, define methods for the `promote` function directly, this would require many redundant definitions for all possible permutations of argument types. Instead, the behavior of `promote` is defined in terms of an auxiliary function called [`promote_rule`](@ref), which one can provide methods for. The `promote_rule` function takes a pair of type objects and returns another type object, such that instances of the argument types will be promoted to the returned type. Thus, by defining the rule:
"""

# ╔═╡ 03bfd342-9e19-11eb-0819-2dea0b8bd4d6
md"""
```julia
promote_rule(::Type{Float64}, ::Type{Float32}) = Float64
```
"""

# ╔═╡ 03bfd356-9e19-11eb-1eea-ddaa4c7fe7de
md"""
one declares that when 64-bit and 32-bit floating-point values are promoted together, they should be promoted to 64-bit floating-point. The promotion type does not need to be one of the argument types. For example, the following promotion rules both occur in Julia Base:
"""

# ╔═╡ 03bfd36a-9e19-11eb-0229-cf4cedd530db
md"""
```julia
promote_rule(::Type{BigInt}, ::Type{Float64}) = BigFloat
promote_rule(::Type{BigInt}, ::Type{Int8}) = BigInt
```
"""

# ╔═╡ 03bfd3a6-9e19-11eb-09ac-894bec71f056
md"""
In the latter case, the result type is [`BigInt`](@ref) since `BigInt` is the only type large enough to hold integers for arbitrary-precision integer arithmetic. Also note that one does not need to define both `promote_rule(::Type{A}, ::Type{B})` and `promote_rule(::Type{B}, ::Type{A})` – the symmetry is implied by the way `promote_rule` is used in the promotion process.
"""

# ╔═╡ 03bfd3ce-9e19-11eb-0407-8d3fa4fb0501
md"""
The `promote_rule` function is used as a building block to define a second function called [`promote_type`](@ref), which, given any number of type objects, returns the common type to which those values, as arguments to `promote` should be promoted. Thus, if one wants to know, in absence of actual values, what type a collection of values of certain types would promote to, one can use `promote_type`:
"""

# ╔═╡ 03bfd4b6-9e19-11eb-1cd0-dfb03d74de18
promote_type(Int8, Int64)

# ╔═╡ 03bfd4e8-9e19-11eb-0e2e-af76cc4c55ef
md"""
Internally, `promote_type` is used inside of `promote` to determine what type argument values should be converted to for promotion. It can, however, be useful in its own right. The curious reader can read the code in [`promotion.jl`](https://github.com/JuliaLang/julia/blob/master/base/promotion.jl), which defines the complete promotion mechanism in about 35 lines.
"""

# ╔═╡ 03bfd4fa-9e19-11eb-05d6-1b1b01c4ad99
md"""
### Case Study: Rational Promotions
"""

# ╔═╡ 03bfd50e-9e19-11eb-12c2-af0033b3a583
md"""
Finally, we finish off our ongoing case study of Julia's rational number type, which makes relatively sophisticated use of the promotion mechanism with the following promotion rules:
"""

# ╔═╡ 03bfd52c-9e19-11eb-05c0-571fdaca8c6f
md"""
```julia
promote_rule(::Type{Rational{T}}, ::Type{S}) where {T<:Integer,S<:Integer} = Rational{promote_type(T,S)}
promote_rule(::Type{Rational{T}}, ::Type{Rational{S}}) where {T<:Integer,S<:Integer} = Rational{promote_type(T,S)}
promote_rule(::Type{Rational{T}}, ::Type{S}) where {T<:Integer,S<:AbstractFloat} = promote_type(T,S)
```
"""

# ╔═╡ 03bfd548-9e19-11eb-23ee-a14fd63d420e
md"""
The first rule says that promoting a rational number with any other integer type promotes to a rational type whose numerator/denominator type is the result of promotion of its numerator/denominator type with the other integer type. The second rule applies the same logic to two different types of rational numbers, resulting in a rational of the promotion of their respective numerator/denominator types. The third and final rule dictates that promoting a rational with a float results in the same type as promoting the numerator/denominator type with the float.
"""

# ╔═╡ 03bfd568-9e19-11eb-0b4e-eb41ad96e896
md"""
This small handful of promotion rules, together with the type's constructors and the default `convert` method for numbers, are sufficient to make rational numbers interoperate completely naturally with all of Julia's other numeric types – integers, floating-point numbers, and complex numbers. By providing appropriate conversion methods and promotion rules in the same manner, any user-defined numeric type can interoperate just as naturally with Julia's predefined numerics.
"""

# ╔═╡ Cell order:
# ╟─03bf8784-9e19-11eb-377c-ed436cdc225c
# ╟─03bf88c4-9e19-11eb-1c49-c5463c2b64c0
# ╟─03bf8d58-9e19-11eb-3468-b7ac5364b75a
# ╟─03bf8df6-9e19-11eb-16c7-b1159ffe5631
# ╟─03bf8e46-9e19-11eb-2621-b706ec596cc5
# ╟─03bf8eaa-9e19-11eb-0660-e921d49b0315
# ╟─03bf8ec8-9e19-11eb-0abb-7f49229e76bf
# ╠═03bfa62e-9e19-11eb-14a4-e5142e2763c8
# ╠═03bfa656-9e19-11eb-24ba-33394d4e5267
# ╠═03bfa656-9e19-11eb-02ba-05ef20b5bdab
# ╠═03bfa660-9e19-11eb-34fe-138522e50a59
# ╠═03bfa6b0-9e19-11eb-190d-e9372eff8d22
# ╠═03bfa6b0-9e19-11eb-3317-6bda08fc4c81
# ╠═03bfa6ba-9e19-11eb-16bc-571fd682e9d2
# ╠═03bfa6ba-9e19-11eb-303e-1f6f523561c9
# ╟─03bfa77a-9e19-11eb-3453-5f03aaa4d8dc
# ╠═03bfab80-9e19-11eb-338b-ad6541ff025f
# ╟─03bfae3a-9e19-11eb-0e1c-7b3a69d1f6bd
# ╟─03bfaea8-9e19-11eb-3d7c-21f70112436b
# ╟─03bfaed0-9e19-11eb-2eda-d792e20f5714
# ╟─03bfb790-9e19-11eb-202a-43ee05b65157
# ╟─03bfb856-9e19-11eb-3699-35031ef3d66e
# ╟─03bfb984-9e19-11eb-081e-fb9a624a464d
# ╟─03bfb9d4-9e19-11eb-36e6-fbcd7a558823
# ╟─03bfba24-9e19-11eb-1e1b-bbac97651e24
# ╟─03bfba42-9e19-11eb-3767-9729ce4a479f
# ╟─03bfba7e-9e19-11eb-2fbf-115d996ead53
# ╟─03bfbac6-9e19-11eb-0fce-7bea489ac133
# ╟─03bfbace-9e19-11eb-3c33-e3373bb76b8e
# ╟─03bfbb00-9e19-11eb-34f9-496d08ccbc0f
# ╟─03bfbb14-9e19-11eb-0f80-7183a49f0035
# ╟─03bfbb58-9e19-11eb-3d52-677ef1f6a74b
# ╟─03bfbb78-9e19-11eb-33f3-ddd76a4e9391
# ╟─03bfbb8c-9e19-11eb-194c-c95d8108c1bb
# ╟─03bfbbdc-9e19-11eb-29b1-290baae97ac5
# ╟─03bfbc18-9e19-11eb-1276-974bf68d045e
# ╟─03bfbc36-9e19-11eb-2fe8-0bc824c69ba7
# ╟─03bfbc4a-9e19-11eb-3f75-6bf3765e3a18
# ╟─03bfbc68-9e19-11eb-29e2-b525bc50e932
# ╟─03bfbc8e-9e19-11eb-2b6a-2f2a31f8d77a
# ╟─03bfbcae-9e19-11eb-1cf0-6f5a514d62ce
# ╟─03bfbcd6-9e19-11eb-3140-09c135d17fbb
# ╟─03bfbd1c-9e19-11eb-0e13-1946116275ca
# ╟─03bfbd3a-9e19-11eb-13b0-55aeb77697bc
# ╠═03bfccf8-9e19-11eb-2390-a90aac58572e
# ╠═03bfcd16-9e19-11eb-3702-434c75853115
# ╠═03bfcd2a-9e19-11eb-3f66-59d6328e8769
# ╠═03bfcd2a-9e19-11eb-10b4-9f1a83065523
# ╠═03bfcd34-9e19-11eb-06db-270423410e43
# ╠═03bfcd34-9e19-11eb-14ee-5b0c1225e493
# ╟─03bfcd7a-9e19-11eb-35fa-b38c22047df8
# ╟─03bfcdca-9e19-11eb-2c4b-6320cd713a71
# ╟─03bfcdfc-9e19-11eb-346d-5dc261c70136
# ╟─03bfce56-9e19-11eb-0b87-9fd3f240903c
# ╟─03bfce6a-9e19-11eb-1a25-63cd77aaa78b
# ╟─03bfce72-9e19-11eb-10c4-ff20d7c8fd33
# ╠═03bfd2a2-9e19-11eb-2290-2f697215044b
# ╠═03bfd2aa-9e19-11eb-37c5-d984d13edf3f
# ╟─03bfd2ca-9e19-11eb-378d-afecff3f7ca0
# ╟─03bfd2f2-9e19-11eb-0327-6d95b2771fe9
# ╟─03bfd324-9e19-11eb-1462-a9bac62c5ee5
# ╟─03bfd342-9e19-11eb-0819-2dea0b8bd4d6
# ╟─03bfd356-9e19-11eb-1eea-ddaa4c7fe7de
# ╟─03bfd36a-9e19-11eb-0229-cf4cedd530db
# ╟─03bfd3a6-9e19-11eb-09ac-894bec71f056
# ╟─03bfd3ce-9e19-11eb-0407-8d3fa4fb0501
# ╠═03bfd4b6-9e19-11eb-1cd0-dfb03d74de18
# ╟─03bfd4e8-9e19-11eb-0e2e-af76cc4c55ef
# ╟─03bfd4fa-9e19-11eb-05d6-1b1b01c4ad99
# ╟─03bfd50e-9e19-11eb-12c2-af0033b3a583
# ╟─03bfd52c-9e19-11eb-05c0-571fdaca8c6f
# ╟─03bfd548-9e19-11eb-23ee-a14fd63d420e
# ╟─03bfd568-9e19-11eb-0b4e-eb41ad96e896
