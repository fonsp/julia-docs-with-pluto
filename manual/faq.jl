### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ 77b62a7e-7c19-481f-8f71-89d20f95e201
md"""
# Frequently Asked Questions
"""

# ╔═╡ 3f4d6474-e03a-47c8-9fc8-7f8d681bcd35
md"""
## General
"""

# ╔═╡ d0ef0d39-e4e5-48c9-8dda-35e185135608
md"""
### Is Julia named after someone or something?
"""

# ╔═╡ 5a7f3387-d811-4e5f-b4a0-7896160f77f7
md"""
No.
"""

# ╔═╡ 1268aebc-b035-4f53-bada-542a3797a77b
md"""
### Why don't you compile Matlab/Python/R/… code to Julia?
"""

# ╔═╡ 05762b65-477e-4b25-a1e7-806376b7502b
md"""
Since many people are familiar with the syntax of other dynamic languages, and lots of code has already been written in those languages, it is natural to wonder why we didn't just plug a Matlab or Python front-end into a Julia back-end (or “transpile” code to Julia) in order to get all the performance benefits of Julia without requiring programmers to learn a new language.  Simple, right?
"""

# ╔═╡ b70cf79b-732e-4871-92f2-470f2009d600
md"""
The basic issue is that there is *nothing special about Julia's compiler*: we use a commonplace compiler (LLVM) with no “secret sauce” that other language developers don't know about.  Indeed, Julia's compiler is in many ways much simpler than those of other dynamic languages (e.g. PyPy or LuaJIT).   Julia's performance advantage derives almost entirely from its front-end: its language semantics allow a [well-written Julia program](@ref man-performance-tips) to *give more opportunities to the compiler* to generate efficient code and memory layouts.  If you tried to compile Matlab or Python code to Julia, our compiler would be limited by the semantics of Matlab or Python to producing code no better than that of existing compilers for those languages (and probably worse).  The key role of semantics is also why several existing Python compilers (like Numba and Pythran) only attempt to optimize a small subset of the language (e.g. operations on Numpy arrays and scalars), and for this subset they are already doing at least as well as we could for the same semantics.  The people working on those projects are incredibly smart and have accomplished amazing things, but retrofitting a compiler onto a language that was designed to be interpreted is a very difficult problem.
"""

# ╔═╡ cc81c284-d22e-43f7-8c2b-f43c77cd61f2
md"""
Julia's advantage is that good performance is not limited to a small subset of “built-in” types and operations, and one can write high-level type-generic code that works on arbitrary user-defined types while remaining fast and memory-efficient.  Types in languages like Python simply don't provide enough information to the compiler for similar capabilities, so as soon as you used those languages as a Julia front-end you would be stuck.
"""

# ╔═╡ 0577cdd2-8d1c-4110-9657-dc89e699c31f
md"""
For similar reasons, automated translation to Julia would also typically generate unreadable, slow, non-idiomatic code that would not be a good starting point for a native Julia port from another language.
"""

# ╔═╡ f2a7b8e1-57aa-405c-b7ca-64f806f39183
md"""
On the other hand, language *interoperability* is extremely useful: we want to exploit existing high-quality code in other languages from Julia (and vice versa)!  The best way to enable this is not a transpiler, but rather via easy inter-language calling facilities.  We have worked hard on this, from the built-in `ccall` intrinsic (to call C and Fortran libraries) to [JuliaInterop](https://github.com/JuliaInterop) packages that connect Julia to Python, Matlab, C++, and more.
"""

# ╔═╡ e031a339-0467-4371-9423-4c06f58b3e32
md"""
## Sessions and the REPL
"""

# ╔═╡ 410e91eb-3699-46a0-ba06-ebbda7db15b3
md"""
### How do I delete an object in memory?
"""

# ╔═╡ 2e3d6c25-3e3f-4e96-b4d0-23fc577a002e
md"""
Julia does not have an analog of MATLAB's `clear` function; once a name is defined in a Julia session (technically, in module `Main`), it is always present.
"""

# ╔═╡ 4cc95731-d48b-4eed-8388-2c002cfe8e4b
md"""
If memory usage is your concern, you can always replace objects with ones that consume less memory.  For example, if `A` is a gigabyte-sized array that you no longer need, you can free the memory with `A = nothing`.  The memory will be released the next time the garbage collector runs; you can force this to happen with [`GC.gc()`](@ref Base.GC.gc). Moreover, an attempt to use `A` will likely result in an error, because most methods are not defined on type `Nothing`.
"""

# ╔═╡ 2fe124a3-608f-4301-b20d-a2d26515fef2
md"""
### How can I modify the declaration of a type in my session?
"""

# ╔═╡ dbc4732b-5db3-42e2-afa9-0daa1dc78b00
md"""
Perhaps you've defined a type and then realize you need to add a new field.  If you try this at the REPL, you get the error:
"""

# ╔═╡ ccbc1be4-a935-447b-a632-b5e2e31c442f
md"""
```
ERROR: invalid redefinition of constant MyType
```
"""

# ╔═╡ e198a69f-a2f5-4d9a-b476-0541fd9d0b3d
md"""
Types in module `Main` cannot be redefined.
"""

# ╔═╡ 64eb4825-70c9-4e28-a1f8-e3aad627a1b8
md"""
While this can be inconvenient when you are developing new code, there's an excellent workaround.  Modules can be replaced by redefining them, and so if you wrap all your new code inside a module you can redefine types and constants.  You can't import the type names into `Main` and then expect to be able to redefine them there, but you can use the module name to resolve the scope.  In other words, while developing you might use a workflow something like this:
"""

# ╔═╡ 73614155-e1f9-4f36-a22e-9ce7a7995a5c
md"""
```julia
include(\"mynewcode.jl\")              # this defines a module MyModule
obj1 = MyModule.ObjConstructor(a, b)
obj2 = MyModule.somefunction(obj1)
# Got an error. Change something in \"mynewcode.jl\"
include(\"mynewcode.jl\")              # reload the module
obj1 = MyModule.ObjConstructor(a, b) # old objects are no longer valid, must reconstruct
obj2 = MyModule.somefunction(obj1)   # this time it worked!
obj3 = MyModule.someotherfunction(obj2, c)
...
```
"""

# ╔═╡ 9480ee74-700e-47c3-89ef-c38e2bfe30f3
md"""
## [Scripting](@id man-scripting)
"""

# ╔═╡ b77b89b9-6d21-4416-b431-230e36bc42e2
md"""
### How do I check if the current file is being run as the main script?
"""

# ╔═╡ 759240ef-5619-4f39-bfca-f874f482e0c1
md"""
When a file is run as the main script using `julia file.jl` one might want to activate extra functionality like command line argument handling. A way to determine that a file is run in this fashion is to check if `abspath(PROGRAM_FILE) == @__FILE__` is `true`.
"""

# ╔═╡ d0b162a8-8fce-4866-859d-77e60197051d
md"""
### [How do I catch CTRL-C in a script?](@id catch-ctrl-c)
"""

# ╔═╡ 9fb870f6-9c28-4ef4-9b25-7c481053de79
md"""
Running a Julia script using `julia file.jl` does not throw [`InterruptException`](@ref) when you try to terminate it with CTRL-C (SIGINT).  To run a certain code before terminating a Julia script, which may or may not be caused by CTRL-C, use [`atexit`](@ref). Alternatively, you can use `julia -e 'include(popfirst!(ARGS))' file.jl` to execute a script while being able to catch `InterruptException` in the [`try`](@ref) block.
"""

# ╔═╡ f37e8707-0fa3-43df-a3a8-c1ea3f304a4e
md"""
### How do I pass options to `julia` using `#!/usr/bin/env`?
"""

# ╔═╡ e0e1e211-bdcd-44e6-b148-e15ef6dd04fa
md"""
Passing options to `julia` in so-called shebang by, e.g., `#!/usr/bin/env julia --startup-file=no` may not work in some platforms such as Linux.  This is because argument parsing in shebang is platform-dependent and not well-specified.  In a Unix-like environment, a reliable way to pass options to `julia` in an executable script would be to start the script as a `bash` script and use `exec` to replace the process to `julia`:
"""

# ╔═╡ 9161c6f8-5f7b-4dc1-95d1-abde1a16d679
md"""
```julia
#!/bin/bash
#=
exec julia --color=yes --startup-file=no \"${BASH_SOURCE[0]}\" \"$@\"
=#

@show ARGS  # put any Julia code here
```
"""

# ╔═╡ a40e228c-4300-4605-87c0-a7a6b3dd3cf1
md"""
In the example above, the code between `#=` and `=#` is run as a `bash` script.  Julia ignores this part since it is a multi-line comment for Julia.  The Julia code after `=#` is ignored by `bash` since it stops parsing the file once it reaches to the `exec` statement.
"""

# ╔═╡ 70049e74-774e-4813-8e21-1f4cbb3f97ec
md"""
!!! note
    In order to [catch CTRL-C](@ref catch-ctrl-c) in the script you can use

    ```julia
    #!/bin/bash
    #=
    exec julia --color=yes --startup-file=no -e 'include(popfirst!(ARGS))' \
        \"${BASH_SOURCE[0]}\" \"$@\"
    =#

    @show ARGS  # put any Julia code here
    ```

    instead. Note that with this strategy [`PROGRAM_FILE`](@ref) will not be set.
"""

# ╔═╡ eaa62a8c-e94f-4f09-a99c-e4894663cd62
md"""
## Functions
"""

# ╔═╡ 3631b78e-e007-436e-9aed-ed9556d28695
md"""
### I passed an argument `x` to a function, modified it inside that function, but on the outside, the variable `x` is still unchanged. Why?
"""

# ╔═╡ a8544ae6-5f2c-4de1-b847-dc0fdf14e289
md"""
Suppose you call a function like this:
"""

# ╔═╡ 9e0f1d1e-e0c0-4b1e-a541-1f8c9d1b4f99
x = 10

# ╔═╡ b4b377de-585d-4643-96d6-6692aaaf4a91
function change_value!(y)
     y = 17
 end

# ╔═╡ ffb2436d-a9d9-4331-8cf2-372e896339db
change_value!(x)

# ╔═╡ 9d5e1c51-6084-4b5b-a252-38e8110d35e0
x # x is unchanged!

# ╔═╡ d9a60b64-af5b-4560-8010-53b1b6b05672
md"""
In Julia, the binding of a variable `x` cannot be changed by passing `x` as an argument to a function. When calling `change_value!(x)` in the above example, `y` is a newly created variable, bound initially to the value of `x`, i.e. `10`; then `y` is rebound to the constant `17`, while the variable `x` of the outer scope is left untouched.
"""

# ╔═╡ 80e3b02a-fb7c-4490-9fe9-0d54bc405441
md"""
However, if `x` is bound to an object of type `Array` (or any other *mutable* type). From within the function, you cannot \"unbind\" `x` from this Array, but you *can* change its content. For example:
"""

# ╔═╡ 6f54e5f4-58e6-4d5d-a897-7e9f283a0cf6
x = [1,2,3]

# ╔═╡ f2abf6e9-fbc5-4450-ad51-f6dfefbd5b82
function change_array!(A)
     A[1] = 5
 end

# ╔═╡ 2b1a1f47-6d74-4570-b072-15f3df7124e3
change_array!(x)

# ╔═╡ 95c44aee-6812-4210-b004-e97d5cb51e36
x

# ╔═╡ 99d86351-7eea-47a9-ac0c-b7b34bb694c6
md"""
Here we created a function `change_array!`, that assigns `5` to the first element of the passed array (bound to `x` at the call site, and bound to `A` within the function). Notice that, after the function call, `x` is still bound to the same array, but the content of that array changed: the variables `A` and `x` were distinct bindings referring to the same mutable `Array` object.
"""

# ╔═╡ b22f8c8f-cbd0-4f72-ad22-f771aff2b9d4
md"""
### Can I use `using` or `import` inside a function?
"""

# ╔═╡ 9bc662eb-d2c1-4e7e-ac24-f2e881cce6be
md"""
No, you are not allowed to have a `using` or `import` statement inside a function.  If you want to import a module but only use its symbols inside a specific function or set of functions, you have two options:
"""

# ╔═╡ 28bfedf2-72d1-4847-9646-37391bba0607
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

# ╔═╡ 1a850a41-0cf6-4d97-8414-dcd751bfcba2
md"""
### What does the `...` operator do?
"""

# ╔═╡ eed1249a-f317-4f4f-942a-3cbb4144ab91
md"""
### The two uses of the `...` operator: slurping and splatting
"""

# ╔═╡ 435a14d7-6926-4886-be6c-b3011f0ec1d3
md"""
Many newcomers to Julia find the use of `...` operator confusing. Part of what makes the `...` operator confusing is that it means two different things depending on context.
"""

# ╔═╡ d8b90f3a-9ea1-45da-8473-ca0490f84eda
md"""
### `...` combines many arguments into one argument in function definitions
"""

# ╔═╡ 2c684706-eef6-444b-8631-92bacf428f48
md"""
In the context of function definitions, the `...` operator is used to combine many different arguments into a single argument. This use of `...` for combining many different arguments into a single argument is called slurping:
"""

# ╔═╡ 8b8b70ab-35bb-45de-90e3-7aebffcd6cbe
function printargs(args...)
     println(typeof(args))
     for (i, arg) in enumerate(args)
         println("Arg #$i = $arg")
     end
 end

# ╔═╡ 39a60bd5-b78b-417d-b5e1-953efa646e4b
printargs(1, 2, 3)

# ╔═╡ fe908672-bcd8-44b1-a58a-2e1ff4c3a852
md"""
If Julia were a language that made more liberal use of ASCII characters, the slurping operator might have been written as `<-...` instead of `...`.
"""

# ╔═╡ c7ea9a48-34be-4fd6-a346-7cf10d9f0b44
md"""
### `...` splits one argument into many different arguments in function calls
"""

# ╔═╡ 555a7b7c-0eb4-4917-9121-d62d319ba5e7
md"""
In contrast to the use of the `...` operator to denote slurping many different arguments into one argument when defining a function, the `...` operator is also used to cause a single function argument to be split apart into many different arguments when used in the context of a function call. This use of `...` is called splatting:
"""

# ╔═╡ 3a1d07fe-ca90-44bc-91f1-4c09f7e1d09c
function threeargs(a, b, c)
     println("a = $a::$(typeof(a))")
     println("b = $b::$(typeof(b))")
     println("c = $c::$(typeof(c))")
 end

# ╔═╡ 978e216e-062f-46d2-91dc-05d66bb104d5
x = [1, 2, 3]

# ╔═╡ a711c141-023b-4d53-9566-42d0b041cf93
threeargs(x...)

# ╔═╡ 1ee4564e-db74-4333-a05d-194f8104e350
md"""
If Julia were a language that made more liberal use of ASCII characters, the splatting operator might have been written as `...->` instead of `...`.
"""

# ╔═╡ 031e8936-c5e3-4e2c-927b-b179a0f047b3
md"""
### What is the return value of an assignment?
"""

# ╔═╡ 59f718c4-e098-4845-ba7f-4c46fb08b0a9
md"""
The operator `=` always returns the right-hand side, therefore:
"""

# ╔═╡ 243f0ef8-2d22-435f-8642-6cf544cfc5a3
function threeint()
     x::Int = 3.0
     x # returns variable x
 end

# ╔═╡ 64f2a444-7e95-4234-9c1b-8a5e9de6f638
function threefloat()
     x::Int = 3.0 # returns 3.0
 end

# ╔═╡ ac9b726b-9171-40bd-9922-14b639720a0e
threeint()

# ╔═╡ 3710dedb-62f1-4b0c-a7d7-f4b4d0c91d4b
threefloat()

# ╔═╡ cfe7075f-a7df-48e2-a8a4-84f944069773
md"""
and similarly:
"""

# ╔═╡ 2eddbfc1-0660-48a8-aa15-ad598af7e07e
function threetup()
     x, y = [3, 3]
     x, y # returns a tuple
 end

# ╔═╡ 4bf8acde-5225-46b2-9d93-515eb7d9fb26
function threearr()
     x, y = [3, 3] # returns an array
 end

# ╔═╡ 4f9b98aa-e628-447a-b935-e644c75ed776
threetup()

# ╔═╡ 035e924e-3456-44d0-bf27-ff3ff4818d24
threearr()

# ╔═╡ da9d5b0b-b36f-4b0a-9c56-fb12fc5bd66a
md"""
## Types, type declarations, and constructors
"""

# ╔═╡ 99775cff-e775-4b2b-b102-339ad7012ef8
md"""
### [What does \"type-stable\" mean?](@id man-type-stability)
"""

# ╔═╡ 57cab9ab-c8a1-4609-8ab3-ec2a986eaa7e
md"""
It means that the type of the output is predictable from the types of the inputs.  In particular, it means that the type of the output cannot vary depending on the *values* of the inputs. The following code is *not* type-stable:
"""

# ╔═╡ 4c1b4906-6d33-4c12-aaed-cab017970d0e
function unstable(flag::Bool)
     if flag
         return 1
     else
         return 1.0
     end
 end

# ╔═╡ a6c837e4-65a3-4086-a8d0-803725ebb6c4
md"""
It returns either an `Int` or a [`Float64`](@ref) depending on the value of its argument. Since Julia can't predict the return type of this function at compile-time, any computation that uses it must be able to cope with values of both types, which makes it hard to produce fast machine code.
"""

# ╔═╡ 2aaade92-4518-4aba-a2d9-7333e92548f7
md"""
### [Why does Julia give a `DomainError` for certain seemingly-sensible operations?](@id faq-domain-errors)
"""

# ╔═╡ bcb31c6d-a493-405b-9192-765ce0b12fd2
md"""
Certain operations make mathematical sense but result in errors:
"""

# ╔═╡ 7c7033e9-dc50-462f-8ce1-2407246e64ac
sqrt(-2.0)

# ╔═╡ 54e47d3a-d39e-406b-ac70-ec03e3bf801d
md"""
This behavior is an inconvenient consequence of the requirement for type-stability.  In the case of [`sqrt`](@ref), most users want `sqrt(2.0)` to give a real number, and would be unhappy if it produced the complex number `1.4142135623730951 + 0.0im`.  One could write the [`sqrt`](@ref) function to switch to a complex-valued output only when passed a negative number (which is what [`sqrt`](@ref) does in some other languages), but then the result would not be [type-stable](@ref man-type-stability) and the [`sqrt`](@ref) function would have poor performance.
"""

# ╔═╡ ffc3c3ab-8e80-4e83-818e-b4f76a60d7e1
md"""
In these and other cases, you can get the result you want by choosing an *input type* that conveys your willingness to accept an *output type* in which the result can be represented:
"""

# ╔═╡ b3bab550-f321-4e3e-b4cc-b426b5b263f6
sqrt(-2.0+0im)

# ╔═╡ 8c3f46f8-d6ad-49ef-aa9b-33718d392c42
md"""
### How can I constrain or compute type parameters?
"""

# ╔═╡ a5baafd9-1566-49d8-a9cf-e89d17b52bde
md"""
The parameters of a [parametric type](@ref Parametric-Types) can hold either types or bits values, and the type itself chooses how it makes use of these parameters. For example, `Array{Float64, 2}` is parameterized by the type `Float64` to express its element type and the integer value `2` to express its number of dimensions.  When defining your own parametric type, you can use subtype constraints to declare that a certain parameter must be a subtype ([`<:`](@ref)) of some abstract type or a previous type parameter.  There is not, however, a dedicated syntax to declare that a parameter must be a *value* of a given type — that is, you cannot directly declare that a dimensionality-like parameter [`isa`](@ref) `Int` within the `struct` definition, for example.  Similarly, you cannot do computations (including simple things like addition or subtraction) on type parameters.  Instead, these sorts of constraints and relationships may be expressed through additional type parameters that are computed and enforced within the type's [constructors](@ref man-constructors).
"""

# ╔═╡ eccfb30e-7db6-4429-b908-276b37e24ac7
md"""
As an example, consider
"""

# ╔═╡ a310cae6-988f-4da0-8124-7c6be117702d
md"""
```julia
struct ConstrainedType{T,N,N+1} # NOTE: INVALID SYNTAX
    A::Array{T,N}
    B::Array{T,N+1}
end
```
"""

# ╔═╡ 64d51ada-f4b8-4f48-8ad4-9fefdcdcf848
md"""
where the user would like to enforce that the third type parameter is always the second plus one. This can be implemented with an explicit type parameter that is checked by an [inner constructor method](@ref man-inner-constructor-methods) (where it can be combined with other checks):
"""

# ╔═╡ dcaa5fff-660a-44b0-b4d6-f5a15a9d0a89
md"""
```julia
struct ConstrainedType{T,N,M}
    A::Array{T,N}
    B::Array{T,M}
    function ConstrainedType(A::Array{T,N}, B::Array{T,M}) where {T,N,M}
        N + 1 == M || throw(ArgumentError(\"second argument should have one more axis\" ))
        new{T,N,M}(A, B)
    end
end
```
"""

# ╔═╡ 79538e16-b482-4aee-9115-3f8031b0402a
md"""
This check is usually *costless*, as the compiler can elide the check for valid concrete types. If the second argument is also computed, it may be advantageous to provide an [outer constructor method](@ref man-outer-constructor-methods) that performs this calculation:
"""

# ╔═╡ a8301041-3309-4820-95e0-4cf19fa51f96
md"""
```julia
ConstrainedType(A) = ConstrainedType(A, compute_B(A))
```
"""

# ╔═╡ fdd3e920-516d-4b78-ba1a-406afc1825dc
md"""
### [Why does Julia use native machine integer arithmetic?](@id faq-integer-arithmetic)
"""

# ╔═╡ 00c074be-de6b-45ac-ab6b-7b4bb25565a1
md"""
Julia uses machine arithmetic for integer computations. This means that the range of `Int` values is bounded and wraps around at either end so that adding, subtracting and multiplying integers can overflow or underflow, leading to some results that can be unsettling at first:
"""

# ╔═╡ cadf750c-0b1b-4d1c-a932-af867907b352
x = typemax(Int)

# ╔═╡ 3a8d9cb2-15e3-4763-8cde-4ca75f3d6602
y = x+1

# ╔═╡ 6db5330b-87d9-4fb5-8c2b-407c35a68462
z = -y

# ╔═╡ 4e20fcad-c176-4985-be4e-5beb2f8b1f71
2*z

# ╔═╡ a8892deb-40b4-42bb-96f0-55d91b8a693d
md"""
Clearly, this is far from the way mathematical integers behave, and you might think it less than ideal for a high-level programming language to expose this to the user. For numerical work where efficiency and transparency are at a premium, however, the alternatives are worse.
"""

# ╔═╡ 9b09deb6-5f3d-4e9a-81bc-35e3fd29179c
md"""
One alternative to consider would be to check each integer operation for overflow and promote results to bigger integer types such as [`Int128`](@ref) or [`BigInt`](@ref) in the case of overflow. Unfortunately, this introduces major overhead on every integer operation (think incrementing a loop counter) – it requires emitting code to perform run-time overflow checks after arithmetic instructions and branches to handle potential overflows. Worse still, this would cause every computation involving integers to be type-unstable. As we mentioned above, [type-stability is crucial](@ref man-type-stability) for effective generation of efficient code. If you can't count on the results of integer operations being integers, it's impossible to generate fast, simple code the way C and Fortran compilers do.
"""

# ╔═╡ dd1489c6-897f-44d4-9447-ee295cd48119
md"""
A variation on this approach, which avoids the appearance of type instability is to merge the `Int` and [`BigInt`](@ref) types into a single hybrid integer type, that internally changes representation when a result no longer fits into the size of a machine integer. While this superficially avoids type-instability at the level of Julia code, it just sweeps the problem under the rug by foisting all of the same difficulties onto the C code implementing this hybrid integer type. This approach *can* be made to work and can even be made quite fast in many cases, but has several drawbacks. One problem is that the in-memory representation of integers and arrays of integers no longer match the natural representation used by C, Fortran and other languages with native machine integers. Thus, to interoperate with those languages, we would ultimately need to introduce native integer types anyway. Any unbounded representation of integers cannot have a fixed number of bits, and thus cannot be stored inline in an array with fixed-size slots – large integer values will always require separate heap-allocated storage. And of course, no matter how clever a hybrid integer implementation one uses, there are always performance traps – situations where performance degrades unexpectedly. Complex representation, lack of interoperability with C and Fortran, the inability to represent integer arrays without additional heap storage, and unpredictable performance characteristics make even the cleverest hybrid integer implementations a poor choice for high-performance numerical work.
"""

# ╔═╡ 4fcbb09b-8628-4ac9-94b5-c7f120328f6b
md"""
An alternative to using hybrid integers or promoting to BigInts is to use saturating integer arithmetic, where adding to the largest integer value leaves it unchanged and likewise for subtracting from the smallest integer value. This is precisely what Matlab™ does:
"""

# ╔═╡ e4b817c5-db2a-4700-b298-a2699565d060
md"""
```
>> int64(9223372036854775807)

ans =

  9223372036854775807

>> int64(9223372036854775807) + 1

ans =

  9223372036854775807

>> int64(-9223372036854775808)

ans =

 -9223372036854775808

>> int64(-9223372036854775808) - 1

ans =

 -9223372036854775808
```
"""

# ╔═╡ ca1964f6-7cb1-482e-8746-aa4a5d3bf1ab
md"""
At first blush, this seems reasonable enough since 9223372036854775807 is much closer to 9223372036854775808 than -9223372036854775808 is and integers are still represented with a fixed size in a natural way that is compatible with C and Fortran. Saturated integer arithmetic, however, is deeply problematic. The first and most obvious issue is that this is not the way machine integer arithmetic works, so implementing saturated operations requires emitting instructions after each machine integer operation to check for underflow or overflow and replace the result with [`typemin(Int)`](@ref) or [`typemax(Int)`](@ref) as appropriate. This alone expands each integer operation from a single, fast instruction into half a dozen instructions, probably including branches. Ouch. But it gets worse – saturating integer arithmetic isn't associative. Consider this Matlab computation:
"""

# ╔═╡ ac3c3712-7a64-4b17-a24a-077d9ca8b5a4
md"""
```
>> n = int64(2)^62
4611686018427387904

>> n + (n - 1)
9223372036854775807

>> (n + n) - 1
9223372036854775806
```
"""

# ╔═╡ 5ff65eab-8967-476d-8374-220b6551c6bc
md"""
This makes it hard to write many basic integer algorithms since a lot of common techniques depend on the fact that machine addition with overflow *is* associative. Consider finding the midpoint between integer values `lo` and `hi` in Julia using the expression `(lo + hi) >>> 1`:
"""

# ╔═╡ 7ac015c5-73ba-41c6-a867-3881dc4fab8b
n = 2^62

# ╔═╡ b3e722ab-4175-48a9-976d-708129831fa5
(n + 2n) >>> 1

# ╔═╡ ea8f197a-deec-43a4-b4e3-42ff014235e5
md"""
See? No problem. That's the correct midpoint between 2^62 and 2^63, despite the fact that `n + 2n` is -4611686018427387904. Now try it in Matlab:
"""

# ╔═╡ c96a7d85-6f19-4974-8818-78219112bbd5
md"""
```
>> (n + 2*n)/2

ans =

  4611686018427387904
```
"""

# ╔═╡ 6dfa32be-c633-4c20-b6e2-636d83b023ff
md"""
Oops. Adding a `>>>` operator to Matlab wouldn't help, because saturation that occurs when adding `n` and `2n` has already destroyed the information necessary to compute the correct midpoint.
"""

# ╔═╡ cdf95c0a-51b9-47e0-9dd5-aab3f8c09d76
md"""
Not only is lack of associativity unfortunate for programmers who cannot rely it for techniques like this, but it also defeats almost anything compilers might want to do to optimize integer arithmetic. For example, since Julia integers use normal machine integer arithmetic, LLVM is free to aggressively optimize simple little functions like `f(k) = 5k-1`. The machine code for this function is just this:
"""

# ╔═╡ 705ac6f0-23d7-471c-9834-36645e0207f9
code_native(f, Tuple{Int})

# ╔═╡ e144ce0d-255d-41b1-bd57-da7585bc77fc
md"""
The actual body of the function is a single `leaq` instruction, which computes the integer multiply and add at once. This is even more beneficial when `f` gets inlined into another function:
"""

# ╔═╡ e743ff63-ee77-464e-9c8d-41774377bc7b
function g(k, n)
     for i = 1:n
         k = f(k)
     end
     return k
 end

# ╔═╡ 04dadaf7-1700-4c23-b985-1c99e8eabc38
code_native(g, Tuple{Int,Int})

# ╔═╡ c4968316-13b2-4fe5-b55d-49d6fd144003
md"""
Since the call to `f` gets inlined, the loop body ends up being just a single `leaq` instruction. Next, consider what happens if we make the number of loop iterations fixed:
"""

# ╔═╡ 3c5c7b8c-718c-41b4-82ba-76b5f119bdaf
function g(k)
     for i = 1:10
         k = f(k)
     end
     return k
 end

# ╔═╡ 48673b68-8f51-4b8c-b86a-deb3a68b9b3e
code_native(g,(Int,))

# ╔═╡ dfee9a05-2053-43eb-afaf-eada9ab3a60c
md"""
Because the compiler knows that integer addition and multiplication are associative and that multiplication distributes over addition – neither of which is true of saturating arithmetic – it can optimize the entire loop down to just a multiply and an add. Saturated arithmetic completely defeats this kind of optimization since associativity and distributivity can fail at each loop iteration, causing different outcomes depending on which iteration the failure occurs in. The compiler can unroll the loop, but it cannot algebraically reduce multiple operations into fewer equivalent operations.
"""

# ╔═╡ 4f7f7324-4842-4850-8fa9-98ceb91af1d8
md"""
The most reasonable alternative to having integer arithmetic silently overflow is to do checked arithmetic everywhere, raising errors when adds, subtracts, and multiplies overflow, producing values that are not value-correct. In this [blog post](https://danluu.com/integer-overflow/), Dan Luu analyzes this and finds that rather than the trivial cost that this approach should in theory have, it ends up having a substantial cost due to compilers (LLVM and GCC) not gracefully optimizing around the added overflow checks. If this improves in the future, we could consider defaulting to checked integer arithmetic in Julia, but for now, we have to live with the possibility of overflow.
"""

# ╔═╡ 9c1bfa14-0847-481b-bb43-927ffad9f8af
md"""
In the meantime, overflow-safe integer operations can be achieved through the use of external libraries such as [SaferIntegers.jl](https://github.com/JeffreySarnoff/SaferIntegers.jl). Note that, as stated previously, the use of these libraries significantly increases the execution time of code using the checked integer types. However, for limited usage, this is far less of an issue than if it were used for all integer operations. You can follow the status of the discussion [here](https://github.com/JuliaLang/julia/issues/855).
"""

# ╔═╡ bc2aa99d-1153-4f38-a9e0-2bc033c4b01c
md"""
### What are the possible causes of an `UndefVarError` during remote execution?
"""

# ╔═╡ 7351dbc5-a5f8-4c9d-9e6d-0b48187446ad
md"""
As the error states, an immediate cause of an `UndefVarError` on a remote node is that a binding by that name does not exist. Let us explore some of the possible causes.
"""

# ╔═╡ ce655567-8742-4d43-8f70-939ecb1c435e
module Foo
     foo() = remotecall_fetch(x->x, 2, "Hello")
 end

# ╔═╡ 0a4a9bb4-f101-4152-a48d-95f6d94e3655
Foo.foo()

# ╔═╡ e2fc2b89-fe5c-4d46-8e99-ecfb1915c727
md"""
The closure `x->x` carries a reference to `Foo`, and since `Foo` is unavailable on node 2, an `UndefVarError` is thrown.
"""

# ╔═╡ 05e108b8-ae59-4aca-8e20-2be70e58d58f
md"""
Globals under modules other than `Main` are not serialized by value to the remote node. Only a reference is sent. Functions which create global bindings (except under `Main`) may cause an `UndefVarError` to be thrown later.
"""

# ╔═╡ 63b9a9b1-b9b6-4670-8bcc-d0fdd6dc46a8
@everywhere module Foo
     function foo()
         global gvar = "Hello"
         remotecall_fetch(()->gvar, 2)
     end
 end

# ╔═╡ e15d207c-e731-4400-b728-6f59d831a491
Foo.foo()

# ╔═╡ 509a0da6-153f-4d04-a1d8-019fc98b0178
md"""
In the above example, `@everywhere module Foo` defined `Foo` on all nodes. However the call to `Foo.foo()` created a new global binding `gvar` on the local node, but this was not found on node 2 resulting in an `UndefVarError` error.
"""

# ╔═╡ d640d5f9-514b-4544-bd5c-4e1f324f7948
md"""
Note that this does not apply to globals created under module `Main`. Globals under module `Main` are serialized and new bindings created under `Main` on the remote node.
"""

# ╔═╡ a3a92b6d-da01-46e7-85ad-0727975e1115
gvar_self = "Node1"

# ╔═╡ c0dfa5d7-64ea-4ac6-813e-520150149958
remotecall_fetch(()->gvar_self, 2)

# ╔═╡ 3b2f1d6a-afc3-4d91-9e2d-11a20c68cc27
remotecall_fetch(varinfo, 2)

# ╔═╡ 7054390b-548a-4b16-b579-3e94bbf7905f
md"""
This does not apply to `function` or `struct` declarations. However, anonymous functions bound to global variables are serialized as can be seen below.
"""

# ╔═╡ bd4dd754-2c8a-40ab-8b9b-13ae7d31769d
bar() = 1

# ╔═╡ 3da7b72e-d3c1-4ec9-b5dc-ff36dbbaaa84
remotecall_fetch(bar, 2)

# ╔═╡ 7c965758-1bfb-49a7-83d8-dae547d8aaf4
anon_bar  = ()->1

# ╔═╡ f66004c9-e0b8-4279-8303-27053b8dbaf4
remotecall_fetch(anon_bar, 2)

# ╔═╡ aca847b9-7fd5-4b4d-b627-a4ada59fc690
md"""
### Why does Julia use `*` for string concatenation? Why not `+` or something else?
"""

# ╔═╡ 198e9539-8760-4687-82a5-d3236ac16e3f
md"""
The [main argument](@ref man-concatenation) against `+` is that string concatenation is not commutative, while `+` is generally used as a commutative operator. While the Julia community recognizes that other languages use different operators and `*` may be unfamiliar for some users, it communicates certain algebraic properties.
"""

# ╔═╡ 8c2b49ab-e6b3-4b00-8a25-40e77c1de272
md"""
Note that you can also use `string(...)` to concatenate strings (and other values converted to strings); similarly, `repeat` can be used instead of `^` to repeat strings. The [interpolation syntax](@ref string-interpolation) is also useful for constructing strings.
"""

# ╔═╡ 97fa12de-c65f-49cc-9f8d-b608aafe7e60
md"""
## Packages and Modules
"""

# ╔═╡ 1391764c-dfc6-45ed-819a-be4279e2e69f
md"""
### What is the difference between \"using\" and \"import\"?
"""

# ╔═╡ 6ecd99cb-3db0-4738-abae-a2ec942d2aaa
md"""
There is only one difference, and on the surface (syntax-wise) it may seem very minor. The difference between `using` and `import` is that with `using` you need to say `function Foo.bar(..` to extend module Foo's function bar with a new method, but with `import Foo.bar`, you only need to say `function bar(...` and it automatically extends module Foo's function bar.
"""

# ╔═╡ 9d239c03-79fe-4f51-a2a8-61e22fa27b45
md"""
The reason this is important enough to have been given separate syntax is that you don't want to accidentally extend a function that you didn't know existed, because that could easily cause a bug. This is most likely to happen with a method that takes a common type like a string or integer, because both you and the other module could define a method to handle such a common type. If you use `import`, then you'll replace the other module's implementation of `bar(s::AbstractString)` with your new implementation, which could easily do something completely different (and break all/many future usages of the other functions in module Foo that depend on calling bar).
"""

# ╔═╡ 15571d16-8cba-48a5-bc36-9994c2591082
md"""
## Nothingness and missing values
"""

# ╔═╡ 16f74201-2f7c-4d41-8ea9-178faa8d0a4c
md"""
### [How does \"null\", \"nothingness\" or \"missingness\" work in Julia?](@id faq-nothing)
"""

# ╔═╡ 3e2dc20c-024d-444f-9270-5bb6ab744f61
md"""
Unlike many languages (for example, C and Java), Julia objects cannot be \"null\" by default. When a reference (variable, object field, or array element) is uninitialized, accessing it will immediately throw an error. This situation can be detected using the [`isdefined`](@ref) or [`isassigned`](@ref Base.isassigned) functions.
"""

# ╔═╡ 1350de19-f615-4226-9402-6b4d9a7f931f
md"""
Some functions are used only for their side effects, and do not need to return a value. In these cases, the convention is to return the value `nothing`, which is just a singleton object of type `Nothing`. This is an ordinary type with no fields; there is nothing special about it except for this convention, and that the REPL does not print anything for it. Some language constructs that would not otherwise have a value also yield `nothing`, for example `if false; end`.
"""

# ╔═╡ d2c7c441-4d47-4ec9-9cb9-ffcb78401854
md"""
For situations where a value `x` of type `T` exists only sometimes, the `Union{T, Nothing}` type can be used for function arguments, object fields and array element types as the equivalent of [`Nullable`, `Option` or `Maybe`](https://en.wikipedia.org/wiki/Nullable_type) in other languages. If the value itself can be `nothing` (notably, when `T` is `Any`), the `Union{Some{T}, Nothing}` type is more appropriate since `x == nothing` then indicates the absence of a value, and `x == Some(nothing)` indicates the presence of a value equal to `nothing`. The [`something`](@ref) function allows unwrapping `Some` objects and using a default value instead of `nothing` arguments. Note that the compiler is able to generate efficient code when working with `Union{T, Nothing}` arguments or fields.
"""

# ╔═╡ 79dfbb16-94b4-4fab-b078-c193fe2abcf3
md"""
To represent missing data in the statistical sense (`NA` in R or `NULL` in SQL), use the [`missing`](@ref) object. See the [`Missing Values`](@ref missing) section for more details.
"""

# ╔═╡ aedbdc14-75ce-4c54-9ac8-007c354d8ed6
md"""
In some languages, the empty tuple (`()`) is considered the canonical form of nothingness. However, in julia it is best thought of as just a regular tuple that happens to contain zero values.
"""

# ╔═╡ 35ed3adb-b7c6-460a-8e3a-63e1447899fc
md"""
The empty (or \"bottom\") type, written as `Union{}` (an empty union type), is a type with no values and no subtypes (except itself). You will generally not need to use this type.
"""

# ╔═╡ 999048a4-e276-47d7-b5bc-4b226c8dbec5
md"""
## Memory
"""

# ╔═╡ ff3e0c9c-c403-45b1-b575-f554d5233471
md"""
### Why does `x += y` allocate memory when `x` and `y` are arrays?
"""

# ╔═╡ 19fad490-aa4e-449d-b243-a5e982a1cbcd
md"""
In Julia, `x += y` gets replaced during parsing by `x = x + y`. For arrays, this has the consequence that, rather than storing the result in the same location in memory as `x`, it allocates a new array to store the result.
"""

# ╔═╡ 8b062342-1f91-40d9-b268-38953b8bfa63
md"""
While this behavior might surprise some, the choice is deliberate. The main reason is the presence of immutable objects within Julia, which cannot change their value once created.  Indeed, a number is an immutable object; the statements `x = 5; x += 1` do not modify the meaning of `5`, they modify the value bound to `x`. For an immutable, the only way to change the value is to reassign it.
"""

# ╔═╡ 5a16def3-1cce-4730-ac39-b24efe8f312f
md"""
To amplify a bit further, consider the following function:
"""

# ╔═╡ 02bd2912-8d1d-4ed1-929a-923e5674d9bb
md"""
```julia
function power_by_squaring(x, n::Int)
    ispow2(n) || error(\"This implementation only works for powers of 2\")
    while n >= 2
        x *= x
        n >>= 1
    end
    x
end
```
"""

# ╔═╡ bed6b4db-3fe9-48d4-950c-9660091782ad
md"""
After a call like `x = 5; y = power_by_squaring(x, 4)`, you would get the expected result: `x == 5 && y == 625`.  However, now suppose that `*=`, when used with matrices, instead mutated the left hand side.  There would be two problems:
"""

# ╔═╡ bc4629ef-74e2-4c7c-98c3-ffaec6b5ef4a
md"""
  * For general square matrices, `A = A*B` cannot be implemented without temporary storage: `A[1,1]` gets computed and stored on the left hand side before you're done using it on the right hand side.
  * Suppose you were willing to allocate a temporary for the computation (which would eliminate most of the point of making `*=` work in-place); if you took advantage of the mutability of `x`, then this function would behave differently for mutable vs. immutable inputs. In particular, for immutable `x`, after the call you'd have (in general) `y != x`, but for mutable `x` you'd have `y == x`.
"""

# ╔═╡ 8c8ca5aa-be18-471e-9b84-fe7aa9715633
md"""
Because supporting generic programming is deemed more important than potential performance optimizations that can be achieved by other means (e.g., using explicit loops), operators like `+=` and `*=` work by rebinding new values.
"""

# ╔═╡ b63d471a-599a-41c5-805a-3d6c6b46c40b
md"""
## [Asynchronous IO and concurrent synchronous writes](@id faq-async-io)
"""

# ╔═╡ 92afc010-82b6-4ccf-a7fa-a95e71354563
md"""
### Why do concurrent writes to the same stream result in inter-mixed output?
"""

# ╔═╡ b4b58b42-3324-482a-97c2-5f7da60cf112
md"""
While the streaming I/O API is synchronous, the underlying implementation is fully asynchronous.
"""

# ╔═╡ 43d14f1c-a5ee-418e-bf55-6d3aab9bfce1
md"""
Consider the printed output from the following:
"""

# ╔═╡ adc878a5-914c-49d7-9e7d-18ac5c3b2497
@sync for i in 1:3
     @async write(stdout, string(i), " Foo ", " Bar ")
 end

# ╔═╡ f5185c8d-ca68-486e-b89c-5e6af88f8031
md"""
This is happening because, while the `write` call is synchronous, the writing of each argument yields to other tasks while waiting for that part of the I/O to complete.
"""

# ╔═╡ 96b26caa-149c-4dcc-890c-a26ed005a0a3
md"""
`print` and `println` \"lock\" the stream during a call. Consequently changing `write` to `println` in the above example results in:
"""

# ╔═╡ c26e2cfa-c85f-44df-b4f5-23579b9c15b2
@sync for i in 1:3
     @async println(stdout, string(i), " Foo ", " Bar ")
 end

# ╔═╡ cd33232c-9bfe-40da-a2fe-dcd3ad86af3d
md"""
You can lock your writes with a `ReentrantLock` like this:
"""

# ╔═╡ 91484781-df33-4a03-88cc-6908845b1a54
l = ReentrantLock();

# ╔═╡ 167ce136-308d-428c-9059-7aa560564c19
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

# ╔═╡ bf6b8d0b-5aad-422b-9e27-d031e4635469
md"""
## Arrays
"""

# ╔═╡ 10c89ee5-7da2-4c69-b703-4942824058aa
md"""
### What are the differences between zero-dimensional arrays and scalars?
"""

# ╔═╡ dec588b2-fc9d-4589-ae75-8012ddf7f8cc
md"""
Zero-dimensional arrays are arrays of the form `Array{T,0}`. They behave similar to scalars, but there are important differences. They deserve a special mention because they are a special case which makes logical sense given the generic definition of arrays, but might be a bit unintuitive at first. The following line defines a zero-dimensional array:
"""

# ╔═╡ bb53c793-d83f-44ba-8ab0-37829c36e29a
md"""
```
julia> A = zeros()
0-dimensional Array{Float64,0}:
0.0
```
"""

# ╔═╡ 698c1b7f-5c3b-40c5-83cd-64cb361c0afc
md"""
In this example, `A` is a mutable container that contains one element, which can be set by `A[] = 1.0` and retrieved with `A[]`. All zero-dimensional arrays have the same size (`size(A) == ()`), and length (`length(A) == 1`). In particular, zero-dimensional arrays are not empty. If you find this unintuitive, here are some ideas that might help to understand Julia's definition.
"""

# ╔═╡ 361f3ff9-43cb-4252-81ca-1a4033eb8611
md"""
  * Zero-dimensional arrays are the \"point\" to vector's \"line\" and matrix's \"plane\". Just as a line has no area (but still represents a set of things), a point has no length or any dimensions at all (but still represents a thing).
  * We define `prod(())` to be 1, and the total number of elements in an array is the product of the size. The size of a zero-dimensional array is `()`, and therefore its length is `1`.
  * Zero-dimensional arrays don't natively have any dimensions into which you index – they’re just `A[]`. We can apply the same \"trailing one\" rule for them as for all other array dimensionalities, so you can indeed index them as `A[1]`, `A[1,1]`, etc; see [Omitted and extra indices](@ref).
"""

# ╔═╡ 3e22354e-398f-41bb-9845-d6fe8b11c878
md"""
It is also important to understand the differences to ordinary scalars. Scalars are not mutable containers (even though they are iterable and define things like `length`, `getindex`, *e.g.* `1[] == 1`). In particular, if `x = 0.0` is defined as a scalar, it is an error to attempt to change its value via `x[] = 1.0`. A scalar `x` can be converted into a zero-dimensional array containing it via `fill(x)`, and conversely, a zero-dimensional array `a` can be converted to the contained scalar via `a[]`. Another difference is that a scalar can participate in linear algebra operations such as `2 * rand(2,2)`, but the analogous operation with a zero-dimensional array `fill(2) * rand(2,2)` is an error.
"""

# ╔═╡ a81119b3-0c60-4e2b-87c2-046e5670c3dd
md"""
### Why are my Julia benchmarks for linear algebra operations different from other languages?
"""

# ╔═╡ 83ba1b5c-d25b-4f85-bd3e-d537196a2c94
md"""
You may find that simple benchmarks of linear algebra building blocks like
"""

# ╔═╡ a57d31f7-99c7-43e8-8e2d-151c7b868dff
md"""
```julia
using BenchmarkTools
A = randn(1000, 1000)
B = randn(1000, 1000)
@btime $A \ $B
@btime $A * $B
```
"""

# ╔═╡ 914648ef-1cd2-492f-a2e2-6ad33556d022
md"""
can be different when compared to other languages like Matlab or R.
"""

# ╔═╡ cdbb5c45-73e9-4020-a2b2-57c2cb1aa861
md"""
Since operations like this are very thin wrappers over the relevant BLAS functions, the reason for the discrepancy is very likely to be
"""

# ╔═╡ e388815f-8fc6-48d0-9225-5485b9f18a35
md"""
1. the BLAS library each language is using,
2. the number of concurrent threads.
"""

# ╔═╡ 07a37042-7747-4f9d-8faf-36ac44c988fa
md"""
Julia compiles and uses its own copy of OpenBLAS, with threads currently capped at `8` (or the number of your cores).
"""

# ╔═╡ ed789128-19cd-407f-90b0-ad40633e108a
md"""
Modifying OpenBLAS settings or compiling Julia with a different BLAS library, eg [Intel MKL](https://software.intel.com/en-us/mkl), may provide performance improvements. You can use [MKL.jl](https://github.com/JuliaComputing/MKL.jl), a package that makes Julia's linear algebra use Intel MKL BLAS and LAPACK instead of OpenBLAS, or search the discussion forum for suggestions on how to set this up manually. Note that Intel MKL cannot be bundled with Julia, as it is not open source.
"""

# ╔═╡ 025eb1ad-eeda-4028-af1d-259732248cae
md"""
## Computing cluster
"""

# ╔═╡ 2e6bf78a-bd60-4bbd-9d7a-7dfe527b6207
md"""
### How do I manage precompilation caches in distributed file systems?
"""

# ╔═╡ a6c07291-8c40-4a0b-a3db-fa31bbcf8ef9
md"""
When using `julia` in high-performance computing (HPC) facilities, invoking *n* `julia` processes simultaneously creates at most *n* temporary copies of precompilation cache files. If this is an issue (slow and/or small distributed file system), you may:
"""

# ╔═╡ f0531088-b2f2-4811-a7c6-159d1f2c09b7
md"""
1. Use `julia` with `--compiled-modules=no` flag to turn off precompilation.
2. Configure a private writable depot using `pushfirst!(DEPOT_PATH, private_path)` where `private_path` is a path unique to this `julia` process.  This can also be done by setting environment variable `JULIA_DEPOT_PATH` to `$private_path:$HOME/.julia`.
3. Create a symlink from `~/.julia/compiled` to a directory in a scratch space.
"""

# ╔═╡ c467f7a0-b88f-417a-93d3-f2badde01351
md"""
## Julia Releases
"""

# ╔═╡ 2c4eeffa-2ac5-427d-bb46-50ddb186c38b
md"""
### Do I want to use the Stable, LTS, or nightly version of Julia?
"""

# ╔═╡ 37bf946d-c99d-4e43-90b2-053c84e4497c
md"""
The Stable version of Julia is the latest released version of Julia, this is the version most people will want to run. It has the latest features, including improved performance. The Stable version of Julia is versioned according to [SemVer](https://semver.org/) as v1.x.y. A new minor release of Julia corresponding to a new Stable version is made approximately every 4-5 months after a few weeks of testing as a release candidate. Unlike the LTS version the a Stable version will not normally recieve bugfixes after another Stable version of Julia has been released. However, upgrading to the next Stable release will always be possible as each release of Julia v1.x will continue to run code written for earlier versions.
"""

# ╔═╡ a74d59eb-31c4-4a43-b97e-7abe2115b95f
md"""
You may prefer the LTS (Long Term Support) version of Julia if you are looking for a very stable code base. The current LTS version of Julia is versioned according to SemVer as v1.0.x; this branch will continue to recieve bugfixes until a new LTS branch is chosen, at which point the v1.0.x series will no longer recieved regular bug fixes and all but the most conservative users will be advised to upgrade to the new LTS version series. As a package developer, you may prefer to develop for the LTS version, to maximize the number of users who can use your package. As per SemVer, code written for v1.0 will continue to work for all future LTS and Stable versions. In general, even if targetting the LTS, one can develop and run code in the latest Stable version, to take advantage of the improved performance; so long as one avoids using new features (such as added library functions or new methods).
"""

# ╔═╡ d42089eb-4999-4048-8a95-a949ab2349ad
md"""
You may prefer the nightly version of Julia if you want to take advantage of the latest updates to the language, and don't mind if the version available today occasionally doesn't actually work. As the name implies, releases to the nightly version are made roughly every night (depending on build infrastructure stability). In general nightly released are fairly safe to use—your code will not catch on fire. However, they may be occasional regressions and or issues that will not be found until more thorough pre-release testing. You may wish to test against the nightly version to ensure that such regressions that affect your use case are caught before a release is made.
"""

# ╔═╡ 07096e19-5f72-487a-bc31-4993146c78db
md"""
Finally, you may also consider building Julia from source for yourself. This option is mainly for those individuals who are comfortable at the command line, or interested in learning. If this describes you, you may also be interested in reading our [guidelines for contributing](https://github.com/JuliaLang/julia/blob/master/CONTRIBUTING.md).
"""

# ╔═╡ 4bbca96b-3e7b-4c9b-abcf-0503a0d6d0b9
md"""
Links to each of these download types can be found on the download page at [https://julialang.org/downloads/](https://julialang.org/downloads/). Note that not all versions of Julia are available for all platforms.
"""

# ╔═╡ f978e856-190f-4fd0-8cc0-880ac183347f
md"""
### How can I transfer the list of installed packages after updating my version of Julia?
"""

# ╔═╡ aba2fffc-b6b1-4bb7-93eb-b8bb903368f3
md"""
Each minor version of julia has its own default [environment](https://docs.julialang.org/en/v1/manual/code-loading/#Environments-1). As a result, upon installing a new minor version of Julia, the packages you added using the previous minor version will not be available by default. The environment for a given julia version is defined by the files `Project.toml` and `Manifest.toml` in a folder matching the version number in `.julia/environments/`, for instance, `.julia/environments/v1.3`.
"""

# ╔═╡ 64990821-c597-4f1b-ae8a-55bb526d1a70
md"""
If you install a new minor version of Julia, say `1.4`, and want to use in its default environment the same packages as in a previous version (e.g. `1.3`), you can copy the contents of the file `Project.toml` from the `1.3` folder to `1.4`. Then, in a session of the new Julia version, enter the \"package management mode\" by typing the key `]`, and run the command [`instantiate`](https://julialang.github.io/Pkg.jl/v1/api/#Pkg.instantiate).
"""

# ╔═╡ 47575362-eea3-45d9-9be6-69ab5215baf5
md"""
This operation will resolve a set of feasible packages from the copied file that are compatible with the target Julia version, and will install or update them if suitable. If you want to reproduce not only the set of packages, but also the versions you were using in the previous Julia version, you should also copy the `Manifest.toml` file before running the Pkg command `instantiate`. However, note that packages may define compatibility constraints that may be affected by changing the version of Julia, so the exact set of versions you had in `1.3` may not work for `1.4`.
"""

# ╔═╡ Cell order:
# ╟─77b62a7e-7c19-481f-8f71-89d20f95e201
# ╟─3f4d6474-e03a-47c8-9fc8-7f8d681bcd35
# ╟─d0ef0d39-e4e5-48c9-8dda-35e185135608
# ╟─5a7f3387-d811-4e5f-b4a0-7896160f77f7
# ╟─1268aebc-b035-4f53-bada-542a3797a77b
# ╟─05762b65-477e-4b25-a1e7-806376b7502b
# ╟─b70cf79b-732e-4871-92f2-470f2009d600
# ╟─cc81c284-d22e-43f7-8c2b-f43c77cd61f2
# ╟─0577cdd2-8d1c-4110-9657-dc89e699c31f
# ╟─f2a7b8e1-57aa-405c-b7ca-64f806f39183
# ╟─e031a339-0467-4371-9423-4c06f58b3e32
# ╟─410e91eb-3699-46a0-ba06-ebbda7db15b3
# ╟─2e3d6c25-3e3f-4e96-b4d0-23fc577a002e
# ╟─4cc95731-d48b-4eed-8388-2c002cfe8e4b
# ╟─2fe124a3-608f-4301-b20d-a2d26515fef2
# ╟─dbc4732b-5db3-42e2-afa9-0daa1dc78b00
# ╟─ccbc1be4-a935-447b-a632-b5e2e31c442f
# ╟─e198a69f-a2f5-4d9a-b476-0541fd9d0b3d
# ╟─64eb4825-70c9-4e28-a1f8-e3aad627a1b8
# ╟─73614155-e1f9-4f36-a22e-9ce7a7995a5c
# ╟─9480ee74-700e-47c3-89ef-c38e2bfe30f3
# ╟─b77b89b9-6d21-4416-b431-230e36bc42e2
# ╟─759240ef-5619-4f39-bfca-f874f482e0c1
# ╟─d0b162a8-8fce-4866-859d-77e60197051d
# ╟─9fb870f6-9c28-4ef4-9b25-7c481053de79
# ╟─f37e8707-0fa3-43df-a3a8-c1ea3f304a4e
# ╟─e0e1e211-bdcd-44e6-b148-e15ef6dd04fa
# ╟─9161c6f8-5f7b-4dc1-95d1-abde1a16d679
# ╟─a40e228c-4300-4605-87c0-a7a6b3dd3cf1
# ╟─70049e74-774e-4813-8e21-1f4cbb3f97ec
# ╟─eaa62a8c-e94f-4f09-a99c-e4894663cd62
# ╟─3631b78e-e007-436e-9aed-ed9556d28695
# ╟─a8544ae6-5f2c-4de1-b847-dc0fdf14e289
# ╠═9e0f1d1e-e0c0-4b1e-a541-1f8c9d1b4f99
# ╠═b4b377de-585d-4643-96d6-6692aaaf4a91
# ╠═ffb2436d-a9d9-4331-8cf2-372e896339db
# ╠═9d5e1c51-6084-4b5b-a252-38e8110d35e0
# ╟─d9a60b64-af5b-4560-8010-53b1b6b05672
# ╟─80e3b02a-fb7c-4490-9fe9-0d54bc405441
# ╠═6f54e5f4-58e6-4d5d-a897-7e9f283a0cf6
# ╠═f2abf6e9-fbc5-4450-ad51-f6dfefbd5b82
# ╠═2b1a1f47-6d74-4570-b072-15f3df7124e3
# ╠═95c44aee-6812-4210-b004-e97d5cb51e36
# ╟─99d86351-7eea-47a9-ac0c-b7b34bb694c6
# ╟─b22f8c8f-cbd0-4f72-ad22-f771aff2b9d4
# ╟─9bc662eb-d2c1-4e7e-ac24-f2e881cce6be
# ╟─28bfedf2-72d1-4847-9646-37391bba0607
# ╟─1a850a41-0cf6-4d97-8414-dcd751bfcba2
# ╟─eed1249a-f317-4f4f-942a-3cbb4144ab91
# ╟─435a14d7-6926-4886-be6c-b3011f0ec1d3
# ╟─d8b90f3a-9ea1-45da-8473-ca0490f84eda
# ╟─2c684706-eef6-444b-8631-92bacf428f48
# ╠═8b8b70ab-35bb-45de-90e3-7aebffcd6cbe
# ╠═39a60bd5-b78b-417d-b5e1-953efa646e4b
# ╟─fe908672-bcd8-44b1-a58a-2e1ff4c3a852
# ╟─c7ea9a48-34be-4fd6-a346-7cf10d9f0b44
# ╟─555a7b7c-0eb4-4917-9121-d62d319ba5e7
# ╠═3a1d07fe-ca90-44bc-91f1-4c09f7e1d09c
# ╠═978e216e-062f-46d2-91dc-05d66bb104d5
# ╠═a711c141-023b-4d53-9566-42d0b041cf93
# ╟─1ee4564e-db74-4333-a05d-194f8104e350
# ╟─031e8936-c5e3-4e2c-927b-b179a0f047b3
# ╟─59f718c4-e098-4845-ba7f-4c46fb08b0a9
# ╠═243f0ef8-2d22-435f-8642-6cf544cfc5a3
# ╠═64f2a444-7e95-4234-9c1b-8a5e9de6f638
# ╠═ac9b726b-9171-40bd-9922-14b639720a0e
# ╠═3710dedb-62f1-4b0c-a7d7-f4b4d0c91d4b
# ╟─cfe7075f-a7df-48e2-a8a4-84f944069773
# ╠═2eddbfc1-0660-48a8-aa15-ad598af7e07e
# ╠═4bf8acde-5225-46b2-9d93-515eb7d9fb26
# ╠═4f9b98aa-e628-447a-b935-e644c75ed776
# ╠═035e924e-3456-44d0-bf27-ff3ff4818d24
# ╟─da9d5b0b-b36f-4b0a-9c56-fb12fc5bd66a
# ╟─99775cff-e775-4b2b-b102-339ad7012ef8
# ╟─57cab9ab-c8a1-4609-8ab3-ec2a986eaa7e
# ╠═4c1b4906-6d33-4c12-aaed-cab017970d0e
# ╟─a6c837e4-65a3-4086-a8d0-803725ebb6c4
# ╟─2aaade92-4518-4aba-a2d9-7333e92548f7
# ╟─bcb31c6d-a493-405b-9192-765ce0b12fd2
# ╠═7c7033e9-dc50-462f-8ce1-2407246e64ac
# ╟─54e47d3a-d39e-406b-ac70-ec03e3bf801d
# ╟─ffc3c3ab-8e80-4e83-818e-b4f76a60d7e1
# ╠═b3bab550-f321-4e3e-b4cc-b426b5b263f6
# ╟─8c3f46f8-d6ad-49ef-aa9b-33718d392c42
# ╟─a5baafd9-1566-49d8-a9cf-e89d17b52bde
# ╟─eccfb30e-7db6-4429-b908-276b37e24ac7
# ╟─a310cae6-988f-4da0-8124-7c6be117702d
# ╟─64d51ada-f4b8-4f48-8ad4-9fefdcdcf848
# ╟─dcaa5fff-660a-44b0-b4d6-f5a15a9d0a89
# ╟─79538e16-b482-4aee-9115-3f8031b0402a
# ╟─a8301041-3309-4820-95e0-4cf19fa51f96
# ╟─fdd3e920-516d-4b78-ba1a-406afc1825dc
# ╟─00c074be-de6b-45ac-ab6b-7b4bb25565a1
# ╠═cadf750c-0b1b-4d1c-a932-af867907b352
# ╠═3a8d9cb2-15e3-4763-8cde-4ca75f3d6602
# ╠═6db5330b-87d9-4fb5-8c2b-407c35a68462
# ╠═4e20fcad-c176-4985-be4e-5beb2f8b1f71
# ╟─a8892deb-40b4-42bb-96f0-55d91b8a693d
# ╟─9b09deb6-5f3d-4e9a-81bc-35e3fd29179c
# ╟─dd1489c6-897f-44d4-9447-ee295cd48119
# ╟─4fcbb09b-8628-4ac9-94b5-c7f120328f6b
# ╟─e4b817c5-db2a-4700-b298-a2699565d060
# ╟─ca1964f6-7cb1-482e-8746-aa4a5d3bf1ab
# ╟─ac3c3712-7a64-4b17-a24a-077d9ca8b5a4
# ╟─5ff65eab-8967-476d-8374-220b6551c6bc
# ╠═7ac015c5-73ba-41c6-a867-3881dc4fab8b
# ╠═b3e722ab-4175-48a9-976d-708129831fa5
# ╟─ea8f197a-deec-43a4-b4e3-42ff014235e5
# ╟─c96a7d85-6f19-4974-8818-78219112bbd5
# ╟─6dfa32be-c633-4c20-b6e2-636d83b023ff
# ╟─cdf95c0a-51b9-47e0-9dd5-aab3f8c09d76
# ╠═705ac6f0-23d7-471c-9834-36645e0207f9
# ╟─e144ce0d-255d-41b1-bd57-da7585bc77fc
# ╠═e743ff63-ee77-464e-9c8d-41774377bc7b
# ╠═04dadaf7-1700-4c23-b985-1c99e8eabc38
# ╟─c4968316-13b2-4fe5-b55d-49d6fd144003
# ╠═3c5c7b8c-718c-41b4-82ba-76b5f119bdaf
# ╠═48673b68-8f51-4b8c-b86a-deb3a68b9b3e
# ╟─dfee9a05-2053-43eb-afaf-eada9ab3a60c
# ╟─4f7f7324-4842-4850-8fa9-98ceb91af1d8
# ╟─9c1bfa14-0847-481b-bb43-927ffad9f8af
# ╟─bc2aa99d-1153-4f38-a9e0-2bc033c4b01c
# ╟─7351dbc5-a5f8-4c9d-9e6d-0b48187446ad
# ╠═ce655567-8742-4d43-8f70-939ecb1c435e
# ╠═0a4a9bb4-f101-4152-a48d-95f6d94e3655
# ╟─e2fc2b89-fe5c-4d46-8e99-ecfb1915c727
# ╟─05e108b8-ae59-4aca-8e20-2be70e58d58f
# ╠═63b9a9b1-b9b6-4670-8bcc-d0fdd6dc46a8
# ╠═e15d207c-e731-4400-b728-6f59d831a491
# ╟─509a0da6-153f-4d04-a1d8-019fc98b0178
# ╟─d640d5f9-514b-4544-bd5c-4e1f324f7948
# ╠═a3a92b6d-da01-46e7-85ad-0727975e1115
# ╠═c0dfa5d7-64ea-4ac6-813e-520150149958
# ╠═3b2f1d6a-afc3-4d91-9e2d-11a20c68cc27
# ╟─7054390b-548a-4b16-b579-3e94bbf7905f
# ╠═bd4dd754-2c8a-40ab-8b9b-13ae7d31769d
# ╠═3da7b72e-d3c1-4ec9-b5dc-ff36dbbaaa84
# ╠═7c965758-1bfb-49a7-83d8-dae547d8aaf4
# ╠═f66004c9-e0b8-4279-8303-27053b8dbaf4
# ╟─aca847b9-7fd5-4b4d-b627-a4ada59fc690
# ╟─198e9539-8760-4687-82a5-d3236ac16e3f
# ╟─8c2b49ab-e6b3-4b00-8a25-40e77c1de272
# ╟─97fa12de-c65f-49cc-9f8d-b608aafe7e60
# ╟─1391764c-dfc6-45ed-819a-be4279e2e69f
# ╟─6ecd99cb-3db0-4738-abae-a2ec942d2aaa
# ╟─9d239c03-79fe-4f51-a2a8-61e22fa27b45
# ╟─15571d16-8cba-48a5-bc36-9994c2591082
# ╟─16f74201-2f7c-4d41-8ea9-178faa8d0a4c
# ╟─3e2dc20c-024d-444f-9270-5bb6ab744f61
# ╟─1350de19-f615-4226-9402-6b4d9a7f931f
# ╟─d2c7c441-4d47-4ec9-9cb9-ffcb78401854
# ╟─79dfbb16-94b4-4fab-b078-c193fe2abcf3
# ╟─aedbdc14-75ce-4c54-9ac8-007c354d8ed6
# ╟─35ed3adb-b7c6-460a-8e3a-63e1447899fc
# ╟─999048a4-e276-47d7-b5bc-4b226c8dbec5
# ╟─ff3e0c9c-c403-45b1-b575-f554d5233471
# ╟─19fad490-aa4e-449d-b243-a5e982a1cbcd
# ╟─8b062342-1f91-40d9-b268-38953b8bfa63
# ╟─5a16def3-1cce-4730-ac39-b24efe8f312f
# ╟─02bd2912-8d1d-4ed1-929a-923e5674d9bb
# ╟─bed6b4db-3fe9-48d4-950c-9660091782ad
# ╟─bc4629ef-74e2-4c7c-98c3-ffaec6b5ef4a
# ╟─8c8ca5aa-be18-471e-9b84-fe7aa9715633
# ╟─b63d471a-599a-41c5-805a-3d6c6b46c40b
# ╟─92afc010-82b6-4ccf-a7fa-a95e71354563
# ╟─b4b58b42-3324-482a-97c2-5f7da60cf112
# ╟─43d14f1c-a5ee-418e-bf55-6d3aab9bfce1
# ╠═adc878a5-914c-49d7-9e7d-18ac5c3b2497
# ╟─f5185c8d-ca68-486e-b89c-5e6af88f8031
# ╟─96b26caa-149c-4dcc-890c-a26ed005a0a3
# ╠═c26e2cfa-c85f-44df-b4f5-23579b9c15b2
# ╟─cd33232c-9bfe-40da-a2fe-dcd3ad86af3d
# ╠═91484781-df33-4a03-88cc-6908845b1a54
# ╠═167ce136-308d-428c-9059-7aa560564c19
# ╟─bf6b8d0b-5aad-422b-9e27-d031e4635469
# ╟─10c89ee5-7da2-4c69-b703-4942824058aa
# ╟─dec588b2-fc9d-4589-ae75-8012ddf7f8cc
# ╟─bb53c793-d83f-44ba-8ab0-37829c36e29a
# ╟─698c1b7f-5c3b-40c5-83cd-64cb361c0afc
# ╟─361f3ff9-43cb-4252-81ca-1a4033eb8611
# ╟─3e22354e-398f-41bb-9845-d6fe8b11c878
# ╟─a81119b3-0c60-4e2b-87c2-046e5670c3dd
# ╟─83ba1b5c-d25b-4f85-bd3e-d537196a2c94
# ╟─a57d31f7-99c7-43e8-8e2d-151c7b868dff
# ╟─914648ef-1cd2-492f-a2e2-6ad33556d022
# ╟─cdbb5c45-73e9-4020-a2b2-57c2cb1aa861
# ╟─e388815f-8fc6-48d0-9225-5485b9f18a35
# ╟─07a37042-7747-4f9d-8faf-36ac44c988fa
# ╟─ed789128-19cd-407f-90b0-ad40633e108a
# ╟─025eb1ad-eeda-4028-af1d-259732248cae
# ╟─2e6bf78a-bd60-4bbd-9d7a-7dfe527b6207
# ╟─a6c07291-8c40-4a0b-a3db-fa31bbcf8ef9
# ╟─f0531088-b2f2-4811-a7c6-159d1f2c09b7
# ╟─c467f7a0-b88f-417a-93d3-f2badde01351
# ╟─2c4eeffa-2ac5-427d-bb46-50ddb186c38b
# ╟─37bf946d-c99d-4e43-90b2-053c84e4497c
# ╟─a74d59eb-31c4-4a43-b97e-7abe2115b95f
# ╟─d42089eb-4999-4048-8a95-a949ab2349ad
# ╟─07096e19-5f72-487a-bc31-4993146c78db
# ╟─4bbca96b-3e7b-4c9b-abcf-0503a0d6d0b9
# ╟─f978e856-190f-4fd0-8cc0-880ac183347f
# ╟─aba2fffc-b6b1-4bb7-93eb-b8bb903368f3
# ╟─64990821-c597-4f1b-ae8a-55bb526d1a70
# ╟─47575362-eea3-45d9-9be6-69ab5215baf5
