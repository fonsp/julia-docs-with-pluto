### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ e912a09a-42ed-4572-b6ef-8a49597337d9
md"""
# [Conversion and Promotion](@id conversion-and-promotion)
"""

# ╔═╡ 4beb862f-a907-403d-9ba2-8a0ea66b1047
md"""
Julia has a system for promoting arguments of mathematical operators to a common type, which has been mentioned in various other sections, including [Integers and Floating-Point Numbers](@ref), [Mathematical Operations and Elementary Functions](@ref), [Types](@ref man-types), and [Methods](@ref). In this section, we explain how this promotion system works, as well as how to extend it to new types and apply it to functions besides built-in mathematical operators. Traditionally, programming languages fall into two camps with respect to promotion of arithmetic arguments:
"""

# ╔═╡ c5687c58-35dc-4cad-92f2-40ec883e9dc2
md"""
  * **Automatic promotion for built-in arithmetic types and operators.** In most languages, built-in numeric types, when used as operands to arithmetic operators with infix syntax, such as `+`, `-`, `*`, and `/`, are automatically promoted to a common type to produce the expected results. C, Java, Perl, and Python, to name a few, all correctly compute the sum `1 + 1.5` as the floating-point value `2.5`, even though one of the operands to `+` is an integer. These systems are convenient and designed carefully enough that they are generally all-but-invisible to the programmer: hardly anyone consciously thinks of this promotion taking place when writing such an expression, but compilers and interpreters must perform conversion before addition since integers and floating-point values cannot be added as-is. Complex rules for such automatic conversions are thus inevitably part of specifications and implementations for such languages.
  * **No automatic promotion.** This camp includes Ada and ML – very \"strict\" statically typed languages. In these languages, every conversion must be explicitly specified by the programmer. Thus, the example expression `1 + 1.5` would be a compilation error in both Ada and ML. Instead one must write `real(1) + 1.5`, explicitly converting the integer `1` to a floating-point value before performing addition. Explicit conversion everywhere is so inconvenient, however, that even Ada has some degree of automatic conversion: integer literals are promoted to the expected integer type automatically, and floating-point literals are similarly promoted to appropriate floating-point types.
"""

# ╔═╡ 9277cab2-32c6-4cc6-b254-ffff8cde6fa0
md"""
In a sense, Julia falls into the \"no automatic promotion\" category: mathematical operators are just functions with special syntax, and the arguments of functions are never automatically converted. However, one may observe that applying mathematical operations to a wide variety of mixed argument types is just an extreme case of polymorphic multiple dispatch – something which Julia's dispatch and type systems are particularly well-suited to handle. \"Automatic\" promotion of mathematical operands simply emerges as a special application: Julia comes with pre-defined catch-all dispatch rules for mathematical operators, invoked when no specific implementation exists for some combination of operand types. These catch-all rules first promote all operands to a common type using user-definable promotion rules, and then invoke a specialized implementation of the operator in question for the resulting values, now of the same type. User-defined types can easily participate in this promotion system by defining methods for conversion to and from other types, and providing a handful of promotion rules defining what types they should promote to when mixed with other types.
"""

# ╔═╡ 5455f4a4-2ed0-4499-92b0-c85f65adb14c
md"""
## Conversion
"""

# ╔═╡ 9bc5cda2-bd60-4b35-b2f5-d0c639ed4168
md"""
The standard way to obtain a value of a certain type `T` is to call the type's constructor, `T(x)`. However, there are cases where it's convenient to convert a value from one type to another without the programmer asking for it explicitly. One example is assigning a value into an array: if `A` is a `Vector{Float64}`, the expression `A[1] = 2` should work by automatically converting the `2` from `Int` to `Float64`, and storing the result in the array. This is done via the [`convert`](@ref) function.
"""

# ╔═╡ 64d09299-7fd4-49d7-94f5-c0588f1e3c77
md"""
The `convert` function generally takes two arguments: the first is a type object and the second is a value to convert to that type. The returned value is the value converted to an instance of given type. The simplest way to understand this function is to see it in action:
"""

# ╔═╡ 68b9f31b-975c-4fc6-b8d4-46ee83e7a570
x = 12

# ╔═╡ 456627d1-9e2b-4ae4-b053-2d6ae96fa5ac
typeof(x)

# ╔═╡ fcd80334-9356-4d74-8950-424ed1ea238e
xu = convert(UInt8, x)

# ╔═╡ 988d500e-1130-4f2b-b73d-082551cfa79c
typeof(xu)

# ╔═╡ d8fc13bf-54f2-41c6-be7f-5eb19641b2b2
xf = convert(AbstractFloat, x)

# ╔═╡ d072923a-071e-4164-8f6e-2a23d38a76a1
typeof(xf)

# ╔═╡ 27464c4f-8204-4293-a0a3-b0baf8a0eba9
a = Any[1 2 3; 4 5 6]

# ╔═╡ 88370449-6f4f-4b66-b797-0b7811ff70a4
convert(Array{Float64}, a)

# ╔═╡ f9de3d13-d4d7-4835-959b-a1f42dec26b4
md"""
Conversion isn't always possible, in which case a [`MethodError`](@ref) is thrown indicating that `convert` doesn't know how to perform the requested conversion:
"""

# ╔═╡ 1c064362-2e10-44de-9a56-90b3d0cfc417
convert(AbstractFloat, "foo")

# ╔═╡ d89347c1-a3fc-4d09-a5c4-7119c6befb16
md"""
Some languages consider parsing strings as numbers or formatting numbers as strings to be conversions (many dynamic languages will even perform conversion for you automatically). This is not the case in Julia. Even though some strings can be parsed as numbers, most strings are not valid representations of numbers, and only a very limited subset of them are. Therefore in Julia the dedicated [`parse`](@ref) function must be used to perform this operation, making it more explicit.
"""

# ╔═╡ b421adf8-0636-4a26-adef-80b71a7b65ff
md"""
### When is `convert` called?
"""

# ╔═╡ 3231f331-2d80-40e6-b133-92912094d098
md"""
The following language constructs call `convert`:
"""

# ╔═╡ daa353cf-ce7c-4f48-86f3-9ee5bfcfe1a0
md"""
  * Assigning to an array converts to the array's element type.
  * Assigning to a field of an object converts to the declared type of the field.
  * Constructing an object with [`new`](@ref) converts to the object's declared field types.
  * Assigning to a variable with a declared type (e.g. `local x::T`) converts to that type.
  * A function with a declared return type converts its return value to that type.
  * Passing a value to [`ccall`](@ref) converts it to the corresponding argument type.
"""

# ╔═╡ 679dff73-bc64-4d42-abba-3a5b7678e40a
md"""
### Conversion vs. Construction
"""

# ╔═╡ 5f0da973-f10b-4af9-b708-709397308f7d
md"""
Note that the behavior of `convert(T, x)` appears to be nearly identical to `T(x)`. Indeed, it usually is. However, there is a key semantic difference: since `convert` can be called implicitly, its methods are restricted to cases that are considered \"safe\" or \"unsurprising\". `convert` will only convert between types that represent the same basic kind of thing (e.g. different representations of numbers, or different string encodings). It is also usually lossless; converting a value to a different type and back again should result in the exact same value.
"""

# ╔═╡ f71e1767-ed05-4a3d-8ae9-bf128aef2ed2
md"""
There are four general kinds of cases where constructors differ from `convert`:
"""

# ╔═╡ db3b361e-393e-4769-a7a1-62b4d2756cea
md"""
#### Constructors for types unrelated to their arguments
"""

# ╔═╡ ce34ff30-69ab-43d8-b94a-f7dcd86a2e1a
md"""
Some constructors don't implement the concept of \"conversion\". For example, `Timer(2)` creates a 2-second timer, which is not really a \"conversion\" from an integer to a timer.
"""

# ╔═╡ f1151eec-293c-4c6e-948b-b48706ada58f
md"""
#### Mutable collections
"""

# ╔═╡ 95ddd974-e7fc-4f1f-8bc8-571bd2702303
md"""
`convert(T, x)` is expected to return the original `x` if `x` is already of type `T`. In contrast, if `T` is a mutable collection type then `T(x)` should always make a new collection (copying elements from `x`).
"""

# ╔═╡ 86b4c565-6664-4c19-a8e5-f457c8974c7f
md"""
#### Wrapper types
"""

# ╔═╡ 1f8ad657-0488-4de7-aa3d-7bd8e82173ee
md"""
For some types which \"wrap\" other values, the constructor may wrap its argument inside a new object even if it is already of the requested type. For example `Some(x)` wraps `x` to indicate that a value is present (in a context where the result might be a `Some` or `nothing`). However, `x` itself might be the object `Some(y)`, in which case the result is `Some(Some(y))`, with two levels of wrapping. `convert(Some, x)`, on the other hand, would just return `x` since it is already a `Some`.
"""

# ╔═╡ 4ea3e7b5-0d58-4f63-bfb6-c89fbfbeda52
md"""
#### Constructors that don't return instances of their own type
"""

# ╔═╡ 39b577d2-a421-4948-bf21-dc41f502e914
md"""
In *very rare* cases it might make sense for the constructor `T(x)` to return an object not of type `T`. This could happen if a wrapper type is its own inverse (e.g. `Flip(Flip(x)) === x`), or to support an old calling syntax for backwards compatibility when a library is restructured. But `convert(T, x)` should always return a value of type `T`.
"""

# ╔═╡ ae850a35-d9bc-48f9-8346-e372c6264f9f
md"""
### Defining New Conversions
"""

# ╔═╡ 9fd84338-9ba2-432d-9697-7993f5833ff4
md"""
When defining a new type, initially all ways of creating it should be defined as constructors. If it becomes clear that implicit conversion would be useful, and that some constructors meet the above \"safety\" criteria, then `convert` methods can be added. These methods are typically quite simple, as they only need to call the appropriate constructor. Such a definition might look like this:
"""

# ╔═╡ 6ee0977b-ac91-4d80-ba66-0649cbd5c159
md"""
```julia
convert(::Type{MyType}, x) = MyType(x)
```
"""

# ╔═╡ 538d9d6b-1a62-4b86-9949-8cef03d22364
md"""
The type of the first argument of this method is [`Type{MyType}`](@ref man-typet-type), the only instance of which is `MyType`. Thus, this method is only invoked when the first argument is the type value `MyType`. Notice the syntax used for the first argument: the argument name is omitted prior to the `::` symbol, and only the type is given. This is the syntax in Julia for a function argument whose type is specified but whose value does not need to be referenced by name.
"""

# ╔═╡ 0bbdea37-9b79-4ebf-b49a-b07b1a443290
md"""
All instances of some abstract types are by default considered \"sufficiently similar\" that a universal `convert` definition is provided in Julia Base. For example, this definition states that it's valid to `convert` any `Number` type to any other by calling a 1-argument constructor:
"""

# ╔═╡ 650fbe9c-74b2-4f99-8d82-af83ae5e6915
md"""
```julia
convert(::Type{T}, x::Number) where {T<:Number} = T(x)
```
"""

# ╔═╡ 045fb6ca-a725-43f5-9aa3-ddab39284c10
md"""
This means that new `Number` types only need to define constructors, since this definition will handle `convert` for them. An identity conversion is also provided to handle the case where the argument is already of the requested type:
"""

# ╔═╡ 5e89565e-4c98-4d2a-b8df-5d621792992f
md"""
```julia
convert(::Type{T}, x::T) where {T<:Number} = x
```
"""

# ╔═╡ 4b800aa4-0cba-4f84-b958-5aefecf09eba
md"""
Similar definitions exist for `AbstractString`, [`AbstractArray`](@ref), and [`AbstractDict`](@ref).
"""

# ╔═╡ 3c48bc4c-0c9a-40e9-a095-c3ef1a5f760d
md"""
## Promotion
"""

# ╔═╡ 2fc24905-e7c4-44e3-9d08-d8fe11ada2d2
md"""
Promotion refers to converting values of mixed types to a single common type. Although it is not strictly necessary, it is generally implied that the common type to which the values are converted can faithfully represent all of the original values. In this sense, the term \"promotion\" is appropriate since the values are converted to a \"greater\" type – i.e. one which can represent all of the input values in a single common type. It is important, however, not to confuse this with object-oriented (structural) super-typing, or Julia's notion of abstract super-types: promotion has nothing to do with the type hierarchy, and everything to do with converting between alternate representations. For instance, although every [`Int32`](@ref) value can also be represented as a [`Float64`](@ref) value, `Int32` is not a subtype of `Float64`.
"""

# ╔═╡ 6f23f6a3-3e82-4f0f-9b5f-b5e551d7c24b
md"""
Promotion to a common \"greater\" type is performed in Julia by the [`promote`](@ref) function, which takes any number of arguments, and returns a tuple of the same number of values, converted to a common type, or throws an exception if promotion is not possible. The most common use case for promotion is to convert numeric arguments to a common type:
"""

# ╔═╡ 13b3b151-95ad-47be-bed5-dcb238d7585a
promote(1, 2.5)

# ╔═╡ 05ec1628-4296-40a9-8f0e-f6c14d67c732
promote(1, 2.5, 3)

# ╔═╡ 8baf796b-b595-4e78-bd6a-50313f0e3661
promote(2, 3//4)

# ╔═╡ bdd92cfc-86c9-4b33-b5c5-f0b1479ad066
promote(1, 2.5, 3, 3//4)

# ╔═╡ a57361ef-66cb-4f28-9f2a-702ecf07aa31
promote(1.5, im)

# ╔═╡ 3af9ca8c-db44-4553-8075-7317c3c9c327
promote(1 + 2im, 3//4)

# ╔═╡ 864ed7fb-2414-4066-8c7f-39c43a07a0d1
md"""
Floating-point values are promoted to the largest of the floating-point argument types. Integer values are promoted to the larger of either the native machine word size or the largest integer argument type. Mixtures of integers and floating-point values are promoted to a floating-point type big enough to hold all the values. Integers mixed with rationals are promoted to rationals. Rationals mixed with floats are promoted to floats. Complex values mixed with real values are promoted to the appropriate kind of complex value.
"""

# ╔═╡ 838a0234-d56c-4913-a7aa-db0bed0a202a
md"""
That is really all there is to using promotions. The rest is just a matter of clever application, the most typical \"clever\" application being the definition of catch-all methods for numeric operations like the arithmetic operators `+`, `-`, `*` and `/`. Here are some of the catch-all method definitions given in [`promotion.jl`](https://github.com/JuliaLang/julia/blob/master/base/promotion.jl):
"""

# ╔═╡ dfc90350-a2c4-4196-9a6e-66ab7422cded
md"""
```julia
+(x::Number, y::Number) = +(promote(x,y)...)
-(x::Number, y::Number) = -(promote(x,y)...)
*(x::Number, y::Number) = *(promote(x,y)...)
/(x::Number, y::Number) = /(promote(x,y)...)
```
"""

# ╔═╡ 300d0a8c-8511-4e4f-b8b3-ff45262b5589
md"""
These method definitions say that in the absence of more specific rules for adding, subtracting, multiplying and dividing pairs of numeric values, promote the values to a common type and then try again. That's all there is to it: nowhere else does one ever need to worry about promotion to a common numeric type for arithmetic operations – it just happens automatically. There are definitions of catch-all promotion methods for a number of other arithmetic and mathematical functions in [`promotion.jl`](https://github.com/JuliaLang/julia/blob/master/base/promotion.jl), but beyond that, there are hardly any calls to `promote` required in Julia Base. The most common usages of `promote` occur in outer constructors methods, provided for convenience, to allow constructor calls with mixed types to delegate to an inner type with fields promoted to an appropriate common type. For example, recall that [`rational.jl`](https://github.com/JuliaLang/julia/blob/master/base/rational.jl) provides the following outer constructor method:
"""

# ╔═╡ 2e52f6cb-d5da-4dc5-9fb6-bdc2a525e418
md"""
```julia
Rational(n::Integer, d::Integer) = Rational(promote(n,d)...)
```
"""

# ╔═╡ 010bd868-d4d0-4b5b-abdc-b5032ff13444
md"""
This allows calls like the following to work:
"""

# ╔═╡ ece8da32-3f55-4d92-bd91-00ea83a8fbd4
x = Rational(Int8(15),Int32(-5))

# ╔═╡ 7b83c1e0-6bcc-4852-9f31-47cac142dc4d
typeof(x)

# ╔═╡ e8c73fcc-e95b-4e98-9de5-f14d33b840f4
md"""
For most user-defined types, it is better practice to require programmers to supply the expected types to constructor functions explicitly, but sometimes, especially for numeric problems, it can be convenient to do promotion automatically.
"""

# ╔═╡ a74436ad-25aa-43de-9d56-454acb1ea764
md"""
### Defining Promotion Rules
"""

# ╔═╡ 479538a6-b9a9-488c-9359-0f0f5bde2afb
md"""
Although one could, in principle, define methods for the `promote` function directly, this would require many redundant definitions for all possible permutations of argument types. Instead, the behavior of `promote` is defined in terms of an auxiliary function called [`promote_rule`](@ref), which one can provide methods for. The `promote_rule` function takes a pair of type objects and returns another type object, such that instances of the argument types will be promoted to the returned type. Thus, by defining the rule:
"""

# ╔═╡ 0275c28c-59fb-4ca5-8e1b-49c5857c4153
md"""
```julia
promote_rule(::Type{Float64}, ::Type{Float32}) = Float64
```
"""

# ╔═╡ 1c4fb19f-600f-4859-9223-06677af4ed3e
md"""
one declares that when 64-bit and 32-bit floating-point values are promoted together, they should be promoted to 64-bit floating-point. The promotion type does not need to be one of the argument types. For example, the following promotion rules both occur in Julia Base:
"""

# ╔═╡ 0333f410-6911-4476-b3a2-8d29bafd476b
md"""
```julia
promote_rule(::Type{BigInt}, ::Type{Float64}) = BigFloat
promote_rule(::Type{BigInt}, ::Type{Int8}) = BigInt
```
"""

# ╔═╡ e523f74e-8767-4acb-b809-e1c31157d878
md"""
In the latter case, the result type is [`BigInt`](@ref) since `BigInt` is the only type large enough to hold integers for arbitrary-precision integer arithmetic. Also note that one does not need to define both `promote_rule(::Type{A}, ::Type{B})` and `promote_rule(::Type{B}, ::Type{A})` – the symmetry is implied by the way `promote_rule` is used in the promotion process.
"""

# ╔═╡ c340a541-6cc7-4112-82a7-cfb8c4c123d1
md"""
The `promote_rule` function is used as a building block to define a second function called [`promote_type`](@ref), which, given any number of type objects, returns the common type to which those values, as arguments to `promote` should be promoted. Thus, if one wants to know, in absence of actual values, what type a collection of values of certain types would promote to, one can use `promote_type`:
"""

# ╔═╡ 8a76be52-bde3-43f7-9dd1-743de957a34d
promote_type(Int8, Int64)

# ╔═╡ 494d803c-9675-444b-98ad-abc885270743
md"""
Internally, `promote_type` is used inside of `promote` to determine what type argument values should be converted to for promotion. It can, however, be useful in its own right. The curious reader can read the code in [`promotion.jl`](https://github.com/JuliaLang/julia/blob/master/base/promotion.jl), which defines the complete promotion mechanism in about 35 lines.
"""

# ╔═╡ 91d626f3-c2d2-4c04-bdb5-074d8162a12d
md"""
### Case Study: Rational Promotions
"""

# ╔═╡ 72d48137-96ea-4767-a31f-537ebbda7618
md"""
Finally, we finish off our ongoing case study of Julia's rational number type, which makes relatively sophisticated use of the promotion mechanism with the following promotion rules:
"""

# ╔═╡ 1d7706ae-c608-4ae2-971c-fed820031949
md"""
```julia
promote_rule(::Type{Rational{T}}, ::Type{S}) where {T<:Integer,S<:Integer} = Rational{promote_type(T,S)}
promote_rule(::Type{Rational{T}}, ::Type{Rational{S}}) where {T<:Integer,S<:Integer} = Rational{promote_type(T,S)}
promote_rule(::Type{Rational{T}}, ::Type{S}) where {T<:Integer,S<:AbstractFloat} = promote_type(T,S)
```
"""

# ╔═╡ c8a98590-c75c-4af4-972a-d2fcb7f269f1
md"""
The first rule says that promoting a rational number with any other integer type promotes to a rational type whose numerator/denominator type is the result of promotion of its numerator/denominator type with the other integer type. The second rule applies the same logic to two different types of rational numbers, resulting in a rational of the promotion of their respective numerator/denominator types. The third and final rule dictates that promoting a rational with a float results in the same type as promoting the numerator/denominator type with the float.
"""

# ╔═╡ ed12bfca-c110-40d2-b36a-1c71608e6f18
md"""
This small handful of promotion rules, together with the type's constructors and the default `convert` method for numbers, are sufficient to make rational numbers interoperate completely naturally with all of Julia's other numeric types – integers, floating-point numbers, and complex numbers. By providing appropriate conversion methods and promotion rules in the same manner, any user-defined numeric type can interoperate just as naturally with Julia's predefined numerics.
"""

# ╔═╡ Cell order:
# ╟─e912a09a-42ed-4572-b6ef-8a49597337d9
# ╟─4beb862f-a907-403d-9ba2-8a0ea66b1047
# ╟─c5687c58-35dc-4cad-92f2-40ec883e9dc2
# ╟─9277cab2-32c6-4cc6-b254-ffff8cde6fa0
# ╟─5455f4a4-2ed0-4499-92b0-c85f65adb14c
# ╟─9bc5cda2-bd60-4b35-b2f5-d0c639ed4168
# ╟─64d09299-7fd4-49d7-94f5-c0588f1e3c77
# ╠═68b9f31b-975c-4fc6-b8d4-46ee83e7a570
# ╠═456627d1-9e2b-4ae4-b053-2d6ae96fa5ac
# ╠═fcd80334-9356-4d74-8950-424ed1ea238e
# ╠═988d500e-1130-4f2b-b73d-082551cfa79c
# ╠═d8fc13bf-54f2-41c6-be7f-5eb19641b2b2
# ╠═d072923a-071e-4164-8f6e-2a23d38a76a1
# ╠═27464c4f-8204-4293-a0a3-b0baf8a0eba9
# ╠═88370449-6f4f-4b66-b797-0b7811ff70a4
# ╟─f9de3d13-d4d7-4835-959b-a1f42dec26b4
# ╠═1c064362-2e10-44de-9a56-90b3d0cfc417
# ╟─d89347c1-a3fc-4d09-a5c4-7119c6befb16
# ╟─b421adf8-0636-4a26-adef-80b71a7b65ff
# ╟─3231f331-2d80-40e6-b133-92912094d098
# ╟─daa353cf-ce7c-4f48-86f3-9ee5bfcfe1a0
# ╟─679dff73-bc64-4d42-abba-3a5b7678e40a
# ╟─5f0da973-f10b-4af9-b708-709397308f7d
# ╟─f71e1767-ed05-4a3d-8ae9-bf128aef2ed2
# ╟─db3b361e-393e-4769-a7a1-62b4d2756cea
# ╟─ce34ff30-69ab-43d8-b94a-f7dcd86a2e1a
# ╟─f1151eec-293c-4c6e-948b-b48706ada58f
# ╟─95ddd974-e7fc-4f1f-8bc8-571bd2702303
# ╟─86b4c565-6664-4c19-a8e5-f457c8974c7f
# ╟─1f8ad657-0488-4de7-aa3d-7bd8e82173ee
# ╟─4ea3e7b5-0d58-4f63-bfb6-c89fbfbeda52
# ╟─39b577d2-a421-4948-bf21-dc41f502e914
# ╟─ae850a35-d9bc-48f9-8346-e372c6264f9f
# ╟─9fd84338-9ba2-432d-9697-7993f5833ff4
# ╟─6ee0977b-ac91-4d80-ba66-0649cbd5c159
# ╟─538d9d6b-1a62-4b86-9949-8cef03d22364
# ╟─0bbdea37-9b79-4ebf-b49a-b07b1a443290
# ╟─650fbe9c-74b2-4f99-8d82-af83ae5e6915
# ╟─045fb6ca-a725-43f5-9aa3-ddab39284c10
# ╟─5e89565e-4c98-4d2a-b8df-5d621792992f
# ╟─4b800aa4-0cba-4f84-b958-5aefecf09eba
# ╟─3c48bc4c-0c9a-40e9-a095-c3ef1a5f760d
# ╟─2fc24905-e7c4-44e3-9d08-d8fe11ada2d2
# ╟─6f23f6a3-3e82-4f0f-9b5f-b5e551d7c24b
# ╠═13b3b151-95ad-47be-bed5-dcb238d7585a
# ╠═05ec1628-4296-40a9-8f0e-f6c14d67c732
# ╠═8baf796b-b595-4e78-bd6a-50313f0e3661
# ╠═bdd92cfc-86c9-4b33-b5c5-f0b1479ad066
# ╠═a57361ef-66cb-4f28-9f2a-702ecf07aa31
# ╠═3af9ca8c-db44-4553-8075-7317c3c9c327
# ╟─864ed7fb-2414-4066-8c7f-39c43a07a0d1
# ╟─838a0234-d56c-4913-a7aa-db0bed0a202a
# ╟─dfc90350-a2c4-4196-9a6e-66ab7422cded
# ╟─300d0a8c-8511-4e4f-b8b3-ff45262b5589
# ╟─2e52f6cb-d5da-4dc5-9fb6-bdc2a525e418
# ╟─010bd868-d4d0-4b5b-abdc-b5032ff13444
# ╠═ece8da32-3f55-4d92-bd91-00ea83a8fbd4
# ╠═7b83c1e0-6bcc-4852-9f31-47cac142dc4d
# ╟─e8c73fcc-e95b-4e98-9de5-f14d33b840f4
# ╟─a74436ad-25aa-43de-9d56-454acb1ea764
# ╟─479538a6-b9a9-488c-9359-0f0f5bde2afb
# ╟─0275c28c-59fb-4ca5-8e1b-49c5857c4153
# ╟─1c4fb19f-600f-4859-9223-06677af4ed3e
# ╟─0333f410-6911-4476-b3a2-8d29bafd476b
# ╟─e523f74e-8767-4acb-b809-e1c31157d878
# ╟─c340a541-6cc7-4112-82a7-cfb8c4c123d1
# ╠═8a76be52-bde3-43f7-9dd1-743de957a34d
# ╟─494d803c-9675-444b-98ad-abc885270743
# ╟─91d626f3-c2d2-4c04-bdb5-074d8162a12d
# ╟─72d48137-96ea-4767-a31f-537ebbda7618
# ╟─1d7706ae-c608-4ae2-971c-fed820031949
# ╟─c8a98590-c75c-4af4-972a-d2fcb7f269f1
# ╟─ed12bfca-c110-40d2-b36a-1c71608e6f18
