### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ 03d38cde-9e19-11eb-1cd8-0bd3695568ef
md"""
# [Performance Tips](@id man-performance-tips)
"""

# ╔═╡ 03d38d10-9e19-11eb-029e-31f83d536d30
md"""
In the following sections, we briefly go through a few techniques that can help make your Julia code run as fast as possible.
"""

# ╔═╡ 03d38d30-9e19-11eb-24d3-4149dcc47a42
md"""
## Avoid global variables
"""

# ╔═╡ 03d38d56-9e19-11eb-2add-035443ef98e8
md"""
A global variable might have its value, and therefore its type, change at any point. This makes it difficult for the compiler to optimize code using global variables. Variables should be local, or passed as arguments to functions, whenever possible.
"""

# ╔═╡ 03d38d62-9e19-11eb-3594-875106645281
md"""
Any code that is performance critical or being benchmarked should be inside a function.
"""

# ╔═╡ 03d38d74-9e19-11eb-0193-e99e86efec31
md"""
We find that global names are frequently constants, and declaring them as such greatly improves performance:
"""

# ╔═╡ 03d38dc2-9e19-11eb-241f-7bc2e3f1d9c9
md"""
```julia
const DEFAULT_VAL = 0
```
"""

# ╔═╡ 03d38dce-9e19-11eb-100d-1960c67537a3
md"""
Uses of non-constant globals can be optimized by annotating their types at the point of use:
"""

# ╔═╡ 03d38df4-9e19-11eb-096c-0d79743cfad7
md"""
```julia
global x = rand(1000)

function loop_over_global()
    s = 0.0
    for i in x::Vector{Float64}
        s += i
    end
    return s
end
```
"""

# ╔═╡ 03d38e00-9e19-11eb-2908-6b189ac2f863
md"""
Passing arguments to functions is better style. It leads to more reusable code and clarifies what the inputs and outputs are.
"""

# ╔═╡ 03d38efc-9e19-11eb-2806-afa4306501eb
md"""
!!! note
    All code in the REPL is evaluated in global scope, so a variable defined and assigned at top level will be a **global** variable. Variables defined at top level scope inside modules are also global.
"""

# ╔═╡ 03d38f22-9e19-11eb-1090-87bd31841bfa
md"""
In the following REPL session:
"""

# ╔═╡ 03d3936e-9e19-11eb-2f48-d93242ffda15
x = 1.0

# ╔═╡ 03d3938c-9e19-11eb-3ca0-616a2de61185
md"""
is equivalent to:
"""

# ╔═╡ 03d39558-9e19-11eb-3f09-d7d6754234dc
global x = 1.0

# ╔═╡ 03d39576-9e19-11eb-3992-13ea75ef6666
md"""
so all the performance issues discussed previously apply.
"""

# ╔═╡ 03d395a8-9e19-11eb-08a4-0f4833cb3f71
md"""
## Measure performance with [`@time`](@ref) and pay attention to memory allocation
"""

# ╔═╡ 03d395bc-9e19-11eb-037b-bf1cf8c5819f
md"""
A useful tool for measuring performance is the [`@time`](@ref) macro. We here repeat the example with the global variable above, but this time with the type annotation removed:
"""

# ╔═╡ 03d39f4e-9e19-11eb-211b-698927e59c1f
x = rand(1000);

# ╔═╡ 03d39f58-9e19-11eb-3c33-f78a40f9c59c
function sum_global()
           s = 0.0
           for i in x
               s += i
           end
           return s
       end;

# ╔═╡ 03d39f6c-9e19-11eb-25db-27cc424394c4
@time sum_global()

# ╔═╡ 03d39f6c-9e19-11eb-31c4-b5bdd50abb20
@time sum_global()

# ╔═╡ 03d39fb2-9e19-11eb-37dc-fd832ea6bf7c
md"""
On the first call (`@time sum_global()`) the function gets compiled. (If you've not yet used [`@time`](@ref) in this session, it will also compile functions needed for timing.)  You should not take the results of this run seriously. For the second run, note that in addition to reporting the time, it also indicated that a significant amount of memory was allocated. We are here just computing a sum over all elements in a vector of 64-bit floats so there should be no need to allocate memory (at least not on the heap which is what `@time` reports).
"""

# ╔═╡ 03d39fd0-9e19-11eb-3941-d9b338dd3d74
md"""
Unexpected memory allocation is almost always a sign of some problem with your code, usually a problem with type-stability or creating many small temporary arrays. Consequently, in addition to the allocation itself, it's very likely that the code generated for your function is far from optimal. Take such indications seriously and follow the advice below.
"""

# ╔═╡ 03d39fee-9e19-11eb-1fad-45989c63b090
md"""
If we instead pass `x` as an argument to the function it no longer allocates memory (the allocation reported below is due to running the `@time` macro in global scope) and is significantly faster after the first call:
"""

# ╔═╡ 03d3a816-9e19-11eb-01a6-6752e58e99dc
x = rand(1000);

# ╔═╡ 03d3a836-9e19-11eb-2c0a-632f0698398e
function sum_arg(x)
           s = 0.0
           for i in x
               s += i
           end
           return s
       end;

# ╔═╡ 03d3a836-9e19-11eb-0f8c-892e3e72d4a7
@time sum_arg(x)

# ╔═╡ 03d3a840-9e19-11eb-2892-65da750f22dc
@time sum_arg(x)

# ╔═╡ 03d3a85e-9e19-11eb-1834-e1894bb49bfa
md"""
The 1 allocation seen is from running the `@time` macro itself in global scope. If we instead run the timing in a function, we can see that indeed no allocations are performed:
"""

# ╔═╡ 03d3ab06-9e19-11eb-2706-1b333df15cf5
time_sum(x) = @time sum_arg(x);

# ╔═╡ 03d3ab06-9e19-11eb-0472-69a8d49b4603
time_sum(x)

# ╔═╡ 03d3ab42-9e19-11eb-39a9-7723f82bde67
md"""
In some situations, your function may need to allocate memory as part of its operation, and this can complicate the simple picture above. In such cases, consider using one of the [tools](@ref tools) below to diagnose problems, or write a version of your function that separates allocation from its algorithmic aspects (see [Pre-allocating outputs](@ref)).
"""

# ╔═╡ 03d3abbc-9e19-11eb-3ec9-4981fed825cf
md"""
!!! note
    For more serious benchmarking, consider the [BenchmarkTools.jl](https://github.com/JuliaCI/BenchmarkTools.jl) package which among other things evaluates the function multiple times in order to reduce noise.
"""

# ╔═╡ 03d3abd8-9e19-11eb-04e2-1926dcd1151b
md"""
## [Tools](@id tools)
"""

# ╔═╡ 03d3abea-9e19-11eb-2fd6-8701155ded3b
md"""
Julia and its package ecosystem includes tools that may help you diagnose problems and improve the performance of your code:
"""

# ╔═╡ 03d3ad72-9e19-11eb-2d73-5f0197f26261
md"""
  * [Profiling](@ref) allows you to measure the performance of your running code and identify lines that serve as bottlenecks. For complex projects, the [ProfileView](https://github.com/timholy/ProfileView.jl) package can help you visualize your profiling results.
  * The [Traceur](https://github.com/JunoLab/Traceur.jl) package can help you find common performance problems in your code.
  * Unexpectedly-large memory allocations–as reported by [`@time`](@ref), [`@allocated`](@ref), or the profiler (through calls to the garbage-collection routines)–hint that there might be issues with your code. If you don't see another reason for the allocations, suspect a type problem.  You can also start Julia with the `--track-allocation=user` option and examine the resulting `*.mem` files to see information about where those allocations occur. See [Memory allocation analysis](@ref).
  * `@code_warntype` generates a representation of your code that can be helpful in finding expressions that result in type uncertainty. See [`@code_warntype`](@ref) below.
"""

# ╔═╡ 03d3ad9a-9e19-11eb-3d1f-c34ebbed6490
md"""
## [Avoid containers with abstract type parameters](@id man-performance-abstract-container)
"""

# ╔═╡ 03d3adae-9e19-11eb-3177-f1038bc74085
md"""
When working with parameterized types, including arrays, it is best to avoid parameterizing with abstract types where possible.
"""

# ╔═╡ 03d3adc2-9e19-11eb-080b-4fdfafda418b
md"""
Consider the following:
"""

# ╔═╡ 03d3b1dc-9e19-11eb-18eb-4d9a379da976
a = Real[]

# ╔═╡ 03d3b1e6-9e19-11eb-10af-a733103beef4
push!(a, 1); push!(a, 2.0); push!(a, π)

# ╔═╡ 03d3b24a-9e19-11eb-0839-518dfaedc953
md"""
Because `a` is an array of abstract type [`Real`](@ref), it must be able to hold any `Real` value. Since `Real` objects can be of arbitrary size and structure, `a` must be represented as an array of pointers to individually allocated `Real` objects. However, if we instead only allow numbers of the same type, e.g. [`Float64`](@ref), to be stored in `a` these can be stored more efficiently:
"""

# ╔═╡ 03d3b59c-9e19-11eb-235e-7fa857852ca1
a = Float64[]

# ╔═╡ 03d3b5ba-9e19-11eb-2eb4-ef1608af8028
push!(a, 1); push!(a, 2.0); push!(a,  π)

# ╔═╡ 03d3b600-9e19-11eb-20c4-09bad066f5f9
md"""
Assigning numbers into `a` will now convert them to `Float64` and `a` will be stored as a contiguous block of 64-bit floating-point values that can be manipulated efficiently.
"""

# ╔═╡ 03d3b632-9e19-11eb-27f3-e10cd8f373e7
md"""
If you cannot avoid containers with abstract value types, it is sometimes better to parametrize with `Any` to avoid runtime type checking. E.g. `IdDict{Any, Any}` performs better than `IdDict{Type, Vector}`
"""

# ╔═╡ 03d3b666-9e19-11eb-1fdb-57bf0747f8ff
md"""
See also the discussion under [Parametric Types](@ref).
"""

# ╔═╡ 03d3b678-9e19-11eb-2209-eb91931d513e
md"""
## Type declarations
"""

# ╔═╡ 03d3b6b4-9e19-11eb-0b2d-73078a021d21
md"""
In many languages with optional type declarations, adding declarations is the principal way to make code run faster. This is *not* the case in Julia. In Julia, the compiler generally knows the types of all function arguments, local variables, and expressions. However, there are a few specific instances where declarations are helpful.
"""

# ╔═╡ 03d3b6f8-9e19-11eb-2d95-a30d040e254d
md"""
### Avoid fields with abstract type
"""

# ╔═╡ 03d3b70e-9e19-11eb-2414-db3091bb47a5
md"""
Types can be declared without specifying the types of their fields:
"""

# ╔═╡ 03d3b8bc-9e19-11eb-13d5-013c9177f3fb
struct MyAmbiguousType
           a
       end

# ╔═╡ 03d3b8e4-9e19-11eb-2679-7bb64a10be92
md"""
This allows `a` to be of any type. This can often be useful, but it does have a downside: for objects of type `MyAmbiguousType`, the compiler will not be able to generate high-performance code. The reason is that the compiler uses the types of objects, not their values, to determine how to build code. Unfortunately, very little can be inferred about an object of type `MyAmbiguousType`:
"""

# ╔═╡ 03d3bd94-9e19-11eb-09a6-6f1d4aef2435
b = MyAmbiguousType("Hello")

# ╔═╡ 03d3bdb2-9e19-11eb-0ec1-67a5e556b827
c = MyAmbiguousType(17)

# ╔═╡ 03d3bdb2-9e19-11eb-3f01-9f90f5b29207
typeof(b)

# ╔═╡ 03d3bdbc-9e19-11eb-3eb0-9d1f0454a946
typeof(c)

# ╔═╡ 03d3bdf8-9e19-11eb-3b11-19c891f51ccb
md"""
The values of `b` and `c` have the same type, yet their underlying representation of data in memory is very different. Even if you stored just numeric values in field `a`, the fact that the memory representation of a [`UInt8`](@ref) differs from a [`Float64`](@ref) also means that the CPU needs to handle them using two different kinds of instructions. Since the required information is not available in the type, such decisions have to be made at run-time. This slows performance.
"""

# ╔═╡ 03d3be2a-9e19-11eb-3513-2f58adbe534f
md"""
You can do better by declaring the type of `a`. Here, we are focused on the case where `a` might be any one of several types, in which case the natural solution is to use parameters. For example:
"""

# ╔═╡ 03d3c44c-9e19-11eb-21ac-d97e8a090b6b
mutable struct MyType{T<:AbstractFloat}
           a::T
       end

# ╔═╡ 03d3c49c-9e19-11eb-3ec3-a36ee50ede8b
md"""
This is a better choice than
"""

# ╔═╡ 03d3c686-9e19-11eb-2ec4-df1801ebbb2c
mutable struct MyStillAmbiguousType
           a::AbstractFloat
       end

# ╔═╡ 03d3c71c-9e19-11eb-1c45-1bba3f894489
md"""
because the first version specifies the type of `a` from the type of the wrapper object. For example:
"""

# ╔═╡ 03d3cbcc-9e19-11eb-263b-6d3412745cb0
m = MyType(3.2)

# ╔═╡ 03d3cbcc-9e19-11eb-10e6-e50579f15a74
t = MyStillAmbiguousType(3.2)

# ╔═╡ 03d3cbd6-9e19-11eb-3bbe-d5a7dca2a57c
typeof(m)

# ╔═╡ 03d3cbea-9e19-11eb-0382-637e78928f8f
typeof(t)

# ╔═╡ 03d3cc1c-9e19-11eb-35a2-ab2b940facf4
md"""
The type of field `a` can be readily determined from the type of `m`, but not from the type of `t`. Indeed, in `t` it's possible to change the type of the field `a`:
"""

# ╔═╡ 03d3d068-9e19-11eb-1f88-8bf0527c7f8d
typeof(t.a)

# ╔═╡ 03d3d068-9e19-11eb-19ae-2307e81eb135
t.a = 4.5f0

# ╔═╡ 03d3d072-9e19-11eb-1144-73032eaa0c76
typeof(t.a)

# ╔═╡ 03d3d0ae-9e19-11eb-3f96-09399886c2f0
md"""
In contrast, once `m` is constructed, the type of `m.a` cannot change:
"""

# ╔═╡ 03d3d32e-9e19-11eb-37b3-7d9ffa7f7991
m.a = 4.5f0

# ╔═╡ 03d3d32e-9e19-11eb-27a4-3f09d5d6b9a5
typeof(m.a)

# ╔═╡ 03d3d36a-9e19-11eb-13a5-b9a42ff084c3
md"""
The fact that the type of `m.a` is known from `m`'s type—coupled with the fact that its type cannot change mid-function—allows the compiler to generate highly-optimized code for objects like `m` but not for objects like `t`.
"""

# ╔═╡ 03d3d38a-9e19-11eb-2b33-17ecd7d877e5
md"""
Of course, all of this is true only if we construct `m` with a concrete type. We can break this by explicitly constructing it with an abstract type:
"""

# ╔═╡ 03d3d874-9e19-11eb-2a25-f934da459d51
m = MyType{AbstractFloat}(3.2)

# ╔═╡ 03d3d87e-9e19-11eb-12cf-2588baf24bc4
typeof(m.a)

# ╔═╡ 03d3d888-9e19-11eb-0236-73a886449cee
m.a = 4.5f0

# ╔═╡ 03d3d8a6-9e19-11eb-165f-bdc18583e8aa
typeof(m.a)

# ╔═╡ 03d3d8c6-9e19-11eb-0fc8-0534d2cd2ba8
md"""
For all practical purposes, such objects behave identically to those of `MyStillAmbiguousType`.
"""

# ╔═╡ 03d3d8ce-9e19-11eb-36a6-4986716d6787
md"""
It's quite instructive to compare the sheer amount code generated for a simple function
"""

# ╔═╡ 03d3d932-9e19-11eb-08e3-53d281879534
md"""
```julia
func(m::MyType) = m.a+1
```
"""

# ╔═╡ 03d3d950-9e19-11eb-2b60-6d1e29130058
md"""
using
"""

# ╔═╡ 03d3d964-9e19-11eb-0bc6-0f1aea44f5c7
md"""
```julia
code_llvm(func, Tuple{MyType{Float64}})
code_llvm(func, Tuple{MyType{AbstractFloat}})
```
"""

# ╔═╡ 03d3de8c-9e19-11eb-1938-a55c684d7a8f
md"""
For reasons of length the results are not shown here, but you may wish to try this yourself. Because the type is fully-specified in the first case, the compiler doesn't need to generate any code to resolve the type at run-time. This results in shorter and faster code.
"""

# ╔═╡ 03d3deb4-9e19-11eb-0866-cff8a15bbd8d
md"""
### Avoid fields with abstract containers
"""

# ╔═╡ 03d3df18-9e19-11eb-14de-6318b3d30a53
md"""
The same best practices also work for container types:
"""

# ╔═╡ 03d3e4a4-9e19-11eb-1dab-5982feafaccc
struct MySimpleContainer{A<:AbstractVector}
           a::A
       end

# ╔═╡ 03d3e4c2-9e19-11eb-1a0d-8fcc91ea708d
struct MyAmbiguousContainer{T}
           a::AbstractVector{T}
       end

# ╔═╡ 03d3e4d6-9e19-11eb-08f8-6106fa7339ea
md"""
For example:
"""

# ╔═╡ 03d3f55c-9e19-11eb-102b-f7ada99b5f83
c = MySimpleContainer(1:3);

# ╔═╡ 03d3f566-9e19-11eb-2dea-5ffd5cbcb49f
typeof(c)

# ╔═╡ 03d3f586-9e19-11eb-3698-d175fb53f08e
c = MySimpleContainer([1:3;]);

# ╔═╡ 03d3f586-9e19-11eb-312d-75c048f97e75
typeof(c)

# ╔═╡ 03d3f58e-9e19-11eb-11ef-a7374e14f98e
b = MyAmbiguousContainer(1:3);

# ╔═╡ 03d3f58e-9e19-11eb-0345-a57845586678
typeof(b)

# ╔═╡ 03d3f598-9e19-11eb-16c4-175b26db3089
b = MyAmbiguousContainer([1:3;]);

# ╔═╡ 03d3f5a2-9e19-11eb-3a8b-e39d6c4b7854
typeof(b)

# ╔═╡ 03d3f606-9e19-11eb-189d-713a908c1316
md"""
For `MySimpleContainer`, the object is fully-specified by its type and parameters, so the compiler can generate optimized functions. In most instances, this will probably suffice.
"""

# ╔═╡ 03d3f64a-9e19-11eb-181c-d71be02a4fdb
md"""
While the compiler can now do its job perfectly well, there are cases where *you* might wish that your code could do different things depending on the *element type* of `a`. Usually the best way to achieve this is to wrap your specific operation (here, `foo`) in a separate function:
"""

# ╔═╡ 03d4007e-9e19-11eb-324c-45cd8d77e3a7
function sumfoo(c::MySimpleContainer)
           s = 0
           for x in c.a
               s += foo(x)
           end
           s
       end

# ╔═╡ 03d40094-9e19-11eb-1d13-cf8cd2f6bec7
foo(x::Integer) = x

# ╔═╡ 03d4009c-9e19-11eb-119b-e30a93bd9edc
foo(x::AbstractFloat) = round(x)

# ╔═╡ 03d400ba-9e19-11eb-18ab-2f4e0245701f
md"""
This keeps things simple, while allowing the compiler to generate optimized code in all cases.
"""

# ╔═╡ 03d4011e-9e19-11eb-0e34-6141c546ceb3
md"""
However, there are cases where you may need to declare different versions of the outer function for different element types or types of the `AbstractVector` of the field `a` in `MySimpleContainer`. You could do it like this:
"""

# ╔═╡ 03d40e52-9e19-11eb-0b7b-2543ba49c19d
function myfunc(c::MySimpleContainer{<:AbstractArray{<:Integer}})
           return c.a[1]+1
       end

# ╔═╡ 03d40e5c-9e19-11eb-262f-9b6298c70482
function myfunc(c::MySimpleContainer{<:AbstractArray{<:AbstractFloat}})
           return c.a[1]+2
       end

# ╔═╡ 03d40e5c-9e19-11eb-3e8c-7fe77d095ec4
function myfunc(c::MySimpleContainer{Vector{T}}) where T <: Integer
           return c.a[1]+3
       end

# ╔═╡ 03d414e2-9e19-11eb-018b-4990adaf8821
myfunc(MySimpleContainer(1:3))

# ╔═╡ 03d414f6-9e19-11eb-1a9a-a133c0f8361f
myfunc(MySimpleContainer(1.0:3))

# ╔═╡ 03d414f6-9e19-11eb-0cba-377dc61f7e28
myfunc(MySimpleContainer([1:3;]))

# ╔═╡ 03d4151e-9e19-11eb-38fc-b7bd02d93464
md"""
### Annotate values taken from untyped locations
"""

# ╔═╡ 03d41548-9e19-11eb-2230-6bc4713c6880
md"""
It is often convenient to work with data structures that may contain values of any type (arrays of type `Array{Any}`). But, if you're using one of these structures and happen to know the type of an element, it helps to share this knowledge with the compiler:
"""

# ╔═╡ 03d41582-9e19-11eb-36e3-214691a62ecf
md"""
```julia
function foo(a::Array{Any,1})
    x = a[1]::Int32
    b = x+1
    ...
end
```
"""

# ╔═╡ 03d41622-9e19-11eb-3bde-cba9a093569c
md"""
Here, we happened to know that the first element of `a` would be an [`Int32`](@ref). Making an annotation like this has the added benefit that it will raise a run-time error if the value is not of the expected type, potentially catching certain bugs earlier.
"""

# ╔═╡ 03d4167e-9e19-11eb-21f6-f1cffb5a6ec2
md"""
In the case that the type of `a[1]` is not known precisely, `x` can be declared via `x = convert(Int32, a[1])::Int32`. The use of the [`convert`](@ref) function allows `a[1]` to be any object convertible to an `Int32` (such as `UInt8`), thus increasing the genericity of the code by loosening the type requirement. Notice that `convert` itself needs a type annotation in this context in order to achieve type stability. This is because the compiler cannot deduce the type of the return value of a function, even `convert`, unless the types of all the function's arguments are known.
"""

# ╔═╡ 03d416b0-9e19-11eb-3868-5910989c0efc
md"""
Type annotation will not enhance (and can actually hinder) performance if the type is abstract, or constructed at run-time. This is because the compiler cannot use the annotation to specialize the subsequent code, and the type-check itself takes time. For example, in the code:
"""

# ╔═╡ 03d416cc-9e19-11eb-199f-6db35b3a9304
md"""
```julia
function nr(a, prec)
    ctype = prec == 32 ? Float32 : Float64
    b = Complex{ctype}(a)
    c = (b + 1.0f0)::Complex{ctype}
    abs(c)
end
```
"""

# ╔═╡ 03d41708-9e19-11eb-32a6-a14fde795647
md"""
the annotation of `c` harms performance. To write performant code involving types constructed at run-time, use the [function-barrier technique](@ref kernel-functions) discussed below, and ensure that the constructed type appears among the argument types of the kernel function so that the kernel operations are properly specialized by the compiler. For example, in the above snippet, as soon as `b` is constructed, it can be passed to another function `k`, the kernel. If, for example, function `k` declares `b` as an argument of type `Complex{T}`, where `T` is a type parameter, then a type annotation appearing in an assignment statement within `k` of the form:
"""

# ╔═╡ 03d41726-9e19-11eb-0e6f-83a59c543283
md"""
```julia
c = (b + 1.0f0)::Complex{T}
```
"""

# ╔═╡ 03d41742-9e19-11eb-2e82-c949d0d2c4fa
md"""
does not hinder performance (but does not help either) since the compiler can determine the type of `c` at the time `k` is compiled.
"""

# ╔═╡ 03d41762-9e19-11eb-28b8-9f80f691de61
md"""
### Be aware of when Julia avoids specializing
"""

# ╔═╡ 03d41794-9e19-11eb-3833-d9261e6b39d6
md"""
As a heuristic, Julia avoids automatically specializing on argument type parameters in three specific cases: `Type`, `Function`, and `Vararg`. Julia will always specialize when the argument is used within the method, but not if the argument is just passed through to another function. This usually has no performance impact at runtime and [improves compiler performance](@ref compiler-efficiency-issues). If you find it does have a performance impact at runtime in your case, you can trigger specialization by adding a type parameter to the method declaration. Here are some examples:
"""

# ╔═╡ 03d417a8-9e19-11eb-0191-47a7149adcac
md"""
This will not specialize:
"""

# ╔═╡ 03d417bc-9e19-11eb-29cb-bd2b1a87d5c4
md"""
```julia
function f_type(t)  # or t::Type
    x = ones(t, 10)
    return sum(map(sin, x))
end
```
"""

# ╔═╡ 03d417d0-9e19-11eb-3f7e-09e3c10111ef
md"""
but this will:
"""

# ╔═╡ 03d417ee-9e19-11eb-09ef-c1d1de223e1d
md"""
```julia
function g_type(t::Type{T}) where T
    x = ones(T, 10)
    return sum(map(sin, x))
end
```
"""

# ╔═╡ 03d417f8-9e19-11eb-262d-53b405b1344e
md"""
These will not specialize:
"""

# ╔═╡ 03d4180c-9e19-11eb-34df-0f94590ca9c8
md"""
```julia
f_func(f, num) = ntuple(f, div(num, 2))
g_func(g::Function, num) = ntuple(g, div(num, 2))
```
"""

# ╔═╡ 03d4182a-9e19-11eb-2267-61fb55a72fae
md"""
but this will:
"""

# ╔═╡ 03d4183e-9e19-11eb-3b4a-ebc57e380249
md"""
```julia
h_func(h::H, num) where {H} = ntuple(h, div(num, 2))
```
"""

# ╔═╡ 03d41852-9e19-11eb-0ee9-eda22fae93cf
md"""
This will not specialize:
"""

# ╔═╡ 03d41878-9e19-11eb-3f3c-353be97e8c34
md"""
```julia
f_vararg(x::Int...) = tuple(x...)
```
"""

# ╔═╡ 03d41884-9e19-11eb-2609-67b37f485758
md"""
but this will:
"""

# ╔═╡ 03d41898-9e19-11eb-3ba4-197af74b95ae
md"""
```julia
g_vararg(x::Vararg{Int, N}) where {N} = tuple(x...)
```
"""

# ╔═╡ 03d418aa-9e19-11eb-15f0-2767698eda7d
md"""
One only needs to introduce a single type parameter to force specialization, even if the other types are unconstrained. For example, this will also specialize, and is useful when the arguments are not all of the same type:
"""

# ╔═╡ 03d418c0-9e19-11eb-1d98-97c456445c35
md"""
```julia
h_vararg(x::Vararg{Any, N}) where {N} = tuple(x...)
```
"""

# ╔═╡ 03d418f2-9e19-11eb-39f0-8f56a468ee3e
md"""
Note that [`@code_typed`](@ref) and friends will always show you specialized code, even if Julia would not normally specialize that method call. You need to check the [method internals](@ref ast-lowered-method) if you want to see whether specializations are generated when argument types are changed, i.e., if `(@which f(...)).specializations` contains specializations for the argument in question.
"""

# ╔═╡ 03d41938-9e19-11eb-2e2e-216f115978f7
md"""
## Break functions into multiple definitions
"""

# ╔═╡ 03d4194e-9e19-11eb-2a88-dd7195a57352
md"""
Writing a function as many small definitions allows the compiler to directly call the most applicable code, or even inline it.
"""

# ╔═╡ 03d41960-9e19-11eb-141c-bb25cc6f6da1
md"""
Here is an example of a "compound function" that should really be written as multiple definitions:
"""

# ╔═╡ 03d41974-9e19-11eb-3e19-b9b64bd8abe7
md"""
```julia
using LinearAlgebra

function mynorm(A)
    if isa(A, Vector)
        return sqrt(real(dot(A,A)))
    elseif isa(A, Matrix)
        return maximum(svdvals(A))
    else
        error("mynorm: invalid argument")
    end
end
```
"""

# ╔═╡ 03d41992-9e19-11eb-21b2-a78eeb02a43f
md"""
This can be written more concisely and efficiently as:
"""

# ╔═╡ 03d419ae-9e19-11eb-3364-c35e0b87ecf0
md"""
```julia
norm(x::Vector) = sqrt(real(dot(x, x)))
norm(A::Matrix) = maximum(svdvals(A))
```
"""

# ╔═╡ 03d419c4-9e19-11eb-0e6a-fb1214e38b2b
md"""
It should however be noted that the compiler is quite efficient at optimizing away the dead branches in code written as the `mynorm` example.
"""

# ╔═╡ 03d419e0-9e19-11eb-3032-cb0a4e65324b
md"""
## Write "type-stable" functions
"""

# ╔═╡ 03d419ec-9e19-11eb-3089-67ded60e6df1
md"""
When possible, it helps to ensure that a function always returns a value of the same type. Consider the following definition:
"""

# ╔═╡ 03d41a00-9e19-11eb-009d-c393589ac1f3
md"""
```julia
pos(x) = x < 0 ? 0 : x
```
"""

# ╔═╡ 03d41a28-9e19-11eb-13c6-6131bc41584e
md"""
Although this seems innocent enough, the problem is that `0` is an integer (of type `Int`) and `x` might be of any type. Thus, depending on the value of `x`, this function might return a value of either of two types. This behavior is allowed, and may be desirable in some cases. But it can easily be fixed as follows:
"""

# ╔═╡ 03d41a3c-9e19-11eb-38e2-214d4c1b8c1b
md"""
```julia
pos(x) = x < 0 ? zero(x) : x
```
"""

# ╔═╡ 03d41a64-9e19-11eb-38c4-d17fd716f7d0
md"""
There is also a [`oneunit`](@ref) function, and a more general [`oftype(x, y)`](@ref) function, which returns `y` converted to the type of `x`.
"""

# ╔═╡ 03d41a6e-9e19-11eb-36bb-f1faf93df73b
md"""
## Avoid changing the type of a variable
"""

# ╔═╡ 03d41a8c-9e19-11eb-0fc3-2f693002fd19
md"""
An analogous "type-stability" problem exists for variables used repeatedly within a function:
"""

# ╔═╡ 03d41aa0-9e19-11eb-2961-574dc417c226
md"""
```julia
function foo()
    x = 1
    for i = 1:10
        x /= rand()
    end
    return x
end
```
"""

# ╔═╡ 03d41ad2-9e19-11eb-29eb-11f462878653
md"""
Local variable `x` starts as an integer, and after one loop iteration becomes a floating-point number (the result of [`/`](@ref) operator). This makes it more difficult for the compiler to optimize the body of the loop. There are several possible fixes:
"""

# ╔═╡ 03d41bec-9e19-11eb-082a-bd25559f2040
md"""
  * Initialize `x` with `x = 1.0`
  * Declare the type of `x` explicitly as `x::Float64 = 1`
  * Use an explicit conversion by `x = oneunit(Float64)`
  * Initialize with the first loop iteration, to `x = 1 / rand()`, then loop `for i = 2:10`
"""

# ╔═╡ 03d41bfe-9e19-11eb-18d7-1f2d540536c8
md"""
## [Separate kernel functions (aka, function barriers)](@id kernel-functions)
"""

# ╔═╡ 03d41c12-9e19-11eb-3fdb-ebc5f7a912f0
md"""
Many functions follow a pattern of performing some set-up work, and then running many iterations to perform a core computation. Where possible, it is a good idea to put these core computations in separate functions. For example, the following contrived function returns an array of a randomly-chosen type:
"""

# ╔═╡ 03d424bc-9e19-11eb-0bc7-b357e440aac1
function strange_twos(n)
           a = Vector{rand(Bool) ? Int64 : Float64}(undef, n)
           for i = 1:n
               a[i] = 2
           end
           return a
       end;

# ╔═╡ 03d424c8-9e19-11eb-3ec6-ddfc36ddd131
strange_twos(3)

# ╔═╡ 03d424dc-9e19-11eb-2efa-d73f4a7a35dd
md"""
This should be written as:
"""

# ╔═╡ 03d42d4c-9e19-11eb-2d0e-67bd154c4073
function fill_twos!(a)
           for i = eachindex(a)
               a[i] = 2
           end
       end;

# ╔═╡ 03d42d6a-9e19-11eb-11e2-5de0c0e1a071
function strange_twos(n)
           a = Vector{rand(Bool) ? Int64 : Float64}(undef, n)
           fill_twos!(a)
           return a
       end;

# ╔═╡ 03d42d6a-9e19-11eb-003c-0f5d196eb250
strange_twos(3)

# ╔═╡ 03d42d92-9e19-11eb-1801-0f1f82301b08
md"""
Julia's compiler specializes code for argument types at function boundaries, so in the original implementation it does not know the type of `a` during the loop (since it is chosen randomly). Therefore the second version is generally faster since the inner loop can be recompiled as part of `fill_twos!` for different types of `a`.
"""

# ╔═╡ 03d42da6-9e19-11eb-16ed-4914346b3cf9
md"""
The second form is also often better style and can lead to more code reuse.
"""

# ╔═╡ 03d42dd8-9e19-11eb-13e7-291e17c0264c
md"""
This pattern is used in several places in Julia Base. For example, see `vcat` and `hcat` in [`abstractarray.jl`](https://github.com/JuliaLang/julia/blob/40fe264f4ffaa29b749bcf42239a89abdcbba846/base/abstractarray.jl#L1205-L1206), or the [`fill!`](@ref) function, which we could have used instead of writing our own `fill_twos!`.
"""

# ╔═╡ 03d42dec-9e19-11eb-1bd2-85d34e90a59b
md"""
Functions like `strange_twos` occur when dealing with data of uncertain type, for example data loaded from an input file that might contain either integers, floats, strings, or something else.
"""

# ╔═╡ 03d42e0a-9e19-11eb-0133-87f0977755f0
md"""
## [Types with values-as-parameters](@id man-performance-value-type)
"""

# ╔═╡ 03d42e46-9e19-11eb-0be5-470df65a7699
md"""
Let's say you want to create an `N`-dimensional array that has size 3 along each axis. Such arrays can be created like this:
"""

# ╔═╡ 03d430a8-9e19-11eb-33e2-f5fb4ce90f39
A = fill(5.0, (3, 3))

# ╔═╡ 03d430d2-9e19-11eb-1ecc-1b0f4ac46cd9
md"""
This approach works very well: the compiler can figure out that `A` is an `Array{Float64,2}` because it knows the type of the fill value (`5.0::Float64`) and the dimensionality (`(3, 3)::NTuple{2,Int}`). This implies that the compiler can generate very efficient code for any future usage of `A` in the same function.
"""

# ╔═╡ 03d430ee-9e19-11eb-0fc1-c5468ae14c27
md"""
But now let's say you want to write a function that creates a 3×3×... array in arbitrary dimensions; you might be tempted to write a function
"""

# ╔═╡ 03d4356a-9e19-11eb-0931-a7b71d20345b
function array3(fillval, N)
           fill(fillval, ntuple(d->3, N))
       end

# ╔═╡ 03d43576-9e19-11eb-2701-ff601681aaef
array3(5.0, 2)

# ╔═╡ 03d435b2-9e19-11eb-01df-357ceeb255c9
md"""
This works, but (as you can verify for yourself using `@code_warntype array3(5.0, 2)`) the problem is that the output type cannot be inferred: the argument `N` is a *value* of type `Int`, and type-inference does not (and cannot) predict its value in advance. This means that code using the output of this function has to be conservative, checking the type on each access of `A`; such code will be very slow.
"""

# ╔═╡ 03d435ee-9e19-11eb-07ce-11a16892a8ce
md"""
Now, one very good way to solve such problems is by using the [function-barrier technique](@ref kernel-functions). However, in some cases you might want to eliminate the type-instability altogether. In such cases, one approach is to pass the dimensionality as a parameter, for example through `Val{T}()` (see ["Value types"](@ref)):
"""

# ╔═╡ 03d43dfa-9e19-11eb-35ac-2b806ca705d3
function array3(fillval, ::Val{N}) where N
           fill(fillval, ntuple(d->3, Val(N)))
       end

# ╔═╡ 03d43e04-9e19-11eb-2a02-95a1d60bd100
array3(5.0, Val(2))

# ╔═╡ 03d43e5e-9e19-11eb-2385-e70a71814c52
md"""
Julia has a specialized version of `ntuple` that accepts a `Val{::Int}` instance as the second parameter; by passing `N` as a type-parameter, you make its "value" known to the compiler. Consequently, this version of `array3` allows the compiler to predict the return type.
"""

# ╔═╡ 03d43e86-9e19-11eb-2bd0-272923811af3
md"""
However, making use of such techniques can be surprisingly subtle. For example, it would be of no help if you called `array3` from a function like this:
"""

# ╔═╡ 03d43ecc-9e19-11eb-0a2b-d54c8d73963f
md"""
```julia
function call_array3(fillval, n)
    A = array3(fillval, Val(n))
end
```
"""

# ╔═╡ 03d43f08-9e19-11eb-3923-3fd1aa559106
md"""
Here, you've created the same problem all over again: the compiler can't guess what `n` is, so it doesn't know the *type* of `Val(n)`. Attempting to use `Val`, but doing so incorrectly, can easily make performance *worse* in many situations. (Only in situations where you're effectively combining `Val` with the function-barrier trick, to make the kernel function more efficient, should code like the above be used.)
"""

# ╔═╡ 03d43f44-9e19-11eb-3fe4-79c69ba4e08e
md"""
An example of correct usage of `Val` would be:
"""

# ╔═╡ 03d43f62-9e19-11eb-106d-6f4022f7fcc1
md"""
```julia
function filter3(A::AbstractArray{T,N}) where {T,N}
    kernel = array3(1, Val(N))
    filter(A, kernel)
end
```
"""

# ╔═╡ 03d43f82-9e19-11eb-0ec4-a7c41137f19a
md"""
In this example, `N` is passed as a parameter, so its "value" is known to the compiler. Essentially, `Val(T)` works only when `T` is either hard-coded/literal (`Val(3)`) or already specified in the type-domain.
"""

# ╔═╡ 03d43f9e-9e19-11eb-095b-31c27f6102f6
md"""
## The dangers of abusing multiple dispatch (aka, more on types with values-as-parameters)
"""

# ╔═╡ 03d43fb4-9e19-11eb-1773-4db086bb40a2
md"""
Once one learns to appreciate multiple dispatch, there's an understandable tendency to go overboard and try to use it for everything. For example, you might imagine using it to store information, e.g.
"""

# ╔═╡ 03d4428c-9e19-11eb-0849-cbe88a67b247
struct Car{Make, Model}
    year::Int
    ...

# ╔═╡ 03d442aa-9e19-11eb-3365-c977618bd7e3
md"""
and then dispatch on objects like `Car{:Honda,:Accord}(year, args...)`.
"""

# ╔═╡ 03d442c8-9e19-11eb-0f70-d13f7ce01809
md"""
This might be worthwhile when either of the following are true:
"""

# ╔═╡ 03d4437c-9e19-11eb-38cf-f96bbed07490
md"""
  * You require CPU-intensive processing on each `Car`, and it becomes vastly more efficient if you know the `Make` and `Model` at compile time and the total number of different `Make` or `Model` that will be used is not too large.
  * You have homogenous lists of the same type of `Car` to process, so that you can store them all in an `Array{Car{:Honda,:Accord},N}`.
"""

# ╔═╡ 03d44390-9e19-11eb-1baf-1d89a2bc8fa0
md"""
When the latter holds, a function processing such a homogenous array can be productively specialized: Julia knows the type of each element in advance (all objects in the container have the same concrete type), so Julia can "look up" the correct method calls when the function is being compiled (obviating the need to check at run-time) and thereby emit efficient code for processing the whole list.
"""

# ╔═╡ 03d443ba-9e19-11eb-17e5-c111b00ef9cc
md"""
When these do not hold, then it's likely that you'll get no benefit; worse, the resulting "combinatorial explosion of types" will be counterproductive. If `items[i+1]` has a different type than `item[i]`, Julia has to look up the type at run-time, search for the appropriate method in method tables, decide (via type intersection) which one matches, determine whether it has been JIT-compiled yet (and do so if not), and then make the call. In essence, you're asking the full type- system and JIT-compilation machinery to basically execute the equivalent of a switch statement or dictionary lookup in your own code.
"""

# ╔═╡ 03d443e0-9e19-11eb-048a-ab259092c8d0
md"""
Some run-time benchmarks comparing (1) type dispatch, (2) dictionary lookup, and (3) a "switch" statement can be found [on the mailing list](https://groups.google.com/forum/#!msg/julia-users/jUMu9A3QKQQ/qjgVWr7vAwAJ).
"""

# ╔═╡ 03d443fe-9e19-11eb-1288-4780e81bcf73
md"""
Perhaps even worse than the run-time impact is the compile-time impact: Julia will compile specialized functions for each different `Car{Make, Model}`; if you have hundreds or thousands of such types, then every function that accepts such an object as a parameter (from a custom `get_year` function you might write yourself, to the generic `push!` function in Julia Base) will have hundreds or thousands of variants compiled for it. Each of these increases the size of the cache of compiled code, the length of internal lists of methods, etc. Excess enthusiasm for values-as-parameters can easily waste enormous resources.
"""

# ╔═╡ 03d44430-9e19-11eb-3017-6b0f10de9b90
md"""
## [Access arrays in memory order, along columns](@id man-performance-column-major)
"""

# ╔═╡ 03d44444-9e19-11eb-3112-4b9b323534d0
md"""
Multidimensional arrays in Julia are stored in column-major order. This means that arrays are stacked one column at a time. This can be verified using the `vec` function or the syntax `[:]` as shown below (notice that the array is ordered `[1 3 2 4]`, not `[1 2 3 4]`):
"""

# ╔═╡ 03d4489a-9e19-11eb-0a16-ed4dd0e6e3d8
x = [1 2; 3 4]

# ╔═╡ 03d4489a-9e19-11eb-2b4c-5139e0ddb78c
x[:]

# ╔═╡ 03d448e0-9e19-11eb-1aaa-d79467413663
md"""
This convention for ordering arrays is common in many languages like Fortran, Matlab, and R (to name a few). The alternative to column-major ordering is row-major ordering, which is the convention adopted by C and Python (`numpy`) among other languages. Remembering the ordering of arrays can have significant performance effects when looping over arrays. A rule of thumb to keep in mind is that with column-major arrays, the first index changes most rapidly. Essentially this means that looping will be faster if the inner-most loop index is the first to appear in a slice expression. Keep in mind that indexing an array with `:` is an implicit loop that iteratively accesses all elements within a particular dimension; it can be faster to extract columns than rows, for example.
"""

# ╔═╡ 03d44912-9e19-11eb-0357-f906dc7bb5df
md"""
Consider the following contrived example. Imagine we wanted to write a function that accepts a [`Vector`](@ref) and returns a square [`Matrix`](@ref) with either the rows or the columns filled with copies of the input vector. Assume that it is not important whether rows or columns are filled with these copies (perhaps the rest of the code can be easily adapted accordingly). We could conceivably do this in at least four ways (in addition to the recommended call to the built-in [`repeat`](@ref)):
"""

# ╔═╡ 03d4493a-9e19-11eb-1a6b-9dc3bb7b06c8
md"""
```julia
function copy_cols(x::Vector{T}) where T
    inds = axes(x, 1)
    out = similar(Array{T}, inds, inds)
    for i = inds
        out[:, i] = x
    end
    return out
end

function copy_rows(x::Vector{T}) where T
    inds = axes(x, 1)
    out = similar(Array{T}, inds, inds)
    for i = inds
        out[i, :] = x
    end
    return out
end

function copy_col_row(x::Vector{T}) where T
    inds = axes(x, 1)
    out = similar(Array{T}, inds, inds)
    for col = inds, row = inds
        out[row, col] = x[row]
    end
    return out
end

function copy_row_col(x::Vector{T}) where T
    inds = axes(x, 1)
    out = similar(Array{T}, inds, inds)
    for row = inds, col = inds
        out[row, col] = x[col]
    end
    return out
end
```
"""

# ╔═╡ 03d4495a-9e19-11eb-14b5-03feaca0fb2e
md"""
Now we will time each of these functions using the same random `10000` by `1` input vector:
"""

# ╔═╡ 03d45146-9e19-11eb-2b54-7d68ee8e69b8
x = randn(10000);

# ╔═╡ 03d45150-9e19-11eb-23e0-4b05f1de2331
fmt(f) = println(rpad(string(f)*": ", 14, ' '), @elapsed f(x))

# ╔═╡ 03d4515a-9e19-11eb-27a3-4bea80b10de8
map(fmt, [copy_cols, copy_rows, copy_col_row, copy_row_col]);

# ╔═╡ 03d4518c-9e19-11eb-2c9a-732b2adaec41
md"""
Notice that `copy_cols` is much faster than `copy_rows`. This is expected because `copy_cols` respects the column-based memory layout of the `Matrix` and fills it one column at a time. Additionally, `copy_col_row` is much faster than `copy_row_col` because it follows our rule of thumb that the first element to appear in a slice expression should be coupled with the inner-most loop.
"""

# ╔═╡ 03d451aa-9e19-11eb-0bc9-f10b4d7496e2
md"""
## Pre-allocating outputs
"""

# ╔═╡ 03d451be-9e19-11eb-16b1-ffa57a83168a
md"""
If your function returns an `Array` or some other complex type, it may have to allocate memory. Unfortunately, oftentimes allocation and its converse, garbage collection, are substantial bottlenecks.
"""

# ╔═╡ 03d451d2-9e19-11eb-2781-6762734e7bfe
md"""
Sometimes you can circumvent the need to allocate memory on each function call by preallocating the output. As a trivial example, compare
"""

# ╔═╡ 03d45cae-9e19-11eb-198e-4f17a6cfa44d
function xinc(x)
           return [x, x+1, x+2]
       end;

# ╔═╡ 03d45cae-9e19-11eb-268e-05af8b0ecda1
function loopinc()
           y = 0
           for i = 1:10^7
               ret = xinc(i)
               y += ret[2]
           end
           return y
       end;

# ╔═╡ 03d45ccc-9e19-11eb-0487-2784bbfcab37
md"""
with
"""

# ╔═╡ 03d46d98-9e19-11eb-2fd9-1b1caa725ad5
function xinc!(ret::AbstractVector{T}, x::T) where T
           ret[1] = x
           ret[2] = x+1
           ret[3] = x+2
           nothing
       end;

# ╔═╡ 03d46db4-9e19-11eb-2986-53edb0ac6103
function loopinc_prealloc()
           ret = Vector{Int}(undef, 3)
           y = 0
           for i = 1:10^7
               xinc!(ret, i)
               y += ret[2]
           end
           return y
       end;

# ╔═╡ 03d46dde-9e19-11eb-0f91-1f019bf9956c
md"""
Timing results:
"""

# ╔═╡ 03d47072-9e19-11eb-083d-b571e519a96f
@time loopinc()

# ╔═╡ 03d4707c-9e19-11eb-1f64-5d43385bf84d
@time loopinc_prealloc()

# ╔═╡ 03d470c2-9e19-11eb-068e-bd835ccd43b2
md"""
Preallocation has other advantages, for example by allowing the caller to control the "output" type from an algorithm. In the example above, we could have passed a `SubArray` rather than an [`Array`](@ref), had we so desired.
"""

# ╔═╡ 03d470f6-9e19-11eb-211a-ab32bb12ffab
md"""
Taken to its extreme, pre-allocation can make your code uglier, so performance measurements and some judgment may be required. However, for "vectorized" (element-wise) functions, the convenient syntax `x .= f.(y)` can be used for in-place operations with fused loops and no temporary arrays (see the [dot syntax for vectorizing functions](@ref man-vectorized)).
"""

# ╔═╡ 03d47112-9e19-11eb-23b3-3586e9b6df3d
md"""
## More dots: Fuse vectorized operations
"""

# ╔═╡ 03d47144-9e19-11eb-2b1f-99479db52673
md"""
Julia has a special [dot syntax](@ref man-vectorized) that converts any scalar function into a "vectorized" function call, and any operator into a "vectorized" operator, with the special property that nested "dot calls" are *fusing*: they are combined at the syntax level into a single loop, without allocating temporary arrays. If you use `.=` and similar assignment operators, the result can also be stored in-place in a pre-allocated array (see above).
"""

# ╔═╡ 03d47176-9e19-11eb-2432-712550e158df
md"""
In a linear-algebra context, this means that even though operations like `vector + vector` and `vector * scalar` are defined, it can be advantageous to instead use `vector .+ vector` and `vector .* scalar` because the resulting loops can be fused with surrounding computations. For example, consider the two functions:
"""

# ╔═╡ 03d479d2-9e19-11eb-3e7f-4db7d880dd73
f(x) = 3x.^2 + 4x + 7x.^3;

# ╔═╡ 03d479e6-9e19-11eb-3d0a-9923b8afe4fe
fdot(x) = @. 3x^2 + 4x + 7x^3 # equivalent to 3 .* x.^2 .+ 4 .* x .+ 7 .* x.^3;

# ╔═╡ 03d47a36-9e19-11eb-0dbd-710a44f176e6
md"""
Both `f` and `fdot` compute the same thing. However, `fdot` (defined with the help of the [`@.`](@ref @__dot__) macro) is significantly faster when applied to an array:
"""

# ╔═╡ 03d47fe0-9e19-11eb-0d37-d916d0b57e3d
x = rand(10^6);

# ╔═╡ 03d47fea-9e19-11eb-176a-af09f7b0ca4e
@time f(x);

# ╔═╡ 03d47ff4-9e19-11eb-0d0b-69f9776f0db7
@time fdot(x);

# ╔═╡ 03d47ff4-9e19-11eb-1e58-117d23d40c39
@time f.(x);

# ╔═╡ 03d48044-9e19-11eb-03bf-3da2b3c10407
md"""
That is, `fdot(x)` is ten times faster and allocates 1/6 the memory of `f(x)`, because each `*` and `+` operation in `f(x)` allocates a new temporary array and executes in a separate loop. (Of course, if you just do `f.(x)` then it is as fast as `fdot(x)` in this example, but in many contexts it is more convenient to just sprinkle some dots in your expressions rather than defining a separate function for each vectorized operation.)
"""

# ╔═╡ 03d48062-9e19-11eb-3863-e7d81fd665de
md"""
## [Consider using views for slices](@id man-performance-views)
"""

# ╔═╡ 03d4815c-9e19-11eb-19a7-1bdf2225b65c
md"""
In Julia, an array "slice" expression like `array[1:5, :]` creates a copy of that data (except on the left-hand side of an assignment, where `array[1:5, :] = ...` assigns in-place to that portion of `array`). If you are doing many operations on the slice, this can be good for performance because it is more efficient to work with a smaller contiguous copy than it would be to index into the original array. On the other hand, if you are just doing a few simple operations on the slice, the cost of the allocation and copy operations can be substantial.
"""

# ╔═╡ 03d481fc-9e19-11eb-3426-a188d0bdea7e
md"""
An alternative is to create a "view" of the array, which is an array object (a `SubArray`) that actually references the data of the original array in-place, without making a copy. (If you write to a view, it modifies the original array's data as well.) This can be done for individual slices by calling [`view`](@ref), or more simply for a whole expression or block of code by putting [`@views`](@ref) in front of that expression. For example:
"""

# ╔═╡ 03d48e54-9e19-11eb-2dd0-27b0b4154e2c
fcopy(x) = sum(x[2:end-1]);

# ╔═╡ 03d48e54-9e19-11eb-3a87-1d7db05df813
@views fview(x) = sum(x[2:end-1]);

# ╔═╡ 03d48e68-9e19-11eb-1e56-83870ec3f888
x = rand(10^6);

# ╔═╡ 03d48e72-9e19-11eb-1791-13cc8feed8ec
@time fcopy(x);

# ╔═╡ 03d48e7a-9e19-11eb-3c19-fdb5bd1ce805
@time fview(x);

# ╔═╡ 03d48e90-9e19-11eb-095c-6137a1ebd2a1
md"""
Notice both the 3× speedup and the decreased memory allocation of the `fview` version of the function.
"""

# ╔═╡ 03d48ea4-9e19-11eb-3fa8-e9c75ed31bfb
md"""
## Copying data is not always bad
"""

# ╔═╡ 03d48ecc-9e19-11eb-2cb5-21dd786e6b0d
md"""
Arrays are stored contiguously in memory, lending themselves to CPU vectorization and fewer memory accesses due to caching. These are the same reasons that it is recommended to access arrays in column-major order (see above). Irregular access patterns and non-contiguous views can drastically slow down computations on arrays because of non-sequential memory access.
"""

# ╔═╡ 03d48ed6-9e19-11eb-1e1d-5361555d6f8d
md"""
Copying irregularly-accessed data into a contiguous array before operating on it can result in a large speedup, such as in the example below. Here, a matrix and a vector are being accessed at 800,000 of their randomly-shuffled indices before being multiplied. Copying the views into plain arrays speeds up the multiplication even with the cost of the copying operation.
"""

# ╔═╡ 03d49ea8-9e19-11eb-136c-55602565b636
using Random

# ╔═╡ 03d49eb2-9e19-11eb-3501-7173af36b88e
x = randn(1_000_000);

# ╔═╡ 03d49ed0-9e19-11eb-1fd1-e3bbc5b2af4b
inds = shuffle(1:1_000_000)[1:800000];

# ╔═╡ 03d49ed0-9e19-11eb-0931-f99f17de4e34
A = randn(50, 1_000_000);

# ╔═╡ 03d49eda-9e19-11eb-0c9b-49ecfc309834
xtmp = zeros(800_000);

# ╔═╡ 03d49eda-9e19-11eb-0154-2b68f0cb88a1
Atmp = zeros(50, 800_000);

# ╔═╡ 03d49ee4-9e19-11eb-2854-e7e69472287c
@time sum(view(A, :, inds) * view(x, inds))

# ╔═╡ 03d49eee-9e19-11eb-18b5-e7e5b83d4c6f
@time begin
           copyto!(xtmp, view(x, inds))
           copyto!(Atmp, view(A, :, inds))
           sum(Atmp * xtmp)
       end

# ╔═╡ 03d49f02-9e19-11eb-190f-5bbc8216d5cf
md"""
Provided there is enough memory for the copies, the cost of copying the view to an array is far outweighed by the speed boost from doing the matrix multiplication on a contiguous array.
"""

# ╔═╡ 03d49f0c-9e19-11eb-002e-b53c0d65ef1a
md"""
## Consider StaticArrays.jl for small fixed-size vector/matrix operations
"""

# ╔═╡ 03d49f52-9e19-11eb-171f-77a0ffd58c7b
md"""
If your application involves many small (`< 100` element) arrays of fixed sizes (i.e. the size is known prior to execution), then you might want to consider using the [StaticArrays.jl package](https://github.com/JuliaArrays/StaticArrays.jl). This package allows you to represent such arrays in a way that avoids unnecessary heap allocations and allows the compiler to specialize code for the *size* of the array, e.g. by completely unrolling vector operations (eliminating the loops) and storing elements in CPU registers.
"""

# ╔═╡ 03d49f70-9e19-11eb-0aa4-bf05874e339e
md"""
For example, if you are doing computations with 2d geometries, you might have many computations with 2-component vectors.  By using the `SVector` type from StaticArrays.jl, you can use convenient vector notation and operations like `norm(3v - w)` on vectors `v` and `w`, while allowing the compiler to unroll the code to a minimal computation equivalent to `@inbounds hypot(3v[1]-w[1], 3v[2]-w[2])`.
"""

# ╔═╡ 03d49f84-9e19-11eb-3d43-eb8d0d057593
md"""
## Avoid string interpolation for I/O
"""

# ╔═╡ 03d49fac-9e19-11eb-15a5-c97b4f084275
md"""
When writing data to a file (or other I/O device), forming extra intermediate strings is a source of overhead. Instead of:
"""

# ╔═╡ 03d49fd4-9e19-11eb-18e7-c31a43ed8fdc
md"""
```julia
println(file, "$a $b")
```
"""

# ╔═╡ 03d49ff2-9e19-11eb-3a06-393d86692469
md"""
use:
"""

# ╔═╡ 03d4a010-9e19-11eb-1864-8fe65dbbb738
md"""
```julia
println(file, a, " ", b)
```
"""

# ╔═╡ 03d4a01a-9e19-11eb-178f-9d9b2b03d5c9
md"""
The first version of the code forms a string, then writes it to the file, while the second version writes values directly to the file. Also notice that in some cases string interpolation can be harder to read. Consider:
"""

# ╔═╡ 03d4a02c-9e19-11eb-00ea-3ba09b3ee114
md"""
```julia
println(file, "$(f(a))$(f(b))")
```
"""

# ╔═╡ 03d4a038-9e19-11eb-3d54-59f9c178c6dc
md"""
versus:
"""

# ╔═╡ 03d4a056-9e19-11eb-2c8c-79bf7d779e1d
md"""
```julia
println(file, f(a), f(b))
```
"""

# ╔═╡ 03d4a05e-9e19-11eb-13fd-5751229ebc58
md"""
## Optimize network I/O during parallel execution
"""

# ╔═╡ 03d4a074-9e19-11eb-210e-05d160fe1a09
md"""
When executing a remote function in parallel:
"""

# ╔═╡ 03d4a092-9e19-11eb-3585-052a0bcedc97
md"""
```julia
using Distributed

responses = Vector{Any}(undef, nworkers())
@sync begin
    for (idx, pid) in enumerate(workers())
        @async responses[idx] = remotecall_fetch(foo, pid, args...)
    end
end
```
"""

# ╔═╡ 03d4a09c-9e19-11eb-2490-c5b53e46ca73
md"""
is faster than:
"""

# ╔═╡ 03d4a0b0-9e19-11eb-0f04-57edf6d80fcb
md"""
```julia
using Distributed

refs = Vector{Any}(undef, nworkers())
for (idx, pid) in enumerate(workers())
    refs[idx] = @spawnat pid foo(args...)
end
responses = [fetch(r) for r in refs]
```
"""

# ╔═╡ 03d4a0f6-9e19-11eb-280e-a57c2eb9d210
md"""
The former results in a single network round-trip to every worker, while the latter results in two network calls - first by the [`@spawnat`](@ref) and the second due to the [`fetch`](@ref) (or even a [`wait`](@ref)). The [`fetch`](@ref)/[`wait`](@ref) is also being executed serially resulting in an overall poorer performance.
"""

# ╔═╡ 03d4a114-9e19-11eb-272b-451145e5f132
md"""
## Fix deprecation warnings
"""

# ╔═╡ 03d4a11e-9e19-11eb-1ac2-ebaf7346799d
md"""
A deprecated function internally performs a lookup in order to print a relevant warning only once. This extra lookup can cause a significant slowdown, so all uses of deprecated functions should be modified as suggested by the warnings.
"""

# ╔═╡ 03d4a13c-9e19-11eb-1998-996a75abc5cc
md"""
## Tweaks
"""

# ╔═╡ 03d4a150-9e19-11eb-077b-c1d027288622
md"""
These are some minor points that might help in tight inner loops.
"""

# ╔═╡ 03d4a27c-9e19-11eb-0a6e-a9bf63e1ada5
md"""
  * Avoid unnecessary arrays. For example, instead of [`sum([x,y,z])`](@ref) use `x+y+z`.
  * Use [`abs2(z)`](@ref) instead of [`abs(z)^2`](@ref) for complex `z`. In general, try to rewrite code to use [`abs2`](@ref) instead of [`abs`](@ref) for complex arguments.
  * Use [`div(x,y)`](@ref) for truncating division of integers instead of [`trunc(x/y)`](@ref), [`fld(x,y)`](@ref) instead of [`floor(x/y)`](@ref), and [`cld(x,y)`](@ref) instead of [`ceil(x/y)`](@ref).
"""

# ╔═╡ 03d4a29c-9e19-11eb-0bba-19d3238f2347
md"""
## [Performance Annotations](@id man-performance-annotations)
"""

# ╔═╡ 03d4a2a4-9e19-11eb-0765-b7792701444a
md"""
Sometimes you can enable better optimization by promising certain program properties.
"""

# ╔═╡ 03d4a3c6-9e19-11eb-1b95-21da954e9fe2
md"""
  * Use [`@inbounds`](@ref) to eliminate array bounds checking within expressions. Be certain before doing this. If the subscripts are ever out of bounds, you may suffer crashes or silent corruption.
  * Use [`@fastmath`](@ref) to allow floating point optimizations that are correct for real numbers, but lead to differences for IEEE numbers. Be careful when doing this, as this may change numerical results. This corresponds to the `-ffast-math` option of clang.
  * Write [`@simd`](@ref) in front of `for` loops to promise that the iterations are independent and may be reordered.  Note that in many cases, Julia can automatically vectorize code without the `@simd` macro; it is only beneficial in cases where such a transformation would otherwise be illegal, including cases like allowing floating-point re-associativity and ignoring dependent memory accesses (`@simd ivdep`). Again, be very careful when asserting `@simd` as erroneously annotating a loop with dependent iterations may result in unexpected results. In particular, note that `setindex!` on some `AbstractArray` subtypes is inherently dependent upon iteration order. **This feature is experimental** and could change or disappear in future versions of Julia.
"""

# ╔═╡ 03d4a3e4-9e19-11eb-1c6c-7f6d2827719a
md"""
The common idiom of using 1:n to index into an AbstractArray is not safe if the Array uses unconventional indexing, and may cause a segmentation fault if bounds checking is turned off. Use `LinearIndices(x)` or `eachindex(x)` instead (see also [Arrays with custom indices](@ref man-custom-indices)).
"""

# ╔═╡ 03d4a4b6-9e19-11eb-1e34-c937d2fe2f7c
md"""
!!! note
    While `@simd` needs to be placed directly in front of an innermost `for` loop, both `@inbounds` and `@fastmath` can be applied to either single expressions or all the expressions that appear within nested blocks of code, e.g., using `@inbounds begin` or `@inbounds for ...`.
"""

# ╔═╡ 03d4a4d4-9e19-11eb-00b8-e3e1ce146379
md"""
Here is an example with both `@inbounds` and `@simd` markup (we here use `@noinline` to prevent the optimizer from trying to be too clever and defeat our benchmark):
"""

# ╔═╡ 03d4a4f2-9e19-11eb-3fc5-b920d9126456
md"""
```julia
@noinline function inner(x, y)
    s = zero(eltype(x))
    for i=eachindex(x)
        @inbounds s += x[i]*y[i]
    end
    return s
end

@noinline function innersimd(x, y)
    s = zero(eltype(x))
    @simd for i = eachindex(x)
        @inbounds s += x[i] * y[i]
    end
    return s
end

function timeit(n, reps)
    x = rand(Float32, n)
    y = rand(Float32, n)
    s = zero(Float64)
    time = @elapsed for j in 1:reps
        s += inner(x, y)
    end
    println("GFlop/sec        = ", 2n*reps / time*1E-9)
    time = @elapsed for j in 1:reps
        s += innersimd(x, y)
    end
    println("GFlop/sec (SIMD) = ", 2n*reps / time*1E-9)
end

timeit(1000, 1000)
```
"""

# ╔═╡ 03d4a51a-9e19-11eb-1fb6-2795b4692fc4
md"""
On a computer with a 2.4GHz Intel Core i5 processor, this produces:
"""

# ╔═╡ 03d4a722-9e19-11eb-221e-4d4113308356
GFlop/sec        = 1.9467069505224963

# ╔═╡ 03d4a740-9e19-11eb-1787-351a46a8bc71
md"""
(`GFlop/sec` measures the performance, and larger numbers are better.)
"""

# ╔═╡ 03d4a772-9e19-11eb-1a1d-c5ac82dffc5d
md"""
Here is an example with all three kinds of markup. This program first calculates the finite difference of a one-dimensional array, and then evaluates the L2-norm of the result:
"""

# ╔═╡ 03d4a79a-9e19-11eb-0b6d-9bd86e58fdfb
md"""
```julia
function init!(u::Vector)
    n = length(u)
    dx = 1.0 / (n-1)
    @fastmath @inbounds @simd for i in 1:n #by asserting that `u` is a `Vector` we can assume it has 1-based indexing
        u[i] = sin(2pi*dx*i)
    end
end

function deriv!(u::Vector, du)
    n = length(u)
    dx = 1.0 / (n-1)
    @fastmath @inbounds du[1] = (u[2] - u[1]) / dx
    @fastmath @inbounds @simd for i in 2:n-1
        du[i] = (u[i+1] - u[i-1]) / (2*dx)
    end
    @fastmath @inbounds du[n] = (u[n] - u[n-1]) / dx
end

function mynorm(u::Vector)
    n = length(u)
    T = eltype(u)
    s = zero(T)
    @fastmath @inbounds @simd for i in 1:n
        s += u[i]^2
    end
    @fastmath @inbounds return sqrt(s)
end

function main()
    n = 2000
    u = Vector{Float64}(undef, n)
    init!(u)
    du = similar(u)

    deriv!(u, du)
    nu = mynorm(du)

    @time for i in 1:10^6
        deriv!(u, du)
        nu = mynorm(du)
    end

    println(nu)
end

main()
```
"""

# ╔═╡ 03d4a7ae-9e19-11eb-18ca-6d03bdc6957b
md"""
On a computer with a 2.7 GHz Intel Core i7 processor, this produces:
"""

# ╔═╡ 03d4a894-9e19-11eb-3cae-db883b5f0440
$ julia wave

# ╔═╡ 03d4a8d0-9e19-11eb-2432-8389bc32fab0
md"""
Here, the option `--math-mode=ieee` disables the `@fastmath` macro, so that we can compare results.
"""

# ╔═╡ 03d4a8e4-9e19-11eb-0cae-a104ee2b4eb4
md"""
In this case, the speedup due to `@fastmath` is a factor of about 3.7. This is unusually large – in general, the speedup will be smaller. (In this particular example, the working set of the benchmark is small enough to fit into the L1 cache of the processor, so that memory access latency does not play a role, and computing time is dominated by CPU usage. In many real world programs this is not the case.) Also, in this case this optimization does not change the result – in general, the result will be slightly different. In some cases, especially for numerically unstable algorithms, the result can be very different.
"""

# ╔═╡ 03d4a920-9e19-11eb-04fe-af76380b6c38
md"""
The annotation `@fastmath` re-arranges floating point expressions, e.g. changing the order of evaluation, or assuming that certain special cases (inf, nan) cannot occur. In this case (and on this particular computer), the main difference is that the expression `1 / (2*dx)` in the function `deriv` is hoisted out of the loop (i.e. calculated outside the loop), as if one had written `idx = 1 / (2*dx)`. In the loop, the expression `... / (2*dx)` then becomes `... * idx`, which is much faster to evaluate. Of course, both the actual optimization that is applied by the compiler as well as the resulting speedup depend very much on the hardware. You can examine the change in generated code by using Julia's [`code_native`](@ref) function.
"""

# ╔═╡ 03d4a940-9e19-11eb-1fb1-9f1e6de8418a
md"""
Note that `@fastmath` also assumes that `NaN`s will not occur during the computation, which can lead to surprising behavior:
"""

# ╔═╡ 03d4add8-9e19-11eb-36c2-c7ef626944ad
f(x) = isnan(x);

# ╔═╡ 03d4ade4-9e19-11eb-3341-9f60fabbdcf2
f(NaN)

# ╔═╡ 03d4ade4-9e19-11eb-2586-e7ed5cf8b32a
f_fast(x) = @fastmath isnan(x);

# ╔═╡ 03d4ae02-9e19-11eb-3764-8d5923e3cfb8
f_fast(NaN)

# ╔═╡ 03d4ae20-9e19-11eb-37a2-01e9e910834f
md"""
## Treat Subnormal Numbers as Zeros
"""

# ╔═╡ 03d4ae52-9e19-11eb-36b6-ab2f8660d24f
md"""
Subnormal numbers, formerly called [denormal numbers](https://en.wikipedia.org/wiki/Denormal_number), are useful in many contexts, but incur a performance penalty on some hardware. A call [`set_zero_subnormals(true)`](@ref) grants permission for floating-point operations to treat subnormal inputs or outputs as zeros, which may improve performance on some hardware. A call [`set_zero_subnormals(false)`](@ref) enforces strict IEEE behavior for subnormal numbers.
"""

# ╔═╡ 03d4ae66-9e19-11eb-141a-71758dfe94a1
md"""
Below is an example where subnormals noticeably impact performance on some hardware:
"""

# ╔═╡ 03d4ae8e-9e19-11eb-2822-976a23967404
md"""
```julia
function timestep(b::Vector{T}, a::Vector{T}, Δt::T) where T
    @assert length(a)==length(b)
    n = length(b)
    b[1] = 1                            # Boundary condition
    for i=2:n-1
        b[i] = a[i] + (a[i-1] - T(2)*a[i] + a[i+1]) * Δt
    end
    b[n] = 0                            # Boundary condition
end

function heatflow(a::Vector{T}, nstep::Integer) where T
    b = similar(a)
    for t=1:div(nstep,2)                # Assume nstep is even
        timestep(b,a,T(0.1))
        timestep(a,b,T(0.1))
    end
end

heatflow(zeros(Float32,10),2)           # Force compilation
for trial=1:6
    a = zeros(Float32,1000)
    set_zero_subnormals(iseven(trial))  # Odd trials use strict IEEE arithmetic
    @time heatflow(a,1000)
end
```
"""

# ╔═╡ 03d4aeae-9e19-11eb-0499-cdbda3326aa5
md"""
This gives an output similar to
"""

# ╔═╡ 03d4afce-9e19-11eb-01e0-51d57e4f42c7
0.002202 seconds

# ╔═╡ 03d4afec-9e19-11eb-1085-5be2440eb103
md"""
Note how each even iteration is significantly faster.
"""

# ╔═╡ 03d4b000-9e19-11eb-287d-ebe8b8c721a9
md"""
This example generates many subnormal numbers because the values in `a` become an exponentially decreasing curve, which slowly flattens out over time.
"""

# ╔═╡ 03d4b016-9e19-11eb-049f-4d2631a082e8
md"""
Treating subnormals as zeros should be used with caution, because doing so breaks some identities, such as `x-y == 0` implies `x == y`:
"""

# ╔═╡ 03d4b750-9e19-11eb-046c-d969daa56dac
x = 3f-38; y = 2f-38;

# ╔═╡ 03d4b762-9e19-11eb-1832-df33cf32f58f
set_zero_subnormals(true); (x - y, x == y)

# ╔═╡ 03d4b762-9e19-11eb-2036-2921bdaa93f5
set_zero_subnormals(false); (x - y, x == y)

# ╔═╡ 03d4b77e-9e19-11eb-0e99-b328947ad26c
md"""
In some applications, an alternative to zeroing subnormal numbers is to inject a tiny bit of noise.  For example, instead of initializing `a` with zeros, initialize it with:
"""

# ╔═╡ 03d4b794-9e19-11eb-1edc-df469244e84c
md"""
```julia
a = rand(Float32,1000) * 1.f-9
```
"""

# ╔═╡ 03d4b7d0-9e19-11eb-10a6-d3f05c656de4
md"""
## [[`@code_warntype`](@ref)](@id man-code-warntype)
"""

# ╔═╡ 03d4b7ee-9e19-11eb-2ad7-71bb297a95c6
md"""
The macro [`@code_warntype`](@ref) (or its function variant [`code_warntype`](@ref)) can sometimes be helpful in diagnosing type-related problems. Here's an example:
"""

# ╔═╡ 03d4c036-9e19-11eb-3414-f7740c7bbe20
@noinline pos(x) = x < 0 ? 0 : x;

# ╔═╡ 03d4c04a-9e19-11eb-1ede-1ffb2511b32a
function f(x)
           y = pos(x)
           return sin(y*x + 1)
       end;

# ╔═╡ 03d4c054-9e19-11eb-18e1-c9abe51d1ff3
@code_warntype f(3.2)

# ╔═╡ 03d4c09a-9e19-11eb-1eef-415663ce4d5c
md"""
Interpreting the output of [`@code_warntype`](@ref), like that of its cousins [`@code_lowered`](@ref), [`@code_typed`](@ref), [`@code_llvm`](@ref), and [`@code_native`](@ref), takes a little practice. Your code is being presented in form that has been heavily digested on its way to generating compiled machine code. Most of the expressions are annotated by a type, indicated by the `::T` (where `T` might be [`Float64`](@ref), for example). The most important characteristic of [`@code_warntype`](@ref) is that non-concrete types are displayed in red; since this document is written in Markdown, which has no color, in this document, red text is denoted by uppercase.
"""

# ╔═╡ 03d4c0d6-9e19-11eb-2d2a-392420efda12
md"""
At the top, the inferred return type of the function is shown as `Body::Float64`. The next lines represent the body of `f` in Julia's SSA IR form. The numbered boxes are labels and represent targets for jumps (via `goto`) in your code. Looking at the body, you can see that the first thing that happens is that `pos` is called and the return value has been inferred as the `Union` type `UNION{FLOAT64, INT64}` shown in uppercase since it is a non-concrete type. This means that we cannot know the exact return type of `pos` based on the input types. However, the result of `y*x`is a `Float64` no matter if `y` is a `Float64` or `Int64` The net result is that `f(x::Float64)` will not be type-unstable in its output, even if some of the intermediate computations are type-unstable.
"""

# ╔═╡ 03d4c124-9e19-11eb-23ff-af1b23484742
md"""
How you use this information is up to you. Obviously, it would be far and away best to fix `pos` to be type-stable: if you did so, all of the variables in `f` would be concrete, and its performance would be optimal. However, there are circumstances where this kind of *ephemeral* type instability might not matter too much: for example, if `pos` is never used in isolation, the fact that `f`'s output is type-stable (for [`Float64`](@ref) inputs) will shield later code from the propagating effects of type instability. This is particularly relevant in cases where fixing the type instability is difficult or impossible. In such cases, the tips above (e.g., adding type annotations and/or breaking up functions) are your best tools to contain the "damage" from type instability. Also, note that even Julia Base has functions that are type unstable. For example, the function [`findfirst`](@ref) returns the index into an array where a key is found, or `nothing` if it is not found, a clear type instability. In order to make it easier to find the type instabilities that are likely to be important, `Union`s containing either `missing` or `nothing` are color highlighted in yellow, instead of red.
"""

# ╔═╡ 03d4c130-9e19-11eb-039a-51353422304f
md"""
The following examples may help you interpret expressions marked as containing non-leaf types:
"""

# ╔═╡ 03d4c342-9e19-11eb-0f30-db24c5c706ff
md"""
  * Function body starting with `Body::UNION{T1,T2})`

      * Interpretation: function with unstable return type
      * Suggestion: make the return value type-stable, even if you have to annotate it
  * `invoke Main.g(%%x::Int64)::UNION{FLOAT64, INT64}`

      * Interpretation: call to a type-unstable function `g`.
      * Suggestion: fix the function, or if necessary annotate the return value
  * `invoke Base.getindex(%%x::Array{Any,1}, 1::Int64)::ANY`

      * Interpretation: accessing elements of poorly-typed arrays
      * Suggestion: use arrays with better-defined types, or if necessary annotate the type of individual element accesses
  * `Base.getfield(%%x, :(:data))::ARRAY{FLOAT64,N} WHERE N`

      * Interpretation: getting a field that is of non-leaf type. In this case, `ArrayContainer` had a field `data::Array{T}`. But `Array` needs the dimension `N`, too, to be a concrete type.
      * Suggestion: use concrete types like `Array{T,3}` or `Array{T,N}`, where `N` is now a parameter of `ArrayContainer`
"""

# ╔═╡ 03d4c362-9e19-11eb-089e-811b8468bc12
md"""
## [Performance of captured variable](@id man-performance-captured)
"""

# ╔═╡ 03d4c374-9e19-11eb-30c9-652aa68a07a3
md"""
Consider the following example that defines an inner function:
"""

# ╔═╡ 03d4c388-9e19-11eb-1b49-ebd395a92821
md"""
```julia
function abmult(r::Int)
    if r < 0
        r = -r
    end
    f = x -> x * r
    return f
end
```
"""

# ╔═╡ 03d4c3ba-9e19-11eb-1175-ebffe1edf568
md"""
Function `abmult` returns a function `f` that multiplies its argument by the absolute value of `r`. The inner function assigned to `f` is called a "closure". Inner functions are also used by the language for `do`-blocks and for generator expressions.
"""

# ╔═╡ 03d4c3e2-9e19-11eb-33dd-c744c3698f6a
md"""
This style of code presents performance challenges for the language. The parser, when translating it into lower-level instructions, substantially reorganizes the above code by extracting the inner function to a separate code block.  "Captured" variables such as `r` that are shared by inner functions and their enclosing scope are also extracted into a heap-allocated "box" accessible to both inner and outer functions because the language specifies that `r` in the inner scope must be identical to `r` in the outer scope even after the outer scope (or another inner function) modifies `r`.
"""

# ╔═╡ 03d4c400-9e19-11eb-3268-5f5966b072be
md"""
The discussion in the preceding paragraph referred to the "parser", that is, the phase of compilation that takes place when the module containing `abmult` is first loaded, as opposed to the later phase when it is first invoked. The parser does not "know" that `Int` is a fixed type, or that the statement `r = -r` transforms an `Int` to another `Int`. The magic of type inference takes place in the later phase of compilation.
"""

# ╔═╡ 03d4c426-9e19-11eb-2c26-d37c807d3010
md"""
Thus, the parser does not know that `r` has a fixed type (`Int`). nor that `r` does not change value once the inner function is created (so that the box is unneeded).  Therefore, the parser emits code for box that holds an object with an abstract type such as `Any`, which requires run-time type dispatch for each occurrence of `r`.  This can be verified by applying `@code_warntype` to the above function.  Both the boxing and the run-time type dispatch can cause loss of performance.
"""

# ╔═╡ 03d4c43c-9e19-11eb-2c4b-b5b9dd813ef9
md"""
If captured variables are used in a performance-critical section of the code, then the following tips help ensure that their use is performant. First, if it is known that a captured variable does not change its type, then this can be declared explicitly with a type annotation (on the variable, not the right-hand side):
"""

# ╔═╡ 03d4c450-9e19-11eb-39ec-d15260c8f285
md"""
```julia
function abmult2(r0::Int)
    r::Int = r0
    if r < 0
        r = -r
    end
    f = x -> x * r
    return f
end
```
"""

# ╔═╡ 03d4c478-9e19-11eb-176b-7b2b810159ac
md"""
The type annotation partially recovers lost performance due to capturing because the parser can associate a concrete type to the object in the box. Going further, if the captured variable does not need to be boxed at all (because it will not be reassigned after the closure is created), this can be indicated with `let` blocks as follows.
"""

# ╔═╡ 03d4c48c-9e19-11eb-1ecc-a3318dbb1eab
md"""
```julia
function abmult3(r::Int)
    if r < 0
        r = -r
    end
    f = let r = r
            x -> x * r
    end
    return f
end
```
"""

# ╔═╡ 03d4c4be-9e19-11eb-2150-fb1625006367
md"""
The `let` block creates a new variable `r` whose scope is only the inner function. The second technique recovers full language performance in the presence of captured variables. Note that this is a rapidly evolving aspect of the compiler, and it is likely that future releases will not require this degree of programmer annotation to attain performance. In the mean time, some user-contributed packages like [FastClosures](https://github.com/c42f/FastClosures.jl) automate the insertion of `let` statements as in `abmult3`.
"""

# ╔═╡ 03d4c4d2-9e19-11eb-13ea-83ad3a624321
md"""
## Checking for equality with a singleton
"""

# ╔═╡ 03d4c4fc-9e19-11eb-0853-b9f70f37df73
md"""
When checking if a value is equal to some singleton it can be better for performance to check for identicality (`===`) instead of equality (`==`). The same advice applies to using `!==` over `!=`. These type of checks frequently occur e.g. when implementing the iteration protocol and checking if `nothing` is returned from [`iterate`](@ref).
"""

# ╔═╡ Cell order:
# ╟─03d38cde-9e19-11eb-1cd8-0bd3695568ef
# ╟─03d38d10-9e19-11eb-029e-31f83d536d30
# ╟─03d38d30-9e19-11eb-24d3-4149dcc47a42
# ╟─03d38d56-9e19-11eb-2add-035443ef98e8
# ╟─03d38d62-9e19-11eb-3594-875106645281
# ╟─03d38d74-9e19-11eb-0193-e99e86efec31
# ╟─03d38dc2-9e19-11eb-241f-7bc2e3f1d9c9
# ╟─03d38dce-9e19-11eb-100d-1960c67537a3
# ╟─03d38df4-9e19-11eb-096c-0d79743cfad7
# ╟─03d38e00-9e19-11eb-2908-6b189ac2f863
# ╟─03d38efc-9e19-11eb-2806-afa4306501eb
# ╟─03d38f22-9e19-11eb-1090-87bd31841bfa
# ╠═03d3936e-9e19-11eb-2f48-d93242ffda15
# ╟─03d3938c-9e19-11eb-3ca0-616a2de61185
# ╠═03d39558-9e19-11eb-3f09-d7d6754234dc
# ╟─03d39576-9e19-11eb-3992-13ea75ef6666
# ╟─03d395a8-9e19-11eb-08a4-0f4833cb3f71
# ╟─03d395bc-9e19-11eb-037b-bf1cf8c5819f
# ╠═03d39f4e-9e19-11eb-211b-698927e59c1f
# ╠═03d39f58-9e19-11eb-3c33-f78a40f9c59c
# ╠═03d39f6c-9e19-11eb-25db-27cc424394c4
# ╠═03d39f6c-9e19-11eb-31c4-b5bdd50abb20
# ╟─03d39fb2-9e19-11eb-37dc-fd832ea6bf7c
# ╟─03d39fd0-9e19-11eb-3941-d9b338dd3d74
# ╟─03d39fee-9e19-11eb-1fad-45989c63b090
# ╠═03d3a816-9e19-11eb-01a6-6752e58e99dc
# ╠═03d3a836-9e19-11eb-2c0a-632f0698398e
# ╠═03d3a836-9e19-11eb-0f8c-892e3e72d4a7
# ╠═03d3a840-9e19-11eb-2892-65da750f22dc
# ╟─03d3a85e-9e19-11eb-1834-e1894bb49bfa
# ╠═03d3ab06-9e19-11eb-2706-1b333df15cf5
# ╠═03d3ab06-9e19-11eb-0472-69a8d49b4603
# ╟─03d3ab42-9e19-11eb-39a9-7723f82bde67
# ╟─03d3abbc-9e19-11eb-3ec9-4981fed825cf
# ╟─03d3abd8-9e19-11eb-04e2-1926dcd1151b
# ╟─03d3abea-9e19-11eb-2fd6-8701155ded3b
# ╟─03d3ad72-9e19-11eb-2d73-5f0197f26261
# ╟─03d3ad9a-9e19-11eb-3d1f-c34ebbed6490
# ╟─03d3adae-9e19-11eb-3177-f1038bc74085
# ╟─03d3adc2-9e19-11eb-080b-4fdfafda418b
# ╠═03d3b1dc-9e19-11eb-18eb-4d9a379da976
# ╠═03d3b1e6-9e19-11eb-10af-a733103beef4
# ╟─03d3b24a-9e19-11eb-0839-518dfaedc953
# ╠═03d3b59c-9e19-11eb-235e-7fa857852ca1
# ╠═03d3b5ba-9e19-11eb-2eb4-ef1608af8028
# ╟─03d3b600-9e19-11eb-20c4-09bad066f5f9
# ╟─03d3b632-9e19-11eb-27f3-e10cd8f373e7
# ╟─03d3b666-9e19-11eb-1fdb-57bf0747f8ff
# ╟─03d3b678-9e19-11eb-2209-eb91931d513e
# ╟─03d3b6b4-9e19-11eb-0b2d-73078a021d21
# ╟─03d3b6f8-9e19-11eb-2d95-a30d040e254d
# ╟─03d3b70e-9e19-11eb-2414-db3091bb47a5
# ╠═03d3b8bc-9e19-11eb-13d5-013c9177f3fb
# ╟─03d3b8e4-9e19-11eb-2679-7bb64a10be92
# ╠═03d3bd94-9e19-11eb-09a6-6f1d4aef2435
# ╠═03d3bdb2-9e19-11eb-0ec1-67a5e556b827
# ╠═03d3bdb2-9e19-11eb-3f01-9f90f5b29207
# ╠═03d3bdbc-9e19-11eb-3eb0-9d1f0454a946
# ╟─03d3bdf8-9e19-11eb-3b11-19c891f51ccb
# ╟─03d3be2a-9e19-11eb-3513-2f58adbe534f
# ╠═03d3c44c-9e19-11eb-21ac-d97e8a090b6b
# ╟─03d3c49c-9e19-11eb-3ec3-a36ee50ede8b
# ╠═03d3c686-9e19-11eb-2ec4-df1801ebbb2c
# ╟─03d3c71c-9e19-11eb-1c45-1bba3f894489
# ╠═03d3cbcc-9e19-11eb-263b-6d3412745cb0
# ╠═03d3cbcc-9e19-11eb-10e6-e50579f15a74
# ╠═03d3cbd6-9e19-11eb-3bbe-d5a7dca2a57c
# ╠═03d3cbea-9e19-11eb-0382-637e78928f8f
# ╟─03d3cc1c-9e19-11eb-35a2-ab2b940facf4
# ╠═03d3d068-9e19-11eb-1f88-8bf0527c7f8d
# ╠═03d3d068-9e19-11eb-19ae-2307e81eb135
# ╠═03d3d072-9e19-11eb-1144-73032eaa0c76
# ╟─03d3d0ae-9e19-11eb-3f96-09399886c2f0
# ╠═03d3d32e-9e19-11eb-37b3-7d9ffa7f7991
# ╠═03d3d32e-9e19-11eb-27a4-3f09d5d6b9a5
# ╟─03d3d36a-9e19-11eb-13a5-b9a42ff084c3
# ╟─03d3d38a-9e19-11eb-2b33-17ecd7d877e5
# ╠═03d3d874-9e19-11eb-2a25-f934da459d51
# ╠═03d3d87e-9e19-11eb-12cf-2588baf24bc4
# ╠═03d3d888-9e19-11eb-0236-73a886449cee
# ╠═03d3d8a6-9e19-11eb-165f-bdc18583e8aa
# ╟─03d3d8c6-9e19-11eb-0fc8-0534d2cd2ba8
# ╟─03d3d8ce-9e19-11eb-36a6-4986716d6787
# ╟─03d3d932-9e19-11eb-08e3-53d281879534
# ╟─03d3d950-9e19-11eb-2b60-6d1e29130058
# ╟─03d3d964-9e19-11eb-0bc6-0f1aea44f5c7
# ╟─03d3de8c-9e19-11eb-1938-a55c684d7a8f
# ╟─03d3deb4-9e19-11eb-0866-cff8a15bbd8d
# ╟─03d3df18-9e19-11eb-14de-6318b3d30a53
# ╠═03d3e4a4-9e19-11eb-1dab-5982feafaccc
# ╠═03d3e4c2-9e19-11eb-1a0d-8fcc91ea708d
# ╟─03d3e4d6-9e19-11eb-08f8-6106fa7339ea
# ╠═03d3f55c-9e19-11eb-102b-f7ada99b5f83
# ╠═03d3f566-9e19-11eb-2dea-5ffd5cbcb49f
# ╠═03d3f586-9e19-11eb-3698-d175fb53f08e
# ╠═03d3f586-9e19-11eb-312d-75c048f97e75
# ╠═03d3f58e-9e19-11eb-11ef-a7374e14f98e
# ╠═03d3f58e-9e19-11eb-0345-a57845586678
# ╠═03d3f598-9e19-11eb-16c4-175b26db3089
# ╠═03d3f5a2-9e19-11eb-3a8b-e39d6c4b7854
# ╟─03d3f606-9e19-11eb-189d-713a908c1316
# ╟─03d3f64a-9e19-11eb-181c-d71be02a4fdb
# ╠═03d4007e-9e19-11eb-324c-45cd8d77e3a7
# ╠═03d40094-9e19-11eb-1d13-cf8cd2f6bec7
# ╠═03d4009c-9e19-11eb-119b-e30a93bd9edc
# ╟─03d400ba-9e19-11eb-18ab-2f4e0245701f
# ╟─03d4011e-9e19-11eb-0e34-6141c546ceb3
# ╠═03d40e52-9e19-11eb-0b7b-2543ba49c19d
# ╠═03d40e5c-9e19-11eb-262f-9b6298c70482
# ╠═03d40e5c-9e19-11eb-3e8c-7fe77d095ec4
# ╠═03d414e2-9e19-11eb-018b-4990adaf8821
# ╠═03d414f6-9e19-11eb-1a9a-a133c0f8361f
# ╠═03d414f6-9e19-11eb-0cba-377dc61f7e28
# ╟─03d4151e-9e19-11eb-38fc-b7bd02d93464
# ╟─03d41548-9e19-11eb-2230-6bc4713c6880
# ╟─03d41582-9e19-11eb-36e3-214691a62ecf
# ╟─03d41622-9e19-11eb-3bde-cba9a093569c
# ╟─03d4167e-9e19-11eb-21f6-f1cffb5a6ec2
# ╟─03d416b0-9e19-11eb-3868-5910989c0efc
# ╟─03d416cc-9e19-11eb-199f-6db35b3a9304
# ╟─03d41708-9e19-11eb-32a6-a14fde795647
# ╟─03d41726-9e19-11eb-0e6f-83a59c543283
# ╟─03d41742-9e19-11eb-2e82-c949d0d2c4fa
# ╟─03d41762-9e19-11eb-28b8-9f80f691de61
# ╟─03d41794-9e19-11eb-3833-d9261e6b39d6
# ╟─03d417a8-9e19-11eb-0191-47a7149adcac
# ╟─03d417bc-9e19-11eb-29cb-bd2b1a87d5c4
# ╟─03d417d0-9e19-11eb-3f7e-09e3c10111ef
# ╟─03d417ee-9e19-11eb-09ef-c1d1de223e1d
# ╟─03d417f8-9e19-11eb-262d-53b405b1344e
# ╟─03d4180c-9e19-11eb-34df-0f94590ca9c8
# ╟─03d4182a-9e19-11eb-2267-61fb55a72fae
# ╟─03d4183e-9e19-11eb-3b4a-ebc57e380249
# ╟─03d41852-9e19-11eb-0ee9-eda22fae93cf
# ╟─03d41878-9e19-11eb-3f3c-353be97e8c34
# ╟─03d41884-9e19-11eb-2609-67b37f485758
# ╟─03d41898-9e19-11eb-3ba4-197af74b95ae
# ╟─03d418aa-9e19-11eb-15f0-2767698eda7d
# ╟─03d418c0-9e19-11eb-1d98-97c456445c35
# ╟─03d418f2-9e19-11eb-39f0-8f56a468ee3e
# ╟─03d41938-9e19-11eb-2e2e-216f115978f7
# ╟─03d4194e-9e19-11eb-2a88-dd7195a57352
# ╟─03d41960-9e19-11eb-141c-bb25cc6f6da1
# ╟─03d41974-9e19-11eb-3e19-b9b64bd8abe7
# ╟─03d41992-9e19-11eb-21b2-a78eeb02a43f
# ╟─03d419ae-9e19-11eb-3364-c35e0b87ecf0
# ╟─03d419c4-9e19-11eb-0e6a-fb1214e38b2b
# ╟─03d419e0-9e19-11eb-3032-cb0a4e65324b
# ╟─03d419ec-9e19-11eb-3089-67ded60e6df1
# ╟─03d41a00-9e19-11eb-009d-c393589ac1f3
# ╟─03d41a28-9e19-11eb-13c6-6131bc41584e
# ╟─03d41a3c-9e19-11eb-38e2-214d4c1b8c1b
# ╟─03d41a64-9e19-11eb-38c4-d17fd716f7d0
# ╟─03d41a6e-9e19-11eb-36bb-f1faf93df73b
# ╟─03d41a8c-9e19-11eb-0fc3-2f693002fd19
# ╟─03d41aa0-9e19-11eb-2961-574dc417c226
# ╟─03d41ad2-9e19-11eb-29eb-11f462878653
# ╟─03d41bec-9e19-11eb-082a-bd25559f2040
# ╟─03d41bfe-9e19-11eb-18d7-1f2d540536c8
# ╟─03d41c12-9e19-11eb-3fdb-ebc5f7a912f0
# ╠═03d424bc-9e19-11eb-0bc7-b357e440aac1
# ╠═03d424c8-9e19-11eb-3ec6-ddfc36ddd131
# ╟─03d424dc-9e19-11eb-2efa-d73f4a7a35dd
# ╠═03d42d4c-9e19-11eb-2d0e-67bd154c4073
# ╠═03d42d6a-9e19-11eb-11e2-5de0c0e1a071
# ╠═03d42d6a-9e19-11eb-003c-0f5d196eb250
# ╟─03d42d92-9e19-11eb-1801-0f1f82301b08
# ╟─03d42da6-9e19-11eb-16ed-4914346b3cf9
# ╟─03d42dd8-9e19-11eb-13e7-291e17c0264c
# ╟─03d42dec-9e19-11eb-1bd2-85d34e90a59b
# ╟─03d42e0a-9e19-11eb-0133-87f0977755f0
# ╟─03d42e46-9e19-11eb-0be5-470df65a7699
# ╠═03d430a8-9e19-11eb-33e2-f5fb4ce90f39
# ╟─03d430d2-9e19-11eb-1ecc-1b0f4ac46cd9
# ╟─03d430ee-9e19-11eb-0fc1-c5468ae14c27
# ╠═03d4356a-9e19-11eb-0931-a7b71d20345b
# ╠═03d43576-9e19-11eb-2701-ff601681aaef
# ╟─03d435b2-9e19-11eb-01df-357ceeb255c9
# ╟─03d435ee-9e19-11eb-07ce-11a16892a8ce
# ╠═03d43dfa-9e19-11eb-35ac-2b806ca705d3
# ╠═03d43e04-9e19-11eb-2a02-95a1d60bd100
# ╟─03d43e5e-9e19-11eb-2385-e70a71814c52
# ╟─03d43e86-9e19-11eb-2bd0-272923811af3
# ╟─03d43ecc-9e19-11eb-0a2b-d54c8d73963f
# ╟─03d43f08-9e19-11eb-3923-3fd1aa559106
# ╟─03d43f44-9e19-11eb-3fe4-79c69ba4e08e
# ╟─03d43f62-9e19-11eb-106d-6f4022f7fcc1
# ╟─03d43f82-9e19-11eb-0ec4-a7c41137f19a
# ╟─03d43f9e-9e19-11eb-095b-31c27f6102f6
# ╟─03d43fb4-9e19-11eb-1773-4db086bb40a2
# ╠═03d4428c-9e19-11eb-0849-cbe88a67b247
# ╟─03d442aa-9e19-11eb-3365-c977618bd7e3
# ╟─03d442c8-9e19-11eb-0f70-d13f7ce01809
# ╟─03d4437c-9e19-11eb-38cf-f96bbed07490
# ╟─03d44390-9e19-11eb-1baf-1d89a2bc8fa0
# ╟─03d443ba-9e19-11eb-17e5-c111b00ef9cc
# ╟─03d443e0-9e19-11eb-048a-ab259092c8d0
# ╟─03d443fe-9e19-11eb-1288-4780e81bcf73
# ╟─03d44430-9e19-11eb-3017-6b0f10de9b90
# ╟─03d44444-9e19-11eb-3112-4b9b323534d0
# ╠═03d4489a-9e19-11eb-0a16-ed4dd0e6e3d8
# ╠═03d4489a-9e19-11eb-2b4c-5139e0ddb78c
# ╟─03d448e0-9e19-11eb-1aaa-d79467413663
# ╟─03d44912-9e19-11eb-0357-f906dc7bb5df
# ╟─03d4493a-9e19-11eb-1a6b-9dc3bb7b06c8
# ╟─03d4495a-9e19-11eb-14b5-03feaca0fb2e
# ╠═03d45146-9e19-11eb-2b54-7d68ee8e69b8
# ╠═03d45150-9e19-11eb-23e0-4b05f1de2331
# ╠═03d4515a-9e19-11eb-27a3-4bea80b10de8
# ╟─03d4518c-9e19-11eb-2c9a-732b2adaec41
# ╟─03d451aa-9e19-11eb-0bc9-f10b4d7496e2
# ╟─03d451be-9e19-11eb-16b1-ffa57a83168a
# ╟─03d451d2-9e19-11eb-2781-6762734e7bfe
# ╠═03d45cae-9e19-11eb-198e-4f17a6cfa44d
# ╠═03d45cae-9e19-11eb-268e-05af8b0ecda1
# ╟─03d45ccc-9e19-11eb-0487-2784bbfcab37
# ╠═03d46d98-9e19-11eb-2fd9-1b1caa725ad5
# ╠═03d46db4-9e19-11eb-2986-53edb0ac6103
# ╟─03d46dde-9e19-11eb-0f91-1f019bf9956c
# ╠═03d47072-9e19-11eb-083d-b571e519a96f
# ╠═03d4707c-9e19-11eb-1f64-5d43385bf84d
# ╟─03d470c2-9e19-11eb-068e-bd835ccd43b2
# ╟─03d470f6-9e19-11eb-211a-ab32bb12ffab
# ╟─03d47112-9e19-11eb-23b3-3586e9b6df3d
# ╟─03d47144-9e19-11eb-2b1f-99479db52673
# ╟─03d47176-9e19-11eb-2432-712550e158df
# ╠═03d479d2-9e19-11eb-3e7f-4db7d880dd73
# ╠═03d479e6-9e19-11eb-3d0a-9923b8afe4fe
# ╟─03d47a36-9e19-11eb-0dbd-710a44f176e6
# ╠═03d47fe0-9e19-11eb-0d37-d916d0b57e3d
# ╠═03d47fea-9e19-11eb-176a-af09f7b0ca4e
# ╠═03d47ff4-9e19-11eb-0d0b-69f9776f0db7
# ╠═03d47ff4-9e19-11eb-1e58-117d23d40c39
# ╟─03d48044-9e19-11eb-03bf-3da2b3c10407
# ╟─03d48062-9e19-11eb-3863-e7d81fd665de
# ╟─03d4815c-9e19-11eb-19a7-1bdf2225b65c
# ╟─03d481fc-9e19-11eb-3426-a188d0bdea7e
# ╠═03d48e54-9e19-11eb-2dd0-27b0b4154e2c
# ╠═03d48e54-9e19-11eb-3a87-1d7db05df813
# ╠═03d48e68-9e19-11eb-1e56-83870ec3f888
# ╠═03d48e72-9e19-11eb-1791-13cc8feed8ec
# ╠═03d48e7a-9e19-11eb-3c19-fdb5bd1ce805
# ╟─03d48e90-9e19-11eb-095c-6137a1ebd2a1
# ╟─03d48ea4-9e19-11eb-3fa8-e9c75ed31bfb
# ╟─03d48ecc-9e19-11eb-2cb5-21dd786e6b0d
# ╟─03d48ed6-9e19-11eb-1e1d-5361555d6f8d
# ╠═03d49ea8-9e19-11eb-136c-55602565b636
# ╠═03d49eb2-9e19-11eb-3501-7173af36b88e
# ╠═03d49ed0-9e19-11eb-1fd1-e3bbc5b2af4b
# ╠═03d49ed0-9e19-11eb-0931-f99f17de4e34
# ╠═03d49eda-9e19-11eb-0c9b-49ecfc309834
# ╠═03d49eda-9e19-11eb-0154-2b68f0cb88a1
# ╠═03d49ee4-9e19-11eb-2854-e7e69472287c
# ╠═03d49eee-9e19-11eb-18b5-e7e5b83d4c6f
# ╟─03d49f02-9e19-11eb-190f-5bbc8216d5cf
# ╟─03d49f0c-9e19-11eb-002e-b53c0d65ef1a
# ╟─03d49f52-9e19-11eb-171f-77a0ffd58c7b
# ╟─03d49f70-9e19-11eb-0aa4-bf05874e339e
# ╟─03d49f84-9e19-11eb-3d43-eb8d0d057593
# ╟─03d49fac-9e19-11eb-15a5-c97b4f084275
# ╟─03d49fd4-9e19-11eb-18e7-c31a43ed8fdc
# ╟─03d49ff2-9e19-11eb-3a06-393d86692469
# ╟─03d4a010-9e19-11eb-1864-8fe65dbbb738
# ╟─03d4a01a-9e19-11eb-178f-9d9b2b03d5c9
# ╟─03d4a02c-9e19-11eb-00ea-3ba09b3ee114
# ╟─03d4a038-9e19-11eb-3d54-59f9c178c6dc
# ╟─03d4a056-9e19-11eb-2c8c-79bf7d779e1d
# ╟─03d4a05e-9e19-11eb-13fd-5751229ebc58
# ╟─03d4a074-9e19-11eb-210e-05d160fe1a09
# ╟─03d4a092-9e19-11eb-3585-052a0bcedc97
# ╟─03d4a09c-9e19-11eb-2490-c5b53e46ca73
# ╟─03d4a0b0-9e19-11eb-0f04-57edf6d80fcb
# ╟─03d4a0f6-9e19-11eb-280e-a57c2eb9d210
# ╟─03d4a114-9e19-11eb-272b-451145e5f132
# ╟─03d4a11e-9e19-11eb-1ac2-ebaf7346799d
# ╟─03d4a13c-9e19-11eb-1998-996a75abc5cc
# ╟─03d4a150-9e19-11eb-077b-c1d027288622
# ╟─03d4a27c-9e19-11eb-0a6e-a9bf63e1ada5
# ╟─03d4a29c-9e19-11eb-0bba-19d3238f2347
# ╟─03d4a2a4-9e19-11eb-0765-b7792701444a
# ╟─03d4a3c6-9e19-11eb-1b95-21da954e9fe2
# ╟─03d4a3e4-9e19-11eb-1c6c-7f6d2827719a
# ╟─03d4a4b6-9e19-11eb-1e34-c937d2fe2f7c
# ╟─03d4a4d4-9e19-11eb-00b8-e3e1ce146379
# ╟─03d4a4f2-9e19-11eb-3fc5-b920d9126456
# ╟─03d4a51a-9e19-11eb-1fb6-2795b4692fc4
# ╠═03d4a722-9e19-11eb-221e-4d4113308356
# ╟─03d4a740-9e19-11eb-1787-351a46a8bc71
# ╟─03d4a772-9e19-11eb-1a1d-c5ac82dffc5d
# ╟─03d4a79a-9e19-11eb-0b6d-9bd86e58fdfb
# ╟─03d4a7ae-9e19-11eb-18ca-6d03bdc6957b
# ╠═03d4a894-9e19-11eb-3cae-db883b5f0440
# ╟─03d4a8d0-9e19-11eb-2432-8389bc32fab0
# ╟─03d4a8e4-9e19-11eb-0cae-a104ee2b4eb4
# ╟─03d4a920-9e19-11eb-04fe-af76380b6c38
# ╟─03d4a940-9e19-11eb-1fb1-9f1e6de8418a
# ╠═03d4add8-9e19-11eb-36c2-c7ef626944ad
# ╠═03d4ade4-9e19-11eb-3341-9f60fabbdcf2
# ╠═03d4ade4-9e19-11eb-2586-e7ed5cf8b32a
# ╠═03d4ae02-9e19-11eb-3764-8d5923e3cfb8
# ╟─03d4ae20-9e19-11eb-37a2-01e9e910834f
# ╟─03d4ae52-9e19-11eb-36b6-ab2f8660d24f
# ╟─03d4ae66-9e19-11eb-141a-71758dfe94a1
# ╟─03d4ae8e-9e19-11eb-2822-976a23967404
# ╟─03d4aeae-9e19-11eb-0499-cdbda3326aa5
# ╠═03d4afce-9e19-11eb-01e0-51d57e4f42c7
# ╟─03d4afec-9e19-11eb-1085-5be2440eb103
# ╟─03d4b000-9e19-11eb-287d-ebe8b8c721a9
# ╟─03d4b016-9e19-11eb-049f-4d2631a082e8
# ╠═03d4b750-9e19-11eb-046c-d969daa56dac
# ╠═03d4b762-9e19-11eb-1832-df33cf32f58f
# ╠═03d4b762-9e19-11eb-2036-2921bdaa93f5
# ╟─03d4b77e-9e19-11eb-0e99-b328947ad26c
# ╟─03d4b794-9e19-11eb-1edc-df469244e84c
# ╟─03d4b7d0-9e19-11eb-10a6-d3f05c656de4
# ╟─03d4b7ee-9e19-11eb-2ad7-71bb297a95c6
# ╠═03d4c036-9e19-11eb-3414-f7740c7bbe20
# ╠═03d4c04a-9e19-11eb-1ede-1ffb2511b32a
# ╠═03d4c054-9e19-11eb-18e1-c9abe51d1ff3
# ╟─03d4c09a-9e19-11eb-1eef-415663ce4d5c
# ╟─03d4c0d6-9e19-11eb-2d2a-392420efda12
# ╟─03d4c124-9e19-11eb-23ff-af1b23484742
# ╟─03d4c130-9e19-11eb-039a-51353422304f
# ╟─03d4c342-9e19-11eb-0f30-db24c5c706ff
# ╟─03d4c362-9e19-11eb-089e-811b8468bc12
# ╟─03d4c374-9e19-11eb-30c9-652aa68a07a3
# ╟─03d4c388-9e19-11eb-1b49-ebd395a92821
# ╟─03d4c3ba-9e19-11eb-1175-ebffe1edf568
# ╟─03d4c3e2-9e19-11eb-33dd-c744c3698f6a
# ╟─03d4c400-9e19-11eb-3268-5f5966b072be
# ╟─03d4c426-9e19-11eb-2c26-d37c807d3010
# ╟─03d4c43c-9e19-11eb-2c4b-b5b9dd813ef9
# ╟─03d4c450-9e19-11eb-39ec-d15260c8f285
# ╟─03d4c478-9e19-11eb-176b-7b2b810159ac
# ╟─03d4c48c-9e19-11eb-1ecc-a3318dbb1eab
# ╟─03d4c4be-9e19-11eb-2150-fb1625006367
# ╟─03d4c4d2-9e19-11eb-13ea-83ad3a624321
# ╟─03d4c4fc-9e19-11eb-0853-b9f70f37df73
