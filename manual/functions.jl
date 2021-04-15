### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ 03c70c34-9e19-11eb-3215-e1b7038588b6
md"""
# [Functions](@id man-functions)
"""

# ╔═╡ 03c70c84-9e19-11eb-24cf-6f18b15e467a
md"""
In Julia, a function is an object that maps a tuple of argument values to a return value. Julia functions are not pure mathematical functions, because they can alter and be affected by the global state of the program. The basic syntax for defining functions in Julia is:
"""

# ╔═╡ 03c712d8-9e19-11eb-3a9b-b3ebe7ce1ae4
function f(x,y)
           x + y
       end

# ╔═╡ 03c71328-9e19-11eb-38d7-e5a2bccf884e
md"""
This function accepts two arguments `x` and `y` and returns the value of the last expression evaluated, which is `x + y`.
"""

# ╔═╡ 03c71348-9e19-11eb-0f5b-839415430e9d
md"""
There is a second, more terse syntax for defining a function in Julia. The traditional function declaration syntax demonstrated above is equivalent to the following compact "assignment form":
"""

# ╔═╡ 03c71508-9e19-11eb-05bd-4d369f832177
f(x,y) = x + y

# ╔═╡ 03c71544-9e19-11eb-1323-3de1aa4abf6e
md"""
In the assignment form, the body of the function must be a single expression, although it can be a compound expression (see [Compound Expressions](@ref man-compound-expressions)). Short, simple function definitions are common in Julia. The short function syntax is accordingly quite idiomatic, considerably reducing both typing and visual noise.
"""

# ╔═╡ 03c71562-9e19-11eb-10ce-830b5d86340b
md"""
A function is called using the traditional parenthesis syntax:
"""

# ╔═╡ 03c71706-9e19-11eb-187e-1bc1edbac39d
f(2,3)

# ╔═╡ 03c71724-9e19-11eb-150e-f5611fbba462
md"""
Without parentheses, the expression `f` refers to the function object, and can be passed around like any other value:
"""

# ╔═╡ 03c71948-9e19-11eb-3d6c-839d8e69df9b
g = f;

# ╔═╡ 03c71968-9e19-11eb-2b3d-6540c2551acf
g(2,3)

# ╔═╡ 03c719ae-9e19-11eb-0f75-c9af9b7d7ecf
md"""
As with variables, Unicode can also be used for function names:
"""

# ╔═╡ 03c71ca6-9e19-11eb-192b-bdb722f39fc9
∑(x,y) = x + y

# ╔═╡ 03c71cbc-9e19-11eb-3be2-5f2086f282a4
∑(2, 3)

# ╔═╡ 03c71d0a-9e19-11eb-0250-bdebd7a17eaf
md"""
## Argument Passing Behavior
"""

# ╔═╡ 03c71d8c-9e19-11eb-2f3e-3f81b905b146
md"""
Julia function arguments follow a convention sometimes called "pass-by-sharing", which means that values are not copied when they are passed to functions. Function arguments themselves act as new variable *bindings* (new locations that can refer to values), but the values they refer to are identical to the passed values. Modifications to mutable values (such as `Array`s) made within a function will be visible to the caller. This is the same behavior found in Scheme, most Lisps, Python, Ruby and Perl, among other dynamic languages.
"""

# ╔═╡ 03c71dd2-9e19-11eb-3737-13a8f283b7a9
md"""
## The `return` Keyword
"""

# ╔═╡ 03c71e18-9e19-11eb-185d-096a78bd9fd7
md"""
The value returned by a function is the value of the last expression evaluated, which, by default, is the last expression in the body of the function definition. In the example function, `f`, from the previous section this is the value of the expression `x + y`. As an alternative, as in many other languages, the `return` keyword causes a function to return immediately, providing an expression whose value is returned:
"""

# ╔═╡ 03c71e68-9e19-11eb-2a36-6bc5154137a0
md"""
```julia
function g(x,y)
    return x * y
    x + y
end
```
"""

# ╔═╡ 03c71e7c-9e19-11eb-1b95-53b20d25284b
md"""
Since function definitions can be entered into interactive sessions, it is easy to compare these definitions:
"""

# ╔═╡ 03c724e4-9e19-11eb-11cd-4744365572ed
f(x,y) = x + y

# ╔═╡ 03c724ee-9e19-11eb-2e16-27044f8eba3c
function g(x,y)
           return x * y
           x + y
       end

# ╔═╡ 03c724fa-9e19-11eb-3ba0-e992a2d0872c
f(2,3)

# ╔═╡ 03c72528-9e19-11eb-041d-313da7d71c4c
g(2,3)

# ╔═╡ 03c72570-9e19-11eb-05b8-0f4941b47f3d
md"""
Of course, in a purely linear function body like `g`, the usage of `return` is pointless since the expression `x + y` is never evaluated and we could simply make `x * y` the last expression in the function and omit the `return`. In conjunction with other control flow, however, `return` is of real use. Here, for example, is a function that computes the hypotenuse length of a right triangle with sides of length `x` and `y`, avoiding overflow:
"""

# ╔═╡ 03c736ac-9e19-11eb-30e4-a5fce66b4a48
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

# ╔═╡ 03c736b4-9e19-11eb-3cd2-e3d797baa707
hypot(3, 4)

# ╔═╡ 03c7370c-9e19-11eb-3123-3d460b2f1a56
md"""
There are three possible points of return from this function, returning the values of three different expressions, depending on the values of `x` and `y`. The `return` on the last line could be omitted since it is the last expression.
"""

# ╔═╡ 03c7375e-9e19-11eb-1651-9bfcf8c7b471
md"""
### Return type
"""

# ╔═╡ 03c7379a-9e19-11eb-2a05-8939ccf16b6c
md"""
A return type can be specified in the function declaration using the `::` operator. This converts the return value to the specified type.
"""

# ╔═╡ 03c73dee-9e19-11eb-17ba-c3c83208bf56
function g(x, y)::Int8
           return x * y
       end;

# ╔═╡ 03c73df8-9e19-11eb-081c-a16e3e152b66
typeof(g(1, 2))

# ╔═╡ 03c73e46-9e19-11eb-141b-61ca90f84162
md"""
This function will always return an `Int8` regardless of the types of `x` and `y`. See [Type Declarations](@ref) for more on return types.
"""

# ╔═╡ 03c73e5c-9e19-11eb-3bc7-af5e59e44e63
md"""
### Returning nothing
"""

# ╔═╡ 03c73e84-9e19-11eb-1dc2-838aa09eb0a8
md"""
For functions that do not need to return a value (functions used only for some side effects), the Julia convention is to return the value [`nothing`](@ref):
"""

# ╔═╡ 03c73eb8-9e19-11eb-2778-f512f2a10c60
md"""
```julia
function printx(x)
    println("x = $x")
    return nothing
end
```
"""

# ╔═╡ 03c73ef2-9e19-11eb-07df-b587be1a7e9a
md"""
This is a *convention* in the sense that `nothing` is not a Julia keyword but a only singleton object of type `Nothing`. Also, you may notice that the `printx` function example above is contrived, because `println` already returns `nothing`, so that the `return` line is redundant.
"""

# ╔═╡ 03c73f2e-9e19-11eb-1065-ad2a45d6f55e
md"""
There are two possible shortened forms for the `return nothing` expression. On the one hand, the `return` keyword implicitly returns `nothing`, so it can be used alone. On the other hand, since functions implicitly return their last expression evaluated, `nothing` can be used alone when it's the last expression. The preference for the expression `return nothing` as opposed to `return` or `nothing` alone is a matter of coding style.
"""

# ╔═╡ 03c73f4a-9e19-11eb-2db6-635704bfe403
md"""
## Operators Are Functions
"""

# ╔═╡ 03c73f7c-9e19-11eb-26f3-6986cffdb2b9
md"""
In Julia, most operators are just functions with support for special syntax. (The exceptions are operators with special evaluation semantics like `&&` and `||`. These operators cannot be functions since [Short-Circuit Evaluation](@ref) requires that their operands are not evaluated before evaluation of the operator.) Accordingly, you can also apply them using parenthesized argument lists, just as you would any other function:
"""

# ╔═╡ 03c74280-9e19-11eb-27e4-a10f73f506cc
1 + 2 + 3

# ╔═╡ 03c7428a-9e19-11eb-0ef5-f91ec8232cbc
+(1,2,3)

# ╔═╡ 03c742c6-9e19-11eb-3ff1-91fc3215af73
md"""
The infix form is exactly equivalent to the function application form – in fact the former is parsed to produce the function call internally. This also means that you can assign and pass around operators such as [`+`](@ref) and [`*`](@ref) just like you would with other function values:
"""

# ╔═╡ 03c7450a-9e19-11eb-0540-e1c6095e9e20
f = +;

# ╔═╡ 03c74514-9e19-11eb-002e-4fa68cf147e7
f(1,2,3)

# ╔═╡ 03c74546-9e19-11eb-04d9-07f26ddfbd96
md"""
Under the name `f`, the function does not support infix notation, however.
"""

# ╔═╡ 03c74564-9e19-11eb-1c59-038ea4bc5868
md"""
## Operators With Special Names
"""

# ╔═╡ 03c74578-9e19-11eb-37a9-2d87b5ea97a2
md"""
A few special expressions correspond to calls to functions with non-obvious names. These are:
"""

# ╔═╡ 03c748b6-9e19-11eb-1d6f-db1d13f7395e
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

# ╔═╡ 03c74906-9e19-11eb-3ccb-1f282b1dcfd5
md"""
## [Anonymous Functions](@id man-anonymous-functions)
"""

# ╔═╡ 03c74942-9e19-11eb-0e00-bf31e14b55a7
md"""
Functions in Julia are [first-class objects](https://en.wikipedia.org/wiki/First-class_citizen): they can be assigned to variables, and called using the standard function call syntax from the variable they have been assigned to. They can be used as arguments, and they can be returned as values. They can also be created anonymously, without being given a name, using either of these syntaxes:
"""

# ╔═╡ 03c7573e-9e19-11eb-0d0c-91ec1d2bba9f
x -> x^2 + 2x - 1

# ╔═╡ 03c75752-9e19-11eb-3de0-3b830fdaebf3
function (x)
           x^2 + 2x - 1
       end

# ╔═╡ 03c757de-9e19-11eb-34d3-3ba8d0b10f4e
md"""
This creates a function taking one argument `x` and returning the value of the polynomial `x^2 + 2x - 1` at that value. Notice that the result is a generic function, but with a compiler-generated name based on consecutive numbering.
"""

# ╔═╡ 03c7584c-9e19-11eb-27d4-d9e325b6c48b
md"""
The primary use for anonymous functions is passing them to functions which take other functions as arguments. A classic example is [`map`](@ref), which applies a function to each value of an array and returns a new array containing the resulting values:
"""

# ╔═╡ 03c75b1c-9e19-11eb-0e1d-8f6e53b7bbb1
map(round, [1.2, 3.5, 1.7])

# ╔═╡ 03c75b4e-9e19-11eb-1442-2d6f3e8a19cb
md"""
This is fine if a named function effecting the transform already exists to pass as the first argument to [`map`](@ref). Often, however, a ready-to-use, named function does not exist. In these situations, the anonymous function construct allows easy creation of a single-use function object without needing a name:
"""

# ╔═╡ 03c75fb0-9e19-11eb-29d9-d5f0d1f4bf51
map(x -> x^2 + 2x - 1, [1, 3, -1])

# ╔═╡ 03c75fd6-9e19-11eb-2384-59f64eab9652
md"""
An anonymous function accepting multiple arguments can be written using the syntax `(x,y,z)->2x+y-z`. A zero-argument anonymous function is written as `()->3`. The idea of a function with no arguments may seem strange, but is useful for "delaying" a computation. In this usage, a block of code is wrapped in a zero-argument function, which is later invoked by calling it as `f`.
"""

# ╔═╡ 03c75ff4-9e19-11eb-22a6-174ce681c8e4
md"""
As an example, consider this call to [`get`](@ref):
"""

# ╔═╡ 03c76030-9e19-11eb-2f69-23c0e3bad98c
md"""
```julia
get(dict, key) do
    # default value calculated here
    time()
end
```
"""

# ╔═╡ 03c7604e-9e19-11eb-11a6-d177c7ef5beb
md"""
The code above is equivalent to calling `get` with an anonymous function containing the code enclosed between `do` and `end`, like so:
"""

# ╔═╡ 03c76062-9e19-11eb-39b1-0bc7857c8d5e
md"""
```julia
get(()->time(), dict, key)
```
"""

# ╔═╡ 03c7608a-9e19-11eb-3990-b96252746d19
md"""
The call to [`time`](@ref) is delayed by wrapping it in a 0-argument anonymous function that is called only when the requested key is absent from `dict`.
"""

# ╔═╡ 03c760a8-9e19-11eb-06ec-5b3b1fcf3c13
md"""
## Tuples
"""

# ╔═╡ 03c760d0-9e19-11eb-0f7d-617e929735db
md"""
Julia has a built-in data structure called a *tuple* that is closely related to function arguments and return values. A tuple is a fixed-length container that can hold any values, but cannot be modified (it is *immutable*). Tuples are constructed with commas and parentheses, and can be accessed via indexing:
"""

# ╔═╡ 03c76738-9e19-11eb-2659-2104fa53de4f
(1, 1+1)

# ╔═╡ 03c76742-9e19-11eb-0a2f-c56b93ac7f05
(1,)

# ╔═╡ 03c76742-9e19-11eb-110e-51ed61b1ecc6
x = (0.0, "hello", 6*7)

# ╔═╡ 03c7674a-9e19-11eb-0117-edd06729eb9e
x[2]

# ╔═╡ 03c7676a-9e19-11eb-32b7-cf2326f411c9
md"""
Notice that a length-1 tuple must be written with a comma, `(1,)`, since `(1)` would just be a parenthesized value. `()` represents the empty (length-0) tuple.
"""

# ╔═╡ 03c7677c-9e19-11eb-24a9-c31d1f0dec28
md"""
## Named Tuples
"""

# ╔═╡ 03c7679c-9e19-11eb-31a7-ad4c25012a36
md"""
The components of tuples can optionally be named, in which case a *named tuple* is constructed:
"""

# ╔═╡ 03c76c1a-9e19-11eb-2e05-e98f5f94f23d
x = (a=2, b=1+2)

# ╔═╡ 03c76c26-9e19-11eb-1bba-85030faa47dc
x[1]

# ╔═╡ 03c76c26-9e19-11eb-0a5f-71818abd0d19
x.a

# ╔═╡ 03c76c42-9e19-11eb-0dc0-73298066d3a2
md"""
Named tuples are very similar to tuples, except that fields can additionally be accessed by name using dot syntax (`x.a`) in addition to the regular indexing syntax (`x[1]`).
"""

# ╔═╡ 03c76c58-9e19-11eb-2b1f-c3dc3324b92f
md"""
## Multiple Return Values
"""

# ╔═╡ 03c76c6a-9e19-11eb-0f0e-013cc87e7bb9
md"""
In Julia, one returns a tuple of values to simulate returning multiple values. However, tuples can be created and destructured without needing parentheses, thereby providing an illusion that multiple values are being returned, rather than a single tuple value. For example, the following function returns a pair of values:
"""

# ╔═╡ 03c76f12-9e19-11eb-1053-473dbc90ee2b
function foo(a,b)
           a+b, a*b
       end

# ╔═╡ 03c76f28-9e19-11eb-16e0-053690d5075c
md"""
If you call it in an interactive session without assigning the return value anywhere, you will see the tuple returned:
"""

# ╔═╡ 03c77098-9e19-11eb-27a9-31fdc143079d
foo(2,3)

# ╔═╡ 03c770ac-9e19-11eb-1bcd-9f17e6ccbe06
md"""
A typical usage of such a pair of return values, however, extracts each value into a variable. Julia supports simple tuple "destructuring" that facilitates this:
"""

# ╔═╡ 03c77368-9e19-11eb-1d62-17fa07ff98e9
x, y = foo(2,3)

# ╔═╡ 03c77372-9e19-11eb-3bf5-77fb3e328253
x

# ╔═╡ 03c77372-9e19-11eb-0e3a-73fcc05733ca
y

# ╔═╡ 03c7738e-9e19-11eb-1d2c-c1ca3109f38e
md"""
You can also return multiple values using the `return` keyword:
"""

# ╔═╡ 03c773ae-9e19-11eb-2725-77ee7637d547
md"""
```julia
function foo(a,b)
    return a+b, a*b
end
```
"""

# ╔═╡ 03c773b8-9e19-11eb-0a85-11afa1df3946
md"""
This has the exact same effect as the previous definition of `foo`.
"""

# ╔═╡ 03c773cc-9e19-11eb-0fb2-793d1a347e22
md"""
## Argument destructuring
"""

# ╔═╡ 03c773e0-9e19-11eb-2834-01bc6521620e
md"""
The destructuring feature can also be used within a function argument. If a function argument name is written as a tuple (e.g. `(x, y)`) instead of just a symbol, then an assignment `(x, y) = argument` will be inserted for you:
"""

# ╔═╡ 03c773f4-9e19-11eb-34da-8316a26b716e
md"""
```julia
julia> minmax(x, y) = (y < x) ? (y, x) : (x, y)

julia> gap((min, max)) = max - min

julia> gap(minmax(10, 2))
8
```
"""

# ╔═╡ 03c77412-9e19-11eb-09e4-4de3c8b0875a
md"""
Notice the extra set of parentheses in the definition of `gap`. Without those, `gap` would be a two-argument function, and this example would not work.
"""

# ╔═╡ 03c77426-9e19-11eb-02c8-f7251bc25b5b
md"""
## Varargs Functions
"""

# ╔═╡ 03c7743a-9e19-11eb-397c-59556e53ddb8
md"""
It is often convenient to be able to write functions taking an arbitrary number of arguments. Such functions are traditionally known as "varargs" functions, which is short for "variable number of arguments". You can define a varargs function by following the last positional argument with an ellipsis:
"""

# ╔═╡ 03c7764c-9e19-11eb-2054-a59c694f9f0b
bar(a,b,x...) = (a,b,x)

# ╔═╡ 03c77674-9e19-11eb-1469-77039d9a78df
md"""
The variables `a` and `b` are bound to the first two argument values as usual, and the variable `x` is bound to an iterable collection of the zero or more values passed to `bar` after its first two arguments:
"""

# ╔═╡ 03c77b08-9e19-11eb-31d5-af9fb48c8b15
bar(1,2)

# ╔═╡ 03c77b10-9e19-11eb-37be-6b72879c72c3
bar(1,2,3)

# ╔═╡ 03c77b10-9e19-11eb-211a-f55f9886de10
bar(1, 2, 3, 4)

# ╔═╡ 03c77b1a-9e19-11eb-0610-b7065006dfeb
bar(1,2,3,4,5,6)

# ╔═╡ 03c77b3a-9e19-11eb-309d-371e5671bdd2
md"""
In all these cases, `x` is bound to a tuple of the trailing values passed to `bar`.
"""

# ╔═╡ 03c77b56-9e19-11eb-0248-ddf8f882a1aa
md"""
It is possible to constrain the number of values passed as a variable argument; this will be discussed later in [Parametrically-constrained Varargs methods](@ref).
"""

# ╔═╡ 03c77b6c-9e19-11eb-0144-c347b2311872
md"""
On the flip side, it is often handy to "splat" the values contained in an iterable collection into a function call as individual arguments. To do this, one also uses `...` but in the function call instead:
"""

# ╔═╡ 03c77e26-9e19-11eb-3c77-b37fed0d7215
x = (3, 4)

# ╔═╡ 03c77e26-9e19-11eb-3b4a-eb28b3278c61
bar(1,2,x...)

# ╔═╡ 03c77e3c-9e19-11eb-0500-69025a7117ce
md"""
In this case a tuple of values is spliced into a varargs call precisely where the variable number of arguments go. This need not be the case, however:
"""

# ╔═╡ 03c78362-9e19-11eb-001d-d56b8dd7a126
x = (2, 3, 4)

# ╔═╡ 03c7836c-9e19-11eb-31da-a7d5db0f8f66
bar(1,x...)

# ╔═╡ 03c7836c-9e19-11eb-3be8-3fa3837e80ae
x = (1, 2, 3, 4)

# ╔═╡ 03c78378-9e19-11eb-1990-fd0c5a669772
bar(x...)

# ╔═╡ 03c78380-9e19-11eb-049d-952c1ebe9b29
md"""
Furthermore, the iterable object splatted into a function call need not be a tuple:
"""

# ╔═╡ 03c78894-9e19-11eb-09a5-db2f20fabc2c
x = [3,4]

# ╔═╡ 03c78894-9e19-11eb-16dd-ed1233923fa2
bar(1,2,x...)

# ╔═╡ 03c7889e-9e19-11eb-3de4-6be70f6fc41c
x = [1,2,3,4]

# ╔═╡ 03c7889e-9e19-11eb-0269-eff2c91382ed
bar(x...)

# ╔═╡ 03c788b2-9e19-11eb-182e-a9577d277bda
md"""
Also, the function that arguments are splatted into need not be a varargs function (although it often is):
"""

# ╔═╡ 03c78ee6-9e19-11eb-2cd9-7f56d633d86b
baz(a,b) = a + b;

# ╔═╡ 03c78ef2-9e19-11eb-209c-d7a2614d78c6
args = [1,2]

# ╔═╡ 03c78ef2-9e19-11eb-072b-434a43ac04e6
baz(args...)

# ╔═╡ 03c78efc-9e19-11eb-3f2c-05e69050747c
args = [1,2,3]

# ╔═╡ 03c78efc-9e19-11eb-37d3-8535878d96cd
baz(args...)

# ╔═╡ 03c78f10-9e19-11eb-051b-99a8c10b14ef
md"""
As you can see, if the wrong number of elements are in the splatted container, then the function call will fail, just as it would if too many arguments were given explicitly.
"""

# ╔═╡ 03c78f24-9e19-11eb-1e87-8bd273871e27
md"""
## Optional Arguments
"""

# ╔═╡ 03c78f60-9e19-11eb-12ae-8b6c19421459
md"""
It is often possible to provide sensible default values for function arguments. This can save users from having to pass every argument on every call. For example, the function [`Date(y, [m, d])`](@ref) from `Dates` module constructs a `Date` type for a given year `y`, month `m` and day `d`. However, `m` and `d` arguments are optional and their default value is `1`. This behavior can be expressed concisely as:
"""

# ╔═╡ 03c78f74-9e19-11eb-30d0-3b47259513f9
md"""
```julia
function Date(y::Int64, m::Int64=1, d::Int64=1)
    err = validargs(Date, y, m, d)
    err === nothing || throw(err)
    return Date(UTD(totaldays(y, m, d)))
end
```
"""

# ╔═╡ 03c78f92-9e19-11eb-2dc0-ed669ad5b282
md"""
Observe, that this definition calls another method of the `Date` function that takes one argument of type `UTInstant{Day}`.
"""

# ╔═╡ 03c78f9c-9e19-11eb-2494-330c348e3bd2
md"""
With this definition, the function can be called with either one, two or three arguments, and `1` is automatically passed when only one or two of the arguments are specified:
"""

# ╔═╡ 03c79384-9e19-11eb-241e-87771ce6950c
using Dates

# ╔═╡ 03c79384-9e19-11eb-1fd4-439512bfc812
Date(2000, 12, 12)

# ╔═╡ 03c7938e-9e19-11eb-2f16-ed56307b3468
Date(2000, 12)

# ╔═╡ 03c7938e-9e19-11eb-3074-ffed0a134477
Date(2000)

# ╔═╡ 03c793b6-9e19-11eb-2e8b-dfc8a0973fe2
md"""
Optional arguments are actually just a convenient syntax for writing multiple method definitions with different numbers of arguments (see [Note on Optional and keyword Arguments](@ref)). This can be checked for our `Date` function example by calling `methods` function.
"""

# ╔═╡ 03c793ca-9e19-11eb-16db-5f007e3ea5fe
md"""
## Keyword Arguments
"""

# ╔═╡ 03c793de-9e19-11eb-185e-674e7435e4bd
md"""
Some functions need a large number of arguments, or have a large number of behaviors. Remembering how to call such functions can be difficult. Keyword arguments can make these complex interfaces easier to use and extend by allowing arguments to be identified by name instead of only by position.
"""

# ╔═╡ 03c793fc-9e19-11eb-3f73-8975219d2a86
md"""
For example, consider a function `plot` that plots a line. This function might have many options, for controlling line style, width, color, and so on. If it accepts keyword arguments, a possible call might look like `plot(x, y, width=2)`, where we have chosen to specify only line width. Notice that this serves two purposes. The call is easier to read, since we can label an argument with its meaning. It also becomes possible to pass any subset of a large number of arguments, in any order.
"""

# ╔═╡ 03c79410-9e19-11eb-301d-6b5b37ce99bf
md"""
Functions with keyword arguments are defined using a semicolon in the signature:
"""

# ╔═╡ 03c79426-9e19-11eb-21c1-f11522a5514d
md"""
```julia
function plot(x, y; style="solid", width=1, color="black")
    ###
end
```
"""

# ╔═╡ 03c79442-9e19-11eb-126c-57e0f408349c
md"""
When the function is called, the semicolon is optional: one can either call `plot(x, y, width=2)` or `plot(x, y; width=2)`, but the former style is more common. An explicit semicolon is required only for passing varargs or computed keywords as described below.
"""

# ╔═╡ 03c7944c-9e19-11eb-3c39-4f5780b442fc
md"""
Keyword argument default values are evaluated only when necessary (when a corresponding keyword argument is not passed), and in left-to-right order. Therefore default expressions may refer to prior keyword arguments.
"""

# ╔═╡ 03c79454-9e19-11eb-1374-a52002451609
md"""
The types of keyword arguments can be made explicit as follows:
"""

# ╔═╡ 03c79474-9e19-11eb-144e-ab06c79721b7
md"""
```julia
function f(;x::Int=1)
    ###
end
```
"""

# ╔═╡ 03c7947e-9e19-11eb-0b91-b17b58d231a7
md"""
Keyword arguments can also be used in varargs functions:
"""

# ╔═╡ 03c79492-9e19-11eb-3109-77567b71997d
md"""
```julia
function plot(x...; style="solid")
    ###
end
```
"""

# ╔═╡ 03c794a6-9e19-11eb-0db9-83347bd5a660
md"""
Extra keyword arguments can be collected using `...`, as in varargs functions:
"""

# ╔═╡ 03c794b8-9e19-11eb-0cf3-313745abe270
md"""
```julia
function f(x; y=0, kwargs...)
    ###
end
```
"""

# ╔═╡ 03c794d8-9e19-11eb-193a-13256c660b8c
md"""
Inside `f`, `kwargs` will be an immutable key-value iterator over a named tuple. Named tuples (as well as dictionaries with keys of `Symbol`) can be passed as keyword arguments using a semicolon in a call, e.g. `f(x, z=1; kwargs...)`.
"""

# ╔═╡ 03c794f6-9e19-11eb-2ef5-5371c976b465
md"""
If a keyword argument is not assigned a default value in the method definition, then it is *required*: an [`UndefKeywordError`](@ref) exception will be thrown if the caller does not assign it a value:
"""

# ╔═╡ 03c7950a-9e19-11eb-344b-a702faa4c9f2
md"""
```julia
function f(x; y)
    ###
end
f(3, y=5) # ok, y is assigned
f(3)      # throws UndefKeywordError(:y)
```
"""

# ╔═╡ 03c7952a-9e19-11eb-3357-37d2e4b505b9
md"""
One can also pass `key => value` expressions after a semicolon. For example, `plot(x, y; :width => 2)` is equivalent to `plot(x, y, width=2)`. This is useful in situations where the keyword name is computed at runtime.
"""

# ╔═╡ 03c79546-9e19-11eb-21ca-55a1525a90fa
md"""
When a bare identifier or dot expression occurs after a semicolon, the keyword argument name is implied by the identifier or field name. For example `plot(x, y; width)` is equivalent to `plot(x, y; width=width)` and `plot(x, y; options.width)` is equivalent to `plot(x, y; width=options.width)`.
"""

# ╔═╡ 03c79564-9e19-11eb-0c72-81bb4f5d3e0c
md"""
The nature of keyword arguments makes it possible to specify the same argument more than once. For example, in the call `plot(x, y; options..., width=2)` it is possible that the `options` structure also contains a value for `width`. In such a case the rightmost occurrence takes precedence; in this example, `width` is certain to have the value `2`. However, explicitly specifying the same keyword argument multiple times, for example `plot(x, y, width=2, width=3)`, is not allowed and results in a syntax error.
"""

# ╔═╡ 03c79578-9e19-11eb-09a5-2b9089f1ef34
md"""
## Evaluation Scope of Default Values
"""

# ╔═╡ 03c7958e-9e19-11eb-084b-0bc8fe02a43a
md"""
When optional and keyword argument default expressions are evaluated, only *previous* arguments are in scope. For example, given this definition:
"""

# ╔═╡ 03c795a0-9e19-11eb-028c-8ba375536ddb
md"""
```julia
function f(x, a=b, b=1)
    ###
end
```
"""

# ╔═╡ 03c795b4-9e19-11eb-168c-67fe60de633b
md"""
the `b` in `a=b` refers to a `b` in an outer scope, not the subsequent argument `b`.
"""

# ╔═╡ 03c795c8-9e19-11eb-3d8f-0fd395eb7dc9
md"""
## Do-Block Syntax for Function Arguments
"""

# ╔═╡ 03c795dc-9e19-11eb-35fe-7ba67c89aa85
md"""
Passing functions as arguments to other functions is a powerful technique, but the syntax for it is not always convenient. Such calls are especially awkward to write when the function argument requires multiple lines. As an example, consider calling [`map`](@ref) on a function with several cases:
"""

# ╔═╡ 03c795ee-9e19-11eb-263d-4d61d3dff179
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

# ╔═╡ 03c7960e-9e19-11eb-2ae4-9ff2fb434349
md"""
Julia provides a reserved word `do` for rewriting this code more clearly:
"""

# ╔═╡ 03c79620-9e19-11eb-030c-5563cf29eb10
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

# ╔═╡ 03c7964a-9e19-11eb-09e3-a5321208aba8
md"""
The `do x` syntax creates an anonymous function with argument `x` and passes it as the first argument to [`map`](@ref). Similarly, `do a,b` would create a two-argument anonymous function, and a plain `do` would declare that what follows is an anonymous function of the form `() -> ...`.
"""

# ╔═╡ 03c79668-9e19-11eb-2320-91047ae0074a
md"""
How these arguments are initialized depends on the "outer" function; here, [`map`](@ref) will sequentially set `x` to `A`, `B`, `C`, calling the anonymous function on each, just as would happen in the syntax `map(func, [A, B, C])`.
"""

# ╔═╡ 03c79686-9e19-11eb-11ca-a12c265dc779
md"""
This syntax makes it easier to use functions to effectively extend the language, since calls look like normal code blocks. There are many possible uses quite different from [`map`](@ref), such as managing system state. For example, there is a version of [`open`](@ref) that runs code ensuring that the opened file is eventually closed:
"""

# ╔═╡ 03c7969a-9e19-11eb-10b4-11294038190e
md"""
```julia
open("outfile", "w") do io
    write(io, data)
end
```
"""

# ╔═╡ 03c796a4-9e19-11eb-348c-a7611e5c17d8
md"""
This is accomplished by the following definition:
"""

# ╔═╡ 03c796b8-9e19-11eb-14dc-b1b771c770cc
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

# ╔═╡ 03c796ea-9e19-11eb-183f-1ff521f7d9e3
md"""
Here, [`open`](@ref) first opens the file for writing and then passes the resulting output stream to the anonymous function you defined in the `do ... end` block. After your function exits, [`open`](@ref) will make sure that the stream is properly closed, regardless of whether your function exited normally or threw an exception. (The `try/finally` construct will be described in [Control Flow](@ref).)
"""

# ╔═╡ 03c796fe-9e19-11eb-3881-dd2a00d10cb6
md"""
With the `do` block syntax, it helps to check the documentation or implementation to know how the arguments of the user function are initialized.
"""

# ╔═╡ 03c7971c-9e19-11eb-26a0-39c8acc82b12
md"""
A `do` block, like any other inner function, can "capture" variables from its enclosing scope. For example, the variable `data` in the above example of `open...do` is captured from the outer scope. Captured variables can create performance challenges as discussed in [performance tips](@ref man-performance-captured).
"""

# ╔═╡ 03c79724-9e19-11eb-2263-35e287cf9a7b
md"""
## Function composition and piping
"""

# ╔═╡ 03c7973a-9e19-11eb-2f74-490f8b5e5380
md"""
Functions in Julia can be combined by composing or piping (chaining) them together.
"""

# ╔═╡ 03c7974e-9e19-11eb-0b98-41d6e51a90a9
md"""
Function composition is when you combine functions together and apply the resulting composition to arguments. You use the function composition operator (`∘`) to compose the functions, so `(f ∘ g)(args...)` is the same as `f(g(args...))`.
"""

# ╔═╡ 03c79762-9e19-11eb-0ea2-ebf11510dc5c
md"""
You can type the composition operator at the REPL and suitably-configured editors using `\circ<tab>`.
"""

# ╔═╡ 03c79780-9e19-11eb-3ada-8fcfce3ca72b
md"""
For example, the `sqrt` and `+` functions can be composed like this:
"""

# ╔═╡ 03c79988-9e19-11eb-219f-39b3df5cce1f
(sqrt ∘ +)(3, 6)

# ╔═╡ 03c79994-9e19-11eb-36bb-df190a9d0b49
md"""
This adds the numbers first, then finds the square root of the result.
"""

# ╔═╡ 03c799a6-9e19-11eb-1046-11fa08e34b91
md"""
The next example composes three functions and maps the result over an array of strings:
"""

# ╔═╡ 03c79c76-9e19-11eb-0a42-af20d822827a
map(first ∘ reverse ∘ uppercase, split("you can compose functions like this"))

# ╔═╡ 03c79c8a-9e19-11eb-1713-a9af321172dd
md"""
Function chaining (sometimes called "piping" or "using a pipe" to send data to a subsequent function) is when you apply a function to the previous function's output:
"""

# ╔═╡ 03c79e6a-9e19-11eb-1f6e-bdc1baa9133d
1:10 |> sum |> sqrt

# ╔═╡ 03c79e88-9e19-11eb-2d1a-bfdf477b9deb
md"""
Here, the total produced by `sum` is passed to the `sqrt` function. The equivalent composition would be:
"""

# ╔═╡ 03c7a098-9e19-11eb-3c59-53a040dd2c4c
(sqrt ∘ sum)(1:10)

# ╔═╡ 03c7a0b8-9e19-11eb-2adb-2d822b09c43e
md"""
The pipe operator can also be used with broadcasting, as `.|>`, to provide a useful combination of the chaining/piping and dot vectorization syntax (described next).
"""

# ╔═╡ 03c7a3c4-9e19-11eb-32a2-693c8af65cf6
["a", "list", "of", "strings"] .|> [uppercase, reverse, titlecase, length]

# ╔═╡ 03c7a3e2-9e19-11eb-12fb-e986206a288e
md"""
## [Dot Syntax for Vectorizing Functions](@id man-vectorized)
"""

# ╔═╡ 03c7a41e-9e19-11eb-36f0-714c621a45ff
md"""
In technical-computing languages, it is common to have "vectorized" versions of functions, which simply apply a given function `f(x)` to each element of an array `A` to yield a new array via `f(A)`. This kind of syntax is convenient for data processing, but in other languages vectorization is also often required for performance: if loops are slow, the "vectorized" version of a function can call fast library code written in a low-level language. In Julia, vectorized functions are *not* required for performance, and indeed it is often beneficial to write your own loops (see [Performance Tips](@ref man-performance-tips)), but they can still be convenient. Therefore, *any* Julia function `f` can be applied elementwise to any array (or other collection) with the syntax `f.(A)`. For example, `sin` can be applied to all elements in the vector `A` like so:
"""

# ╔═╡ 03c7a6da-9e19-11eb-0a5f-8d71856d9345
A = [1.0, 2.0, 3.0]

# ╔═╡ 03c7a6da-9e19-11eb-1888-39fa2fb95591
sin.(A)

# ╔═╡ 03c7a702-9e19-11eb-1014-316b9bc87f76
md"""
Of course, you can omit the dot if you write a specialized "vector" method of `f`, e.g. via `f(A::AbstractArray) = map(f, A)`, and this is just as efficient as `f.(A)`. The advantage of the `f.(A)` syntax is that which functions are vectorizable need not be decided upon in advance by the library writer.
"""

# ╔═╡ 03c7a740-9e19-11eb-3e59-e3210ad77f1c
md"""
More generally, `f.(args...)` is actually equivalent to `broadcast(f, args...)`, which allows you to operate on multiple arrays (even of different shapes), or a mix of arrays and scalars (see [Broadcasting](@ref)). For example, if you have `f(x,y) = 3x + 4y`, then `f.(pi,A)` will return a new array consisting of `f(pi,a)` for each `a` in `A`, and `f.(vector1,vector2)` will return a new vector consisting of `f(vector1[i],vector2[i])` for each index `i` (throwing an exception if the vectors have different length).
"""

# ╔═╡ 03c7ae0a-9e19-11eb-370e-b1190adffd0a
f(x,y) = 3x + 4y;

# ╔═╡ 03c7ae0a-9e19-11eb-0f0f-a1ac0e4f92c4
A = [1.0, 2.0, 3.0];

# ╔═╡ 03c7ae16-9e19-11eb-1ebd-a7277e3e6f1d
B = [4.0, 5.0, 6.0];

# ╔═╡ 03c7ae1e-9e19-11eb-1472-1fd943636b87
f.(pi, A)

# ╔═╡ 03c7ae28-9e19-11eb-3597-bbbbd30e62ab
f.(A, B)

# ╔═╡ 03c7ae82-9e19-11eb-0ac8-13056c4ff08c
md"""
Moreover, *nested* `f.(args...)` calls are *fused* into a single `broadcast` loop. For example, `sin.(cos.(X))` is equivalent to `broadcast(x -> sin(cos(x)), X)`, similar to `[sin(cos(x)) for x in X]`: there is only a single loop over `X`, and a single array is allocated for the result. [In contrast, `sin(cos(X))` in a typical "vectorized" language would first allocate one temporary array for `tmp=cos(X)`, and then compute `sin(tmp)` in a separate loop, allocating a second array.] This loop fusion is not a compiler optimization that may or may not occur, it is a *syntactic guarantee* whenever nested `f.(args...)` calls are encountered. Technically, the fusion stops as soon as a "non-dot" function call is encountered; for example, in `sin.(sort(cos.(X)))` the `sin` and `cos` loops cannot be merged because of the intervening `sort` function.
"""

# ╔═╡ 03c7aebe-9e19-11eb-1757-a924f73514e5
md"""
Finally, the maximum efficiency is typically achieved when the output array of a vectorized operation is *pre-allocated*, so that repeated calls do not allocate new arrays over and over again for the results (see [Pre-allocating outputs](@ref)). A convenient syntax for this is `X .= ...`, which is equivalent to `broadcast!(identity, X, ...)` except that, as above, the `broadcast!` loop is fused with any nested "dot" calls. For example, `X .= sin.(Y)` is equivalent to `broadcast!(sin, X, Y)`, overwriting `X` with `sin.(Y)` in-place. If the left-hand side is an array-indexing expression, e.g. `X[begin+1:end] .= sin.(Y)`, then it translates to `broadcast!` on a `view`, e.g. `broadcast!(sin, view(X, firstindex(X)+1:lastindex(X)), Y)`, so that the left-hand side is updated in-place.
"""

# ╔═╡ 03c7aedc-9e19-11eb-1d95-d3d5e4ba662e
md"""
Since adding dots to many operations and function calls in an expression can be tedious and lead to code that is difficult to read, the macro [`@.`](@ref @__dot__) is provided to convert *every* function call, operation, and assignment in an expression into the "dotted" version.
"""

# ╔═╡ 03c7b448-9e19-11eb-36e5-eb0d603a8c66
Y = [1.0, 2.0, 3.0, 4.0];

# ╔═╡ 03c7b454-9e19-11eb-071f-4be01273c98d
X = similar(Y); # pre-allocate output array

# ╔═╡ 03c7b45e-9e19-11eb-274d-ef5d5bd4e777
@. X = sin(cos(Y)) # equivalent to X .= sin.(cos.(Y))

# ╔═╡ 03c7b486-9e19-11eb-3b4e-f38be9769ebb
md"""
Binary (or unary) operators like `.+` are handled with the same mechanism: they are equivalent to `broadcast` calls and are fused with other nested "dot" calls.  `X .+= Y` etcetera is equivalent to `X .= X .+ Y` and results in a fused in-place assignment;  see also [dot operators](@ref man-dot-operators).
"""

# ╔═╡ 03c7b4a4-9e19-11eb-2157-6b9d05f5cf3f
md"""
You can also combine dot operations with function chaining using [`|>`](@ref), as in this example:
"""

# ╔═╡ 03c7b972-9e19-11eb-16f6-51476acb80d6
[1:5;] .|> [x->x^2, inv, x->2*x, -, isodd]

# ╔═╡ 03c7b984-9e19-11eb-084f-8398c3d87e85
md"""
## Further Reading
"""

# ╔═╡ 03c7b9ae-9e19-11eb-2f3c-11946ee8b734
md"""
We should mention here that this is far from a complete picture of defining functions. Julia has a sophisticated type system and allows multiple dispatch on argument types. None of the examples given here provide any type annotations on their arguments, meaning that they are applicable to all types of arguments. The type system is described in [Types](@ref man-types) and defining a function in terms of methods chosen by multiple dispatch on run-time argument types is described in [Methods](@ref).
"""

# ╔═╡ Cell order:
# ╟─03c70c34-9e19-11eb-3215-e1b7038588b6
# ╟─03c70c84-9e19-11eb-24cf-6f18b15e467a
# ╠═03c712d8-9e19-11eb-3a9b-b3ebe7ce1ae4
# ╟─03c71328-9e19-11eb-38d7-e5a2bccf884e
# ╟─03c71348-9e19-11eb-0f5b-839415430e9d
# ╠═03c71508-9e19-11eb-05bd-4d369f832177
# ╟─03c71544-9e19-11eb-1323-3de1aa4abf6e
# ╟─03c71562-9e19-11eb-10ce-830b5d86340b
# ╠═03c71706-9e19-11eb-187e-1bc1edbac39d
# ╟─03c71724-9e19-11eb-150e-f5611fbba462
# ╠═03c71948-9e19-11eb-3d6c-839d8e69df9b
# ╠═03c71968-9e19-11eb-2b3d-6540c2551acf
# ╟─03c719ae-9e19-11eb-0f75-c9af9b7d7ecf
# ╠═03c71ca6-9e19-11eb-192b-bdb722f39fc9
# ╠═03c71cbc-9e19-11eb-3be2-5f2086f282a4
# ╟─03c71d0a-9e19-11eb-0250-bdebd7a17eaf
# ╟─03c71d8c-9e19-11eb-2f3e-3f81b905b146
# ╟─03c71dd2-9e19-11eb-3737-13a8f283b7a9
# ╟─03c71e18-9e19-11eb-185d-096a78bd9fd7
# ╟─03c71e68-9e19-11eb-2a36-6bc5154137a0
# ╟─03c71e7c-9e19-11eb-1b95-53b20d25284b
# ╠═03c724e4-9e19-11eb-11cd-4744365572ed
# ╠═03c724ee-9e19-11eb-2e16-27044f8eba3c
# ╠═03c724fa-9e19-11eb-3ba0-e992a2d0872c
# ╠═03c72528-9e19-11eb-041d-313da7d71c4c
# ╟─03c72570-9e19-11eb-05b8-0f4941b47f3d
# ╠═03c736ac-9e19-11eb-30e4-a5fce66b4a48
# ╠═03c736b4-9e19-11eb-3cd2-e3d797baa707
# ╟─03c7370c-9e19-11eb-3123-3d460b2f1a56
# ╟─03c7375e-9e19-11eb-1651-9bfcf8c7b471
# ╟─03c7379a-9e19-11eb-2a05-8939ccf16b6c
# ╠═03c73dee-9e19-11eb-17ba-c3c83208bf56
# ╠═03c73df8-9e19-11eb-081c-a16e3e152b66
# ╟─03c73e46-9e19-11eb-141b-61ca90f84162
# ╟─03c73e5c-9e19-11eb-3bc7-af5e59e44e63
# ╟─03c73e84-9e19-11eb-1dc2-838aa09eb0a8
# ╟─03c73eb8-9e19-11eb-2778-f512f2a10c60
# ╟─03c73ef2-9e19-11eb-07df-b587be1a7e9a
# ╟─03c73f2e-9e19-11eb-1065-ad2a45d6f55e
# ╟─03c73f4a-9e19-11eb-2db6-635704bfe403
# ╟─03c73f7c-9e19-11eb-26f3-6986cffdb2b9
# ╠═03c74280-9e19-11eb-27e4-a10f73f506cc
# ╠═03c7428a-9e19-11eb-0ef5-f91ec8232cbc
# ╟─03c742c6-9e19-11eb-3ff1-91fc3215af73
# ╠═03c7450a-9e19-11eb-0540-e1c6095e9e20
# ╠═03c74514-9e19-11eb-002e-4fa68cf147e7
# ╟─03c74546-9e19-11eb-04d9-07f26ddfbd96
# ╟─03c74564-9e19-11eb-1c59-038ea4bc5868
# ╟─03c74578-9e19-11eb-37a9-2d87b5ea97a2
# ╟─03c748b6-9e19-11eb-1d6f-db1d13f7395e
# ╟─03c74906-9e19-11eb-3ccb-1f282b1dcfd5
# ╟─03c74942-9e19-11eb-0e00-bf31e14b55a7
# ╠═03c7573e-9e19-11eb-0d0c-91ec1d2bba9f
# ╠═03c75752-9e19-11eb-3de0-3b830fdaebf3
# ╟─03c757de-9e19-11eb-34d3-3ba8d0b10f4e
# ╟─03c7584c-9e19-11eb-27d4-d9e325b6c48b
# ╠═03c75b1c-9e19-11eb-0e1d-8f6e53b7bbb1
# ╟─03c75b4e-9e19-11eb-1442-2d6f3e8a19cb
# ╠═03c75fb0-9e19-11eb-29d9-d5f0d1f4bf51
# ╟─03c75fd6-9e19-11eb-2384-59f64eab9652
# ╟─03c75ff4-9e19-11eb-22a6-174ce681c8e4
# ╟─03c76030-9e19-11eb-2f69-23c0e3bad98c
# ╟─03c7604e-9e19-11eb-11a6-d177c7ef5beb
# ╟─03c76062-9e19-11eb-39b1-0bc7857c8d5e
# ╟─03c7608a-9e19-11eb-3990-b96252746d19
# ╟─03c760a8-9e19-11eb-06ec-5b3b1fcf3c13
# ╟─03c760d0-9e19-11eb-0f7d-617e929735db
# ╠═03c76738-9e19-11eb-2659-2104fa53de4f
# ╠═03c76742-9e19-11eb-0a2f-c56b93ac7f05
# ╠═03c76742-9e19-11eb-110e-51ed61b1ecc6
# ╠═03c7674a-9e19-11eb-0117-edd06729eb9e
# ╟─03c7676a-9e19-11eb-32b7-cf2326f411c9
# ╟─03c7677c-9e19-11eb-24a9-c31d1f0dec28
# ╟─03c7679c-9e19-11eb-31a7-ad4c25012a36
# ╠═03c76c1a-9e19-11eb-2e05-e98f5f94f23d
# ╠═03c76c26-9e19-11eb-1bba-85030faa47dc
# ╠═03c76c26-9e19-11eb-0a5f-71818abd0d19
# ╟─03c76c42-9e19-11eb-0dc0-73298066d3a2
# ╟─03c76c58-9e19-11eb-2b1f-c3dc3324b92f
# ╟─03c76c6a-9e19-11eb-0f0e-013cc87e7bb9
# ╠═03c76f12-9e19-11eb-1053-473dbc90ee2b
# ╟─03c76f28-9e19-11eb-16e0-053690d5075c
# ╠═03c77098-9e19-11eb-27a9-31fdc143079d
# ╟─03c770ac-9e19-11eb-1bcd-9f17e6ccbe06
# ╠═03c77368-9e19-11eb-1d62-17fa07ff98e9
# ╠═03c77372-9e19-11eb-3bf5-77fb3e328253
# ╠═03c77372-9e19-11eb-0e3a-73fcc05733ca
# ╟─03c7738e-9e19-11eb-1d2c-c1ca3109f38e
# ╟─03c773ae-9e19-11eb-2725-77ee7637d547
# ╟─03c773b8-9e19-11eb-0a85-11afa1df3946
# ╟─03c773cc-9e19-11eb-0fb2-793d1a347e22
# ╟─03c773e0-9e19-11eb-2834-01bc6521620e
# ╟─03c773f4-9e19-11eb-34da-8316a26b716e
# ╟─03c77412-9e19-11eb-09e4-4de3c8b0875a
# ╟─03c77426-9e19-11eb-02c8-f7251bc25b5b
# ╟─03c7743a-9e19-11eb-397c-59556e53ddb8
# ╠═03c7764c-9e19-11eb-2054-a59c694f9f0b
# ╟─03c77674-9e19-11eb-1469-77039d9a78df
# ╠═03c77b08-9e19-11eb-31d5-af9fb48c8b15
# ╠═03c77b10-9e19-11eb-37be-6b72879c72c3
# ╠═03c77b10-9e19-11eb-211a-f55f9886de10
# ╠═03c77b1a-9e19-11eb-0610-b7065006dfeb
# ╟─03c77b3a-9e19-11eb-309d-371e5671bdd2
# ╟─03c77b56-9e19-11eb-0248-ddf8f882a1aa
# ╟─03c77b6c-9e19-11eb-0144-c347b2311872
# ╠═03c77e26-9e19-11eb-3c77-b37fed0d7215
# ╠═03c77e26-9e19-11eb-3b4a-eb28b3278c61
# ╟─03c77e3c-9e19-11eb-0500-69025a7117ce
# ╠═03c78362-9e19-11eb-001d-d56b8dd7a126
# ╠═03c7836c-9e19-11eb-31da-a7d5db0f8f66
# ╠═03c7836c-9e19-11eb-3be8-3fa3837e80ae
# ╠═03c78378-9e19-11eb-1990-fd0c5a669772
# ╟─03c78380-9e19-11eb-049d-952c1ebe9b29
# ╠═03c78894-9e19-11eb-09a5-db2f20fabc2c
# ╠═03c78894-9e19-11eb-16dd-ed1233923fa2
# ╠═03c7889e-9e19-11eb-3de4-6be70f6fc41c
# ╠═03c7889e-9e19-11eb-0269-eff2c91382ed
# ╟─03c788b2-9e19-11eb-182e-a9577d277bda
# ╠═03c78ee6-9e19-11eb-2cd9-7f56d633d86b
# ╠═03c78ef2-9e19-11eb-209c-d7a2614d78c6
# ╠═03c78ef2-9e19-11eb-072b-434a43ac04e6
# ╠═03c78efc-9e19-11eb-3f2c-05e69050747c
# ╠═03c78efc-9e19-11eb-37d3-8535878d96cd
# ╟─03c78f10-9e19-11eb-051b-99a8c10b14ef
# ╟─03c78f24-9e19-11eb-1e87-8bd273871e27
# ╟─03c78f60-9e19-11eb-12ae-8b6c19421459
# ╟─03c78f74-9e19-11eb-30d0-3b47259513f9
# ╟─03c78f92-9e19-11eb-2dc0-ed669ad5b282
# ╟─03c78f9c-9e19-11eb-2494-330c348e3bd2
# ╠═03c79384-9e19-11eb-241e-87771ce6950c
# ╠═03c79384-9e19-11eb-1fd4-439512bfc812
# ╠═03c7938e-9e19-11eb-2f16-ed56307b3468
# ╠═03c7938e-9e19-11eb-3074-ffed0a134477
# ╟─03c793b6-9e19-11eb-2e8b-dfc8a0973fe2
# ╟─03c793ca-9e19-11eb-16db-5f007e3ea5fe
# ╟─03c793de-9e19-11eb-185e-674e7435e4bd
# ╟─03c793fc-9e19-11eb-3f73-8975219d2a86
# ╟─03c79410-9e19-11eb-301d-6b5b37ce99bf
# ╟─03c79426-9e19-11eb-21c1-f11522a5514d
# ╟─03c79442-9e19-11eb-126c-57e0f408349c
# ╟─03c7944c-9e19-11eb-3c39-4f5780b442fc
# ╟─03c79454-9e19-11eb-1374-a52002451609
# ╟─03c79474-9e19-11eb-144e-ab06c79721b7
# ╟─03c7947e-9e19-11eb-0b91-b17b58d231a7
# ╟─03c79492-9e19-11eb-3109-77567b71997d
# ╟─03c794a6-9e19-11eb-0db9-83347bd5a660
# ╟─03c794b8-9e19-11eb-0cf3-313745abe270
# ╟─03c794d8-9e19-11eb-193a-13256c660b8c
# ╟─03c794f6-9e19-11eb-2ef5-5371c976b465
# ╟─03c7950a-9e19-11eb-344b-a702faa4c9f2
# ╟─03c7952a-9e19-11eb-3357-37d2e4b505b9
# ╟─03c79546-9e19-11eb-21ca-55a1525a90fa
# ╟─03c79564-9e19-11eb-0c72-81bb4f5d3e0c
# ╟─03c79578-9e19-11eb-09a5-2b9089f1ef34
# ╟─03c7958e-9e19-11eb-084b-0bc8fe02a43a
# ╟─03c795a0-9e19-11eb-028c-8ba375536ddb
# ╟─03c795b4-9e19-11eb-168c-67fe60de633b
# ╟─03c795c8-9e19-11eb-3d8f-0fd395eb7dc9
# ╟─03c795dc-9e19-11eb-35fe-7ba67c89aa85
# ╟─03c795ee-9e19-11eb-263d-4d61d3dff179
# ╟─03c7960e-9e19-11eb-2ae4-9ff2fb434349
# ╟─03c79620-9e19-11eb-030c-5563cf29eb10
# ╟─03c7964a-9e19-11eb-09e3-a5321208aba8
# ╟─03c79668-9e19-11eb-2320-91047ae0074a
# ╟─03c79686-9e19-11eb-11ca-a12c265dc779
# ╟─03c7969a-9e19-11eb-10b4-11294038190e
# ╟─03c796a4-9e19-11eb-348c-a7611e5c17d8
# ╟─03c796b8-9e19-11eb-14dc-b1b771c770cc
# ╟─03c796ea-9e19-11eb-183f-1ff521f7d9e3
# ╟─03c796fe-9e19-11eb-3881-dd2a00d10cb6
# ╟─03c7971c-9e19-11eb-26a0-39c8acc82b12
# ╟─03c79724-9e19-11eb-2263-35e287cf9a7b
# ╟─03c7973a-9e19-11eb-2f74-490f8b5e5380
# ╟─03c7974e-9e19-11eb-0b98-41d6e51a90a9
# ╟─03c79762-9e19-11eb-0ea2-ebf11510dc5c
# ╟─03c79780-9e19-11eb-3ada-8fcfce3ca72b
# ╠═03c79988-9e19-11eb-219f-39b3df5cce1f
# ╟─03c79994-9e19-11eb-36bb-df190a9d0b49
# ╟─03c799a6-9e19-11eb-1046-11fa08e34b91
# ╠═03c79c76-9e19-11eb-0a42-af20d822827a
# ╟─03c79c8a-9e19-11eb-1713-a9af321172dd
# ╠═03c79e6a-9e19-11eb-1f6e-bdc1baa9133d
# ╟─03c79e88-9e19-11eb-2d1a-bfdf477b9deb
# ╠═03c7a098-9e19-11eb-3c59-53a040dd2c4c
# ╟─03c7a0b8-9e19-11eb-2adb-2d822b09c43e
# ╠═03c7a3c4-9e19-11eb-32a2-693c8af65cf6
# ╟─03c7a3e2-9e19-11eb-12fb-e986206a288e
# ╟─03c7a41e-9e19-11eb-36f0-714c621a45ff
# ╠═03c7a6da-9e19-11eb-0a5f-8d71856d9345
# ╠═03c7a6da-9e19-11eb-1888-39fa2fb95591
# ╟─03c7a702-9e19-11eb-1014-316b9bc87f76
# ╟─03c7a740-9e19-11eb-3e59-e3210ad77f1c
# ╠═03c7ae0a-9e19-11eb-370e-b1190adffd0a
# ╠═03c7ae0a-9e19-11eb-0f0f-a1ac0e4f92c4
# ╠═03c7ae16-9e19-11eb-1ebd-a7277e3e6f1d
# ╠═03c7ae1e-9e19-11eb-1472-1fd943636b87
# ╠═03c7ae28-9e19-11eb-3597-bbbbd30e62ab
# ╟─03c7ae82-9e19-11eb-0ac8-13056c4ff08c
# ╟─03c7aebe-9e19-11eb-1757-a924f73514e5
# ╟─03c7aedc-9e19-11eb-1d95-d3d5e4ba662e
# ╠═03c7b448-9e19-11eb-36e5-eb0d603a8c66
# ╠═03c7b454-9e19-11eb-071f-4be01273c98d
# ╠═03c7b45e-9e19-11eb-274d-ef5d5bd4e777
# ╟─03c7b486-9e19-11eb-3b4e-f38be9769ebb
# ╟─03c7b4a4-9e19-11eb-2157-6b9d05f5cf3f
# ╠═03c7b972-9e19-11eb-16f6-51476acb80d6
# ╟─03c7b984-9e19-11eb-084f-8398c3d87e85
# ╟─03c7b9ae-9e19-11eb-2f3c-11946ee8b734
