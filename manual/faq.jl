### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ 03c47078-9e19-11eb-1ef0-310277eded72
md"""
# Frequently Asked Questions
"""

# ╔═╡ 03c470be-9e19-11eb-2516-45137204526e
md"""
## General
"""

# ╔═╡ 03c470f8-9e19-11eb-0f3f-a7b91dda0c70
md"""
### Is Julia named after someone or something?
"""

# ╔═╡ 03c47122-9e19-11eb-3ecb-6fce6545ab21
md"""
No.
"""

# ╔═╡ 03c47136-9e19-11eb-0a65-15e1e3db7251
md"""
### Why don't you compile Matlab/Python/R/… code to Julia?
"""

# ╔═╡ 03c4714a-9e19-11eb-2c5d-378bb9e5c2dd
md"""
Since many people are familiar with the syntax of other dynamic languages, and lots of code has already been written in those languages, it is natural to wonder why we didn't just plug a Matlab or Python front-end into a Julia back-end (or “transpile” code to Julia) in order to get all the performance benefits of Julia without requiring programmers to learn a new language.  Simple, right?
"""

# ╔═╡ 03c471e0-9e19-11eb-18bb-f358f13b5252
md"""
The basic issue is that there is *nothing special about Julia's compiler*: we use a commonplace compiler (LLVM) with no “secret sauce” that other language developers don't know about.  Indeed, Julia's compiler is in many ways much simpler than those of other dynamic languages (e.g. PyPy or LuaJIT).   Julia's performance advantage derives almost entirely from its front-end: its language semantics allow a [well-written Julia program](@ref man-performance-tips) to *give more opportunities to the compiler* to generate efficient code and memory layouts.  If you tried to compile Matlab or Python code to Julia, our compiler would be limited by the semantics of Matlab or Python to producing code no better than that of existing compilers for those languages (and probably worse).  The key role of semantics is also why several existing Python compilers (like Numba and Pythran) only attempt to optimize a small subset of the language (e.g. operations on Numpy arrays and scalars), and for this subset they are already doing at least as well as we could for the same semantics.  The people working on those projects are incredibly smart and have accomplished amazing things, but retrofitting a compiler onto a language that was designed to be interpreted is a very difficult problem.
"""

# ╔═╡ 03c471fc-9e19-11eb-0328-03566eec4950
md"""
Julia's advantage is that good performance is not limited to a small subset of “built-in” types and operations, and one can write high-level type-generic code that works on arbitrary user-defined types while remaining fast and memory-efficient.  Types in languages like Python simply don't provide enough information to the compiler for similar capabilities, so as soon as you used those languages as a Julia front-end you would be stuck.
"""

# ╔═╡ 03c47212-9e19-11eb-1802-d3e2f8650010
md"""
For similar reasons, automated translation to Julia would also typically generate unreadable, slow, non-idiomatic code that would not be a good starting point for a native Julia port from another language.
"""

# ╔═╡ 03c47244-9e19-11eb-320e-d789bb846b3e
md"""
On the other hand, language *interoperability* is extremely useful: we want to exploit existing high-quality code in other languages from Julia (and vice versa)!  The best way to enable this is not a transpiler, but rather via easy inter-language calling facilities.  We have worked hard on this, from the built-in `ccall` intrinsic (to call C and Fortran libraries) to [JuliaInterop](https://github.com/JuliaInterop) packages that connect Julia to Python, Matlab, C++, and more.
"""

# ╔═╡ 03c47258-9e19-11eb-05e1-bd7f86b8703e
md"""
## Sessions and the REPL
"""

# ╔═╡ 03c4726c-9e19-11eb-2148-eb93bd4831e7
md"""
### How do I delete an object in memory?
"""

# ╔═╡ 03c472b2-9e19-11eb-03e8-8b398e204504
md"""
Julia does not have an analog of MATLAB's `clear` function; once a name is defined in a Julia session (technically, in module `Main`), it is always present.
"""

# ╔═╡ 03c472e4-9e19-11eb-1701-17f014579a2e
md"""
If memory usage is your concern, you can always replace objects with ones that consume less memory.  For example, if `A` is a gigabyte-sized array that you no longer need, you can free the memory with `A = nothing`.  The memory will be released the next time the garbage collector runs; you can force this to happen with [`GC.gc()`](@ref Base.GC.gc). Moreover, an attempt to use `A` will likely result in an error, because most methods are not defined on type `Nothing`.
"""

# ╔═╡ 03c472ee-9e19-11eb-065c-41cf5a500bbc
md"""
### How can I modify the declaration of a type in my session?
"""

# ╔═╡ 03c4730c-9e19-11eb-2b55-b567765b396c
md"""
Perhaps you've defined a type and then realize you need to add a new field.  If you try this at the REPL, you get the error:
"""

# ╔═╡ 03c476d8-9e19-11eb-0db8-4142c34132e3
ERROR: invalid redefinition

# ╔═╡ 03c476fe-9e19-11eb-3f1c-111ec93970ce
md"""
Types in module `Main` cannot be redefined.
"""

# ╔═╡ 03c47712-9e19-11eb-080b-9be16bd8c2dd
md"""
While this can be inconvenient when you are developing new code, there's an excellent workaround.  Modules can be replaced by redefining them, and so if you wrap all your new code inside a module you can redefine types and constants.  You can't import the type names into `Main` and then expect to be able to redefine them there, but you can use the module name to resolve the scope.  In other words, while developing you might use a workflow something like this:
"""

# ╔═╡ 03c47776-9e19-11eb-1cfc-c74d02cedc80
md"""
```julia
include("mynewcode.jl")              # this defines a module MyModule
obj1 = MyModule.ObjConstructor(a, b)
obj2 = MyModule.somefunction(obj1)
# Got an error. Change something in "mynewcode.jl"
include("mynewcode.jl")              # reload the module
obj1 = MyModule.ObjConstructor(a, b) # old objects are no longer valid, must reconstruct
obj2 = MyModule.somefunction(obj1)   # this time it worked!
obj3 = MyModule.someotherfunction(obj2, c)
...
```
"""

# ╔═╡ 03c4778a-9e19-11eb-3816-3732606b7a27
md"""
## [Scripting](@id man-scripting)
"""

# ╔═╡ 03c4779c-9e19-11eb-3d6f-c17b1ee9eff7
md"""
### How do I check if the current file is being run as the main script?
"""

# ╔═╡ 03c477c6-9e19-11eb-06b5-3b59aa407d70
md"""
When a file is run as the main script using `julia file.jl` one might want to activate extra functionality like command line argument handling. A way to determine that a file is run in this fashion is to check if `abspath(PROGRAM_FILE) == @__FILE__` is `true`.
"""

# ╔═╡ 03c477e4-9e19-11eb-2f67-9f8b83f30cf7
md"""
### [How do I catch CTRL-C in a script?](@id catch-ctrl-c)
"""

# ╔═╡ 03c47816-9e19-11eb-23d5-094a531c6085
md"""
Running a Julia script using `julia file.jl` does not throw [`InterruptException`](@ref) when you try to terminate it with CTRL-C (SIGINT).  To run a certain code before terminating a Julia script, which may or may not be caused by CTRL-C, use [`atexit`](@ref). Alternatively, you can use `julia -e 'include(popfirst!(ARGS))' file.jl` to execute a script while being able to catch `InterruptException` in the [`try`](@ref) block.
"""

# ╔═╡ 03c4782a-9e19-11eb-2e9f-6b9bae196822
md"""
### How do I pass options to `julia` using `#!/usr/bin/env`?
"""

# ╔═╡ 03c47872-9e19-11eb-39a4-77dab1c85aa6
md"""
Passing options to `julia` in so-called shebang by, e.g., `#!/usr/bin/env julia --startup-file=no` may not work in some platforms such as Linux.  This is because argument parsing in shebang is platform-dependent and not well-specified.  In a Unix-like environment, a reliable way to pass options to `julia` in an executable script would be to start the script as a `bash` script and use `exec` to replace the process to `julia`:
"""

# ╔═╡ 03c47884-9e19-11eb-3448-67bdcd5c8622
md"""
```julia
#!/bin/bash
#=
exec julia --color=yes --startup-file=no "${BASH_SOURCE[0]}" "$@"
=#

@show ARGS  # put any Julia code here
```
"""

# ╔═╡ 03c478a4-9e19-11eb-10ee-6d6e5cf4e277
md"""
In the example above, the code between `#=` and `=#` is run as a `bash` script.  Julia ignores this part since it is a multi-line comment for Julia.  The Julia code after `=#` is ignored by `bash` since it stops parsing the file once it reaches to the `exec` statement.
"""

# ╔═╡ 03c47a78-9e19-11eb-1f62-992d3b8e88c3
md"""
!!! note
    In order to [catch CTRL-C](@ref catch-ctrl-c) in the script you can use

    ```julia
    #!/bin/bash
    #=
    exec julia --color=yes --startup-file=no -e 'include(popfirst!(ARGS))' \
        "${BASH_SOURCE[0]}" "$@"
    =#

    @show ARGS  # put any Julia code here
    ```

    instead. Note that with this strategy [`PROGRAM_FILE`](@ref) will not be set.
"""

# ╔═╡ 03c47a8c-9e19-11eb-3a0d-77ac1c6d4e6b
md"""
## Functions
"""

# ╔═╡ 03c47aaa-9e19-11eb-0525-adc69429fb0a
md"""
### I passed an argument `x` to a function, modified it inside that function, but on the outside, the variable `x` is still unchanged. Why?
"""

# ╔═╡ 03c47abe-9e19-11eb-18d9-f118dc86bbbd
md"""
Suppose you call a function like this:
"""

# ╔═╡ 03c48130-9e19-11eb-2ef4-b94df77d7f34
x = 10

# ╔═╡ 03c48130-9e19-11eb-3c2d-c34166d159c1
function change_value!(y)
           y = 17
       end

# ╔═╡ 03c4813a-9e19-11eb-3584-5dbc6541f5f0
change_value!(x)

# ╔═╡ 03c4813a-9e19-11eb-3533-73b6fa026baf
x # x is unchanged!

# ╔═╡ 03c48180-9e19-11eb-2349-9b1dacf5ff02
md"""
In Julia, the binding of a variable `x` cannot be changed by passing `x` as an argument to a function. When calling `change_value!(x)` in the above example, `y` is a newly created variable, bound initially to the value of `x`, i.e. `10`; then `y` is rebound to the constant `17`, while the variable `x` of the outer scope is left untouched.
"""

# ╔═╡ 03c481b2-9e19-11eb-1580-f90056fe60b8
md"""
However, if `x` is bound to an object of type `Array` (or any other *mutable* type). From within the function, you cannot "unbind" `x` from this Array, but you *can* change its content. For example:
"""

# ╔═╡ 03c486f8-9e19-11eb-376d-039147d725c4
x = [1,2,3]

# ╔═╡ 03c48720-9e19-11eb-0932-933748b4e637
function change_array!(A)
           A[1] = 5
       end

# ╔═╡ 03c4872a-9e19-11eb-3348-595c4191743f
change_array!(x)

# ╔═╡ 03c48734-9e19-11eb-2264-f3f0181d15bf
x

# ╔═╡ 03c48786-9e19-11eb-1f2b-cf898c55c740
md"""
Here we created a function `change_array!`, that assigns `5` to the first element of the passed array (bound to `x` at the call site, and bound to `A` within the function). Notice that, after the function call, `x` is still bound to the same array, but the content of that array changed: the variables `A` and `x` were distinct bindings referring to the same mutable `Array` object.
"""

# ╔═╡ 03c487ac-9e19-11eb-0cb0-b5083f5c4788
md"""
### Can I use `using` or `import` inside a function?
"""

# ╔═╡ 03c487d4-9e19-11eb-056d-eb613ecdb703
md"""
No, you are not allowed to have a `using` or `import` statement inside a function.  If you want to import a module but only use its symbols inside a specific function or set of functions, you have two options:
"""

# ╔═╡ 03c48964-9e19-11eb-0330-b7b485fa53aa
md"""
1. Use `import`:

    ```julia
    import Foo
    function bar(...)
        # ... refer to Foo symbols via Foo.baz ...
    end
    ```

    This loads the module `Foo` and defines a variable `Foo` that refers to the module, but does not import any of the other symbols from the module into the current namespace.  You refer to the `Foo` symbols by their qualified names `Foo.bar` etc.
2. Wrap your function in a module:

    ```julia
    module Bar
    export bar
    using Foo
    function bar(...)
        # ... refer to Foo.baz as simply baz ....
    end
    end
    using Bar
    ```

    This imports all the symbols from `Foo`, but only inside the module `Bar`.
"""

# ╔═╡ 03c48996-9e19-11eb-0cbe-a1e6bf9a6244
md"""
### What does the `...` operator do?
"""

# ╔═╡ 03c489aa-9e19-11eb-1294-91809acaaad8
md"""
### The two uses of the `...` operator: slurping and splatting
"""

# ╔═╡ 03c489d2-9e19-11eb-0b79-bde22a1bd774
md"""
Many newcomers to Julia find the use of `...` operator confusing. Part of what makes the `...` operator confusing is that it means two different things depending on context.
"""

# ╔═╡ 03c48a04-9e19-11eb-095f-2d446e9dd309
md"""
### `...` combines many arguments into one argument in function definitions
"""

# ╔═╡ 03c48a2c-9e19-11eb-2259-bd7c4fb5e9fb
md"""
In the context of function definitions, the `...` operator is used to combine many different arguments into a single argument. This use of `...` for combining many different arguments into a single argument is called slurping:
"""

# ╔═╡ 03c493e6-9e19-11eb-1203-5da919b32fde
function printargs(args...)
           println(typeof(args))
           for (i, arg) in enumerate(args)
               println("Arg #$i = $arg")
           end
       end

# ╔═╡ 03c493f0-9e19-11eb-042d-f500a1cff427
printargs(1, 2, 3)

# ╔═╡ 03c49454-9e19-11eb-0a1b-4b890bb686e7
md"""
If Julia were a language that made more liberal use of ASCII characters, the slurping operator might have been written as `<-...` instead of `...`.
"""

# ╔═╡ 03c49472-9e19-11eb-3f64-93603878aceb
md"""
### `...` splits one argument into many different arguments in function calls
"""

# ╔═╡ 03c4949a-9e19-11eb-2d86-937d9619b852
md"""
In contrast to the use of the `...` operator to denote slurping many different arguments into one argument when defining a function, the `...` operator is also used to cause a single function argument to be split apart into many different arguments when used in the context of a function call. This use of `...` is called splatting:
"""

# ╔═╡ 03c49e9a-9e19-11eb-1bd7-c1ac57281333
function threeargs(a, b, c)
           println("a = $a::$(typeof(a))")
           println("b = $b::$(typeof(b))")
           println("c = $c::$(typeof(c))")
       end

# ╔═╡ 03c49ea6-9e19-11eb-34d1-23a42c208849
x = [1, 2, 3]

# ╔═╡ 03c49eae-9e19-11eb-1299-bd431aa7a33c
threeargs(x...)

# ╔═╡ 03c49ecc-9e19-11eb-3ffe-e9fcaf8e6039
md"""
If Julia were a language that made more liberal use of ASCII characters, the splatting operator might have been written as `...->` instead of `...`.
"""

# ╔═╡ 03c49ef4-9e19-11eb-03e0-79777520bf23
md"""
### What is the return value of an assignment?
"""

# ╔═╡ 03c49f12-9e19-11eb-0bc8-c7ac0557cc5f
md"""
The operator `=` always returns the right-hand side, therefore:
"""

# ╔═╡ 03c4a566-9e19-11eb-2e81-6539beafe0d7
function threeint()
           x::Int = 3.0
           x # returns variable x
       end

# ╔═╡ 03c4a570-9e19-11eb-218d-d9cfad01f5a8
function threefloat()
           x::Int = 3.0 # returns 3.0
       end

# ╔═╡ 03c4a570-9e19-11eb-1447-7d869e46c074
threeint()

# ╔═╡ 03c4a584-9e19-11eb-11eb-817c2a02fd33
threefloat()

# ╔═╡ 03c4a598-9e19-11eb-0e1e-9f4fe3c27ab9
md"""
and similarly:
"""

# ╔═╡ 03c4ace4-9e19-11eb-1cb9-6d15967a705d
function threetup()
           x, y = [3, 3]
           x, y # returns a tuple
       end

# ╔═╡ 03c4acfa-9e19-11eb-18d5-fbe64bc7a8e0
function threearr()
           x, y = [3, 3] # returns an array
       end

# ╔═╡ 03c4ad16-9e19-11eb-35e5-f19c38615392
threetup()

# ╔═╡ 03c4ad16-9e19-11eb-35eb-0bfc1524f874
threearr()

# ╔═╡ 03c4ad48-9e19-11eb-08c8-6b0af983d0fc
md"""
## Types, type declarations, and constructors
"""

# ╔═╡ 03c4ad72-9e19-11eb-244e-15fb5f005b1c
md"""
### [What does "type-stable" mean?](@id man-type-stability)
"""

# ╔═╡ 03c4ada4-9e19-11eb-1ac3-5b7d00a8f3d7
md"""
It means that the type of the output is predictable from the types of the inputs.  In particular, it means that the type of the output cannot vary depending on the *values* of the inputs. The following code is *not* type-stable:
"""

# ╔═╡ 03c4b1fa-9e19-11eb-0728-4d180a70de40
function unstable(flag::Bool)
           if flag
               return 1
           else
               return 1.0
           end
       end

# ╔═╡ 03c4b22c-9e19-11eb-08dd-09793e7fbb9c
md"""
It returns either an `Int` or a [`Float64`](@ref) depending on the value of its argument. Since Julia can't predict the return type of this function at compile-time, any computation that uses it must be able to cope with values of both types, which makes it hard to produce fast machine code.
"""

# ╔═╡ 03c4b252-9e19-11eb-2235-7bfe7c2f0d10
md"""
### [Why does Julia give a `DomainError` for certain seemingly-sensible operations?](@id faq-domain-errors)
"""

# ╔═╡ 03c4b268-9e19-11eb-323d-d9350f533556
md"""
Certain operations make mathematical sense but result in errors:
"""

# ╔═╡ 03c4b3c6-9e19-11eb-03b5-63b24770e48f
sqrt(-2.0)

# ╔═╡ 03c4b4b6-9e19-11eb-2665-99305f1e9b0a
md"""
This behavior is an inconvenient consequence of the requirement for type-stability.  In the case of [`sqrt`](@ref), most users want `sqrt(2.0)` to give a real number, and would be unhappy if it produced the complex number `1.4142135623730951 + 0.0im`.  One could write the [`sqrt`](@ref) function to switch to a complex-valued output only when passed a negative number (which is what [`sqrt`](@ref) does in some other languages), but then the result would not be [type-stable](@ref man-type-stability) and the [`sqrt`](@ref) function would have poor performance.
"""

# ╔═╡ 03c4b4f4-9e19-11eb-21c8-5bee3962e619
md"""
In these and other cases, you can get the result you want by choosing an *input type* that conveys your willingness to accept an *output type* in which the result can be represented:
"""

# ╔═╡ 03c4ba7e-9e19-11eb-3e7e-a981d19159e2
sqrt(-2.0+0im)

# ╔═╡ 03c4bab0-9e19-11eb-29c5-05966921f89b
md"""
### How can I constrain or compute type parameters?
"""

# ╔═╡ 03c4bcb8-9e19-11eb-2ba0-17c33b7f51c8
md"""
The parameters of a [parametric type](@ref Parametric-Types) can hold either types or bits values, and the type itself chooses how it makes use of these parameters. For example, `Array{Float64, 2}` is parameterized by the type `Float64` to express its element type and the integer value `2` to express its number of dimensions.  When defining your own parametric type, you can use subtype constraints to declare that a certain parameter must be a subtype ([`<:`](@ref)) of some abstract type or a previous type parameter.  There is not, however, a dedicated syntax to declare that a parameter must be a *value* of a given type — that is, you cannot directly declare that a dimensionality-like parameter [`isa`](@ref) `Int` within the `struct` definition, for example.  Similarly, you cannot do computations (including simple things like addition or subtraction) on type parameters.  Instead, these sorts of constraints and relationships may be expressed through additional type parameters that are computed and enforced within the type's [constructors](@ref man-constructors).
"""

# ╔═╡ 03c4bcce-9e19-11eb-3588-c35778dadd23
md"""
As an example, consider
"""

# ╔═╡ 03c4bd3a-9e19-11eb-2f8c-c3ff9bb13022
md"""
```julia
struct ConstrainedType{T,N,N+1} # NOTE: INVALID SYNTAX
    A::Array{T,N}
    B::Array{T,N+1}
end
```
"""

# ╔═╡ 03c4bd80-9e19-11eb-197b-53c109296bab
md"""
where the user would like to enforce that the third type parameter is always the second plus one. This can be implemented with an explicit type parameter that is checked by an [inner constructor method](@ref man-inner-constructor-methods) (where it can be combined with other checks):
"""

# ╔═╡ 03c4bd9e-9e19-11eb-0909-3daa32b8a669
md"""
```julia
struct ConstrainedType{T,N,M}
    A::Array{T,N}
    B::Array{T,M}
    function ConstrainedType(A::Array{T,N}, B::Array{T,M}) where {T,N,M}
        N + 1 == M || throw(ArgumentError("second argument should have one more axis" ))
        new{T,N,M}(A, B)
    end
end
```
"""

# ╔═╡ 03c4bdc4-9e19-11eb-1def-d195f8736212
md"""
This check is usually *costless*, as the compiler can elide the check for valid concrete types. If the second argument is also computed, it may be advantageous to provide an [outer constructor method](@ref man-outer-constructor-methods) that performs this calculation:
"""

# ╔═╡ 03c4bdda-9e19-11eb-075f-d150f84534fa
md"""
```julia
ConstrainedType(A) = ConstrainedType(A, compute_B(A))
```
"""

# ╔═╡ 03c4bdf8-9e19-11eb-33f0-654f0236e0a7
md"""
### [Why does Julia use native machine integer arithmetic?](@id faq-integer-arithmetic)
"""

# ╔═╡ 03c4be16-9e19-11eb-1e0b-6369f39bb27a
md"""
Julia uses machine arithmetic for integer computations. This means that the range of `Int` values is bounded and wraps around at either end so that adding, subtracting and multiplying integers can overflow or underflow, leading to some results that can be unsettling at first:
"""

# ╔═╡ 03c4c5e6-9e19-11eb-3203-7b9bfb3a852e
x = typemax(Int)

# ╔═╡ 03c4c5fa-9e19-11eb-2456-c149675be864
y = x+1

# ╔═╡ 03c4c60e-9e19-11eb-1d0d-ab36a7f0a13b
z = -y

# ╔═╡ 03c4c65e-9e19-11eb-238a-2746de67c233
2*z

# ╔═╡ 03c4c690-9e19-11eb-0cbe-07ee90c9e025
md"""
Clearly, this is far from the way mathematical integers behave, and you might think it less than ideal for a high-level programming language to expose this to the user. For numerical work where efficiency and transparency are at a premium, however, the alternatives are worse.
"""

# ╔═╡ 03c4c6e0-9e19-11eb-27ed-b15a402e9010
md"""
One alternative to consider would be to check each integer operation for overflow and promote results to bigger integer types such as [`Int128`](@ref) or [`BigInt`](@ref) in the case of overflow. Unfortunately, this introduces major overhead on every integer operation (think incrementing a loop counter) – it requires emitting code to perform run-time overflow checks after arithmetic instructions and branches to handle potential overflows. Worse still, this would cause every computation involving integers to be type-unstable. As we mentioned above, [type-stability is crucial](@ref man-type-stability) for effective generation of efficient code. If you can't count on the results of integer operations being integers, it's impossible to generate fast, simple code the way C and Fortran compilers do.
"""

# ╔═╡ 03c4c71c-9e19-11eb-28ff-8d56aa782a91
md"""
A variation on this approach, which avoids the appearance of type instability is to merge the `Int` and [`BigInt`](@ref) types into a single hybrid integer type, that internally changes representation when a result no longer fits into the size of a machine integer. While this superficially avoids type-instability at the level of Julia code, it just sweeps the problem under the rug by foisting all of the same difficulties onto the C code implementing this hybrid integer type. This approach *can* be made to work and can even be made quite fast in many cases, but has several drawbacks. One problem is that the in-memory representation of integers and arrays of integers no longer match the natural representation used by C, Fortran and other languages with native machine integers. Thus, to interoperate with those languages, we would ultimately need to introduce native integer types anyway. Any unbounded representation of integers cannot have a fixed number of bits, and thus cannot be stored inline in an array with fixed-size slots – large integer values will always require separate heap-allocated storage. And of course, no matter how clever a hybrid integer implementation one uses, there are always performance traps – situations where performance degrades unexpectedly. Complex representation, lack of interoperability with C and Fortran, the inability to represent integer arrays without additional heap storage, and unpredictable performance characteristics make even the cleverest hybrid integer implementations a poor choice for high-performance numerical work.
"""

# ╔═╡ 03c4c726-9e19-11eb-3b28-a5c47707db61
md"""
An alternative to using hybrid integers or promoting to BigInts is to use saturating integer arithmetic, where adding to the largest integer value leaves it unchanged and likewise for subtracting from the smallest integer value. This is precisely what Matlab™ does:
"""

# ╔═╡ 03c4c80e-9e19-11eb-3350-c552f0e0d273
>> int64

# ╔═╡ 03c4c840-9e19-11eb-39be-17fdeeebc58d
md"""
At first blush, this seems reasonable enough since 9223372036854775807 is much closer to 9223372036854775808 than -9223372036854775808 is and integers are still represented with a fixed size in a natural way that is compatible with C and Fortran. Saturated integer arithmetic, however, is deeply problematic. The first and most obvious issue is that this is not the way machine integer arithmetic works, so implementing saturated operations requires emitting instructions after each machine integer operation to check for underflow or overflow and replace the result with [`typemin(Int)`](@ref) or [`typemax(Int)`](@ref) as appropriate. This alone expands each integer operation from a single, fast instruction into half a dozen instructions, probably including branches. Ouch. But it gets worse – saturating integer arithmetic isn't associative. Consider this Matlab computation:
"""

# ╔═╡ 03c4c8c0-9e19-11eb-2a6a-a5128b27270e
>> n

# ╔═╡ 03c4c910-9e19-11eb-3b3f-e9b4686f8de3
md"""
This makes it hard to write many basic integer algorithms since a lot of common techniques depend on the fact that machine addition with overflow *is* associative. Consider finding the midpoint between integer values `lo` and `hi` in Julia using the expression `(lo + hi) >>> 1`:
"""

# ╔═╡ 03c4cca6-9e19-11eb-3a5a-63db9552f8e8
n = 2^62

# ╔═╡ 03c4ccbc-9e19-11eb-2987-2188485b91f0
(n + 2n) >>> 1

# ╔═╡ 03c4ccd0-9e19-11eb-1e84-33c94852808a
md"""
See? No problem. That's the correct midpoint between 2^62 and 2^63, despite the fact that `n + 2n` is -4611686018427387904. Now try it in Matlab:
"""

# ╔═╡ 03c4cd7c-9e19-11eb-3069-afb0ddd6b25f
>> (

# ╔═╡ 03c4cd98-9e19-11eb-2bc1-9daf5cbc115f
md"""
Oops. Adding a `>>>` operator to Matlab wouldn't help, because saturation that occurs when adding `n` and `2n` has already destroyed the information necessary to compute the correct midpoint.
"""

# ╔═╡ 03c4cdc0-9e19-11eb-2f5f-85260ede66bf
md"""
Not only is lack of associativity unfortunate for programmers who cannot rely it for techniques like this, but it also defeats almost anything compilers might want to do to optimize integer arithmetic. For example, since Julia integers use normal machine integer arithmetic, LLVM is free to aggressively optimize simple little functions like `f(k) = 5k-1`. The machine code for this function is just this:
"""

# ╔═╡ 03c4cf6e-9e19-11eb-0c47-b31fc735697c
code_native(f, Tuple{Int})

# ╔═╡ 03c4cf8c-9e19-11eb-37eb-57e5534cb17a
md"""
The actual body of the function is a single `leaq` instruction, which computes the integer multiply and add at once. This is even more beneficial when `f` gets inlined into another function:
"""

# ╔═╡ 03c4d568-9e19-11eb-2572-93398bd3bfe2
function g(k, n)
           for i = 1:n
               k = f(k)
           end
           return k
       end

# ╔═╡ 03c4d568-9e19-11eb-18b4-79263a664e02
code_native(g, Tuple{Int,Int})

# ╔═╡ 03c4d590-9e19-11eb-04c2-6995d76f3120
md"""
Since the call to `f` gets inlined, the loop body ends up being just a single `leaq` instruction. Next, consider what happens if we make the number of loop iterations fixed:
"""

# ╔═╡ 03c4daea-9e19-11eb-0e9b-af261ee556d0
function g(k)
           for i = 1:10
               k = f(k)
           end
           return k
       end

# ╔═╡ 03c4dafe-9e19-11eb-35bb-8b69f48d8a02
code_native(g,(Int,))

# ╔═╡ 03c4db28-9e19-11eb-27da-1156f777e117
md"""
Because the compiler knows that integer addition and multiplication are associative and that multiplication distributes over addition – neither of which is true of saturating arithmetic – it can optimize the entire loop down to just a multiply and an add. Saturated arithmetic completely defeats this kind of optimization since associativity and distributivity can fail at each loop iteration, causing different outcomes depending on which iteration the failure occurs in. The compiler can unroll the loop, but it cannot algebraically reduce multiple operations into fewer equivalent operations.
"""

# ╔═╡ 03c4db4e-9e19-11eb-3d22-ed32eb006ba3
md"""
The most reasonable alternative to having integer arithmetic silently overflow is to do checked arithmetic everywhere, raising errors when adds, subtracts, and multiplies overflow, producing values that are not value-correct. In this [blog post](https://danluu.com/integer-overflow/), Dan Luu analyzes this and finds that rather than the trivial cost that this approach should in theory have, it ends up having a substantial cost due to compilers (LLVM and GCC) not gracefully optimizing around the added overflow checks. If this improves in the future, we could consider defaulting to checked integer arithmetic in Julia, but for now, we have to live with the possibility of overflow.
"""

# ╔═╡ 03c4db6c-9e19-11eb-23d8-9d0bed4ff638
md"""
In the meantime, overflow-safe integer operations can be achieved through the use of external libraries such as [SaferIntegers.jl](https://github.com/JeffreySarnoff/SaferIntegers.jl). Note that, as stated previously, the use of these libraries significantly increases the execution time of code using the checked integer types. However, for limited usage, this is far less of an issue than if it were used for all integer operations. You can follow the status of the discussion [here](https://github.com/JuliaLang/julia/issues/855).
"""

# ╔═╡ 03c4db94-9e19-11eb-0c13-3d00e5328db5
md"""
### What are the possible causes of an `UndefVarError` during remote execution?
"""

# ╔═╡ 03c4dba8-9e19-11eb-3a6f-75c07621ed50
md"""
As the error states, an immediate cause of an `UndefVarError` on a remote node is that a binding by that name does not exist. Let us explore some of the possible causes.
"""

# ╔═╡ 03c4dffe-9e19-11eb-2aa5-c392c3446f4c
module Foo
           foo() = remotecall_fetch(x->x, 2, "Hello")
       end

# ╔═╡ 03c4e008-9e19-11eb-0a2a-6140aa0c4dd3
Foo.foo()

# ╔═╡ 03c4e030-9e19-11eb-017e-af405014adb4
md"""
The closure `x->x` carries a reference to `Foo`, and since `Foo` is unavailable on node 2, an `UndefVarError` is thrown.
"""

# ╔═╡ 03c4e04e-9e19-11eb-25ff-b5dffb00f9b5
md"""
Globals under modules other than `Main` are not serialized by value to the remote node. Only a reference is sent. Functions which create global bindings (except under `Main`) may cause an `UndefVarError` to be thrown later.
"""

# ╔═╡ 03c4e5e4-9e19-11eb-147b-1da0d1a9c4a8
@everywhere module Foo
           function foo()
               global gvar = "Hello"
               remotecall_fetch(()->gvar, 2)
           end
       end

# ╔═╡ 03c4e604-9e19-11eb-3b0c-77805fa6a45d
Foo.foo()

# ╔═╡ 03c4e62a-9e19-11eb-39d9-7fb02981baf9
md"""
In the above example, `@everywhere module Foo` defined `Foo` on all nodes. However the call to `Foo.foo()` created a new global binding `gvar` on the local node, but this was not found on node 2 resulting in an `UndefVarError` error.
"""

# ╔═╡ 03c4e652-9e19-11eb-2b69-35dd91611b42
md"""
Note that this does not apply to globals created under module `Main`. Globals under module `Main` are serialized and new bindings created under `Main` on the remote node.
"""

# ╔═╡ 03c4e9ea-9e19-11eb-10dd-6d4170ef04e2
gvar_self = "Node1"

# ╔═╡ 03c4e9ea-9e19-11eb-3fc2-672bff918fa8
remotecall_fetch(()->gvar_self, 2)

# ╔═╡ 03c4e9ea-9e19-11eb-1c25-0140400cd3c0
remotecall_fetch(varinfo, 2)

# ╔═╡ 03c4ea12-9e19-11eb-1560-3f2a93a6b302
md"""
This does not apply to `function` or `struct` declarations. However, anonymous functions bound to global variables are serialized as can be seen below.
"""

# ╔═╡ 03c4efee-9e19-11eb-0bac-477dd365a8c7
bar() = 1

# ╔═╡ 03c4f002-9e19-11eb-0ff6-a16e0a8c129c
remotecall_fetch(bar, 2)

# ╔═╡ 03c4f002-9e19-11eb-108b-9356b76621d8
anon_bar  = ()->1

# ╔═╡ 03c4f00a-9e19-11eb-3354-4749929e2737
remotecall_fetch(anon_bar, 2)

# ╔═╡ 03c4f03c-9e19-11eb-116b-333ac381ce2f
md"""
### Why does Julia use `*` for string concatenation? Why not `+` or something else?
"""

# ╔═╡ 03c4f06e-9e19-11eb-03a7-0dfc2d713371
md"""
The [main argument](@ref man-concatenation) against `+` is that string concatenation is not commutative, while `+` is generally used as a commutative operator. While the Julia community recognizes that other languages use different operators and `*` may be unfamiliar for some users, it communicates certain algebraic properties.
"""

# ╔═╡ 03c4f098-9e19-11eb-0c08-97ff24603741
md"""
Note that you can also use `string(...)` to concatenate strings (and other values converted to strings); similarly, `repeat` can be used instead of `^` to repeat strings. The [interpolation syntax](@ref string-interpolation) is also useful for constructing strings.
"""

# ╔═╡ 03c4f0b6-9e19-11eb-31f7-3ddb9d3b86d9
md"""
## Packages and Modules
"""

# ╔═╡ 03c4f0e0-9e19-11eb-19f2-6df93a82fdaa
md"""
### What is the difference between "using" and "import"?
"""

# ╔═╡ 03c4f106-9e19-11eb-1ec1-f1a0b4d3902a
md"""
There is only one difference, and on the surface (syntax-wise) it may seem very minor. The difference between `using` and `import` is that with `using` you need to say `function Foo.bar(..` to extend module Foo's function bar with a new method, but with `import Foo.bar`, you only need to say `function bar(...` and it automatically extends module Foo's function bar.
"""

# ╔═╡ 03c4f124-9e19-11eb-26ef-2b1c43e61e6e
md"""
The reason this is important enough to have been given separate syntax is that you don't want to accidentally extend a function that you didn't know existed, because that could easily cause a bug. This is most likely to happen with a method that takes a common type like a string or integer, because both you and the other module could define a method to handle such a common type. If you use `import`, then you'll replace the other module's implementation of `bar(s::AbstractString)` with your new implementation, which could easily do something completely different (and break all/many future usages of the other functions in module Foo that depend on calling bar).
"""

# ╔═╡ 03c4f144-9e19-11eb-20b3-0b0765b3a6a4
md"""
## Nothingness and missing values
"""

# ╔═╡ 03c4f156-9e19-11eb-1d77-4d6ee922dc99
md"""
### [How does "null", "nothingness" or "missingness" work in Julia?](@id faq-nothing)
"""

# ╔═╡ 03c4f17e-9e19-11eb-1192-ad9662e73032
md"""
Unlike many languages (for example, C and Java), Julia objects cannot be "null" by default. When a reference (variable, object field, or array element) is uninitialized, accessing it will immediately throw an error. This situation can be detected using the [`isdefined`](@ref) or [`isassigned`](@ref Base.isassigned) functions.
"""

# ╔═╡ 03c4f19c-9e19-11eb-1444-972729d1fccc
md"""
Some functions are used only for their side effects, and do not need to return a value. In these cases, the convention is to return the value `nothing`, which is just a singleton object of type `Nothing`. This is an ordinary type with no fields; there is nothing special about it except for this convention, and that the REPL does not print anything for it. Some language constructs that would not otherwise have a value also yield `nothing`, for example `if false; end`.
"""

# ╔═╡ 03c4f200-9e19-11eb-1b30-a13245c3cca2
md"""
For situations where a value `x` of type `T` exists only sometimes, the `Union{T, Nothing}` type can be used for function arguments, object fields and array element types as the equivalent of [`Nullable`, `Option` or `Maybe`](https://en.wikipedia.org/wiki/Nullable_type) in other languages. If the value itself can be `nothing` (notably, when `T` is `Any`), the `Union{Some{T}, Nothing}` type is more appropriate since `x == nothing` then indicates the absence of a value, and `x == Some(nothing)` indicates the presence of a value equal to `nothing`. The [`something`](@ref) function allows unwrapping `Some` objects and using a default value instead of `nothing` arguments. Note that the compiler is able to generate efficient code when working with `Union{T, Nothing}` arguments or fields.
"""

# ╔═╡ 03c4f228-9e19-11eb-0db4-77726b348c9e
md"""
To represent missing data in the statistical sense (`NA` in R or `NULL` in SQL), use the [`missing`](@ref) object. See the [`Missing Values`](@ref missing) section for more details.
"""

# ╔═╡ 03c4f23c-9e19-11eb-2b92-912cdce346e6
md"""
In some languages, the empty tuple (`()`) is considered the canonical form of nothingness. However, in julia it is best thought of as just a regular tuple that happens to contain zero values.
"""

# ╔═╡ 03c4f25a-9e19-11eb-2d35-9d8d64fdfea0
md"""
The empty (or "bottom") type, written as `Union{}` (an empty union type), is a type with no values and no subtypes (except itself). You will generally not need to use this type.
"""

# ╔═╡ 03c4f264-9e19-11eb-06c8-8382851de2b6
md"""
## Memory
"""

# ╔═╡ 03c4f296-9e19-11eb-3af5-8d0c2a5bf1f4
md"""
### Why does `x += y` allocate memory when `x` and `y` are arrays?
"""

# ╔═╡ 03c4f2b4-9e19-11eb-3134-ddf3784071ee
md"""
In Julia, `x += y` gets replaced during parsing by `x = x + y`. For arrays, this has the consequence that, rather than storing the result in the same location in memory as `x`, it allocates a new array to store the result.
"""

# ╔═╡ 03c4f2c8-9e19-11eb-08d4-c7c434dc9103
md"""
While this behavior might surprise some, the choice is deliberate. The main reason is the presence of immutable objects within Julia, which cannot change their value once created.  Indeed, a number is an immutable object; the statements `x = 5; x += 1` do not modify the meaning of `5`, they modify the value bound to `x`. For an immutable, the only way to change the value is to reassign it.
"""

# ╔═╡ 03c4f2da-9e19-11eb-2a1e-7b78808af237
md"""
To amplify a bit further, consider the following function:
"""

# ╔═╡ 03c4f304-9e19-11eb-2b1c-533790f3feef
md"""
```julia
function power_by_squaring(x, n::Int)
    ispow2(n) || error("This implementation only works for powers of 2")
    while n >= 2
        x *= x
        n >>= 1
    end
    x
end
```
"""

# ╔═╡ 03c4f318-9e19-11eb-088a-dbf7215f5408
md"""
After a call like `x = 5; y = power_by_squaring(x, 4)`, you would get the expected result: `x == 5 && y == 625`.  However, now suppose that `*=`, when used with matrices, instead mutated the left hand side.  There would be two problems:
"""

# ╔═╡ 03c4f408-9e19-11eb-0b3b-49689ee2c0aa
md"""
  * For general square matrices, `A = A*B` cannot be implemented without temporary storage: `A[1,1]` gets computed and stored on the left hand side before you're done using it on the right hand side.
  * Suppose you were willing to allocate a temporary for the computation (which would eliminate most of the point of making `*=` work in-place); if you took advantage of the mutability of `x`, then this function would behave differently for mutable vs. immutable inputs. In particular, for immutable `x`, after the call you'd have (in general) `y != x`, but for mutable `x` you'd have `y == x`.
"""

# ╔═╡ 03c4f430-9e19-11eb-09da-cf5d8e7a9dd0
md"""
Because supporting generic programming is deemed more important than potential performance optimizations that can be achieved by other means (e.g., using explicit loops), operators like `+=` and `*=` work by rebinding new values.
"""

# ╔═╡ 03c4f442-9e19-11eb-047b-1b689416ff9d
md"""
## [Asynchronous IO and concurrent synchronous writes](@id faq-async-io)
"""

# ╔═╡ 03c4f458-9e19-11eb-2b15-59004e0e44c9
md"""
### Why do concurrent writes to the same stream result in inter-mixed output?
"""

# ╔═╡ 03c4f46c-9e19-11eb-3622-93554dacb361
md"""
While the streaming I/O API is synchronous, the underlying implementation is fully asynchronous.
"""

# ╔═╡ 03c4f480-9e19-11eb-197d-0bedf34ed399
md"""
Consider the printed output from the following:
"""

# ╔═╡ 03c4f9e2-9e19-11eb-2d35-7597b1eed7b8
@sync for i in 1:3
           @async write(stdout, string(i), " Foo ", " Bar ")
       end

# ╔═╡ 03c4fa14-9e19-11eb-03d0-197e95fac6da
md"""
This is happening because, while the `write` call is synchronous, the writing of each argument yields to other tasks while waiting for that part of the I/O to complete.
"""

# ╔═╡ 03c4fa34-9e19-11eb-3672-f7e26e8a551e
md"""
`print` and `println` "lock" the stream during a call. Consequently changing `write` to `println` in the above example results in:
"""

# ╔═╡ 03c4ff1e-9e19-11eb-2a50-3f54dcc58fec
@sync for i in 1:3
           @async println(stdout, string(i), " Foo ", " Bar ")
       end

# ╔═╡ 03c4ff3e-9e19-11eb-2aea-4f6025c78c37
md"""
You can lock your writes with a `ReentrantLock` like this:
"""

# ╔═╡ 03c5075c-9e19-11eb-1102-495097bf530c
l = ReentrantLock();

# ╔═╡ 03c5075c-9e19-11eb-24bf-276970117509
@sync for i in 1:3
           @async begin
               lock(l)
               try
                   write(stdout, string(i), " Foo ", " Bar ")
               finally
                   unlock(l)
               end
           end
       end

# ╔═╡ 03c5077c-9e19-11eb-3287-bd70e1ea5352
md"""
## Arrays
"""

# ╔═╡ 03c5078e-9e19-11eb-1e0d-6b8580a2cebe
md"""
### What are the differences between zero-dimensional arrays and scalars?
"""

# ╔═╡ 03c507b8-9e19-11eb-1471-f386a3343fa3
md"""
Zero-dimensional arrays are arrays of the form `Array{T,0}`. They behave similar to scalars, but there are important differences. They deserve a special mention because they are a special case which makes logical sense given the generic definition of arrays, but might be a bit unintuitive at first. The following line defines a zero-dimensional array:
"""

# ╔═╡ 03c508f6-9e19-11eb-32fb-a7a7bf80e0b1
A = zeros()

# ╔═╡ 03c50928-9e19-11eb-168c-67680cf32ca6
md"""
In this example, `A` is a mutable container that contains one element, which can be set by `A[] = 1.0` and retrieved with `A[]`. All zero-dimensional arrays have the same size (`size(A) == ()`), and length (`length(A) == 1`). In particular, zero-dimensional arrays are not empty. If you find this unintuitive, here are some ideas that might help to understand Julia's definition.
"""

# ╔═╡ 03c509fe-9e19-11eb-2bc2-f979a59f33c5
md"""
  * Zero-dimensional arrays are the "point" to vector's "line" and matrix's "plane". Just as a line has no area (but still represents a set of things), a point has no length or any dimensions at all (but still represents a thing).
  * We define `prod(())` to be 1, and the total number of elements in an array is the product of the size. The size of a zero-dimensional array is `()`, and therefore its length is `1`.
  * Zero-dimensional arrays don't natively have any dimensions into which you index – they’re just `A[]`. We can apply the same "trailing one" rule for them as for all other array dimensionalities, so you can indeed index them as `A[1]`, `A[1,1]`, etc; see [Omitted and extra indices](@ref).
"""

# ╔═╡ 03c50a42-9e19-11eb-1010-3df92121d1ed
md"""
It is also important to understand the differences to ordinary scalars. Scalars are not mutable containers (even though they are iterable and define things like `length`, `getindex`, *e.g.* `1[] == 1`). In particular, if `x = 0.0` is defined as a scalar, it is an error to attempt to change its value via `x[] = 1.0`. A scalar `x` can be converted into a zero-dimensional array containing it via `fill(x)`, and conversely, a zero-dimensional array `a` can be converted to the contained scalar via `a[]`. Another difference is that a scalar can participate in linear algebra operations such as `2 * rand(2,2)`, but the analogous operation with a zero-dimensional array `fill(2) * rand(2,2)` is an error.
"""

# ╔═╡ 03c50a4c-9e19-11eb-0c63-ef8e80e2983e
md"""
### Why are my Julia benchmarks for linear algebra operations different from other languages?
"""

# ╔═╡ 03c50a74-9e19-11eb-3acc-052f6c1af091
md"""
You may find that simple benchmarks of linear algebra building blocks like
"""

# ╔═╡ 03c50a90-9e19-11eb-3049-d3d7400bc9ba
md"""
```julia
using BenchmarkTools
A = randn(1000, 1000)
B = randn(1000, 1000)
@btime $A \ $B
@btime $A * $B
```
"""

# ╔═╡ 03c50aa6-9e19-11eb-1e63-7b15a23234b8
md"""
can be different when compared to other languages like Matlab or R.
"""

# ╔═╡ 03c50aba-9e19-11eb-3778-d1a2b924a078
md"""
Since operations like this are very thin wrappers over the relevant BLAS functions, the reason for the discrepancy is very likely to be
"""

# ╔═╡ 03c50b28-9e19-11eb-2e61-bf6540de628e
md"""
1. the BLAS library each language is using,
2. the number of concurrent threads.
"""

# ╔═╡ 03c50b3c-9e19-11eb-2d0f-1f114977355f
md"""
Julia compiles and uses its own copy of OpenBLAS, with threads currently capped at `8` (or the number of your cores).
"""

# ╔═╡ 03c50b66-9e19-11eb-36a0-a1a1039a21b1
md"""
Modifying OpenBLAS settings or compiling Julia with a different BLAS library, eg [Intel MKL](https://software.intel.com/en-us/mkl), may provide performance improvements. You can use [MKL.jl](https://github.com/JuliaComputing/MKL.jl), a package that makes Julia's linear algebra use Intel MKL BLAS and LAPACK instead of OpenBLAS, or search the discussion forum for suggestions on how to set this up manually. Note that Intel MKL cannot be bundled with Julia, as it is not open source.
"""

# ╔═╡ 03c50b78-9e19-11eb-1f62-555b44394954
md"""
## Computing cluster
"""

# ╔═╡ 03c50b8c-9e19-11eb-3af5-bfc91d7202ac
md"""
### How do I manage precompilation caches in distributed file systems?
"""

# ╔═╡ 03c50bb4-9e19-11eb-33e3-45325a9a5d12
md"""
When using `julia` in high-performance computing (HPC) facilities, invoking *n* `julia` processes simultaneously creates at most *n* temporary copies of precompilation cache files. If this is an issue (slow and/or small distributed file system), you may:
"""

# ╔═╡ 03c50c5e-9e19-11eb-2bd3-d712e7421675
md"""
1. Use `julia` with `--compiled-modules=no` flag to turn off precompilation.
2. Configure a private writable depot using `pushfirst!(DEPOT_PATH, private_path)` where `private_path` is a path unique to this `julia` process.  This can also be done by setting environment variable `JULIA_DEPOT_PATH` to `$private_path:$HOME/.julia`.
3. Create a symlink from `~/.julia/compiled` to a directory in a scratch space.
"""

# ╔═╡ 03c50c72-9e19-11eb-1db2-7d1f37c65316
md"""
## Julia Releases
"""

# ╔═╡ 03c50c86-9e19-11eb-24e9-d91452a6d72e
md"""
### Do I want to use the Stable, LTS, or nightly version of Julia?
"""

# ╔═╡ 03c50cae-9e19-11eb-0791-c189ea9bfd98
md"""
The Stable version of Julia is the latest released version of Julia, this is the version most people will want to run. It has the latest features, including improved performance. The Stable version of Julia is versioned according to [SemVer](https://semver.org/) as v1.x.y. A new minor release of Julia corresponding to a new Stable version is made approximately every 4-5 months after a few weeks of testing as a release candidate. Unlike the LTS version the a Stable version will not normally recieve bugfixes after another Stable version of Julia has been released. However, upgrading to the next Stable release will always be possible as each release of Julia v1.x will continue to run code written for earlier versions.
"""

# ╔═╡ 03c50cd6-9e19-11eb-02b2-73bc403ea772
md"""
You may prefer the LTS (Long Term Support) version of Julia if you are looking for a very stable code base. The current LTS version of Julia is versioned according to SemVer as v1.0.x; this branch will continue to recieve bugfixes until a new LTS branch is chosen, at which point the v1.0.x series will no longer recieved regular bug fixes and all but the most conservative users will be advised to upgrade to the new LTS version series. As a package developer, you may prefer to develop for the LTS version, to maximize the number of users who can use your package. As per SemVer, code written for v1.0 will continue to work for all future LTS and Stable versions. In general, even if targetting the LTS, one can develop and run code in the latest Stable version, to take advantage of the improved performance; so long as one avoids using new features (such as added library functions or new methods).
"""

# ╔═╡ 03c50cea-9e19-11eb-32f8-cfcec2d035e9
md"""
You may prefer the nightly version of Julia if you want to take advantage of the latest updates to the language, and don't mind if the version available today occasionally doesn't actually work. As the name implies, releases to the nightly version are made roughly every night (depending on build infrastructure stability). In general nightly released are fairly safe to use—your code will not catch on fire. However, they may be occasional regressions and or issues that will not be found until more thorough pre-release testing. You may wish to test against the nightly version to ensure that such regressions that affect your use case are caught before a release is made.
"""

# ╔═╡ 03c50d12-9e19-11eb-30a7-d975f401b806
md"""
Finally, you may also consider building Julia from source for yourself. This option is mainly for those individuals who are comfortable at the command line, or interested in learning. If this describes you, you may also be interested in reading our [guidelines for contributing](https://github.com/JuliaLang/julia/blob/master/CONTRIBUTING.md).
"""

# ╔═╡ 03c50d26-9e19-11eb-0b2b-af63a1f402dd
md"""
Links to each of these download types can be found on the download page at [https://julialang.org/downloads/](https://julialang.org/downloads/). Note that not all versions of Julia are available for all platforms.
"""

# ╔═╡ 03c50d4e-9e19-11eb-2f63-3147897fb73f
md"""
### How can I transfer the list of installed packages after updating my version of Julia?
"""

# ╔═╡ 03c50d6c-9e19-11eb-29d0-8ff36c748c49
md"""
Each minor version of julia has its own default [environment](https://docs.julialang.org/en/v1/manual/code-loading/#Environments-1). As a result, upon installing a new minor version of Julia, the packages you added using the previous minor version will not be available by default. The environment for a given julia version is defined by the files `Project.toml` and `Manifest.toml` in a folder matching the version number in `.julia/environments/`, for instance, `.julia/environments/v1.3`.
"""

# ╔═╡ 03c50d9e-9e19-11eb-2a8d-818a535c2348
md"""
If you install a new minor version of Julia, say `1.4`, and want to use in its default environment the same packages as in a previous version (e.g. `1.3`), you can copy the contents of the file `Project.toml` from the `1.3` folder to `1.4`. Then, in a session of the new Julia version, enter the "package management mode" by typing the key `]`, and run the command [`instantiate`](https://julialang.github.io/Pkg.jl/v1/api/#Pkg.instantiate).
"""

# ╔═╡ 03c50dbc-9e19-11eb-1252-e5a4d70137fc
md"""
This operation will resolve a set of feasible packages from the copied file that are compatible with the target Julia version, and will install or update them if suitable. If you want to reproduce not only the set of packages, but also the versions you were using in the previous Julia version, you should also copy the `Manifest.toml` file before running the Pkg command `instantiate`. However, note that packages may define compatibility constraints that may be affected by changing the version of Julia, so the exact set of versions you had in `1.3` may not work for `1.4`.
"""

# ╔═╡ Cell order:
# ╟─03c47078-9e19-11eb-1ef0-310277eded72
# ╟─03c470be-9e19-11eb-2516-45137204526e
# ╟─03c470f8-9e19-11eb-0f3f-a7b91dda0c70
# ╟─03c47122-9e19-11eb-3ecb-6fce6545ab21
# ╟─03c47136-9e19-11eb-0a65-15e1e3db7251
# ╟─03c4714a-9e19-11eb-2c5d-378bb9e5c2dd
# ╟─03c471e0-9e19-11eb-18bb-f358f13b5252
# ╟─03c471fc-9e19-11eb-0328-03566eec4950
# ╟─03c47212-9e19-11eb-1802-d3e2f8650010
# ╟─03c47244-9e19-11eb-320e-d789bb846b3e
# ╟─03c47258-9e19-11eb-05e1-bd7f86b8703e
# ╟─03c4726c-9e19-11eb-2148-eb93bd4831e7
# ╟─03c472b2-9e19-11eb-03e8-8b398e204504
# ╟─03c472e4-9e19-11eb-1701-17f014579a2e
# ╟─03c472ee-9e19-11eb-065c-41cf5a500bbc
# ╟─03c4730c-9e19-11eb-2b55-b567765b396c
# ╠═03c476d8-9e19-11eb-0db8-4142c34132e3
# ╟─03c476fe-9e19-11eb-3f1c-111ec93970ce
# ╟─03c47712-9e19-11eb-080b-9be16bd8c2dd
# ╟─03c47776-9e19-11eb-1cfc-c74d02cedc80
# ╟─03c4778a-9e19-11eb-3816-3732606b7a27
# ╟─03c4779c-9e19-11eb-3d6f-c17b1ee9eff7
# ╟─03c477c6-9e19-11eb-06b5-3b59aa407d70
# ╟─03c477e4-9e19-11eb-2f67-9f8b83f30cf7
# ╟─03c47816-9e19-11eb-23d5-094a531c6085
# ╟─03c4782a-9e19-11eb-2e9f-6b9bae196822
# ╟─03c47872-9e19-11eb-39a4-77dab1c85aa6
# ╟─03c47884-9e19-11eb-3448-67bdcd5c8622
# ╟─03c478a4-9e19-11eb-10ee-6d6e5cf4e277
# ╟─03c47a78-9e19-11eb-1f62-992d3b8e88c3
# ╟─03c47a8c-9e19-11eb-3a0d-77ac1c6d4e6b
# ╟─03c47aaa-9e19-11eb-0525-adc69429fb0a
# ╟─03c47abe-9e19-11eb-18d9-f118dc86bbbd
# ╠═03c48130-9e19-11eb-2ef4-b94df77d7f34
# ╠═03c48130-9e19-11eb-3c2d-c34166d159c1
# ╠═03c4813a-9e19-11eb-3584-5dbc6541f5f0
# ╠═03c4813a-9e19-11eb-3533-73b6fa026baf
# ╟─03c48180-9e19-11eb-2349-9b1dacf5ff02
# ╟─03c481b2-9e19-11eb-1580-f90056fe60b8
# ╠═03c486f8-9e19-11eb-376d-039147d725c4
# ╠═03c48720-9e19-11eb-0932-933748b4e637
# ╠═03c4872a-9e19-11eb-3348-595c4191743f
# ╠═03c48734-9e19-11eb-2264-f3f0181d15bf
# ╟─03c48786-9e19-11eb-1f2b-cf898c55c740
# ╟─03c487ac-9e19-11eb-0cb0-b5083f5c4788
# ╟─03c487d4-9e19-11eb-056d-eb613ecdb703
# ╟─03c48964-9e19-11eb-0330-b7b485fa53aa
# ╟─03c48996-9e19-11eb-0cbe-a1e6bf9a6244
# ╟─03c489aa-9e19-11eb-1294-91809acaaad8
# ╟─03c489d2-9e19-11eb-0b79-bde22a1bd774
# ╟─03c48a04-9e19-11eb-095f-2d446e9dd309
# ╟─03c48a2c-9e19-11eb-2259-bd7c4fb5e9fb
# ╠═03c493e6-9e19-11eb-1203-5da919b32fde
# ╠═03c493f0-9e19-11eb-042d-f500a1cff427
# ╟─03c49454-9e19-11eb-0a1b-4b890bb686e7
# ╟─03c49472-9e19-11eb-3f64-93603878aceb
# ╟─03c4949a-9e19-11eb-2d86-937d9619b852
# ╠═03c49e9a-9e19-11eb-1bd7-c1ac57281333
# ╠═03c49ea6-9e19-11eb-34d1-23a42c208849
# ╠═03c49eae-9e19-11eb-1299-bd431aa7a33c
# ╟─03c49ecc-9e19-11eb-3ffe-e9fcaf8e6039
# ╟─03c49ef4-9e19-11eb-03e0-79777520bf23
# ╟─03c49f12-9e19-11eb-0bc8-c7ac0557cc5f
# ╠═03c4a566-9e19-11eb-2e81-6539beafe0d7
# ╠═03c4a570-9e19-11eb-218d-d9cfad01f5a8
# ╠═03c4a570-9e19-11eb-1447-7d869e46c074
# ╠═03c4a584-9e19-11eb-11eb-817c2a02fd33
# ╟─03c4a598-9e19-11eb-0e1e-9f4fe3c27ab9
# ╠═03c4ace4-9e19-11eb-1cb9-6d15967a705d
# ╠═03c4acfa-9e19-11eb-18d5-fbe64bc7a8e0
# ╠═03c4ad16-9e19-11eb-35e5-f19c38615392
# ╠═03c4ad16-9e19-11eb-35eb-0bfc1524f874
# ╟─03c4ad48-9e19-11eb-08c8-6b0af983d0fc
# ╟─03c4ad72-9e19-11eb-244e-15fb5f005b1c
# ╟─03c4ada4-9e19-11eb-1ac3-5b7d00a8f3d7
# ╠═03c4b1fa-9e19-11eb-0728-4d180a70de40
# ╟─03c4b22c-9e19-11eb-08dd-09793e7fbb9c
# ╟─03c4b252-9e19-11eb-2235-7bfe7c2f0d10
# ╟─03c4b268-9e19-11eb-323d-d9350f533556
# ╠═03c4b3c6-9e19-11eb-03b5-63b24770e48f
# ╟─03c4b4b6-9e19-11eb-2665-99305f1e9b0a
# ╟─03c4b4f4-9e19-11eb-21c8-5bee3962e619
# ╠═03c4ba7e-9e19-11eb-3e7e-a981d19159e2
# ╟─03c4bab0-9e19-11eb-29c5-05966921f89b
# ╟─03c4bcb8-9e19-11eb-2ba0-17c33b7f51c8
# ╟─03c4bcce-9e19-11eb-3588-c35778dadd23
# ╟─03c4bd3a-9e19-11eb-2f8c-c3ff9bb13022
# ╟─03c4bd80-9e19-11eb-197b-53c109296bab
# ╟─03c4bd9e-9e19-11eb-0909-3daa32b8a669
# ╟─03c4bdc4-9e19-11eb-1def-d195f8736212
# ╟─03c4bdda-9e19-11eb-075f-d150f84534fa
# ╟─03c4bdf8-9e19-11eb-33f0-654f0236e0a7
# ╟─03c4be16-9e19-11eb-1e0b-6369f39bb27a
# ╠═03c4c5e6-9e19-11eb-3203-7b9bfb3a852e
# ╠═03c4c5fa-9e19-11eb-2456-c149675be864
# ╠═03c4c60e-9e19-11eb-1d0d-ab36a7f0a13b
# ╠═03c4c65e-9e19-11eb-238a-2746de67c233
# ╟─03c4c690-9e19-11eb-0cbe-07ee90c9e025
# ╟─03c4c6e0-9e19-11eb-27ed-b15a402e9010
# ╟─03c4c71c-9e19-11eb-28ff-8d56aa782a91
# ╟─03c4c726-9e19-11eb-3b28-a5c47707db61
# ╠═03c4c80e-9e19-11eb-3350-c552f0e0d273
# ╟─03c4c840-9e19-11eb-39be-17fdeeebc58d
# ╠═03c4c8c0-9e19-11eb-2a6a-a5128b27270e
# ╟─03c4c910-9e19-11eb-3b3f-e9b4686f8de3
# ╠═03c4cca6-9e19-11eb-3a5a-63db9552f8e8
# ╠═03c4ccbc-9e19-11eb-2987-2188485b91f0
# ╟─03c4ccd0-9e19-11eb-1e84-33c94852808a
# ╠═03c4cd7c-9e19-11eb-3069-afb0ddd6b25f
# ╟─03c4cd98-9e19-11eb-2bc1-9daf5cbc115f
# ╟─03c4cdc0-9e19-11eb-2f5f-85260ede66bf
# ╠═03c4cf6e-9e19-11eb-0c47-b31fc735697c
# ╟─03c4cf8c-9e19-11eb-37eb-57e5534cb17a
# ╠═03c4d568-9e19-11eb-2572-93398bd3bfe2
# ╠═03c4d568-9e19-11eb-18b4-79263a664e02
# ╟─03c4d590-9e19-11eb-04c2-6995d76f3120
# ╠═03c4daea-9e19-11eb-0e9b-af261ee556d0
# ╠═03c4dafe-9e19-11eb-35bb-8b69f48d8a02
# ╟─03c4db28-9e19-11eb-27da-1156f777e117
# ╟─03c4db4e-9e19-11eb-3d22-ed32eb006ba3
# ╟─03c4db6c-9e19-11eb-23d8-9d0bed4ff638
# ╟─03c4db94-9e19-11eb-0c13-3d00e5328db5
# ╟─03c4dba8-9e19-11eb-3a6f-75c07621ed50
# ╠═03c4dffe-9e19-11eb-2aa5-c392c3446f4c
# ╠═03c4e008-9e19-11eb-0a2a-6140aa0c4dd3
# ╟─03c4e030-9e19-11eb-017e-af405014adb4
# ╟─03c4e04e-9e19-11eb-25ff-b5dffb00f9b5
# ╠═03c4e5e4-9e19-11eb-147b-1da0d1a9c4a8
# ╠═03c4e604-9e19-11eb-3b0c-77805fa6a45d
# ╟─03c4e62a-9e19-11eb-39d9-7fb02981baf9
# ╟─03c4e652-9e19-11eb-2b69-35dd91611b42
# ╠═03c4e9ea-9e19-11eb-10dd-6d4170ef04e2
# ╠═03c4e9ea-9e19-11eb-3fc2-672bff918fa8
# ╠═03c4e9ea-9e19-11eb-1c25-0140400cd3c0
# ╟─03c4ea12-9e19-11eb-1560-3f2a93a6b302
# ╠═03c4efee-9e19-11eb-0bac-477dd365a8c7
# ╠═03c4f002-9e19-11eb-0ff6-a16e0a8c129c
# ╠═03c4f002-9e19-11eb-108b-9356b76621d8
# ╠═03c4f00a-9e19-11eb-3354-4749929e2737
# ╟─03c4f03c-9e19-11eb-116b-333ac381ce2f
# ╟─03c4f06e-9e19-11eb-03a7-0dfc2d713371
# ╟─03c4f098-9e19-11eb-0c08-97ff24603741
# ╟─03c4f0b6-9e19-11eb-31f7-3ddb9d3b86d9
# ╟─03c4f0e0-9e19-11eb-19f2-6df93a82fdaa
# ╟─03c4f106-9e19-11eb-1ec1-f1a0b4d3902a
# ╟─03c4f124-9e19-11eb-26ef-2b1c43e61e6e
# ╟─03c4f144-9e19-11eb-20b3-0b0765b3a6a4
# ╟─03c4f156-9e19-11eb-1d77-4d6ee922dc99
# ╟─03c4f17e-9e19-11eb-1192-ad9662e73032
# ╟─03c4f19c-9e19-11eb-1444-972729d1fccc
# ╟─03c4f200-9e19-11eb-1b30-a13245c3cca2
# ╟─03c4f228-9e19-11eb-0db4-77726b348c9e
# ╟─03c4f23c-9e19-11eb-2b92-912cdce346e6
# ╟─03c4f25a-9e19-11eb-2d35-9d8d64fdfea0
# ╟─03c4f264-9e19-11eb-06c8-8382851de2b6
# ╟─03c4f296-9e19-11eb-3af5-8d0c2a5bf1f4
# ╟─03c4f2b4-9e19-11eb-3134-ddf3784071ee
# ╟─03c4f2c8-9e19-11eb-08d4-c7c434dc9103
# ╟─03c4f2da-9e19-11eb-2a1e-7b78808af237
# ╟─03c4f304-9e19-11eb-2b1c-533790f3feef
# ╟─03c4f318-9e19-11eb-088a-dbf7215f5408
# ╟─03c4f408-9e19-11eb-0b3b-49689ee2c0aa
# ╟─03c4f430-9e19-11eb-09da-cf5d8e7a9dd0
# ╟─03c4f442-9e19-11eb-047b-1b689416ff9d
# ╟─03c4f458-9e19-11eb-2b15-59004e0e44c9
# ╟─03c4f46c-9e19-11eb-3622-93554dacb361
# ╟─03c4f480-9e19-11eb-197d-0bedf34ed399
# ╠═03c4f9e2-9e19-11eb-2d35-7597b1eed7b8
# ╟─03c4fa14-9e19-11eb-03d0-197e95fac6da
# ╟─03c4fa34-9e19-11eb-3672-f7e26e8a551e
# ╠═03c4ff1e-9e19-11eb-2a50-3f54dcc58fec
# ╟─03c4ff3e-9e19-11eb-2aea-4f6025c78c37
# ╠═03c5075c-9e19-11eb-1102-495097bf530c
# ╠═03c5075c-9e19-11eb-24bf-276970117509
# ╟─03c5077c-9e19-11eb-3287-bd70e1ea5352
# ╟─03c5078e-9e19-11eb-1e0d-6b8580a2cebe
# ╟─03c507b8-9e19-11eb-1471-f386a3343fa3
# ╠═03c508f6-9e19-11eb-32fb-a7a7bf80e0b1
# ╟─03c50928-9e19-11eb-168c-67680cf32ca6
# ╟─03c509fe-9e19-11eb-2bc2-f979a59f33c5
# ╟─03c50a42-9e19-11eb-1010-3df92121d1ed
# ╟─03c50a4c-9e19-11eb-0c63-ef8e80e2983e
# ╟─03c50a74-9e19-11eb-3acc-052f6c1af091
# ╟─03c50a90-9e19-11eb-3049-d3d7400bc9ba
# ╟─03c50aa6-9e19-11eb-1e63-7b15a23234b8
# ╟─03c50aba-9e19-11eb-3778-d1a2b924a078
# ╟─03c50b28-9e19-11eb-2e61-bf6540de628e
# ╟─03c50b3c-9e19-11eb-2d0f-1f114977355f
# ╟─03c50b66-9e19-11eb-36a0-a1a1039a21b1
# ╟─03c50b78-9e19-11eb-1f62-555b44394954
# ╟─03c50b8c-9e19-11eb-3af5-bfc91d7202ac
# ╟─03c50bb4-9e19-11eb-33e3-45325a9a5d12
# ╟─03c50c5e-9e19-11eb-2bd3-d712e7421675
# ╟─03c50c72-9e19-11eb-1db2-7d1f37c65316
# ╟─03c50c86-9e19-11eb-24e9-d91452a6d72e
# ╟─03c50cae-9e19-11eb-0791-c189ea9bfd98
# ╟─03c50cd6-9e19-11eb-02b2-73bc403ea772
# ╟─03c50cea-9e19-11eb-32f8-cfcec2d035e9
# ╟─03c50d12-9e19-11eb-30a7-d975f401b806
# ╟─03c50d26-9e19-11eb-0b2b-af63a1f402dd
# ╟─03c50d4e-9e19-11eb-2f63-3147897fb73f
# ╟─03c50d6c-9e19-11eb-29d0-8ff36c748c49
# ╟─03c50d9e-9e19-11eb-2a8d-818a535c2348
# ╟─03c50dbc-9e19-11eb-1252-e5a4d70137fc
