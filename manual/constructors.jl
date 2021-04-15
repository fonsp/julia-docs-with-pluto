### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ 03bcef1a-9e19-11eb-0510-dd1c5c379cfa
md"""
# [Constructors](@id man-constructors)
"""

# ╔═╡ 03bcef92-9e19-11eb-3424-7fe8d8ccec95
md"""
Constructors [^1] are functions that create new objects – specifically, instances of [Composite Types](@ref). In Julia, type objects also serve as constructor functions: they create new instances of themselves when applied to an argument tuple as a function. This much was already mentioned briefly when composite types were introduced. For example:
"""

# ╔═╡ 03bcf898-9e19-11eb-0f23-f17dc6ec4952
struct Foo
           bar
           baz
       end

# ╔═╡ 03bcf8a2-9e19-11eb-2ed7-1bf5632d7007
foo = Foo(1, 2)

# ╔═╡ 03bcf8ac-9e19-11eb-0598-877bf1f9fce3
foo.bar

# ╔═╡ 03bcf8b4-9e19-11eb-030b-4f17e10e6cd3
foo.baz

# ╔═╡ 03bcf906-9e19-11eb-0adc-473c8a66014b
md"""
For many types, forming new objects by binding their field values together is all that is ever needed to create instances. However, in some cases more functionality is required when creating composite objects. Sometimes invariants must be enforced, either by checking arguments or by transforming them. [Recursive data structures](https://en.wikipedia.org/wiki/Recursion_%28computer_science%29#Recursive_data_structures_.28structural_recursion.29), especially those that may be self-referential, often cannot be constructed cleanly without first being created in an incomplete state and then altered programmatically to be made whole, as a separate step from object creation. Sometimes, it's just convenient to be able to construct objects with fewer or different types of parameters than they have fields. Julia's system for object construction addresses all of these cases and more.
"""

# ╔═╡ 03bcfa64-9e19-11eb-274b-cf5c0a6f8c11
md"""
[^1]: Nomenclature: while the term "constructor" generally refers to the entire function which constructs objects of a type, it is common to abuse terminology slightly and refer to specific constructor methods as "constructors". In such situations, it is generally clear from the context that the term is used to mean "constructor method" rather than "constructor function", especially as it is often used in the sense of singling out a particular method of the constructor from all of the others.
"""

# ╔═╡ 03bcfaaa-9e19-11eb-01b1-53a408dcb377
md"""
## [Outer Constructor Methods](@id man-outer-constructor-methods)
"""

# ╔═╡ 03bcfadc-9e19-11eb-0dd2-6d226f450e14
md"""
A constructor is just like any other function in Julia in that its overall behavior is defined by the combined behavior of its methods. Accordingly, you can add functionality to a constructor by simply defining new methods. For example, let's say you want to add a constructor method for `Foo` objects that takes only one argument and uses the given value for both the `bar` and `baz` fields. This is simple:
"""

# ╔═╡ 03bcfd5c-9e19-11eb-276b-cf40fc7884aa
Foo(x) = Foo(x,x)

# ╔═╡ 03bcfd66-9e19-11eb-03d0-63f71219b0ba
Foo(1)

# ╔═╡ 03bcfd84-9e19-11eb-3e6b-059261645a6d
md"""
You could also add a zero-argument `Foo` constructor method that supplies default values for both of the `bar` and `baz` fields:
"""

# ╔═╡ 03bcff64-9e19-11eb-02fb-df28bbbef287
Foo() = Foo(0)

# ╔═╡ 03bcff6e-9e19-11eb-2892-c91e8f976cd2
Foo()

# ╔═╡ 03bcffd2-9e19-11eb-02d4-e3d70a3c7531
md"""
Here the zero-argument constructor method calls the single-argument constructor method, which in turn calls the automatically provided two-argument constructor method. For reasons that will become clear very shortly, additional constructor methods declared as normal methods like this are called *outer* constructor methods. Outer constructor methods can only ever create a new instance by calling another constructor method, such as the automatically provided default ones.
"""

# ╔═╡ 03bcfff0-9e19-11eb-2076-91b57668a230
md"""
## [Inner Constructor Methods](@id man-inner-constructor-methods)
"""

# ╔═╡ 03bd000e-9e19-11eb-3743-7319d41bca22
md"""
While outer constructor methods succeed in addressing the problem of providing additional convenience methods for constructing objects, they fail to address the other two use cases mentioned in the introduction of this chapter: enforcing invariants, and allowing construction of self-referential objects. For these problems, one needs *inner* constructor methods. An inner constructor method is like an outer constructor method, except for two differences:
"""

# ╔═╡ 03bd00fe-9e19-11eb-35c1-232d046a0492
md"""
1. It is declared inside the block of a type declaration, rather than outside of it like normal methods.
2. It has access to a special locally existent function called [`new`](@ref) that creates objects of the block's type.
"""

# ╔═╡ 03bd011c-9e19-11eb-157d-a16478f4917f
md"""
For example, suppose one wants to declare a type that holds a pair of real numbers, subject to the constraint that the first number is not greater than the second one. One could declare it like this:
"""

# ╔═╡ 03bd0aae-9e19-11eb-0622-750c6692c9ef
struct OrderedPair
           x::Real
           y::Real
           OrderedPair(x,y) = x > y ? error("out of order") : new(x,y)
       end

# ╔═╡ 03bd0b1c-9e19-11eb-1018-41b8cbd88fb9
md"""
Now `OrderedPair` objects can only be constructed such that `x <= y`:
"""

# ╔═╡ 03bd10d0-9e19-11eb-374e-1dfcaa160e1d
OrderedPair(1, 2)

# ╔═╡ 03bd10dc-9e19-11eb-3202-dd5557852056
OrderedPair(2,1)

# ╔═╡ 03bd1134-9e19-11eb-2463-c11819e4c020
md"""
If the type were declared `mutable`, you could reach in and directly change the field values to violate this invariant. Of course, messing around with an object's internals uninvited is bad practice. You (or someone else) can also provide additional outer constructor methods at any later point, but once a type is declared, there is no way to add more inner constructor methods. Since outer constructor methods can only create objects by calling other constructor methods, ultimately, some inner constructor must be called to create an object. This guarantees that all objects of the declared type must come into existence by a call to one of the inner constructor methods provided with the type, thereby giving some degree of enforcement of a type's invariants.
"""

# ╔═╡ 03bd117a-9e19-11eb-0095-f12450aa7d56
md"""
If any inner constructor method is defined, no default constructor method is provided: it is presumed that you have supplied yourself with all the inner constructors you need. The default constructor is equivalent to writing your own inner constructor method that takes all of the object's fields as parameters (constrained to be of the correct type, if the corresponding field has a type), and passes them to `new`, returning the resulting object:
"""

# ╔═╡ 03bd14ae-9e19-11eb-3a4a-eb588eb84bc6
struct Foo
           bar
           baz
           Foo(bar,baz) = new(bar,baz)
       end

# ╔═╡ 03bd14cc-9e19-11eb-1c9d-2d576d569471
md"""
This declaration has the same effect as the earlier definition of the `Foo` type without an explicit inner constructor method. The following two types are equivalent – one with a default constructor, the other with an explicit constructor:
"""

# ╔═╡ 03bd1c4a-9e19-11eb-16e7-b703ed1d9a6b
struct T1
           x::Int64
       end

# ╔═╡ 03bd1c6a-9e19-11eb-06eb-bd8cf8c89f41
struct T2
           x::Int64
           T2(x) = new(x)
       end

# ╔═╡ 03bd1c74-9e19-11eb-17a8-311377563081
T1(1)

# ╔═╡ 03bd1c74-9e19-11eb-3151-7b2609dfdfcd
T2(1)

# ╔═╡ 03bd1c7c-9e19-11eb-3d7a-ddbbd875dae3
T1(1.0)

# ╔═╡ 03bd1c7c-9e19-11eb-35d3-6f08bf78f369
T2(1.0)

# ╔═╡ 03bd1ca6-9e19-11eb-0a91-29e72ad62364
md"""
It is good practice to provide as few inner constructor methods as possible: only those taking all arguments explicitly and enforcing essential error checking and transformation. Additional convenience constructor methods, supplying default values or auxiliary transformations, should be provided as outer constructors that call the inner constructors to do the heavy lifting. This separation is typically quite natural.
"""

# ╔═╡ 03bd1cce-9e19-11eb-0371-a51111290d37
md"""
## Incomplete Initialization
"""

# ╔═╡ 03bd1ce2-9e19-11eb-3844-5361fc59f2f3
md"""
The final problem which has still not been addressed is construction of self-referential objects, or more generally, recursive data structures. Since the fundamental difficulty may not be immediately obvious, let us briefly explain it. Consider the following recursive type declaration:
"""

# ╔═╡ 03bd1e90-9e19-11eb-1df8-9b167008c0c9
mutable struct SelfReferential
           obj::SelfReferential
       end

# ╔═╡ 03bd1eba-9e19-11eb-091b-7b8c9ade79c3
md"""
This type may appear innocuous enough, until one considers how to construct an instance of it. If `a` is an instance of `SelfReferential`, then a second instance can be created by the call:
"""

# ╔═╡ 03bd1fe4-9e19-11eb-289d-61571b393df0
b = SelfReferential(a)

# ╔═╡ 03bd2002-9e19-11eb-1c9b-59d1b810ce62
md"""
But how does one construct the first instance when no instance exists to provide as a valid value for its `obj` field? The only solution is to allow creating an incompletely initialized instance of `SelfReferential` with an unassigned `obj` field, and using that incomplete instance as a valid value for the `obj` field of another instance, such as, for example, itself.
"""

# ╔═╡ 03bd2048-9e19-11eb-0701-456d4db4aea5
md"""
To allow for the creation of incompletely initialized objects, Julia allows the [`new`](@ref) function to be called with fewer than the number of fields that the type has, returning an object with the unspecified fields uninitialized. The inner constructor method can then use the incomplete object, finishing its initialization before returning it. Here, for example, is another attempt at defining the `SelfReferential` type, this time using a zero-argument inner constructor returning instances having `obj` fields pointing to themselves:
"""

# ╔═╡ 03bd2462-9e19-11eb-28e4-f5cc990c2648
mutable struct SelfReferential
           obj::SelfReferential
           SelfReferential() = (x = new(); x.obj = x)
       end

# ╔═╡ 03bd2476-9e19-11eb-0e4e-37a4eed87d1f
md"""
We can verify that this constructor works and constructs objects that are, in fact, self-referential:
"""

# ╔═╡ 03bd2840-9e19-11eb-3ef9-b33038230b7b
x = SelfReferential();

# ╔═╡ 03bd2860-9e19-11eb-0fe3-390593abbb28
x === x

# ╔═╡ 03bd2860-9e19-11eb-3b2e-c7db334c0f4a
x === x.obj

# ╔═╡ 03bd2868-9e19-11eb-22ed-9f4684066f9f
x === x.obj.obj

# ╔═╡ 03bd287c-9e19-11eb-2eb6-f5d022519431
md"""
Although it is generally a good idea to return a fully initialized object from an inner constructor, it is possible to return incompletely initialized objects:
"""

# ╔═╡ 03bd2bc2-9e19-11eb-1867-fdf69b40d54a
mutable struct Incomplete
           data
           Incomplete() = new()
       end

# ╔═╡ 03bd2bd8-9e19-11eb-3fe2-a99ebc905893
z = Incomplete();

# ╔═╡ 03bd2bec-9e19-11eb-25db-f7d262032970
md"""
While you are allowed to create objects with uninitialized fields, any access to an uninitialized reference is an immediate error:
"""

# ╔═╡ 03bd2c8c-9e19-11eb-2507-19872dca5e4e
z.data

# ╔═╡ 03bd2caa-9e19-11eb-1dcf-41e7f03d979b
md"""
This avoids the need to continually check for `null` values. However, not all object fields are references. Julia considers some types to be "plain data", meaning all of their data is self-contained and does not reference other objects. The plain data types consist of primitive types (e.g. `Int`) and immutable structs of other plain data types. The initial contents of a plain data type is undefined:
"""

# ╔═╡ 03bd2fde-9e19-11eb-1f50-8d5b3019f78c
struct HasPlain
           n::Int
           HasPlain() = new()
       end

# ╔═╡ 03bd2fde-9e19-11eb-3ced-81518fb093d9
HasPlain()

# ╔═╡ 03bd2ffc-9e19-11eb-2280-fb2a65efec50
md"""
Arrays of plain data types exhibit the same behavior.
"""

# ╔═╡ 03bd3010-9e19-11eb-393c-f1b72347d316
md"""
You can pass incomplete objects to other functions from inner constructors to delegate their completion:
"""

# ╔═╡ 03bd3376-9e19-11eb-0ff3-79c596ae7b21
mutable struct Lazy
           data
           Lazy(v) = complete_me(new(), v)
       end

# ╔═╡ 03bd3394-9e19-11eb-2b74-63358dc4de6f
md"""
As with incomplete objects returned from constructors, if `complete_me` or any of its callees try to access the `data` field of the `Lazy` object before it has been initialized, an error will be thrown immediately.
"""

# ╔═╡ 03bd33b2-9e19-11eb-167f-e355cafa4f2d
md"""
## Parametric Constructors
"""

# ╔═╡ 03bd33e4-9e19-11eb-1d2e-f30b997563df
md"""
Parametric types add a few wrinkles to the constructor story. Recall from [Parametric Types](@ref) that, by default, instances of parametric composite types can be constructed either with explicitly given type parameters or with type parameters implied by the types of the arguments given to the constructor. Here are some examples:
"""

# ╔═╡ 03bd3f38-9e19-11eb-1f87-7d6526ac94cc
struct Point{T<:Real}
           x::T
           y::T
       end

# ╔═╡ 03bd3f42-9e19-11eb-0cfe-dd270a378fed
Point(1,2) ## implicit T ##

# ╔═╡ 03bd3f42-9e19-11eb-3104-d9e1debaf9c5
Point(1.0,2.5) ## implicit T ##

# ╔═╡ 03bd3f56-9e19-11eb-0905-1198a9176793
Point(1,2.5) ## implicit T ##

# ╔═╡ 03bd3f56-9e19-11eb-2915-eb849ac31e69
Point{Int64}(1, 2) ## explicit T ##

# ╔═╡ 03bd3f60-9e19-11eb-3d18-b5e9141ada15
Point{Int64}(1.0,2.5) ## explicit T ##

# ╔═╡ 03bd3f60-9e19-11eb-147d-799386945272
Point{Float64}(1.0, 2.5) ## explicit T ##

# ╔═╡ 03bd3f6a-9e19-11eb-2cbc-af6f2e21e5f6
Point{Float64}(1,2) ## explicit T ##

# ╔═╡ 03bd3fb2-9e19-11eb-2770-255a51e494e5
md"""
As you can see, for constructor calls with explicit type parameters, the arguments are converted to the implied field types: `Point{Int64}(1,2)` works, but `Point{Int64}(1.0,2.5)` raises an [`InexactError`](@ref) when converting `2.5` to [`Int64`](@ref). When the type is implied by the arguments to the constructor call, as in `Point(1,2)`, then the types of the arguments must agree – otherwise the `T` cannot be determined – but any pair of real arguments with matching type may be given to the generic `Point` constructor.
"""

# ╔═╡ 03bd3fe0-9e19-11eb-24fe-77ed9e0f2e6f
md"""
What's really going on here is that `Point`, `Point{Float64}` and `Point{Int64}` are all different constructor functions. In fact, `Point{T}` is a distinct constructor function for each type `T`. Without any explicitly provided inner constructors, the declaration of the composite type `Point{T<:Real}` automatically provides an inner constructor, `Point{T}`, for each possible type `T<:Real`, that behaves just like non-parametric default inner constructors do. It also provides a single general outer `Point` constructor that takes pairs of real arguments, which must be of the same type. This automatic provision of constructors is equivalent to the following explicit declaration:
"""

# ╔═╡ 03bd487a-9e19-11eb-393e-012e37249954
struct Point{T<:Real}
           x::T
           y::T
           Point{T}(x,y) where {T<:Real} = new(x,y)
       end

# ╔═╡ 03bd4882-9e19-11eb-0f9a-db327aacf65f
Point(x::T, y::T) where {T<:Real} = Point{T}(x,y);

# ╔═╡ 03bd48b6-9e19-11eb-345c-618eaebc118c
md"""
Notice that each definition looks like the form of constructor call that it handles. The call `Point{Int64}(1,2)` will invoke the definition `Point{T}(x,y)` inside the `struct` block. The outer constructor declaration, on the other hand, defines a method for the general `Point` constructor which only applies to pairs of values of the same real type. This declaration makes constructor calls without explicit type parameters, like `Point(1,2)` and `Point(1.0,2.5)`, work. Since the method declaration restricts the arguments to being of the same type, calls like `Point(1,2.5)`, with arguments of different types, result in "no method" errors.
"""

# ╔═╡ 03bd48d4-9e19-11eb-047e-cb599a7a5bf6
md"""
Suppose we wanted to make the constructor call `Point(1,2.5)` work by "promoting" the integer value `1` to the floating-point value `1.0`. The simplest way to achieve this is to define the following additional outer constructor method:
"""

# ╔═╡ 03bd4bae-9e19-11eb-32ee-837b6624750a
Point(x::Int64, y::Float64) = Point(convert(Float64,x),y);

# ╔═╡ 03bd4bfe-9e19-11eb-03c0-fd40fe7f4547
md"""
This method uses the [`convert`](@ref) function to explicitly convert `x` to [`Float64`](@ref) and then delegates construction to the general constructor for the case where both arguments are [`Float64`](@ref). With this method definition what was previously a [`MethodError`](@ref) now successfully creates a point of type `Point{Float64}`:
"""

# ╔═╡ 03bd4e4c-9e19-11eb-3365-53974d6ebfeb
p = Point(1,2.5)

# ╔═╡ 03bd4e56-9e19-11eb-28bb-6f91805a87d0
typeof(p)

# ╔═╡ 03bd4e6a-9e19-11eb-07a7-5d880cf97887
md"""
However, other similar calls still don't work:
"""

# ╔═╡ 03bd4f8c-9e19-11eb-281f-6309b0b88b83
Point(1.5,2)

# ╔═╡ 03bd4fb4-9e19-11eb-0ff4-d14b0513dfe1
md"""
For a more general way to make all such calls work sensibly, see [Conversion and Promotion](@ref conversion-and-promotion). At the risk of spoiling the suspense, we can reveal here that all it takes is the following outer method definition to make all calls to the general `Point` constructor work as one would expect:
"""

# ╔═╡ 03bd52b6-9e19-11eb-3b73-33a8c3bea7c2
Point(x::Real, y::Real) = Point(promote(x,y)...);

# ╔═╡ 03bd52de-9e19-11eb-38a3-bbf12bd056d8
md"""
The `promote` function converts all its arguments to a common type – in this case [`Float64`](@ref). With this method definition, the `Point` constructor promotes its arguments the same way that numeric operators like [`+`](@ref) do, and works for all kinds of real numbers:
"""

# ╔═╡ 03bd5770-9e19-11eb-2417-e3e2c7ac152c
Point(1.5,2)

# ╔═╡ 03bd5770-9e19-11eb-1d6a-a12b3fceb7ef
Point(1,1//2)

# ╔═╡ 03bd577a-9e19-11eb-290b-0b513e2472eb
Point(1.0,1//2)

# ╔═╡ 03bd578e-9e19-11eb-11f2-9fa0ba37088f
md"""
Thus, while the implicit type parameter constructors provided by default in Julia are fairly strict, it is possible to make them behave in a more relaxed but sensible manner quite easily. Moreover, since constructors can leverage all of the power of the type system, methods, and multiple dispatch, defining sophisticated behavior is typically quite simple.
"""

# ╔═╡ 03bd57ac-9e19-11eb-194a-654835d15601
md"""
## Case Study: Rational
"""

# ╔═╡ 03bd57d4-9e19-11eb-309d-89ceb413c41e
md"""
Perhaps the best way to tie all these pieces together is to present a real world example of a parametric composite type and its constructor methods. To that end, we implement our own rational number type `OurRational`, similar to Julia's built-in [`Rational`](@ref) type, defined in [`rational.jl`](https://github.com/JuliaLang/julia/blob/master/base/rational.jl):
"""

# ╔═╡ 03bd81aa-9e19-11eb-06d7-e7383a586d08
struct OurRational{T<:Integer} <: Real
           num::T
           den::T
           function OurRational{T}(num::T, den::T) where T<:Integer
               if num == 0 && den == 0
                    error("invalid rational: 0//0")
               end
               g = gcd(den, num)
               num = div(num, g)
               den = div(den, g)
               new(num, den)
           end
       end

# ╔═╡ 03bd81b4-9e19-11eb-3b5f-47a3d55bf3c3
OurRational(n::T, d::T) where {T<:Integer} = OurRational{T}(n,d)

# ╔═╡ 03bd81c8-9e19-11eb-371d-9182e9fa02cd
OurRational(n::Integer, d::Integer) = OurRational(promote(n,d)...)

# ╔═╡ 03bd81d0-9e19-11eb-1cf6-0def731a9e28
OurRational(n::Integer) = OurRational(n,one(n))

# ╔═╡ 03bd81d0-9e19-11eb-1e69-c9a1aa2fdfa2
⊘(n::Integer, d::Integer) = OurRational(n,d)

# ╔═╡ 03bd81dc-9e19-11eb-3da3-2bd7cc978d1f
⊘(x::OurRational, y::Integer) = x.num ⊘ (x.den*y)

# ╔═╡ 03bd81dc-9e19-11eb-0e60-3981cf31dc13
⊘(x::Integer, y::OurRational) = (x*y.den) ⊘ y.num

# ╔═╡ 03bd81e6-9e19-11eb-3fba-8fc20c25a4bf
⊘(x::Complex, y::Real) = complex(real(x) ⊘ y, imag(x) ⊘ y)

# ╔═╡ 03bd81f0-9e19-11eb-027d-fbf2a5044beb
⊘(x::Real, y::Complex) = (x*y') ⊘ real(y*y')

# ╔═╡ 03bd81f0-9e19-11eb-0b64-51e4b6b962d5
function ⊘(x::Complex, y::Complex)
           xy = x*y'
           yy = real(y*y')
           complex(real(xy) ⊘ yy, imag(xy) ⊘ yy)
       end

# ╔═╡ 03bd822c-9e19-11eb-1589-4997e1cfeb97
md"""
The first line – `struct OurRational{T<:Integer} <: Real` – declares that `OurRational` takes one type parameter of an integer type, and is itself a real type. The field declarations `num::T` and `den::T` indicate that the data held in a `OurRational{T}` object are a pair of integers of type `T`, one representing the rational value's numerator and the other representing its denominator.
"""

# ╔═╡ 03bd825e-9e19-11eb-0bf7-7d98651829fa
md"""
Now things get interesting. `OurRational` has a single inner constructor method which checks that `num` and `den` aren't both zero and ensures that every rational is constructed in "lowest terms" with a non-negative denominator. This is accomplished by dividing the given numerator and denominator values by their greatest common divisor, computed using the `gcd` function. Since `gcd` returns the greatest common divisor of its arguments with sign matching the first argument (`den` here), after this division the new value of `den` is guaranteed to be non-negative. Because this is the only inner constructor for `OurRational`, we can be certain that `OurRational` objects are always constructed in this normalized form.
"""

# ╔═╡ 03bd8286-9e19-11eb-32b4-9d7687a458a8
md"""
`OurRational` also provides several outer constructor methods for convenience. The first is the "standard" general constructor that infers the type parameter `T` from the type of the numerator and denominator when they have the same type. The second applies when the given numerator and denominator values have different types: it promotes them to a common type and then delegates construction to the outer constructor for arguments of matching type. The third outer constructor turns integer values into rationals by supplying a value of `1` as the denominator.
"""

# ╔═╡ 03bd82cc-9e19-11eb-326c-652cda9b5ac4
md"""
Following the outer constructor definitions, we defined a number of methods for the `⊘` operator, which provides a syntax for writing rationals (e.g. `1 ⊘ 2`). Julia's `Rational` type uses the [`//`](@ref) operator for this purpose. Before these definitions, `⊘` is a completely undefined operator with only syntax and no meaning. Afterwards, it behaves just as described in [Rational Numbers](@ref) – its entire behavior is defined in these few lines. The first and most basic definition just makes `a ⊘ b` construct a `OurRational` by applying the `OurRational` constructor to `a` and `b` when they are integers. When one of the operands of `⊘` is already a rational number, we construct a new rational for the resulting ratio slightly differently; this behavior is actually identical to division of a rational with an integer. Finally, applying `⊘` to complex integral values creates an instance of `Complex{OurRational}` – a complex number whose real and imaginary parts are rationals:
"""

# ╔═╡ 03bd87f4-9e19-11eb-2304-a1ac5b5af3ee
z = (1 + 2im) ⊘ (1 - 2im);

# ╔═╡ 03bd8808-9e19-11eb-0d1a-e16d155f5b85
typeof(z)

# ╔═╡ 03bd8808-9e19-11eb-174d-67c6f91ad152
typeof(z) <: Complex{OurRational}

# ╔═╡ 03bd883a-9e19-11eb-032d-61b3c5f3579b
md"""
Thus, although the `⊘` operator usually returns an instance of `OurRational`, if either of its arguments are complex integers, it will return an instance of `Complex{OurRational}` instead. The interested reader should consider perusing the rest of [`rational.jl`](https://github.com/JuliaLang/julia/blob/master/base/rational.jl): it is short, self-contained, and implements an entire basic Julia type.
"""

# ╔═╡ 03bd884e-9e19-11eb-1549-a9175c3c998c
md"""
## Outer-only constructors
"""

# ╔═╡ 03bd8878-9e19-11eb-1b7a-011ee44f15d6
md"""
As we have seen, a typical parametric type has inner constructors that are called when type parameters are known; e.g. they apply to `Point{Int}` but not to `Point`. Optionally, outer constructors that determine type parameters automatically can be added, for example constructing a `Point{Int}` from the call `Point(1,2)`. Outer constructors call inner constructors to actually make instances. However, in some cases one would rather not provide inner constructors, so that specific type parameters cannot be requested manually.
"""

# ╔═╡ 03bd888a-9e19-11eb-3f25-a34bd73b4eb1
md"""
For example, say we define a type that stores a vector along with an accurate representation of its sum:
"""

# ╔═╡ 03bd8f2e-9e19-11eb-3a81-295b3969f9b8
struct SummedArray{T<:Number,S<:Number}
           data::Vector{T}
           sum::S
       end

# ╔═╡ 03bd8f38-9e19-11eb-0a7c-9982d0e366e2
SummedArray(Int32[1; 2; 3], Int32(6))

# ╔═╡ 03bd8f74-9e19-11eb-0920-afb681b520e2
md"""
The problem is that we want `S` to be a larger type than `T`, so that we can sum many elements with less information loss. For example, when `T` is [`Int32`](@ref), we would like `S` to be [`Int64`](@ref). Therefore we want to avoid an interface that allows the user to construct instances of the type `SummedArray{Int32,Int32}`. One way to do this is to provide a constructor only for `SummedArray`, but inside the `struct` definition block to suppress generation of default constructors:
"""

# ╔═╡ 03bd997e-9e19-11eb-03fc-c56631a0fc7b
struct SummedArray{T<:Number,S<:Number}
           data::Vector{T}
           sum::S
           function SummedArray(a::Vector{T}) where T
               S = widen(T)
               new{T,S}(a, sum(S, a))
           end
       end

# ╔═╡ 03bd9988-9e19-11eb-0641-e92a09a6dc3b
SummedArray(Int32[1; 2; 3], Int32(6))

# ╔═╡ 03bd99b0-9e19-11eb-2234-732e34040148
md"""
This constructor will be invoked by the syntax `SummedArray(a)`. The syntax `new{T,S}` allows specifying parameters for the type to be constructed, i.e. this call will return a `SummedArray{T,S}`. `new{T,S}` can be used in any constructor definition, but for convenience the parameters to `new{}` are automatically derived from the type being constructed when possible.
"""

# ╔═╡ Cell order:
# ╟─03bcef1a-9e19-11eb-0510-dd1c5c379cfa
# ╟─03bcef92-9e19-11eb-3424-7fe8d8ccec95
# ╠═03bcf898-9e19-11eb-0f23-f17dc6ec4952
# ╠═03bcf8a2-9e19-11eb-2ed7-1bf5632d7007
# ╠═03bcf8ac-9e19-11eb-0598-877bf1f9fce3
# ╠═03bcf8b4-9e19-11eb-030b-4f17e10e6cd3
# ╟─03bcf906-9e19-11eb-0adc-473c8a66014b
# ╟─03bcfa64-9e19-11eb-274b-cf5c0a6f8c11
# ╟─03bcfaaa-9e19-11eb-01b1-53a408dcb377
# ╟─03bcfadc-9e19-11eb-0dd2-6d226f450e14
# ╠═03bcfd5c-9e19-11eb-276b-cf40fc7884aa
# ╠═03bcfd66-9e19-11eb-03d0-63f71219b0ba
# ╟─03bcfd84-9e19-11eb-3e6b-059261645a6d
# ╠═03bcff64-9e19-11eb-02fb-df28bbbef287
# ╠═03bcff6e-9e19-11eb-2892-c91e8f976cd2
# ╟─03bcffd2-9e19-11eb-02d4-e3d70a3c7531
# ╟─03bcfff0-9e19-11eb-2076-91b57668a230
# ╟─03bd000e-9e19-11eb-3743-7319d41bca22
# ╟─03bd00fe-9e19-11eb-35c1-232d046a0492
# ╟─03bd011c-9e19-11eb-157d-a16478f4917f
# ╠═03bd0aae-9e19-11eb-0622-750c6692c9ef
# ╟─03bd0b1c-9e19-11eb-1018-41b8cbd88fb9
# ╠═03bd10d0-9e19-11eb-374e-1dfcaa160e1d
# ╠═03bd10dc-9e19-11eb-3202-dd5557852056
# ╟─03bd1134-9e19-11eb-2463-c11819e4c020
# ╟─03bd117a-9e19-11eb-0095-f12450aa7d56
# ╠═03bd14ae-9e19-11eb-3a4a-eb588eb84bc6
# ╟─03bd14cc-9e19-11eb-1c9d-2d576d569471
# ╠═03bd1c4a-9e19-11eb-16e7-b703ed1d9a6b
# ╠═03bd1c6a-9e19-11eb-06eb-bd8cf8c89f41
# ╠═03bd1c74-9e19-11eb-17a8-311377563081
# ╠═03bd1c74-9e19-11eb-3151-7b2609dfdfcd
# ╠═03bd1c7c-9e19-11eb-3d7a-ddbbd875dae3
# ╠═03bd1c7c-9e19-11eb-35d3-6f08bf78f369
# ╟─03bd1ca6-9e19-11eb-0a91-29e72ad62364
# ╟─03bd1cce-9e19-11eb-0371-a51111290d37
# ╟─03bd1ce2-9e19-11eb-3844-5361fc59f2f3
# ╠═03bd1e90-9e19-11eb-1df8-9b167008c0c9
# ╟─03bd1eba-9e19-11eb-091b-7b8c9ade79c3
# ╠═03bd1fe4-9e19-11eb-289d-61571b393df0
# ╟─03bd2002-9e19-11eb-1c9b-59d1b810ce62
# ╟─03bd2048-9e19-11eb-0701-456d4db4aea5
# ╠═03bd2462-9e19-11eb-28e4-f5cc990c2648
# ╟─03bd2476-9e19-11eb-0e4e-37a4eed87d1f
# ╠═03bd2840-9e19-11eb-3ef9-b33038230b7b
# ╠═03bd2860-9e19-11eb-0fe3-390593abbb28
# ╠═03bd2860-9e19-11eb-3b2e-c7db334c0f4a
# ╠═03bd2868-9e19-11eb-22ed-9f4684066f9f
# ╟─03bd287c-9e19-11eb-2eb6-f5d022519431
# ╠═03bd2bc2-9e19-11eb-1867-fdf69b40d54a
# ╠═03bd2bd8-9e19-11eb-3fe2-a99ebc905893
# ╟─03bd2bec-9e19-11eb-25db-f7d262032970
# ╠═03bd2c8c-9e19-11eb-2507-19872dca5e4e
# ╟─03bd2caa-9e19-11eb-1dcf-41e7f03d979b
# ╠═03bd2fde-9e19-11eb-1f50-8d5b3019f78c
# ╠═03bd2fde-9e19-11eb-3ced-81518fb093d9
# ╟─03bd2ffc-9e19-11eb-2280-fb2a65efec50
# ╟─03bd3010-9e19-11eb-393c-f1b72347d316
# ╠═03bd3376-9e19-11eb-0ff3-79c596ae7b21
# ╟─03bd3394-9e19-11eb-2b74-63358dc4de6f
# ╟─03bd33b2-9e19-11eb-167f-e355cafa4f2d
# ╟─03bd33e4-9e19-11eb-1d2e-f30b997563df
# ╠═03bd3f38-9e19-11eb-1f87-7d6526ac94cc
# ╠═03bd3f42-9e19-11eb-0cfe-dd270a378fed
# ╠═03bd3f42-9e19-11eb-3104-d9e1debaf9c5
# ╠═03bd3f56-9e19-11eb-0905-1198a9176793
# ╠═03bd3f56-9e19-11eb-2915-eb849ac31e69
# ╠═03bd3f60-9e19-11eb-3d18-b5e9141ada15
# ╠═03bd3f60-9e19-11eb-147d-799386945272
# ╠═03bd3f6a-9e19-11eb-2cbc-af6f2e21e5f6
# ╟─03bd3fb2-9e19-11eb-2770-255a51e494e5
# ╟─03bd3fe0-9e19-11eb-24fe-77ed9e0f2e6f
# ╠═03bd487a-9e19-11eb-393e-012e37249954
# ╠═03bd4882-9e19-11eb-0f9a-db327aacf65f
# ╟─03bd48b6-9e19-11eb-345c-618eaebc118c
# ╟─03bd48d4-9e19-11eb-047e-cb599a7a5bf6
# ╠═03bd4bae-9e19-11eb-32ee-837b6624750a
# ╟─03bd4bfe-9e19-11eb-03c0-fd40fe7f4547
# ╠═03bd4e4c-9e19-11eb-3365-53974d6ebfeb
# ╠═03bd4e56-9e19-11eb-28bb-6f91805a87d0
# ╟─03bd4e6a-9e19-11eb-07a7-5d880cf97887
# ╠═03bd4f8c-9e19-11eb-281f-6309b0b88b83
# ╟─03bd4fb4-9e19-11eb-0ff4-d14b0513dfe1
# ╠═03bd52b6-9e19-11eb-3b73-33a8c3bea7c2
# ╟─03bd52de-9e19-11eb-38a3-bbf12bd056d8
# ╠═03bd5770-9e19-11eb-2417-e3e2c7ac152c
# ╠═03bd5770-9e19-11eb-1d6a-a12b3fceb7ef
# ╠═03bd577a-9e19-11eb-290b-0b513e2472eb
# ╟─03bd578e-9e19-11eb-11f2-9fa0ba37088f
# ╟─03bd57ac-9e19-11eb-194a-654835d15601
# ╟─03bd57d4-9e19-11eb-309d-89ceb413c41e
# ╠═03bd81aa-9e19-11eb-06d7-e7383a586d08
# ╠═03bd81b4-9e19-11eb-3b5f-47a3d55bf3c3
# ╠═03bd81c8-9e19-11eb-371d-9182e9fa02cd
# ╠═03bd81d0-9e19-11eb-1cf6-0def731a9e28
# ╠═03bd81d0-9e19-11eb-1e69-c9a1aa2fdfa2
# ╠═03bd81dc-9e19-11eb-3da3-2bd7cc978d1f
# ╠═03bd81dc-9e19-11eb-0e60-3981cf31dc13
# ╠═03bd81e6-9e19-11eb-3fba-8fc20c25a4bf
# ╠═03bd81f0-9e19-11eb-027d-fbf2a5044beb
# ╠═03bd81f0-9e19-11eb-0b64-51e4b6b962d5
# ╟─03bd822c-9e19-11eb-1589-4997e1cfeb97
# ╟─03bd825e-9e19-11eb-0bf7-7d98651829fa
# ╟─03bd8286-9e19-11eb-32b4-9d7687a458a8
# ╟─03bd82cc-9e19-11eb-326c-652cda9b5ac4
# ╠═03bd87f4-9e19-11eb-2304-a1ac5b5af3ee
# ╠═03bd8808-9e19-11eb-0d1a-e16d155f5b85
# ╠═03bd8808-9e19-11eb-174d-67c6f91ad152
# ╟─03bd883a-9e19-11eb-032d-61b3c5f3579b
# ╟─03bd884e-9e19-11eb-1549-a9175c3c998c
# ╟─03bd8878-9e19-11eb-1b7a-011ee44f15d6
# ╟─03bd888a-9e19-11eb-3f25-a34bd73b4eb1
# ╠═03bd8f2e-9e19-11eb-3a81-295b3969f9b8
# ╠═03bd8f38-9e19-11eb-0a7c-9982d0e366e2
# ╟─03bd8f74-9e19-11eb-0920-afb681b520e2
# ╠═03bd997e-9e19-11eb-03fc-c56631a0fc7b
# ╠═03bd9988-9e19-11eb-0641-e92a09a6dc3b
# ╟─03bd99b0-9e19-11eb-2234-732e34040148
