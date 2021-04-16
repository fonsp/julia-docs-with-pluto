### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ 74a0322d-6a11-49bf-a137-1df0adaa1965
md"""
# [Performance Tips](@id man-performance-tips)
"""

# ╔═╡ dcd19b1c-9ebf-4a6b-a0c4-a1b3933aeadb
md"""
In the following sections, we briefly go through a few techniques that can help make your Julia code run as fast as possible.
"""

# ╔═╡ 62937f65-6404-410e-9d7a-039aceccafcf
md"""
## Avoid global variables
"""

# ╔═╡ 886e9b53-41e1-488c-8474-d2e1907f6897
md"""
A global variable might have its value, and therefore its type, change at any point. This makes it difficult for the compiler to optimize code using global variables. Variables should be local, or passed as arguments to functions, whenever possible.
"""

# ╔═╡ 8b8db9e7-42f0-4231-9534-b0d65c22b05d
md"""
Any code that is performance critical or being benchmarked should be inside a function.
"""

# ╔═╡ 7115e055-33dd-4e04-a3ca-b9ec1f6337ea
md"""
We find that global names are frequently constants, and declaring them as such greatly improves performance:
"""

# ╔═╡ b4fc996c-49b0-4404-96b3-1042cb8d3f0f
md"""
```julia
const DEFAULT_VAL = 0
```
"""

# ╔═╡ 1b606e97-c4ed-4110-9852-d9086323061a
md"""
Uses of non-constant globals can be optimized by annotating their types at the point of use:
"""

# ╔═╡ 1100c6c0-39c7-458b-9511-6c5c0433ea20
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

# ╔═╡ d7bffdae-f7a2-4103-b890-0b5b9a01ba3d
md"""
Passing arguments to functions is better style. It leads to more reusable code and clarifies what the inputs and outputs are.
"""

# ╔═╡ b21f14aa-4112-4cec-89ba-d1e7c4c0fffe
md"""
!!! note
    All code in the REPL is evaluated in global scope, so a variable defined and assigned at top level will be a **global** variable. Variables defined at top level scope inside modules are also global.
"""

# ╔═╡ 45aa58ab-aad8-4835-a1dd-21ba6d81adf2
md"""
In the following REPL session:
"""

# ╔═╡ 35f61526-22c9-40b8-befc-42902c247ba5
x = 1.0

# ╔═╡ 6b6a6c09-e5fc-4a0b-9335-32409200ec45
md"""
is equivalent to:
"""

# ╔═╡ 9f1b67be-7a3a-41f4-9f89-2dbb125b8d3c
global x = 1.0

# ╔═╡ 444c8931-76fb-4ce0-b764-b35e35b63b13
md"""
so all the performance issues discussed previously apply.
"""

# ╔═╡ 9332aad8-aec5-4ca2-9afb-20d74e8117ba
md"""
## Measure performance with [`@time`](@ref) and pay attention to memory allocation
"""

# ╔═╡ 7297b697-a426-4886-ac15-e65077c02f5d
md"""
A useful tool for measuring performance is the [`@time`](@ref) macro. We here repeat the example with the global variable above, but this time with the type annotation removed:
"""

# ╔═╡ 56cdb4de-d871-4ca3-bfef-d91c73676f13
x = rand(1000);

# ╔═╡ a773b461-a5cd-4805-9328-ecb092f3782a
function sum_global()
     s = 0.0
     for i in x
         s += i
     end
     return s
 end;

# ╔═╡ 0e243d8a-6c22-41e9-bc38-0c02d643dfa8
@time sum_global()

# ╔═╡ c3985e75-f2d8-401d-8189-c853b60fe1c0
@time sum_global()

# ╔═╡ 8a2728e6-dc2e-4b4d-ac56-52df3c1d542b
md"""
On the first call (`@time sum_global()`) the function gets compiled. (If you've not yet used [`@time`](@ref) in this session, it will also compile functions needed for timing.)  You should not take the results of this run seriously. For the second run, note that in addition to reporting the time, it also indicated that a significant amount of memory was allocated. We are here just computing a sum over all elements in a vector of 64-bit floats so there should be no need to allocate memory (at least not on the heap which is what `@time` reports).
"""

# ╔═╡ af0c41ef-18bc-4d65-b332-2626bb1fef72
md"""
Unexpected memory allocation is almost always a sign of some problem with your code, usually a problem with type-stability or creating many small temporary arrays. Consequently, in addition to the allocation itself, it's very likely that the code generated for your function is far from optimal. Take such indications seriously and follow the advice below.
"""

# ╔═╡ b8aba5bb-bed7-4f14-8053-f765f4486331
md"""
If we instead pass `x` as an argument to the function it no longer allocates memory (the allocation reported below is due to running the `@time` macro in global scope) and is significantly faster after the first call:
"""

# ╔═╡ 01f8f809-cf4e-4985-b04f-99af98aab8c2
x = rand(1000);

# ╔═╡ a2c8cee9-b534-47ad-b262-91d65af2a653
function sum_arg(x)
     s = 0.0
     for i in x
         s += i
     end
     return s
 end;

# ╔═╡ c639c06b-20f5-422e-99f1-7358d2df6990
@time sum_arg(x)

# ╔═╡ 5c2bd3f3-70c1-4f48-b9a8-3c3988be4319
@time sum_arg(x)

# ╔═╡ 352072c4-514e-4007-818a-9d8c81b4c781
md"""
The 1 allocation seen is from running the `@time` macro itself in global scope. If we instead run the timing in a function, we can see that indeed no allocations are performed:
"""

# ╔═╡ dd69a1fc-aa68-4eec-b1b5-152ad54dd9fe
time_sum(x) = @time sum_arg(x);

# ╔═╡ 27a4778e-82d3-4551-a902-976b0775db67
time_sum(x)

# ╔═╡ 2743608a-235d-408f-a886-a495fc31d8b2
md"""
In some situations, your function may need to allocate memory as part of its operation, and this can complicate the simple picture above. In such cases, consider using one of the [tools](@ref tools) below to diagnose problems, or write a version of your function that separates allocation from its algorithmic aspects (see [Pre-allocating outputs](@ref)).
"""

# ╔═╡ bf43c133-a969-472c-8e9c-460d826e3f83
md"""
!!! note
    For more serious benchmarking, consider the [BenchmarkTools.jl](https://github.com/JuliaCI/BenchmarkTools.jl) package which among other things evaluates the function multiple times in order to reduce noise.
"""

# ╔═╡ d0d02497-514d-4fac-b7b7-1cc0c71710f3
md"""
## [Tools](@id tools)
"""

# ╔═╡ 89a144ec-baa6-4036-acef-4f8e4544d773
md"""
Julia and its package ecosystem includes tools that may help you diagnose problems and improve the performance of your code:
"""

# ╔═╡ e6ae554b-28d1-4f8e-84e0-9ca66a4967e2
md"""
  * [Profiling](@ref) allows you to measure the performance of your running code and identify lines that serve as bottlenecks. For complex projects, the [ProfileView](https://github.com/timholy/ProfileView.jl) package can help you visualize your profiling results.
  * The [Traceur](https://github.com/JunoLab/Traceur.jl) package can help you find common performance problems in your code.
  * Unexpectedly-large memory allocations–as reported by [`@time`](@ref), [`@allocated`](@ref), or the profiler (through calls to the garbage-collection routines)–hint that there might be issues with your code. If you don't see another reason for the allocations, suspect a type problem.  You can also start Julia with the `--track-allocation=user` option and examine the resulting `*.mem` files to see information about where those allocations occur. See [Memory allocation analysis](@ref).
  * `@code_warntype` generates a representation of your code that can be helpful in finding expressions that result in type uncertainty. See [`@code_warntype`](@ref) below.
"""

# ╔═╡ 5d34ce4b-1e8c-42ea-9e13-eefa0524ad24
md"""
## [Avoid containers with abstract type parameters](@id man-performance-abstract-container)
"""

# ╔═╡ d58d8317-cf93-4921-92a7-93a3ad07cdcb
md"""
When working with parameterized types, including arrays, it is best to avoid parameterizing with abstract types where possible.
"""

# ╔═╡ 6ea38242-5ee3-48c3-9483-772cb02c7486
md"""
Consider the following:
"""

# ╔═╡ 99042a13-79b3-4fd9-a5da-0872dd55f539
a = Real[]

# ╔═╡ 82268b23-ab8b-4fa6-8be7-5c2b22bfa3dc
push!(a, 1); push!(a, 2.0); push!(a, π)

# ╔═╡ 71a6ff64-1b34-449a-a970-9290e828bd24
md"""
Because `a` is an array of abstract type [`Real`](@ref), it must be able to hold any `Real` value. Since `Real` objects can be of arbitrary size and structure, `a` must be represented as an array of pointers to individually allocated `Real` objects. However, if we instead only allow numbers of the same type, e.g. [`Float64`](@ref), to be stored in `a` these can be stored more efficiently:
"""

# ╔═╡ 16ce0cb6-cada-44ac-9c7b-d8c3a5972893
a = Float64[]

# ╔═╡ 21e39956-57f2-4b6e-8a26-dd115566629c
push!(a, 1); push!(a, 2.0); push!(a,  π)

# ╔═╡ f8b34280-a4cb-4028-86ca-618cba1702db
md"""
Assigning numbers into `a` will now convert them to `Float64` and `a` will be stored as a contiguous block of 64-bit floating-point values that can be manipulated efficiently.
"""

# ╔═╡ 6901c405-ecb7-40ef-8062-bb99aadd602a
md"""
If you cannot avoid containers with abstract value types, it is sometimes better to parametrize with `Any` to avoid runtime type checking. E.g. `IdDict{Any, Any}` performs better than `IdDict{Type, Vector}`
"""

# ╔═╡ f7e9e00a-9e5e-4f6a-9279-210c92a9deca
md"""
See also the discussion under [Parametric Types](@ref).
"""

# ╔═╡ 74524077-ce3b-4bbe-8005-1385f1ece137
md"""
## Type declarations
"""

# ╔═╡ 4ef2a123-940d-4299-83ce-4a4222b1749d
md"""
In many languages with optional type declarations, adding declarations is the principal way to make code run faster. This is *not* the case in Julia. In Julia, the compiler generally knows the types of all function arguments, local variables, and expressions. However, there are a few specific instances where declarations are helpful.
"""

# ╔═╡ 9f88466f-3da7-4ebb-9343-0da792cd820c
md"""
### Avoid fields with abstract type
"""

# ╔═╡ 600a8a06-8cde-4b43-965d-7cff5e26ff23
md"""
Types can be declared without specifying the types of their fields:
"""

# ╔═╡ 5cb47aed-0d74-4747-8732-ed1ecb0edfab
struct MyAmbiguousType
     a
 end

# ╔═╡ 8d327e0a-239f-420f-94a2-f8852378fff8
md"""
This allows `a` to be of any type. This can often be useful, but it does have a downside: for objects of type `MyAmbiguousType`, the compiler will not be able to generate high-performance code. The reason is that the compiler uses the types of objects, not their values, to determine how to build code. Unfortunately, very little can be inferred about an object of type `MyAmbiguousType`:
"""

# ╔═╡ 58ff13d9-dc55-4e9e-b628-f8f82f3eac21
b = MyAmbiguousType("Hello")

# ╔═╡ 27f563a6-8045-4dd4-b41d-08be31054449
c = MyAmbiguousType(17)

# ╔═╡ c49feaef-be58-4df2-a78a-7af62c6e1895
typeof(b)

# ╔═╡ 4e76ac16-a554-41dd-a087-3f6911518fb4
typeof(c)

# ╔═╡ 9f4850f9-7334-4b83-9b1c-667a8e9a6817
md"""
The values of `b` and `c` have the same type, yet their underlying representation of data in memory is very different. Even if you stored just numeric values in field `a`, the fact that the memory representation of a [`UInt8`](@ref) differs from a [`Float64`](@ref) also means that the CPU needs to handle them using two different kinds of instructions. Since the required information is not available in the type, such decisions have to be made at run-time. This slows performance.
"""

# ╔═╡ 56ad807a-c388-4ac3-8de0-8f68a01a334c
md"""
You can do better by declaring the type of `a`. Here, we are focused on the case where `a` might be any one of several types, in which case the natural solution is to use parameters. For example:
"""

# ╔═╡ acec5b85-9828-44e7-99d9-4b6d4a703f04
mutable struct MyType{T<:AbstractFloat}
     a::T
 end

# ╔═╡ f42f3b48-0468-4287-94b5-340eb5900738
md"""
This is a better choice than
"""

# ╔═╡ 9241f943-1909-40af-9e70-5396c5543a14
mutable struct MyStillAmbiguousType
     a::AbstractFloat
 end

# ╔═╡ c7df9264-ecc4-4e2d-bd23-3b198e66127b
md"""
because the first version specifies the type of `a` from the type of the wrapper object. For example:
"""

# ╔═╡ 4e2d1342-c0a0-48d8-a58c-76a5b9aaab78
m = MyType(3.2)

# ╔═╡ 26a8d6d3-86be-42a3-8a1c-32973678bfe1
t = MyStillAmbiguousType(3.2)

# ╔═╡ 0b6cff6c-e39c-49cc-839d-61f6dbc84c0d
typeof(m)

# ╔═╡ 797d6b0e-5234-4128-b484-89f51c44f959
typeof(t)

# ╔═╡ 83d0ec33-3c70-4a5c-ae7b-6e73c8145f84
md"""
The type of field `a` can be readily determined from the type of `m`, but not from the type of `t`. Indeed, in `t` it's possible to change the type of the field `a`:
"""

# ╔═╡ 3bfe86ae-3380-4b60-a83d-42ff38ec0213
typeof(t.a)

# ╔═╡ dcbc2be4-9fb5-46b3-924d-70e3e94225f5
t.a = 4.5f0

# ╔═╡ 824ab3c5-586f-41fb-ac79-460424b9c9b7
typeof(t.a)

# ╔═╡ dc9b7d47-818c-4b6d-99b7-346e42c7a3a3
md"""
In contrast, once `m` is constructed, the type of `m.a` cannot change:
"""

# ╔═╡ b9ff1d16-8c53-4645-bc04-29bbfa64ed32
m.a = 4.5f0

# ╔═╡ a28c0a1e-a9a5-4590-9e2b-5840561413fc
typeof(m.a)

# ╔═╡ 2e8265e7-d5f9-4f76-9018-cc27f9b66fa0
md"""
The fact that the type of `m.a` is known from `m`'s type—coupled with the fact that its type cannot change mid-function—allows the compiler to generate highly-optimized code for objects like `m` but not for objects like `t`.
"""

# ╔═╡ d5f3e142-d44a-43a6-a25a-149e27af012a
md"""
Of course, all of this is true only if we construct `m` with a concrete type. We can break this by explicitly constructing it with an abstract type:
"""

# ╔═╡ d4248879-5486-4cd3-9ca9-493d07ce2daf
m = MyType{AbstractFloat}(3.2)

# ╔═╡ 1ec53372-c657-493b-8ee7-3152be2274f9
typeof(m.a)

# ╔═╡ 4a04f0fa-edd8-4bdf-b59a-20cdebd22251
m.a = 4.5f0

# ╔═╡ 97427e74-8435-4af2-ae89-e4ee6067c0ec
typeof(m.a)

# ╔═╡ 0329c262-bf8f-4843-8652-ab084cfae3df
md"""
For all practical purposes, such objects behave identically to those of `MyStillAmbiguousType`.
"""

# ╔═╡ a4384062-28eb-45de-a7eb-555dd7146f89
md"""
It's quite instructive to compare the sheer amount code generated for a simple function
"""

# ╔═╡ 4409ea61-5b35-49d5-8f7a-24e84186dd79
md"""
```julia
func(m::MyType) = m.a+1
```
"""

# ╔═╡ 2626ec4e-faa0-4e37-9748-b21d711b968f
md"""
using
"""

# ╔═╡ 0713157f-a50d-4013-b096-212922776911
md"""
```julia
code_llvm(func, Tuple{MyType{Float64}})
code_llvm(func, Tuple{MyType{AbstractFloat}})
```
"""

# ╔═╡ cfca57b7-070d-45b8-8b92-c95e3b06d35d
md"""
For reasons of length the results are not shown here, but you may wish to try this yourself. Because the type is fully-specified in the first case, the compiler doesn't need to generate any code to resolve the type at run-time. This results in shorter and faster code.
"""

# ╔═╡ 6915a37d-15ab-4f12-b5c0-4274ddba6d0a
md"""
### Avoid fields with abstract containers
"""

# ╔═╡ f63a7881-d7e4-4193-9a3e-c0876f89d7a2
md"""
The same best practices also work for container types:
"""

# ╔═╡ 3a1a12d7-094a-4a65-b4c1-19afc395a0b0
struct MySimpleContainer{A<:AbstractVector}
     a::A
 end

# ╔═╡ d10e45f6-5705-41d4-96bf-7f8c8008765e
struct MyAmbiguousContainer{T}
     a::AbstractVector{T}
 end

# ╔═╡ d25d9b19-4d4e-4a58-9652-c0c525219a88
md"""
For example:
"""

# ╔═╡ bc245bbd-dcfd-4837-8c77-3afd102ed775
c = MySimpleContainer(1:3);

# ╔═╡ 440a773f-28bd-4c08-a95e-0577f8e176be
typeof(c)

# ╔═╡ ef7ba24b-577a-4b5d-ab5c-f095c5d166cd
c = MySimpleContainer([1:3;]);

# ╔═╡ c88866bc-08be-4435-91e3-854766d67df5
typeof(c)

# ╔═╡ 11b3a959-eb53-495b-b221-5d01b14e8471
b = MyAmbiguousContainer(1:3);

# ╔═╡ 5894b572-d420-48dd-a6f1-278c5b1a196a
typeof(b)

# ╔═╡ 3ca21ad1-6736-435c-a8a8-0c4e87c998ee
b = MyAmbiguousContainer([1:3;]);

# ╔═╡ 646dfe68-df88-4be1-8c9c-08f3ce28e1b4
typeof(b)

# ╔═╡ d8fc5af7-22e8-4a4a-8052-f3cca3cdf6cc
md"""
For `MySimpleContainer`, the object is fully-specified by its type and parameters, so the compiler can generate optimized functions. In most instances, this will probably suffice.
"""

# ╔═╡ 656ddd27-c0b2-49fb-a099-c0e863e4d0d2
md"""
While the compiler can now do its job perfectly well, there are cases where *you* might wish that your code could do different things depending on the *element type* of `a`. Usually the best way to achieve this is to wrap your specific operation (here, `foo`) in a separate function:
"""

# ╔═╡ 2aa155cd-729f-49ad-b25c-e1be2266750f
function sumfoo(c::MySimpleContainer)
     s = 0
     for x in c.a
         s += foo(x)
     end
     s
 end

# ╔═╡ ab87e407-7c0b-4521-84ba-72de1e64635e
foo(x::Integer) = x

# ╔═╡ 1d678381-1416-486a-8fe7-a42a29bc704f
foo(x::AbstractFloat) = round(x)

# ╔═╡ 575c0a35-4a94-41b1-a6de-248c5053958f
md"""
This keeps things simple, while allowing the compiler to generate optimized code in all cases.
"""

# ╔═╡ 3268eefd-8fda-4e5d-8799-2f2e8fc5e72d
md"""
However, there are cases where you may need to declare different versions of the outer function for different element types or types of the `AbstractVector` of the field `a` in `MySimpleContainer`. You could do it like this:
"""

# ╔═╡ c8c6612a-c6c3-47da-86a5-fe94e3bdebd7
function myfunc(c::MySimpleContainer{<:AbstractArray{<:Integer}})
     return c.a[1]+1
 end

# ╔═╡ fae8d7cf-7460-4745-a848-80dd8b16e4ad
function myfunc(c::MySimpleContainer{<:AbstractArray{<:AbstractFloat}})
     return c.a[1]+2
 end

# ╔═╡ 1e46c398-48c3-4cca-bf27-84e711ad6ddd
function myfunc(c::MySimpleContainer{Vector{T}}) where T <: Integer
     return c.a[1]+3
 end

# ╔═╡ dc74a6d4-64d4-49ab-8c17-de3c6a181086
myfunc(MySimpleContainer(1:3))

# ╔═╡ f815f8a5-8323-408f-a1a4-be52258b5f26
myfunc(MySimpleContainer(1.0:3))

# ╔═╡ cea50d4c-7ae9-4cf1-b839-761719fce65d
myfunc(MySimpleContainer([1:3;]))

# ╔═╡ ca6978aa-fa87-47f8-b57a-6b631ed92a54
md"""
### Annotate values taken from untyped locations
"""

# ╔═╡ f2feaaae-24a9-4b9b-8ae7-6c1dc88c7905
md"""
It is often convenient to work with data structures that may contain values of any type (arrays of type `Array{Any}`). But, if you're using one of these structures and happen to know the type of an element, it helps to share this knowledge with the compiler:
"""

# ╔═╡ df6a7329-9f65-4196-a255-c1e5c7f07e98
md"""
```julia
function foo(a::Array{Any,1})
    x = a[1]::Int32
    b = x+1
    ...
end
```
"""

# ╔═╡ cb22e3f6-64f4-4f58-8d9e-ffea55041688
md"""
Here, we happened to know that the first element of `a` would be an [`Int32`](@ref). Making an annotation like this has the added benefit that it will raise a run-time error if the value is not of the expected type, potentially catching certain bugs earlier.
"""

# ╔═╡ f9ebb06b-2069-4341-a384-be2b9bba75b1
md"""
In the case that the type of `a[1]` is not known precisely, `x` can be declared via `x = convert(Int32, a[1])::Int32`. The use of the [`convert`](@ref) function allows `a[1]` to be any object convertible to an `Int32` (such as `UInt8`), thus increasing the genericity of the code by loosening the type requirement. Notice that `convert` itself needs a type annotation in this context in order to achieve type stability. This is because the compiler cannot deduce the type of the return value of a function, even `convert`, unless the types of all the function's arguments are known.
"""

# ╔═╡ 854a1031-8c93-4b12-be00-d2ae16cbdfed
md"""
Type annotation will not enhance (and can actually hinder) performance if the type is abstract, or constructed at run-time. This is because the compiler cannot use the annotation to specialize the subsequent code, and the type-check itself takes time. For example, in the code:
"""

# ╔═╡ e05738f7-0e75-47e2-9cdd-1677869789c3
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

# ╔═╡ 497f2d90-e48b-4df7-b6dc-86484d840008
md"""
the annotation of `c` harms performance. To write performant code involving types constructed at run-time, use the [function-barrier technique](@ref kernel-functions) discussed below, and ensure that the constructed type appears among the argument types of the kernel function so that the kernel operations are properly specialized by the compiler. For example, in the above snippet, as soon as `b` is constructed, it can be passed to another function `k`, the kernel. If, for example, function `k` declares `b` as an argument of type `Complex{T}`, where `T` is a type parameter, then a type annotation appearing in an assignment statement within `k` of the form:
"""

# ╔═╡ b80c6743-0588-4be6-9a7e-6f66561362c9
md"""
```julia
c = (b + 1.0f0)::Complex{T}
```
"""

# ╔═╡ bba3aa7f-6957-45fa-8980-1eeaca8e668a
md"""
does not hinder performance (but does not help either) since the compiler can determine the type of `c` at the time `k` is compiled.
"""

# ╔═╡ c9a0a979-35c0-4ac2-acd5-0b7df7c80650
md"""
### Be aware of when Julia avoids specializing
"""

# ╔═╡ ce2825ac-d059-49c7-addf-66d33ee97711
md"""
As a heuristic, Julia avoids automatically specializing on argument type parameters in three specific cases: `Type`, `Function`, and `Vararg`. Julia will always specialize when the argument is used within the method, but not if the argument is just passed through to another function. This usually has no performance impact at runtime and [improves compiler performance](@ref compiler-efficiency-issues). If you find it does have a performance impact at runtime in your case, you can trigger specialization by adding a type parameter to the method declaration. Here are some examples:
"""

# ╔═╡ d5658435-8f23-44ee-ba2c-20a756352bf6
md"""
This will not specialize:
"""

# ╔═╡ 1ade4089-1b18-41fb-8197-f2b5025c9ab8
md"""
```julia
function f_type(t)  # or t::Type
    x = ones(t, 10)
    return sum(map(sin, x))
end
```
"""

# ╔═╡ baf347c2-99a3-42b8-adda-ec687eeeaee8
md"""
but this will:
"""

# ╔═╡ 411d650e-1ad3-4fef-a572-66c21615fdc0
md"""
```julia
function g_type(t::Type{T}) where T
    x = ones(T, 10)
    return sum(map(sin, x))
end
```
"""

# ╔═╡ e66c295f-a171-4f9d-85e8-a8a781fd0716
md"""
These will not specialize:
"""

# ╔═╡ 8992ef1a-7006-4460-8de2-f1a171a16f06
md"""
```julia
f_func(f, num) = ntuple(f, div(num, 2))
g_func(g::Function, num) = ntuple(g, div(num, 2))
```
"""

# ╔═╡ ed64e1e4-bd2e-4b10-9a31-589fc3100589
md"""
but this will:
"""

# ╔═╡ 921e52ea-364f-415a-bb7d-bd896fb7703d
md"""
```julia
h_func(h::H, num) where {H} = ntuple(h, div(num, 2))
```
"""

# ╔═╡ b2e37cf5-d39b-4c93-b247-4579bcd61406
md"""
This will not specialize:
"""

# ╔═╡ f9cda48f-7e65-4241-8f32-2182b508d262
md"""
```julia
f_vararg(x::Int...) = tuple(x...)
```
"""

# ╔═╡ bc429b64-665f-478f-bf71-739a82a22727
md"""
but this will:
"""

# ╔═╡ 08fdc9ab-cc4a-41a5-9b0a-009b1720dee7
md"""
```julia
g_vararg(x::Vararg{Int, N}) where {N} = tuple(x...)
```
"""

# ╔═╡ 07499d78-e439-42c7-a9e2-46e96d514473
md"""
One only needs to introduce a single type parameter to force specialization, even if the other types are unconstrained. For example, this will also specialize, and is useful when the arguments are not all of the same type:
"""

# ╔═╡ feba96ed-ca96-4d8b-a613-65ec50e6df63
md"""
```julia
h_vararg(x::Vararg{Any, N}) where {N} = tuple(x...)
```
"""

# ╔═╡ 6883abe1-e655-4975-b710-9cc90210963a
md"""
Note that [`@code_typed`](@ref) and friends will always show you specialized code, even if Julia would not normally specialize that method call. You need to check the [method internals](@ref ast-lowered-method) if you want to see whether specializations are generated when argument types are changed, i.e., if `(@which f(...)).specializations` contains specializations for the argument in question.
"""

# ╔═╡ d23a5283-98d2-483c-8429-3f22d6e1db6e
md"""
## Break functions into multiple definitions
"""

# ╔═╡ b250bbbb-df29-4513-8a38-48b1d947212b
md"""
Writing a function as many small definitions allows the compiler to directly call the most applicable code, or even inline it.
"""

# ╔═╡ a5c5a3a0-09f4-45c6-8d5f-86426199c9e3
md"""
Here is an example of a \"compound function\" that should really be written as multiple definitions:
"""

# ╔═╡ 6f66bf72-e62b-48f9-852e-26c5ef6de63d
md"""
```julia
using LinearAlgebra

function mynorm(A)
    if isa(A, Vector)
        return sqrt(real(dot(A,A)))
    elseif isa(A, Matrix)
        return maximum(svdvals(A))
    else
        error(\"mynorm: invalid argument\")
    end
end
```
"""

# ╔═╡ 0dbb7827-56b9-4d87-80c1-7230b69286c8
md"""
This can be written more concisely and efficiently as:
"""

# ╔═╡ 9c5f30b2-fd41-4391-ac01-7edd58392acc
md"""
```julia
norm(x::Vector) = sqrt(real(dot(x, x)))
norm(A::Matrix) = maximum(svdvals(A))
```
"""

# ╔═╡ d5e96eb4-a75b-41e4-a45e-9afae606c361
md"""
It should however be noted that the compiler is quite efficient at optimizing away the dead branches in code written as the `mynorm` example.
"""

# ╔═╡ d2551702-7ab8-47c7-a251-0ea3aa131d23
md"""
## Write \"type-stable\" functions
"""

# ╔═╡ 89c006e7-a639-4981-a637-770f0b15a355
md"""
When possible, it helps to ensure that a function always returns a value of the same type. Consider the following definition:
"""

# ╔═╡ d61c72d4-3bcb-4eb9-8ac9-8c7b59307cdb
md"""
```julia
pos(x) = x < 0 ? 0 : x
```
"""

# ╔═╡ 78cf8a61-adf6-4b6e-94af-9cda1e693b63
md"""
Although this seems innocent enough, the problem is that `0` is an integer (of type `Int`) and `x` might be of any type. Thus, depending on the value of `x`, this function might return a value of either of two types. This behavior is allowed, and may be desirable in some cases. But it can easily be fixed as follows:
"""

# ╔═╡ 8b18ba8d-2b5b-4dd2-8fdc-15e8e0507b98
md"""
```julia
pos(x) = x < 0 ? zero(x) : x
```
"""

# ╔═╡ bfa679ff-de08-45e3-939c-3f9ace435496
md"""
There is also a [`oneunit`](@ref) function, and a more general [`oftype(x, y)`](@ref) function, which returns `y` converted to the type of `x`.
"""

# ╔═╡ 6626c328-dd10-45c6-a4fe-448f3a8b544f
md"""
## Avoid changing the type of a variable
"""

# ╔═╡ 2e898a38-a727-4f96-a9c6-724b1e1976e3
md"""
An analogous \"type-stability\" problem exists for variables used repeatedly within a function:
"""

# ╔═╡ fa70f08a-0701-4d10-9404-94477f15004c
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

# ╔═╡ ed43b6a5-cbbe-49e5-a92a-2908ded3fcdc
md"""
Local variable `x` starts as an integer, and after one loop iteration becomes a floating-point number (the result of [`/`](@ref) operator). This makes it more difficult for the compiler to optimize the body of the loop. There are several possible fixes:
"""

# ╔═╡ 8b7842cf-43da-4cec-8b58-875e0808da5d
md"""
  * Initialize `x` with `x = 1.0`
  * Declare the type of `x` explicitly as `x::Float64 = 1`
  * Use an explicit conversion by `x = oneunit(Float64)`
  * Initialize with the first loop iteration, to `x = 1 / rand()`, then loop `for i = 2:10`
"""

# ╔═╡ fa3fc559-bfd6-482c-895e-7eb5d94b52c5
md"""
## [Separate kernel functions (aka, function barriers)](@id kernel-functions)
"""

# ╔═╡ 5b650f8b-e1f1-40e9-bea2-57d2c22dcfe6
md"""
Many functions follow a pattern of performing some set-up work, and then running many iterations to perform a core computation. Where possible, it is a good idea to put these core computations in separate functions. For example, the following contrived function returns an array of a randomly-chosen type:
"""

# ╔═╡ a0c38a7d-7e00-42f3-946c-8f14ac4b833f
function strange_twos(n)
     a = Vector{rand(Bool) ? Int64 : Float64}(undef, n)
     for i = 1:n
         a[i] = 2
     end
     return a
 end;

# ╔═╡ f55e761f-f211-4678-b785-2ff24e6f6e0c
strange_twos(3)

# ╔═╡ 07bab014-705b-48e0-9103-f2e8ffbeca49
md"""
This should be written as:
"""

# ╔═╡ 47caf682-a17d-4580-957a-1c70e7ebbdcd
function fill_twos!(a)
     for i = eachindex(a)
         a[i] = 2
     end
 end;

# ╔═╡ b216da58-3a1e-447e-a28a-c4a05d6c7071
function strange_twos(n)
     a = Vector{rand(Bool) ? Int64 : Float64}(undef, n)
     fill_twos!(a)
     return a
 end;

# ╔═╡ bfdc30ea-1012-421b-ac4f-c1ef3c549602
strange_twos(3)

# ╔═╡ 68d80aff-b957-44e5-90a4-94913745af91
md"""
Julia's compiler specializes code for argument types at function boundaries, so in the original implementation it does not know the type of `a` during the loop (since it is chosen randomly). Therefore the second version is generally faster since the inner loop can be recompiled as part of `fill_twos!` for different types of `a`.
"""

# ╔═╡ 2f1f1fd0-df45-4dfc-abef-8134e5aab0de
md"""
The second form is also often better style and can lead to more code reuse.
"""

# ╔═╡ f66e3abb-8cae-4546-8a54-3b8884685563
md"""
This pattern is used in several places in Julia Base. For example, see `vcat` and `hcat` in [`abstractarray.jl`](https://github.com/JuliaLang/julia/blob/40fe264f4ffaa29b749bcf42239a89abdcbba846/base/abstractarray.jl#L1205-L1206), or the [`fill!`](@ref) function, which we could have used instead of writing our own `fill_twos!`.
"""

# ╔═╡ 31f0a957-2c03-4e01-ba2f-13ad6a02ed61
md"""
Functions like `strange_twos` occur when dealing with data of uncertain type, for example data loaded from an input file that might contain either integers, floats, strings, or something else.
"""

# ╔═╡ 2d815049-df1c-4123-abca-aacaf327ef4d
md"""
## [Types with values-as-parameters](@id man-performance-value-type)
"""

# ╔═╡ 803cf46d-5e83-4270-9c3d-bd2b5d4b2331
md"""
Let's say you want to create an `N`-dimensional array that has size 3 along each axis. Such arrays can be created like this:
"""

# ╔═╡ 52701064-a9c5-453f-aff8-e8408d4ac40f
A = fill(5.0, (3, 3))

# ╔═╡ 97150741-3d26-4272-b7d2-7254346a24d3
md"""
This approach works very well: the compiler can figure out that `A` is an `Array{Float64,2}` because it knows the type of the fill value (`5.0::Float64`) and the dimensionality (`(3, 3)::NTuple{2,Int}`). This implies that the compiler can generate very efficient code for any future usage of `A` in the same function.
"""

# ╔═╡ d7071ee9-566a-48ef-8557-9ef082c28f82
md"""
But now let's say you want to write a function that creates a 3×3×... array in arbitrary dimensions; you might be tempted to write a function
"""

# ╔═╡ 5869ce26-dc16-475e-96e5-f8e4ab478811
function array3(fillval, N)
     fill(fillval, ntuple(d->3, N))
 end

# ╔═╡ db00e32f-7f85-4348-a8ce-0814ba12ce80
array3(5.0, 2)

# ╔═╡ 466e46cf-95d7-4c65-9881-cec5d3a6b0ed
md"""
This works, but (as you can verify for yourself using `@code_warntype array3(5.0, 2)`) the problem is that the output type cannot be inferred: the argument `N` is a *value* of type `Int`, and type-inference does not (and cannot) predict its value in advance. This means that code using the output of this function has to be conservative, checking the type on each access of `A`; such code will be very slow.
"""

# ╔═╡ 2986d55a-711e-4534-b251-f9fbdcf10325
md"""
Now, one very good way to solve such problems is by using the [function-barrier technique](@ref kernel-functions). However, in some cases you might want to eliminate the type-instability altogether. In such cases, one approach is to pass the dimensionality as a parameter, for example through `Val{T}()` (see [\"Value types\"](@ref)):
"""

# ╔═╡ 4f8e025a-080c-4c4e-85f5-7740beedb20f
function array3(fillval, ::Val{N}) where N
     fill(fillval, ntuple(d->3, Val(N)))
 end

# ╔═╡ 32176b33-24eb-4ad7-89b3-936b5d569717
array3(5.0, Val(2))

# ╔═╡ ce8a6e71-d050-4649-920e-f851f9e9f473
md"""
Julia has a specialized version of `ntuple` that accepts a `Val{::Int}` instance as the second parameter; by passing `N` as a type-parameter, you make its \"value\" known to the compiler. Consequently, this version of `array3` allows the compiler to predict the return type.
"""

# ╔═╡ fa55d3b3-13b8-4678-ab69-479f578ae504
md"""
However, making use of such techniques can be surprisingly subtle. For example, it would be of no help if you called `array3` from a function like this:
"""

# ╔═╡ 2dc56c74-1e44-4411-96ab-7268abfb72d9
md"""
```julia
function call_array3(fillval, n)
    A = array3(fillval, Val(n))
end
```
"""

# ╔═╡ 9e65d195-3137-4425-a6cb-ec1809fa4209
md"""
Here, you've created the same problem all over again: the compiler can't guess what `n` is, so it doesn't know the *type* of `Val(n)`. Attempting to use `Val`, but doing so incorrectly, can easily make performance *worse* in many situations. (Only in situations where you're effectively combining `Val` with the function-barrier trick, to make the kernel function more efficient, should code like the above be used.)
"""

# ╔═╡ 1c32b277-f16d-4e13-a096-044157b5ab48
md"""
An example of correct usage of `Val` would be:
"""

# ╔═╡ 1feb191b-2024-47e9-8a46-cf4df58aee6c
md"""
```julia
function filter3(A::AbstractArray{T,N}) where {T,N}
    kernel = array3(1, Val(N))
    filter(A, kernel)
end
```
"""

# ╔═╡ c97bd46e-03e8-4129-894e-ef5d2700ad7b
md"""
In this example, `N` is passed as a parameter, so its \"value\" is known to the compiler. Essentially, `Val(T)` works only when `T` is either hard-coded/literal (`Val(3)`) or already specified in the type-domain.
"""

# ╔═╡ 27d40918-54f1-43c4-b832-4de6b691009b
md"""
## The dangers of abusing multiple dispatch (aka, more on types with values-as-parameters)
"""

# ╔═╡ ccf75d26-3970-4ddd-84d4-730362e1f0e8
md"""
Once one learns to appreciate multiple dispatch, there's an understandable tendency to go overboard and try to use it for everything. For example, you might imagine using it to store information, e.g.
"""

# ╔═╡ 5adb0235-7e59-42fa-b4aa-adb7cae2302c
md"""
```
struct Car{Make, Model}
    year::Int
    ...more fields...
end
```
"""

# ╔═╡ f6bd75d4-8f76-4d45-9416-f9cb93f80456
md"""
and then dispatch on objects like `Car{:Honda,:Accord}(year, args...)`.
"""

# ╔═╡ 41622256-2e17-429d-b095-aaa82a39bafd
md"""
This might be worthwhile when either of the following are true:
"""

# ╔═╡ fcd1d3c1-84d1-4c5c-80ad-b12fd13ec7b6
md"""
  * You require CPU-intensive processing on each `Car`, and it becomes vastly more efficient if you know the `Make` and `Model` at compile time and the total number of different `Make` or `Model` that will be used is not too large.
  * You have homogenous lists of the same type of `Car` to process, so that you can store them all in an `Array{Car{:Honda,:Accord},N}`.
"""

# ╔═╡ 95222ad0-5d1c-4f25-b87b-b102aadf18ae
md"""
When the latter holds, a function processing such a homogenous array can be productively specialized: Julia knows the type of each element in advance (all objects in the container have the same concrete type), so Julia can \"look up\" the correct method calls when the function is being compiled (obviating the need to check at run-time) and thereby emit efficient code for processing the whole list.
"""

# ╔═╡ 4f1c6d2a-c8b6-4155-97d3-586dd64ac47d
md"""
When these do not hold, then it's likely that you'll get no benefit; worse, the resulting \"combinatorial explosion of types\" will be counterproductive. If `items[i+1]` has a different type than `item[i]`, Julia has to look up the type at run-time, search for the appropriate method in method tables, decide (via type intersection) which one matches, determine whether it has been JIT-compiled yet (and do so if not), and then make the call. In essence, you're asking the full type- system and JIT-compilation machinery to basically execute the equivalent of a switch statement or dictionary lookup in your own code.
"""

# ╔═╡ 9c5641fc-6a51-4e35-84b0-332ebeed47c9
md"""
Some run-time benchmarks comparing (1) type dispatch, (2) dictionary lookup, and (3) a \"switch\" statement can be found [on the mailing list](https://groups.google.com/forum/#!msg/julia-users/jUMu9A3QKQQ/qjgVWr7vAwAJ).
"""

# ╔═╡ 35abdbb4-731e-4d64-8a62-983e3c516eb7
md"""
Perhaps even worse than the run-time impact is the compile-time impact: Julia will compile specialized functions for each different `Car{Make, Model}`; if you have hundreds or thousands of such types, then every function that accepts such an object as a parameter (from a custom `get_year` function you might write yourself, to the generic `push!` function in Julia Base) will have hundreds or thousands of variants compiled for it. Each of these increases the size of the cache of compiled code, the length of internal lists of methods, etc. Excess enthusiasm for values-as-parameters can easily waste enormous resources.
"""

# ╔═╡ 1df82830-f85b-403b-ab49-305e10ca28ae
md"""
## [Access arrays in memory order, along columns](@id man-performance-column-major)
"""

# ╔═╡ 59889b5a-343d-4c59-9d95-082e57793e50
md"""
Multidimensional arrays in Julia are stored in column-major order. This means that arrays are stacked one column at a time. This can be verified using the `vec` function or the syntax `[:]` as shown below (notice that the array is ordered `[1 3 2 4]`, not `[1 2 3 4]`):
"""

# ╔═╡ a341eadc-df6c-4d78-8b11-c2a23d9b3dac
x = [1 2; 3 4]

# ╔═╡ 4d3400e9-c607-46f5-9ae6-3aea11bc23a0
x[:]

# ╔═╡ 98adb522-e82e-48dd-8697-b0f65bd8824b
md"""
This convention for ordering arrays is common in many languages like Fortran, Matlab, and R (to name a few). The alternative to column-major ordering is row-major ordering, which is the convention adopted by C and Python (`numpy`) among other languages. Remembering the ordering of arrays can have significant performance effects when looping over arrays. A rule of thumb to keep in mind is that with column-major arrays, the first index changes most rapidly. Essentially this means that looping will be faster if the inner-most loop index is the first to appear in a slice expression. Keep in mind that indexing an array with `:` is an implicit loop that iteratively accesses all elements within a particular dimension; it can be faster to extract columns than rows, for example.
"""

# ╔═╡ 33ba962c-1627-45c6-829d-10b747365984
md"""
Consider the following contrived example. Imagine we wanted to write a function that accepts a [`Vector`](@ref) and returns a square [`Matrix`](@ref) with either the rows or the columns filled with copies of the input vector. Assume that it is not important whether rows or columns are filled with these copies (perhaps the rest of the code can be easily adapted accordingly). We could conceivably do this in at least four ways (in addition to the recommended call to the built-in [`repeat`](@ref)):
"""

# ╔═╡ 3d452c15-6a14-400b-8791-a1ec8d6756fc
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

# ╔═╡ cd21fe75-5d7a-4978-ba02-588a23e4f063
md"""
Now we will time each of these functions using the same random `10000` by `1` input vector:
"""

# ╔═╡ 58b3e793-46c0-4948-af90-63e99bf0f9be
x = randn(10000);

# ╔═╡ 4da30ab5-4d69-4f40-9d08-05adfda1a4d7
fmt(f) = println(rpad(string(f)*": ", 14, ' '), @elapsed f(x))

# ╔═╡ be3244c3-13a1-429e-a4d9-c4d3b240ec52
map(fmt, [copy_cols, copy_rows, copy_col_row, copy_row_col]);

# ╔═╡ 1e60341a-ee8c-45fb-9e96-4e17c5ecb48f
md"""
Notice that `copy_cols` is much faster than `copy_rows`. This is expected because `copy_cols` respects the column-based memory layout of the `Matrix` and fills it one column at a time. Additionally, `copy_col_row` is much faster than `copy_row_col` because it follows our rule of thumb that the first element to appear in a slice expression should be coupled with the inner-most loop.
"""

# ╔═╡ e334731d-17e0-47f7-8fff-2ad4b979ccf3
md"""
## Pre-allocating outputs
"""

# ╔═╡ 94856792-bb77-4923-adf7-562344ed674d
md"""
If your function returns an `Array` or some other complex type, it may have to allocate memory. Unfortunately, oftentimes allocation and its converse, garbage collection, are substantial bottlenecks.
"""

# ╔═╡ b422bb6d-6225-4d73-8279-b4b0dca38b92
md"""
Sometimes you can circumvent the need to allocate memory on each function call by preallocating the output. As a trivial example, compare
"""

# ╔═╡ 8eee0179-cc70-475a-a639-7de74be11560
function xinc(x)
     return [x, x+1, x+2]
 end;

# ╔═╡ 0ba781b9-61f4-4e12-991b-6d1989e585f9
function loopinc()
     y = 0
     for i = 1:10^7
         ret = xinc(i)
         y += ret[2]
     end
     return y
 end;

# ╔═╡ 27b4f53e-e4cb-4ee1-bf77-e5ccb9eaa48e
md"""
with
"""

# ╔═╡ 58372285-bb14-40c2-9f66-1f0269747b30
function xinc!(ret::AbstractVector{T}, x::T) where T
     ret[1] = x
     ret[2] = x+1
     ret[3] = x+2
     nothing
 end;

# ╔═╡ 6c228f88-7f9f-41a9-a14c-682316e1d049
function loopinc_prealloc()
     ret = Vector{Int}(undef, 3)
     y = 0
     for i = 1:10^7
         xinc!(ret, i)
         y += ret[2]
     end
     return y
 end;

# ╔═╡ 4da87070-14c5-4370-8f68-2c12e9e24e70
md"""
Timing results:
"""

# ╔═╡ f5af65c6-0dec-48b1-b043-0cd7eb5c0b72
@time loopinc()

# ╔═╡ 0e7e94ae-c4d9-4671-9c8a-19d5a6e4da6d
@time loopinc_prealloc()

# ╔═╡ ed7df4fb-ac79-47d5-82a9-05ee22249d2f
md"""
Preallocation has other advantages, for example by allowing the caller to control the \"output\" type from an algorithm. In the example above, we could have passed a `SubArray` rather than an [`Array`](@ref), had we so desired.
"""

# ╔═╡ 187b2e8c-2cdf-4ade-839d-4f6eed4d39c4
md"""
Taken to its extreme, pre-allocation can make your code uglier, so performance measurements and some judgment may be required. However, for \"vectorized\" (element-wise) functions, the convenient syntax `x .= f.(y)` can be used for in-place operations with fused loops and no temporary arrays (see the [dot syntax for vectorizing functions](@ref man-vectorized)).
"""

# ╔═╡ 5452ec28-87e4-4d9b-af79-07e542cd85f5
md"""
## More dots: Fuse vectorized operations
"""

# ╔═╡ 77fe0646-59d4-4766-bde9-aef5c7fa1758
md"""
Julia has a special [dot syntax](@ref man-vectorized) that converts any scalar function into a \"vectorized\" function call, and any operator into a \"vectorized\" operator, with the special property that nested \"dot calls\" are *fusing*: they are combined at the syntax level into a single loop, without allocating temporary arrays. If you use `.=` and similar assignment operators, the result can also be stored in-place in a pre-allocated array (see above).
"""

# ╔═╡ 8064e4ce-d736-4cb3-a8af-fbc1e2f36e0b
md"""
In a linear-algebra context, this means that even though operations like `vector + vector` and `vector * scalar` are defined, it can be advantageous to instead use `vector .+ vector` and `vector .* scalar` because the resulting loops can be fused with surrounding computations. For example, consider the two functions:
"""

# ╔═╡ 1bc9d55a-1969-453f-b800-7803bb4b7853
f(x) = 3x.^2 + 4x + 7x.^3;

# ╔═╡ ed74ca1f-13f3-44b8-8e55-47059c154167
fdot(x) = @. 3x^2 + 4x + 7x^3 # equivalent to 3 .* x.^2 .+ 4 .* x .+ 7 .* x.^3;

# ╔═╡ e1dcc4e9-3383-4310-a623-e83bfa90957e
md"""
Both `f` and `fdot` compute the same thing. However, `fdot` (defined with the help of the [`@.`](@ref @__dot__) macro) is significantly faster when applied to an array:
"""

# ╔═╡ d78e9c87-ab48-4afd-a1c0-5e4e0b7fc1f2
x = rand(10^6);

# ╔═╡ 0413a76c-4e24-4df1-9c5f-a15b2c5c4021
@time f(x);

# ╔═╡ c0f40914-80e8-4b48-98c0-c6eff6a14f56
@time fdot(x);

# ╔═╡ 682083d2-34ae-4a30-bc75-c285a45cc484
@time f.(x);

# ╔═╡ 6afd00e8-f5fc-4366-8e9a-d002d61a7326
md"""
That is, `fdot(x)` is ten times faster and allocates 1/6 the memory of `f(x)`, because each `*` and `+` operation in `f(x)` allocates a new temporary array and executes in a separate loop. (Of course, if you just do `f.(x)` then it is as fast as `fdot(x)` in this example, but in many contexts it is more convenient to just sprinkle some dots in your expressions rather than defining a separate function for each vectorized operation.)
"""

# ╔═╡ a231d3e9-5346-43b8-a7c8-715eb1f989f6
md"""
## [Consider using views for slices](@id man-performance-views)
"""

# ╔═╡ ea83cd5d-841f-4756-bc61-afa5033575f3
md"""
In Julia, an array \"slice\" expression like `array[1:5, :]` creates a copy of that data (except on the left-hand side of an assignment, where `array[1:5, :] = ...` assigns in-place to that portion of `array`). If you are doing many operations on the slice, this can be good for performance because it is more efficient to work with a smaller contiguous copy than it would be to index into the original array. On the other hand, if you are just doing a few simple operations on the slice, the cost of the allocation and copy operations can be substantial.
"""

# ╔═╡ 38914bc0-bf10-4d89-aee7-0579e50b3a7c
md"""
An alternative is to create a \"view\" of the array, which is an array object (a `SubArray`) that actually references the data of the original array in-place, without making a copy. (If you write to a view, it modifies the original array's data as well.) This can be done for individual slices by calling [`view`](@ref), or more simply for a whole expression or block of code by putting [`@views`](@ref) in front of that expression. For example:
"""

# ╔═╡ 2b7d5bfe-921e-461f-a29a-cf00cdba75a3
fcopy(x) = sum(x[2:end-1]);

# ╔═╡ 233c3fc8-3dcb-4fb8-8d10-80e085ea5491
@views fview(x) = sum(x[2:end-1]);

# ╔═╡ 53612e33-4a4b-4e15-97d8-4c8d8d656f0d
x = rand(10^6);

# ╔═╡ ef9d5997-76c4-45db-9c54-981ed5647bf2
@time fcopy(x);

# ╔═╡ 4e75bba8-6591-4c86-ab9e-d189e2e4c9de
@time fview(x);

# ╔═╡ 8b53c174-5bf9-44e8-bc11-82a463f7995c
md"""
Notice both the 3× speedup and the decreased memory allocation of the `fview` version of the function.
"""

# ╔═╡ 64f158db-b18a-4589-a88c-3100eff2a926
md"""
## Copying data is not always bad
"""

# ╔═╡ 0ae53f9f-c03d-44c9-a7ac-38316c1bbe21
md"""
Arrays are stored contiguously in memory, lending themselves to CPU vectorization and fewer memory accesses due to caching. These are the same reasons that it is recommended to access arrays in column-major order (see above). Irregular access patterns and non-contiguous views can drastically slow down computations on arrays because of non-sequential memory access.
"""

# ╔═╡ b072cad6-08de-408c-aef4-ad9aaac16447
md"""
Copying irregularly-accessed data into a contiguous array before operating on it can result in a large speedup, such as in the example below. Here, a matrix and a vector are being accessed at 800,000 of their randomly-shuffled indices before being multiplied. Copying the views into plain arrays speeds up the multiplication even with the cost of the copying operation.
"""

# ╔═╡ 5a71cdf6-44aa-4fa1-af52-54a117b45bf7
using Random

# ╔═╡ 10280d62-d068-4054-b73d-378482fa316b
x = randn(1_000_000);

# ╔═╡ 35923728-f98e-4433-b5fc-ca1e2266859f
inds = shuffle(1:1_000_000)[1:800000];

# ╔═╡ 554f71ad-4031-45e7-adaa-f0ffb7a4f36a
A = randn(50, 1_000_000);

# ╔═╡ 11869f42-8c1f-43d0-8487-4c544cc06fd9
xtmp = zeros(800_000);

# ╔═╡ da67ba54-5d32-4546-b52b-809c3494008a
Atmp = zeros(50, 800_000);

# ╔═╡ 43873124-f5f6-4c88-98dd-6344effde208
@time sum(view(A, :, inds) * view(x, inds))

# ╔═╡ 5ffb615a-914c-4d0d-ae0b-7268f6f18cea
@time begin
     copyto!(xtmp, view(x, inds))
     copyto!(Atmp, view(A, :, inds))
     sum(Atmp * xtmp)
 end

# ╔═╡ 77f19432-da58-4de5-a642-a87fe20fb6e8
md"""
Provided there is enough memory for the copies, the cost of copying the view to an array is far outweighed by the speed boost from doing the matrix multiplication on a contiguous array.
"""

# ╔═╡ e2f3a4f5-1d32-43ee-a852-3eafc206942c
md"""
## Consider StaticArrays.jl for small fixed-size vector/matrix operations
"""

# ╔═╡ ceb5b836-0a61-4130-8c99-6b6008858519
md"""
If your application involves many small (`< 100` element) arrays of fixed sizes (i.e. the size is known prior to execution), then you might want to consider using the [StaticArrays.jl package](https://github.com/JuliaArrays/StaticArrays.jl). This package allows you to represent such arrays in a way that avoids unnecessary heap allocations and allows the compiler to specialize code for the *size* of the array, e.g. by completely unrolling vector operations (eliminating the loops) and storing elements in CPU registers.
"""

# ╔═╡ 6bdde19f-ca6f-4520-8299-9e43ee02606f
md"""
For example, if you are doing computations with 2d geometries, you might have many computations with 2-component vectors.  By using the `SVector` type from StaticArrays.jl, you can use convenient vector notation and operations like `norm(3v - w)` on vectors `v` and `w`, while allowing the compiler to unroll the code to a minimal computation equivalent to `@inbounds hypot(3v[1]-w[1], 3v[2]-w[2])`.
"""

# ╔═╡ 96c3b9cc-edc1-4096-91a9-ef3af021e439
md"""
## Avoid string interpolation for I/O
"""

# ╔═╡ 7b7a8347-8556-41ba-902b-071aa216bbc0
md"""
When writing data to a file (or other I/O device), forming extra intermediate strings is a source of overhead. Instead of:
"""

# ╔═╡ 9f2349df-6873-4420-918f-1471d2a42fa1
md"""
```julia
println(file, \"$a $b\")
```
"""

# ╔═╡ 609bb1bb-cd1c-472f-8d65-3327eb1f2112
md"""
use:
"""

# ╔═╡ f85c7e12-9146-41c8-89b6-e0d1745c5675
md"""
```julia
println(file, a, \" \", b)
```
"""

# ╔═╡ 9226d22e-0744-4b5c-a196-342f32fb10b8
md"""
The first version of the code forms a string, then writes it to the file, while the second version writes values directly to the file. Also notice that in some cases string interpolation can be harder to read. Consider:
"""

# ╔═╡ ccc6496a-ee0e-488b-b39b-b9ae70594290
md"""
```julia
println(file, \"$(f(a))$(f(b))\")
```
"""

# ╔═╡ 257518e4-1cb7-4e42-8462-607653ed419f
md"""
versus:
"""

# ╔═╡ 4b5b5bd6-e317-4fbc-9676-81eed839b6bc
md"""
```julia
println(file, f(a), f(b))
```
"""

# ╔═╡ 9fc37471-11ae-4ff9-889e-b2cf45245536
md"""
## Optimize network I/O during parallel execution
"""

# ╔═╡ 113376db-f08b-4526-8eec-8d2ca690bbf2
md"""
When executing a remote function in parallel:
"""

# ╔═╡ 8dd6287c-cf01-4a39-bdf5-557acd7d8965
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

# ╔═╡ d5ad7e5c-05a9-4ba6-9b8d-1e634aa4d38b
md"""
is faster than:
"""

# ╔═╡ 1b52447e-a66e-477b-b0f5-819cb17c5ff9
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

# ╔═╡ c5698308-92a2-49a5-b3a6-a4fc79e60117
md"""
The former results in a single network round-trip to every worker, while the latter results in two network calls - first by the [`@spawnat`](@ref) and the second due to the [`fetch`](@ref) (or even a [`wait`](@ref)). The [`fetch`](@ref)/[`wait`](@ref) is also being executed serially resulting in an overall poorer performance.
"""

# ╔═╡ 8d6a9c51-4a1b-4419-bf38-56ae26995720
md"""
## Fix deprecation warnings
"""

# ╔═╡ b12a1c4c-da21-44e3-9fc7-b4bc3bed9691
md"""
A deprecated function internally performs a lookup in order to print a relevant warning only once. This extra lookup can cause a significant slowdown, so all uses of deprecated functions should be modified as suggested by the warnings.
"""

# ╔═╡ 019c0a28-c473-4ed8-9c69-ad9d58c0e25c
md"""
## Tweaks
"""

# ╔═╡ 9b2ed1f6-e157-4734-84e1-f2ff0f070865
md"""
These are some minor points that might help in tight inner loops.
"""

# ╔═╡ cfec0a66-cb1b-49ac-b2d6-146c850a1480
md"""
  * Avoid unnecessary arrays. For example, instead of [`sum([x,y,z])`](@ref) use `x+y+z`.
  * Use [`abs2(z)`](@ref) instead of [`abs(z)^2`](@ref) for complex `z`. In general, try to rewrite code to use [`abs2`](@ref) instead of [`abs`](@ref) for complex arguments.
  * Use [`div(x,y)`](@ref) for truncating division of integers instead of [`trunc(x/y)`](@ref), [`fld(x,y)`](@ref) instead of [`floor(x/y)`](@ref), and [`cld(x,y)`](@ref) instead of [`ceil(x/y)`](@ref).
"""

# ╔═╡ 1861c0ae-cef7-433c-b161-2ba5c4250079
md"""
## [Performance Annotations](@id man-performance-annotations)
"""

# ╔═╡ 2921c571-f9e1-4953-9dd2-fa1a70fcfa43
md"""
Sometimes you can enable better optimization by promising certain program properties.
"""

# ╔═╡ 25b19b0e-fa7d-4988-889b-ff2f7cd02e21
md"""
  * Use [`@inbounds`](@ref) to eliminate array bounds checking within expressions. Be certain before doing this. If the subscripts are ever out of bounds, you may suffer crashes or silent corruption.
  * Use [`@fastmath`](@ref) to allow floating point optimizations that are correct for real numbers, but lead to differences for IEEE numbers. Be careful when doing this, as this may change numerical results. This corresponds to the `-ffast-math` option of clang.
  * Write [`@simd`](@ref) in front of `for` loops to promise that the iterations are independent and may be reordered.  Note that in many cases, Julia can automatically vectorize code without the `@simd` macro; it is only beneficial in cases where such a transformation would otherwise be illegal, including cases like allowing floating-point re-associativity and ignoring dependent memory accesses (`@simd ivdep`). Again, be very careful when asserting `@simd` as erroneously annotating a loop with dependent iterations may result in unexpected results. In particular, note that `setindex!` on some `AbstractArray` subtypes is inherently dependent upon iteration order. **This feature is experimental** and could change or disappear in future versions of Julia.
"""

# ╔═╡ 331071d1-ebfc-4820-a095-6a9df1c3c0f7
md"""
The common idiom of using 1:n to index into an AbstractArray is not safe if the Array uses unconventional indexing, and may cause a segmentation fault if bounds checking is turned off. Use `LinearIndices(x)` or `eachindex(x)` instead (see also [Arrays with custom indices](@ref man-custom-indices)).
"""

# ╔═╡ 4be4ffc4-dcc8-41ca-9b6c-94071cae1f0c
md"""
!!! note
    While `@simd` needs to be placed directly in front of an innermost `for` loop, both `@inbounds` and `@fastmath` can be applied to either single expressions or all the expressions that appear within nested blocks of code, e.g., using `@inbounds begin` or `@inbounds for ...`.
"""

# ╔═╡ 7cb824fa-0999-4fe6-9bf6-e65d880b88ca
md"""
Here is an example with both `@inbounds` and `@simd` markup (we here use `@noinline` to prevent the optimizer from trying to be too clever and defeat our benchmark):
"""

# ╔═╡ 7ecf9105-12c3-4274-a30b-88c5f53e1cbf
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
    println(\"GFlop/sec        = \", 2n*reps / time*1E-9)
    time = @elapsed for j in 1:reps
        s += innersimd(x, y)
    end
    println(\"GFlop/sec (SIMD) = \", 2n*reps / time*1E-9)
end

timeit(1000, 1000)
```
"""

# ╔═╡ b54ef6e7-0155-49d7-810c-3a0f4709e35f
md"""
On a computer with a 2.4GHz Intel Core i5 processor, this produces:
"""

# ╔═╡ 9a59a8a7-3cd3-42dc-a1fb-13be18c014ff
md"""
```
GFlop/sec        = 1.9467069505224963
GFlop/sec (SIMD) = 17.578554163920018
```
"""

# ╔═╡ c9c5c6fb-80e5-4351-804e-50f637ea4a20
md"""
(`GFlop/sec` measures the performance, and larger numbers are better.)
"""

# ╔═╡ e3286a30-e7c1-40c4-a1a4-cdba8cb3af4e
md"""
Here is an example with all three kinds of markup. This program first calculates the finite difference of a one-dimensional array, and then evaluates the L2-norm of the result:
"""

# ╔═╡ f6020c25-47e5-411d-a643-40c345533fde
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

# ╔═╡ ce03971b-6456-4cfe-8d45-26d80e62a1aa
md"""
On a computer with a 2.7 GHz Intel Core i7 processor, this produces:
"""

# ╔═╡ cba7be0e-df6c-451c-814b-9daf9a962a95
md"""
```
$ julia wave.jl;
  1.207814709 seconds
4.443986180758249

$ julia --math-mode=ieee wave.jl;
  4.487083643 seconds
4.443986180758249
```
"""

# ╔═╡ dc26823d-ce1a-4807-bf74-826999ae57e9
md"""
Here, the option `--math-mode=ieee` disables the `@fastmath` macro, so that we can compare results.
"""

# ╔═╡ 608820a5-0e93-4b4c-ac14-0665fff873ac
md"""
In this case, the speedup due to `@fastmath` is a factor of about 3.7. This is unusually large – in general, the speedup will be smaller. (In this particular example, the working set of the benchmark is small enough to fit into the L1 cache of the processor, so that memory access latency does not play a role, and computing time is dominated by CPU usage. In many real world programs this is not the case.) Also, in this case this optimization does not change the result – in general, the result will be slightly different. In some cases, especially for numerically unstable algorithms, the result can be very different.
"""

# ╔═╡ 6d2ffa12-3d61-44a5-9f37-630743c1d5cb
md"""
The annotation `@fastmath` re-arranges floating point expressions, e.g. changing the order of evaluation, or assuming that certain special cases (inf, nan) cannot occur. In this case (and on this particular computer), the main difference is that the expression `1 / (2*dx)` in the function `deriv` is hoisted out of the loop (i.e. calculated outside the loop), as if one had written `idx = 1 / (2*dx)`. In the loop, the expression `... / (2*dx)` then becomes `... * idx`, which is much faster to evaluate. Of course, both the actual optimization that is applied by the compiler as well as the resulting speedup depend very much on the hardware. You can examine the change in generated code by using Julia's [`code_native`](@ref) function.
"""

# ╔═╡ e71a6db6-53b9-4b15-a8c0-23ccd951daf5
md"""
Note that `@fastmath` also assumes that `NaN`s will not occur during the computation, which can lead to surprising behavior:
"""

# ╔═╡ b651d2bc-7d4d-4753-b866-d06525e49454
f(x) = isnan(x);

# ╔═╡ 59f9b9f0-0285-4215-9888-6a2fd65ce148
f(NaN)

# ╔═╡ d1c400cc-4616-41a4-a8c9-9ea0ec4293d0
f_fast(x) = @fastmath isnan(x);

# ╔═╡ f8957233-b91e-4fbf-a20c-7a50eacf8fa3
f_fast(NaN)

# ╔═╡ 010775c5-6489-4eb7-837f-1bb0de9c2638
md"""
## Treat Subnormal Numbers as Zeros
"""

# ╔═╡ d6b3ca6a-745c-444a-bc2d-fd488f168afd
md"""
Subnormal numbers, formerly called [denormal numbers](https://en.wikipedia.org/wiki/Denormal_number), are useful in many contexts, but incur a performance penalty on some hardware. A call [`set_zero_subnormals(true)`](@ref) grants permission for floating-point operations to treat subnormal inputs or outputs as zeros, which may improve performance on some hardware. A call [`set_zero_subnormals(false)`](@ref) enforces strict IEEE behavior for subnormal numbers.
"""

# ╔═╡ 7c1ab67e-e942-498d-86ef-fc7692e5eecf
md"""
Below is an example where subnormals noticeably impact performance on some hardware:
"""

# ╔═╡ fbfb7872-b25c-407a-9718-872cbcc90030
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

# ╔═╡ c12e7f59-8a0a-4494-bba7-1a2572aedd7a
md"""
This gives an output similar to
"""

# ╔═╡ e52ccb68-7882-4fce-b902-0b212e51c186
md"""
```
  0.002202 seconds (1 allocation: 4.063 KiB)
  0.001502 seconds (1 allocation: 4.063 KiB)
  0.002139 seconds (1 allocation: 4.063 KiB)
  0.001454 seconds (1 allocation: 4.063 KiB)
  0.002115 seconds (1 allocation: 4.063 KiB)
  0.001455 seconds (1 allocation: 4.063 KiB)
```
"""

# ╔═╡ 2321e203-daf6-4230-af94-8e86f4e58a3b
md"""
Note how each even iteration is significantly faster.
"""

# ╔═╡ d25bb035-607e-48fe-a953-ab5339062b5a
md"""
This example generates many subnormal numbers because the values in `a` become an exponentially decreasing curve, which slowly flattens out over time.
"""

# ╔═╡ 0effee55-0a0b-4ce9-8ca2-a5d2b87f82f0
md"""
Treating subnormals as zeros should be used with caution, because doing so breaks some identities, such as `x-y == 0` implies `x == y`:
"""

# ╔═╡ f3f759a7-ac70-4739-bed2-4e122cb80a36
x = 3f-38; y = 2f-38;

# ╔═╡ 4fe07e66-325e-428d-bb9d-01f0d3800ffd
set_zero_subnormals(true); (x - y, x == y)

# ╔═╡ 88400bf5-88db-4af6-93a4-c332d3dbf512
set_zero_subnormals(false); (x - y, x == y)

# ╔═╡ 4017e24c-35c1-4efa-8993-76e4cdf325a0
md"""
In some applications, an alternative to zeroing subnormal numbers is to inject a tiny bit of noise.  For example, instead of initializing `a` with zeros, initialize it with:
"""

# ╔═╡ 19983218-e52d-4d22-aebe-ca310b3c110a
md"""
```julia
a = rand(Float32,1000) * 1.f-9
```
"""

# ╔═╡ 0359c171-f867-4269-92b1-e11ef933f980
md"""
## [[`@code_warntype`](@ref)](@id man-code-warntype)
"""

# ╔═╡ 51545f40-2824-45a2-a256-d0875f7a2d03
md"""
The macro [`@code_warntype`](@ref) (or its function variant [`code_warntype`](@ref)) can sometimes be helpful in diagnosing type-related problems. Here's an example:
"""

# ╔═╡ 8983169b-2583-4cfa-b93e-82130b8f11ef
@noinline pos(x) = x < 0 ? 0 : x;

# ╔═╡ b8ab1309-3367-4fca-adf7-ce8b3c5f2690
function f(x)
     y = pos(x)
     return sin(y*x + 1)
 end;

# ╔═╡ 028e2bd1-4b5c-40b3-bbbc-80bdd3ea9e7e
@code_warntype f(3.2)

# ╔═╡ 5bb52a79-df22-491d-b145-0498ac67cfe0
md"""
Interpreting the output of [`@code_warntype`](@ref), like that of its cousins [`@code_lowered`](@ref), [`@code_typed`](@ref), [`@code_llvm`](@ref), and [`@code_native`](@ref), takes a little practice. Your code is being presented in form that has been heavily digested on its way to generating compiled machine code. Most of the expressions are annotated by a type, indicated by the `::T` (where `T` might be [`Float64`](@ref), for example). The most important characteristic of [`@code_warntype`](@ref) is that non-concrete types are displayed in red; since this document is written in Markdown, which has no color, in this document, red text is denoted by uppercase.
"""

# ╔═╡ f82c8b1f-dc29-4c23-ba3a-6881762752e6
md"""
At the top, the inferred return type of the function is shown as `Body::Float64`. The next lines represent the body of `f` in Julia's SSA IR form. The numbered boxes are labels and represent targets for jumps (via `goto`) in your code. Looking at the body, you can see that the first thing that happens is that `pos` is called and the return value has been inferred as the `Union` type `UNION{FLOAT64, INT64}` shown in uppercase since it is a non-concrete type. This means that we cannot know the exact return type of `pos` based on the input types. However, the result of `y*x`is a `Float64` no matter if `y` is a `Float64` or `Int64` The net result is that `f(x::Float64)` will not be type-unstable in its output, even if some of the intermediate computations are type-unstable.
"""

# ╔═╡ 17816a65-4633-4c60-b379-bd441b29a255
md"""
How you use this information is up to you. Obviously, it would be far and away best to fix `pos` to be type-stable: if you did so, all of the variables in `f` would be concrete, and its performance would be optimal. However, there are circumstances where this kind of *ephemeral* type instability might not matter too much: for example, if `pos` is never used in isolation, the fact that `f`'s output is type-stable (for [`Float64`](@ref) inputs) will shield later code from the propagating effects of type instability. This is particularly relevant in cases where fixing the type instability is difficult or impossible. In such cases, the tips above (e.g., adding type annotations and/or breaking up functions) are your best tools to contain the \"damage\" from type instability. Also, note that even Julia Base has functions that are type unstable. For example, the function [`findfirst`](@ref) returns the index into an array where a key is found, or `nothing` if it is not found, a clear type instability. In order to make it easier to find the type instabilities that are likely to be important, `Union`s containing either `missing` or `nothing` are color highlighted in yellow, instead of red.
"""

# ╔═╡ 41da8487-dd6f-427b-8d81-4028fb4df618
md"""
The following examples may help you interpret expressions marked as containing non-leaf types:
"""

# ╔═╡ bc388a1d-0082-44e4-860a-148965d9927d
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

# ╔═╡ 156e5e37-2d94-42b9-95d2-f6dd36d52cc7
md"""
## [Performance of captured variable](@id man-performance-captured)
"""

# ╔═╡ 99bd933c-0097-46a7-9350-c3a4c09f7dc1
md"""
Consider the following example that defines an inner function:
"""

# ╔═╡ 7c4b1a00-3750-4f38-8508-288db779d076
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

# ╔═╡ f79b8a77-beab-43cc-b6ae-1003f5d6b50d
md"""
Function `abmult` returns a function `f` that multiplies its argument by the absolute value of `r`. The inner function assigned to `f` is called a \"closure\". Inner functions are also used by the language for `do`-blocks and for generator expressions.
"""

# ╔═╡ 47c8269c-fe56-4a01-95b7-21310ecccc86
md"""
This style of code presents performance challenges for the language. The parser, when translating it into lower-level instructions, substantially reorganizes the above code by extracting the inner function to a separate code block.  \"Captured\" variables such as `r` that are shared by inner functions and their enclosing scope are also extracted into a heap-allocated \"box\" accessible to both inner and outer functions because the language specifies that `r` in the inner scope must be identical to `r` in the outer scope even after the outer scope (or another inner function) modifies `r`.
"""

# ╔═╡ faf938b5-ddf3-442f-935c-3a5aa1c6fe53
md"""
The discussion in the preceding paragraph referred to the \"parser\", that is, the phase of compilation that takes place when the module containing `abmult` is first loaded, as opposed to the later phase when it is first invoked. The parser does not \"know\" that `Int` is a fixed type, or that the statement `r = -r` transforms an `Int` to another `Int`. The magic of type inference takes place in the later phase of compilation.
"""

# ╔═╡ a24c0c4c-7ceb-462a-8f5c-a209590ca904
md"""
Thus, the parser does not know that `r` has a fixed type (`Int`). nor that `r` does not change value once the inner function is created (so that the box is unneeded).  Therefore, the parser emits code for box that holds an object with an abstract type such as `Any`, which requires run-time type dispatch for each occurrence of `r`.  This can be verified by applying `@code_warntype` to the above function.  Both the boxing and the run-time type dispatch can cause loss of performance.
"""

# ╔═╡ 64ddcf33-b8cd-4d32-9b3f-1bc0f2b71b1a
md"""
If captured variables are used in a performance-critical section of the code, then the following tips help ensure that their use is performant. First, if it is known that a captured variable does not change its type, then this can be declared explicitly with a type annotation (on the variable, not the right-hand side):
"""

# ╔═╡ 8bf3238c-b5c0-470e-a62b-c27ac858a6e3
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

# ╔═╡ e44b048d-740a-4835-92d5-dbc69d16d9cd
md"""
The type annotation partially recovers lost performance due to capturing because the parser can associate a concrete type to the object in the box. Going further, if the captured variable does not need to be boxed at all (because it will not be reassigned after the closure is created), this can be indicated with `let` blocks as follows.
"""

# ╔═╡ e8f31a09-fbd8-4fdc-849e-88f9164dd70a
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

# ╔═╡ 0c2a8ccb-3c88-4af8-8b0f-296ffdc5660a
md"""
The `let` block creates a new variable `r` whose scope is only the inner function. The second technique recovers full language performance in the presence of captured variables. Note that this is a rapidly evolving aspect of the compiler, and it is likely that future releases will not require this degree of programmer annotation to attain performance. In the mean time, some user-contributed packages like [FastClosures](https://github.com/c42f/FastClosures.jl) automate the insertion of `let` statements as in `abmult3`.
"""

# ╔═╡ defa2bb7-e6d3-45f7-af38-8558102d7290
md"""
## Checking for equality with a singleton
"""

# ╔═╡ 66311a4f-bb8d-4f2b-b52d-88a8c3e8d3cb
md"""
When checking if a value is equal to some singleton it can be better for performance to check for identicality (`===`) instead of equality (`==`). The same advice applies to using `!==` over `!=`. These type of checks frequently occur e.g. when implementing the iteration protocol and checking if `nothing` is returned from [`iterate`](@ref).
"""

# ╔═╡ Cell order:
# ╟─74a0322d-6a11-49bf-a137-1df0adaa1965
# ╟─dcd19b1c-9ebf-4a6b-a0c4-a1b3933aeadb
# ╟─62937f65-6404-410e-9d7a-039aceccafcf
# ╟─886e9b53-41e1-488c-8474-d2e1907f6897
# ╟─8b8db9e7-42f0-4231-9534-b0d65c22b05d
# ╟─7115e055-33dd-4e04-a3ca-b9ec1f6337ea
# ╟─b4fc996c-49b0-4404-96b3-1042cb8d3f0f
# ╟─1b606e97-c4ed-4110-9852-d9086323061a
# ╟─1100c6c0-39c7-458b-9511-6c5c0433ea20
# ╟─d7bffdae-f7a2-4103-b890-0b5b9a01ba3d
# ╟─b21f14aa-4112-4cec-89ba-d1e7c4c0fffe
# ╟─45aa58ab-aad8-4835-a1dd-21ba6d81adf2
# ╠═35f61526-22c9-40b8-befc-42902c247ba5
# ╟─6b6a6c09-e5fc-4a0b-9335-32409200ec45
# ╠═9f1b67be-7a3a-41f4-9f89-2dbb125b8d3c
# ╟─444c8931-76fb-4ce0-b764-b35e35b63b13
# ╟─9332aad8-aec5-4ca2-9afb-20d74e8117ba
# ╟─7297b697-a426-4886-ac15-e65077c02f5d
# ╠═56cdb4de-d871-4ca3-bfef-d91c73676f13
# ╠═a773b461-a5cd-4805-9328-ecb092f3782a
# ╠═0e243d8a-6c22-41e9-bc38-0c02d643dfa8
# ╠═c3985e75-f2d8-401d-8189-c853b60fe1c0
# ╟─8a2728e6-dc2e-4b4d-ac56-52df3c1d542b
# ╟─af0c41ef-18bc-4d65-b332-2626bb1fef72
# ╟─b8aba5bb-bed7-4f14-8053-f765f4486331
# ╠═01f8f809-cf4e-4985-b04f-99af98aab8c2
# ╠═a2c8cee9-b534-47ad-b262-91d65af2a653
# ╠═c639c06b-20f5-422e-99f1-7358d2df6990
# ╠═5c2bd3f3-70c1-4f48-b9a8-3c3988be4319
# ╟─352072c4-514e-4007-818a-9d8c81b4c781
# ╠═dd69a1fc-aa68-4eec-b1b5-152ad54dd9fe
# ╠═27a4778e-82d3-4551-a902-976b0775db67
# ╟─2743608a-235d-408f-a886-a495fc31d8b2
# ╟─bf43c133-a969-472c-8e9c-460d826e3f83
# ╟─d0d02497-514d-4fac-b7b7-1cc0c71710f3
# ╟─89a144ec-baa6-4036-acef-4f8e4544d773
# ╟─e6ae554b-28d1-4f8e-84e0-9ca66a4967e2
# ╟─5d34ce4b-1e8c-42ea-9e13-eefa0524ad24
# ╟─d58d8317-cf93-4921-92a7-93a3ad07cdcb
# ╟─6ea38242-5ee3-48c3-9483-772cb02c7486
# ╠═99042a13-79b3-4fd9-a5da-0872dd55f539
# ╠═82268b23-ab8b-4fa6-8be7-5c2b22bfa3dc
# ╟─71a6ff64-1b34-449a-a970-9290e828bd24
# ╠═16ce0cb6-cada-44ac-9c7b-d8c3a5972893
# ╠═21e39956-57f2-4b6e-8a26-dd115566629c
# ╟─f8b34280-a4cb-4028-86ca-618cba1702db
# ╟─6901c405-ecb7-40ef-8062-bb99aadd602a
# ╟─f7e9e00a-9e5e-4f6a-9279-210c92a9deca
# ╟─74524077-ce3b-4bbe-8005-1385f1ece137
# ╟─4ef2a123-940d-4299-83ce-4a4222b1749d
# ╟─9f88466f-3da7-4ebb-9343-0da792cd820c
# ╟─600a8a06-8cde-4b43-965d-7cff5e26ff23
# ╠═5cb47aed-0d74-4747-8732-ed1ecb0edfab
# ╟─8d327e0a-239f-420f-94a2-f8852378fff8
# ╠═58ff13d9-dc55-4e9e-b628-f8f82f3eac21
# ╠═27f563a6-8045-4dd4-b41d-08be31054449
# ╠═c49feaef-be58-4df2-a78a-7af62c6e1895
# ╠═4e76ac16-a554-41dd-a087-3f6911518fb4
# ╟─9f4850f9-7334-4b83-9b1c-667a8e9a6817
# ╟─56ad807a-c388-4ac3-8de0-8f68a01a334c
# ╠═acec5b85-9828-44e7-99d9-4b6d4a703f04
# ╟─f42f3b48-0468-4287-94b5-340eb5900738
# ╠═9241f943-1909-40af-9e70-5396c5543a14
# ╟─c7df9264-ecc4-4e2d-bd23-3b198e66127b
# ╠═4e2d1342-c0a0-48d8-a58c-76a5b9aaab78
# ╠═26a8d6d3-86be-42a3-8a1c-32973678bfe1
# ╠═0b6cff6c-e39c-49cc-839d-61f6dbc84c0d
# ╠═797d6b0e-5234-4128-b484-89f51c44f959
# ╟─83d0ec33-3c70-4a5c-ae7b-6e73c8145f84
# ╠═3bfe86ae-3380-4b60-a83d-42ff38ec0213
# ╠═dcbc2be4-9fb5-46b3-924d-70e3e94225f5
# ╠═824ab3c5-586f-41fb-ac79-460424b9c9b7
# ╟─dc9b7d47-818c-4b6d-99b7-346e42c7a3a3
# ╠═b9ff1d16-8c53-4645-bc04-29bbfa64ed32
# ╠═a28c0a1e-a9a5-4590-9e2b-5840561413fc
# ╟─2e8265e7-d5f9-4f76-9018-cc27f9b66fa0
# ╟─d5f3e142-d44a-43a6-a25a-149e27af012a
# ╠═d4248879-5486-4cd3-9ca9-493d07ce2daf
# ╠═1ec53372-c657-493b-8ee7-3152be2274f9
# ╠═4a04f0fa-edd8-4bdf-b59a-20cdebd22251
# ╠═97427e74-8435-4af2-ae89-e4ee6067c0ec
# ╟─0329c262-bf8f-4843-8652-ab084cfae3df
# ╟─a4384062-28eb-45de-a7eb-555dd7146f89
# ╟─4409ea61-5b35-49d5-8f7a-24e84186dd79
# ╟─2626ec4e-faa0-4e37-9748-b21d711b968f
# ╟─0713157f-a50d-4013-b096-212922776911
# ╟─cfca57b7-070d-45b8-8b92-c95e3b06d35d
# ╟─6915a37d-15ab-4f12-b5c0-4274ddba6d0a
# ╟─f63a7881-d7e4-4193-9a3e-c0876f89d7a2
# ╠═3a1a12d7-094a-4a65-b4c1-19afc395a0b0
# ╠═d10e45f6-5705-41d4-96bf-7f8c8008765e
# ╟─d25d9b19-4d4e-4a58-9652-c0c525219a88
# ╠═bc245bbd-dcfd-4837-8c77-3afd102ed775
# ╠═440a773f-28bd-4c08-a95e-0577f8e176be
# ╠═ef7ba24b-577a-4b5d-ab5c-f095c5d166cd
# ╠═c88866bc-08be-4435-91e3-854766d67df5
# ╠═11b3a959-eb53-495b-b221-5d01b14e8471
# ╠═5894b572-d420-48dd-a6f1-278c5b1a196a
# ╠═3ca21ad1-6736-435c-a8a8-0c4e87c998ee
# ╠═646dfe68-df88-4be1-8c9c-08f3ce28e1b4
# ╟─d8fc5af7-22e8-4a4a-8052-f3cca3cdf6cc
# ╟─656ddd27-c0b2-49fb-a099-c0e863e4d0d2
# ╠═2aa155cd-729f-49ad-b25c-e1be2266750f
# ╠═ab87e407-7c0b-4521-84ba-72de1e64635e
# ╠═1d678381-1416-486a-8fe7-a42a29bc704f
# ╟─575c0a35-4a94-41b1-a6de-248c5053958f
# ╟─3268eefd-8fda-4e5d-8799-2f2e8fc5e72d
# ╠═c8c6612a-c6c3-47da-86a5-fe94e3bdebd7
# ╠═fae8d7cf-7460-4745-a848-80dd8b16e4ad
# ╠═1e46c398-48c3-4cca-bf27-84e711ad6ddd
# ╠═dc74a6d4-64d4-49ab-8c17-de3c6a181086
# ╠═f815f8a5-8323-408f-a1a4-be52258b5f26
# ╠═cea50d4c-7ae9-4cf1-b839-761719fce65d
# ╟─ca6978aa-fa87-47f8-b57a-6b631ed92a54
# ╟─f2feaaae-24a9-4b9b-8ae7-6c1dc88c7905
# ╟─df6a7329-9f65-4196-a255-c1e5c7f07e98
# ╟─cb22e3f6-64f4-4f58-8d9e-ffea55041688
# ╟─f9ebb06b-2069-4341-a384-be2b9bba75b1
# ╟─854a1031-8c93-4b12-be00-d2ae16cbdfed
# ╟─e05738f7-0e75-47e2-9cdd-1677869789c3
# ╟─497f2d90-e48b-4df7-b6dc-86484d840008
# ╟─b80c6743-0588-4be6-9a7e-6f66561362c9
# ╟─bba3aa7f-6957-45fa-8980-1eeaca8e668a
# ╟─c9a0a979-35c0-4ac2-acd5-0b7df7c80650
# ╟─ce2825ac-d059-49c7-addf-66d33ee97711
# ╟─d5658435-8f23-44ee-ba2c-20a756352bf6
# ╟─1ade4089-1b18-41fb-8197-f2b5025c9ab8
# ╟─baf347c2-99a3-42b8-adda-ec687eeeaee8
# ╟─411d650e-1ad3-4fef-a572-66c21615fdc0
# ╟─e66c295f-a171-4f9d-85e8-a8a781fd0716
# ╟─8992ef1a-7006-4460-8de2-f1a171a16f06
# ╟─ed64e1e4-bd2e-4b10-9a31-589fc3100589
# ╟─921e52ea-364f-415a-bb7d-bd896fb7703d
# ╟─b2e37cf5-d39b-4c93-b247-4579bcd61406
# ╟─f9cda48f-7e65-4241-8f32-2182b508d262
# ╟─bc429b64-665f-478f-bf71-739a82a22727
# ╟─08fdc9ab-cc4a-41a5-9b0a-009b1720dee7
# ╟─07499d78-e439-42c7-a9e2-46e96d514473
# ╟─feba96ed-ca96-4d8b-a613-65ec50e6df63
# ╟─6883abe1-e655-4975-b710-9cc90210963a
# ╟─d23a5283-98d2-483c-8429-3f22d6e1db6e
# ╟─b250bbbb-df29-4513-8a38-48b1d947212b
# ╟─a5c5a3a0-09f4-45c6-8d5f-86426199c9e3
# ╟─6f66bf72-e62b-48f9-852e-26c5ef6de63d
# ╟─0dbb7827-56b9-4d87-80c1-7230b69286c8
# ╟─9c5f30b2-fd41-4391-ac01-7edd58392acc
# ╟─d5e96eb4-a75b-41e4-a45e-9afae606c361
# ╟─d2551702-7ab8-47c7-a251-0ea3aa131d23
# ╟─89c006e7-a639-4981-a637-770f0b15a355
# ╟─d61c72d4-3bcb-4eb9-8ac9-8c7b59307cdb
# ╟─78cf8a61-adf6-4b6e-94af-9cda1e693b63
# ╟─8b18ba8d-2b5b-4dd2-8fdc-15e8e0507b98
# ╟─bfa679ff-de08-45e3-939c-3f9ace435496
# ╟─6626c328-dd10-45c6-a4fe-448f3a8b544f
# ╟─2e898a38-a727-4f96-a9c6-724b1e1976e3
# ╟─fa70f08a-0701-4d10-9404-94477f15004c
# ╟─ed43b6a5-cbbe-49e5-a92a-2908ded3fcdc
# ╟─8b7842cf-43da-4cec-8b58-875e0808da5d
# ╟─fa3fc559-bfd6-482c-895e-7eb5d94b52c5
# ╟─5b650f8b-e1f1-40e9-bea2-57d2c22dcfe6
# ╠═a0c38a7d-7e00-42f3-946c-8f14ac4b833f
# ╠═f55e761f-f211-4678-b785-2ff24e6f6e0c
# ╟─07bab014-705b-48e0-9103-f2e8ffbeca49
# ╠═47caf682-a17d-4580-957a-1c70e7ebbdcd
# ╠═b216da58-3a1e-447e-a28a-c4a05d6c7071
# ╠═bfdc30ea-1012-421b-ac4f-c1ef3c549602
# ╟─68d80aff-b957-44e5-90a4-94913745af91
# ╟─2f1f1fd0-df45-4dfc-abef-8134e5aab0de
# ╟─f66e3abb-8cae-4546-8a54-3b8884685563
# ╟─31f0a957-2c03-4e01-ba2f-13ad6a02ed61
# ╟─2d815049-df1c-4123-abca-aacaf327ef4d
# ╟─803cf46d-5e83-4270-9c3d-bd2b5d4b2331
# ╠═52701064-a9c5-453f-aff8-e8408d4ac40f
# ╟─97150741-3d26-4272-b7d2-7254346a24d3
# ╟─d7071ee9-566a-48ef-8557-9ef082c28f82
# ╠═5869ce26-dc16-475e-96e5-f8e4ab478811
# ╠═db00e32f-7f85-4348-a8ce-0814ba12ce80
# ╟─466e46cf-95d7-4c65-9881-cec5d3a6b0ed
# ╟─2986d55a-711e-4534-b251-f9fbdcf10325
# ╠═4f8e025a-080c-4c4e-85f5-7740beedb20f
# ╠═32176b33-24eb-4ad7-89b3-936b5d569717
# ╟─ce8a6e71-d050-4649-920e-f851f9e9f473
# ╟─fa55d3b3-13b8-4678-ab69-479f578ae504
# ╟─2dc56c74-1e44-4411-96ab-7268abfb72d9
# ╟─9e65d195-3137-4425-a6cb-ec1809fa4209
# ╟─1c32b277-f16d-4e13-a096-044157b5ab48
# ╟─1feb191b-2024-47e9-8a46-cf4df58aee6c
# ╟─c97bd46e-03e8-4129-894e-ef5d2700ad7b
# ╟─27d40918-54f1-43c4-b832-4de6b691009b
# ╟─ccf75d26-3970-4ddd-84d4-730362e1f0e8
# ╟─5adb0235-7e59-42fa-b4aa-adb7cae2302c
# ╟─f6bd75d4-8f76-4d45-9416-f9cb93f80456
# ╟─41622256-2e17-429d-b095-aaa82a39bafd
# ╟─fcd1d3c1-84d1-4c5c-80ad-b12fd13ec7b6
# ╟─95222ad0-5d1c-4f25-b87b-b102aadf18ae
# ╟─4f1c6d2a-c8b6-4155-97d3-586dd64ac47d
# ╟─9c5641fc-6a51-4e35-84b0-332ebeed47c9
# ╟─35abdbb4-731e-4d64-8a62-983e3c516eb7
# ╟─1df82830-f85b-403b-ab49-305e10ca28ae
# ╟─59889b5a-343d-4c59-9d95-082e57793e50
# ╠═a341eadc-df6c-4d78-8b11-c2a23d9b3dac
# ╠═4d3400e9-c607-46f5-9ae6-3aea11bc23a0
# ╟─98adb522-e82e-48dd-8697-b0f65bd8824b
# ╟─33ba962c-1627-45c6-829d-10b747365984
# ╟─3d452c15-6a14-400b-8791-a1ec8d6756fc
# ╟─cd21fe75-5d7a-4978-ba02-588a23e4f063
# ╠═58b3e793-46c0-4948-af90-63e99bf0f9be
# ╠═4da30ab5-4d69-4f40-9d08-05adfda1a4d7
# ╠═be3244c3-13a1-429e-a4d9-c4d3b240ec52
# ╟─1e60341a-ee8c-45fb-9e96-4e17c5ecb48f
# ╟─e334731d-17e0-47f7-8fff-2ad4b979ccf3
# ╟─94856792-bb77-4923-adf7-562344ed674d
# ╟─b422bb6d-6225-4d73-8279-b4b0dca38b92
# ╠═8eee0179-cc70-475a-a639-7de74be11560
# ╠═0ba781b9-61f4-4e12-991b-6d1989e585f9
# ╟─27b4f53e-e4cb-4ee1-bf77-e5ccb9eaa48e
# ╠═58372285-bb14-40c2-9f66-1f0269747b30
# ╠═6c228f88-7f9f-41a9-a14c-682316e1d049
# ╟─4da87070-14c5-4370-8f68-2c12e9e24e70
# ╠═f5af65c6-0dec-48b1-b043-0cd7eb5c0b72
# ╠═0e7e94ae-c4d9-4671-9c8a-19d5a6e4da6d
# ╟─ed7df4fb-ac79-47d5-82a9-05ee22249d2f
# ╟─187b2e8c-2cdf-4ade-839d-4f6eed4d39c4
# ╟─5452ec28-87e4-4d9b-af79-07e542cd85f5
# ╟─77fe0646-59d4-4766-bde9-aef5c7fa1758
# ╟─8064e4ce-d736-4cb3-a8af-fbc1e2f36e0b
# ╠═1bc9d55a-1969-453f-b800-7803bb4b7853
# ╠═ed74ca1f-13f3-44b8-8e55-47059c154167
# ╟─e1dcc4e9-3383-4310-a623-e83bfa90957e
# ╠═d78e9c87-ab48-4afd-a1c0-5e4e0b7fc1f2
# ╠═0413a76c-4e24-4df1-9c5f-a15b2c5c4021
# ╠═c0f40914-80e8-4b48-98c0-c6eff6a14f56
# ╠═682083d2-34ae-4a30-bc75-c285a45cc484
# ╟─6afd00e8-f5fc-4366-8e9a-d002d61a7326
# ╟─a231d3e9-5346-43b8-a7c8-715eb1f989f6
# ╟─ea83cd5d-841f-4756-bc61-afa5033575f3
# ╟─38914bc0-bf10-4d89-aee7-0579e50b3a7c
# ╠═2b7d5bfe-921e-461f-a29a-cf00cdba75a3
# ╠═233c3fc8-3dcb-4fb8-8d10-80e085ea5491
# ╠═53612e33-4a4b-4e15-97d8-4c8d8d656f0d
# ╠═ef9d5997-76c4-45db-9c54-981ed5647bf2
# ╠═4e75bba8-6591-4c86-ab9e-d189e2e4c9de
# ╟─8b53c174-5bf9-44e8-bc11-82a463f7995c
# ╟─64f158db-b18a-4589-a88c-3100eff2a926
# ╟─0ae53f9f-c03d-44c9-a7ac-38316c1bbe21
# ╟─b072cad6-08de-408c-aef4-ad9aaac16447
# ╠═5a71cdf6-44aa-4fa1-af52-54a117b45bf7
# ╠═10280d62-d068-4054-b73d-378482fa316b
# ╠═35923728-f98e-4433-b5fc-ca1e2266859f
# ╠═554f71ad-4031-45e7-adaa-f0ffb7a4f36a
# ╠═11869f42-8c1f-43d0-8487-4c544cc06fd9
# ╠═da67ba54-5d32-4546-b52b-809c3494008a
# ╠═43873124-f5f6-4c88-98dd-6344effde208
# ╠═5ffb615a-914c-4d0d-ae0b-7268f6f18cea
# ╟─77f19432-da58-4de5-a642-a87fe20fb6e8
# ╟─e2f3a4f5-1d32-43ee-a852-3eafc206942c
# ╟─ceb5b836-0a61-4130-8c99-6b6008858519
# ╟─6bdde19f-ca6f-4520-8299-9e43ee02606f
# ╟─96c3b9cc-edc1-4096-91a9-ef3af021e439
# ╟─7b7a8347-8556-41ba-902b-071aa216bbc0
# ╟─9f2349df-6873-4420-918f-1471d2a42fa1
# ╟─609bb1bb-cd1c-472f-8d65-3327eb1f2112
# ╟─f85c7e12-9146-41c8-89b6-e0d1745c5675
# ╟─9226d22e-0744-4b5c-a196-342f32fb10b8
# ╟─ccc6496a-ee0e-488b-b39b-b9ae70594290
# ╟─257518e4-1cb7-4e42-8462-607653ed419f
# ╟─4b5b5bd6-e317-4fbc-9676-81eed839b6bc
# ╟─9fc37471-11ae-4ff9-889e-b2cf45245536
# ╟─113376db-f08b-4526-8eec-8d2ca690bbf2
# ╟─8dd6287c-cf01-4a39-bdf5-557acd7d8965
# ╟─d5ad7e5c-05a9-4ba6-9b8d-1e634aa4d38b
# ╟─1b52447e-a66e-477b-b0f5-819cb17c5ff9
# ╟─c5698308-92a2-49a5-b3a6-a4fc79e60117
# ╟─8d6a9c51-4a1b-4419-bf38-56ae26995720
# ╟─b12a1c4c-da21-44e3-9fc7-b4bc3bed9691
# ╟─019c0a28-c473-4ed8-9c69-ad9d58c0e25c
# ╟─9b2ed1f6-e157-4734-84e1-f2ff0f070865
# ╟─cfec0a66-cb1b-49ac-b2d6-146c850a1480
# ╟─1861c0ae-cef7-433c-b161-2ba5c4250079
# ╟─2921c571-f9e1-4953-9dd2-fa1a70fcfa43
# ╟─25b19b0e-fa7d-4988-889b-ff2f7cd02e21
# ╟─331071d1-ebfc-4820-a095-6a9df1c3c0f7
# ╟─4be4ffc4-dcc8-41ca-9b6c-94071cae1f0c
# ╟─7cb824fa-0999-4fe6-9bf6-e65d880b88ca
# ╟─7ecf9105-12c3-4274-a30b-88c5f53e1cbf
# ╟─b54ef6e7-0155-49d7-810c-3a0f4709e35f
# ╟─9a59a8a7-3cd3-42dc-a1fb-13be18c014ff
# ╟─c9c5c6fb-80e5-4351-804e-50f637ea4a20
# ╟─e3286a30-e7c1-40c4-a1a4-cdba8cb3af4e
# ╟─f6020c25-47e5-411d-a643-40c345533fde
# ╟─ce03971b-6456-4cfe-8d45-26d80e62a1aa
# ╟─cba7be0e-df6c-451c-814b-9daf9a962a95
# ╟─dc26823d-ce1a-4807-bf74-826999ae57e9
# ╟─608820a5-0e93-4b4c-ac14-0665fff873ac
# ╟─6d2ffa12-3d61-44a5-9f37-630743c1d5cb
# ╟─e71a6db6-53b9-4b15-a8c0-23ccd951daf5
# ╠═b651d2bc-7d4d-4753-b866-d06525e49454
# ╠═59f9b9f0-0285-4215-9888-6a2fd65ce148
# ╠═d1c400cc-4616-41a4-a8c9-9ea0ec4293d0
# ╠═f8957233-b91e-4fbf-a20c-7a50eacf8fa3
# ╟─010775c5-6489-4eb7-837f-1bb0de9c2638
# ╟─d6b3ca6a-745c-444a-bc2d-fd488f168afd
# ╟─7c1ab67e-e942-498d-86ef-fc7692e5eecf
# ╟─fbfb7872-b25c-407a-9718-872cbcc90030
# ╟─c12e7f59-8a0a-4494-bba7-1a2572aedd7a
# ╟─e52ccb68-7882-4fce-b902-0b212e51c186
# ╟─2321e203-daf6-4230-af94-8e86f4e58a3b
# ╟─d25bb035-607e-48fe-a953-ab5339062b5a
# ╟─0effee55-0a0b-4ce9-8ca2-a5d2b87f82f0
# ╠═f3f759a7-ac70-4739-bed2-4e122cb80a36
# ╠═4fe07e66-325e-428d-bb9d-01f0d3800ffd
# ╠═88400bf5-88db-4af6-93a4-c332d3dbf512
# ╟─4017e24c-35c1-4efa-8993-76e4cdf325a0
# ╟─19983218-e52d-4d22-aebe-ca310b3c110a
# ╟─0359c171-f867-4269-92b1-e11ef933f980
# ╟─51545f40-2824-45a2-a256-d0875f7a2d03
# ╠═8983169b-2583-4cfa-b93e-82130b8f11ef
# ╠═b8ab1309-3367-4fca-adf7-ce8b3c5f2690
# ╠═028e2bd1-4b5c-40b3-bbbc-80bdd3ea9e7e
# ╟─5bb52a79-df22-491d-b145-0498ac67cfe0
# ╟─f82c8b1f-dc29-4c23-ba3a-6881762752e6
# ╟─17816a65-4633-4c60-b379-bd441b29a255
# ╟─41da8487-dd6f-427b-8d81-4028fb4df618
# ╟─bc388a1d-0082-44e4-860a-148965d9927d
# ╟─156e5e37-2d94-42b9-95d2-f6dd36d52cc7
# ╟─99bd933c-0097-46a7-9350-c3a4c09f7dc1
# ╟─7c4b1a00-3750-4f38-8508-288db779d076
# ╟─f79b8a77-beab-43cc-b6ae-1003f5d6b50d
# ╟─47c8269c-fe56-4a01-95b7-21310ecccc86
# ╟─faf938b5-ddf3-442f-935c-3a5aa1c6fe53
# ╟─a24c0c4c-7ceb-462a-8f5c-a209590ca904
# ╟─64ddcf33-b8cd-4d32-9b3f-1bc0f2b71b1a
# ╟─8bf3238c-b5c0-470e-a62b-c27ac858a6e3
# ╟─e44b048d-740a-4835-92d5-dbc69d16d9cd
# ╟─e8f31a09-fbd8-4fdc-849e-88f9164dd70a
# ╟─0c2a8ccb-3c88-4af8-8b0f-296ffdc5660a
# ╟─defa2bb7-e6d3-45f7-af38-8558102d7290
# ╟─66311a4f-bb8d-4f2b-b52d-88a8c3e8d3cb
