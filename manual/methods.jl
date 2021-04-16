### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ cd74a764-9d84-42e8-a59b-5e4e479562b7
md"""
# Methods
"""

# ╔═╡ b54f037f-34ec-44c1-bda9-d4297794d723
md"""
Recall from [Functions](@ref man-functions) that a function is an object that maps a tuple of arguments to a return value, or throws an exception if no appropriate value can be returned. It is common for the same conceptual function or operation to be implemented quite differently for different types of arguments: adding two integers is very different from adding two floating-point numbers, both of which are distinct from adding an integer to a floating-point number. Despite their implementation differences, these operations all fall under the general concept of \"addition\". Accordingly, in Julia, these behaviors all belong to a single object: the `+` function.
"""

# ╔═╡ aae21b35-9f91-433a-a232-4b49046db0cd
md"""
To facilitate using many different implementations of the same concept smoothly, functions need not be defined all at once, but can rather be defined piecewise by providing specific behaviors for certain combinations of argument types and counts. A definition of one possible behavior for a function is called a *method*. Thus far, we have presented only examples of functions defined with a single method, applicable to all types of arguments. However, the signatures of method definitions can be annotated to indicate the types of arguments in addition to their number, and more than a single method definition may be provided. When a function is applied to a particular tuple of arguments, the most specific method applicable to those arguments is applied. Thus, the overall behavior of a function is a patchwork of the behaviors of its various method definitions. If the patchwork is well designed, even though the implementations of the methods may be quite different, the outward behavior of the function will appear seamless and consistent.
"""

# ╔═╡ 6eb86f13-4127-48f2-a59a-1bb71dd16b7a
md"""
The choice of which method to execute when a function is applied is called *dispatch*. Julia allows the dispatch process to choose which of a function's methods to call based on the number of arguments given, and on the types of all of the function's arguments. This is different than traditional object-oriented languages, where dispatch occurs based only on the first argument, which often has a special argument syntax, and is sometimes implied rather than explicitly written as an argument. [^1] Using all of a function's arguments to choose which method should be invoked, rather than just the first, is known as [multiple dispatch](https://en.wikipedia.org/wiki/Multiple_dispatch). Multiple dispatch is particularly useful for mathematical code, where it makes little sense to artificially deem the operations to \"belong\" to one argument more than any of the others: does the addition operation in `x + y` belong to `x` any more than it does to `y`? The implementation of a mathematical operator generally depends on the types of all of its arguments. Even beyond mathematical operations, however, multiple dispatch ends up being a powerful and convenient paradigm for structuring and organizing programs.
"""

# ╔═╡ c1c3d4d8-ead9-46cf-b35d-1958e0d9bb1c
md"""
[^1]: In C++ or Java, for example, in a method call like `obj.meth(arg1,arg2)`, the object obj \"receives\" the method call and is implicitly passed to the method via the `this` keyword, rather than as an explicit method argument. When the current `this` object is the receiver of a method call, it can be omitted altogether, writing just `meth(arg1,arg2)`, with `this` implied as the receiving object.
"""

# ╔═╡ 3fee0837-9348-4637-8a08-12cd74ee8c70
md"""
!!! note
    All the examples in this chapter assume that you are defining modules for a function in the *same* module. If you want to add methods to a function in *another* module, you have to `import` it or use the name qualified with module names. See the section on [namespace management](@ref namespace-management).
"""

# ╔═╡ feec78dc-2f33-4b87-afe4-b1c27aa6d6e3
md"""
## Defining Methods
"""

# ╔═╡ 73c48fd9-334c-492e-8abb-f324c5f625e9
md"""
Until now, we have, in our examples, defined only functions with a single method having unconstrained argument types. Such functions behave just like they would in traditional dynamically typed languages. Nevertheless, we have used multiple dispatch and methods almost continually without being aware of it: all of Julia's standard functions and operators, like the aforementioned `+` function, have many methods defining their behavior over various possible combinations of argument type and count.
"""

# ╔═╡ 61e804e2-704a-487e-9a0b-aa44267260c1
md"""
When defining a function, one can optionally constrain the types of parameters it is applicable to, using the `::` type-assertion operator, introduced in the section on [Composite Types](@ref):
"""

# ╔═╡ aaa1ab25-4763-4ae1-9d76-0d1f69f76f27
f(x::Float64, y::Float64) = 2x + y

# ╔═╡ f3e38e95-87f1-4e6c-bda7-3a7fdbb748bd
md"""
This function definition applies only to calls where `x` and `y` are both values of type [`Float64`](@ref):
"""

# ╔═╡ 17036359-15bc-4862-b7c3-ed81b58fbf93
f(2.0, 3.0)

# ╔═╡ 3d4dcfa1-82a6-4f4a-b956-3e1df5691ff1
md"""
Applying it to any other types of arguments will result in a [`MethodError`](@ref):
"""

# ╔═╡ 1cd102cc-11d6-4df9-b1b8-80d7797a7aa7
f(2.0, 3)

# ╔═╡ 9ddc7d4b-2ca5-46f0-af15-e117eb77b41b
f(Float32(2.0), 3.0)

# ╔═╡ 93e63edc-a9bc-4d8c-b42a-6236d5d71a71
f(2.0, "3.0")

# ╔═╡ 81fe5077-bc70-4281-8f24-8d1766718904
f("2.0", "3.0")

# ╔═╡ c91714cc-f64b-4fcd-8646-39005d82b92d
md"""
As you can see, the arguments must be precisely of type [`Float64`](@ref). Other numeric types, such as integers or 32-bit floating-point values, are not automatically converted to 64-bit floating-point, nor are strings parsed as numbers. Because `Float64` is a concrete type and concrete types cannot be subclassed in Julia, such a definition can only be applied to arguments that are exactly of type `Float64`. It may often be useful, however, to write more general methods where the declared parameter types are abstract:
"""

# ╔═╡ 9423e342-ad6f-4a9a-9382-ed931d3b005f
f(x::Number, y::Number) = 2x - y

# ╔═╡ 485bdf91-71f4-49af-abab-ab09467607e6
f(2.0, 3)

# ╔═╡ 2b8ad3c9-6ada-47c3-a616-a08c10fb4e75
md"""
This method definition applies to any pair of arguments that are instances of [`Number`](@ref). They need not be of the same type, so long as they are each numeric values. The problem of handling disparate numeric types is delegated to the arithmetic operations in the expression `2x - y`.
"""

# ╔═╡ 4eaaae6f-c921-4121-8c9e-e51c6f6af1bd
md"""
To define a function with multiple methods, one simply defines the function multiple times, with different numbers and types of arguments. The first method definition for a function creates the function object, and subsequent method definitions add new methods to the existing function object. The most specific method definition matching the number and types of the arguments will be executed when the function is applied. Thus, the two method definitions above, taken together, define the behavior for `f` over all pairs of instances of the abstract type `Number` – but with a different behavior specific to pairs of [`Float64`](@ref) values. If one of the arguments is a 64-bit float but the other one is not, then the `f(Float64,Float64)` method cannot be called and the more general `f(Number,Number)` method must be used:
"""

# ╔═╡ 67084698-38d8-41c7-afee-ccf0e07304a9
f(2.0, 3.0)

# ╔═╡ 018334aa-4fa4-401c-b98f-35506ee32b91
f(2, 3.0)

# ╔═╡ 1f26632a-24e7-4845-910b-999b9f238b15
f(2.0, 3)

# ╔═╡ ad1cfada-7c21-41ea-b611-de33e73db6d9
f(2, 3)

# ╔═╡ c1f848ce-6f5d-4a85-887b-83817cc58a09
md"""
The `2x + y` definition is only used in the first case, while the `2x - y` definition is used in the others. No automatic casting or conversion of function arguments is ever performed: all conversion in Julia is non-magical and completely explicit. [Conversion and Promotion](@ref conversion-and-promotion), however, shows how clever application of sufficiently advanced technology can be indistinguishable from magic. [^Clarke61]
"""

# ╔═╡ bc1a949f-da6c-4c8a-a081-fe1275260a19
md"""
For non-numeric values, and for fewer or more than two arguments, the function `f` remains undefined, and applying it will still result in a [`MethodError`](@ref):
"""

# ╔═╡ 19c50861-50f6-43d3-9888-fcaca0713a5b
f("foo", 3)

# ╔═╡ a82062e9-e75f-4281-8195-2e6ece17aadc
f()

# ╔═╡ b91ce8ee-5bd4-4a57-88ba-f3b24b33536e
md"""
You can easily see which methods exist for a function by entering the function object itself in an interactive session:
"""

# ╔═╡ df90b1c0-7cc6-4a91-824e-0ba8baf1a542
f

# ╔═╡ 5cc84e1a-3592-48cd-921d-6067884e5e94
md"""
This output tells us that `f` is a function object with two methods. To find out what the signatures of those methods are, use the [`methods`](@ref) function:
"""

# ╔═╡ 2708942a-c534-4661-831e-bd0e22630107
methods(f)

# ╔═╡ bfcf6ea8-89ca-4fca-8c17-ced78aa14d2f
md"""
which shows that `f` has two methods, one taking two `Float64` arguments and one taking arguments of type `Number`. It also indicates the file and line number where the methods were defined: because these methods were defined at the REPL, we get the apparent line number `none:1`.
"""

# ╔═╡ 1c0977d9-2be1-4f13-9b83-9f838a9518ac
md"""
In the absence of a type declaration with `::`, the type of a method parameter is `Any` by default, meaning that it is unconstrained since all values in Julia are instances of the abstract type `Any`. Thus, we can define a catch-all method for `f` like so:
"""

# ╔═╡ 43b24989-8ab4-45ad-9a00-11a70fb41393
f(x,y) = println("Whoa there, Nelly.")

# ╔═╡ 8ddff8a2-532f-4430-9d72-1aa7c8382104
methods(f)

# ╔═╡ 38de3427-0f57-49ba-8365-1766524bdef2
f("foo", 1)

# ╔═╡ c0a222f8-eeda-4012-9704-25a9464b32e9
md"""
This catch-all is less specific than any other possible method definition for a pair of parameter values, so it will only be called on pairs of arguments to which no other method definition applies.
"""

# ╔═╡ ee199f18-50a6-4153-a917-b1b5ae3830a1
md"""
Note that in the signature of the third method, there is no type specified for the arguments `x` and `y`. This is a shortened way of expressing `f(x::Any, y::Any)`.
"""

# ╔═╡ c0a4ea8e-2776-4332-9f69-f5dc8f9ffbad
md"""
Although it seems a simple concept, multiple dispatch on the types of values is perhaps the single most powerful and central feature of the Julia language. Core operations typically have dozens of methods:
"""

# ╔═╡ 6212fe7b-ee4a-4f7e-8cd6-0d472a5f2a4b
methods(+)

# ╔═╡ 510b1427-0db1-4e83-b52a-a5e2ad0355b1
md"""
Multiple dispatch together with the flexible parametric type system give Julia its ability to abstractly express high-level algorithms decoupled from implementation details, yet generate efficient, specialized code to handle each case at run time.
"""

# ╔═╡ 16d990b7-f00a-4a81-a9b5-81ec7d9a5c9d
md"""
## [Method Ambiguities](@id man-ambiguities)
"""

# ╔═╡ 88f9506c-96f2-48a5-8266-a109ec835b43
md"""
It is possible to define a set of function methods such that there is no unique most specific method applicable to some combinations of arguments:
"""

# ╔═╡ 83dea7fd-040d-4db3-9df7-1a306eb7b9e1
g(x::Float64, y) = 2x + y

# ╔═╡ 8a5f0146-a29d-4a72-afc9-7ffa2277601e
g(x, y::Float64) = x + 2y

# ╔═╡ c7a20fb8-92d2-4719-9890-a80f620490e1
g(2.0, 3)

# ╔═╡ fdf2d170-94e4-4478-8cb5-ca464dcd95d6
g(2, 3.0)

# ╔═╡ a99c4d78-f8eb-4b6d-ae89-f60f9565fcde
g(2.0, 3.0)

# ╔═╡ 384db450-b475-4aa7-8063-801735f075d5
md"""
Here the call `g(2.0, 3.0)` could be handled by either the `g(Float64, Any)` or the `g(Any, Float64)` method, and neither is more specific than the other. In such cases, Julia raises a [`MethodError`](@ref) rather than arbitrarily picking a method. You can avoid method ambiguities by specifying an appropriate method for the intersection case:
"""

# ╔═╡ e5c6884d-a651-4c44-b758-d6298b52031a
g(x::Float64, y::Float64) = 2x + 2y

# ╔═╡ 6cb51af5-2546-4179-86c0-4031c267eba7
g(2.0, 3)

# ╔═╡ be9d3ec3-128d-425a-8863-bdb85b1e951b
g(2, 3.0)

# ╔═╡ 19cb690c-e980-4ecf-a960-e33d874c4250
g(2.0, 3.0)

# ╔═╡ 04d610aa-204d-4e36-8434-6cb1ffa9ce6c
md"""
It is recommended that the disambiguating method be defined first, since otherwise the ambiguity exists, if transiently, until the more specific method is defined.
"""

# ╔═╡ 76b774eb-5c08-4de9-840a-8b465057c6a6
md"""
In more complex cases, resolving method ambiguities involves a certain element of design; this topic is explored further [below](@ref man-method-design-ambiguities).
"""

# ╔═╡ 1fa8e9d1-144c-4d84-a5d1-315f631437ec
md"""
## Parametric Methods
"""

# ╔═╡ ca8e6ffa-5426-4186-98e3-84bde7166cdd
md"""
Method definitions can optionally have type parameters qualifying the signature:
"""

# ╔═╡ 9905248e-4838-456a-8797-d73d910ba46a
same_type(x::T, y::T) where {T} = true

# ╔═╡ 2603be54-70cd-40d1-8e38-74972f9f873b
same_type(x,y) = false

# ╔═╡ d4620c1d-fc76-476b-9c14-f7e80f5553a4
md"""
The first method applies whenever both arguments are of the same concrete type, regardless of what type that is, while the second method acts as a catch-all, covering all other cases. Thus, overall, this defines a boolean function that checks whether its two arguments are of the same type:
"""

# ╔═╡ d572090d-41a8-4463-9c97-9b5d6537403d
same_type(1, 2)

# ╔═╡ e368336b-60f7-47a6-a3ad-0ba6d4b04d62
same_type(1, 2.0)

# ╔═╡ c66e6d1e-5fd7-47c1-bc78-a167edf9b89d
same_type(1.0, 2.0)

# ╔═╡ 2d169ac2-1006-426d-8e79-f0d0ba597056
same_type("foo", 2.0)

# ╔═╡ 3c1d0bf4-5dbb-4b77-ab1b-32c557127fb2
same_type("foo", "bar")

# ╔═╡ b55ba6f5-5ca8-4267-885c-760c013d0a25
same_type(Int32(1), Int64(2))

# ╔═╡ aef57bc5-efce-4fba-9dce-ce4866d2c844
md"""
Such definitions correspond to methods whose type signatures are `UnionAll` types (see [UnionAll Types](@ref)).
"""

# ╔═╡ 16042a7a-97a7-4aa5-bef5-433861d2fdea
md"""
This kind of definition of function behavior by dispatch is quite common – idiomatic, even – in Julia. Method type parameters are not restricted to being used as the types of arguments: they can be used anywhere a value would be in the signature of the function or body of the function. Here's an example where the method type parameter `T` is used as the type parameter to the parametric type `Vector{T}` in the method signature:
"""

# ╔═╡ c307ccb4-dec2-4266-aca1-e15fd7f9ccdb
myappend(v::Vector{T}, x::T) where {T} = [v..., x]

# ╔═╡ fb07d97c-99b3-415a-a708-daeb02aed48d
myappend([1,2,3],4)

# ╔═╡ fa02cb4a-4a24-40dc-81ed-b1bafbbf0517
myappend([1,2,3],2.5)

# ╔═╡ f3900f6a-28e4-4ace-a6b6-50d6f571bdcf
myappend([1.0,2.0,3.0],4.0)

# ╔═╡ 6ac24ad2-df9b-46f6-97a6-b63659bce8b7
myappend([1.0,2.0,3.0],4)

# ╔═╡ ca706449-cc98-4fe4-8f2d-afacc25100ca
md"""
As you can see, the type of the appended element must match the element type of the vector it is appended to, or else a [`MethodError`](@ref) is raised. In the following example, the method type parameter `T` is used as the return value:
"""

# ╔═╡ e5b3c428-bfed-4c59-9781-8a9eeec0a89f
mytypeof(x::T) where {T} = T

# ╔═╡ f7af6eb9-0f61-4b6c-a6c4-9f063d73af41
mytypeof(1)

# ╔═╡ bb33c930-3dba-4dde-b6a2-c12b4faac2d5
mytypeof(1.0)

# ╔═╡ a2bb042d-5bf3-4ee5-ac1d-0e8fd89ecdd3
md"""
Just as you can put subtype constraints on type parameters in type declarations (see [Parametric Types](@ref)), you can also constrain type parameters of methods:
"""

# ╔═╡ f718c8e4-f8a2-4168-96e3-c2b7c7c51416
same_type_numeric(x::T, y::T) where {T<:Number} = true

# ╔═╡ 939dc816-a07b-4ec5-9666-b156dd1995ff
same_type_numeric(x::Number, y::Number) = false

# ╔═╡ bc391a52-ba4c-4ee2-bf52-3999bc36f42a
same_type_numeric(1, 2)

# ╔═╡ 73b161eb-6c38-4c2d-a6e3-6adff1343950
same_type_numeric(1, 2.0)

# ╔═╡ ec202dd8-ae68-47cc-8228-7a310a04354e
same_type_numeric(1.0, 2.0)

# ╔═╡ f4238a16-696f-40e9-b3ca-ae596b9c1a54
same_type_numeric("foo", 2.0)

# ╔═╡ f467fab4-94aa-4f67-b74f-4d43ae8756b3
same_type_numeric("foo", "bar")

# ╔═╡ e7613477-7356-439b-88b8-e06a24f21904
same_type_numeric(Int32(1), Int64(2))

# ╔═╡ 0ca251a6-bae2-4f35-9d1c-c1b1f3677bea
md"""
The `same_type_numeric` function behaves much like the `same_type` function defined above, but is only defined for pairs of numbers.
"""

# ╔═╡ fc5297a9-ba22-42f3-9422-239607b9296a
md"""
Parametric methods allow the same syntax as `where` expressions used to write types (see [UnionAll Types](@ref)). If there is only a single parameter, the enclosing curly braces (in `where {T}`) can be omitted, but are often preferred for clarity. Multiple parameters can be separated with commas, e.g. `where {T, S<:Real}`, or written using nested `where`, e.g. `where S<:Real where T`.
"""

# ╔═╡ c60574ff-1b61-4109-adf0-4c5421ad0e2c
md"""
## Redefining Methods
"""

# ╔═╡ bed7e397-05bf-4f97-8057-f84ad701ada6
md"""
When redefining a method or adding new methods, it is important to realize that these changes don't take effect immediately. This is key to Julia's ability to statically infer and compile code to run fast, without the usual JIT tricks and overhead. Indeed, any new method definition won't be visible to the current runtime environment, including Tasks and Threads (and any previously defined `@generated` functions). Let's start with an example to see what this means:
"""

# ╔═╡ d791bc43-59d5-42ae-8676-c0738da11f47
function tryeval()
     @eval newfun() = 1
     newfun()
 end

# ╔═╡ b69e628d-3862-49ee-9c2a-fece6a017b3e
tryeval()

# ╔═╡ 0bd59c10-32b1-459a-befc-363cde529c71
newfun()

# ╔═╡ 528d2dcc-bd07-4195-ab15-7da6ea150bbd
md"""
In this example, observe that the new definition for `newfun` has been created, but can't be immediately called. The new global is immediately visible to the `tryeval` function, so you could write `return newfun` (without parentheses). But neither you, nor any of your callers, nor the functions they call, or etc. can call this new method definition!
"""

# ╔═╡ d007da36-58f9-404a-85e9-78f94339bea9
md"""
But there's an exception: future calls to `newfun` *from the REPL* work as expected, being able to both see and call the new definition of `newfun`.
"""

# ╔═╡ 4c5dedb6-e87b-411b-9c4f-35b430cbaa08
md"""
However, future calls to `tryeval` will continue to see the definition of `newfun` as it was *at the previous statement at the REPL*, and thus before that call to `tryeval`.
"""

# ╔═╡ 99d282f8-a8d9-4cb4-862c-986859c0c195
md"""
You may want to try this for yourself to see how it works.
"""

# ╔═╡ cae8a505-6aab-41ff-a372-80c88c9cacc5
md"""
The implementation of this behavior is a \"world age counter\". This monotonically increasing value tracks each method definition operation. This allows describing \"the set of method definitions visible to a given runtime environment\" as a single number, or \"world age\". It also allows comparing the methods available in two worlds just by comparing their ordinal value. In the example above, we see that the \"current world\" (in which the method `newfun` exists), is one greater than the task-local \"runtime world\" that was fixed when the execution of `tryeval` started.
"""

# ╔═╡ cf325372-5b60-40c0-b1e2-9f9687b53722
md"""
Sometimes it is necessary to get around this (for example, if you are implementing the above REPL). Fortunately, there is an easy solution: call the function using [`Base.invokelatest`](@ref):
"""

# ╔═╡ a0503cc0-6ee0-4b8a-abaf-4da6d68506e2
function tryeval2()
     @eval newfun2() = 2
     Base.invokelatest(newfun2)
 end

# ╔═╡ f86aafe0-7b9a-40e4-baa9-a71a7efc1535
tryeval2()

# ╔═╡ 489601a7-0d70-4981-b289-628612743fcb
md"""
Finally, let's take a look at some more complex examples where this rule comes into play. Define a function `f(x)`, which initially has one method:
"""

# ╔═╡ f3395e77-20ee-4209-be85-7dc160afa1b4
f(x) = "original definition"

# ╔═╡ 3a6ecf30-6d70-4d85-a8d0-a53129d9f697
md"""
Start some other operations that use `f(x)`:
"""

# ╔═╡ 3124e5ea-b19f-4d8d-a6c6-b6a12b96d3fc
g(x) = f(x)

# ╔═╡ ac5939e9-d6c4-47fc-8744-e89acb404968
t = @async f(wait()); yield();

# ╔═╡ 40324f98-aaea-4c4d-b53e-53cea3eec3f0
md"""
Now we add some new methods to `f(x)`:
"""

# ╔═╡ cf190f6c-9779-4537-9cff-3959c6dc9c6d
f(x::Int) = "definition for Int"

# ╔═╡ 0795614a-09dd-44f2-a77d-c5fdf24c0385
f(x::Type{Int}) = "definition for Type{Int}"

# ╔═╡ 4b5c0b0b-43c2-4d8c-8c3b-6152b528a0a7
md"""
Compare how these results differ:
"""

# ╔═╡ d9bb0180-7fb1-48fc-9ffb-32cd91b4abb2
f(1)

# ╔═╡ d38e5cf4-3a06-4d65-80ef-ea2779ed4dbd
g(1)

# ╔═╡ afd3d2f0-9e9b-46fe-a3c6-6989118da949
fetch(schedule(t, 1))

# ╔═╡ 8bc9ac4b-e447-4caf-932b-ccde57be7096
t = @async f(wait()); yield();

# ╔═╡ fc7fb6b7-d39c-4e0a-ba6e-2dd875074641
fetch(schedule(t, 1))

# ╔═╡ b9200d4e-846a-4ed6-850a-f5b246850aa5
md"""
## Design Patterns with Parametric Methods
"""

# ╔═╡ e376f025-2272-4f65-b15b-0936be4754d9
md"""
While complex dispatch logic is not required for performance or usability, sometimes it can be the best way to express some algorithm. Here are a few common design patterns that come up sometimes when using dispatch in this way.
"""

# ╔═╡ 7fcd3eb8-26a5-4dbb-a539-fddc95d26a66
md"""
### Extracting the type parameter from a super-type
"""

# ╔═╡ 093c2b1e-579e-4f38-b0ca-700d9e2639bf
md"""
Here is the correct code template for returning the element-type `T` of any arbitrary subtype of `AbstractArray`:
"""

# ╔═╡ 4e3cef5e-9c77-4649-843a-7489998293ed
md"""
```julia
abstract type AbstractArray{T, N} end
eltype(::Type{<:AbstractArray{T}}) where {T} = T
```
"""

# ╔═╡ 80562130-623b-46b3-96e5-71d571421dea
md"""
using so-called triangular dispatch.  Note that if `T` is a `UnionAll` type, as e.g. `eltype(Array{T} where T <: Integer)`, then `Any` is returned (as does the version of `eltype` in `Base`).
"""

# ╔═╡ 816d0c00-12fa-4171-a0b1-514b7e230100
md"""
Another way, which used to be the only correct way before the advent of triangular dispatch in Julia v0.6, is:
"""

# ╔═╡ 1e495b92-ecb8-4290-bd34-cf7d5115dea3
md"""
```julia
abstract type AbstractArray{T, N} end
eltype(::Type{AbstractArray}) = Any
eltype(::Type{AbstractArray{T}}) where {T} = T
eltype(::Type{AbstractArray{T, N}}) where {T, N} = T
eltype(::Type{A}) where {A<:AbstractArray} = eltype(supertype(A))
```
"""

# ╔═╡ a74b22b2-3688-432b-878a-8a6573c1bfd9
md"""
Another possibility is the following, which could be useful to adapt to cases where the parameter `T` would need to be matched more narrowly:
"""

# ╔═╡ 7557f437-88a1-4777-bcfc-80e71cb72e5c
md"""
```julia
eltype(::Type{AbstractArray{T, N} where {T<:S, N<:M}}) where {M, S} = Any
eltype(::Type{AbstractArray{T, N} where {T<:S}}) where {N, S} = Any
eltype(::Type{AbstractArray{T, N} where {N<:M}}) where {M, T} = T
eltype(::Type{AbstractArray{T, N}}) where {T, N} = T
eltype(::Type{A}) where {A <: AbstractArray} = eltype(supertype(A))
```
"""

# ╔═╡ 2c9a4f83-08cf-4403-b604-0f997bd97461
md"""
One common mistake is to try and get the element-type by using introspection:
"""

# ╔═╡ ecd5500b-7723-4d2f-b6a4-b36d0f995ebe
md"""
```julia
eltype_wrong(::Type{A}) where {A<:AbstractArray} = A.parameters[1]
```
"""

# ╔═╡ 694bb614-ee85-41d7-bb5b-ac55272de0a7
md"""
However, it is not hard to construct cases where this will fail:
"""

# ╔═╡ 49d4e9e6-edb0-4eaa-a361-56b84590e807
md"""
```julia
struct BitVector <: AbstractArray{Bool, 1}; end
```
"""

# ╔═╡ 577c1bbb-7391-4934-9675-c280f64554fb
md"""
Here we have created a type `BitVector` which has no parameters, but where the element-type is still fully specified, with `T` equal to `Bool`!
"""

# ╔═╡ d70a7c2e-61f0-4486-8c9e-a49ef2c62bd1
md"""
### Building a similar type with a different type parameter
"""

# ╔═╡ b27fc9c0-56b4-4da0-8d1c-29ef6ba9c924
md"""
When building generic code, there is often a need for constructing a similar object with some change made to the layout of the type, also necessitating a change of the type parameters. For instance, you might have some sort of abstract array with an arbitrary element type and want to write your computation on it with a specific element type. We must implement a method for each `AbstractArray{T}` subtype that describes how to compute this type transform. There is no general transform of one subtype into another subtype with a different parameter. (Quick review: do you see why this is?)
"""

# ╔═╡ f3928a3b-9d24-44a6-8bf7-54be6a6f5905
md"""
The subtypes of `AbstractArray` typically implement two methods to achieve this: A method to convert the input array to a subtype of a specific `AbstractArray{T, N}` abstract type; and a method to make a new uninitialized array with a specific element type. Sample implementations of these can be found in Julia Base. Here is a basic example usage of them, guaranteeing that `input` and `output` are of the same type:
"""

# ╔═╡ 230287de-1791-4475-adc3-028f6c91ce72
md"""
```julia
input = convert(AbstractArray{Eltype}, input)
output = similar(input, Eltype)
```
"""

# ╔═╡ 695ef186-42ce-4d97-861b-65a91cecb8a9
md"""
As an extension of this, in cases where the algorithm needs a copy of the input array, [`convert`](@ref) is insufficient as the return value may alias the original input. Combining [`similar`](@ref) (to make the output array) and [`copyto!`](@ref) (to fill it with the input data) is a generic way to express the requirement for a mutable copy of the input argument:
"""

# ╔═╡ 1f80fe20-0503-4b2a-9310-0b51b9b9329a
md"""
```julia
copy_with_eltype(input, Eltype) = copyto!(similar(input, Eltype), input)
```
"""

# ╔═╡ dc90ea5e-4e30-4094-b009-b183295ef29c
md"""
### Iterated dispatch
"""

# ╔═╡ e635e8f8-d11b-43b9-a72c-d979a1dc7717
md"""
In order to dispatch a multi-level parametric argument list, often it is best to separate each level of dispatch into distinct functions. This may sound similar in approach to single-dispatch, but as we shall see below, it is still more flexible.
"""

# ╔═╡ f66812ce-538c-40ae-ae98-23f6b1005211
md"""
For example, trying to dispatch on the element-type of an array will often run into ambiguous situations. Instead, commonly code will dispatch first on the container type, then recurse down to a more specific method based on eltype. In most cases, the algorithms lend themselves conveniently to this hierarchical approach, while in other cases, this rigor must be resolved manually. This dispatching branching can be observed, for example, in the logic to sum two matrices:
"""

# ╔═╡ abcc232c-fd7e-456b-af69-a1db010b5ee0
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

# ╔═╡ d6c46e1e-acec-4855-8310-5463382c2e2f
md"""
### Trait-based dispatch
"""

# ╔═╡ 99357eaa-9cf4-459e-863e-0a6a9b65d55d
md"""
A natural extension to the iterated dispatch above is to add a layer to method selection that allows to dispatch on sets of types which are independent from the sets defined by the type hierarchy. We could construct such a set by writing out a `Union` of the types in question, but then this set would not be extensible as `Union`-types cannot be altered after creation. However, such an extensible set can be programmed with a design pattern often referred to as a [\"Holy-trait\"](https://github.com/JuliaLang/julia/issues/2345#issuecomment-54537633).
"""

# ╔═╡ c3122d7b-045a-4011-9a92-74058efc8dd7
md"""
This pattern is implemented by defining a generic function which computes a different singleton value (or type) for each trait-set to which the function arguments may belong to.  If this function is pure there is no impact on performance compared to normal dispatch.
"""

# ╔═╡ 10fe95af-d928-47d0-8260-f17d18068dc2
md"""
The example in the previous section glossed over the implementation details of [`map`](@ref) and [`promote`](@ref), which both operate in terms of these traits. When iterating over a matrix, such as in the implementation of `map`, one important question is what order to use to traverse the data. When `AbstractArray` subtypes implement the [`Base.IndexStyle`](@ref) trait, other functions such as `map` can dispatch on this information to pick the best algorithm (see [Abstract Array Interface](@ref man-interface-array)). This means that each subtype does not need to implement a custom version of `map`, since the generic definitions + trait classes will enable the system to select the fastest version. Here a toy implementation of `map` illustrating the trait-based dispatch:
"""

# ╔═╡ eafc4965-269e-4ea0-a69b-25f323f13bb4
md"""
```julia
map(f, a::AbstractArray, b::AbstractArray) = map(Base.IndexStyle(a, b), f, a, b)
# generic implementation:
map(::Base.IndexCartesian, f, a::AbstractArray, b::AbstractArray) = ...
# linear-indexing implementation (faster)
map(::Base.IndexLinear, f, a::AbstractArray, b::AbstractArray) = ...
```
"""

# ╔═╡ c0fce545-afc9-453f-ac43-ab2793450c78
md"""
This trait-based approach is also present in the [`promote`](@ref) mechanism employed by the scalar `+`. It uses [`promote_type`](@ref), which returns the optimal common type to compute the operation given the two types of the operands. This makes it possible to reduce the problem of implementing every function for every pair of possible type arguments, to the much smaller problem of implementing a conversion operation from each type to a common type, plus a table of preferred pair-wise promotion rules.
"""

# ╔═╡ 5b5f385d-4fe1-4779-b4bd-1e65cb5fe87a
md"""
### Output-type computation
"""

# ╔═╡ e84f5f5a-e41d-44a4-8832-84f156201367
md"""
The discussion of trait-based promotion provides a transition into our next design pattern: computing the output element type for a matrix operation.
"""

# ╔═╡ 3925b5a8-44a7-4e51-b11d-27156ef43ea5
md"""
For implementing primitive operations, such as addition, we use the [`promote_type`](@ref) function to compute the desired output type. (As before, we saw this at work in the `promote` call in the call to `+`).
"""

# ╔═╡ 887b7a0d-86f4-4613-92c3-ec7a79553db5
md"""
For more complex functions on matrices, it may be necessary to compute the expected return type for a more complex sequence of operations. This is often performed by the following steps:
"""

# ╔═╡ f5ff7d49-2187-489e-8f63-de22d7a65f1e
md"""
1. Write a small function `op` that expresses the set of operations performed by the kernel of the algorithm.
2. Compute the element type `R` of the result matrix as `promote_op(op, argument_types...)`, where `argument_types` is computed from `eltype` applied to each input array.
3. Build the output matrix as `similar(R, dims)`, where `dims` are the desired dimensions of the output array.
"""

# ╔═╡ 1ca312b2-7bfd-4ec1-aa31-777d501c3f10
md"""
For a more specific example, a generic square-matrix multiply pseudo-code might look like:
"""

# ╔═╡ 6b7f2455-c7c1-48a1-b43d-7d02df49bdc3
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

# ╔═╡ 5c776e65-724d-467e-95f2-723f97f16089
md"""
### Separate convert and kernel logic
"""

# ╔═╡ c36fad35-8771-4196-8138-d96a2e249c3d
md"""
One way to significantly cut down on compile-times and testing complexity is to isolate the logic for converting to the desired type and the computation. This lets the compiler specialize and inline the conversion logic independent from the rest of the body of the larger kernel.
"""

# ╔═╡ 5bb28872-c9c9-4985-b88a-4ce810c06666
md"""
This is a common pattern seen when converting from a larger class of types to the one specific argument type that is actually supported by the algorithm:
"""

# ╔═╡ 36cd14f1-4a07-4e6d-bf2f-6149a64a6c8f
md"""
```julia
complexfunction(arg::Int) = ...
complexfunction(arg::Any) = complexfunction(convert(Int, arg))

matmul(a::T, b::T) = ...
matmul(a, b) = matmul(promote(a, b)...)
```
"""

# ╔═╡ 7a6f2ddd-149e-4e49-80fb-8fd1563a0aa8
md"""
## Parametrically-constrained Varargs methods
"""

# ╔═╡ 3cbdcaf1-d55f-4fab-8ad0-dbefcbbcc699
md"""
Function parameters can also be used to constrain the number of arguments that may be supplied to a \"varargs\" function ([Varargs Functions](@ref)).  The notation `Vararg{T,N}` is used to indicate such a constraint.  For example:
"""

# ╔═╡ e3339737-f1f0-471d-8ae3-538acfffedc0
bar(a,b,x::Vararg{Any,2}) = (a,b,x)

# ╔═╡ 68fbd25c-0e14-4da2-a63c-c2861b46d598
bar(1,2,3)

# ╔═╡ 696fae9c-26bf-47b8-9b8b-82be94ae6a7b
bar(1,2,3,4)

# ╔═╡ 0c61770a-1d3d-454a-86a3-e89c35074143
bar(1,2,3,4,5)

# ╔═╡ fe0f5063-1449-4d17-a888-e349c0285580
md"""
More usefully, it is possible to constrain varargs methods by a parameter. For example:
"""

# ╔═╡ 0a75d087-f3a6-4b71-a0d4-5472611e234c
md"""
```julia
function getindex(A::AbstractArray{T,N}, indices::Vararg{Number,N}) where {T,N}
```
"""

# ╔═╡ 94929435-74be-467c-992f-f86e944dcb05
md"""
would be called only when the number of `indices` matches the dimensionality of the array.
"""

# ╔═╡ 4467a049-ee21-4146-be9b-30d1601841b3
md"""
When only the type of supplied arguments needs to be constrained `Vararg{T}` can be equivalently written as `T...`. For instance `f(x::Int...) = x` is a shorthand for `f(x::Vararg{Int}) = x`.
"""

# ╔═╡ b7ede21b-69d3-4f0c-8406-f3ce6583a600
md"""
## Note on Optional and keyword Arguments
"""

# ╔═╡ 9c2eebbf-e0e7-4c05-a56f-a052ff1a95ea
md"""
As mentioned briefly in [Functions](@ref man-functions), optional arguments are implemented as syntax for multiple method definitions. For example, this definition:
"""

# ╔═╡ c2c13839-c290-4fd8-945c-d8d92422ee15
md"""
```julia
f(a=1,b=2) = a+2b
```
"""

# ╔═╡ f81529b7-5ca6-47ae-a74b-b24e517eb9cb
md"""
translates to the following three methods:
"""

# ╔═╡ c4614175-13e2-405d-92fb-cca91dcdcca4
md"""
```julia
f(a,b) = a+2b
f(a) = f(a,2)
f() = f(1,2)
```
"""

# ╔═╡ 94555fdb-bf2b-436d-9287-3eb292b8b78d
md"""
This means that calling `f()` is equivalent to calling `f(1,2)`. In this case the result is `5`, because `f(1,2)` invokes the first method of `f` above. However, this need not always be the case. If you define a fourth method that is more specialized for integers:
"""

# ╔═╡ 8374dfab-5ea8-40a5-ae9e-66b601fa416e
md"""
```julia
f(a::Int,b::Int) = a-2b
```
"""

# ╔═╡ 54309f82-1923-412b-899b-3a68907290b9
md"""
then the result of both `f()` and `f(1,2)` is `-3`. In other words, optional arguments are tied to a function, not to any specific method of that function. It depends on the types of the optional arguments which method is invoked. When optional arguments are defined in terms of a global variable, the type of the optional argument may even change at run-time.
"""

# ╔═╡ 571c28ea-6598-47c2-a508-4e194f4e6eb6
md"""
Keyword arguments behave quite differently from ordinary positional arguments. In particular, they do not participate in method dispatch. Methods are dispatched based only on positional arguments, with keyword arguments processed after the matching method is identified.
"""

# ╔═╡ 1a5a730b-11c0-4b54-ac6c-75258e3238bd
md"""
## Function-like objects
"""

# ╔═╡ 9c6e101a-6079-400e-b55e-32ac71238bc3
md"""
Methods are associated with types, so it is possible to make any arbitrary Julia object \"callable\" by adding methods to its type. (Such \"callable\" objects are sometimes called \"functors.\")
"""

# ╔═╡ 402c3af8-88ce-4b69-92ef-280d858d7564
md"""
For example, you can define a type that stores the coefficients of a polynomial, but behaves like a function evaluating the polynomial:
"""

# ╔═╡ 3d9ada08-4347-4811-913a-5a3c218cea2e
struct Polynomial{R}
     coeffs::Vector{R}
 end

# ╔═╡ c4776c21-b4e2-4511-9ad5-bbecfde3d3ce
function (p::Polynomial)(x)
     v = p.coeffs[end]
     for i = (length(p.coeffs)-1):-1:1
         v = v*x + p.coeffs[i]
     end
     return v
 end

# ╔═╡ b7cc7787-a8ef-4948-b3c2-990e78f8532f
(p::Polynomial)() = p(5)

# ╔═╡ 61bda853-2190-4be2-81b2-a5389966bf59
md"""
Notice that the function is specified by type instead of by name. As with normal functions there is a terse syntax form. In the function body, `p` will refer to the object that was called. A `Polynomial` can be used as follows:
"""

# ╔═╡ 5b08039c-8bb1-4cb1-9b21-d40784f2cd11
p = Polynomial([1,10,100])

# ╔═╡ c9f5cbb6-02f5-4c3e-9f86-09ae3bc35c38
p(3)

# ╔═╡ e7e17a4f-d483-4d6b-b49d-913af16dc341
p()

# ╔═╡ fc3cc3aa-a1a3-4543-9055-f40eae182008
md"""
This mechanism is also the key to how type constructors and closures (inner functions that refer to their surrounding environment) work in Julia.
"""

# ╔═╡ 28a23df5-9fc0-4954-ab8a-c1418fe62052
md"""
## Empty generic functions
"""

# ╔═╡ b21aa2cf-76fa-4e06-bfa8-4e26cce0b1dd
md"""
Occasionally it is useful to introduce a generic function without yet adding methods. This can be used to separate interface definitions from implementations. It might also be done for the purpose of documentation or code readability. The syntax for this is an empty `function` block without a tuple of arguments:
"""

# ╔═╡ 47aa1a2e-7ff0-4cb9-ae7d-70a00273833b
md"""
```julia
function emptyfunc end
```
"""

# ╔═╡ d4d532bc-befa-4f61-8a83-b928b317cfb7
md"""
## [Method design and the avoidance of ambiguities](@id man-method-design-ambiguities)
"""

# ╔═╡ ccee4a8f-2926-4a63-8cb7-968e348310d7
md"""
Julia's method polymorphism is one of its most powerful features, yet exploiting this power can pose design challenges.  In particular, in more complex method hierarchies it is not uncommon for [ambiguities](@ref man-ambiguities) to arise.
"""

# ╔═╡ 69ab16bb-369c-4bde-a180-c25103187c4b
md"""
Above, it was pointed out that one can resolve ambiguities like
"""

# ╔═╡ 901b7cec-94c1-4b93-80bf-54fa50d0b398
md"""
```julia
f(x, y::Int) = 1
f(x::Int, y) = 2
```
"""

# ╔═╡ 78b6259b-ff8f-425c-853f-0693bbe4dc4e
md"""
by defining a method
"""

# ╔═╡ b5ebad91-00af-46e4-b0d8-3671cc7663eb
md"""
```julia
f(x::Int, y::Int) = 3
```
"""

# ╔═╡ b75abe46-a2ec-4aa6-9793-56fc5042fc9a
md"""
This is often the right strategy; however, there are circumstances where following this advice mindlessly can be counterproductive. In particular, the more methods a generic function has, the more possibilities there are for ambiguities. When your method hierarchies get more complicated than this simple example, it can be worth your while to think carefully about alternative strategies.
"""

# ╔═╡ a6e29687-66fb-4adb-ba20-37ba35cdfc2d
md"""
Below we discuss particular challenges and some alternative ways to resolve such issues.
"""

# ╔═╡ 388f4b36-921b-40d2-a667-aacf927b15f9
md"""
### Tuple and NTuple arguments
"""

# ╔═╡ 6e537b7d-a9cc-4805-bb8b-6e876cab6039
md"""
`Tuple` (and `NTuple`) arguments present special challenges. For example,
"""

# ╔═╡ 5135558b-e10a-4c98-ab6c-a1b6b4d47657
md"""
```julia
f(x::NTuple{N,Int}) where {N} = 1
f(x::NTuple{N,Float64}) where {N} = 2
```
"""

# ╔═╡ 1fbc3ee6-7eac-4101-8844-c1f4bbb4ad61
md"""
are ambiguous because of the possibility that `N == 0`: there are no elements to determine whether the `Int` or `Float64` variant should be called. To resolve the ambiguity, one approach is define a method for the empty tuple:
"""

# ╔═╡ 15f101ab-cecd-4afb-8fcb-ef1140edcb8e
md"""
```julia
f(x::Tuple{}) = 3
```
"""

# ╔═╡ 42dfbe6a-5260-47d1-889d-fd7b9ea9213b
md"""
Alternatively, for all methods but one you can insist that there is at least one element in the tuple:
"""

# ╔═╡ 2112c15d-1b2c-464b-9864-e6ec054b0ebb
md"""
```julia
f(x::NTuple{N,Int}) where {N} = 1           # this is the fallback
f(x::Tuple{Float64, Vararg{Float64}}) = 2   # this requires at least one Float64
```
"""

# ╔═╡ 2a3dbe8f-169e-4c93-a037-dfd4355f55bd
md"""
### [Orthogonalize your design](@id man-methods-orthogonalize)
"""

# ╔═╡ ecc064ae-a909-43d1-90bc-ebec0af10232
md"""
When you might be tempted to dispatch on two or more arguments, consider whether a \"wrapper\" function might make for a simpler design. For example, instead of writing multiple variants:
"""

# ╔═╡ 970ab1ea-0a5f-4f61-9e14-d09692ce1731
md"""
```julia
f(x::A, y::A) = ...
f(x::A, y::B) = ...
f(x::B, y::A) = ...
f(x::B, y::B) = ...
```
"""

# ╔═╡ 6b24c522-6fb1-489b-83a2-3223aaf3b310
md"""
you might consider defining
"""

# ╔═╡ d6d414a7-a4ee-4368-a2d4-19760e60eb1b
md"""
```julia
f(x::A, y::A) = ...
f(x, y) = f(g(x), g(y))
```
"""

# ╔═╡ 3db6f6bf-efb8-4329-ba02-d74f280cf253
md"""
where `g` converts the argument to type `A`. This is a very specific example of the more general principle of [orthogonal design](https://en.wikipedia.org/wiki/Orthogonality_(programming)), in which separate concepts are assigned to separate methods. Here, `g` will most likely need a fallback definition
"""

# ╔═╡ 9303bab2-f9fe-425f-b5d8-c1e125a9dc99
md"""
```julia
g(x::A) = x
```
"""

# ╔═╡ c6f2ab55-a13b-4046-bba5-e7db76c9b404
md"""
A related strategy exploits `promote` to bring `x` and `y` to a common type:
"""

# ╔═╡ 832cac8a-baec-4424-917d-661b2fbb4e02
md"""
```julia
f(x::T, y::T) where {T} = ...
f(x, y) = f(promote(x, y)...)
```
"""

# ╔═╡ 9aaf5680-331a-4e31-91f5-d07fe41dbb3b
md"""
One risk with this design is the possibility that if there is no suitable promotion method converting `x` and `y` to the same type, the second method will recurse on itself infinitely and trigger a stack overflow.
"""

# ╔═╡ f69f9a40-2217-4e29-8fd1-4d0c66ad3674
md"""
### Dispatch on one argument at a time
"""

# ╔═╡ 55d8acc2-88d3-47eb-a943-b442cfea884e
md"""
If you need to dispatch on multiple arguments, and there are many fallbacks with too many combinations to make it practical to define all possible variants, then consider introducing a \"name cascade\" where (for example) you dispatch on the first argument and then call an internal method:
"""

# ╔═╡ 3e1bc818-304c-40d0-8a74-9f8c2eeb76d3
md"""
```julia
f(x::A, y) = _fA(x, y)
f(x::B, y) = _fB(x, y)
```
"""

# ╔═╡ 414a3097-f4e4-4090-b49c-70b3af5c1eb8
md"""
Then the internal methods `_fA` and `_fB` can dispatch on `y` without concern about ambiguities with each other with respect to `x`.
"""

# ╔═╡ 148d7e97-2660-4d26-9ab1-ec0685aeba71
md"""
Be aware that this strategy has at least one major disadvantage: in many cases, it is not possible for users to further customize the behavior of `f` by defining further specializations of your exported function `f`. Instead, they have to define specializations for your internal methods `_fA` and `_fB`, and this blurs the lines between exported and internal methods.
"""

# ╔═╡ 1eefde6c-4d57-4e42-b6dd-8d46a5153b63
md"""
### Abstract containers and element types
"""

# ╔═╡ a526e106-6cb8-4b2c-b93d-3a46fabeedff
md"""
Where possible, try to avoid defining methods that dispatch on specific element types of abstract containers. For example,
"""

# ╔═╡ 7fac1e98-05b9-4a5f-8391-66684062c945
md"""
```julia
-(A::AbstractArray{T}, b::Date) where {T<:Date}
```
"""

# ╔═╡ a9d5753f-aa95-4f65-931e-1940befd2a4f
md"""
generates ambiguities for anyone who defines a method
"""

# ╔═╡ 1a2978a8-33c6-4b2d-900e-af5c0e22d9ea
md"""
```julia
-(A::MyArrayType{T}, b::T) where {T}
```
"""

# ╔═╡ 1cef5f73-15a9-40d9-9155-e833fc70fa3f
md"""
The best approach is to avoid defining *either* of these methods: instead, rely on a generic method `-(A::AbstractArray, b)` and make sure this method is implemented with generic calls (like `similar` and `-`) that do the right thing for each container type and element type *separately*. This is just a more complex variant of the advice to [orthogonalize](@ref man-methods-orthogonalize) your methods.
"""

# ╔═╡ 02d1ec53-a297-4a9a-b282-f79280326824
md"""
When this approach is not possible, it may be worth starting a discussion with other developers about resolving the ambiguity; just because one method was defined first does not necessarily mean that it can't be modified or eliminated.  As a last resort, one developer can define the \"band-aid\" method
"""

# ╔═╡ 32148554-6644-49d7-97df-728aef8eb07a
md"""
```julia
-(A::MyArrayType{T}, b::Date) where {T<:Date} = ...
```
"""

# ╔═╡ 6462899a-19c7-4d27-8356-631593c818e8
md"""
that resolves the ambiguity by brute force.
"""

# ╔═╡ 6b5e4678-6e2c-4f15-a87c-d4107bbfa30a
md"""
### Complex method \"cascades\" with default arguments
"""

# ╔═╡ 3f9c621c-8031-46cd-a3c3-5b0a86ced71d
md"""
If you are defining a method \"cascade\" that supplies defaults, be careful about dropping any arguments that correspond to potential defaults. For example, suppose you're writing a digital filtering algorithm and you have a method that handles the edges of the signal by applying padding:
"""

# ╔═╡ 2a478e5d-5181-437c-855d-6d80b9d8d433
md"""
```julia
function myfilter(A, kernel, ::Replicate)
    Apadded = replicate_edges(A, size(kernel))
    myfilter(Apadded, kernel)  # now perform the \"real\" computation
end
```
"""

# ╔═╡ 459b037c-ff95-4a71-8d1b-8dbc21fc6020
md"""
This will run afoul of a method that supplies default padding:
"""

# ╔═╡ d1553160-e27f-4d0e-b87e-f5b165e83aa7
md"""
```julia
myfilter(A, kernel) = myfilter(A, kernel, Replicate()) # replicate the edge by default
```
"""

# ╔═╡ 4514595f-62e5-4d82-b497-e097bbfc6b9a
md"""
Together, these two methods generate an infinite recursion with `A` constantly growing bigger.
"""

# ╔═╡ 61f38b1a-ac49-4f85-bcc7-d1ce80e8b769
md"""
The better design would be to define your call hierarchy like this:
"""

# ╔═╡ adaada9b-ccf3-4914-bd12-2e573801b831
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
    # Here's the \"real\" implementation of the core computation
end
```
"""

# ╔═╡ 0b42b7d3-1691-4338-b302-ea31964c1372
md"""
`NoPad` is supplied in the same argument position as any other kind of padding, so it keeps the dispatch hierarchy well organized and with reduced likelihood of ambiguities. Moreover, it extends the \"public\" `myfilter` interface: a user who wants to control the padding explicitly can call the `NoPad` variant directly.
"""

# ╔═╡ f752f87c-2ab2-491a-89dd-1a16fab541b1
md"""
[^Clarke61]: Arthur C. Clarke, *Profiles of the Future* (1961): Clarke's Third Law.
"""

# ╔═╡ Cell order:
# ╟─cd74a764-9d84-42e8-a59b-5e4e479562b7
# ╟─b54f037f-34ec-44c1-bda9-d4297794d723
# ╟─aae21b35-9f91-433a-a232-4b49046db0cd
# ╟─6eb86f13-4127-48f2-a59a-1bb71dd16b7a
# ╟─c1c3d4d8-ead9-46cf-b35d-1958e0d9bb1c
# ╟─3fee0837-9348-4637-8a08-12cd74ee8c70
# ╟─feec78dc-2f33-4b87-afe4-b1c27aa6d6e3
# ╟─73c48fd9-334c-492e-8abb-f324c5f625e9
# ╟─61e804e2-704a-487e-9a0b-aa44267260c1
# ╠═aaa1ab25-4763-4ae1-9d76-0d1f69f76f27
# ╟─f3e38e95-87f1-4e6c-bda7-3a7fdbb748bd
# ╠═17036359-15bc-4862-b7c3-ed81b58fbf93
# ╟─3d4dcfa1-82a6-4f4a-b956-3e1df5691ff1
# ╠═1cd102cc-11d6-4df9-b1b8-80d7797a7aa7
# ╠═9ddc7d4b-2ca5-46f0-af15-e117eb77b41b
# ╠═93e63edc-a9bc-4d8c-b42a-6236d5d71a71
# ╠═81fe5077-bc70-4281-8f24-8d1766718904
# ╟─c91714cc-f64b-4fcd-8646-39005d82b92d
# ╠═9423e342-ad6f-4a9a-9382-ed931d3b005f
# ╠═485bdf91-71f4-49af-abab-ab09467607e6
# ╟─2b8ad3c9-6ada-47c3-a616-a08c10fb4e75
# ╟─4eaaae6f-c921-4121-8c9e-e51c6f6af1bd
# ╠═67084698-38d8-41c7-afee-ccf0e07304a9
# ╠═018334aa-4fa4-401c-b98f-35506ee32b91
# ╠═1f26632a-24e7-4845-910b-999b9f238b15
# ╠═ad1cfada-7c21-41ea-b611-de33e73db6d9
# ╟─c1f848ce-6f5d-4a85-887b-83817cc58a09
# ╟─bc1a949f-da6c-4c8a-a081-fe1275260a19
# ╠═19c50861-50f6-43d3-9888-fcaca0713a5b
# ╠═a82062e9-e75f-4281-8195-2e6ece17aadc
# ╟─b91ce8ee-5bd4-4a57-88ba-f3b24b33536e
# ╠═df90b1c0-7cc6-4a91-824e-0ba8baf1a542
# ╟─5cc84e1a-3592-48cd-921d-6067884e5e94
# ╠═2708942a-c534-4661-831e-bd0e22630107
# ╟─bfcf6ea8-89ca-4fca-8c17-ced78aa14d2f
# ╟─1c0977d9-2be1-4f13-9b83-9f838a9518ac
# ╠═43b24989-8ab4-45ad-9a00-11a70fb41393
# ╠═8ddff8a2-532f-4430-9d72-1aa7c8382104
# ╠═38de3427-0f57-49ba-8365-1766524bdef2
# ╟─c0a222f8-eeda-4012-9704-25a9464b32e9
# ╟─ee199f18-50a6-4153-a917-b1b5ae3830a1
# ╟─c0a4ea8e-2776-4332-9f69-f5dc8f9ffbad
# ╠═6212fe7b-ee4a-4f7e-8cd6-0d472a5f2a4b
# ╟─510b1427-0db1-4e83-b52a-a5e2ad0355b1
# ╟─16d990b7-f00a-4a81-a9b5-81ec7d9a5c9d
# ╟─88f9506c-96f2-48a5-8266-a109ec835b43
# ╠═83dea7fd-040d-4db3-9df7-1a306eb7b9e1
# ╠═8a5f0146-a29d-4a72-afc9-7ffa2277601e
# ╠═c7a20fb8-92d2-4719-9890-a80f620490e1
# ╠═fdf2d170-94e4-4478-8cb5-ca464dcd95d6
# ╠═a99c4d78-f8eb-4b6d-ae89-f60f9565fcde
# ╟─384db450-b475-4aa7-8063-801735f075d5
# ╠═e5c6884d-a651-4c44-b758-d6298b52031a
# ╠═6cb51af5-2546-4179-86c0-4031c267eba7
# ╠═be9d3ec3-128d-425a-8863-bdb85b1e951b
# ╠═19cb690c-e980-4ecf-a960-e33d874c4250
# ╟─04d610aa-204d-4e36-8434-6cb1ffa9ce6c
# ╟─76b774eb-5c08-4de9-840a-8b465057c6a6
# ╟─1fa8e9d1-144c-4d84-a5d1-315f631437ec
# ╟─ca8e6ffa-5426-4186-98e3-84bde7166cdd
# ╠═9905248e-4838-456a-8797-d73d910ba46a
# ╠═2603be54-70cd-40d1-8e38-74972f9f873b
# ╟─d4620c1d-fc76-476b-9c14-f7e80f5553a4
# ╠═d572090d-41a8-4463-9c97-9b5d6537403d
# ╠═e368336b-60f7-47a6-a3ad-0ba6d4b04d62
# ╠═c66e6d1e-5fd7-47c1-bc78-a167edf9b89d
# ╠═2d169ac2-1006-426d-8e79-f0d0ba597056
# ╠═3c1d0bf4-5dbb-4b77-ab1b-32c557127fb2
# ╠═b55ba6f5-5ca8-4267-885c-760c013d0a25
# ╟─aef57bc5-efce-4fba-9dce-ce4866d2c844
# ╟─16042a7a-97a7-4aa5-bef5-433861d2fdea
# ╠═c307ccb4-dec2-4266-aca1-e15fd7f9ccdb
# ╠═fb07d97c-99b3-415a-a708-daeb02aed48d
# ╠═fa02cb4a-4a24-40dc-81ed-b1bafbbf0517
# ╠═f3900f6a-28e4-4ace-a6b6-50d6f571bdcf
# ╠═6ac24ad2-df9b-46f6-97a6-b63659bce8b7
# ╟─ca706449-cc98-4fe4-8f2d-afacc25100ca
# ╠═e5b3c428-bfed-4c59-9781-8a9eeec0a89f
# ╠═f7af6eb9-0f61-4b6c-a6c4-9f063d73af41
# ╠═bb33c930-3dba-4dde-b6a2-c12b4faac2d5
# ╟─a2bb042d-5bf3-4ee5-ac1d-0e8fd89ecdd3
# ╠═f718c8e4-f8a2-4168-96e3-c2b7c7c51416
# ╠═939dc816-a07b-4ec5-9666-b156dd1995ff
# ╠═bc391a52-ba4c-4ee2-bf52-3999bc36f42a
# ╠═73b161eb-6c38-4c2d-a6e3-6adff1343950
# ╠═ec202dd8-ae68-47cc-8228-7a310a04354e
# ╠═f4238a16-696f-40e9-b3ca-ae596b9c1a54
# ╠═f467fab4-94aa-4f67-b74f-4d43ae8756b3
# ╠═e7613477-7356-439b-88b8-e06a24f21904
# ╟─0ca251a6-bae2-4f35-9d1c-c1b1f3677bea
# ╟─fc5297a9-ba22-42f3-9422-239607b9296a
# ╟─c60574ff-1b61-4109-adf0-4c5421ad0e2c
# ╟─bed7e397-05bf-4f97-8057-f84ad701ada6
# ╠═d791bc43-59d5-42ae-8676-c0738da11f47
# ╠═b69e628d-3862-49ee-9c2a-fece6a017b3e
# ╠═0bd59c10-32b1-459a-befc-363cde529c71
# ╟─528d2dcc-bd07-4195-ab15-7da6ea150bbd
# ╟─d007da36-58f9-404a-85e9-78f94339bea9
# ╟─4c5dedb6-e87b-411b-9c4f-35b430cbaa08
# ╟─99d282f8-a8d9-4cb4-862c-986859c0c195
# ╟─cae8a505-6aab-41ff-a372-80c88c9cacc5
# ╟─cf325372-5b60-40c0-b1e2-9f9687b53722
# ╠═a0503cc0-6ee0-4b8a-abaf-4da6d68506e2
# ╠═f86aafe0-7b9a-40e4-baa9-a71a7efc1535
# ╟─489601a7-0d70-4981-b289-628612743fcb
# ╠═f3395e77-20ee-4209-be85-7dc160afa1b4
# ╟─3a6ecf30-6d70-4d85-a8d0-a53129d9f697
# ╠═3124e5ea-b19f-4d8d-a6c6-b6a12b96d3fc
# ╠═ac5939e9-d6c4-47fc-8744-e89acb404968
# ╟─40324f98-aaea-4c4d-b53e-53cea3eec3f0
# ╠═cf190f6c-9779-4537-9cff-3959c6dc9c6d
# ╠═0795614a-09dd-44f2-a77d-c5fdf24c0385
# ╟─4b5c0b0b-43c2-4d8c-8c3b-6152b528a0a7
# ╠═d9bb0180-7fb1-48fc-9ffb-32cd91b4abb2
# ╠═d38e5cf4-3a06-4d65-80ef-ea2779ed4dbd
# ╠═afd3d2f0-9e9b-46fe-a3c6-6989118da949
# ╠═8bc9ac4b-e447-4caf-932b-ccde57be7096
# ╠═fc7fb6b7-d39c-4e0a-ba6e-2dd875074641
# ╟─b9200d4e-846a-4ed6-850a-f5b246850aa5
# ╟─e376f025-2272-4f65-b15b-0936be4754d9
# ╟─7fcd3eb8-26a5-4dbb-a539-fddc95d26a66
# ╟─093c2b1e-579e-4f38-b0ca-700d9e2639bf
# ╟─4e3cef5e-9c77-4649-843a-7489998293ed
# ╟─80562130-623b-46b3-96e5-71d571421dea
# ╟─816d0c00-12fa-4171-a0b1-514b7e230100
# ╟─1e495b92-ecb8-4290-bd34-cf7d5115dea3
# ╟─a74b22b2-3688-432b-878a-8a6573c1bfd9
# ╟─7557f437-88a1-4777-bcfc-80e71cb72e5c
# ╟─2c9a4f83-08cf-4403-b604-0f997bd97461
# ╟─ecd5500b-7723-4d2f-b6a4-b36d0f995ebe
# ╟─694bb614-ee85-41d7-bb5b-ac55272de0a7
# ╟─49d4e9e6-edb0-4eaa-a361-56b84590e807
# ╟─577c1bbb-7391-4934-9675-c280f64554fb
# ╟─d70a7c2e-61f0-4486-8c9e-a49ef2c62bd1
# ╟─b27fc9c0-56b4-4da0-8d1c-29ef6ba9c924
# ╟─f3928a3b-9d24-44a6-8bf7-54be6a6f5905
# ╟─230287de-1791-4475-adc3-028f6c91ce72
# ╟─695ef186-42ce-4d97-861b-65a91cecb8a9
# ╟─1f80fe20-0503-4b2a-9310-0b51b9b9329a
# ╟─dc90ea5e-4e30-4094-b009-b183295ef29c
# ╟─e635e8f8-d11b-43b9-a72c-d979a1dc7717
# ╟─f66812ce-538c-40ae-ae98-23f6b1005211
# ╟─abcc232c-fd7e-456b-af69-a1db010b5ee0
# ╟─d6c46e1e-acec-4855-8310-5463382c2e2f
# ╟─99357eaa-9cf4-459e-863e-0a6a9b65d55d
# ╟─c3122d7b-045a-4011-9a92-74058efc8dd7
# ╟─10fe95af-d928-47d0-8260-f17d18068dc2
# ╟─eafc4965-269e-4ea0-a69b-25f323f13bb4
# ╟─c0fce545-afc9-453f-ac43-ab2793450c78
# ╟─5b5f385d-4fe1-4779-b4bd-1e65cb5fe87a
# ╟─e84f5f5a-e41d-44a4-8832-84f156201367
# ╟─3925b5a8-44a7-4e51-b11d-27156ef43ea5
# ╟─887b7a0d-86f4-4613-92c3-ec7a79553db5
# ╟─f5ff7d49-2187-489e-8f63-de22d7a65f1e
# ╟─1ca312b2-7bfd-4ec1-aa31-777d501c3f10
# ╟─6b7f2455-c7c1-48a1-b43d-7d02df49bdc3
# ╟─5c776e65-724d-467e-95f2-723f97f16089
# ╟─c36fad35-8771-4196-8138-d96a2e249c3d
# ╟─5bb28872-c9c9-4985-b88a-4ce810c06666
# ╟─36cd14f1-4a07-4e6d-bf2f-6149a64a6c8f
# ╟─7a6f2ddd-149e-4e49-80fb-8fd1563a0aa8
# ╟─3cbdcaf1-d55f-4fab-8ad0-dbefcbbcc699
# ╠═e3339737-f1f0-471d-8ae3-538acfffedc0
# ╠═68fbd25c-0e14-4da2-a63c-c2861b46d598
# ╠═696fae9c-26bf-47b8-9b8b-82be94ae6a7b
# ╠═0c61770a-1d3d-454a-86a3-e89c35074143
# ╟─fe0f5063-1449-4d17-a888-e349c0285580
# ╟─0a75d087-f3a6-4b71-a0d4-5472611e234c
# ╟─94929435-74be-467c-992f-f86e944dcb05
# ╟─4467a049-ee21-4146-be9b-30d1601841b3
# ╟─b7ede21b-69d3-4f0c-8406-f3ce6583a600
# ╟─9c2eebbf-e0e7-4c05-a56f-a052ff1a95ea
# ╟─c2c13839-c290-4fd8-945c-d8d92422ee15
# ╟─f81529b7-5ca6-47ae-a74b-b24e517eb9cb
# ╟─c4614175-13e2-405d-92fb-cca91dcdcca4
# ╟─94555fdb-bf2b-436d-9287-3eb292b8b78d
# ╟─8374dfab-5ea8-40a5-ae9e-66b601fa416e
# ╟─54309f82-1923-412b-899b-3a68907290b9
# ╟─571c28ea-6598-47c2-a508-4e194f4e6eb6
# ╟─1a5a730b-11c0-4b54-ac6c-75258e3238bd
# ╟─9c6e101a-6079-400e-b55e-32ac71238bc3
# ╟─402c3af8-88ce-4b69-92ef-280d858d7564
# ╠═3d9ada08-4347-4811-913a-5a3c218cea2e
# ╠═c4776c21-b4e2-4511-9ad5-bbecfde3d3ce
# ╠═b7cc7787-a8ef-4948-b3c2-990e78f8532f
# ╟─61bda853-2190-4be2-81b2-a5389966bf59
# ╠═5b08039c-8bb1-4cb1-9b21-d40784f2cd11
# ╠═c9f5cbb6-02f5-4c3e-9f86-09ae3bc35c38
# ╠═e7e17a4f-d483-4d6b-b49d-913af16dc341
# ╟─fc3cc3aa-a1a3-4543-9055-f40eae182008
# ╟─28a23df5-9fc0-4954-ab8a-c1418fe62052
# ╟─b21aa2cf-76fa-4e06-bfa8-4e26cce0b1dd
# ╟─47aa1a2e-7ff0-4cb9-ae7d-70a00273833b
# ╟─d4d532bc-befa-4f61-8a83-b928b317cfb7
# ╟─ccee4a8f-2926-4a63-8cb7-968e348310d7
# ╟─69ab16bb-369c-4bde-a180-c25103187c4b
# ╟─901b7cec-94c1-4b93-80bf-54fa50d0b398
# ╟─78b6259b-ff8f-425c-853f-0693bbe4dc4e
# ╟─b5ebad91-00af-46e4-b0d8-3671cc7663eb
# ╟─b75abe46-a2ec-4aa6-9793-56fc5042fc9a
# ╟─a6e29687-66fb-4adb-ba20-37ba35cdfc2d
# ╟─388f4b36-921b-40d2-a667-aacf927b15f9
# ╟─6e537b7d-a9cc-4805-bb8b-6e876cab6039
# ╟─5135558b-e10a-4c98-ab6c-a1b6b4d47657
# ╟─1fbc3ee6-7eac-4101-8844-c1f4bbb4ad61
# ╟─15f101ab-cecd-4afb-8fcb-ef1140edcb8e
# ╟─42dfbe6a-5260-47d1-889d-fd7b9ea9213b
# ╟─2112c15d-1b2c-464b-9864-e6ec054b0ebb
# ╟─2a3dbe8f-169e-4c93-a037-dfd4355f55bd
# ╟─ecc064ae-a909-43d1-90bc-ebec0af10232
# ╟─970ab1ea-0a5f-4f61-9e14-d09692ce1731
# ╟─6b24c522-6fb1-489b-83a2-3223aaf3b310
# ╟─d6d414a7-a4ee-4368-a2d4-19760e60eb1b
# ╟─3db6f6bf-efb8-4329-ba02-d74f280cf253
# ╟─9303bab2-f9fe-425f-b5d8-c1e125a9dc99
# ╟─c6f2ab55-a13b-4046-bba5-e7db76c9b404
# ╟─832cac8a-baec-4424-917d-661b2fbb4e02
# ╟─9aaf5680-331a-4e31-91f5-d07fe41dbb3b
# ╟─f69f9a40-2217-4e29-8fd1-4d0c66ad3674
# ╟─55d8acc2-88d3-47eb-a943-b442cfea884e
# ╟─3e1bc818-304c-40d0-8a74-9f8c2eeb76d3
# ╟─414a3097-f4e4-4090-b49c-70b3af5c1eb8
# ╟─148d7e97-2660-4d26-9ab1-ec0685aeba71
# ╟─1eefde6c-4d57-4e42-b6dd-8d46a5153b63
# ╟─a526e106-6cb8-4b2c-b93d-3a46fabeedff
# ╟─7fac1e98-05b9-4a5f-8391-66684062c945
# ╟─a9d5753f-aa95-4f65-931e-1940befd2a4f
# ╟─1a2978a8-33c6-4b2d-900e-af5c0e22d9ea
# ╟─1cef5f73-15a9-40d9-9155-e833fc70fa3f
# ╟─02d1ec53-a297-4a9a-b282-f79280326824
# ╟─32148554-6644-49d7-97df-728aef8eb07a
# ╟─6462899a-19c7-4d27-8356-631593c818e8
# ╟─6b5e4678-6e2c-4f15-a87c-d4107bbfa30a
# ╟─3f9c621c-8031-46cd-a3c3-5b0a86ced71d
# ╟─2a478e5d-5181-437c-855d-6d80b9d8d433
# ╟─459b037c-ff95-4a71-8d1b-8dbc21fc6020
# ╟─d1553160-e27f-4d0e-b87e-f5b165e83aa7
# ╟─4514595f-62e5-4d82-b497-e097bbfc6b9a
# ╟─61f38b1a-ac49-4f85-bcc7-d1ce80e8b769
# ╟─adaada9b-ccf3-4914-bd12-2e573801b831
# ╟─0b42b7d3-1691-4338-b302-ea31964c1372
# ╟─f752f87c-2ab2-491a-89dd-1a16fab541b1
