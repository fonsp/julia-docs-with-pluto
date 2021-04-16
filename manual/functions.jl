### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ 976eb3b0-53f7-45f0-ac6d-0127203d5044
md"""
# [Functions](@id man-functions)
"""

# ╔═╡ 660f9ee8-d6a1-470e-9a39-dcde1ac4e8a0
md"""
In Julia, a function is an object that maps a tuple of argument values to a return value. Julia functions are not pure mathematical functions, because they can alter and be affected by the global state of the program. The basic syntax for defining functions in Julia is:
"""

# ╔═╡ 9de72f85-a416-41be-9399-88dbad501d1a
function f(x,y)
     x + y
 end

# ╔═╡ 894b6b1c-cdc0-4343-9c2e-6db83ba58f22
md"""
This function accepts two arguments `x` and `y` and returns the value of the last expression evaluated, which is `x + y`.
"""

# ╔═╡ bf1ca0bc-8e23-4145-b57f-81207720c0e0
md"""
There is a second, more terse syntax for defining a function in Julia. The traditional function declaration syntax demonstrated above is equivalent to the following compact \"assignment form\":
"""

# ╔═╡ d84640f5-fb92-49fe-a292-d212ec18f505
f(x,y) = x + y

# ╔═╡ 9c052770-7518-4b8e-969d-b8e71e43e217
md"""
In the assignment form, the body of the function must be a single expression, although it can be a compound expression (see [Compound Expressions](@ref man-compound-expressions)). Short, simple function definitions are common in Julia. The short function syntax is accordingly quite idiomatic, considerably reducing both typing and visual noise.
"""

# ╔═╡ d299e181-e3f0-439f-ba11-5bfc7209d17d
md"""
A function is called using the traditional parenthesis syntax:
"""

# ╔═╡ abf077a2-d2c4-4f92-aed7-1a2367826d8d
f(2,3)

# ╔═╡ bd8d65f1-7627-4fb0-8381-7cba39757d26
md"""
Without parentheses, the expression `f` refers to the function object, and can be passed around like any other value:
"""

# ╔═╡ f938bed1-eac4-4370-a4e5-f361563ae6c3
g = f;

# ╔═╡ 1631a923-a399-4527-868a-375bff49e775
g(2,3)

# ╔═╡ 0f02aeef-f5cc-4d98-9350-6b9d1ae6fb44
md"""
As with variables, Unicode can also be used for function names:
"""

# ╔═╡ b2e413c1-3292-4091-ac3a-d00a57707bfd
∑(x,y) = x + y

# ╔═╡ b52a5edd-10f6-4e4d-a195-38ab44719279
∑(2, 3)

# ╔═╡ b428491f-76bd-4222-8ec4-5c5364780dc5
md"""
## Argument Passing Behavior
"""

# ╔═╡ beaee484-e849-44ad-9393-1d6dcf0e57bd
md"""
Julia function arguments follow a convention sometimes called \"pass-by-sharing\", which means that values are not copied when they are passed to functions. Function arguments themselves act as new variable *bindings* (new locations that can refer to values), but the values they refer to are identical to the passed values. Modifications to mutable values (such as `Array`s) made within a function will be visible to the caller. This is the same behavior found in Scheme, most Lisps, Python, Ruby and Perl, among other dynamic languages.
"""

# ╔═╡ 753d805b-1f43-48ae-8ee0-89649152b6e3
md"""
## The `return` Keyword
"""

# ╔═╡ 478c9c2a-13dd-4de1-8c7d-487d94b6a1d7
md"""
The value returned by a function is the value of the last expression evaluated, which, by default, is the last expression in the body of the function definition. In the example function, `f`, from the previous section this is the value of the expression `x + y`. As an alternative, as in many other languages, the `return` keyword causes a function to return immediately, providing an expression whose value is returned:
"""

# ╔═╡ 13cad595-98fc-43b6-828f-751bbc461d8d
md"""
```julia
function g(x,y)
    return x * y
    x + y
end
```
"""

# ╔═╡ 42629963-0df8-4d5c-b0f7-973fbaf310a9
md"""
Since function definitions can be entered into interactive sessions, it is easy to compare these definitions:
"""

# ╔═╡ 00565eb8-b882-40b8-b5d9-9af2e92c7682
f(x,y) = x + y

# ╔═╡ 0125887e-0c13-4550-8ba5-a599944b9b57
function g(x,y)
     return x * y
     x + y
 end

# ╔═╡ 599b19a4-51c7-480d-ba6e-e2e68416de2e
f(2,3)

# ╔═╡ fbacf27b-8f6c-41c1-a9e0-2d573746357a
g(2,3)

# ╔═╡ 98016434-2454-4ac5-b64a-340fec6c3ce8
md"""
Of course, in a purely linear function body like `g`, the usage of `return` is pointless since the expression `x + y` is never evaluated and we could simply make `x * y` the last expression in the function and omit the `return`. In conjunction with other control flow, however, `return` is of real use. Here, for example, is a function that computes the hypotenuse length of a right triangle with sides of length `x` and `y`, avoiding overflow:
"""

# ╔═╡ bbd9ea31-92df-40ac-8aa9-c5a37e6c2985
function hypot(x,y)
     x = abs(x)
     y = abs(y)
     if x > y
         r = y/x
         return x*sqrt(1+r*r)
     end
     if y == 0
         return zero(x)
     end
     r = x/y
     return y*sqrt(1+r*r)
 end

# ╔═╡ f7b15930-6a71-42d3-bfc1-5f4e1f0b6b00
hypot(3, 4)

# ╔═╡ 5ec6f4df-aed4-4a8c-9195-0d414b6c6b06
md"""
There are three possible points of return from this function, returning the values of three different expressions, depending on the values of `x` and `y`. The `return` on the last line could be omitted since it is the last expression.
"""

# ╔═╡ 6b723b70-1785-4eb9-b44c-3dfde47f72b2
md"""
### Return type
"""

# ╔═╡ 6fc47afc-b371-42db-ab5a-7c1b04186bf1
md"""
A return type can be specified in the function declaration using the `::` operator. This converts the return value to the specified type.
"""

# ╔═╡ 6f2a8268-3fc7-454d-9c9f-ffe73a88f342
function g(x, y)::Int8
     return x * y
 end;

# ╔═╡ 66a92ea9-032f-4fb5-863d-8cc2ed5aed71
typeof(g(1, 2))

# ╔═╡ 7547acb4-398c-4a45-8e6f-6953d1c728da
md"""
This function will always return an `Int8` regardless of the types of `x` and `y`. See [Type Declarations](@ref) for more on return types.
"""

# ╔═╡ 4a8adf95-9b28-4ece-9d52-b4781fb2d854
md"""
### Returning nothing
"""

# ╔═╡ 6bb098f4-7607-47c7-b159-120e91d13ec1
md"""
For functions that do not need to return a value (functions used only for some side effects), the Julia convention is to return the value [`nothing`](@ref):
"""

# ╔═╡ 0c276b17-267d-4f7d-b376-4e02e3e5af9d
md"""
```julia
function printx(x)
    println(\"x = $x\")
    return nothing
end
```
"""

# ╔═╡ bce4e027-34c5-4c4c-a707-da64df74b1f6
md"""
This is a *convention* in the sense that `nothing` is not a Julia keyword but a only singleton object of type `Nothing`. Also, you may notice that the `printx` function example above is contrived, because `println` already returns `nothing`, so that the `return` line is redundant.
"""

# ╔═╡ 1231294a-bd7f-4d7b-8adb-acf93fd094ab
md"""
There are two possible shortened forms for the `return nothing` expression. On the one hand, the `return` keyword implicitly returns `nothing`, so it can be used alone. On the other hand, since functions implicitly return their last expression evaluated, `nothing` can be used alone when it's the last expression. The preference for the expression `return nothing` as opposed to `return` or `nothing` alone is a matter of coding style.
"""

# ╔═╡ 24d8572f-508b-40df-ad9d-f58ff734dc02
md"""
## Operators Are Functions
"""

# ╔═╡ 25a68ad0-69c9-4ce8-a7be-a222407ba402
md"""
In Julia, most operators are just functions with support for special syntax. (The exceptions are operators with special evaluation semantics like `&&` and `||`. These operators cannot be functions since [Short-Circuit Evaluation](@ref) requires that their operands are not evaluated before evaluation of the operator.) Accordingly, you can also apply them using parenthesized argument lists, just as you would any other function:
"""

# ╔═╡ d6365006-6dc2-42fa-934f-db2952ed5165
1 + 2 + 3

# ╔═╡ 23d6d89d-aae8-4e1b-b22d-2f0283a467a2
+(1,2,3)

# ╔═╡ d55c9ff0-146c-4e1a-a0ae-cce8b61408a8
md"""
The infix form is exactly equivalent to the function application form – in fact the former is parsed to produce the function call internally. This also means that you can assign and pass around operators such as [`+`](@ref) and [`*`](@ref) just like you would with other function values:
"""

# ╔═╡ 7816d420-d2a7-4a96-a270-aa31706a4891
f = +;

# ╔═╡ 0780c807-9d44-43c3-bbdd-bfc2533bf2f8
f(1,2,3)

# ╔═╡ 85c32258-cafe-4a3a-8cba-5ee807840c13
md"""
Under the name `f`, the function does not support infix notation, however.
"""

# ╔═╡ b761bc8c-e55f-4291-98a4-aab758e720b6
md"""
## Operators With Special Names
"""

# ╔═╡ d086375c-2004-4a64-8b78-fe8208e65b40
md"""
A few special expressions correspond to calls to functions with non-obvious names. These are:
"""

# ╔═╡ b643a2c1-62e7-42f8-8270-125ce2c12ccc
md"""
| Expression        | Calls                                    |
|:----------------- |:---------------------------------------- |
| `[A B C ...]`     | [`hcat`](@ref)                           |
| `[A; B; C; ...]`  | [`vcat`](@ref)                           |
| `[A B; C D; ...]` | [`hvcat`](@ref)                          |
| `A'`              | [`adjoint`](@ref)                        |
| `A[i]`            | [`getindex`](@ref)                       |
| `A[i] = x`        | [`setindex!`](@ref)                      |
| `A.n`             | [`getproperty`](@ref Base.getproperty)   |
| `A.n = x`         | [`setproperty!`](@ref Base.setproperty!) |
"""

# ╔═╡ 1e1d043e-400c-4686-9daf-d48fb21dbba9
md"""
## [Anonymous Functions](@id man-anonymous-functions)
"""

# ╔═╡ 7433df95-014b-43b1-b4ef-ae5add512e48
md"""
Functions in Julia are [first-class objects](https://en.wikipedia.org/wiki/First-class_citizen): they can be assigned to variables, and called using the standard function call syntax from the variable they have been assigned to. They can be used as arguments, and they can be returned as values. They can also be created anonymously, without being given a name, using either of these syntaxes:
"""

# ╔═╡ da3bca81-cfc8-47e8-86b3-0ba4ceee8ff5
x -> x^2 + 2x - 1

# ╔═╡ 9457721a-9ca7-4c06-a680-f49a543b8570
function (x)
     x^2 + 2x - 1
 end

# ╔═╡ 53277164-cb39-4d43-a2af-7d91c7b666d8
md"""
This creates a function taking one argument `x` and returning the value of the polynomial `x^2 + 2x - 1` at that value. Notice that the result is a generic function, but with a compiler-generated name based on consecutive numbering.
"""

# ╔═╡ c33f7b69-8c7c-4cbd-b82c-d14f7e119e14
md"""
The primary use for anonymous functions is passing them to functions which take other functions as arguments. A classic example is [`map`](@ref), which applies a function to each value of an array and returns a new array containing the resulting values:
"""

# ╔═╡ 05fe9eb1-888b-4677-a0c4-ec320b565556
map(round, [1.2, 3.5, 1.7])

# ╔═╡ 071c07d2-46e0-4753-ba66-cf0881713205
md"""
This is fine if a named function effecting the transform already exists to pass as the first argument to [`map`](@ref). Often, however, a ready-to-use, named function does not exist. In these situations, the anonymous function construct allows easy creation of a single-use function object without needing a name:
"""

# ╔═╡ aed0c00a-3186-49dd-aaf9-90ffd4a6b751
map(x -> x^2 + 2x - 1, [1, 3, -1])

# ╔═╡ 080e8e78-6a87-43ea-bd74-8a120d30ed2b
md"""
An anonymous function accepting multiple arguments can be written using the syntax `(x,y,z)->2x+y-z`. A zero-argument anonymous function is written as `()->3`. The idea of a function with no arguments may seem strange, but is useful for \"delaying\" a computation. In this usage, a block of code is wrapped in a zero-argument function, which is later invoked by calling it as `f`.
"""

# ╔═╡ 73a398f4-a269-4797-8d6a-011fc044e2f0
md"""
As an example, consider this call to [`get`](@ref):
"""

# ╔═╡ 4acd49b1-0b57-4248-84ac-2ae9b4a339e9
md"""
```julia
get(dict, key) do
    # default value calculated here
    time()
end
```
"""

# ╔═╡ c8385939-915c-47c6-89f5-d6088a939da5
md"""
The code above is equivalent to calling `get` with an anonymous function containing the code enclosed between `do` and `end`, like so:
"""

# ╔═╡ 988e8bc2-73a4-4dd0-aec4-6898ddd92faf
md"""
```julia
get(()->time(), dict, key)
```
"""

# ╔═╡ acda9fc9-d889-4057-a206-a88018270245
md"""
The call to [`time`](@ref) is delayed by wrapping it in a 0-argument anonymous function that is called only when the requested key is absent from `dict`.
"""

# ╔═╡ f11bc3ff-98e7-4da7-8423-ba8f6494d08e
md"""
## Tuples
"""

# ╔═╡ a95c5741-3e66-46a7-801c-eecb800e1c0a
md"""
Julia has a built-in data structure called a *tuple* that is closely related to function arguments and return values. A tuple is a fixed-length container that can hold any values, but cannot be modified (it is *immutable*). Tuples are constructed with commas and parentheses, and can be accessed via indexing:
"""

# ╔═╡ 71e190dc-a96e-4189-80a5-b03f6ad65af0
(1, 1+1)

# ╔═╡ 5e8ed4c4-946c-4e01-afaf-026b8e7f99bd
(1,)

# ╔═╡ 82ac4844-65b5-49fe-be5b-4ed392668bc6
x = (0.0, "hello", 6*7)

# ╔═╡ c571f923-972a-496b-ac58-d6777eb6d692
x[2]

# ╔═╡ 479dea31-1a4c-4fac-9f97-568c38f5a9f2
md"""
Notice that a length-1 tuple must be written with a comma, `(1,)`, since `(1)` would just be a parenthesized value. `()` represents the empty (length-0) tuple.
"""

# ╔═╡ d0a04a58-5e6c-4892-a718-4cb8149924c5
md"""
## Named Tuples
"""

# ╔═╡ 166e29e8-c1b0-44a6-b712-c86d57a79b9f
md"""
The components of tuples can optionally be named, in which case a *named tuple* is constructed:
"""

# ╔═╡ 2e31c2cd-fc92-4b37-b719-9f3ab69a7426
x = (a=2, b=1+2)

# ╔═╡ 534d2690-c512-4ae8-af2b-ef7f39526e00
x[1]

# ╔═╡ 85ca2f0b-90c1-40f5-b8e4-b84ff8997aaa
x.a

# ╔═╡ abf80534-f409-42a8-8037-8285b9687941
md"""
Named tuples are very similar to tuples, except that fields can additionally be accessed by name using dot syntax (`x.a`) in addition to the regular indexing syntax (`x[1]`).
"""

# ╔═╡ bbdaa7b0-2bb5-4111-af18-097f5778848f
md"""
## Multiple Return Values
"""

# ╔═╡ 905dda1e-ec33-4905-92c1-cf358a1ad3d0
md"""
In Julia, one returns a tuple of values to simulate returning multiple values. However, tuples can be created and destructured without needing parentheses, thereby providing an illusion that multiple values are being returned, rather than a single tuple value. For example, the following function returns a pair of values:
"""

# ╔═╡ 945c33fd-0009-44c9-86fb-eca553c4d745
function foo(a,b)
     a+b, a*b
 end

# ╔═╡ 63ed6951-64f2-4d83-8817-c9503a3e7a3c
md"""
If you call it in an interactive session without assigning the return value anywhere, you will see the tuple returned:
"""

# ╔═╡ 32c99526-7a83-4512-9be8-2febe976f693
foo(2,3)

# ╔═╡ b8329d2f-cad3-4c31-8f04-6c50a890bdf2
md"""
A typical usage of such a pair of return values, however, extracts each value into a variable. Julia supports simple tuple \"destructuring\" that facilitates this:
"""

# ╔═╡ 70ecc781-eb9d-4d83-aef7-7cd54f0edd66
x, y = foo(2,3)

# ╔═╡ 0b9b6e81-fae2-4c9e-8150-9ca6d053c661
x

# ╔═╡ 61f02494-9677-4c90-a08d-e083dc638423
y

# ╔═╡ 57630307-e964-4030-ba36-6dd4b8bbbc31
md"""
You can also return multiple values using the `return` keyword:
"""

# ╔═╡ 803dc48b-1950-4ec6-9766-3f4be2c42b80
md"""
```julia
function foo(a,b)
    return a+b, a*b
end
```
"""

# ╔═╡ 65460138-0a5c-4544-87ca-e5bd1763a256
md"""
This has the exact same effect as the previous definition of `foo`.
"""

# ╔═╡ ad34b9f5-c91c-4392-84a1-13f5e3e0832c
md"""
## Argument destructuring
"""

# ╔═╡ 81f82eb2-ad76-4fb3-a96f-6cabbcde4114
md"""
The destructuring feature can also be used within a function argument. If a function argument name is written as a tuple (e.g. `(x, y)`) instead of just a symbol, then an assignment `(x, y) = argument` will be inserted for you:
"""

# ╔═╡ fb069ded-1d5e-4227-89ea-dcf2771cef47
md"""
```julia
julia> minmax(x, y) = (y < x) ? (y, x) : (x, y)

julia> gap((min, max)) = max - min

julia> gap(minmax(10, 2))
8
```
"""

# ╔═╡ e0ab0e61-0568-46a2-a51e-140bdea34501
md"""
Notice the extra set of parentheses in the definition of `gap`. Without those, `gap` would be a two-argument function, and this example would not work.
"""

# ╔═╡ 657d13f2-e8cf-4601-8144-285e30782ef3
md"""
## Varargs Functions
"""

# ╔═╡ e0c00c30-4f16-4df1-aac4-78493a3150dd
md"""
It is often convenient to be able to write functions taking an arbitrary number of arguments. Such functions are traditionally known as \"varargs\" functions, which is short for \"variable number of arguments\". You can define a varargs function by following the last positional argument with an ellipsis:
"""

# ╔═╡ e87bf8e4-a410-4d3f-beaa-40d10727a35d
bar(a,b,x...) = (a,b,x)

# ╔═╡ baa68a4f-1388-446d-88b9-5e27cf4a641f
md"""
The variables `a` and `b` are bound to the first two argument values as usual, and the variable `x` is bound to an iterable collection of the zero or more values passed to `bar` after its first two arguments:
"""

# ╔═╡ 082deae3-b345-4c31-bfe4-5b4abeb67504
bar(1,2)

# ╔═╡ b2f93a63-6b1d-49eb-a225-a00df782426b
bar(1,2,3)

# ╔═╡ 0ae8342d-c554-496c-9195-6554323a84ff
bar(1, 2, 3, 4)

# ╔═╡ d5a1e230-a9df-4c20-b6b7-cc9efb6884c4
bar(1,2,3,4,5,6)

# ╔═╡ 66e3bd59-454e-4c45-ab4c-92cef7c59091
md"""
In all these cases, `x` is bound to a tuple of the trailing values passed to `bar`.
"""

# ╔═╡ 4efe089f-c394-490e-8405-599c5b03d7fc
md"""
It is possible to constrain the number of values passed as a variable argument; this will be discussed later in [Parametrically-constrained Varargs methods](@ref).
"""

# ╔═╡ 6ac8b069-8760-4eb3-b9ec-396ee6fb1314
md"""
On the flip side, it is often handy to \"splat\" the values contained in an iterable collection into a function call as individual arguments. To do this, one also uses `...` but in the function call instead:
"""

# ╔═╡ e23a17d6-59d0-4cc6-b685-8cad2243e252
x = (3, 4)

# ╔═╡ 38af5644-3031-4d41-b332-469eace81e39
bar(1,2,x...)

# ╔═╡ 8953e105-865b-4807-8aec-7147b0184a94
md"""
In this case a tuple of values is spliced into a varargs call precisely where the variable number of arguments go. This need not be the case, however:
"""

# ╔═╡ 2b0116fd-0929-4e7e-886b-4d58dadc59f6
x = (2, 3, 4)

# ╔═╡ 441ac4a1-8b70-4ab8-bbd4-8b1b3271759f
bar(1,x...)

# ╔═╡ d2464aa9-6804-421e-a81b-9899e4161dea
x = (1, 2, 3, 4)

# ╔═╡ 02646757-03a8-4ecd-a0c5-4740902f538a
bar(x...)

# ╔═╡ 5cba24e2-3de3-4440-b503-84cef2bb3e55
md"""
Furthermore, the iterable object splatted into a function call need not be a tuple:
"""

# ╔═╡ 5cc14b66-a053-4390-9192-ec5a81360022
x = [3,4]

# ╔═╡ 17f94373-afd9-4000-b023-4d30d6416d35
bar(1,2,x...)

# ╔═╡ 6a1c28a3-ae71-4f35-92e3-812e928aa398
x = [1,2,3,4]

# ╔═╡ 825d709c-8a79-448c-ba02-71f04c29e7b8
bar(x...)

# ╔═╡ 69bd2061-1ad4-4962-a647-f9866f5da0a3
md"""
Also, the function that arguments are splatted into need not be a varargs function (although it often is):
"""

# ╔═╡ 763e6e4a-84d7-42f6-96a0-ff7a9b734ce4
baz(a,b) = a + b;

# ╔═╡ b4d75385-2d75-4926-b215-dd339594f6c4
args = [1,2]

# ╔═╡ 1d8170c7-c623-4ebe-b934-cd44330c8622
baz(args...)

# ╔═╡ 06646361-77f0-43c4-95c2-163628a094d2
args = [1,2,3]

# ╔═╡ 1b6b5796-cfaf-4288-ac92-36440b0400a0
baz(args...)

# ╔═╡ a3933e7e-da2c-4339-9b61-dd48116c93e8
md"""
As you can see, if the wrong number of elements are in the splatted container, then the function call will fail, just as it would if too many arguments were given explicitly.
"""

# ╔═╡ 8b0b9264-9ba0-4fa3-90f6-075d811bc907
md"""
## Optional Arguments
"""

# ╔═╡ 55304302-3de6-450e-99ee-bc78e16a6144
md"""
It is often possible to provide sensible default values for function arguments. This can save users from having to pass every argument on every call. For example, the function [`Date(y, [m, d])`](@ref) from `Dates` module constructs a `Date` type for a given year `y`, month `m` and day `d`. However, `m` and `d` arguments are optional and their default value is `1`. This behavior can be expressed concisely as:
"""

# ╔═╡ b5ca30e7-5926-44ef-82c1-cb849ace32e4
md"""
```julia
function Date(y::Int64, m::Int64=1, d::Int64=1)
    err = validargs(Date, y, m, d)
    err === nothing || throw(err)
    return Date(UTD(totaldays(y, m, d)))
end
```
"""

# ╔═╡ 767e6252-4908-4950-aa4d-0ae3fb42c908
md"""
Observe, that this definition calls another method of the `Date` function that takes one argument of type `UTInstant{Day}`.
"""

# ╔═╡ eaac3320-5dad-47aa-9b97-45e426a6c535
md"""
With this definition, the function can be called with either one, two or three arguments, and `1` is automatically passed when only one or two of the arguments are specified:
"""

# ╔═╡ e7d294f6-0f75-49ed-a278-22a27bf103c4
using Dates

# ╔═╡ 911bcba3-d137-4e84-a299-a26a39e98a9f
Date(2000, 12, 12)

# ╔═╡ a4269057-6dba-42a0-ad71-d099aa490bf6
Date(2000, 12)

# ╔═╡ 17827302-be6f-451c-8467-2a7ab1c76873
Date(2000)

# ╔═╡ bb75f1a5-4103-45f4-b3bf-92b7f9af736b
md"""
Optional arguments are actually just a convenient syntax for writing multiple method definitions with different numbers of arguments (see [Note on Optional and keyword Arguments](@ref)). This can be checked for our `Date` function example by calling `methods` function.
"""

# ╔═╡ 46424c5b-bb5b-4dca-a05b-9ba49489d966
md"""
## Keyword Arguments
"""

# ╔═╡ e181f61e-9f6c-40fd-9f50-d2d0036b9638
md"""
Some functions need a large number of arguments, or have a large number of behaviors. Remembering how to call such functions can be difficult. Keyword arguments can make these complex interfaces easier to use and extend by allowing arguments to be identified by name instead of only by position.
"""

# ╔═╡ 4b56de00-1fa8-4981-9394-521d29e899d7
md"""
For example, consider a function `plot` that plots a line. This function might have many options, for controlling line style, width, color, and so on. If it accepts keyword arguments, a possible call might look like `plot(x, y, width=2)`, where we have chosen to specify only line width. Notice that this serves two purposes. The call is easier to read, since we can label an argument with its meaning. It also becomes possible to pass any subset of a large number of arguments, in any order.
"""

# ╔═╡ 61522354-7fa1-48dd-8f12-ac4886d4f021
md"""
Functions with keyword arguments are defined using a semicolon in the signature:
"""

# ╔═╡ 314b0a27-433c-47ee-83a3-29fff8197cde
md"""
```julia
function plot(x, y; style=\"solid\", width=1, color=\"black\")
    ###
end
```
"""

# ╔═╡ 62fec882-3f27-475f-ac42-1b0d65c2890e
md"""
When the function is called, the semicolon is optional: one can either call `plot(x, y, width=2)` or `plot(x, y; width=2)`, but the former style is more common. An explicit semicolon is required only for passing varargs or computed keywords as described below.
"""

# ╔═╡ b9774b3f-2aac-4cb6-ab5f-02e1a52cceb4
md"""
Keyword argument default values are evaluated only when necessary (when a corresponding keyword argument is not passed), and in left-to-right order. Therefore default expressions may refer to prior keyword arguments.
"""

# ╔═╡ 9ce7112a-8208-449b-9f84-1c5b8dccf74d
md"""
The types of keyword arguments can be made explicit as follows:
"""

# ╔═╡ 3b6b6581-29b1-4234-a099-8b5d0705d300
md"""
```julia
function f(;x::Int=1)
    ###
end
```
"""

# ╔═╡ 13204fa4-7b34-4f6b-a291-fe5b3cd04660
md"""
Keyword arguments can also be used in varargs functions:
"""

# ╔═╡ b5424a83-e054-4ccf-93ab-8f57484f4c9e
md"""
```julia
function plot(x...; style=\"solid\")
    ###
end
```
"""

# ╔═╡ c34f9711-f4ae-49d3-bc05-702e16c2bcba
md"""
Extra keyword arguments can be collected using `...`, as in varargs functions:
"""

# ╔═╡ 8667bde1-0c81-42e7-83ed-d2d0d3adac50
md"""
```julia
function f(x; y=0, kwargs...)
    ###
end
```
"""

# ╔═╡ 159f0f33-a767-451b-ace0-bf3c561c99fe
md"""
Inside `f`, `kwargs` will be an immutable key-value iterator over a named tuple. Named tuples (as well as dictionaries with keys of `Symbol`) can be passed as keyword arguments using a semicolon in a call, e.g. `f(x, z=1; kwargs...)`.
"""

# ╔═╡ 73be42fe-b862-4892-9bdc-0f260964efab
md"""
If a keyword argument is not assigned a default value in the method definition, then it is *required*: an [`UndefKeywordError`](@ref) exception will be thrown if the caller does not assign it a value:
"""

# ╔═╡ 3dc79299-ee32-47cc-8b4a-fb03057747da
md"""
```julia
function f(x; y)
    ###
end
f(3, y=5) # ok, y is assigned
f(3)      # throws UndefKeywordError(:y)
```
"""

# ╔═╡ 446cad8c-dfb2-4779-968b-b83a55a481a7
md"""
One can also pass `key => value` expressions after a semicolon. For example, `plot(x, y; :width => 2)` is equivalent to `plot(x, y, width=2)`. This is useful in situations where the keyword name is computed at runtime.
"""

# ╔═╡ 0551bda5-75a2-4cf6-b3cb-3fd2055498fb
md"""
When a bare identifier or dot expression occurs after a semicolon, the keyword argument name is implied by the identifier or field name. For example `plot(x, y; width)` is equivalent to `plot(x, y; width=width)` and `plot(x, y; options.width)` is equivalent to `plot(x, y; width=options.width)`.
"""

# ╔═╡ 246652e4-afa2-4160-8595-ecb482a02c0f
md"""
The nature of keyword arguments makes it possible to specify the same argument more than once. For example, in the call `plot(x, y; options..., width=2)` it is possible that the `options` structure also contains a value for `width`. In such a case the rightmost occurrence takes precedence; in this example, `width` is certain to have the value `2`. However, explicitly specifying the same keyword argument multiple times, for example `plot(x, y, width=2, width=3)`, is not allowed and results in a syntax error.
"""

# ╔═╡ c1a0ddf0-553f-4eef-8e50-82b958e1913d
md"""
## Evaluation Scope of Default Values
"""

# ╔═╡ 56d773ef-35f9-4748-a2fc-7cc40f93b95f
md"""
When optional and keyword argument default expressions are evaluated, only *previous* arguments are in scope. For example, given this definition:
"""

# ╔═╡ a5ac2811-32cf-4e4a-927d-1fcd39ac33d9
md"""
```julia
function f(x, a=b, b=1)
    ###
end
```
"""

# ╔═╡ fc8e142b-6ed2-4023-80f9-ac9b7f02b225
md"""
the `b` in `a=b` refers to a `b` in an outer scope, not the subsequent argument `b`.
"""

# ╔═╡ a91a018a-9dd1-48bf-ac80-68bba615bf67
md"""
## Do-Block Syntax for Function Arguments
"""

# ╔═╡ 104b74f1-7c9b-402d-b041-b969dde41692
md"""
Passing functions as arguments to other functions is a powerful technique, but the syntax for it is not always convenient. Such calls are especially awkward to write when the function argument requires multiple lines. As an example, consider calling [`map`](@ref) on a function with several cases:
"""

# ╔═╡ dde00368-52e4-426f-a78d-85895a37e119
md"""
```julia
map(x->begin
           if x < 0 && iseven(x)
               return 0
           elseif x == 0
               return 1
           else
               return x
           end
       end,
    [A, B, C])
```
"""

# ╔═╡ 6ece7e9c-e4f2-4f20-a273-f24f4a178f3a
md"""
Julia provides a reserved word `do` for rewriting this code more clearly:
"""

# ╔═╡ fd463702-eec1-46eb-bfcd-38ec71f8428d
md"""
```julia
map([A, B, C]) do x
    if x < 0 && iseven(x)
        return 0
    elseif x == 0
        return 1
    else
        return x
    end
end
```
"""

# ╔═╡ 8e40f4de-60f9-4a5d-94d7-a2d158cff45f
md"""
The `do x` syntax creates an anonymous function with argument `x` and passes it as the first argument to [`map`](@ref). Similarly, `do a,b` would create a two-argument anonymous function, and a plain `do` would declare that what follows is an anonymous function of the form `() -> ...`.
"""

# ╔═╡ 2d31bd20-e4f4-41e8-b947-7cbef848d81f
md"""
How these arguments are initialized depends on the \"outer\" function; here, [`map`](@ref) will sequentially set `x` to `A`, `B`, `C`, calling the anonymous function on each, just as would happen in the syntax `map(func, [A, B, C])`.
"""

# ╔═╡ 0ae6286e-0ad5-4c1e-9151-9cb288a34e4a
md"""
This syntax makes it easier to use functions to effectively extend the language, since calls look like normal code blocks. There are many possible uses quite different from [`map`](@ref), such as managing system state. For example, there is a version of [`open`](@ref) that runs code ensuring that the opened file is eventually closed:
"""

# ╔═╡ 3b78517c-42be-44ac-a539-ebcd0c694046
md"""
```julia
open(\"outfile\", \"w\") do io
    write(io, data)
end
```
"""

# ╔═╡ ecda3d51-0742-42c9-84f8-a4731ef521bb
md"""
This is accomplished by the following definition:
"""

# ╔═╡ f64bcdc8-6052-4e9c-8d42-71b26d33fdba
md"""
```julia
function open(f::Function, args...)
    io = open(args...)
    try
        f(io)
    finally
        close(io)
    end
end
```
"""

# ╔═╡ 9c0bd06d-b455-4641-b1eb-9b29535cc679
md"""
Here, [`open`](@ref) first opens the file for writing and then passes the resulting output stream to the anonymous function you defined in the `do ... end` block. After your function exits, [`open`](@ref) will make sure that the stream is properly closed, regardless of whether your function exited normally or threw an exception. (The `try/finally` construct will be described in [Control Flow](@ref).)
"""

# ╔═╡ 5bdd6204-ba33-4309-a8cc-977d7c9b9666
md"""
With the `do` block syntax, it helps to check the documentation or implementation to know how the arguments of the user function are initialized.
"""

# ╔═╡ 44deb3d1-c962-4521-8b3b-b7e29ebc34ce
md"""
A `do` block, like any other inner function, can \"capture\" variables from its enclosing scope. For example, the variable `data` in the above example of `open...do` is captured from the outer scope. Captured variables can create performance challenges as discussed in [performance tips](@ref man-performance-captured).
"""

# ╔═╡ a516afcc-88bc-4ba7-816c-51fb384d94a7
md"""
## Function composition and piping
"""

# ╔═╡ 4378ab37-57b7-4859-b06c-5a2dae3fd521
md"""
Functions in Julia can be combined by composing or piping (chaining) them together.
"""

# ╔═╡ 0713c159-7a7d-4563-a880-dfc764ad93d8
md"""
Function composition is when you combine functions together and apply the resulting composition to arguments. You use the function composition operator (`∘`) to compose the functions, so `(f ∘ g)(args...)` is the same as `f(g(args...))`.
"""

# ╔═╡ 25433514-2070-4ff1-a2ca-7c8e44ebfe41
md"""
You can type the composition operator at the REPL and suitably-configured editors using `\circ<tab>`.
"""

# ╔═╡ cf79d9ec-53e3-4ad4-9f3c-a4c63dea2d4d
md"""
For example, the `sqrt` and `+` functions can be composed like this:
"""

# ╔═╡ 59b658b9-8455-404d-9c66-1baf0567805c
(sqrt ∘ +)(3, 6)

# ╔═╡ 598f3b5d-214f-4804-8b5d-225c1091f5c0
md"""
This adds the numbers first, then finds the square root of the result.
"""

# ╔═╡ a7d54972-7bf1-480f-afdb-cc645db2ccd5
md"""
The next example composes three functions and maps the result over an array of strings:
"""

# ╔═╡ da7ef4d3-eddb-4014-8cea-7461fd3c861d
map(first ∘ reverse ∘ uppercase, split("you can compose functions like this"))

# ╔═╡ 8ea06c74-5e5d-47b2-952a-2e370ab48358
md"""
Function chaining (sometimes called \"piping\" or \"using a pipe\" to send data to a subsequent function) is when you apply a function to the previous function's output:
"""

# ╔═╡ 82f05e2c-de74-4c94-8e1f-ff3b669fdd0f
1:10 |> sum |> sqrt

# ╔═╡ 7575f733-5568-40ee-b65f-9006b862d691
md"""
Here, the total produced by `sum` is passed to the `sqrt` function. The equivalent composition would be:
"""

# ╔═╡ fe0e9944-91a6-4722-9e62-3e0e0a131b7d
(sqrt ∘ sum)(1:10)

# ╔═╡ a724cb55-dfb2-4b81-9b61-8c314f924813
md"""
The pipe operator can also be used with broadcasting, as `.|>`, to provide a useful combination of the chaining/piping and dot vectorization syntax (described next).
"""

# ╔═╡ e1b829bd-a0ad-49ba-8c0d-a1a605e94dc2
["a", "list", "of", "strings"] .|> [uppercase, reverse, titlecase, length]

# ╔═╡ b837305c-afcb-4b14-abd0-2edb6038b79b
md"""
## [Dot Syntax for Vectorizing Functions](@id man-vectorized)
"""

# ╔═╡ 88974f54-8181-4d3a-85d3-27a0488b8ac6
md"""
In technical-computing languages, it is common to have \"vectorized\" versions of functions, which simply apply a given function `f(x)` to each element of an array `A` to yield a new array via `f(A)`. This kind of syntax is convenient for data processing, but in other languages vectorization is also often required for performance: if loops are slow, the \"vectorized\" version of a function can call fast library code written in a low-level language. In Julia, vectorized functions are *not* required for performance, and indeed it is often beneficial to write your own loops (see [Performance Tips](@ref man-performance-tips)), but they can still be convenient. Therefore, *any* Julia function `f` can be applied elementwise to any array (or other collection) with the syntax `f.(A)`. For example, `sin` can be applied to all elements in the vector `A` like so:
"""

# ╔═╡ e4d6f0e2-32af-4e78-b02d-cd2a5dff7df1
A = [1.0, 2.0, 3.0]

# ╔═╡ dab01307-3323-4ac0-9987-adf34f7eb9c1
sin.(A)

# ╔═╡ c6d3ff4c-e3f6-49f2-a434-05569c646f92
md"""
Of course, you can omit the dot if you write a specialized \"vector\" method of `f`, e.g. via `f(A::AbstractArray) = map(f, A)`, and this is just as efficient as `f.(A)`. The advantage of the `f.(A)` syntax is that which functions are vectorizable need not be decided upon in advance by the library writer.
"""

# ╔═╡ 7fce0499-ec96-44c2-958d-cad351ee97c6
md"""
More generally, `f.(args...)` is actually equivalent to `broadcast(f, args...)`, which allows you to operate on multiple arrays (even of different shapes), or a mix of arrays and scalars (see [Broadcasting](@ref)). For example, if you have `f(x,y) = 3x + 4y`, then `f.(pi,A)` will return a new array consisting of `f(pi,a)` for each `a` in `A`, and `f.(vector1,vector2)` will return a new vector consisting of `f(vector1[i],vector2[i])` for each index `i` (throwing an exception if the vectors have different length).
"""

# ╔═╡ 90f74d6b-d6a9-4c28-ae48-df9cef74465e
f(x,y) = 3x + 4y;

# ╔═╡ 85f84140-d803-45dd-8687-42c032f42999
A = [1.0, 2.0, 3.0];

# ╔═╡ d229fcb5-4beb-42fa-95ea-c6915d554287
B = [4.0, 5.0, 6.0];

# ╔═╡ a2f0a718-d8c5-489d-9112-a5699eae5de6
f.(pi, A)

# ╔═╡ 9bb6bfa6-281d-4c72-9c24-2115cf68970a
f.(A, B)

# ╔═╡ 64d74034-b2bf-4536-8e3c-ba1f718b912a
md"""
Moreover, *nested* `f.(args...)` calls are *fused* into a single `broadcast` loop. For example, `sin.(cos.(X))` is equivalent to `broadcast(x -> sin(cos(x)), X)`, similar to `[sin(cos(x)) for x in X]`: there is only a single loop over `X`, and a single array is allocated for the result. [In contrast, `sin(cos(X))` in a typical \"vectorized\" language would first allocate one temporary array for `tmp=cos(X)`, and then compute `sin(tmp)` in a separate loop, allocating a second array.] This loop fusion is not a compiler optimization that may or may not occur, it is a *syntactic guarantee* whenever nested `f.(args...)` calls are encountered. Technically, the fusion stops as soon as a \"non-dot\" function call is encountered; for example, in `sin.(sort(cos.(X)))` the `sin` and `cos` loops cannot be merged because of the intervening `sort` function.
"""

# ╔═╡ 4e934a38-99fe-403a-8851-a3496fdf2aa7
md"""
Finally, the maximum efficiency is typically achieved when the output array of a vectorized operation is *pre-allocated*, so that repeated calls do not allocate new arrays over and over again for the results (see [Pre-allocating outputs](@ref)). A convenient syntax for this is `X .= ...`, which is equivalent to `broadcast!(identity, X, ...)` except that, as above, the `broadcast!` loop is fused with any nested \"dot\" calls. For example, `X .= sin.(Y)` is equivalent to `broadcast!(sin, X, Y)`, overwriting `X` with `sin.(Y)` in-place. If the left-hand side is an array-indexing expression, e.g. `X[begin+1:end] .= sin.(Y)`, then it translates to `broadcast!` on a `view`, e.g. `broadcast!(sin, view(X, firstindex(X)+1:lastindex(X)), Y)`, so that the left-hand side is updated in-place.
"""

# ╔═╡ dd99374b-783b-407d-8ae4-b98fb56fe8bb
md"""
Since adding dots to many operations and function calls in an expression can be tedious and lead to code that is difficult to read, the macro [`@.`](@ref @__dot__) is provided to convert *every* function call, operation, and assignment in an expression into the \"dotted\" version.
"""

# ╔═╡ 9069ed6d-5597-439d-a33b-43258a171dc5
Y = [1.0, 2.0, 3.0, 4.0];

# ╔═╡ d72b16cb-58bd-4c36-b087-cef63950fc47
X = similar(Y); # pre-allocate output array

# ╔═╡ 69d2e7bf-55b5-4c29-b7eb-ff0d9935f602
@. X = sin(cos(Y)) # equivalent to X .= sin.(cos.(Y))

# ╔═╡ 0fc3bc58-6314-4f57-bf70-b70073b259d5
md"""
Binary (or unary) operators like `.+` are handled with the same mechanism: they are equivalent to `broadcast` calls and are fused with other nested \"dot\" calls.  `X .+= Y` etcetera is equivalent to `X .= X .+ Y` and results in a fused in-place assignment;  see also [dot operators](@ref man-dot-operators).
"""

# ╔═╡ cfb85bb8-9692-48b2-ae2a-ea5513cf779b
md"""
You can also combine dot operations with function chaining using [`|>`](@ref), as in this example:
"""

# ╔═╡ f2366b57-22b8-461a-be68-4057f6ee82e8
[1:5;] .|> [x->x^2, inv, x->2*x, -, isodd]

# ╔═╡ d274aec0-9a0c-4172-b1e4-6f4312484987
md"""
## Further Reading
"""

# ╔═╡ 18809ded-6a42-494c-9612-cb281d35bc54
md"""
We should mention here that this is far from a complete picture of defining functions. Julia has a sophisticated type system and allows multiple dispatch on argument types. None of the examples given here provide any type annotations on their arguments, meaning that they are applicable to all types of arguments. The type system is described in [Types](@ref man-types) and defining a function in terms of methods chosen by multiple dispatch on run-time argument types is described in [Methods](@ref).
"""

# ╔═╡ Cell order:
# ╟─976eb3b0-53f7-45f0-ac6d-0127203d5044
# ╟─660f9ee8-d6a1-470e-9a39-dcde1ac4e8a0
# ╠═9de72f85-a416-41be-9399-88dbad501d1a
# ╟─894b6b1c-cdc0-4343-9c2e-6db83ba58f22
# ╟─bf1ca0bc-8e23-4145-b57f-81207720c0e0
# ╠═d84640f5-fb92-49fe-a292-d212ec18f505
# ╟─9c052770-7518-4b8e-969d-b8e71e43e217
# ╟─d299e181-e3f0-439f-ba11-5bfc7209d17d
# ╠═abf077a2-d2c4-4f92-aed7-1a2367826d8d
# ╟─bd8d65f1-7627-4fb0-8381-7cba39757d26
# ╠═f938bed1-eac4-4370-a4e5-f361563ae6c3
# ╠═1631a923-a399-4527-868a-375bff49e775
# ╟─0f02aeef-f5cc-4d98-9350-6b9d1ae6fb44
# ╠═b2e413c1-3292-4091-ac3a-d00a57707bfd
# ╠═b52a5edd-10f6-4e4d-a195-38ab44719279
# ╟─b428491f-76bd-4222-8ec4-5c5364780dc5
# ╟─beaee484-e849-44ad-9393-1d6dcf0e57bd
# ╟─753d805b-1f43-48ae-8ee0-89649152b6e3
# ╟─478c9c2a-13dd-4de1-8c7d-487d94b6a1d7
# ╟─13cad595-98fc-43b6-828f-751bbc461d8d
# ╟─42629963-0df8-4d5c-b0f7-973fbaf310a9
# ╠═00565eb8-b882-40b8-b5d9-9af2e92c7682
# ╠═0125887e-0c13-4550-8ba5-a599944b9b57
# ╠═599b19a4-51c7-480d-ba6e-e2e68416de2e
# ╠═fbacf27b-8f6c-41c1-a9e0-2d573746357a
# ╟─98016434-2454-4ac5-b64a-340fec6c3ce8
# ╠═bbd9ea31-92df-40ac-8aa9-c5a37e6c2985
# ╠═f7b15930-6a71-42d3-bfc1-5f4e1f0b6b00
# ╟─5ec6f4df-aed4-4a8c-9195-0d414b6c6b06
# ╟─6b723b70-1785-4eb9-b44c-3dfde47f72b2
# ╟─6fc47afc-b371-42db-ab5a-7c1b04186bf1
# ╠═6f2a8268-3fc7-454d-9c9f-ffe73a88f342
# ╠═66a92ea9-032f-4fb5-863d-8cc2ed5aed71
# ╟─7547acb4-398c-4a45-8e6f-6953d1c728da
# ╟─4a8adf95-9b28-4ece-9d52-b4781fb2d854
# ╟─6bb098f4-7607-47c7-b159-120e91d13ec1
# ╟─0c276b17-267d-4f7d-b376-4e02e3e5af9d
# ╟─bce4e027-34c5-4c4c-a707-da64df74b1f6
# ╟─1231294a-bd7f-4d7b-8adb-acf93fd094ab
# ╟─24d8572f-508b-40df-ad9d-f58ff734dc02
# ╟─25a68ad0-69c9-4ce8-a7be-a222407ba402
# ╠═d6365006-6dc2-42fa-934f-db2952ed5165
# ╠═23d6d89d-aae8-4e1b-b22d-2f0283a467a2
# ╟─d55c9ff0-146c-4e1a-a0ae-cce8b61408a8
# ╠═7816d420-d2a7-4a96-a270-aa31706a4891
# ╠═0780c807-9d44-43c3-bbdd-bfc2533bf2f8
# ╟─85c32258-cafe-4a3a-8cba-5ee807840c13
# ╟─b761bc8c-e55f-4291-98a4-aab758e720b6
# ╟─d086375c-2004-4a64-8b78-fe8208e65b40
# ╟─b643a2c1-62e7-42f8-8270-125ce2c12ccc
# ╟─1e1d043e-400c-4686-9daf-d48fb21dbba9
# ╟─7433df95-014b-43b1-b4ef-ae5add512e48
# ╠═da3bca81-cfc8-47e8-86b3-0ba4ceee8ff5
# ╠═9457721a-9ca7-4c06-a680-f49a543b8570
# ╟─53277164-cb39-4d43-a2af-7d91c7b666d8
# ╟─c33f7b69-8c7c-4cbd-b82c-d14f7e119e14
# ╠═05fe9eb1-888b-4677-a0c4-ec320b565556
# ╟─071c07d2-46e0-4753-ba66-cf0881713205
# ╠═aed0c00a-3186-49dd-aaf9-90ffd4a6b751
# ╟─080e8e78-6a87-43ea-bd74-8a120d30ed2b
# ╟─73a398f4-a269-4797-8d6a-011fc044e2f0
# ╟─4acd49b1-0b57-4248-84ac-2ae9b4a339e9
# ╟─c8385939-915c-47c6-89f5-d6088a939da5
# ╟─988e8bc2-73a4-4dd0-aec4-6898ddd92faf
# ╟─acda9fc9-d889-4057-a206-a88018270245
# ╟─f11bc3ff-98e7-4da7-8423-ba8f6494d08e
# ╟─a95c5741-3e66-46a7-801c-eecb800e1c0a
# ╠═71e190dc-a96e-4189-80a5-b03f6ad65af0
# ╠═5e8ed4c4-946c-4e01-afaf-026b8e7f99bd
# ╠═82ac4844-65b5-49fe-be5b-4ed392668bc6
# ╠═c571f923-972a-496b-ac58-d6777eb6d692
# ╟─479dea31-1a4c-4fac-9f97-568c38f5a9f2
# ╟─d0a04a58-5e6c-4892-a718-4cb8149924c5
# ╟─166e29e8-c1b0-44a6-b712-c86d57a79b9f
# ╠═2e31c2cd-fc92-4b37-b719-9f3ab69a7426
# ╠═534d2690-c512-4ae8-af2b-ef7f39526e00
# ╠═85ca2f0b-90c1-40f5-b8e4-b84ff8997aaa
# ╟─abf80534-f409-42a8-8037-8285b9687941
# ╟─bbdaa7b0-2bb5-4111-af18-097f5778848f
# ╟─905dda1e-ec33-4905-92c1-cf358a1ad3d0
# ╠═945c33fd-0009-44c9-86fb-eca553c4d745
# ╟─63ed6951-64f2-4d83-8817-c9503a3e7a3c
# ╠═32c99526-7a83-4512-9be8-2febe976f693
# ╟─b8329d2f-cad3-4c31-8f04-6c50a890bdf2
# ╠═70ecc781-eb9d-4d83-aef7-7cd54f0edd66
# ╠═0b9b6e81-fae2-4c9e-8150-9ca6d053c661
# ╠═61f02494-9677-4c90-a08d-e083dc638423
# ╟─57630307-e964-4030-ba36-6dd4b8bbbc31
# ╟─803dc48b-1950-4ec6-9766-3f4be2c42b80
# ╟─65460138-0a5c-4544-87ca-e5bd1763a256
# ╟─ad34b9f5-c91c-4392-84a1-13f5e3e0832c
# ╟─81f82eb2-ad76-4fb3-a96f-6cabbcde4114
# ╟─fb069ded-1d5e-4227-89ea-dcf2771cef47
# ╟─e0ab0e61-0568-46a2-a51e-140bdea34501
# ╟─657d13f2-e8cf-4601-8144-285e30782ef3
# ╟─e0c00c30-4f16-4df1-aac4-78493a3150dd
# ╠═e87bf8e4-a410-4d3f-beaa-40d10727a35d
# ╟─baa68a4f-1388-446d-88b9-5e27cf4a641f
# ╠═082deae3-b345-4c31-bfe4-5b4abeb67504
# ╠═b2f93a63-6b1d-49eb-a225-a00df782426b
# ╠═0ae8342d-c554-496c-9195-6554323a84ff
# ╠═d5a1e230-a9df-4c20-b6b7-cc9efb6884c4
# ╟─66e3bd59-454e-4c45-ab4c-92cef7c59091
# ╟─4efe089f-c394-490e-8405-599c5b03d7fc
# ╟─6ac8b069-8760-4eb3-b9ec-396ee6fb1314
# ╠═e23a17d6-59d0-4cc6-b685-8cad2243e252
# ╠═38af5644-3031-4d41-b332-469eace81e39
# ╟─8953e105-865b-4807-8aec-7147b0184a94
# ╠═2b0116fd-0929-4e7e-886b-4d58dadc59f6
# ╠═441ac4a1-8b70-4ab8-bbd4-8b1b3271759f
# ╠═d2464aa9-6804-421e-a81b-9899e4161dea
# ╠═02646757-03a8-4ecd-a0c5-4740902f538a
# ╟─5cba24e2-3de3-4440-b503-84cef2bb3e55
# ╠═5cc14b66-a053-4390-9192-ec5a81360022
# ╠═17f94373-afd9-4000-b023-4d30d6416d35
# ╠═6a1c28a3-ae71-4f35-92e3-812e928aa398
# ╠═825d709c-8a79-448c-ba02-71f04c29e7b8
# ╟─69bd2061-1ad4-4962-a647-f9866f5da0a3
# ╠═763e6e4a-84d7-42f6-96a0-ff7a9b734ce4
# ╠═b4d75385-2d75-4926-b215-dd339594f6c4
# ╠═1d8170c7-c623-4ebe-b934-cd44330c8622
# ╠═06646361-77f0-43c4-95c2-163628a094d2
# ╠═1b6b5796-cfaf-4288-ac92-36440b0400a0
# ╟─a3933e7e-da2c-4339-9b61-dd48116c93e8
# ╟─8b0b9264-9ba0-4fa3-90f6-075d811bc907
# ╟─55304302-3de6-450e-99ee-bc78e16a6144
# ╟─b5ca30e7-5926-44ef-82c1-cb849ace32e4
# ╟─767e6252-4908-4950-aa4d-0ae3fb42c908
# ╟─eaac3320-5dad-47aa-9b97-45e426a6c535
# ╠═e7d294f6-0f75-49ed-a278-22a27bf103c4
# ╠═911bcba3-d137-4e84-a299-a26a39e98a9f
# ╠═a4269057-6dba-42a0-ad71-d099aa490bf6
# ╠═17827302-be6f-451c-8467-2a7ab1c76873
# ╟─bb75f1a5-4103-45f4-b3bf-92b7f9af736b
# ╟─46424c5b-bb5b-4dca-a05b-9ba49489d966
# ╟─e181f61e-9f6c-40fd-9f50-d2d0036b9638
# ╟─4b56de00-1fa8-4981-9394-521d29e899d7
# ╟─61522354-7fa1-48dd-8f12-ac4886d4f021
# ╟─314b0a27-433c-47ee-83a3-29fff8197cde
# ╟─62fec882-3f27-475f-ac42-1b0d65c2890e
# ╟─b9774b3f-2aac-4cb6-ab5f-02e1a52cceb4
# ╟─9ce7112a-8208-449b-9f84-1c5b8dccf74d
# ╟─3b6b6581-29b1-4234-a099-8b5d0705d300
# ╟─13204fa4-7b34-4f6b-a291-fe5b3cd04660
# ╟─b5424a83-e054-4ccf-93ab-8f57484f4c9e
# ╟─c34f9711-f4ae-49d3-bc05-702e16c2bcba
# ╟─8667bde1-0c81-42e7-83ed-d2d0d3adac50
# ╟─159f0f33-a767-451b-ace0-bf3c561c99fe
# ╟─73be42fe-b862-4892-9bdc-0f260964efab
# ╟─3dc79299-ee32-47cc-8b4a-fb03057747da
# ╟─446cad8c-dfb2-4779-968b-b83a55a481a7
# ╟─0551bda5-75a2-4cf6-b3cb-3fd2055498fb
# ╟─246652e4-afa2-4160-8595-ecb482a02c0f
# ╟─c1a0ddf0-553f-4eef-8e50-82b958e1913d
# ╟─56d773ef-35f9-4748-a2fc-7cc40f93b95f
# ╟─a5ac2811-32cf-4e4a-927d-1fcd39ac33d9
# ╟─fc8e142b-6ed2-4023-80f9-ac9b7f02b225
# ╟─a91a018a-9dd1-48bf-ac80-68bba615bf67
# ╟─104b74f1-7c9b-402d-b041-b969dde41692
# ╟─dde00368-52e4-426f-a78d-85895a37e119
# ╟─6ece7e9c-e4f2-4f20-a273-f24f4a178f3a
# ╟─fd463702-eec1-46eb-bfcd-38ec71f8428d
# ╟─8e40f4de-60f9-4a5d-94d7-a2d158cff45f
# ╟─2d31bd20-e4f4-41e8-b947-7cbef848d81f
# ╟─0ae6286e-0ad5-4c1e-9151-9cb288a34e4a
# ╟─3b78517c-42be-44ac-a539-ebcd0c694046
# ╟─ecda3d51-0742-42c9-84f8-a4731ef521bb
# ╟─f64bcdc8-6052-4e9c-8d42-71b26d33fdba
# ╟─9c0bd06d-b455-4641-b1eb-9b29535cc679
# ╟─5bdd6204-ba33-4309-a8cc-977d7c9b9666
# ╟─44deb3d1-c962-4521-8b3b-b7e29ebc34ce
# ╟─a516afcc-88bc-4ba7-816c-51fb384d94a7
# ╟─4378ab37-57b7-4859-b06c-5a2dae3fd521
# ╟─0713c159-7a7d-4563-a880-dfc764ad93d8
# ╟─25433514-2070-4ff1-a2ca-7c8e44ebfe41
# ╟─cf79d9ec-53e3-4ad4-9f3c-a4c63dea2d4d
# ╠═59b658b9-8455-404d-9c66-1baf0567805c
# ╟─598f3b5d-214f-4804-8b5d-225c1091f5c0
# ╟─a7d54972-7bf1-480f-afdb-cc645db2ccd5
# ╠═da7ef4d3-eddb-4014-8cea-7461fd3c861d
# ╟─8ea06c74-5e5d-47b2-952a-2e370ab48358
# ╠═82f05e2c-de74-4c94-8e1f-ff3b669fdd0f
# ╟─7575f733-5568-40ee-b65f-9006b862d691
# ╠═fe0e9944-91a6-4722-9e62-3e0e0a131b7d
# ╟─a724cb55-dfb2-4b81-9b61-8c314f924813
# ╠═e1b829bd-a0ad-49ba-8c0d-a1a605e94dc2
# ╟─b837305c-afcb-4b14-abd0-2edb6038b79b
# ╟─88974f54-8181-4d3a-85d3-27a0488b8ac6
# ╠═e4d6f0e2-32af-4e78-b02d-cd2a5dff7df1
# ╠═dab01307-3323-4ac0-9987-adf34f7eb9c1
# ╟─c6d3ff4c-e3f6-49f2-a434-05569c646f92
# ╟─7fce0499-ec96-44c2-958d-cad351ee97c6
# ╠═90f74d6b-d6a9-4c28-ae48-df9cef74465e
# ╠═85f84140-d803-45dd-8687-42c032f42999
# ╠═d229fcb5-4beb-42fa-95ea-c6915d554287
# ╠═a2f0a718-d8c5-489d-9112-a5699eae5de6
# ╠═9bb6bfa6-281d-4c72-9c24-2115cf68970a
# ╟─64d74034-b2bf-4536-8e3c-ba1f718b912a
# ╟─4e934a38-99fe-403a-8851-a3496fdf2aa7
# ╟─dd99374b-783b-407d-8ae4-b98fb56fe8bb
# ╠═9069ed6d-5597-439d-a33b-43258a171dc5
# ╠═d72b16cb-58bd-4c36-b087-cef63950fc47
# ╠═69d2e7bf-55b5-4c29-b7eb-ff0d9935f602
# ╟─0fc3bc58-6314-4f57-bf70-b70073b259d5
# ╟─cfb85bb8-9692-48b2-ae2a-ea5513cf779b
# ╠═f2366b57-22b8-461a-be68-4057f6ee82e8
# ╟─d274aec0-9a0c-4172-b1e4-6f4312484987
# ╟─18809ded-6a42-494c-9612-cb281d35bc54
