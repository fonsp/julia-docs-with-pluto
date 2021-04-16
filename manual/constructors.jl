### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ 030af795-1953-46b6-b462-b8e4ad2dd64e
md"""
# [Constructors](@id man-constructors)
"""

# ╔═╡ 2c50014b-e00a-42d8-975e-25345f06772a
md"""
Constructors [^1] are functions that create new objects – specifically, instances of [Composite Types](@ref). In Julia, type objects also serve as constructor functions: they create new instances of themselves when applied to an argument tuple as a function. This much was already mentioned briefly when composite types were introduced. For example:
"""

# ╔═╡ a2fe404c-b9c6-46af-ab74-41cccf09117b
struct Foo
     bar
     baz
 end

# ╔═╡ ecd15023-ae24-4d77-ab47-8906f7cd0223
foo = Foo(1, 2)

# ╔═╡ 3a1a1461-66e6-4f84-82bc-9b002ce47d07
foo.bar

# ╔═╡ bc42170d-716b-4524-9c2c-7b80ba564bc1
foo.baz

# ╔═╡ 122d1815-e12a-45f0-a07a-d6cc950d3f70
md"""
For many types, forming new objects by binding their field values together is all that is ever needed to create instances. However, in some cases more functionality is required when creating composite objects. Sometimes invariants must be enforced, either by checking arguments or by transforming them. [Recursive data structures](https://en.wikipedia.org/wiki/Recursion_%28computer_science%29#Recursive_data_structures_.28structural_recursion.29), especially those that may be self-referential, often cannot be constructed cleanly without first being created in an incomplete state and then altered programmatically to be made whole, as a separate step from object creation. Sometimes, it's just convenient to be able to construct objects with fewer or different types of parameters than they have fields. Julia's system for object construction addresses all of these cases and more.
"""

# ╔═╡ 0e61f58f-0e7e-4b0f-b728-becfbafe1551
md"""
[^1]: Nomenclature: while the term \"constructor\" generally refers to the entire function which constructs objects of a type, it is common to abuse terminology slightly and refer to specific constructor methods as \"constructors\". In such situations, it is generally clear from the context that the term is used to mean \"constructor method\" rather than \"constructor function\", especially as it is often used in the sense of singling out a particular method of the constructor from all of the others.
"""

# ╔═╡ 3919e995-526c-4572-b042-4512d4eccf66
md"""
## [Outer Constructor Methods](@id man-outer-constructor-methods)
"""

# ╔═╡ f5043763-cd17-4371-9438-2daa810a02ad
md"""
A constructor is just like any other function in Julia in that its overall behavior is defined by the combined behavior of its methods. Accordingly, you can add functionality to a constructor by simply defining new methods. For example, let's say you want to add a constructor method for `Foo` objects that takes only one argument and uses the given value for both the `bar` and `baz` fields. This is simple:
"""

# ╔═╡ a60b9082-b409-4a08-bfe4-8e712119e8a5
Foo(x) = Foo(x,x)

# ╔═╡ e917a81e-d842-4a77-95b0-56b41c372048
Foo(1)

# ╔═╡ 0ae93dc5-527d-44db-be5f-7042b1e76b98
md"""
You could also add a zero-argument `Foo` constructor method that supplies default values for both of the `bar` and `baz` fields:
"""

# ╔═╡ cedd85cc-1f0c-4995-9e65-8b39bf72b68d
Foo() = Foo(0)

# ╔═╡ 039497c2-9de5-46ba-8f0c-99fa17d166f1
Foo()

# ╔═╡ 1473ae85-e330-44b7-b0dd-570f0623f01c
md"""
Here the zero-argument constructor method calls the single-argument constructor method, which in turn calls the automatically provided two-argument constructor method. For reasons that will become clear very shortly, additional constructor methods declared as normal methods like this are called *outer* constructor methods. Outer constructor methods can only ever create a new instance by calling another constructor method, such as the automatically provided default ones.
"""

# ╔═╡ 19bc728a-b2c5-4073-a248-a320e99eeb69
md"""
## [Inner Constructor Methods](@id man-inner-constructor-methods)
"""

# ╔═╡ bdef3455-169c-4551-b495-967dc67c7b77
md"""
While outer constructor methods succeed in addressing the problem of providing additional convenience methods for constructing objects, they fail to address the other two use cases mentioned in the introduction of this chapter: enforcing invariants, and allowing construction of self-referential objects. For these problems, one needs *inner* constructor methods. An inner constructor method is like an outer constructor method, except for two differences:
"""

# ╔═╡ e5c07f65-8e25-49a8-b8b5-4fbb7e8796d0
md"""
1. It is declared inside the block of a type declaration, rather than outside of it like normal methods.
2. It has access to a special locally existent function called [`new`](@ref) that creates objects of the block's type.
"""

# ╔═╡ f9c4e5a6-2895-45b8-af8a-67c3345bd43f
md"""
For example, suppose one wants to declare a type that holds a pair of real numbers, subject to the constraint that the first number is not greater than the second one. One could declare it like this:
"""

# ╔═╡ 733553be-e2d9-489f-8769-ceeff3170f2b
struct OrderedPair
     x::Real
     y::Real
     OrderedPair(x,y) = x > y ? error("out of order") : new(x,y)
 end

# ╔═╡ f7be527c-237a-4dc2-a5af-a37b935b952c
md"""
Now `OrderedPair` objects can only be constructed such that `x <= y`:
"""

# ╔═╡ 17422a2a-e741-43aa-a679-701a7659ce2b
OrderedPair(1, 2)

# ╔═╡ 4c932812-efff-4b39-930f-94fb3fd0b6cb
OrderedPair(2,1)

# ╔═╡ b090dd4d-cf3f-4348-a171-af4533158a4b
md"""
If the type were declared `mutable`, you could reach in and directly change the field values to violate this invariant. Of course, messing around with an object's internals uninvited is bad practice. You (or someone else) can also provide additional outer constructor methods at any later point, but once a type is declared, there is no way to add more inner constructor methods. Since outer constructor methods can only create objects by calling other constructor methods, ultimately, some inner constructor must be called to create an object. This guarantees that all objects of the declared type must come into existence by a call to one of the inner constructor methods provided with the type, thereby giving some degree of enforcement of a type's invariants.
"""

# ╔═╡ 92d3267c-d987-4900-99fd-c9c0c6439154
md"""
If any inner constructor method is defined, no default constructor method is provided: it is presumed that you have supplied yourself with all the inner constructors you need. The default constructor is equivalent to writing your own inner constructor method that takes all of the object's fields as parameters (constrained to be of the correct type, if the corresponding field has a type), and passes them to `new`, returning the resulting object:
"""

# ╔═╡ 1e3d87c6-a5d6-4fc1-a032-dc3747f0db49
struct Foo
     bar
     baz
     Foo(bar,baz) = new(bar,baz)
 end

# ╔═╡ a35cf270-50d5-45ac-baab-44f72b40be2e
md"""
This declaration has the same effect as the earlier definition of the `Foo` type without an explicit inner constructor method. The following two types are equivalent – one with a default constructor, the other with an explicit constructor:
"""

# ╔═╡ 94b33b54-04a0-4d5b-a18a-782f069c5187
struct T1
     x::Int64
 end

# ╔═╡ 877fbfe9-e132-41e8-b8f8-1a310fbb7a71
struct T2
     x::Int64
     T2(x) = new(x)
 end

# ╔═╡ c2f5690d-81e6-489d-978f-4cd541fe89c6
T1(1)

# ╔═╡ edb525dc-6e23-41f3-8636-03ff674574ba
T2(1)

# ╔═╡ dbbddb9b-9249-4207-85b0-a1f16e1108f7
T1(1.0)

# ╔═╡ f6448ea6-2729-4ca9-87b2-58e4a296d5a1
T2(1.0)

# ╔═╡ b14cc5bc-521d-4289-b88c-e0f2a4a6dcb4
md"""
It is good practice to provide as few inner constructor methods as possible: only those taking all arguments explicitly and enforcing essential error checking and transformation. Additional convenience constructor methods, supplying default values or auxiliary transformations, should be provided as outer constructors that call the inner constructors to do the heavy lifting. This separation is typically quite natural.
"""

# ╔═╡ 2732e78c-77e2-4d31-a609-b0a76a356a95
md"""
## Incomplete Initialization
"""

# ╔═╡ e4842b10-8767-4bf3-a8dd-1ef76adebd6e
md"""
The final problem which has still not been addressed is construction of self-referential objects, or more generally, recursive data structures. Since the fundamental difficulty may not be immediately obvious, let us briefly explain it. Consider the following recursive type declaration:
"""

# ╔═╡ 0db1906a-0060-4ecd-8b7f-ff4cd026abf7
mutable struct SelfReferential
     obj::SelfReferential
 end

# ╔═╡ ee7f1f2a-cab4-4053-827d-a7348c5ccea6
md"""
This type may appear innocuous enough, until one considers how to construct an instance of it. If `a` is an instance of `SelfReferential`, then a second instance can be created by the call:
"""

# ╔═╡ 9d42edcd-6744-4a90-a9dc-512dc71059b0
b = SelfReferential(a)

# ╔═╡ f4732df3-39ee-4498-851a-8f840936bde0
md"""
But how does one construct the first instance when no instance exists to provide as a valid value for its `obj` field? The only solution is to allow creating an incompletely initialized instance of `SelfReferential` with an unassigned `obj` field, and using that incomplete instance as a valid value for the `obj` field of another instance, such as, for example, itself.
"""

# ╔═╡ 245ee88d-9b69-4c97-bd52-d89d54a3441c
md"""
To allow for the creation of incompletely initialized objects, Julia allows the [`new`](@ref) function to be called with fewer than the number of fields that the type has, returning an object with the unspecified fields uninitialized. The inner constructor method can then use the incomplete object, finishing its initialization before returning it. Here, for example, is another attempt at defining the `SelfReferential` type, this time using a zero-argument inner constructor returning instances having `obj` fields pointing to themselves:
"""

# ╔═╡ c3c46d0d-6695-45d7-b0f9-890e7456ccf0
mutable struct SelfReferential
     obj::SelfReferential
     SelfReferential() = (x = new(); x.obj = x)
 end

# ╔═╡ 32a621ef-1e5f-495e-8a11-054fb6a68568
md"""
We can verify that this constructor works and constructs objects that are, in fact, self-referential:
"""

# ╔═╡ 788c11fd-1035-44cb-bd26-9545243ed7b8
x = SelfReferential();

# ╔═╡ a3e59e00-fbd8-4100-ac31-aeaf9e8cd254
x === x

# ╔═╡ e641b579-6cdb-4f22-8365-751876079cc8
x === x.obj

# ╔═╡ 23cc5922-96d5-479d-8e29-14704f82147a
x === x.obj.obj

# ╔═╡ 3e829760-f8ed-413e-bce0-3f0850e11475
md"""
Although it is generally a good idea to return a fully initialized object from an inner constructor, it is possible to return incompletely initialized objects:
"""

# ╔═╡ 13d759c3-f933-48a2-9701-de5bf4a91844
mutable struct Incomplete
     data
     Incomplete() = new()
 end

# ╔═╡ 114a6c4d-c0df-40ad-b0b4-50bab3fb18d8
z = Incomplete();

# ╔═╡ 8b01dad6-4111-4337-84b8-787efb332ef5
md"""
While you are allowed to create objects with uninitialized fields, any access to an uninitialized reference is an immediate error:
"""

# ╔═╡ 2ea81c16-0885-4e1d-9690-43c743dfaa1e
z.data

# ╔═╡ a559bed5-c44a-4d25-9eef-7e33642b7c16
md"""
This avoids the need to continually check for `null` values. However, not all object fields are references. Julia considers some types to be \"plain data\", meaning all of their data is self-contained and does not reference other objects. The plain data types consist of primitive types (e.g. `Int`) and immutable structs of other plain data types. The initial contents of a plain data type is undefined:
"""

# ╔═╡ 9c28dfc0-a990-4d69-8473-2bd55af25d72
struct HasPlain
     n::Int
     HasPlain() = new()
 end

# ╔═╡ 098d8fd6-a8bb-45ff-a5cf-e37b1b4e1b5b
HasPlain()

# ╔═╡ d10ad718-5048-4af5-846b-8cb2046a89a9
md"""
Arrays of plain data types exhibit the same behavior.
"""

# ╔═╡ 37ff8214-b81e-41cf-bee5-381dc952bf22
md"""
You can pass incomplete objects to other functions from inner constructors to delegate their completion:
"""

# ╔═╡ c98a7942-f85a-4f23-b9e5-622904c3ea0d
mutable struct Lazy
     data
     Lazy(v) = complete_me(new(), v)
 end

# ╔═╡ 34bab941-4789-4694-b382-96a24d866c1d
md"""
As with incomplete objects returned from constructors, if `complete_me` or any of its callees try to access the `data` field of the `Lazy` object before it has been initialized, an error will be thrown immediately.
"""

# ╔═╡ e5fd2a0a-469f-44f0-8f0b-44e9aa5bd3db
md"""
## Parametric Constructors
"""

# ╔═╡ bfdfdade-2059-4b17-a53d-acd15c6775c9
md"""
Parametric types add a few wrinkles to the constructor story. Recall from [Parametric Types](@ref) that, by default, instances of parametric composite types can be constructed either with explicitly given type parameters or with type parameters implied by the types of the arguments given to the constructor. Here are some examples:
"""

# ╔═╡ 2868c161-d500-4dfd-9c79-bda418574e50
struct Point{T<:Real}
     x::T
     y::T
 end

# ╔═╡ 8bb5a0f8-e165-4cba-9ce7-61b2a39a70e2
Point(1,2) ## implicit T ##

# ╔═╡ 582aacc6-5f5d-4689-9365-6a5c2457d701
Point(1.0,2.5) ## implicit T ##

# ╔═╡ ba607f41-c4bf-494c-b6b8-b00e6d2a2a86
Point(1,2.5) ## implicit T ##

# ╔═╡ 57630466-bea7-4921-a484-c49d99df7bc8
Point{Int64}(1, 2) ## explicit T ##

# ╔═╡ 86709979-c288-477a-bd94-c19261175575
Point{Int64}(1.0,2.5) ## explicit T ##

# ╔═╡ dac919d3-12df-411e-88cb-2d347218fc93
Point{Float64}(1.0, 2.5) ## explicit T ##

# ╔═╡ 6aab1cca-e05e-4fca-8ec9-785a16e4626d
Point{Float64}(1,2) ## explicit T ##

# ╔═╡ 9df15d6c-8847-4466-8906-4a41f3b0d31f
md"""
As you can see, for constructor calls with explicit type parameters, the arguments are converted to the implied field types: `Point{Int64}(1,2)` works, but `Point{Int64}(1.0,2.5)` raises an [`InexactError`](@ref) when converting `2.5` to [`Int64`](@ref). When the type is implied by the arguments to the constructor call, as in `Point(1,2)`, then the types of the arguments must agree – otherwise the `T` cannot be determined – but any pair of real arguments with matching type may be given to the generic `Point` constructor.
"""

# ╔═╡ 72e27d65-922f-43af-83e9-3cb3f1894ef2
md"""
What's really going on here is that `Point`, `Point{Float64}` and `Point{Int64}` are all different constructor functions. In fact, `Point{T}` is a distinct constructor function for each type `T`. Without any explicitly provided inner constructors, the declaration of the composite type `Point{T<:Real}` automatically provides an inner constructor, `Point{T}`, for each possible type `T<:Real`, that behaves just like non-parametric default inner constructors do. It also provides a single general outer `Point` constructor that takes pairs of real arguments, which must be of the same type. This automatic provision of constructors is equivalent to the following explicit declaration:
"""

# ╔═╡ bd92e321-816a-4a9e-86be-0cd119e7a154
struct Point{T<:Real}
     x::T
     y::T
     Point{T}(x,y) where {T<:Real} = new(x,y)
 end

# ╔═╡ e98db70e-0572-48f9-b0c8-b7ce53f09c82
Point(x::T, y::T) where {T<:Real} = Point{T}(x,y);

# ╔═╡ e2840543-dcce-434b-b6d0-f49edfd544c3
md"""
Notice that each definition looks like the form of constructor call that it handles. The call `Point{Int64}(1,2)` will invoke the definition `Point{T}(x,y)` inside the `struct` block. The outer constructor declaration, on the other hand, defines a method for the general `Point` constructor which only applies to pairs of values of the same real type. This declaration makes constructor calls without explicit type parameters, like `Point(1,2)` and `Point(1.0,2.5)`, work. Since the method declaration restricts the arguments to being of the same type, calls like `Point(1,2.5)`, with arguments of different types, result in \"no method\" errors.
"""

# ╔═╡ 50a0c1fe-a6d9-412d-9437-33df506de1dc
md"""
Suppose we wanted to make the constructor call `Point(1,2.5)` work by \"promoting\" the integer value `1` to the floating-point value `1.0`. The simplest way to achieve this is to define the following additional outer constructor method:
"""

# ╔═╡ 081739ea-b325-480c-963a-22da5c8f8188
Point(x::Int64, y::Float64) = Point(convert(Float64,x),y);

# ╔═╡ 69e3da89-4883-4b33-a49c-4afd4015432e
md"""
This method uses the [`convert`](@ref) function to explicitly convert `x` to [`Float64`](@ref) and then delegates construction to the general constructor for the case where both arguments are [`Float64`](@ref). With this method definition what was previously a [`MethodError`](@ref) now successfully creates a point of type `Point{Float64}`:
"""

# ╔═╡ 7e10fc08-c613-49b8-a035-fb607c9eec63
p = Point(1,2.5)

# ╔═╡ 69bf50e4-ceae-414f-92f9-7a3ea3c6a30b
typeof(p)

# ╔═╡ d2efad5f-5c24-4776-9892-388bfeac4280
md"""
However, other similar calls still don't work:
"""

# ╔═╡ e61cb24f-840f-4fa5-af3a-1de75b4afdf3
Point(1.5,2)

# ╔═╡ 1e49c294-7826-4a3c-87ca-d28cba02ba05
md"""
For a more general way to make all such calls work sensibly, see [Conversion and Promotion](@ref conversion-and-promotion). At the risk of spoiling the suspense, we can reveal here that all it takes is the following outer method definition to make all calls to the general `Point` constructor work as one would expect:
"""

# ╔═╡ b7fabd87-d013-4708-a1b4-d3545cbe2572
Point(x::Real, y::Real) = Point(promote(x,y)...);

# ╔═╡ c6f77231-f96a-49dc-8292-762b1ae44689
md"""
The `promote` function converts all its arguments to a common type – in this case [`Float64`](@ref). With this method definition, the `Point` constructor promotes its arguments the same way that numeric operators like [`+`](@ref) do, and works for all kinds of real numbers:
"""

# ╔═╡ 81cc44a9-148e-4864-94e6-db9a4b1c52f0
Point(1.5,2)

# ╔═╡ 8a007c9c-ec3f-469b-8b4e-96b39f41d824
Point(1,1//2)

# ╔═╡ 42c7d4a3-49c1-4438-a10c-4845cf38dc63
Point(1.0,1//2)

# ╔═╡ 1e004d0a-ee00-4892-9291-16f9a5e72a49
md"""
Thus, while the implicit type parameter constructors provided by default in Julia are fairly strict, it is possible to make them behave in a more relaxed but sensible manner quite easily. Moreover, since constructors can leverage all of the power of the type system, methods, and multiple dispatch, defining sophisticated behavior is typically quite simple.
"""

# ╔═╡ e0ae9a35-204a-4775-a1b6-d13eb8ba2ee9
md"""
## Case Study: Rational
"""

# ╔═╡ 5dca6e9b-64d0-4098-9dec-defa444d748c
md"""
Perhaps the best way to tie all these pieces together is to present a real world example of a parametric composite type and its constructor methods. To that end, we implement our own rational number type `OurRational`, similar to Julia's built-in [`Rational`](@ref) type, defined in [`rational.jl`](https://github.com/JuliaLang/julia/blob/master/base/rational.jl):
"""

# ╔═╡ 51f0b860-ae87-42bf-8b2f-ff8ee776f492
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

# ╔═╡ 4c757d33-71b5-4d1c-9cdd-96e73bd07f19
OurRational(n::T, d::T) where {T<:Integer} = OurRational{T}(n,d)

# ╔═╡ c8f26a10-ca09-428a-a634-c4bd6460d95a
OurRational(n::Integer, d::Integer) = OurRational(promote(n,d)...)

# ╔═╡ 0490ed5d-2b83-4bae-bb34-3718fc4bae59
OurRational(n::Integer) = OurRational(n,one(n))

# ╔═╡ 840d7552-6c9f-4988-a932-a7c1b2510b27
⊘(n::Integer, d::Integer) = OurRational(n,d)

# ╔═╡ 90520875-39c8-4187-8506-7bf756f2df87
⊘(x::OurRational, y::Integer) = x.num ⊘ (x.den*y)

# ╔═╡ b4a22d33-2a14-44d2-a0d6-5feda6da1aef
⊘(x::Integer, y::OurRational) = (x*y.den) ⊘ y.num

# ╔═╡ 6f14cbd4-20fc-4dbe-b247-b89d9edacc74
⊘(x::Complex, y::Real) = complex(real(x) ⊘ y, imag(x) ⊘ y)

# ╔═╡ 08a8a9a7-38f9-46ad-9832-31e46cf31ad0
⊘(x::Real, y::Complex) = (x*y') ⊘ real(y*y')

# ╔═╡ 48ea7ccf-64e0-4840-90bc-32782ac26bac
function ⊘(x::Complex, y::Complex)
     xy = x*y'
     yy = real(y*y')
     complex(real(xy) ⊘ yy, imag(xy) ⊘ yy)
 end

# ╔═╡ e5026119-01b0-4953-9ed1-290391dc6357
md"""
The first line – `struct OurRational{T<:Integer} <: Real` – declares that `OurRational` takes one type parameter of an integer type, and is itself a real type. The field declarations `num::T` and `den::T` indicate that the data held in a `OurRational{T}` object are a pair of integers of type `T`, one representing the rational value's numerator and the other representing its denominator.
"""

# ╔═╡ a3b8aa99-7c15-4e3b-b48e-ef156bf472cc
md"""
Now things get interesting. `OurRational` has a single inner constructor method which checks that `num` and `den` aren't both zero and ensures that every rational is constructed in \"lowest terms\" with a non-negative denominator. This is accomplished by dividing the given numerator and denominator values by their greatest common divisor, computed using the `gcd` function. Since `gcd` returns the greatest common divisor of its arguments with sign matching the first argument (`den` here), after this division the new value of `den` is guaranteed to be non-negative. Because this is the only inner constructor for `OurRational`, we can be certain that `OurRational` objects are always constructed in this normalized form.
"""

# ╔═╡ cc9a3f79-0355-4929-a1ff-1453f82c39a7
md"""
`OurRational` also provides several outer constructor methods for convenience. The first is the \"standard\" general constructor that infers the type parameter `T` from the type of the numerator and denominator when they have the same type. The second applies when the given numerator and denominator values have different types: it promotes them to a common type and then delegates construction to the outer constructor for arguments of matching type. The third outer constructor turns integer values into rationals by supplying a value of `1` as the denominator.
"""

# ╔═╡ bcc195bc-c7cf-4243-a3b8-206f53744d10
md"""
Following the outer constructor definitions, we defined a number of methods for the `⊘` operator, which provides a syntax for writing rationals (e.g. `1 ⊘ 2`). Julia's `Rational` type uses the [`//`](@ref) operator for this purpose. Before these definitions, `⊘` is a completely undefined operator with only syntax and no meaning. Afterwards, it behaves just as described in [Rational Numbers](@ref) – its entire behavior is defined in these few lines. The first and most basic definition just makes `a ⊘ b` construct a `OurRational` by applying the `OurRational` constructor to `a` and `b` when they are integers. When one of the operands of `⊘` is already a rational number, we construct a new rational for the resulting ratio slightly differently; this behavior is actually identical to division of a rational with an integer. Finally, applying `⊘` to complex integral values creates an instance of `Complex{OurRational}` – a complex number whose real and imaginary parts are rationals:
"""

# ╔═╡ 44d18c46-24de-46bb-95bb-dbd1c588103c
z = (1 + 2im) ⊘ (1 - 2im);

# ╔═╡ f80fc33a-8fb9-40ea-94ff-ebb24d1760c2
typeof(z)

# ╔═╡ 5069623f-e25d-4625-989e-4d111beaed14
typeof(z) <: Complex{OurRational}

# ╔═╡ 94b4e48e-7bf1-4f47-a79a-9309b65db1cb
md"""
Thus, although the `⊘` operator usually returns an instance of `OurRational`, if either of its arguments are complex integers, it will return an instance of `Complex{OurRational}` instead. The interested reader should consider perusing the rest of [`rational.jl`](https://github.com/JuliaLang/julia/blob/master/base/rational.jl): it is short, self-contained, and implements an entire basic Julia type.
"""

# ╔═╡ eb9ef1f2-18ef-4873-b199-0c2c1086426e
md"""
## Outer-only constructors
"""

# ╔═╡ a041c76e-f084-423d-8c8e-cfc897d41ecb
md"""
As we have seen, a typical parametric type has inner constructors that are called when type parameters are known; e.g. they apply to `Point{Int}` but not to `Point`. Optionally, outer constructors that determine type parameters automatically can be added, for example constructing a `Point{Int}` from the call `Point(1,2)`. Outer constructors call inner constructors to actually make instances. However, in some cases one would rather not provide inner constructors, so that specific type parameters cannot be requested manually.
"""

# ╔═╡ 9284da4c-dc63-4ffc-aab1-dc94570c2a36
md"""
For example, say we define a type that stores a vector along with an accurate representation of its sum:
"""

# ╔═╡ 349ae71f-4b92-47a1-8a41-72f3d3c3ae50
struct SummedArray{T<:Number,S<:Number}
     data::Vector{T}
     sum::S
 end

# ╔═╡ 113767d8-d046-40b9-b3b2-0b9e49d9e115
SummedArray(Int32[1; 2; 3], Int32(6))

# ╔═╡ e52a599d-5bde-441b-ad14-6e950d2e11ee
md"""
The problem is that we want `S` to be a larger type than `T`, so that we can sum many elements with less information loss. For example, when `T` is [`Int32`](@ref), we would like `S` to be [`Int64`](@ref). Therefore we want to avoid an interface that allows the user to construct instances of the type `SummedArray{Int32,Int32}`. One way to do this is to provide a constructor only for `SummedArray`, but inside the `struct` definition block to suppress generation of default constructors:
"""

# ╔═╡ e4b18f18-96e0-4021-b8ce-d8999164b6a3
struct SummedArray{T<:Number,S<:Number}
     data::Vector{T}
     sum::S
     function SummedArray(a::Vector{T}) where T
         S = widen(T)
         new{T,S}(a, sum(S, a))
     end
 end

# ╔═╡ 8fd523d3-e497-4a35-8e0f-58650f26af23
SummedArray(Int32[1; 2; 3], Int32(6))

# ╔═╡ c7311aac-f24a-45ce-80fd-5486ecdef4de
md"""
This constructor will be invoked by the syntax `SummedArray(a)`. The syntax `new{T,S}` allows specifying parameters for the type to be constructed, i.e. this call will return a `SummedArray{T,S}`. `new{T,S}` can be used in any constructor definition, but for convenience the parameters to `new{}` are automatically derived from the type being constructed when possible.
"""

# ╔═╡ Cell order:
# ╟─030af795-1953-46b6-b462-b8e4ad2dd64e
# ╟─2c50014b-e00a-42d8-975e-25345f06772a
# ╠═a2fe404c-b9c6-46af-ab74-41cccf09117b
# ╠═ecd15023-ae24-4d77-ab47-8906f7cd0223
# ╠═3a1a1461-66e6-4f84-82bc-9b002ce47d07
# ╠═bc42170d-716b-4524-9c2c-7b80ba564bc1
# ╟─122d1815-e12a-45f0-a07a-d6cc950d3f70
# ╟─0e61f58f-0e7e-4b0f-b728-becfbafe1551
# ╟─3919e995-526c-4572-b042-4512d4eccf66
# ╟─f5043763-cd17-4371-9438-2daa810a02ad
# ╠═a60b9082-b409-4a08-bfe4-8e712119e8a5
# ╠═e917a81e-d842-4a77-95b0-56b41c372048
# ╟─0ae93dc5-527d-44db-be5f-7042b1e76b98
# ╠═cedd85cc-1f0c-4995-9e65-8b39bf72b68d
# ╠═039497c2-9de5-46ba-8f0c-99fa17d166f1
# ╟─1473ae85-e330-44b7-b0dd-570f0623f01c
# ╟─19bc728a-b2c5-4073-a248-a320e99eeb69
# ╟─bdef3455-169c-4551-b495-967dc67c7b77
# ╟─e5c07f65-8e25-49a8-b8b5-4fbb7e8796d0
# ╟─f9c4e5a6-2895-45b8-af8a-67c3345bd43f
# ╠═733553be-e2d9-489f-8769-ceeff3170f2b
# ╟─f7be527c-237a-4dc2-a5af-a37b935b952c
# ╠═17422a2a-e741-43aa-a679-701a7659ce2b
# ╠═4c932812-efff-4b39-930f-94fb3fd0b6cb
# ╟─b090dd4d-cf3f-4348-a171-af4533158a4b
# ╟─92d3267c-d987-4900-99fd-c9c0c6439154
# ╠═1e3d87c6-a5d6-4fc1-a032-dc3747f0db49
# ╟─a35cf270-50d5-45ac-baab-44f72b40be2e
# ╠═94b33b54-04a0-4d5b-a18a-782f069c5187
# ╠═877fbfe9-e132-41e8-b8f8-1a310fbb7a71
# ╠═c2f5690d-81e6-489d-978f-4cd541fe89c6
# ╠═edb525dc-6e23-41f3-8636-03ff674574ba
# ╠═dbbddb9b-9249-4207-85b0-a1f16e1108f7
# ╠═f6448ea6-2729-4ca9-87b2-58e4a296d5a1
# ╟─b14cc5bc-521d-4289-b88c-e0f2a4a6dcb4
# ╟─2732e78c-77e2-4d31-a609-b0a76a356a95
# ╟─e4842b10-8767-4bf3-a8dd-1ef76adebd6e
# ╠═0db1906a-0060-4ecd-8b7f-ff4cd026abf7
# ╟─ee7f1f2a-cab4-4053-827d-a7348c5ccea6
# ╠═9d42edcd-6744-4a90-a9dc-512dc71059b0
# ╟─f4732df3-39ee-4498-851a-8f840936bde0
# ╟─245ee88d-9b69-4c97-bd52-d89d54a3441c
# ╠═c3c46d0d-6695-45d7-b0f9-890e7456ccf0
# ╟─32a621ef-1e5f-495e-8a11-054fb6a68568
# ╠═788c11fd-1035-44cb-bd26-9545243ed7b8
# ╠═a3e59e00-fbd8-4100-ac31-aeaf9e8cd254
# ╠═e641b579-6cdb-4f22-8365-751876079cc8
# ╠═23cc5922-96d5-479d-8e29-14704f82147a
# ╟─3e829760-f8ed-413e-bce0-3f0850e11475
# ╠═13d759c3-f933-48a2-9701-de5bf4a91844
# ╠═114a6c4d-c0df-40ad-b0b4-50bab3fb18d8
# ╟─8b01dad6-4111-4337-84b8-787efb332ef5
# ╠═2ea81c16-0885-4e1d-9690-43c743dfaa1e
# ╟─a559bed5-c44a-4d25-9eef-7e33642b7c16
# ╠═9c28dfc0-a990-4d69-8473-2bd55af25d72
# ╠═098d8fd6-a8bb-45ff-a5cf-e37b1b4e1b5b
# ╟─d10ad718-5048-4af5-846b-8cb2046a89a9
# ╟─37ff8214-b81e-41cf-bee5-381dc952bf22
# ╠═c98a7942-f85a-4f23-b9e5-622904c3ea0d
# ╟─34bab941-4789-4694-b382-96a24d866c1d
# ╟─e5fd2a0a-469f-44f0-8f0b-44e9aa5bd3db
# ╟─bfdfdade-2059-4b17-a53d-acd15c6775c9
# ╠═2868c161-d500-4dfd-9c79-bda418574e50
# ╠═8bb5a0f8-e165-4cba-9ce7-61b2a39a70e2
# ╠═582aacc6-5f5d-4689-9365-6a5c2457d701
# ╠═ba607f41-c4bf-494c-b6b8-b00e6d2a2a86
# ╠═57630466-bea7-4921-a484-c49d99df7bc8
# ╠═86709979-c288-477a-bd94-c19261175575
# ╠═dac919d3-12df-411e-88cb-2d347218fc93
# ╠═6aab1cca-e05e-4fca-8ec9-785a16e4626d
# ╟─9df15d6c-8847-4466-8906-4a41f3b0d31f
# ╟─72e27d65-922f-43af-83e9-3cb3f1894ef2
# ╠═bd92e321-816a-4a9e-86be-0cd119e7a154
# ╠═e98db70e-0572-48f9-b0c8-b7ce53f09c82
# ╟─e2840543-dcce-434b-b6d0-f49edfd544c3
# ╟─50a0c1fe-a6d9-412d-9437-33df506de1dc
# ╠═081739ea-b325-480c-963a-22da5c8f8188
# ╟─69e3da89-4883-4b33-a49c-4afd4015432e
# ╠═7e10fc08-c613-49b8-a035-fb607c9eec63
# ╠═69bf50e4-ceae-414f-92f9-7a3ea3c6a30b
# ╟─d2efad5f-5c24-4776-9892-388bfeac4280
# ╠═e61cb24f-840f-4fa5-af3a-1de75b4afdf3
# ╟─1e49c294-7826-4a3c-87ca-d28cba02ba05
# ╠═b7fabd87-d013-4708-a1b4-d3545cbe2572
# ╟─c6f77231-f96a-49dc-8292-762b1ae44689
# ╠═81cc44a9-148e-4864-94e6-db9a4b1c52f0
# ╠═8a007c9c-ec3f-469b-8b4e-96b39f41d824
# ╠═42c7d4a3-49c1-4438-a10c-4845cf38dc63
# ╟─1e004d0a-ee00-4892-9291-16f9a5e72a49
# ╟─e0ae9a35-204a-4775-a1b6-d13eb8ba2ee9
# ╟─5dca6e9b-64d0-4098-9dec-defa444d748c
# ╠═51f0b860-ae87-42bf-8b2f-ff8ee776f492
# ╠═4c757d33-71b5-4d1c-9cdd-96e73bd07f19
# ╠═c8f26a10-ca09-428a-a634-c4bd6460d95a
# ╠═0490ed5d-2b83-4bae-bb34-3718fc4bae59
# ╠═840d7552-6c9f-4988-a932-a7c1b2510b27
# ╠═90520875-39c8-4187-8506-7bf756f2df87
# ╠═b4a22d33-2a14-44d2-a0d6-5feda6da1aef
# ╠═6f14cbd4-20fc-4dbe-b247-b89d9edacc74
# ╠═08a8a9a7-38f9-46ad-9832-31e46cf31ad0
# ╠═48ea7ccf-64e0-4840-90bc-32782ac26bac
# ╟─e5026119-01b0-4953-9ed1-290391dc6357
# ╟─a3b8aa99-7c15-4e3b-b48e-ef156bf472cc
# ╟─cc9a3f79-0355-4929-a1ff-1453f82c39a7
# ╟─bcc195bc-c7cf-4243-a3b8-206f53744d10
# ╠═44d18c46-24de-46bb-95bb-dbd1c588103c
# ╠═f80fc33a-8fb9-40ea-94ff-ebb24d1760c2
# ╠═5069623f-e25d-4625-989e-4d111beaed14
# ╟─94b4e48e-7bf1-4f47-a79a-9309b65db1cb
# ╟─eb9ef1f2-18ef-4873-b199-0c2c1086426e
# ╟─a041c76e-f084-423d-8c8e-cfc897d41ecb
# ╟─9284da4c-dc63-4ffc-aab1-dc94570c2a36
# ╠═349ae71f-4b92-47a1-8a41-72f3d3c3ae50
# ╠═113767d8-d046-40b9-b3b2-0b9e49d9e115
# ╟─e52a599d-5bde-441b-ad14-6e950d2e11ee
# ╠═e4b18f18-96e0-4021-b8ce-d8999164b6a3
# ╠═8fd523d3-e497-4a35-8e0f-58650f26af23
# ╟─c7311aac-f24a-45ce-80fd-5486ecdef4de
