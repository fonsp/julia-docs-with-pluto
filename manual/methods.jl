### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ 03ce9706-9e19-11eb-3939-83b370fc5391
md"""
# Methods
"""

# ╔═╡ 03ce9846-9e19-11eb-0dcd-bb00199c2630
md"""
Recall from [Functions](@ref man-functions) that a function is an object that maps a tuple of arguments to a return value, or throws an exception if no appropriate value can be returned. It is common for the same conceptual function or operation to be implemented quite differently for different types of arguments: adding two integers is very different from adding two floating-point numbers, both of which are distinct from adding an integer to a floating-point number. Despite their implementation differences, these operations all fall under the general concept of "addition". Accordingly, in Julia, these behaviors all belong to a single object: the `+` function.
"""

# ╔═╡ 03ce9882-9e19-11eb-23a8-7df63c0f43bc
md"""
To facilitate using many different implementations of the same concept smoothly, functions need not be defined all at once, but can rather be defined piecewise by providing specific behaviors for certain combinations of argument types and counts. A definition of one possible behavior for a function is called a *method*. Thus far, we have presented only examples of functions defined with a single method, applicable to all types of arguments. However, the signatures of method definitions can be annotated to indicate the types of arguments in addition to their number, and more than a single method definition may be provided. When a function is applied to a particular tuple of arguments, the most specific method applicable to those arguments is applied. Thus, the overall behavior of a function is a patchwork of the behaviors of its various method definitions. If the patchwork is well designed, even though the implementations of the methods may be quite different, the outward behavior of the function will appear seamless and consistent.
"""

# ╔═╡ 03ce98e6-9e19-11eb-208f-d9d94802fdbb
md"""
The choice of which method to execute when a function is applied is called *dispatch*. Julia allows the dispatch process to choose which of a function's methods to call based on the number of arguments given, and on the types of all of the function's arguments. This is different than traditional object-oriented languages, where dispatch occurs based only on the first argument, which often has a special argument syntax, and is sometimes implied rather than explicitly written as an argument. [^1] Using all of a function's arguments to choose which method should be invoked, rather than just the first, is known as [multiple dispatch](https://en.wikipedia.org/wiki/Multiple_dispatch). Multiple dispatch is particularly useful for mathematical code, where it makes little sense to artificially deem the operations to "belong" to one argument more than any of the others: does the addition operation in `x + y` belong to `x` any more than it does to `y`? The implementation of a mathematical operator generally depends on the types of all of its arguments. Even beyond mathematical operations, however, multiple dispatch ends up being a powerful and convenient paradigm for structuring and organizing programs.
"""

# ╔═╡ 03ce9a12-9e19-11eb-1db2-3388f667031d
md"""
[^1]: In C++ or Java, for example, in a method call like `obj.meth(arg1,arg2)`, the object obj "receives" the method call and is implicitly passed to the method via the `this` keyword, rather than as an explicit method argument. When the current `this` object is the receiver of a method call, it can be omitted altogether, writing just `meth(arg1,arg2)`, with `this` implied as the receiving object.
"""

# ╔═╡ 03ce9ac6-9e19-11eb-28df-5188d1fda3b8
md"""
!!! note
    All the examples in this chapter assume that you are defining modules for a function in the *same* module. If you want to add methods to a function in *another* module, you have to `import` it or use the name qualified with module names. See the section on [namespace management](@ref namespace-management).
"""

# ╔═╡ 03ce9b02-9e19-11eb-372e-cfdd8baeaf69
md"""
## Defining Methods
"""

# ╔═╡ 03ce9b2a-9e19-11eb-3b4a-e9042a8e6cb4
md"""
Until now, we have, in our examples, defined only functions with a single method having unconstrained argument types. Such functions behave just like they would in traditional dynamically typed languages. Nevertheless, we have used multiple dispatch and methods almost continually without being aware of it: all of Julia's standard functions and operators, like the aforementioned `+` function, have many methods defining their behavior over various possible combinations of argument type and count.
"""

# ╔═╡ 03ce9b48-9e19-11eb-1bb0-9d58e82c71c9
md"""
When defining a function, one can optionally constrain the types of parameters it is applicable to, using the `::` type-assertion operator, introduced in the section on [Composite Types](@ref):
"""

# ╔═╡ 03cea2fa-9e19-11eb-19f6-2ffcae2ca33a
f(x::Float64, y::Float64) = 2x + y

# ╔═╡ 03cea354-9e19-11eb-1622-9d8c398462f4
md"""
This function definition applies only to calls where `x` and `y` are both values of type [`Float64`](@ref):
"""

# ╔═╡ 03cea502-9e19-11eb-1f55-a59d49adf575
f(2.0, 3.0)

# ╔═╡ 03cea53e-9e19-11eb-0cee-4110721dba60
md"""
Applying it to any other types of arguments will result in a [`MethodError`](@ref):
"""

# ╔═╡ 03ceab56-9e19-11eb-0c0b-43da6bf96c75
f(2.0, 3)

# ╔═╡ 03ceab60-9e19-11eb-1ee6-c1664a47ce09
f(Float32(2.0), 3.0)

# ╔═╡ 03ceab9c-9e19-11eb-1fa5-9dc7d5c93ff5
f(2.0, "3.0")

# ╔═╡ 03ceab9c-9e19-11eb-08b2-41b6f8c16ac2
f("2.0", "3.0")

# ╔═╡ 03ceabd8-9e19-11eb-39c6-a5cb22f0c129
md"""
As you can see, the arguments must be precisely of type [`Float64`](@ref). Other numeric types, such as integers or 32-bit floating-point values, are not automatically converted to 64-bit floating-point, nor are strings parsed as numbers. Because `Float64` is a concrete type and concrete types cannot be subclassed in Julia, such a definition can only be applied to arguments that are exactly of type `Float64`. It may often be useful, however, to write more general methods where the declared parameter types are abstract:
"""

# ╔═╡ 03ceafe8-9e19-11eb-388e-23e271b9d04e
f(x::Number, y::Number) = 2x - y

# ╔═╡ 03ceaffc-9e19-11eb-30aa-e7198179b3cb
f(2.0, 3)

# ╔═╡ 03ceb042-9e19-11eb-1cfa-19a895ce48f9
md"""
This method definition applies to any pair of arguments that are instances of [`Number`](@ref). They need not be of the same type, so long as they are each numeric values. The problem of handling disparate numeric types is delegated to the arithmetic operations in the expression `2x - y`.
"""

# ╔═╡ 03ceb0a6-9e19-11eb-035b-9db2e0b01b4e
md"""
To define a function with multiple methods, one simply defines the function multiple times, with different numbers and types of arguments. The first method definition for a function creates the function object, and subsequent method definitions add new methods to the existing function object. The most specific method definition matching the number and types of the arguments will be executed when the function is applied. Thus, the two method definitions above, taken together, define the behavior for `f` over all pairs of instances of the abstract type `Number` – but with a different behavior specific to pairs of [`Float64`](@ref) values. If one of the arguments is a 64-bit float but the other one is not, then the `f(Float64,Float64)` method cannot be called and the more general `f(Number,Number)` method must be used:
"""

# ╔═╡ 03ceb4a2-9e19-11eb-2795-81913800d535
f(2.0, 3.0)

# ╔═╡ 03ceb4a2-9e19-11eb-06fb-63aadf4779ea
f(2, 3.0)

# ╔═╡ 03ceb4b6-9e19-11eb-24e5-b996795f4f9b
f(2.0, 3)

# ╔═╡ 03ceb4b6-9e19-11eb-1495-fb2a1bf414ea
f(2, 3)

# ╔═╡ 03ceb4e8-9e19-11eb-1636-99f37dbdc6ca
md"""
The `2x + y` definition is only used in the first case, while the `2x - y` definition is used in the others. No automatic casting or conversion of function arguments is ever performed: all conversion in Julia is non-magical and completely explicit. [Conversion and Promotion](@ref conversion-and-promotion), however, shows how clever application of sufficiently advanced technology can be indistinguishable from magic. [^Clarke61]
"""

# ╔═╡ 03ceb510-9e19-11eb-20f7-652f870801ba
md"""
For non-numeric values, and for fewer or more than two arguments, the function `f` remains undefined, and applying it will still result in a [`MethodError`](@ref):
"""

# ╔═╡ 03ceb722-9e19-11eb-0903-b72c4c13eaee
f("foo", 3)

# ╔═╡ 03ceb72a-9e19-11eb-3215-c3d3735db9f7
f()

# ╔═╡ 03ceb740-9e19-11eb-21e7-cbf29cfbf40b
md"""
You can easily see which methods exist for a function by entering the function object itself in an interactive session:
"""

# ╔═╡ 03ceb7b8-9e19-11eb-3dba-99b2f16dbdba
f

# ╔═╡ 03ceb7f4-9e19-11eb-1749-af319daf3b76
md"""
This output tells us that `f` is a function object with two methods. To find out what the signatures of those methods are, use the [`methods`](@ref) function:
"""

# ╔═╡ 03ceb8d0-9e19-11eb-3061-371f648b9cf0
methods(f)

# ╔═╡ 03ceb8f6-9e19-11eb-079a-cdfd292e2804
md"""
which shows that `f` has two methods, one taking two `Float64` arguments and one taking arguments of type `Number`. It also indicates the file and line number where the methods were defined: because these methods were defined at the REPL, we get the apparent line number `none:1`.
"""

# ╔═╡ 03ceb916-9e19-11eb-3f71-8b7bd8714124
md"""
In the absence of a type declaration with `::`, the type of a method parameter is `Any` by default, meaning that it is unconstrained since all values in Julia are instances of the abstract type `Any`. Thus, we can define a catch-all method for `f` like so:
"""

# ╔═╡ 03cebfb0-9e19-11eb-3c99-ef1dd3342467
f(x,y) = println("Whoa there, Nelly.")

# ╔═╡ 03cebfba-9e19-11eb-3a3d-93edfde645d0
methods(f)

# ╔═╡ 03cebfba-9e19-11eb-20ed-b1583ec80c3d
f("foo", 1)

# ╔═╡ 03cebfec-9e19-11eb-2b44-3f34995a7561
md"""
This catch-all is less specific than any other possible method definition for a pair of parameter values, so it will only be called on pairs of arguments to which no other method definition applies.
"""

# ╔═╡ 03cec032-9e19-11eb-20ce-2380e1092417
md"""
Note that in the signature of the third method, there is no type specified for the arguments `x` and `y`. This is a shortened way of expressing `f(x::Any, y::Any)`.
"""

# ╔═╡ 03cec03e-9e19-11eb-34c3-af84ad734e47
md"""
Although it seems a simple concept, multiple dispatch on the types of values is perhaps the single most powerful and central feature of the Julia language. Core operations typically have dozens of methods:
"""

# ╔═╡ 03cec19a-9e19-11eb-08ee-e3d990573e93
methods(+)

# ╔═╡ 03cec1b8-9e19-11eb-3a39-1dddca89300a
md"""
Multiple dispatch together with the flexible parametric type system give Julia its ability to abstractly express high-level algorithms decoupled from implementation details, yet generate efficient, specialized code to handle each case at run time.
"""

# ╔═╡ 03cec1e0-9e19-11eb-3f6b-e3f5666b43d1
md"""
## [Method Ambiguities](@id man-ambiguities)
"""

# ╔═╡ 03cec1f4-9e19-11eb-3409-fdf2aa935ef5
md"""
It is possible to define a set of function methods such that there is no unique most specific method applicable to some combinations of arguments:
"""

# ╔═╡ 03ceca64-9e19-11eb-2652-ab858396f311
g(x::Float64, y) = 2x + y

# ╔═╡ 03ceca6e-9e19-11eb-0c7d-bb8a014545d7
g(x, y::Float64) = x + 2y

# ╔═╡ 03ceca6e-9e19-11eb-3076-5349f6f41f8e
g(2.0, 3)

# ╔═╡ 03ceca76-9e19-11eb-37c9-455e70d292c8
g(2, 3.0)

# ╔═╡ 03ceca82-9e19-11eb-1a0a-dff9b025ce6d
g(2.0, 3.0)

# ╔═╡ 03cecaf0-9e19-11eb-38fe-0339b8912616
md"""
Here the call `g(2.0, 3.0)` could be handled by either the `g(Float64, Any)` or the `g(Any, Float64)` method, and neither is more specific than the other. In such cases, Julia raises a [`MethodError`](@ref) rather than arbitrarily picking a method. You can avoid method ambiguities by specifying an appropriate method for the intersection case:
"""

# ╔═╡ 03ced34c-9e19-11eb-36e0-8fc1da62e822
g(x::Float64, y::Float64) = 2x + 2y

# ╔═╡ 03ced356-9e19-11eb-35ac-517ab8bd519f
g(2.0, 3)

# ╔═╡ 03ced360-9e19-11eb-3909-c74bb83833c8
g(2, 3.0)

# ╔═╡ 03ced37e-9e19-11eb-0daf-99d73668cb38
g(2.0, 3.0)

# ╔═╡ 03ced3a6-9e19-11eb-1afe-05869f47915a
md"""
It is recommended that the disambiguating method be defined first, since otherwise the ambiguity exists, if transiently, until the more specific method is defined.
"""

# ╔═╡ 03ced3d8-9e19-11eb-3a28-a93ce15a0fb7
md"""
In more complex cases, resolving method ambiguities involves a certain element of design; this topic is explored further [below](@ref man-method-design-ambiguities).
"""

# ╔═╡ 03ced3f6-9e19-11eb-2796-abe128db7569
md"""
## Parametric Methods
"""

# ╔═╡ 03ced40a-9e19-11eb-00c7-275e46fef727
md"""
Method definitions can optionally have type parameters qualifying the signature:
"""

# ╔═╡ 03ced874-9e19-11eb-092d-732746645512
same_type(x::T, y::T) where {T} = true

# ╔═╡ 03ced874-9e19-11eb-3929-67ed17ca2170
same_type(x,y) = false

# ╔═╡ 03ced892-9e19-11eb-056b-7ba9e86a14d6
md"""
The first method applies whenever both arguments are of the same concrete type, regardless of what type that is, while the second method acts as a catch-all, covering all other cases. Thus, overall, this defines a boolean function that checks whether its two arguments are of the same type:
"""

# ╔═╡ 03cee116-9e19-11eb-1c80-3f36f0b5fbd1
same_type(1, 2)

# ╔═╡ 03cee120-9e19-11eb-066a-ffffccc557d4
same_type(1, 2.0)

# ╔═╡ 03cee120-9e19-11eb-397e-378bff99455f
same_type(1.0, 2.0)

# ╔═╡ 03cee12a-9e19-11eb-34d4-9d588f83405e
same_type("foo", 2.0)

# ╔═╡ 03cee136-9e19-11eb-37ee-b774ca21eea6
same_type("foo", "bar")

# ╔═╡ 03cee13e-9e19-11eb-110e-153374f6175d
same_type(Int32(1), Int64(2))

# ╔═╡ 03cee17a-9e19-11eb-358a-7dc7c97fe446
md"""
Such definitions correspond to methods whose type signatures are `UnionAll` types (see [UnionAll Types](@ref)).
"""

# ╔═╡ 03cee1a2-9e19-11eb-2f7e-476f3a74694a
md"""
This kind of definition of function behavior by dispatch is quite common – idiomatic, even – in Julia. Method type parameters are not restricted to being used as the types of arguments: they can be used anywhere a value would be in the signature of the function or body of the function. Here's an example where the method type parameter `T` is used as the type parameter to the parametric type `Vector{T}` in the method signature:
"""

# ╔═╡ 03cef2a8-9e19-11eb-282b-3db057d30609
myappend(v::Vector{T}, x::T) where {T} = [v..., x]

# ╔═╡ 03cef2b4-9e19-11eb-3c45-c390d4f81209
myappend([1,2,3],4)

# ╔═╡ 03cef2be-9e19-11eb-2862-993622339f28
myappend([1,2,3],2.5)

# ╔═╡ 03cef2be-9e19-11eb-134a-51a5954e21ed
myappend([1.0,2.0,3.0],4.0)

# ╔═╡ 03cef2c8-9e19-11eb-3f6f-971f6a906817
myappend([1.0,2.0,3.0],4)

# ╔═╡ 03cef32c-9e19-11eb-0936-75d03286764d
md"""
As you can see, the type of the appended element must match the element type of the vector it is appended to, or else a [`MethodError`](@ref) is raised. In the following example, the method type parameter `T` is used as the return value:
"""

# ╔═╡ 03cefafc-9e19-11eb-2d81-d73ba3683c80
mytypeof(x::T) where {T} = T

# ╔═╡ 03cefb06-9e19-11eb-33a5-a9d101155c84
mytypeof(1)

# ╔═╡ 03cefb10-9e19-11eb-3a64-ef99f40df962
mytypeof(1.0)

# ╔═╡ 03cefb74-9e19-11eb-19cd-ab224cde1731
md"""
Just as you can put subtype constraints on type parameters in type declarations (see [Parametric Types](@ref)), you can also constrain type parameters of methods:
"""

# ╔═╡ 03cf08da-9e19-11eb-1650-194bff926967
same_type_numeric(x::T, y::T) where {T<:Number} = true

# ╔═╡ 03cf08da-9e19-11eb-33ac-d9eb2b3f3714
same_type_numeric(x::Number, y::Number) = false

# ╔═╡ 03cf08e4-9e19-11eb-0cfe-f71e7df63900
same_type_numeric(1, 2)

# ╔═╡ 03cf08f8-9e19-11eb-0e89-1347b1e50539
same_type_numeric(1, 2.0)

# ╔═╡ 03cf08f8-9e19-11eb-3fcf-59bf92164dda
same_type_numeric(1.0, 2.0)

# ╔═╡ 03cf0904-9e19-11eb-23ea-f3efb895468f
same_type_numeric("foo", 2.0)

# ╔═╡ 03cf0904-9e19-11eb-124f-617701ab7bfb
same_type_numeric("foo", "bar")

# ╔═╡ 03cf090c-9e19-11eb-1100-e519036862c2
same_type_numeric(Int32(1), Int64(2))

# ╔═╡ 03cf0936-9e19-11eb-1c1f-9b9a3287003b
md"""
The `same_type_numeric` function behaves much like the `same_type` function defined above, but is only defined for pairs of numbers.
"""

# ╔═╡ 03cf0970-9e19-11eb-3523-5359b65eb16b
md"""
Parametric methods allow the same syntax as `where` expressions used to write types (see [UnionAll Types](@ref)). If there is only a single parameter, the enclosing curly braces (in `where {T}`) can be omitted, but are often preferred for clarity. Multiple parameters can be separated with commas, e.g. `where {T, S<:Real}`, or written using nested `where`, e.g. `where S<:Real where T`.
"""

# ╔═╡ 03cf098e-9e19-11eb-22a0-6fd6d91f0334
md"""
## Redefining Methods
"""

# ╔═╡ 03cf09b6-9e19-11eb-2cff-af76accc8573
md"""
When redefining a method or adding new methods, it is important to realize that these changes don't take effect immediately. This is key to Julia's ability to statically infer and compile code to run fast, without the usual JIT tricks and overhead. Indeed, any new method definition won't be visible to the current runtime environment, including Tasks and Threads (and any previously defined `@generated` functions). Let's start with an example to see what this means:
"""

# ╔═╡ 03cf0e16-9e19-11eb-0864-c956df715700
function tryeval()
           @eval newfun() = 1
           newfun()
       end

# ╔═╡ 03cf0e20-9e19-11eb-1576-b7e63f0a7527
tryeval()

# ╔═╡ 03cf0e2a-9e19-11eb-2a7a-9f8705618a7f
newfun()

# ╔═╡ 03cf0e8e-9e19-11eb-11d5-49145776777c
md"""
In this example, observe that the new definition for `newfun` has been created, but can't be immediately called. The new global is immediately visible to the `tryeval` function, so you could write `return newfun` (without parentheses). But neither you, nor any of your callers, nor the functions they call, or etc. can call this new method definition!
"""

# ╔═╡ 03cf0eb6-9e19-11eb-237b-2be9382dbac2
md"""
But there's an exception: future calls to `newfun` *from the REPL* work as expected, being able to both see and call the new definition of `newfun`.
"""

# ╔═╡ 03cf0ede-9e19-11eb-0209-2f8273fc5983
md"""
However, future calls to `tryeval` will continue to see the definition of `newfun` as it was *at the previous statement at the REPL*, and thus before that call to `tryeval`.
"""

# ╔═╡ 03cf0ef2-9e19-11eb-281d-03d49d03cab8
md"""
You may want to try this for yourself to see how it works.
"""

# ╔═╡ 03cf0f10-9e19-11eb-3aad-f971ba467356
md"""
The implementation of this behavior is a "world age counter". This monotonically increasing value tracks each method definition operation. This allows describing "the set of method definitions visible to a given runtime environment" as a single number, or "world age". It also allows comparing the methods available in two worlds just by comparing their ordinal value. In the example above, we see that the "current world" (in which the method `newfun` exists), is one greater than the task-local "runtime world" that was fixed when the execution of `tryeval` started.
"""

# ╔═╡ 03cf0f2e-9e19-11eb-14e1-4d1792f759cc
md"""
Sometimes it is necessary to get around this (for example, if you are implementing the above REPL). Fortunately, there is an easy solution: call the function using [`Base.invokelatest`](@ref):
"""

# ╔═╡ 03cf1348-9e19-11eb-1d22-55927602a8e7
function tryeval2()
           @eval newfun2() = 2
           Base.invokelatest(newfun2)
       end

# ╔═╡ 03cf135c-9e19-11eb-3ead-1df102e0bf0c
tryeval2()

# ╔═╡ 03cf137a-9e19-11eb-0e4d-cf7a771d3d06
md"""
Finally, let's take a look at some more complex examples where this rule comes into play. Define a function `f(x)`, which initially has one method:
"""

# ╔═╡ 03cf14f6-9e19-11eb-0acd-f740885e4d00
f(x) = "original definition"

# ╔═╡ 03cf1514-9e19-11eb-3714-3354c4cdfb8c
md"""
Start some other operations that use `f(x)`:
"""

# ╔═╡ 03cf18aa-9e19-11eb-2171-6314f08e1a0e
g(x) = f(x)

# ╔═╡ 03cf18aa-9e19-11eb-049a-419df6dfcaa6
t = @async f(wait()); yield();

# ╔═╡ 03cf18ca-9e19-11eb-280f-f7b57f677470
md"""
Now we add some new methods to `f(x)`:
"""

# ╔═╡ 03cf1c82-9e19-11eb-17aa-d17a907b6037
f(x::Int) = "definition for Int"

# ╔═╡ 03cf1c9e-9e19-11eb-003e-7d72c46eea49
f(x::Type{Int}) = "definition for Type{Int}"

# ╔═╡ 03cf1cb0-9e19-11eb-3189-65a8c6d663f9
md"""
Compare how these results differ:
"""

# ╔═╡ 03cf2342-9e19-11eb-1244-b541a91ee192
f(1)

# ╔═╡ 03cf234c-9e19-11eb-3b2c-cfc248a60c97
g(1)

# ╔═╡ 03cf2358-9e19-11eb-317d-0b746abd0ec1
fetch(schedule(t, 1))

# ╔═╡ 03cf2360-9e19-11eb-0242-b3157b43b3b3
t = @async f(wait()); yield();

# ╔═╡ 03cf2360-9e19-11eb-352e-a3b35c29b47d
fetch(schedule(t, 1))

# ╔═╡ 03cf237e-9e19-11eb-1878-413e77e55486
md"""
## Design Patterns with Parametric Methods
"""

# ╔═╡ 03cf2392-9e19-11eb-1a05-5dd94f63daaf
md"""
While complex dispatch logic is not required for performance or usability, sometimes it can be the best way to express some algorithm. Here are a few common design patterns that come up sometimes when using dispatch in this way.
"""

# ╔═╡ 03cf23d8-9e19-11eb-2e41-adc32bed9ee5
md"""
### Extracting the type parameter from a super-type
"""

# ╔═╡ 03cf23f6-9e19-11eb-1fc6-374cdeaf1ce0
md"""
Here is the correct code template for returning the element-type `T` of any arbitrary subtype of `AbstractArray`:
"""

# ╔═╡ 03cf243c-9e19-11eb-2764-b779eb2193c9
md"""
```julia
abstract type AbstractArray{T, N} end
eltype(::Type{<:AbstractArray{T}}) where {T} = T
```
"""

# ╔═╡ 03cf2464-9e19-11eb-29cd-dd456f5c4454
md"""
using so-called triangular dispatch.  Note that if `T` is a `UnionAll` type, as e.g. `eltype(Array{T} where T <: Integer)`, then `Any` is returned (as does the version of `eltype` in `Base`).
"""

# ╔═╡ 03cf2478-9e19-11eb-34be-cdb90eb35a72
md"""
Another way, which used to be the only correct way before the advent of triangular dispatch in Julia v0.6, is:
"""

# ╔═╡ 03cf24a0-9e19-11eb-11de-778ddccddb2a
md"""
```julia
abstract type AbstractArray{T, N} end
eltype(::Type{AbstractArray}) = Any
eltype(::Type{AbstractArray{T}}) where {T} = T
eltype(::Type{AbstractArray{T, N}}) where {T, N} = T
eltype(::Type{A}) where {A<:AbstractArray} = eltype(supertype(A))
```
"""

# ╔═╡ 03cf24c0-9e19-11eb-0eaa-41f2dc757cc0
md"""
Another possibility is the following, which could be useful to adapt to cases where the parameter `T` would need to be matched more narrowly:
"""

# ╔═╡ 03cf24dc-9e19-11eb-351f-270397ff65ad
md"""
```julia
eltype(::Type{AbstractArray{T, N} where {T<:S, N<:M}}) where {M, S} = Any
eltype(::Type{AbstractArray{T, N} where {T<:S}}) where {N, S} = Any
eltype(::Type{AbstractArray{T, N} where {N<:M}}) where {M, T} = T
eltype(::Type{AbstractArray{T, N}}) where {T, N} = T
eltype(::Type{A}) where {A <: AbstractArray} = eltype(supertype(A))
```
"""

# ╔═╡ 03cf24fa-9e19-11eb-2d19-d5499fe2584a
md"""
One common mistake is to try and get the element-type by using introspection:
"""

# ╔═╡ 03cf2504-9e19-11eb-1bc8-3d8595f2dc57
md"""
```julia
eltype_wrong(::Type{A}) where {A<:AbstractArray} = A.parameters[1]
```
"""

# ╔═╡ 03cf2518-9e19-11eb-21c7-a38598fc7728
md"""
However, it is not hard to construct cases where this will fail:
"""

# ╔═╡ 03cf252c-9e19-11eb-3b33-8bb4cfb90e25
md"""
```julia
struct BitVector <: AbstractArray{Bool, 1}; end
```
"""

# ╔═╡ 03cf2552-9e19-11eb-0dd3-33f71eb37f74
md"""
Here we have created a type `BitVector` which has no parameters, but where the element-type is still fully specified, with `T` equal to `Bool`!
"""

# ╔═╡ 03cf2568-9e19-11eb-1f44-7dac74afa843
md"""
### Building a similar type with a different type parameter
"""

# ╔═╡ 03cf257c-9e19-11eb-2fd2-79168ea0ce60
md"""
When building generic code, there is often a need for constructing a similar object with some change made to the layout of the type, also necessitating a change of the type parameters. For instance, you might have some sort of abstract array with an arbitrary element type and want to write your computation on it with a specific element type. We must implement a method for each `AbstractArray{T}` subtype that describes how to compute this type transform. There is no general transform of one subtype into another subtype with a different parameter. (Quick review: do you see why this is?)
"""

# ╔═╡ 03cf25a4-9e19-11eb-027b-7fbb9f7e1eef
md"""
The subtypes of `AbstractArray` typically implement two methods to achieve this: A method to convert the input array to a subtype of a specific `AbstractArray{T, N}` abstract type; and a method to make a new uninitialized array with a specific element type. Sample implementations of these can be found in Julia Base. Here is a basic example usage of them, guaranteeing that `input` and `output` are of the same type:
"""

# ╔═╡ 03cf25b8-9e19-11eb-0aee-45a0a49f890c
md"""
```julia
input = convert(AbstractArray{Eltype}, input)
output = similar(input, Eltype)
```
"""

# ╔═╡ 03cf25ea-9e19-11eb-357f-2bb2e0ff4653
md"""
As an extension of this, in cases where the algorithm needs a copy of the input array, [`convert`](@ref) is insufficient as the return value may alias the original input. Combining [`similar`](@ref) (to make the output array) and [`copyto!`](@ref) (to fill it with the input data) is a generic way to express the requirement for a mutable copy of the input argument:
"""

# ╔═╡ 03cf261c-9e19-11eb-39f6-37e132e67b18
md"""
```julia
copy_with_eltype(input, Eltype) = copyto!(similar(input, Eltype), input)
```
"""

# ╔═╡ 03cf2628-9e19-11eb-0443-657afddb0fa1
md"""
### Iterated dispatch
"""

# ╔═╡ 03cf263a-9e19-11eb-0643-8904bcc7afc3
md"""
In order to dispatch a multi-level parametric argument list, often it is best to separate each level of dispatch into distinct functions. This may sound similar in approach to single-dispatch, but as we shall see below, it is still more flexible.
"""

# ╔═╡ 03cf2656-9e19-11eb-3e71-a94d4a233071
md"""
For example, trying to dispatch on the element-type of an array will often run into ambiguous situations. Instead, commonly code will dispatch first on the container type, then recurse down to a more specific method based on eltype. In most cases, the algorithms lend themselves conveniently to this hierarchical approach, while in other cases, this rigor must be resolved manually. This dispatching branching can be observed, for example, in the logic to sum two matrices:
"""

# ╔═╡ 03cf266c-9e19-11eb-3844-c128d0f7a2b1
md"""
```julia
# First dispatch selects the map algorithm for element-wise summation.
+(a::Matrix, b::Matrix) = map(+, a, b)
# Then dispatch handles each element and selects the appropriate
# common element type for the computation.
+(a, b) = +(promote(a, b)...)
# Once the elements have the same type, they can be added.
# For example, via primitive operations exposed by the processor.
+(a::Float64, b::Float64) = Core.add(a, b)
```
"""

# ╔═╡ 03cf2680-9e19-11eb-153e-6903f47b5a56
md"""
### Trait-based dispatch
"""

# ╔═╡ 03cf269e-9e19-11eb-3c5e-29bca4113b4c
md"""
A natural extension to the iterated dispatch above is to add a layer to method selection that allows to dispatch on sets of types which are independent from the sets defined by the type hierarchy. We could construct such a set by writing out a `Union` of the types in question, but then this set would not be extensible as `Union`-types cannot be altered after creation. However, such an extensible set can be programmed with a design pattern often referred to as a ["Holy-trait"](https://github.com/JuliaLang/julia/issues/2345#issuecomment-54537633).
"""

# ╔═╡ 03cf26ba-9e19-11eb-3f9f-b146ebd24bbd
md"""
This pattern is implemented by defining a generic function which computes a different singleton value (or type) for each trait-set to which the function arguments may belong to.  If this function is pure there is no impact on performance compared to normal dispatch.
"""

# ╔═╡ 03cf26f8-9e19-11eb-27dd-a1cefa7bdf30
md"""
The example in the previous section glossed over the implementation details of [`map`](@ref) and [`promote`](@ref), which both operate in terms of these traits. When iterating over a matrix, such as in the implementation of `map`, one important question is what order to use to traverse the data. When `AbstractArray` subtypes implement the [`Base.IndexStyle`](@ref) trait, other functions such as `map` can dispatch on this information to pick the best algorithm (see [Abstract Array Interface](@ref man-interface-array)). This means that each subtype does not need to implement a custom version of `map`, since the generic definitions + trait classes will enable the system to select the fastest version. Here a toy implementation of `map` illustrating the trait-based dispatch:
"""

# ╔═╡ 03cf2716-9e19-11eb-30c5-35eab7f54cfd
md"""
```julia
map(f, a::AbstractArray, b::AbstractArray) = map(Base.IndexStyle(a, b), f, a, b)
# generic implementation:
map(::Base.IndexCartesian, f, a::AbstractArray, b::AbstractArray) = ...
# linear-indexing implementation (faster)
map(::Base.IndexLinear, f, a::AbstractArray, b::AbstractArray) = ...
```
"""

# ╔═╡ 03cf273e-9e19-11eb-15b4-7bc31e65e84f
md"""
This trait-based approach is also present in the [`promote`](@ref) mechanism employed by the scalar `+`. It uses [`promote_type`](@ref), which returns the optimal common type to compute the operation given the two types of the operands. This makes it possible to reduce the problem of implementing every function for every pair of possible type arguments, to the much smaller problem of implementing a conversion operation from each type to a common type, plus a table of preferred pair-wise promotion rules.
"""

# ╔═╡ 03cf2752-9e19-11eb-2b9d-2139c32f490c
md"""
### Output-type computation
"""

# ╔═╡ 03cf2766-9e19-11eb-1cb0-a5d11a53be87
md"""
The discussion of trait-based promotion provides a transition into our next design pattern: computing the output element type for a matrix operation.
"""

# ╔═╡ 03cf27ac-9e19-11eb-15aa-510c90e3e34e
md"""
For implementing primitive operations, such as addition, we use the [`promote_type`](@ref) function to compute the desired output type. (As before, we saw this at work in the `promote` call in the call to `+`).
"""

# ╔═╡ 03cf27b6-9e19-11eb-0dfa-5b440fffad3b
md"""
For more complex functions on matrices, it may be necessary to compute the expected return type for a more complex sequence of operations. This is often performed by the following steps:
"""

# ╔═╡ 03cf293c-9e19-11eb-042d-19561c78b1b5
md"""
1. Write a small function `op` that expresses the set of operations performed by the kernel of the algorithm.
2. Compute the element type `R` of the result matrix as `promote_op(op, argument_types...)`, where `argument_types` is computed from `eltype` applied to each input array.
3. Build the output matrix as `similar(R, dims)`, where `dims` are the desired dimensions of the output array.
"""

# ╔═╡ 03cf2958-9e19-11eb-2da0-a5e20a9095fb
md"""
For a more specific example, a generic square-matrix multiply pseudo-code might look like:
"""

# ╔═╡ 03cf29a0-9e19-11eb-1cfd-114d4ef43a91
md"""
```julia
function matmul(a::AbstractMatrix, b::AbstractMatrix)
    op = (ai, bi) -> ai * bi + ai * bi

    ## this is insufficient because it assumes `one(eltype(a))` is constructable:
    # R = typeof(op(one(eltype(a)), one(eltype(b))))

    ## this fails because it assumes `a[1]` exists and is representative of all elements of the array
    # R = typeof(op(a[1], b[1]))

    ## this is incorrect because it assumes that `+` calls `promote_type`
    ## but this is not true for some types, such as Bool:
    # R = promote_type(ai, bi)

    # this is wrong, since depending on the return value
    # of type-inference is very brittle (as well as not being optimizable):
    # R = Base.return_types(op, (eltype(a), eltype(b)))

    ## but, finally, this works:
    R = promote_op(op, eltype(a), eltype(b))
    ## although sometimes it may give a larger type than desired
    ## it will always give a correct type

    output = similar(b, R, (size(a, 1), size(b, 2)))
    if size(a, 2) > 0
        for j in 1:size(b, 2)
            for i in 1:size(a, 1)
                ## here we don't use `ab = zero(R)`,
                ## since `R` might be `Any` and `zero(Any)` is not defined
                ## we also must declare `ab::R` to make the type of `ab` constant in the loop,
                ## since it is possible that typeof(a * b) != typeof(a * b + a * b) == R
                ab::R = a[i, 1] * b[1, j]
                for k in 2:size(a, 2)
                    ab += a[i, k] * b[k, j]
                end
                output[i, j] = ab
            end
        end
    end
    return output
end
```
"""

# ╔═╡ 03cf29aa-9e19-11eb-3bb1-530902492101
md"""
### Separate convert and kernel logic
"""

# ╔═╡ 03cf29c8-9e19-11eb-187f-e9f1cbfda4ab
md"""
One way to significantly cut down on compile-times and testing complexity is to isolate the logic for converting to the desired type and the computation. This lets the compiler specialize and inline the conversion logic independent from the rest of the body of the larger kernel.
"""

# ╔═╡ 03cf29dc-9e19-11eb-2a1f-eb4e77aa2143
md"""
This is a common pattern seen when converting from a larger class of types to the one specific argument type that is actually supported by the algorithm:
"""

# ╔═╡ 03cf29f0-9e19-11eb-1feb-c7c9c7541df0
md"""
```julia
complexfunction(arg::Int) = ...
complexfunction(arg::Any) = complexfunction(convert(Int, arg))

matmul(a::T, b::T) = ...
matmul(a, b) = matmul(promote(a, b)...)
```
"""

# ╔═╡ 03cf2a04-9e19-11eb-0e25-fb1a52896e05
md"""
## Parametrically-constrained Varargs methods
"""

# ╔═╡ 03cf2a2e-9e19-11eb-2648-ff5b130667a3
md"""
Function parameters can also be used to constrain the number of arguments that may be supplied to a "varargs" function ([Varargs Functions](@ref)).  The notation `Vararg{T,N}` is used to indicate such a constraint.  For example:
"""

# ╔═╡ 03cf30b2-9e19-11eb-1e8d-e5ebcb698e1f
bar(a,b,x::Vararg{Any,2}) = (a,b,x)

# ╔═╡ 03cf30bc-9e19-11eb-1381-fb4591dd63cc
bar(1,2,3)

# ╔═╡ 03cf30bc-9e19-11eb-0309-ffab01acfcb2
bar(1,2,3,4)

# ╔═╡ 03cf30da-9e19-11eb-2895-01c579743611
bar(1,2,3,4,5)

# ╔═╡ 03cf30ee-9e19-11eb-0987-bbf852f5bafb
md"""
More usefully, it is possible to constrain varargs methods by a parameter. For example:
"""

# ╔═╡ 03cf3104-9e19-11eb-111a-9986a845c833
md"""
```julia
function getindex(A::AbstractArray{T,N}, indices::Vararg{Number,N}) where {T,N}
```
"""

# ╔═╡ 03cf3120-9e19-11eb-14d1-13428500ab46
md"""
would be called only when the number of `indices` matches the dimensionality of the array.
"""

# ╔═╡ 03cf313e-9e19-11eb-3f98-25e5f5d5f61d
md"""
When only the type of supplied arguments needs to be constrained `Vararg{T}` can be equivalently written as `T...`. For instance `f(x::Int...) = x` is a shorthand for `f(x::Vararg{Int}) = x`.
"""

# ╔═╡ 03cf3152-9e19-11eb-3461-99126093d4eb
md"""
## Note on Optional and keyword Arguments
"""

# ╔═╡ 03cf3170-9e19-11eb-073c-89b0fca3a0e0
md"""
As mentioned briefly in [Functions](@ref man-functions), optional arguments are implemented as syntax for multiple method definitions. For example, this definition:
"""

# ╔═╡ 03cf3184-9e19-11eb-171e-73343b719361
md"""
```julia
f(a=1,b=2) = a+2b
```
"""

# ╔═╡ 03cf318e-9e19-11eb-373c-1970a255a597
md"""
translates to the following three methods:
"""

# ╔═╡ 03cf31a2-9e19-11eb-28a7-c575beb18e16
md"""
```julia
f(a,b) = a+2b
f(a) = f(a,2)
f() = f(1,2)
```
"""

# ╔═╡ 03cf31de-9e19-11eb-13ac-c71e06b49d61
md"""
This means that calling `f()` is equivalent to calling `f(1,2)`. In this case the result is `5`, because `f(1,2)` invokes the first method of `f` above. However, this need not always be the case. If you define a fourth method that is more specialized for integers:
"""

# ╔═╡ 03cf31f2-9e19-11eb-3b03-99574bb83665
md"""
```julia
f(a::Int,b::Int) = a-2b
```
"""

# ╔═╡ 03cf3206-9e19-11eb-3893-2180432c6244
md"""
then the result of both `f()` and `f(1,2)` is `-3`. In other words, optional arguments are tied to a function, not to any specific method of that function. It depends on the types of the optional arguments which method is invoked. When optional arguments are defined in terms of a global variable, the type of the optional argument may even change at run-time.
"""

# ╔═╡ 03cf322e-9e19-11eb-274b-f3b87711a025
md"""
Keyword arguments behave quite differently from ordinary positional arguments. In particular, they do not participate in method dispatch. Methods are dispatched based only on positional arguments, with keyword arguments processed after the matching method is identified.
"""

# ╔═╡ 03cf323a-9e19-11eb-273d-4ffa0eb50c44
md"""
## Function-like objects
"""

# ╔═╡ 03cf324c-9e19-11eb-2932-37bf8c1e1e6b
md"""
Methods are associated with types, so it is possible to make any arbitrary Julia object "callable" by adding methods to its type. (Such "callable" objects are sometimes called "functors.")
"""

# ╔═╡ 03cf3260-9e19-11eb-1527-c98edb8b58a7
md"""
For example, you can define a type that stores the coefficients of a polynomial, but behaves like a function evaluating the polynomial:
"""

# ╔═╡ 03cf3eb8-9e19-11eb-253f-0ba07f6f6a78
struct Polynomial{R}
           coeffs::Vector{R}
       end

# ╔═╡ 03cf3ec2-9e19-11eb-2ef7-615f0675d31a
function (p::Polynomial)(x)
           v = p.coeffs[end]
           for i = (length(p.coeffs)-1):-1:1
               v = v*x + p.coeffs[i]
           end
           return v
       end

# ╔═╡ 03cf3ec2-9e19-11eb-1790-27f603b7136f
(p::Polynomial)() = p(5)

# ╔═╡ 03cf3eea-9e19-11eb-3166-77fd7faf5295
md"""
Notice that the function is specified by type instead of by name. As with normal functions there is a terse syntax form. In the function body, `p` will refer to the object that was called. A `Polynomial` can be used as follows:
"""

# ╔═╡ 03cf4232-9e19-11eb-23bf-c57f742f676d
p = Polynomial([1,10,100])

# ╔═╡ 03cf4232-9e19-11eb-3281-0f14479c4dfb
p(3)

# ╔═╡ 03cf423c-9e19-11eb-367e-2b99093e13c8
p()

# ╔═╡ 03cf4250-9e19-11eb-0f45-3dd2327aac56
md"""
This mechanism is also the key to how type constructors and closures (inner functions that refer to their surrounding environment) work in Julia.
"""

# ╔═╡ 03cf4264-9e19-11eb-377b-d55b6f6fc8fb
md"""
## Empty generic functions
"""

# ╔═╡ 03cf4282-9e19-11eb-07ce-9fb34018e288
md"""
Occasionally it is useful to introduce a generic function without yet adding methods. This can be used to separate interface definitions from implementations. It might also be done for the purpose of documentation or code readability. The syntax for this is an empty `function` block without a tuple of arguments:
"""

# ╔═╡ 03cf42a0-9e19-11eb-3bea-2fa56ba08dc7
md"""
```julia
function emptyfunc end
```
"""

# ╔═╡ 03cf42b6-9e19-11eb-3f99-19c462101262
md"""
## [Method design and the avoidance of ambiguities](@id man-method-design-ambiguities)
"""

# ╔═╡ 03cf42d2-9e19-11eb-0645-03e4e24e3d78
md"""
Julia's method polymorphism is one of its most powerful features, yet exploiting this power can pose design challenges.  In particular, in more complex method hierarchies it is not uncommon for [ambiguities](@ref man-ambiguities) to arise.
"""

# ╔═╡ 03cf42e8-9e19-11eb-35f8-c7625b0a7581
md"""
Above, it was pointed out that one can resolve ambiguities like
"""

# ╔═╡ 03cf42fa-9e19-11eb-3ead-bb0e792d9ebe
md"""
```julia
f(x, y::Int) = 1
f(x::Int, y) = 2
```
"""

# ╔═╡ 03cf430e-9e19-11eb-3e96-436b063b0e3c
md"""
by defining a method
"""

# ╔═╡ 03cf4316-9e19-11eb-31bc-0f760cd65669
md"""
```julia
f(x::Int, y::Int) = 3
```
"""

# ╔═╡ 03cf4336-9e19-11eb-26ce-cf90508e574e
md"""
This is often the right strategy; however, there are circumstances where following this advice mindlessly can be counterproductive. In particular, the more methods a generic function has, the more possibilities there are for ambiguities. When your method hierarchies get more complicated than this simple example, it can be worth your while to think carefully about alternative strategies.
"""

# ╔═╡ 03cf4340-9e19-11eb-02ee-ff3a06fe1451
md"""
Below we discuss particular challenges and some alternative ways to resolve such issues.
"""

# ╔═╡ 03cf435e-9e19-11eb-11c9-994502cd9aa9
md"""
### Tuple and NTuple arguments
"""

# ╔═╡ 03cf4386-9e19-11eb-2235-0f4ae2736ecb
md"""
`Tuple` (and `NTuple`) arguments present special challenges. For example,
"""

# ╔═╡ 03cf4390-9e19-11eb-2690-9b20b275e75a
md"""
```julia
f(x::NTuple{N,Int}) where {N} = 1
f(x::NTuple{N,Float64}) where {N} = 2
```
"""

# ╔═╡ 03cf43ae-9e19-11eb-127f-197e4b9aaf03
md"""
are ambiguous because of the possibility that `N == 0`: there are no elements to determine whether the `Int` or `Float64` variant should be called. To resolve the ambiguity, one approach is define a method for the empty tuple:
"""

# ╔═╡ 03cf43cc-9e19-11eb-1fb3-25176f823e4a
md"""
```julia
f(x::Tuple{}) = 3
```
"""

# ╔═╡ 03cf43e0-9e19-11eb-005c-ef7e87bb8e9d
md"""
Alternatively, for all methods but one you can insist that there is at least one element in the tuple:
"""

# ╔═╡ 03cf43f4-9e19-11eb-0790-c741546389f3
md"""
```julia
f(x::NTuple{N,Int}) where {N} = 1           # this is the fallback
f(x::Tuple{Float64, Vararg{Float64}}) = 2   # this requires at least one Float64
```
"""

# ╔═╡ 03cf4412-9e19-11eb-28ec-6f1e518c453f
md"""
### [Orthogonalize your design](@id man-methods-orthogonalize)
"""

# ╔═╡ 03cf441e-9e19-11eb-157d-d520e648466d
md"""
When you might be tempted to dispatch on two or more arguments, consider whether a "wrapper" function might make for a simpler design. For example, instead of writing multiple variants:
"""

# ╔═╡ 03cf4430-9e19-11eb-09cf-a11be9e583f4
md"""
```julia
f(x::A, y::A) = ...
f(x::A, y::B) = ...
f(x::B, y::A) = ...
f(x::B, y::B) = ...
```
"""

# ╔═╡ 03cf4444-9e19-11eb-3361-b18d09fcf4da
md"""
you might consider defining
"""

# ╔═╡ 03cf4458-9e19-11eb-0711-15d0d77c7c6b
md"""
```julia
f(x::A, y::A) = ...
f(x, y) = f(g(x), g(y))
```
"""

# ╔═╡ 03cf4476-9e19-11eb-335a-778ad3d81083
md"""
where `g` converts the argument to type `A`. This is a very specific example of the more general principle of [orthogonal design](https://en.wikipedia.org/wiki/Orthogonality_(programming)), in which separate concepts are assigned to separate methods. Here, `g` will most likely need a fallback definition
"""

# ╔═╡ 03cf448a-9e19-11eb-01ec-cbd09c7b0cc8
md"""
```julia
g(x::A) = x
```
"""

# ╔═╡ 03cf44a8-9e19-11eb-2478-c58155d5086b
md"""
A related strategy exploits `promote` to bring `x` and `y` to a common type:
"""

# ╔═╡ 03cf44bc-9e19-11eb-282a-e376d52e712f
md"""
```julia
f(x::T, y::T) where {T} = ...
f(x, y) = f(promote(x, y)...)
```
"""

# ╔═╡ 03cf44da-9e19-11eb-2de3-a11009f3458f
md"""
One risk with this design is the possibility that if there is no suitable promotion method converting `x` and `y` to the same type, the second method will recurse on itself infinitely and trigger a stack overflow.
"""

# ╔═╡ 03cf44f8-9e19-11eb-1425-a792dca13a5b
md"""
### Dispatch on one argument at a time
"""

# ╔═╡ 03cf450c-9e19-11eb-3fa9-c30c66369b79
md"""
If you need to dispatch on multiple arguments, and there are many fallbacks with too many combinations to make it practical to define all possible variants, then consider introducing a "name cascade" where (for example) you dispatch on the first argument and then call an internal method:
"""

# ╔═╡ 03cf4520-9e19-11eb-2d81-b78ad332aef1
md"""
```julia
f(x::A, y) = _fA(x, y)
f(x::B, y) = _fB(x, y)
```
"""

# ╔═╡ 03cf453e-9e19-11eb-1f64-390a8b5ffe40
md"""
Then the internal methods `_fA` and `_fB` can dispatch on `y` without concern about ambiguities with each other with respect to `x`.
"""

# ╔═╡ 03cf455c-9e19-11eb-3504-5dbf05a78424
md"""
Be aware that this strategy has at least one major disadvantage: in many cases, it is not possible for users to further customize the behavior of `f` by defining further specializations of your exported function `f`. Instead, they have to define specializations for your internal methods `_fA` and `_fB`, and this blurs the lines between exported and internal methods.
"""

# ╔═╡ 03cf4570-9e19-11eb-009f-33985fd928a6
md"""
### Abstract containers and element types
"""

# ╔═╡ 03cf4586-9e19-11eb-3b21-f9ea8638f036
md"""
Where possible, try to avoid defining methods that dispatch on specific element types of abstract containers. For example,
"""

# ╔═╡ 03cf4598-9e19-11eb-23a9-ff4b8aa72b9c
md"""
```julia
-(A::AbstractArray{T}, b::Date) where {T<:Date}
```
"""

# ╔═╡ 03cf45ac-9e19-11eb-2767-c3a27e422e2a
md"""
generates ambiguities for anyone who defines a method
"""

# ╔═╡ 03cf45b8-9e19-11eb-38b2-f984b4c86380
md"""
```julia
-(A::MyArrayType{T}, b::T) where {T}
```
"""

# ╔═╡ 03cf45fc-9e19-11eb-2479-e5286ea54f95
md"""
The best approach is to avoid defining *either* of these methods: instead, rely on a generic method `-(A::AbstractArray, b)` and make sure this method is implemented with generic calls (like `similar` and `-`) that do the right thing for each container type and element type *separately*. This is just a more complex variant of the advice to [orthogonalize](@ref man-methods-orthogonalize) your methods.
"""

# ╔═╡ 03cf4606-9e19-11eb-16ae-f5b431560c3e
md"""
When this approach is not possible, it may be worth starting a discussion with other developers about resolving the ambiguity; just because one method was defined first does not necessarily mean that it can't be modified or eliminated.  As a last resort, one developer can define the "band-aid" method
"""

# ╔═╡ 03cf4618-9e19-11eb-3f33-eb6731578697
md"""
```julia
-(A::MyArrayType{T}, b::Date) where {T<:Date} = ...
```
"""

# ╔═╡ 03cf4638-9e19-11eb-26db-0d2f0d544276
md"""
that resolves the ambiguity by brute force.
"""

# ╔═╡ 03cf464a-9e19-11eb-24f8-8d37f83195e6
md"""
### Complex method "cascades" with default arguments
"""

# ╔═╡ 03cf4660-9e19-11eb-3080-49e64c8cd973
md"""
If you are defining a method "cascade" that supplies defaults, be careful about dropping any arguments that correspond to potential defaults. For example, suppose you're writing a digital filtering algorithm and you have a method that handles the edges of the signal by applying padding:
"""

# ╔═╡ 03cf4674-9e19-11eb-3420-f3049e2f6a15
md"""
```julia
function myfilter(A, kernel, ::Replicate)
    Apadded = replicate_edges(A, size(kernel))
    myfilter(Apadded, kernel)  # now perform the "real" computation
end
```
"""

# ╔═╡ 03cf467e-9e19-11eb-0926-7fd7ba91e194
md"""
This will run afoul of a method that supplies default padding:
"""

# ╔═╡ 03cf4692-9e19-11eb-106c-819294771f18
md"""
```julia
myfilter(A, kernel) = myfilter(A, kernel, Replicate()) # replicate the edge by default
```
"""

# ╔═╡ 03cf46b0-9e19-11eb-2d50-575bb12894f9
md"""
Together, these two methods generate an infinite recursion with `A` constantly growing bigger.
"""

# ╔═╡ 03cf46bc-9e19-11eb-0a88-776d5ec655d6
md"""
The better design would be to define your call hierarchy like this:
"""

# ╔═╡ 03cf46ce-9e19-11eb-0c5e-bf21ca6fc09b
md"""
```julia
struct NoPad end  # indicate that no padding is desired, or that it's already applied

myfilter(A, kernel) = myfilter(A, kernel, Replicate())  # default boundary conditions

function myfilter(A, kernel, ::Replicate)
    Apadded = replicate_edges(A, size(kernel))
    myfilter(Apadded, kernel, NoPad())  # indicate the new boundary conditions
end

# other padding methods go here

function myfilter(A, kernel, ::NoPad)
    # Here's the "real" implementation of the core computation
end
```
"""

# ╔═╡ 03cf46f6-9e19-11eb-3f94-a5f70fab04a8
md"""
`NoPad` is supplied in the same argument position as any other kind of padding, so it keeps the dispatch hierarchy well organized and with reduced likelihood of ambiguities. Moreover, it extends the "public" `myfilter` interface: a user who wants to control the padding explicitly can call the `NoPad` variant directly.
"""

# ╔═╡ 03cf4764-9e19-11eb-2de6-2db35717096b
md"""
[^Clarke61]: Arthur C. Clarke, *Profiles of the Future* (1961): Clarke's Third Law.
"""

# ╔═╡ Cell order:
# ╟─03ce9706-9e19-11eb-3939-83b370fc5391
# ╟─03ce9846-9e19-11eb-0dcd-bb00199c2630
# ╟─03ce9882-9e19-11eb-23a8-7df63c0f43bc
# ╟─03ce98e6-9e19-11eb-208f-d9d94802fdbb
# ╟─03ce9a12-9e19-11eb-1db2-3388f667031d
# ╟─03ce9ac6-9e19-11eb-28df-5188d1fda3b8
# ╟─03ce9b02-9e19-11eb-372e-cfdd8baeaf69
# ╟─03ce9b2a-9e19-11eb-3b4a-e9042a8e6cb4
# ╟─03ce9b48-9e19-11eb-1bb0-9d58e82c71c9
# ╠═03cea2fa-9e19-11eb-19f6-2ffcae2ca33a
# ╟─03cea354-9e19-11eb-1622-9d8c398462f4
# ╠═03cea502-9e19-11eb-1f55-a59d49adf575
# ╟─03cea53e-9e19-11eb-0cee-4110721dba60
# ╠═03ceab56-9e19-11eb-0c0b-43da6bf96c75
# ╠═03ceab60-9e19-11eb-1ee6-c1664a47ce09
# ╠═03ceab9c-9e19-11eb-1fa5-9dc7d5c93ff5
# ╠═03ceab9c-9e19-11eb-08b2-41b6f8c16ac2
# ╟─03ceabd8-9e19-11eb-39c6-a5cb22f0c129
# ╠═03ceafe8-9e19-11eb-388e-23e271b9d04e
# ╠═03ceaffc-9e19-11eb-30aa-e7198179b3cb
# ╟─03ceb042-9e19-11eb-1cfa-19a895ce48f9
# ╟─03ceb0a6-9e19-11eb-035b-9db2e0b01b4e
# ╠═03ceb4a2-9e19-11eb-2795-81913800d535
# ╠═03ceb4a2-9e19-11eb-06fb-63aadf4779ea
# ╠═03ceb4b6-9e19-11eb-24e5-b996795f4f9b
# ╠═03ceb4b6-9e19-11eb-1495-fb2a1bf414ea
# ╟─03ceb4e8-9e19-11eb-1636-99f37dbdc6ca
# ╟─03ceb510-9e19-11eb-20f7-652f870801ba
# ╠═03ceb722-9e19-11eb-0903-b72c4c13eaee
# ╠═03ceb72a-9e19-11eb-3215-c3d3735db9f7
# ╟─03ceb740-9e19-11eb-21e7-cbf29cfbf40b
# ╠═03ceb7b8-9e19-11eb-3dba-99b2f16dbdba
# ╟─03ceb7f4-9e19-11eb-1749-af319daf3b76
# ╠═03ceb8d0-9e19-11eb-3061-371f648b9cf0
# ╟─03ceb8f6-9e19-11eb-079a-cdfd292e2804
# ╟─03ceb916-9e19-11eb-3f71-8b7bd8714124
# ╠═03cebfb0-9e19-11eb-3c99-ef1dd3342467
# ╠═03cebfba-9e19-11eb-3a3d-93edfde645d0
# ╠═03cebfba-9e19-11eb-20ed-b1583ec80c3d
# ╟─03cebfec-9e19-11eb-2b44-3f34995a7561
# ╟─03cec032-9e19-11eb-20ce-2380e1092417
# ╟─03cec03e-9e19-11eb-34c3-af84ad734e47
# ╠═03cec19a-9e19-11eb-08ee-e3d990573e93
# ╟─03cec1b8-9e19-11eb-3a39-1dddca89300a
# ╟─03cec1e0-9e19-11eb-3f6b-e3f5666b43d1
# ╟─03cec1f4-9e19-11eb-3409-fdf2aa935ef5
# ╠═03ceca64-9e19-11eb-2652-ab858396f311
# ╠═03ceca6e-9e19-11eb-0c7d-bb8a014545d7
# ╠═03ceca6e-9e19-11eb-3076-5349f6f41f8e
# ╠═03ceca76-9e19-11eb-37c9-455e70d292c8
# ╠═03ceca82-9e19-11eb-1a0a-dff9b025ce6d
# ╟─03cecaf0-9e19-11eb-38fe-0339b8912616
# ╠═03ced34c-9e19-11eb-36e0-8fc1da62e822
# ╠═03ced356-9e19-11eb-35ac-517ab8bd519f
# ╠═03ced360-9e19-11eb-3909-c74bb83833c8
# ╠═03ced37e-9e19-11eb-0daf-99d73668cb38
# ╟─03ced3a6-9e19-11eb-1afe-05869f47915a
# ╟─03ced3d8-9e19-11eb-3a28-a93ce15a0fb7
# ╟─03ced3f6-9e19-11eb-2796-abe128db7569
# ╟─03ced40a-9e19-11eb-00c7-275e46fef727
# ╠═03ced874-9e19-11eb-092d-732746645512
# ╠═03ced874-9e19-11eb-3929-67ed17ca2170
# ╟─03ced892-9e19-11eb-056b-7ba9e86a14d6
# ╠═03cee116-9e19-11eb-1c80-3f36f0b5fbd1
# ╠═03cee120-9e19-11eb-066a-ffffccc557d4
# ╠═03cee120-9e19-11eb-397e-378bff99455f
# ╠═03cee12a-9e19-11eb-34d4-9d588f83405e
# ╠═03cee136-9e19-11eb-37ee-b774ca21eea6
# ╠═03cee13e-9e19-11eb-110e-153374f6175d
# ╟─03cee17a-9e19-11eb-358a-7dc7c97fe446
# ╟─03cee1a2-9e19-11eb-2f7e-476f3a74694a
# ╠═03cef2a8-9e19-11eb-282b-3db057d30609
# ╠═03cef2b4-9e19-11eb-3c45-c390d4f81209
# ╠═03cef2be-9e19-11eb-2862-993622339f28
# ╠═03cef2be-9e19-11eb-134a-51a5954e21ed
# ╠═03cef2c8-9e19-11eb-3f6f-971f6a906817
# ╟─03cef32c-9e19-11eb-0936-75d03286764d
# ╠═03cefafc-9e19-11eb-2d81-d73ba3683c80
# ╠═03cefb06-9e19-11eb-33a5-a9d101155c84
# ╠═03cefb10-9e19-11eb-3a64-ef99f40df962
# ╟─03cefb74-9e19-11eb-19cd-ab224cde1731
# ╠═03cf08da-9e19-11eb-1650-194bff926967
# ╠═03cf08da-9e19-11eb-33ac-d9eb2b3f3714
# ╠═03cf08e4-9e19-11eb-0cfe-f71e7df63900
# ╠═03cf08f8-9e19-11eb-0e89-1347b1e50539
# ╠═03cf08f8-9e19-11eb-3fcf-59bf92164dda
# ╠═03cf0904-9e19-11eb-23ea-f3efb895468f
# ╠═03cf0904-9e19-11eb-124f-617701ab7bfb
# ╠═03cf090c-9e19-11eb-1100-e519036862c2
# ╟─03cf0936-9e19-11eb-1c1f-9b9a3287003b
# ╟─03cf0970-9e19-11eb-3523-5359b65eb16b
# ╟─03cf098e-9e19-11eb-22a0-6fd6d91f0334
# ╟─03cf09b6-9e19-11eb-2cff-af76accc8573
# ╠═03cf0e16-9e19-11eb-0864-c956df715700
# ╠═03cf0e20-9e19-11eb-1576-b7e63f0a7527
# ╠═03cf0e2a-9e19-11eb-2a7a-9f8705618a7f
# ╟─03cf0e8e-9e19-11eb-11d5-49145776777c
# ╟─03cf0eb6-9e19-11eb-237b-2be9382dbac2
# ╟─03cf0ede-9e19-11eb-0209-2f8273fc5983
# ╟─03cf0ef2-9e19-11eb-281d-03d49d03cab8
# ╟─03cf0f10-9e19-11eb-3aad-f971ba467356
# ╟─03cf0f2e-9e19-11eb-14e1-4d1792f759cc
# ╠═03cf1348-9e19-11eb-1d22-55927602a8e7
# ╠═03cf135c-9e19-11eb-3ead-1df102e0bf0c
# ╟─03cf137a-9e19-11eb-0e4d-cf7a771d3d06
# ╠═03cf14f6-9e19-11eb-0acd-f740885e4d00
# ╟─03cf1514-9e19-11eb-3714-3354c4cdfb8c
# ╠═03cf18aa-9e19-11eb-2171-6314f08e1a0e
# ╠═03cf18aa-9e19-11eb-049a-419df6dfcaa6
# ╟─03cf18ca-9e19-11eb-280f-f7b57f677470
# ╠═03cf1c82-9e19-11eb-17aa-d17a907b6037
# ╠═03cf1c9e-9e19-11eb-003e-7d72c46eea49
# ╟─03cf1cb0-9e19-11eb-3189-65a8c6d663f9
# ╠═03cf2342-9e19-11eb-1244-b541a91ee192
# ╠═03cf234c-9e19-11eb-3b2c-cfc248a60c97
# ╠═03cf2358-9e19-11eb-317d-0b746abd0ec1
# ╠═03cf2360-9e19-11eb-0242-b3157b43b3b3
# ╠═03cf2360-9e19-11eb-352e-a3b35c29b47d
# ╟─03cf237e-9e19-11eb-1878-413e77e55486
# ╟─03cf2392-9e19-11eb-1a05-5dd94f63daaf
# ╟─03cf23d8-9e19-11eb-2e41-adc32bed9ee5
# ╟─03cf23f6-9e19-11eb-1fc6-374cdeaf1ce0
# ╟─03cf243c-9e19-11eb-2764-b779eb2193c9
# ╟─03cf2464-9e19-11eb-29cd-dd456f5c4454
# ╟─03cf2478-9e19-11eb-34be-cdb90eb35a72
# ╟─03cf24a0-9e19-11eb-11de-778ddccddb2a
# ╟─03cf24c0-9e19-11eb-0eaa-41f2dc757cc0
# ╟─03cf24dc-9e19-11eb-351f-270397ff65ad
# ╟─03cf24fa-9e19-11eb-2d19-d5499fe2584a
# ╟─03cf2504-9e19-11eb-1bc8-3d8595f2dc57
# ╟─03cf2518-9e19-11eb-21c7-a38598fc7728
# ╟─03cf252c-9e19-11eb-3b33-8bb4cfb90e25
# ╟─03cf2552-9e19-11eb-0dd3-33f71eb37f74
# ╟─03cf2568-9e19-11eb-1f44-7dac74afa843
# ╟─03cf257c-9e19-11eb-2fd2-79168ea0ce60
# ╟─03cf25a4-9e19-11eb-027b-7fbb9f7e1eef
# ╟─03cf25b8-9e19-11eb-0aee-45a0a49f890c
# ╟─03cf25ea-9e19-11eb-357f-2bb2e0ff4653
# ╟─03cf261c-9e19-11eb-39f6-37e132e67b18
# ╟─03cf2628-9e19-11eb-0443-657afddb0fa1
# ╟─03cf263a-9e19-11eb-0643-8904bcc7afc3
# ╟─03cf2656-9e19-11eb-3e71-a94d4a233071
# ╟─03cf266c-9e19-11eb-3844-c128d0f7a2b1
# ╟─03cf2680-9e19-11eb-153e-6903f47b5a56
# ╟─03cf269e-9e19-11eb-3c5e-29bca4113b4c
# ╟─03cf26ba-9e19-11eb-3f9f-b146ebd24bbd
# ╟─03cf26f8-9e19-11eb-27dd-a1cefa7bdf30
# ╟─03cf2716-9e19-11eb-30c5-35eab7f54cfd
# ╟─03cf273e-9e19-11eb-15b4-7bc31e65e84f
# ╟─03cf2752-9e19-11eb-2b9d-2139c32f490c
# ╟─03cf2766-9e19-11eb-1cb0-a5d11a53be87
# ╟─03cf27ac-9e19-11eb-15aa-510c90e3e34e
# ╟─03cf27b6-9e19-11eb-0dfa-5b440fffad3b
# ╟─03cf293c-9e19-11eb-042d-19561c78b1b5
# ╟─03cf2958-9e19-11eb-2da0-a5e20a9095fb
# ╟─03cf29a0-9e19-11eb-1cfd-114d4ef43a91
# ╟─03cf29aa-9e19-11eb-3bb1-530902492101
# ╟─03cf29c8-9e19-11eb-187f-e9f1cbfda4ab
# ╟─03cf29dc-9e19-11eb-2a1f-eb4e77aa2143
# ╟─03cf29f0-9e19-11eb-1feb-c7c9c7541df0
# ╟─03cf2a04-9e19-11eb-0e25-fb1a52896e05
# ╟─03cf2a2e-9e19-11eb-2648-ff5b130667a3
# ╠═03cf30b2-9e19-11eb-1e8d-e5ebcb698e1f
# ╠═03cf30bc-9e19-11eb-1381-fb4591dd63cc
# ╠═03cf30bc-9e19-11eb-0309-ffab01acfcb2
# ╠═03cf30da-9e19-11eb-2895-01c579743611
# ╟─03cf30ee-9e19-11eb-0987-bbf852f5bafb
# ╟─03cf3104-9e19-11eb-111a-9986a845c833
# ╟─03cf3120-9e19-11eb-14d1-13428500ab46
# ╟─03cf313e-9e19-11eb-3f98-25e5f5d5f61d
# ╟─03cf3152-9e19-11eb-3461-99126093d4eb
# ╟─03cf3170-9e19-11eb-073c-89b0fca3a0e0
# ╟─03cf3184-9e19-11eb-171e-73343b719361
# ╟─03cf318e-9e19-11eb-373c-1970a255a597
# ╟─03cf31a2-9e19-11eb-28a7-c575beb18e16
# ╟─03cf31de-9e19-11eb-13ac-c71e06b49d61
# ╟─03cf31f2-9e19-11eb-3b03-99574bb83665
# ╟─03cf3206-9e19-11eb-3893-2180432c6244
# ╟─03cf322e-9e19-11eb-274b-f3b87711a025
# ╟─03cf323a-9e19-11eb-273d-4ffa0eb50c44
# ╟─03cf324c-9e19-11eb-2932-37bf8c1e1e6b
# ╟─03cf3260-9e19-11eb-1527-c98edb8b58a7
# ╠═03cf3eb8-9e19-11eb-253f-0ba07f6f6a78
# ╠═03cf3ec2-9e19-11eb-2ef7-615f0675d31a
# ╠═03cf3ec2-9e19-11eb-1790-27f603b7136f
# ╟─03cf3eea-9e19-11eb-3166-77fd7faf5295
# ╠═03cf4232-9e19-11eb-23bf-c57f742f676d
# ╠═03cf4232-9e19-11eb-3281-0f14479c4dfb
# ╠═03cf423c-9e19-11eb-367e-2b99093e13c8
# ╟─03cf4250-9e19-11eb-0f45-3dd2327aac56
# ╟─03cf4264-9e19-11eb-377b-d55b6f6fc8fb
# ╟─03cf4282-9e19-11eb-07ce-9fb34018e288
# ╟─03cf42a0-9e19-11eb-3bea-2fa56ba08dc7
# ╟─03cf42b6-9e19-11eb-3f99-19c462101262
# ╟─03cf42d2-9e19-11eb-0645-03e4e24e3d78
# ╟─03cf42e8-9e19-11eb-35f8-c7625b0a7581
# ╟─03cf42fa-9e19-11eb-3ead-bb0e792d9ebe
# ╟─03cf430e-9e19-11eb-3e96-436b063b0e3c
# ╟─03cf4316-9e19-11eb-31bc-0f760cd65669
# ╟─03cf4336-9e19-11eb-26ce-cf90508e574e
# ╟─03cf4340-9e19-11eb-02ee-ff3a06fe1451
# ╟─03cf435e-9e19-11eb-11c9-994502cd9aa9
# ╟─03cf4386-9e19-11eb-2235-0f4ae2736ecb
# ╟─03cf4390-9e19-11eb-2690-9b20b275e75a
# ╟─03cf43ae-9e19-11eb-127f-197e4b9aaf03
# ╟─03cf43cc-9e19-11eb-1fb3-25176f823e4a
# ╟─03cf43e0-9e19-11eb-005c-ef7e87bb8e9d
# ╟─03cf43f4-9e19-11eb-0790-c741546389f3
# ╟─03cf4412-9e19-11eb-28ec-6f1e518c453f
# ╟─03cf441e-9e19-11eb-157d-d520e648466d
# ╟─03cf4430-9e19-11eb-09cf-a11be9e583f4
# ╟─03cf4444-9e19-11eb-3361-b18d09fcf4da
# ╟─03cf4458-9e19-11eb-0711-15d0d77c7c6b
# ╟─03cf4476-9e19-11eb-335a-778ad3d81083
# ╟─03cf448a-9e19-11eb-01ec-cbd09c7b0cc8
# ╟─03cf44a8-9e19-11eb-2478-c58155d5086b
# ╟─03cf44bc-9e19-11eb-282a-e376d52e712f
# ╟─03cf44da-9e19-11eb-2de3-a11009f3458f
# ╟─03cf44f8-9e19-11eb-1425-a792dca13a5b
# ╟─03cf450c-9e19-11eb-3fa9-c30c66369b79
# ╟─03cf4520-9e19-11eb-2d81-b78ad332aef1
# ╟─03cf453e-9e19-11eb-1f64-390a8b5ffe40
# ╟─03cf455c-9e19-11eb-3504-5dbf05a78424
# ╟─03cf4570-9e19-11eb-009f-33985fd928a6
# ╟─03cf4586-9e19-11eb-3b21-f9ea8638f036
# ╟─03cf4598-9e19-11eb-23a9-ff4b8aa72b9c
# ╟─03cf45ac-9e19-11eb-2767-c3a27e422e2a
# ╟─03cf45b8-9e19-11eb-38b2-f984b4c86380
# ╟─03cf45fc-9e19-11eb-2479-e5286ea54f95
# ╟─03cf4606-9e19-11eb-16ae-f5b431560c3e
# ╟─03cf4618-9e19-11eb-3f33-eb6731578697
# ╟─03cf4638-9e19-11eb-26db-0d2f0d544276
# ╟─03cf464a-9e19-11eb-24f8-8d37f83195e6
# ╟─03cf4660-9e19-11eb-3080-49e64c8cd973
# ╟─03cf4674-9e19-11eb-3420-f3049e2f6a15
# ╟─03cf467e-9e19-11eb-0926-7fd7ba91e194
# ╟─03cf4692-9e19-11eb-106c-819294771f18
# ╟─03cf46b0-9e19-11eb-2d50-575bb12894f9
# ╟─03cf46bc-9e19-11eb-0a88-776d5ec655d6
# ╟─03cf46ce-9e19-11eb-0c5e-bf21ca6fc09b
# ╟─03cf46f6-9e19-11eb-3f94-a5f70fab04a8
# ╟─03cf4764-9e19-11eb-2de6-2db35717096b
