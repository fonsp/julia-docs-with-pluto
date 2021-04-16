### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ fce4b478-0e4a-419a-bf1c-c2985de3f368
md"""
# [Types](@id man-types)
"""

# ╔═╡ dcb168bc-aa05-4534-a1da-04c39eae408e
md"""
Type systems have traditionally fallen into two quite different camps: static type systems, where every program expression must have a type computable before the execution of the program, and dynamic type systems, where nothing is known about types until run time, when the actual values manipulated by the program are available. Object orientation allows some flexibility in statically typed languages by letting code be written without the precise types of values being known at compile time. The ability to write code that can operate on different types is called polymorphism. All code in classic dynamically typed languages is polymorphic: only by explicitly checking types, or when objects fail to support operations at run-time, are the types of any values ever restricted.
"""

# ╔═╡ fae89ec1-b202-4d47-879a-22910b414840
md"""
Julia's type system is dynamic, but gains some of the advantages of static type systems by making it possible to indicate that certain values are of specific types. This can be of great assistance in generating efficient code, but even more significantly, it allows method dispatch on the types of function arguments to be deeply integrated with the language. Method dispatch is explored in detail in [Methods](@ref), but is rooted in the type system presented here.
"""

# ╔═╡ 9c72038e-6af3-439b-830b-77fe8d08523b
md"""
The default behavior in Julia when types are omitted is to allow values to be of any type. Thus, one can write many useful Julia functions without ever explicitly using types. When additional expressiveness is needed, however, it is easy to gradually introduce explicit type annotations into previously \"untyped\" code. Adding annotations serves three primary purposes: to take advantage of Julia's powerful multiple-dispatch mechanism,  to improve human readability, and to catch programmer errors.
"""

# ╔═╡ 757b5d8b-e4a8-40b6-bedf-f3974e98f961
md"""
Describing Julia in the lingo of [type systems](https://en.wikipedia.org/wiki/Type_system), it is: dynamic, nominative and parametric. Generic types can be parameterized, and the hierarchical relationships between types are [explicitly declared](https://en.wikipedia.org/wiki/Nominal_type_system), rather than [implied by compatible structure](https://en.wikipedia.org/wiki/Structural_type_system). One particularly distinctive feature of Julia's type system is that concrete types may not subtype each other: all concrete types are final and may only have abstract types as their supertypes. While this might at first seem unduly restrictive, it has many beneficial consequences with surprisingly few drawbacks. It turns out that being able to inherit behavior is much more important than being able to inherit structure, and inheriting both causes significant difficulties in traditional object-oriented languages. Other high-level aspects of Julia's type system that should be mentioned up front are:
"""

# ╔═╡ ac0d81cb-f1e3-476d-b462-6bf887fd696d
md"""
  * There is no division between object and non-object values: all values in Julia are true objects having a type that belongs to a single, fully connected type graph, all nodes of which are equally first-class as types.
  * There is no meaningful concept of a \"compile-time type\": the only type a value has is its actual type when the program is running. This is called a \"run-time type\" in object-oriented languages where the combination of static compilation with polymorphism makes this distinction significant.
  * Only values, not variables, have types – variables are simply names bound to values, although for simplicity we may say \"type of a variable\" as shorthand for \"type of the value to which a variable refers\".
  * Both abstract and concrete types can be parameterized by other types. They can also be parameterized by symbols, by values of any type for which [`isbits`](@ref) returns true (essentially, things like numbers and bools that are stored like C types or `struct`s with no pointers to other objects), and also by tuples thereof. Type parameters may be omitted when they do not need to be referenced or restricted.
"""

# ╔═╡ cf0ee90a-a4e0-4040-b438-0206503c73d2
md"""
Julia's type system is designed to be powerful and expressive, yet clear, intuitive and unobtrusive. Many Julia programmers may never feel the need to write code that explicitly uses types. Some kinds of programming, however, become clearer, simpler, faster and more robust with declared types.
"""

# ╔═╡ 52c7d681-bccb-4b83-aa15-6a20394b58e0
md"""
## Type Declarations
"""

# ╔═╡ 49ea8853-95d2-419e-a4f2-f0c8fd3f2acb
md"""
The `::` operator can be used to attach type annotations to expressions and variables in programs. There are two primary reasons to do this:
"""

# ╔═╡ dc222c41-e6be-4593-9803-e5c85f27d582
md"""
1. As an assertion to help confirm that your program works the way you expect,
2. To provide extra type information to the compiler, which can then improve performance in some cases
"""

# ╔═╡ df22e3af-c747-4de1-bbcd-ff89f05ab814
md"""
When appended to an expression computing a value, the `::` operator is read as \"is an instance of\". It can be used anywhere to assert that the value of the expression on the left is an instance of the type on the right. When the type on the right is concrete, the value on the left must have that type as its implementation – recall that all concrete types are final, so no implementation is a subtype of any other. When the type is abstract, it suffices for the value to be implemented by a concrete type that is a subtype of the abstract type. If the type assertion is not true, an exception is thrown, otherwise, the left-hand value is returned:
"""

# ╔═╡ 2ab3887a-31bb-4350-b4e9-b0a82b2b021b
(1+2)::AbstractFloat

# ╔═╡ ca1d7172-dd30-407d-9746-350b28402fda
(1+2)::Int

# ╔═╡ c5abd2de-812c-453c-90d2-b7e82adf45f4
md"""
This allows a type assertion to be attached to any expression in-place.
"""

# ╔═╡ 3d28ea19-598d-4697-a187-285f96f1bd30
md"""
When appended to a variable on the left-hand side of an assignment, or as part of a `local` declaration, the `::` operator means something a bit different: it declares the variable to always have the specified type, like a type declaration in a statically-typed language such as C. Every value assigned to the variable will be converted to the declared type using [`convert`](@ref):
"""

# ╔═╡ 1ca0a196-bc00-45cc-93e2-ec05b5aafba6
function foo()
     x::Int8 = 100
     x
 end

# ╔═╡ b3392876-5024-4b08-8671-bc9f02eeadc8
x = foo()

# ╔═╡ 5c42eefc-29f2-4cf4-9a17-052bc5bcc52e
typeof(x)

# ╔═╡ c882235f-3f62-4749-834c-ea7ed0848b1a
md"""
This feature is useful for avoiding performance \"gotchas\" that could occur if one of the assignments to a variable changed its type unexpectedly.
"""

# ╔═╡ 09f3c65a-15c7-429b-a0d0-a11e87f581c4
md"""
This \"declaration\" behavior only occurs in specific contexts:
"""

# ╔═╡ 02b1a1f6-1205-40aa-bd97-2d05a781e07f
md"""
```julia
local x::Int8  # in a local declaration
x::Int8 = 10   # as the left-hand side of an assignment
```
"""

# ╔═╡ bcbb40b2-b93e-45f4-bdb6-5bb2acd2b63b
md"""
and applies to the whole current scope, even before the declaration. Currently, type declarations cannot be used in global scope, e.g. in the REPL, since Julia does not yet have constant-type globals.
"""

# ╔═╡ 7b5bf1ad-dff1-487a-9382-4a1485dccfb4
md"""
Declarations can also be attached to function definitions:
"""

# ╔═╡ d264027b-5853-44ec-a703-e52674f8e649
md"""
```julia
function sinc(x)::Float64
    if x == 0
        return 1
    end
    return sin(pi*x)/(pi*x)
end
```
"""

# ╔═╡ 15a740c2-66b8-4af9-b5d0-89a07dc8ef57
md"""
Returning from this function behaves just like an assignment to a variable with a declared type: the value is always converted to `Float64`.
"""

# ╔═╡ afd6f2fd-d5b8-4c15-8e2a-880d4ff25bdb
md"""
## [Abstract Types](@id man-abstract-types)
"""

# ╔═╡ 8494156d-6666-4ebb-8f83-f751e409714f
md"""
Abstract types cannot be instantiated, and serve only as nodes in the type graph, thereby describing sets of related concrete types: those concrete types which are their descendants. We begin with abstract types even though they have no instantiation because they are the backbone of the type system: they form the conceptual hierarchy which makes Julia's type system more than just a collection of object implementations.
"""

# ╔═╡ 0ebc2b69-817e-4068-bc12-bbab5f51efc9
md"""
Recall that in [Integers and Floating-Point Numbers](@ref), we introduced a variety of concrete types of numeric values: [`Int8`](@ref), [`UInt8`](@ref), [`Int16`](@ref), [`UInt16`](@ref), [`Int32`](@ref), [`UInt32`](@ref), [`Int64`](@ref), [`UInt64`](@ref), [`Int128`](@ref), [`UInt128`](@ref), [`Float16`](@ref), [`Float32`](@ref), and [`Float64`](@ref). Although they have different representation sizes, `Int8`, `Int16`, `Int32`, `Int64` and `Int128` all have in common that they are signed integer types. Likewise `UInt8`, `UInt16`, `UInt32`, `UInt64` and `UInt128` are all unsigned integer types, while `Float16`, `Float32` and `Float64` are distinct in being floating-point types rather than integers. It is common for a piece of code to make sense, for example, only if its arguments are some kind of integer, but not really depend on what particular *kind* of integer. For example, the greatest common denominator algorithm works for all kinds of integers, but will not work for floating-point numbers. Abstract types allow the construction of a hierarchy of types, providing a context into which concrete types can fit. This allows you, for example, to easily program to any type that is an integer, without restricting an algorithm to a specific type of integer.
"""

# ╔═╡ f31bdf9a-8e17-41a6-bc49-496418d02b31
md"""
Abstract types are declared using the [`abstract type`](@ref) keyword. The general syntaxes for declaring an abstract type are:
"""

# ╔═╡ 579a5cd9-b814-4333-96ab-c4b8f89fabf9
md"""
```
abstract type «name» end
abstract type «name» <: «supertype» end
```
"""

# ╔═╡ 8ee40666-e889-4fce-b357-05b9a0a94a7b
md"""
The `abstract type` keyword introduces a new abstract type, whose name is given by `«name»`. This name can be optionally followed by [`<:`](@ref) and an already-existing type, indicating that the newly declared abstract type is a subtype of this \"parent\" type.
"""

# ╔═╡ 9ada773c-a26a-4b2b-91b4-d6629c63c2b9
md"""
When no supertype is given, the default supertype is `Any` – a predefined abstract type that all objects are instances of and all types are subtypes of. In type theory, `Any` is commonly called \"top\" because it is at the apex of the type graph. Julia also has a predefined abstract \"bottom\" type, at the nadir of the type graph, which is written as `Union{}`. It is the exact opposite of `Any`: no object is an instance of `Union{}` and all types are supertypes of `Union{}`.
"""

# ╔═╡ b8dd2c89-34ff-45c4-b8ec-93a0ee48d58a
md"""
Let's consider some of the abstract types that make up Julia's numerical hierarchy:
"""

# ╔═╡ eab25a9b-3881-43cb-8c08-f5281ddb9bf9
md"""
```julia
abstract type Number end
abstract type Real     <: Number end
abstract type AbstractFloat <: Real end
abstract type Integer  <: Real end
abstract type Signed   <: Integer end
abstract type Unsigned <: Integer end
```
"""

# ╔═╡ d7d8b132-d7f4-44cd-8575-f8a86088bd91
md"""
The [`Number`](@ref) type is a direct child type of `Any`, and [`Real`](@ref) is its child. In turn, `Real` has two children (it has more, but only two are shown here; we'll get to the others later): [`Integer`](@ref) and [`AbstractFloat`](@ref), separating the world into representations of integers and representations of real numbers. Representations of real numbers include, of course, floating-point types, but also include other types, such as rationals. Hence, `AbstractFloat` is a proper subtype of `Real`, including only floating-point representations of real numbers. Integers are further subdivided into [`Signed`](@ref) and [`Unsigned`](@ref) varieties.
"""

# ╔═╡ 99d82193-6fb8-47fd-ba3b-411d84f27f5e
md"""
The `<:` operator in general means \"is a subtype of\", and, used in declarations like this, declares the right-hand type to be an immediate supertype of the newly declared type. It can also be used in expressions as a subtype operator which returns `true` when its left operand is a subtype of its right operand:
"""

# ╔═╡ c850568f-bdfd-44d4-a540-a57ad6097697
Integer <: Number

# ╔═╡ 5c2be37a-a9c6-497c-8a6b-9cc032ef0dc2
Integer <: AbstractFloat

# ╔═╡ 985ffaa1-51b3-4a30-bca8-ea7832a0b533
md"""
An important use of abstract types is to provide default implementations for concrete types. To give a simple example, consider:
"""

# ╔═╡ ae75b271-52eb-4a39-be1f-087b554a39d8
md"""
```julia
function myplus(x,y)
    x+y
end
```
"""

# ╔═╡ 61371f4d-7620-4374-b57e-cde9835a239d
md"""
The first thing to note is that the above argument declarations are equivalent to `x::Any` and `y::Any`. When this function is invoked, say as `myplus(2,5)`, the dispatcher chooses the most specific method named `myplus` that matches the given arguments. (See [Methods](@ref) for more information on multiple dispatch.)
"""

# ╔═╡ 509a546d-dc46-4d5e-b7d0-546c6b54f50b
md"""
Assuming no method more specific than the above is found, Julia next internally defines and compiles a method called `myplus` specifically for two `Int` arguments based on the generic function given above, i.e., it implicitly defines and compiles:
"""

# ╔═╡ b9226004-1a54-4f23-93d7-a5a1ed8d1186
md"""
```julia
function myplus(x::Int,y::Int)
    x+y
end
```
"""

# ╔═╡ fbed8119-2358-4fd3-bb20-9adaa72d0efc
md"""
and finally, it invokes this specific method.
"""

# ╔═╡ 827bd762-0e7e-49fc-83f5-02c97de288a8
md"""
Thus, abstract types allow programmers to write generic functions that can later be used as the default method by many combinations of concrete types. Thanks to multiple dispatch, the programmer has full control over whether the default or more specific method is used.
"""

# ╔═╡ c5438a58-b383-41b9-83fd-2a15e5ecddfe
md"""
An important point to note is that there is no loss in performance if the programmer relies on a function whose arguments are abstract types, because it is recompiled for each tuple of argument concrete types with which it is invoked. (There may be a performance issue, however, in the case of function arguments that are containers of abstract types; see [Performance Tips](@ref man-performance-abstract-container).)
"""

# ╔═╡ 15a7058c-ae8a-4391-bf3c-15e08f80f1c4
md"""
## Primitive Types
"""

# ╔═╡ 0f18f6a6-28e7-49e5-97b0-7b3ea51d0081
md"""
!!! warning
    It is almost always preferable to wrap an existing primitive type in a new composite type than to define your own primitive type.

    This functionality exists to allow Julia to bootstrap the standard primitive types that LLVM supports. Once they are defined, there is very little reason to define more.
"""

# ╔═╡ 1f333bfe-636b-4e46-8af3-87358101e50e
md"""
A primitive type is a concrete type whose data consists of plain old bits. Classic examples of primitive types are integers and floating-point values. Unlike most languages, Julia lets you declare your own primitive types, rather than providing only a fixed set of built-in ones. In fact, the standard primitive types are all defined in the language itself:
"""

# ╔═╡ 3f8fce94-672b-4577-ac73-7b48b4623c31
md"""
```julia
primitive type Float16 <: AbstractFloat 16 end
primitive type Float32 <: AbstractFloat 32 end
primitive type Float64 <: AbstractFloat 64 end

primitive type Bool <: Integer 8 end
primitive type Char <: AbstractChar 32 end

primitive type Int8    <: Signed   8 end
primitive type UInt8   <: Unsigned 8 end
primitive type Int16   <: Signed   16 end
primitive type UInt16  <: Unsigned 16 end
primitive type Int32   <: Signed   32 end
primitive type UInt32  <: Unsigned 32 end
primitive type Int64   <: Signed   64 end
primitive type UInt64  <: Unsigned 64 end
primitive type Int128  <: Signed   128 end
primitive type UInt128 <: Unsigned 128 end
```
"""

# ╔═╡ 06260e78-788b-415d-a4b2-75c86459dcfe
md"""
The general syntaxes for declaring a primitive type are:
"""

# ╔═╡ 55be505d-a4c2-4ce0-ad6a-f573554a53d6
md"""
```
primitive type «name» «bits» end
primitive type «name» <: «supertype» «bits» end
```
"""

# ╔═╡ 7524d9d1-f26e-4da4-9648-12eecba6f50d
md"""
The number of bits indicates how much storage the type requires and the name gives the new type a name. A primitive type can optionally be declared to be a subtype of some supertype. If a supertype is omitted, then the type defaults to having `Any` as its immediate supertype. The declaration of [`Bool`](@ref) above therefore means that a boolean value takes eight bits to store, and has [`Integer`](@ref) as its immediate supertype. Currently, only sizes that are multiples of 8 bits are supported and you are likely to experience LLVM bugs with sizes other than those used above. Therefore, boolean values, although they really need just a single bit, cannot be declared to be any smaller than eight bits.
"""

# ╔═╡ 10843ef5-27c1-44cf-98d5-89f5835530c0
md"""
The types [`Bool`](@ref), [`Int8`](@ref) and [`UInt8`](@ref) all have identical representations: they are eight-bit chunks of memory. Since Julia's type system is nominative, however, they are not interchangeable despite having identical structure. A fundamental difference between them is that they have different supertypes: [`Bool`](@ref)'s direct supertype is [`Integer`](@ref), [`Int8`](@ref)'s is [`Signed`](@ref), and [`UInt8`](@ref)'s is [`Unsigned`](@ref). All other differences between [`Bool`](@ref), [`Int8`](@ref), and [`UInt8`](@ref) are matters of behavior – the way functions are defined to act when given objects of these types as arguments. This is why a nominative type system is necessary: if structure determined type, which in turn dictates behavior, then it would be impossible to make [`Bool`](@ref) behave any differently than [`Int8`](@ref) or [`UInt8`](@ref).
"""

# ╔═╡ 5002a185-00ab-46e4-af43-ad66f1c1ff2f
md"""
## Composite Types
"""

# ╔═╡ 1094f745-0ddc-41a2-b89d-bda3d7b0aab5
md"""
[Composite types](https://en.wikipedia.org/wiki/Composite_data_type) are called records, structs, or objects in various languages. A composite type is a collection of named fields, an instance of which can be treated as a single value. In many languages, composite types are the only kind of user-definable type, and they are by far the most commonly used user-defined type in Julia as well.
"""

# ╔═╡ ca1ec9a5-442d-4984-af22-02387fc25b19
md"""
In mainstream object oriented languages, such as C++, Java, Python and Ruby, composite types also have named functions associated with them, and the combination is called an \"object\". In purer object-oriented languages, such as Ruby or Smalltalk, all values are objects whether they are composites or not. In less pure object oriented languages, including C++ and Java, some values, such as integers and floating-point values, are not objects, while instances of user-defined composite types are true objects with associated methods. In Julia, all values are objects, but functions are not bundled with the objects they operate on. This is necessary since Julia chooses which method of a function to use by multiple dispatch, meaning that the types of *all* of a function's arguments are considered when selecting a method, rather than just the first one (see [Methods](@ref) for more information on methods and dispatch). Thus, it would be inappropriate for functions to \"belong\" to only their first argument. Organizing methods into function objects rather than having named bags of methods \"inside\" each object ends up being a highly beneficial aspect of the language design.
"""

# ╔═╡ 69afdbfb-21b4-425f-9f97-fb212863b697
md"""
Composite types are introduced with the [`struct`](@ref) keyword followed by a block of field names, optionally annotated with types using the `::` operator:
"""

# ╔═╡ 0b8c9887-26be-418d-bea8-d4b3375e9159
struct Foo
     bar
     baz::Int
     qux::Float64
 end

# ╔═╡ 2c661ef6-d69d-4662-8964-6e67743605f5
md"""
Fields with no type annotation default to `Any`, and can accordingly hold any type of value.
"""

# ╔═╡ 13aee84d-fa7a-477d-ada5-1101e4799f8c
md"""
New objects of type `Foo` are created by applying the `Foo` type object like a function to values for its fields:
"""

# ╔═╡ dac5eb99-e1c2-4384-b130-683aa9a1ceda
foo = Foo("Hello, world.", 23, 1.5)

# ╔═╡ 3d839ffd-307d-4a16-ba1c-7d7d8f6b3ebc
typeof(foo)

# ╔═╡ c6ced6eb-c26a-4d1a-8b63-ddf625254110
md"""
When a type is applied like a function it is called a *constructor*. Two constructors are generated automatically (these are called *default constructors*). One accepts any arguments and calls [`convert`](@ref) to convert them to the types of the fields, and the other accepts arguments that match the field types exactly. The reason both of these are generated is that this makes it easier to add new definitions without inadvertently replacing a default constructor.
"""

# ╔═╡ 543ef7f0-d099-4bd3-bf7b-9ca32ffd3dca
md"""
Since the `bar` field is unconstrained in type, any value will do. However, the value for `baz` must be convertible to `Int`:
"""

# ╔═╡ ab15244c-fdbb-4107-8a5f-530ec21c39fd
Foo((), 23.5, 1)

# ╔═╡ c62bcc4b-f9ae-4793-b2dc-362989fb341a
md"""
You may find a list of field names using the [`fieldnames`](@ref) function.
"""

# ╔═╡ 1f6e9810-6b89-42d5-94de-6fc2df985d87
fieldnames(Foo)

# ╔═╡ 643371d4-645c-490c-b855-d013f4e0def6
md"""
You can access the field values of a composite object using the traditional `foo.bar` notation:
"""

# ╔═╡ 15a605f5-092e-4907-9e74-d1dfeccd75c7
foo.bar

# ╔═╡ bcb87b6b-ffcf-4992-964a-96def1130af5
foo.baz

# ╔═╡ 19297ff7-f519-4e05-8c33-c503ded6b1dc
foo.qux

# ╔═╡ 76e0db05-3546-4725-ae93-21398252fed9
md"""
Composite objects declared with `struct` are *immutable*; they cannot be modified after construction. This may seem odd at first, but it has several advantages:
"""

# ╔═╡ 2882cd84-8fa7-4493-927e-6ac956824207
md"""
  * It can be more efficient. Some structs can be packed efficiently into arrays, and in some cases the compiler is able to avoid allocating immutable objects entirely.
  * It is not possible to violate the invariants provided by the type's constructors.
  * Code using immutable objects can be easier to reason about.
"""

# ╔═╡ 14258a49-8ffe-413f-b102-31c1169bd2cb
md"""
An immutable object might contain mutable objects, such as arrays, as fields. Those contained objects will remain mutable; only the fields of the immutable object itself cannot be changed to point to different objects.
"""

# ╔═╡ e642c1b7-72d1-4288-83a4-fdb810174bd0
md"""
Where required, mutable composite objects can be declared with the keyword [`mutable struct`](@ref), to be discussed in the next section.
"""

# ╔═╡ 225334ac-fccd-42fa-ab3e-c90e3c688085
md"""
If all the fields of an immutable structure are indistinguishable (`===`) then two immutable values containing those fields are also indistinguishable:
"""

# ╔═╡ 18d2f0fe-7410-4d4d-9e50-e115e8629810
struct X
     a::Int
     b::Float64
 end

# ╔═╡ f19f0795-ab67-412b-a360-990fd3b7e2a1
X(1, 2) === X(1, 2)

# ╔═╡ 9bcb8cd9-1d93-4674-846b-db407676ba69
md"""
There is much more to say about how instances of composite types are created, but that discussion depends on both [Parametric Types](@ref) and on [Methods](@ref), and is sufficiently important to be addressed in its own section: [Constructors](@ref man-constructors).
"""

# ╔═╡ 944ad34c-5c8c-4b74-947e-7c8e92d42d46
md"""
## Mutable Composite Types
"""

# ╔═╡ fbf50303-a8af-4095-81cb-d77b18138140
md"""
If a composite type is declared with `mutable struct` instead of `struct`, then instances of it can be modified:
"""

# ╔═╡ c129d45a-ce8e-4549-86f3-3fc0c85c0bdb
mutable struct Bar
     baz
     qux::Float64
 end

# ╔═╡ 9898f29c-72d7-48a1-b008-bd3ccbb50e27
bar = Bar("Hello", 1.5);

# ╔═╡ 1b625394-c5a2-421f-905c-f2eee489e2af
bar.qux = 2.0

# ╔═╡ c3eadcea-178d-4f59-84df-c6c420dd85c9
bar.baz = 1//2

# ╔═╡ 68ecb770-9c51-4c36-8c88-d8b817d0e1c6
md"""
In order to support mutation, such objects are generally allocated on the heap, and have stable memory addresses. A mutable object is like a little container that might hold different values over time, and so can only be reliably identified with its address. In contrast, an instance of an immutable type is associated with specific field values –- the field values alone tell you everything about the object. In deciding whether to make a type mutable, ask whether two instances with the same field values would be considered identical, or if they might need to change independently over time. If they would be considered identical, the type should probably be immutable.
"""

# ╔═╡ 5498491e-e37e-4f20-a1db-8c64ba5be6b5
md"""
To recap, two essential properties define immutability in Julia:
"""

# ╔═╡ 0ce69919-a13d-4195-8853-ef02bf73a099
md"""
  * It is not permitted to modify the value of an immutable type.

      * For bits types this means that the bit pattern of a value once set will never change and that value is the identity of a bits type.
      * For composite  types, this means that the identity of the values of its fields will never change. When the fields are bits types, that means their bits will never change, for fields whose values are mutable types like arrays, that means the fields will always refer to the same mutable value even though that mutable value's content may itself be modified.
  * An object with an immutable type may be copied freely by the compiler since its immutability makes it impossible to programmatically distinguish between the original object and a copy.

      * In particular, this means that small enough immutable values like integers and floats are typically passed to functions in registers (or stack allocated).
      * Mutable values, on the other hand are heap-allocated and passed to functions as pointers to heap-allocated values except in cases where the compiler is sure that there's no way to tell that this is not what is happening.
"""

# ╔═╡ cacbdb1e-8059-4cd7-8d1e-312fe1390d8e
md"""
## [Declared Types](@id man-declared-types)
"""

# ╔═╡ c605c1e1-1b0d-4df6-a97b-f4ff4838b1e2
md"""
The three kinds of types (abstract, primitive, composite) discussed in the previous sections are actually all closely related. They share the same key properties:
"""

# ╔═╡ 4098fa47-0278-47fd-b9be-564b25aa5c8c
md"""
  * They are explicitly declared.
  * They have names.
  * They have explicitly declared supertypes.
  * They may have parameters.
"""

# ╔═╡ 3b70d863-9c25-4a7e-8fca-632fc9d152d5
md"""
Because of these shared properties, these types are internally represented as instances of the same concept, `DataType`, which is the type of any of these types:
"""

# ╔═╡ 4d29f33e-354d-4eee-92fd-094c622b106b
typeof(Real)

# ╔═╡ 65f064db-81e1-4c70-890c-5f1f9ec98a13
typeof(Int)

# ╔═╡ 657b61ae-cbe1-4d9c-b2c8-90b65686e59e
md"""
A `DataType` may be abstract or concrete. If it is concrete, it has a specified size, storage layout, and (optionally) field names. Thus a primitive type is a `DataType` with nonzero size, but no field names. A composite type is a `DataType` that has field names or is empty (zero size).
"""

# ╔═╡ 0a27e691-9fd5-42ee-852b-04f0536c34e9
md"""
Every concrete value in the system is an instance of some `DataType`.
"""

# ╔═╡ d7892ac4-a4df-4ced-8b22-a4ec7a0f87ed
md"""
## Type Unions
"""

# ╔═╡ 2424367d-f14c-41bf-af3e-c8a0d1003ac3
md"""
A type union is a special abstract type which includes as objects all instances of any of its argument types, constructed using the special [`Union`](@ref) keyword:
"""

# ╔═╡ d82ea975-762f-43ca-975e-6f1b7d9e9a99
IntOrString = Union{Int,AbstractString}

# ╔═╡ 841d9207-27fc-4c45-8faa-12a5dc2e4ea2
1 :: IntOrString

# ╔═╡ 8ba8b7d0-b28b-4cd7-a23d-bbfcf479a9c4
"Hello!" :: IntOrString

# ╔═╡ 4da274de-c657-4708-bfca-068adfda4d58
1.0 :: IntOrString

# ╔═╡ 91f097d0-02c3-4870-8de8-fd453ceb716b
md"""
The compilers for many languages have an internal union construct for reasoning about types; Julia simply exposes it to the programmer. The Julia compiler is able to generate efficient code in the presence of `Union` types with a small number of types [^1], by generating specialized code in separate branches for each possible type.
"""

# ╔═╡ 0060ed4e-92ba-4f08-aecf-cf949e2c8d03
md"""
A particularly useful case of a `Union` type is `Union{T, Nothing}`, where `T` can be any type and [`Nothing`](@ref) is the singleton type whose only instance is the object [`nothing`](@ref). This pattern is the Julia equivalent of [`Nullable`, `Option` or `Maybe`](https://en.wikipedia.org/wiki/Nullable_type) types in other languages. Declaring a function argument or a field as `Union{T, Nothing}` allows setting it either to a value of type `T`, or to `nothing` to indicate that there is no value. See [this FAQ entry](@ref faq-nothing) for more information.
"""

# ╔═╡ c1b97921-ba59-4527-b66b-13915205f8a1
md"""
## Parametric Types
"""

# ╔═╡ 12652c8d-2474-4feb-bd58-06687271cead
md"""
An important and powerful feature of Julia's type system is that it is parametric: types can take parameters, so that type declarations actually introduce a whole family of new types – one for each possible combination of parameter values. There are many languages that support some version of [generic programming](https://en.wikipedia.org/wiki/Generic_programming), wherein data structures and algorithms to manipulate them may be specified without specifying the exact types involved. For example, some form of generic programming exists in ML, Haskell, Ada, Eiffel, C++, Java, C#, F#, and Scala, just to name a few. Some of these languages support true parametric polymorphism (e.g. ML, Haskell, Scala), while others support ad-hoc, template-based styles of generic programming (e.g. C++, Java). With so many different varieties of generic programming and parametric types in various languages, we won't even attempt to compare Julia's parametric types to other languages, but will instead focus on explaining Julia's system in its own right. We will note, however, that because Julia is a dynamically typed language and doesn't need to make all type decisions at compile time, many traditional difficulties encountered in static parametric type systems can be relatively easily handled.
"""

# ╔═╡ f035bc33-0f78-4be5-953c-b91d8346032a
md"""
All declared types (the `DataType` variety) can be parameterized, with the same syntax in each case. We will discuss them in the following order: first, parametric composite types, then parametric abstract types, and finally parametric primitive types.
"""

# ╔═╡ a1062514-b408-4bba-acf3-4056a46032ab
md"""
### [Parametric Composite Types](@id man-parametric-composite-types)
"""

# ╔═╡ 056b9b5a-cc46-44f1-a333-d377ebadc2d6
md"""
Type parameters are introduced immediately after the type name, surrounded by curly braces:
"""

# ╔═╡ 9296bc08-6e85-40a9-9f55-414cb9dfcaed
struct Point{T}
     x::T
     y::T
 end

# ╔═╡ d877caf1-a8d6-479e-ad9b-f8d18f5ea86e
md"""
This declaration defines a new parametric type, `Point{T}`, holding two \"coordinates\" of type `T`. What, one may ask, is `T`? Well, that's precisely the point of parametric types: it can be any type at all (or a value of any bits type, actually, although here it's clearly used as a type). `Point{Float64}` is a concrete type equivalent to the type defined by replacing `T` in the definition of `Point` with [`Float64`](@ref). Thus, this single declaration actually declares an unlimited number of types: `Point{Float64}`, `Point{AbstractString}`, `Point{Int64}`, etc. Each of these is now a usable concrete type:
"""

# ╔═╡ d285cd41-836b-4af0-882b-117cdc001665
Point{Float64}

# ╔═╡ caf5f34f-1e04-445a-bc2a-7b8d7dee8198
Point{AbstractString}

# ╔═╡ 5d668a71-11e3-4fad-b9ce-7aabdc19b453
md"""
The type `Point{Float64}` is a point whose coordinates are 64-bit floating-point values, while the type `Point{AbstractString}` is a \"point\" whose \"coordinates\" are string objects (see [Strings](@ref)).
"""

# ╔═╡ abf771d4-1cb4-44ea-81ef-d32e46153ed7
md"""
`Point` itself is also a valid type object, containing all instances `Point{Float64}`, `Point{AbstractString}`, etc. as subtypes:
"""

# ╔═╡ 9f02c85e-27f8-4866-a6c7-30c6ac0f0ce6
Point{Float64} <: Point

# ╔═╡ 9e2cbc18-a09e-43fb-b12d-c09836c27db1
Point{AbstractString} <: Point

# ╔═╡ 2f859928-266e-4a16-b4c1-9e8685f5f8a1
md"""
Other types, of course, are not subtypes of it:
"""

# ╔═╡ 2eb66416-d7ed-4d34-b042-733e795e8de9
Float64 <: Point

# ╔═╡ b8e3df32-5ca5-41fe-af33-6924a34bffb4
AbstractString <: Point

# ╔═╡ 210e3207-fc9b-4d65-aada-f0f9569549fd
md"""
Concrete `Point` types with different values of `T` are never subtypes of each other:
"""

# ╔═╡ 1e6d3a0d-d928-4107-b08a-c467796360f1
Point{Float64} <: Point{Int64}

# ╔═╡ e74e343c-9cfb-48ea-8260-a9f08a8d6024
Point{Float64} <: Point{Real}

# ╔═╡ 1544180d-41f8-49e8-af6f-2d75dda72196
md"""
!!! warning
    This last point is *very* important: even though `Float64 <: Real` we **DO NOT** have `Point{Float64} <: Point{Real}`.
"""

# ╔═╡ 2533e11c-5613-4830-8401-796fb3bab04a
md"""
In other words, in the parlance of type theory, Julia's type parameters are *invariant*, rather than being [covariant (or even contravariant)](https://en.wikipedia.org/wiki/Covariance_and_contravariance_%28computer_science%29). This is for practical reasons: while any instance of `Point{Float64}` may conceptually be like an instance of `Point{Real}` as well, the two types have different representations in memory:
"""

# ╔═╡ d78c39c7-48f9-4de4-90f2-b7c04ced4d03
md"""
  * An instance of `Point{Float64}` can be represented compactly and efficiently as an immediate pair of 64-bit values;
  * An instance of `Point{Real}` must be able to hold any pair of instances of [`Real`](@ref). Since objects that are instances of `Real` can be of arbitrary size and structure, in practice an instance of `Point{Real}` must be represented as a pair of pointers to individually allocated `Real` objects.
"""

# ╔═╡ f1c48f61-9305-49e7-989c-8cc4154cbf2e
md"""
The efficiency gained by being able to store `Point{Float64}` objects with immediate values is magnified enormously in the case of arrays: an `Array{Float64}` can be stored as a contiguous memory block of 64-bit floating-point values, whereas an `Array{Real}` must be an array of pointers to individually allocated [`Real`](@ref) objects – which may well be [boxed](https://en.wikipedia.org/wiki/Object_type_%28object-oriented_programming%29#Boxing) 64-bit floating-point values, but also might be arbitrarily large, complex objects, which are declared to be implementations of the `Real` abstract type.
"""

# ╔═╡ 9ed12e4a-0fbf-4f8e-8254-f4f7254f8adc
md"""
Since `Point{Float64}` is not a subtype of `Point{Real}`, the following method can't be applied to arguments of type `Point{Float64}`:
"""

# ╔═╡ 6fc937e1-3395-4ec1-8f18-e813b7da6af2
md"""
```julia
function norm(p::Point{Real})
    sqrt(p.x^2 + p.y^2)
end
```
"""

# ╔═╡ fe92ff9f-488f-45fc-a581-5eadaa2bb37c
md"""
A correct way to define a method that accepts all arguments of type `Point{T}` where `T` is a subtype of [`Real`](@ref) is:
"""

# ╔═╡ 63987c5c-b85e-431c-9e37-73285382c0a0
md"""
```julia
function norm(p::Point{<:Real})
    sqrt(p.x^2 + p.y^2)
end
```
"""

# ╔═╡ 2d1986a2-fbab-46b1-b3f8-951604f99bc4
md"""
(Equivalently, one could define `function norm(p::Point{T} where T<:Real)` or `function norm(p::Point{T}) where T<:Real`; see [UnionAll Types](@ref).)
"""

# ╔═╡ c5d16e83-e0cc-4ceb-8aa3-dfe9ce39c6ad
md"""
More examples will be discussed later in [Methods](@ref).
"""

# ╔═╡ ca00736b-52dc-4c5a-ae67-58fb86f14519
md"""
How does one construct a `Point` object? It is possible to define custom constructors for composite types, which will be discussed in detail in [Constructors](@ref man-constructors), but in the absence of any special constructor declarations, there are two default ways of creating new composite objects, one in which the type parameters are explicitly given and the other in which they are implied by the arguments to the object constructor.
"""

# ╔═╡ e32b1789-2056-4d40-bd7d-f9a46a54e610
md"""
Since the type `Point{Float64}` is a concrete type equivalent to `Point` declared with [`Float64`](@ref) in place of `T`, it can be applied as a constructor accordingly:
"""

# ╔═╡ 7dbc3e7e-9ba8-4c97-8abf-fb2a2775c6ff
p = Point{Float64}(1.0, 2.0)

# ╔═╡ c02c7a47-c102-4f17-8228-7db375c04315
typeof(p)

# ╔═╡ 21c534c9-f9bb-485c-90cd-866f52fc9c3e
md"""
For the default constructor, exactly one argument must be supplied for each field:
"""

# ╔═╡ 848cfd94-150e-4875-b457-78a005c86dd1
Point{Float64}(1.0)

# ╔═╡ 2d7c2b73-324f-4cb9-920c-ac0991b854fe
Point{Float64}(1.0,2.0,3.0)

# ╔═╡ a1a51029-ea9c-4ca0-9d95-f3e9402c197e
md"""
Only one default constructor is generated for parametric types, since overriding it is not possible. This constructor accepts any arguments and converts them to the field types.
"""

# ╔═╡ 25c7137c-31e5-45f6-91f6-731f57119299
md"""
In many cases, it is redundant to provide the type of `Point` object one wants to construct, since the types of arguments to the constructor call already implicitly provide type information. For that reason, you can also apply `Point` itself as a constructor, provided that the implied value of the parameter type `T` is unambiguous:
"""

# ╔═╡ aae9039f-4dfb-4462-9348-ae28ec9b08af
p1 = Point(1.0,2.0)

# ╔═╡ 88c43dae-879e-4b97-8094-8a6803c5d243
typeof(p1)

# ╔═╡ 5051806f-7a8d-426d-a567-3d174051eebc
p2 = Point(1,2)

# ╔═╡ 4e4ef8e6-f37d-4f71-be63-2a79d8036edb
typeof(p2)

# ╔═╡ d0544dc6-789e-47ba-b662-17642b7c53c2
md"""
In the case of `Point`, the type of `T` is unambiguously implied if and only if the two arguments to `Point` have the same type. When this isn't the case, the constructor will fail with a [`MethodError`](@ref):
"""

# ╔═╡ c029b1e6-4de7-43d1-9e55-9be6a2cb5948
Point(1,2.5)

# ╔═╡ 3aab1ff6-cf1a-4f6f-93ba-e97fabf59279
md"""
Constructor methods to appropriately handle such mixed cases can be defined, but that will not be discussed until later on in [Constructors](@ref man-constructors).
"""

# ╔═╡ 5938176f-abbe-421e-a8a8-ea704ff32877
md"""
### Parametric Abstract Types
"""

# ╔═╡ d7a069a5-7a3d-49e7-b1f1-da55e654f01b
md"""
Parametric abstract type declarations declare a collection of abstract types, in much the same way:
"""

# ╔═╡ 2d932348-d976-4fa9-92ff-226dbfbb04f3
abstract type Pointy{T} end

# ╔═╡ 9844033c-8e82-42fd-9493-e088e6e7d231
md"""
With this declaration, `Pointy{T}` is a distinct abstract type for each type or integer value of `T`. As with parametric composite types, each such instance is a subtype of `Pointy`:
"""

# ╔═╡ 08050e0f-80d1-456c-a706-039f049ca276
Pointy{Int64} <: Pointy

# ╔═╡ e94e8ff4-7c87-415e-8b30-f896926a7649
Pointy{1} <: Pointy

# ╔═╡ b950a293-0bea-4479-ae32-1d2b17d4110d
md"""
Parametric abstract types are invariant, much as parametric composite types are:
"""

# ╔═╡ 5d3c3678-6625-401e-baf8-1b87c851cbdb
Pointy{Float64} <: Pointy{Real}

# ╔═╡ 3fe0b6d2-e542-4de1-a12c-823f038e79d8
Pointy{Real} <: Pointy{Float64}

# ╔═╡ 1fc141eb-a899-4d84-9fbd-4824ee14801b
md"""
The notation `Pointy{<:Real}` can be used to express the Julia analogue of a *covariant* type, while `Pointy{>:Int}` the analogue of a *contravariant* type, but technically these represent *sets* of types (see [UnionAll Types](@ref)).
"""

# ╔═╡ f06873c1-842a-4f6a-800d-4e7cf99030fd
Pointy{Float64} <: Pointy{<:Real}

# ╔═╡ e82714ef-3279-46fa-87b1-de902ec1d189
Pointy{Real} <: Pointy{>:Int}

# ╔═╡ 56a84682-8bd9-4e51-898e-62fb2bfbc71b
md"""
Much as plain old abstract types serve to create a useful hierarchy of types over concrete types, parametric abstract types serve the same purpose with respect to parametric composite types. We could, for example, have declared `Point{T}` to be a subtype of `Pointy{T}` as follows:
"""

# ╔═╡ 83b39758-547a-4b9d-a457-a80227c56a3f
struct Point{T} <: Pointy{T}
     x::T
     y::T
 end

# ╔═╡ 01783bcb-6daf-4255-854b-2283915a2127
md"""
Given such a declaration, for each choice of `T`, we have `Point{T}` as a subtype of `Pointy{T}`:
"""

# ╔═╡ 3d8874eb-42cb-455b-bda9-f082d6113c08
Point{Float64} <: Pointy{Float64}

# ╔═╡ dbbd90dc-faef-4e86-8d35-51f6a4c30095
Point{Real} <: Pointy{Real}

# ╔═╡ 132480b4-9de2-407b-9270-2d3d43788658
Point{AbstractString} <: Pointy{AbstractString}

# ╔═╡ 55cf4db4-4c65-4587-980e-4c491a3411ef
md"""
This relationship is also invariant:
"""

# ╔═╡ 7945529e-552b-440d-a6eb-1a6279aed529
Point{Float64} <: Pointy{Real}

# ╔═╡ 91dd0757-433d-4d37-b716-8b7eb220154a
Point{Float64} <: Pointy{<:Real}

# ╔═╡ 1db5ef92-de02-40dd-a410-aeca6766d11a
md"""
What purpose do parametric abstract types like `Pointy` serve? Consider if we create a point-like implementation that only requires a single coordinate because the point is on the diagonal line *x = y*:
"""

# ╔═╡ 35fe8ba9-a3b2-44a8-bbd0-961cdcab899c
struct DiagPoint{T} <: Pointy{T}
     x::T
 end

# ╔═╡ 5a977b55-ef1d-434f-80e6-98d8873ec2c7
md"""
Now both `Point{Float64}` and `DiagPoint{Float64}` are implementations of the `Pointy{Float64}` abstraction, and similarly for every other possible choice of type `T`. This allows programming to a common interface shared by all `Pointy` objects, implemented for both `Point` and `DiagPoint`. This cannot be fully demonstrated, however, until we have introduced methods and dispatch in the next section, [Methods](@ref).
"""

# ╔═╡ 1844f1e9-89e8-482b-8fee-1cd5831fd962
md"""
There are situations where it may not make sense for type parameters to range freely over all possible types. In such situations, one can constrain the range of `T` like so:
"""

# ╔═╡ 3cf946a5-fb79-4a0e-a1bd-c262d3296e18
abstract type Pointy{T<:Real} end

# ╔═╡ 91513206-0ecf-42d3-844b-1467b2c62f05
md"""
With such a declaration, it is acceptable to use any type that is a subtype of [`Real`](@ref) in place of `T`, but not types that are not subtypes of `Real`:
"""

# ╔═╡ 2d7c1a72-a84d-4bb8-9158-f988c1b72fa0
Pointy{Float64}

# ╔═╡ 8db64885-444b-476a-85cd-22b1860598bb
Pointy{Real}

# ╔═╡ 1c6dc0a4-8038-47b0-aa91-9043addd1c80
Pointy{AbstractString}

# ╔═╡ 14b1f39f-6581-46bd-b35c-5e91e28c35bb
Pointy{1}

# ╔═╡ 12bfabb5-5a63-4e9b-9cbc-e7e056a58d41
md"""
Type parameters for parametric composite types can be restricted in the same manner:
"""

# ╔═╡ 1697aba4-1a58-4e98-b5e4-b0265ab48611
md"""
```julia
struct Point{T<:Real} <: Pointy{T}
    x::T
    y::T
end
```
"""

# ╔═╡ 1b074b0b-d45e-4c24-a78c-55c24c4c0257
md"""
To give a real-world example of how all this parametric type machinery can be useful, here is the actual definition of Julia's [`Rational`](@ref) immutable type (except that we omit the constructor here for simplicity), representing an exact ratio of integers:
"""

# ╔═╡ c57d54ba-7b96-457e-ab56-9a64c2762412
md"""
```julia
struct Rational{T<:Integer} <: Real
    num::T
    den::T
end
```
"""

# ╔═╡ 05b2ce70-7932-4aa1-8bf6-ebaeec470121
md"""
It only makes sense to take ratios of integer values, so the parameter type `T` is restricted to being a subtype of [`Integer`](@ref), and a ratio of integers represents a value on the real number line, so any [`Rational`](@ref) is an instance of the [`Real`](@ref) abstraction.
"""

# ╔═╡ 9c203aed-15a7-4698-afef-da508aa4724b
md"""
### Tuple Types
"""

# ╔═╡ 03d7f9aa-4bac-40cd-b777-1e2628722fa7
md"""
Tuples are an abstraction of the arguments of a function – without the function itself. The salient aspects of a function's arguments are their order and their types. Therefore a tuple type is similar to a parameterized immutable type where each parameter is the type of one field. For example, a 2-element tuple type resembles the following immutable type:
"""

# ╔═╡ 701bbae9-290e-42fd-aae7-24684998909a
md"""
```julia
struct Tuple2{A,B}
    a::A
    b::B
end
```
"""

# ╔═╡ be4b596b-c8a8-4206-8e1f-0b4d02827ef7
md"""
However, there are three key differences:
"""

# ╔═╡ fb4724fe-9b88-4fdd-ab5b-a1a246221543
md"""
  * Tuple types may have any number of parameters.
  * Tuple types are *covariant* in their parameters: `Tuple{Int}` is a subtype of `Tuple{Any}`. Therefore `Tuple{Any}` is considered an abstract type, and tuple types are only concrete if their parameters are.
  * Tuples do not have field names; fields are only accessed by index.
"""

# ╔═╡ 2eae80be-4077-4e2d-b635-c3706f08f44e
md"""
Tuple values are written with parentheses and commas. When a tuple is constructed, an appropriate tuple type is generated on demand:
"""

# ╔═╡ f0ed79f0-6888-4725-858a-f81c5e925a7e
typeof((1,"foo",2.5))

# ╔═╡ 4fbf2b32-78d2-4905-bb71-e8f8ca23127e
md"""
Note the implications of covariance:
"""

# ╔═╡ b0b52407-afa1-49bd-8ded-bbb36796e4ff
Tuple{Int,AbstractString} <: Tuple{Real,Any}

# ╔═╡ 527d5581-9fbd-411d-89b1-c08e2fadc821
Tuple{Int,AbstractString} <: Tuple{Real,Real}

# ╔═╡ 962d9d09-306e-45b2-b422-cf5a8d952acb
Tuple{Int,AbstractString} <: Tuple{Real,}

# ╔═╡ 4869a84c-8f76-4f98-b887-8db03d46cbe9
md"""
Intuitively, this corresponds to the type of a function's arguments being a subtype of the function's signature (when the signature matches).
"""

# ╔═╡ 6a2a517b-bf79-4982-8ba3-f93d4ec530a0
md"""
### Vararg Tuple Types
"""

# ╔═╡ ab3bf29f-61a4-4ce2-8968-8d6196a7c347
md"""
The last parameter of a tuple type can be the special type [`Vararg`](@ref), which denotes any number of trailing elements:
"""

# ╔═╡ 79d16e33-ec23-46e8-8467-02d0c0a14002
mytupletype = Tuple{AbstractString,Vararg{Int}}

# ╔═╡ 0539da64-0437-40f0-a6e5-c6056333d1a4
isa(("1",), mytupletype)

# ╔═╡ dd753b67-0337-48b8-8741-8087357fa456
isa(("1",1), mytupletype)

# ╔═╡ 363597e2-7e18-4244-9492-feb944926c6b
isa(("1",1,2), mytupletype)

# ╔═╡ f0697eb5-dcbc-48c8-b80d-bbed2c449da3
isa(("1",1,2,3.0), mytupletype)

# ╔═╡ 5ee2534f-11e7-4938-a1d1-a0d989155ab5
md"""
Notice that `Vararg{T}` corresponds to zero or more elements of type `T`. Vararg tuple types are used to represent the arguments accepted by varargs methods (see [Varargs Functions](@ref)).
"""

# ╔═╡ e6d4f4fe-116a-4d0c-83cc-66871f241d7a
md"""
The type `Vararg{T,N}` corresponds to exactly `N` elements of type `T`.  `NTuple{N,T}` is a convenient alias for `Tuple{Vararg{T,N}}`, i.e. a tuple type containing exactly `N` elements of type `T`.
"""

# ╔═╡ 798966e4-3d90-494e-b405-b576c261bb3e
md"""
### Named Tuple Types
"""

# ╔═╡ 62d1cf20-31cf-4955-926a-e6c3a2af7182
md"""
Named tuples are instances of the [`NamedTuple`](@ref) type, which has two parameters: a tuple of symbols giving the field names, and a tuple type giving the field types.
"""

# ╔═╡ e65501d9-2ad1-4c3b-94b1-f632a5bd4c1a
typeof((a=1,b="hello"))

# ╔═╡ 27c8e91a-0a4a-4f70-bc09-03b77b100ad8
md"""
The [`@NamedTuple`](@ref) macro provides a more convenient `struct`-like syntax for declaring `NamedTuple` types via `key::Type` declarations, where an omitted `::Type` corresponds to `::Any`.
"""

# ╔═╡ 815e2ba3-43d2-440b-a12e-cf957b128e56
@NamedTuple{a::Int, b::String}

# ╔═╡ 5c31f04b-e5d8-48a0-9a61-2447f9bb0744
@NamedTuple begin
     a::Int
     b::String
 end

# ╔═╡ b5c956fc-2caf-4fcd-be8d-9f8f8433af0e
md"""
A `NamedTuple` type can be used as a constructor, accepting a single tuple argument. The constructed `NamedTuple` type can be either a concrete type, with both parameters specified, or a type that specifies only field names:
"""

# ╔═╡ 419839ac-3351-4808-9cf9-4c58a619f57e
@NamedTuple{a::Float32,b::String}((1,""))

# ╔═╡ 4b0f75bc-360f-42ca-9499-c52e23d36dbf
NamedTuple{(:a, :b)}((1,""))

# ╔═╡ 2b8fba14-24b0-41fc-acfe-380e02cb8f16
md"""
If field types are specified, the arguments are converted. Otherwise the types of the arguments are used directly.
"""

# ╔═╡ 099c9c9b-b8bd-497b-ad35-28596eb73276
md"""
### Parametric Primitive Types
"""

# ╔═╡ 43ce636b-1164-49e9-9cca-be39f1e5c1b0
md"""
Primitive types can also be declared parametrically. For example, pointers are represented as primitive types which would be declared in Julia like this:
"""

# ╔═╡ f898871d-5503-4cff-a904-62432eb9b6c8
md"""
```julia
# 32-bit system:
primitive type Ptr{T} 32 end

# 64-bit system:
primitive type Ptr{T} 64 end
```
"""

# ╔═╡ a1593bc8-4a47-4817-8a92-6ed91df6f2df
md"""
The slightly odd feature of these declarations as compared to typical parametric composite types, is that the type parameter `T` is not used in the definition of the type itself – it is just an abstract tag, essentially defining an entire family of types with identical structure, differentiated only by their type parameter. Thus, `Ptr{Float64}` and `Ptr{Int64}` are distinct types, even though they have identical representations. And of course, all specific pointer types are subtypes of the umbrella [`Ptr`](@ref) type:
"""

# ╔═╡ 484898e1-64ee-49cb-8563-82a6ba0f1daf
Ptr{Float64} <: Ptr

# ╔═╡ 4aa9e0b9-e1d2-42aa-9f88-309ccbf7988e
Ptr{Int64} <: Ptr

# ╔═╡ 4558cd48-2567-41d6-8f69-f8dce36aca99
md"""
## UnionAll Types
"""

# ╔═╡ 367e8d68-f7cb-4d95-bc67-175749da0ff3
md"""
We have said that a parametric type like `Ptr` acts as a supertype of all its instances (`Ptr{Int64}` etc.). How does this work? `Ptr` itself cannot be a normal data type, since without knowing the type of the referenced data the type clearly cannot be used for memory operations. The answer is that `Ptr` (or other parametric types like `Array`) is a different kind of type called a [`UnionAll`](@ref) type. Such a type expresses the *iterated union* of types for all values of some parameter.
"""

# ╔═╡ e98fb352-9139-4894-9229-8e1999236353
md"""
`UnionAll` types are usually written using the keyword `where`. For example `Ptr` could be more accurately written as `Ptr{T} where T`, meaning all values whose type is `Ptr{T}` for some value of `T`. In this context, the parameter `T` is also often called a \"type variable\" since it is like a variable that ranges over types. Each `where` introduces a single type variable, so these expressions are nested for types with multiple parameters, for example `Array{T,N} where N where T`.
"""

# ╔═╡ 51748cf7-8667-4734-abdf-2550c0ea214c
md"""
The type application syntax `A{B,C}` requires `A` to be a `UnionAll` type, and first substitutes `B` for the outermost type variable in `A`. The result is expected to be another `UnionAll` type, into which `C` is then substituted. So `A{B,C}` is equivalent to `A{B}{C}`. This explains why it is possible to partially instantiate a type, as in `Array{Float64}`: the first parameter value has been fixed, but the second still ranges over all possible values. Using explicit `where` syntax, any subset of parameters can be fixed. For example, the type of all 1-dimensional arrays can be written as `Array{T,1} where T`.
"""

# ╔═╡ 68d89eae-f667-4cda-a954-c4f42f845cb6
md"""
Type variables can be restricted with subtype relations. `Array{T} where T<:Integer` refers to all arrays whose element type is some kind of [`Integer`](@ref). The syntax `Array{<:Integer}` is a convenient shorthand for `Array{T} where T<:Integer`. Type variables can have both lower and upper bounds. `Array{T} where Int<:T<:Number` refers to all arrays of [`Number`](@ref)s that are able to contain `Int`s (since `T` must be at least as big as `Int`). The syntax `where T>:Int` also works to specify only the lower bound of a type variable, and `Array{>:Int}` is equivalent to `Array{T} where T>:Int`.
"""

# ╔═╡ 42b252e5-9773-460d-8e1c-8e9361e1f3f9
md"""
Since `where` expressions nest, type variable bounds can refer to outer type variables. For example `Tuple{T,Array{S}} where S<:AbstractArray{T} where T<:Real` refers to 2-tuples whose first element is some [`Real`](@ref), and whose second element is an `Array` of any kind of array whose element type contains the type of the first tuple element.
"""

# ╔═╡ 5b43c672-4857-4530-9d41-1814dd928bef
md"""
The `where` keyword itself can be nested inside a more complex declaration. For example, consider the two types created by the following declarations:
"""

# ╔═╡ 730391f2-3c6e-4dfe-9c4a-80bffb0909dd
const T1 = Array{Array{T,1} where T, 1}

# ╔═╡ 4d943dfc-655a-47c5-81d9-965975b662fd
const T2 = Array{Array{T, 1}, 1} where T

# ╔═╡ 17a00eb7-5da9-48e1-8d1f-ede91dfc466d
md"""
Type `T1` defines a 1-dimensional array of 1-dimensional arrays; each of the inner arrays consists of objects of the same type, but this type may vary from one inner array to the next. On the other hand, type `T2` defines a 1-dimensional array of 1-dimensional arrays all of whose inner arrays must have the same type.  Note that `T2` is an abstract type, e.g., `Array{Array{Int,1},1} <: T2`, whereas `T1` is a concrete type. As a consequence, `T1` can be constructed with a zero-argument constructor `a=T1()` but `T2` cannot.
"""

# ╔═╡ 4dee6671-fdd6-473b-a8d2-81709f2e3aa0
md"""
There is a convenient syntax for naming such types, similar to the short form of function definition syntax:
"""

# ╔═╡ 1d23f304-aba6-4387-8bcc-c1ff5da0d8c0
md"""
```julia
Vector{T} = Array{T, 1}
```
"""

# ╔═╡ 952e8e54-6512-4376-8ed5-8de7654812cd
md"""
This is equivalent to `const Vector = Array{T,1} where T`. Writing `Vector{Float64}` is equivalent to writing `Array{Float64,1}`, and the umbrella type `Vector` has as instances all `Array` objects where the second parameter – the number of array dimensions – is 1, regardless of what the element type is. In languages where parametric types must always be specified in full, this is not especially helpful, but in Julia, this allows one to write just `Vector` for the abstract type including all one-dimensional dense arrays of any element type.
"""

# ╔═╡ 51cdb98a-9ce2-4df8-a33f-16d34e16239d
md"""
## [Singleton types](@id man-singleton-types)
"""

# ╔═╡ 3277cfae-5431-4a6f-8c88-fbf3867d1f7d
md"""
Immutable composite types with no fields are called *singletons*. Formally, if
"""

# ╔═╡ a55586f5-7220-4d09-8735-039d3e22c4c4
md"""
1. `T` is an immutable composite type (i.e. defined with `struct`),
2. `a isa T && b isa T` implies `a === b`,
"""

# ╔═╡ 1fecc455-854e-47fe-869e-319da3b945c6
md"""
then `T` is a singleton type.[^2] [`Base.issingletontype`](@ref) can be used to check if a type is a singleton type. [Abstract types](@ref man-abstract-types) cannot be singleton types by construction.
"""

# ╔═╡ 9dbda9c2-72d9-4d29-b49f-1f0968444cb1
md"""
From the definition, it follows that there can be only one instance of such types:
"""

# ╔═╡ 5d49eaef-b5bf-4e05-b381-14bca8e31e7e
struct NoFields
 end

# ╔═╡ c4f85d53-1d6f-4497-99fc-ee0a2735e676
NoFields() === NoFields()

# ╔═╡ 50975d33-780a-48a2-aa29-426d2acb910f
Base.issingletontype(NoFields)

# ╔═╡ d6afcaf7-376b-4604-8dca-73471ecab538
md"""
The [`===`](@ref) function confirms that the constructed instances of `NoFields` are actually one and the same.
"""

# ╔═╡ b310cba2-6036-4ee7-b1fc-b65fcaa5ca63
md"""
Parametric types can be singleton types when the above condition holds. For example,
"""

# ╔═╡ 623deb06-4adb-47bc-80b4-7be424ae8da4
struct NoFieldsParam{T}
 end

# ╔═╡ 30559609-6ba1-47e7-8d46-7f2814cffb2b
Base.issingletontype(NoFieldsParam) # can't be a singleton type ...

# ╔═╡ 871c4161-8084-4659-b8de-32408e0f3017
NoFieldsParam{Int}() isa NoFieldsParam # ... because it has ...

# ╔═╡ 89c33bf4-0aeb-4d8e-a6a5-d533d471e54e
NoFieldsParam{Bool}() isa NoFieldsParam # ... multiple instances

# ╔═╡ 35259389-a563-4437-aa2f-81ca6242b5dd
Base.issingletontype(NoFieldsParam{Int}) # parametrized, it is a singleton

# ╔═╡ 6c0a6dd8-2ac9-4d27-a2ba-c33e74ab530a
NoFieldsParam{Int}() === NoFieldsParam{Int}()

# ╔═╡ b9f882d2-93c9-4b7b-9e74-fbd5ace09e9b
md"""
## [`Type{T}` type selectors](@id man-typet-type)
"""

# ╔═╡ 1ab45f50-7a64-4252-8c44-6a12a5d0824e
md"""
For each type `T`, `Type{T}` is an abstract parametric type whose only instance is the object `T`. Until we discuss [Parametric Methods](@ref) and [conversions](@ref conversion-and-promotion), it is difficult to explain the utility of this construct, but in short, it allows one to specialize function behavior on specific types as *values*. This is useful for writing methods (especially parametric ones) whose behavior depends on a type that is given as an explicit argument rather than implied by the type of one of its arguments.
"""

# ╔═╡ 724779b1-fed7-4e58-a725-487de3a3521f
md"""
Since the definition is a little difficult to parse, let's look at some examples:
"""

# ╔═╡ 662b2839-4e29-4061-ac95-1ce001700206
isa(Float64, Type{Float64})

# ╔═╡ 57798fec-cd44-40be-9483-c019659b9624
isa(Real, Type{Float64})

# ╔═╡ f112f4be-e4e4-4f5e-b0c6-83428f73f813
isa(Real, Type{Real})

# ╔═╡ 622bf9b1-c6f0-409e-aab3-56761f773e94
isa(Float64, Type{Real})

# ╔═╡ df8f16c9-a586-42d8-912d-cb0ef3499e71
md"""
In other words, [`isa(A, Type{B})`](@ref) is true if and only if `A` and `B` are the same object and that object is a type.
"""

# ╔═╡ efc88768-1f8b-4f44-8349-87afb12b0284
md"""
In particular, since parametric types are [invariant](@ref man-parametric-composite-types), we have
"""

# ╔═╡ 19ff26df-5d20-4d79-9b34-37c266d3569d
struct TypeParamExample{T}
     x::T
 end

# ╔═╡ 2cdb7a8f-d8ff-4b33-943b-8e15c453948b
TypeParamExample isa Type{TypeParamExample}

# ╔═╡ de112d26-abe1-4396-bcfd-53be2aaa3d73
TypeParamExample{Int} isa Type{TypeParamExample}

# ╔═╡ 62caeb28-a98e-454e-8b94-2e714329f1cd
TypeParamExample{Int} isa Type{TypeParamExample{Int}}

# ╔═╡ ce2a5f6b-e53d-41e4-84af-308de0a26b2a
md"""
Without the parameter, `Type` is simply an abstract type which has all type objects as its instances:
"""

# ╔═╡ 8e2f7061-f96d-4436-ad8d-84b686e81211
isa(Type{Float64}, Type)

# ╔═╡ cdbac6e4-6620-4072-9a79-bd22a47feb0d
isa(Float64, Type)

# ╔═╡ 061a5568-dd55-44e4-8290-e7c9ba7e85b6
isa(Real, Type)

# ╔═╡ 0ad2fe18-b2d3-4ca5-8957-f52197057725
md"""
Any object that is not a type is not an instance of `Type`:
"""

# ╔═╡ 8c0ed420-910a-41c0-8fd4-8d441f21081a
isa(1, Type)

# ╔═╡ 6b47fb8f-c080-4bfb-b788-804deefb9954
isa("foo", Type)

# ╔═╡ f2a5f6b9-f8f1-450f-98cd-e2f18aeeb217
md"""
While `Type` is part of Julia's type hierarchy like any other abstract parametric type, it is not commonly used outside method signatures except in some special cases. Another important use case for `Type` is sharpening field types which would otherwise be captured less precisely, e.g. as [`DataType`](@ref man-declared-types) in the example below where the default constuctor could lead to performance problems in code relying on the precise wrapped type (similarly to [abstract type parameters](@ref man-performance-abstract-container)).
"""

# ╔═╡ 9a134e64-47e3-4c38-8306-a83a4ddc073f
struct WrapType{T}
 value::T
 end

# ╔═╡ 6c9078c4-a934-43be-91f9-cbbbfcca8534
WrapType(Float64) # default constructor, note DataType

# ╔═╡ 1c3a1a2e-b51e-4857-92d0-1d08d2c1a296
WrapType(::Type{T}) where T = WrapType{Type{T}}(T)

# ╔═╡ 6cf9fe30-e0e1-441c-bf96-a96d4f62eea8
WrapType(Float64) # sharpened constructor, note more precise Type{Float64}

# ╔═╡ 1ef7ad74-1e52-4893-909f-21903d55c77f
md"""
## Type Aliases
"""

# ╔═╡ 65dc8c65-c16f-4395-a904-c846916266e8
md"""
Sometimes it is convenient to introduce a new name for an already expressible type. This can be done with a simple assignment statement. For example, `UInt` is aliased to either [`UInt32`](@ref) or [`UInt64`](@ref) as is appropriate for the size of pointers on the system:
"""

# ╔═╡ 7a91ef38-baa5-4870-ad57-0d77907c41a5
# 32-bit system:

# ╔═╡ 905b72c8-d545-4d33-8856-4171b1d2f6c6
UInt

# ╔═╡ 7904870a-f969-4630-aa2d-32d0b0054fd8
UInt

# ╔═╡ 115d86aa-db35-4aeb-a7f9-974118ceacdb
md"""
This is accomplished via the following code in `base/boot.jl`:
"""

# ╔═╡ b1d4786d-5809-462b-8cab-f4d4c1a09ea5
md"""
```julia
if Int === Int64
    const UInt = UInt64
else
    const UInt = UInt32
end
```
"""

# ╔═╡ 8e5c5e4c-b94d-4d20-8a3b-24533e4fd8e9
md"""
Of course, this depends on what `Int` is aliased to – but that is predefined to be the correct type – either [`Int32`](@ref) or [`Int64`](@ref).
"""

# ╔═╡ 812d2bbb-13cf-4056-a30b-64ffaa554e0f
md"""
(Note that unlike `Int`, `Float` does not exist as a type alias for a specific sized [`AbstractFloat`](@ref). Unlike with integer registers, where the size of `Int` reflects the size of a native pointer on that machine, the floating point register sizes are specified by the IEEE-754 standard.)
"""

# ╔═╡ af34e362-2092-4f45-a23f-aa09a5a99fff
md"""
## Operations on Types
"""

# ╔═╡ 3851833d-3e2b-4803-bff9-cd1a959b3c46
md"""
Since types in Julia are themselves objects, ordinary functions can operate on them. Some functions that are particularly useful for working with or exploring types have already been introduced, such as the `<:` operator, which indicates whether its left hand operand is a subtype of its right hand operand.
"""

# ╔═╡ 82b9f472-ec05-4e32-8ad1-51aeb286fd5b
md"""
The [`isa`](@ref) function tests if an object is of a given type and returns true or false:
"""

# ╔═╡ 0584a11c-eb0f-410f-9e0c-b6e27b68ddb7
isa(1, Int)

# ╔═╡ 7d160f92-fd52-4d7c-9227-c3eeafd30cd9
isa(1, AbstractFloat)

# ╔═╡ 24a01e28-afe7-4327-8d44-6291b3917ef8
md"""
The [`typeof`](@ref) function, already used throughout the manual in examples, returns the type of its argument. Since, as noted above, types are objects, they also have types, and we can ask what their types are:
"""

# ╔═╡ bbc3c985-8f9d-4ca6-8bd0-48152e837283
typeof(Rational{Int})

# ╔═╡ 2aed1f66-ef9a-4139-991f-132fa8a2500e
typeof(Union{Real,String})

# ╔═╡ ab090fb6-8365-4a87-9d4f-3670936c731e
md"""
What if we repeat the process? What is the type of a type of a type? As it happens, types are all composite values and thus all have a type of `DataType`:
"""

# ╔═╡ f134f226-f45a-4300-82cf-66c1ac7ad619
typeof(DataType)

# ╔═╡ 0bc0246c-3132-4eb4-96c0-6336cd8b46ee
typeof(Union)

# ╔═╡ 211ecb9e-50f1-407a-bf39-dcf2fcb6adab
md"""
`DataType` is its own type.
"""

# ╔═╡ e384a41e-1123-4e83-b444-e907a2e2353a
md"""
Another operation that applies to some types is [`supertype`](@ref), which reveals a type's supertype. Only declared types (`DataType`) have unambiguous supertypes:
"""

# ╔═╡ 6c74aa80-60af-4ac3-b58e-c12e2558846d
supertype(Float64)

# ╔═╡ 4f58395e-0dc4-4944-9693-cc5e2ef90b87
supertype(Number)

# ╔═╡ d256e109-af22-4b0d-b528-fea876c36458
supertype(AbstractString)

# ╔═╡ 1c42967c-eec1-4ca0-a877-6d3788db412f
supertype(Any)

# ╔═╡ 1538242f-f8c8-4221-99e4-e7541f865784
md"""
If you apply [`supertype`](@ref) to other type objects (or non-type objects), a [`MethodError`](@ref) is raised:
"""

# ╔═╡ 24367a0a-9e23-48c1-ad2d-092777ccae1a
supertype(Union{Float64,Int64})

# ╔═╡ da8e6401-c0a6-4565-ae6d-e9c6282783df
md"""
## [Custom pretty-printing](@id man-custom-pretty-printing)
"""

# ╔═╡ 49d2e54f-8c1f-46ed-b845-cfd1e221d77c
md"""
Often, one wants to customize how instances of a type are displayed.  This is accomplished by overloading the [`show`](@ref) function.  For example, suppose we define a type to represent complex numbers in polar form:
"""

# ╔═╡ 281c9a7c-c752-4159-8cb0-4cef356e9d51
struct Polar{T<:Real} <: Number
     r::T
     Θ::T
 end

# ╔═╡ 98ba2c6d-a426-40ec-9326-9b0d4223a9a5
Polar(r::Real,Θ::Real) = Polar(promote(r,Θ)...)

# ╔═╡ 69efb33b-4dce-4d96-af31-70f73ea309cf
md"""
Here, we've added a custom constructor function so that it can take arguments of different [`Real`](@ref) types and promote them to a common type (see [Constructors](@ref man-constructors) and [Conversion and Promotion](@ref conversion-and-promotion)). (Of course, we would have to define lots of other methods, too, to make it act like a [`Number`](@ref), e.g. `+`, `*`, `one`, `zero`, promotion rules and so on.) By default, instances of this type display rather simply, with information about the type name and the field values, as e.g. `Polar{Float64}(3.0,4.0)`.
"""

# ╔═╡ 737a541f-aa19-4884-97fa-c9254ef40243
md"""
If we want it to display instead as `3.0 * exp(4.0im)`, we would define the following method to print the object to a given output object `io` (representing a file, terminal, buffer, etcetera; see [Networking and Streams](@ref)):
"""

# ╔═╡ fe9977b3-9566-4f67-8e34-bfd7c4a0a775
Base.show(io::IO, z::Polar) = print(io, z.r, " * exp(", z.Θ, "im)")

# ╔═╡ 90951fb2-fd42-4575-bc27-21397a7af21b
md"""
More fine-grained control over display of `Polar` objects is possible. In particular, sometimes one wants both a verbose multi-line printing format, used for displaying a single object in the REPL and other interactive environments, and also a more compact single-line format used for [`print`](@ref) or for displaying the object as part of another object (e.g. in an array). Although by default the `show(io, z)` function is called in both cases, you can define a *different* multi-line format for displaying an object by overloading a three-argument form of `show` that takes the `text/plain` MIME type as its second argument (see [Multimedia I/O](@ref)), for example:
"""

# ╔═╡ 9547072f-1591-4954-adda-a7a1cdf5b072
Base.show(io::IO, ::MIME"text/plain", z::Polar{T}) where{T} =
     print(io, "Polar{$T} complex number:\n   ", z)

# ╔═╡ cb9afc62-6555-48fa-80d8-8a4777fb5473
md"""
(Note that `print(..., z)` here will call the 2-argument `show(io, z)` method.) This results in:
"""

# ╔═╡ 6c6150b3-7f86-4082-bc41-8cd6ff94845f
Polar(3, 4.0)

# ╔═╡ 2830e9d9-3a2f-4781-92f0-44549293372a
[Polar(3, 4.0), Polar(4.0,5.3)]

# ╔═╡ e20b3668-ed1a-4058-9341-ef23bfa340f1
md"""
where the single-line `show(io, z)` form is still used for an array of `Polar` values.   Technically, the REPL calls `display(z)` to display the result of executing a line, which defaults to `show(stdout, MIME(\"text/plain\"), z)`, which in turn defaults to `show(stdout, z)`, but you should *not* define new [`display`](@ref) methods unless you are defining a new multimedia display handler (see [Multimedia I/O](@ref)).
"""

# ╔═╡ ef88fefa-202d-4220-a596-a75c93ce56c4
md"""
Moreover, you can also define `show` methods for other MIME types in order to enable richer display (HTML, images, etcetera) of objects in environments that support this (e.g. IJulia).   For example, we can define formatted HTML display of `Polar` objects, with superscripts and italics, via:
"""

# ╔═╡ 6a13d38b-1bdf-4d6f-8043-5461a51cc3b8
Base.show(io::IO, ::MIME"text/html", z::Polar{T}) where {T} =
     println(io, "<code>Polar{$T}</code> complex number: ",
             z.r, " <i>e</i><sup>", z.Θ, " <i>i</i></sup>")

# ╔═╡ 835f18c3-2446-46d6-b579-6fa8999245ed
md"""
A `Polar` object will then display automatically using HTML in an environment that supports HTML display, but you can call `show` manually to get HTML output if you want:
"""

# ╔═╡ d93a6a58-183f-4b38-ab6f-fd1c91a98686
show(stdout, "text/html", Polar(3.0,4.0))

# ╔═╡ a943461d-26a5-4a46-bb32-c838cca5c125
md"""
```@raw html
<p>An HTML renderer would display this as: <code>Polar{Float64}</code> complex number: 3.0 <i>e</i><sup>4.0 <i>i</i></sup></p>
```
"""

# ╔═╡ b86cbb9a-e550-4f3f-86e3-2afaefe3a10f
md"""
As a rule of thumb, the single-line `show` method should print a valid Julia expression for creating the shown object.  When this `show` method contains infix operators, such as the multiplication operator (`*`) in our single-line `show` method for `Polar` above, it may not parse correctly when printed as part of another object.  To see this, consider the expression object (see [Program representation](@ref)) which takes the square of a specific instance of our `Polar` type:
"""

# ╔═╡ 6daf4ed6-75cb-43a6-a5a0-d4c3d93d79db
a = Polar(3, 4.0)

# ╔═╡ 0e7de41a-d1c0-484f-82df-a93152670971
print(:($a^2))

# ╔═╡ a7e4a1ae-9a9f-4d57-8110-fe4d8dee89e2
md"""
Because the operator `^` has higher precedence than `*` (see [Operator Precedence and Associativity](@ref)), this output does not faithfully represent the expression `a ^ 2` which should be equal to `(3.0 * exp(4.0im)) ^ 2`.  To solve this issue, we must make a custom method for `Base.show_unquoted(io::IO, z::Polar, indent::Int, precedence::Int)`, which is called internally by the expression object when printing:
"""

# ╔═╡ 9f66e8fb-8404-4186-8579-0c59769a265e
function Base.show_unquoted(io::IO, z::Polar, ::Int, precedence::Int)
     if Base.operator_precedence(:*) <= precedence
         print(io, "(")
         show(io, z)
         print(io, ")")
     else
         show(io, z)
     end
 end

# ╔═╡ e6c2c272-75f4-4737-a090-72b5fc2c0886
:($a^2)

# ╔═╡ 50a52952-de36-4a23-8cda-8158bb5dbed7
md"""
The method defined above adds parentheses around the call to `show` when the precedence of the calling operator is higher than or equal to the precedence of multiplication.  This check allows expressions which parse correctly without the parentheses (such as `:($a + 2)` and `:($a == 2)`) to omit them when printing:
"""

# ╔═╡ ae221acc-e41e-429e-b367-758f5816731d
:($a + 2)

# ╔═╡ db562624-e4e3-47fe-b25d-3ccb399c46c3
:($a == 2)

# ╔═╡ 590d5f9b-67a8-4c5d-bf4b-3486ea28be41
md"""
In some cases, it is useful to adjust the behavior of `show` methods depending on the context. This can be achieved via the [`IOContext`](@ref) type, which allows passing contextual properties together with a wrapped IO stream. For example, we can build a shorter representation in our `show` method when the `:compact` property is set to `true`, falling back to the long representation if the property is `false` or absent:
"""

# ╔═╡ 9778e871-61a6-4acd-b3da-618e23299763
function Base.show(io::IO, z::Polar)
     if get(io, :compact, false)
         print(io, z.r, "ℯ", z.Θ, "im")
     else
         print(io, z.r, " * exp(", z.Θ, "im)")
     end
 end

# ╔═╡ 190925c4-6868-49c0-a3e6-bed32db44891
md"""
This new compact representation will be used when the passed IO stream is an `IOContext` object with the `:compact` property set. In particular, this is the case when printing arrays with multiple columns (where horizontal space is limited):
"""

# ╔═╡ 33ffe0d4-5ea6-431f-96c9-e198dc654312
show(IOContext(stdout, :compact=>true), Polar(3, 4.0))

# ╔═╡ a3b26185-75f9-4b86-824b-99a7854e3ef4
[Polar(3, 4.0) Polar(4.0,5.3)]

# ╔═╡ 4cba7ab6-3e0e-4e9d-a155-890d475f1a3c
md"""
See the [`IOContext`](@ref) documentation for a list of common properties which can be used to adjust printing.
"""

# ╔═╡ 84471bad-d52e-4581-a158-f79b342f0515
md"""
## \"Value types\"
"""

# ╔═╡ 8b17bdcf-be14-448d-bb98-295a5c5d4941
md"""
In Julia, you can't dispatch on a *value* such as `true` or `false`. However, you can dispatch on parametric types, and Julia allows you to include \"plain bits\" values (Types, Symbols, Integers, floating-point numbers, tuples, etc.) as type parameters.  A common example is the dimensionality parameter in `Array{T,N}`, where `T` is a type (e.g., [`Float64`](@ref)) but `N` is just an `Int`.
"""

# ╔═╡ 00c17d59-173a-46e0-bce1-6e04f3a0ef8e
md"""
You can create your own custom types that take values as parameters, and use them to control dispatch of custom types. By way of illustration of this idea, let's introduce a parametric type, `Val{x}`, and a constructor `Val(x) = Val{x}()`, which serves as a customary way to exploit this technique for cases where you don't need a more elaborate hierarchy.
"""

# ╔═╡ 66e4fbaf-bcc0-48cc-a744-bb9e5ada7a6b
md"""
[`Val`](@ref) is defined as:
"""

# ╔═╡ 7922cb72-991f-4e56-8dd1-ad1886b1b7e2
struct Val{x}
 end

# ╔═╡ 6f8a7113-7598-4747-8227-5b60ed186cff
Val(x) = Val{x}()

# ╔═╡ 1447db31-2cb3-4a52-b03d-6ef3e278a154
md"""
There is no more to the implementation of `Val` than this.  Some functions in Julia's standard library accept `Val` instances as arguments, and you can also use it to write your own functions.  For example:
"""

# ╔═╡ 7302c056-e6fa-42f7-849a-61f3b966d1c3
firstlast(::Val{true}) = "First"

# ╔═╡ cf1f0b49-c225-438f-b362-2ed250acaf01
firstlast(::Val{false}) = "Last"

# ╔═╡ 368c850a-eaf6-42c8-b125-56ac1b735237
firstlast(Val(true))

# ╔═╡ c2a21f58-5dbc-4c87-aab1-80d6e1c3c20a
firstlast(Val(false))

# ╔═╡ 29f9abee-59a6-4f51-a16b-0a6cd0f0614c
md"""
For consistency across Julia, the call site should always pass a `Val` *instance* rather than using a *type*, i.e., use `foo(Val(:bar))` rather than `foo(Val{:bar})`.
"""

# ╔═╡ 5f034a1b-82ca-46c8-b13a-1f7705904a25
md"""
It's worth noting that it's extremely easy to mis-use parametric \"value\" types, including `Val`; in unfavorable cases, you can easily end up making the performance of your code much *worse*.  In particular, you would never want to write actual code as illustrated above.  For more information about the proper (and improper) uses of `Val`, please read [the more extensive discussion in the performance tips](@ref man-performance-value-type).
"""

# ╔═╡ 46ac9414-f63a-453b-a92e-bd6e029546b0
md"""
[^1]: \"Small\" is defined by the `MAX_UNION_SPLITTING` constant, which is currently set to 4.
"""

# ╔═╡ 11fb22a2-9757-4f0d-b859-1916fb826220
md"""
[^2]: A few popular languages have singleton types, including Haskell, Scala and Ruby.
"""

# ╔═╡ Cell order:
# ╟─fce4b478-0e4a-419a-bf1c-c2985de3f368
# ╟─dcb168bc-aa05-4534-a1da-04c39eae408e
# ╟─fae89ec1-b202-4d47-879a-22910b414840
# ╟─9c72038e-6af3-439b-830b-77fe8d08523b
# ╟─757b5d8b-e4a8-40b6-bedf-f3974e98f961
# ╟─ac0d81cb-f1e3-476d-b462-6bf887fd696d
# ╟─cf0ee90a-a4e0-4040-b438-0206503c73d2
# ╟─52c7d681-bccb-4b83-aa15-6a20394b58e0
# ╟─49ea8853-95d2-419e-a4f2-f0c8fd3f2acb
# ╟─dc222c41-e6be-4593-9803-e5c85f27d582
# ╟─df22e3af-c747-4de1-bbcd-ff89f05ab814
# ╠═2ab3887a-31bb-4350-b4e9-b0a82b2b021b
# ╠═ca1d7172-dd30-407d-9746-350b28402fda
# ╟─c5abd2de-812c-453c-90d2-b7e82adf45f4
# ╟─3d28ea19-598d-4697-a187-285f96f1bd30
# ╠═1ca0a196-bc00-45cc-93e2-ec05b5aafba6
# ╠═b3392876-5024-4b08-8671-bc9f02eeadc8
# ╠═5c42eefc-29f2-4cf4-9a17-052bc5bcc52e
# ╟─c882235f-3f62-4749-834c-ea7ed0848b1a
# ╟─09f3c65a-15c7-429b-a0d0-a11e87f581c4
# ╟─02b1a1f6-1205-40aa-bd97-2d05a781e07f
# ╟─bcbb40b2-b93e-45f4-bdb6-5bb2acd2b63b
# ╟─7b5bf1ad-dff1-487a-9382-4a1485dccfb4
# ╟─d264027b-5853-44ec-a703-e52674f8e649
# ╟─15a740c2-66b8-4af9-b5d0-89a07dc8ef57
# ╟─afd6f2fd-d5b8-4c15-8e2a-880d4ff25bdb
# ╟─8494156d-6666-4ebb-8f83-f751e409714f
# ╟─0ebc2b69-817e-4068-bc12-bbab5f51efc9
# ╟─f31bdf9a-8e17-41a6-bc49-496418d02b31
# ╟─579a5cd9-b814-4333-96ab-c4b8f89fabf9
# ╟─8ee40666-e889-4fce-b357-05b9a0a94a7b
# ╟─9ada773c-a26a-4b2b-91b4-d6629c63c2b9
# ╟─b8dd2c89-34ff-45c4-b8ec-93a0ee48d58a
# ╟─eab25a9b-3881-43cb-8c08-f5281ddb9bf9
# ╟─d7d8b132-d7f4-44cd-8575-f8a86088bd91
# ╟─99d82193-6fb8-47fd-ba3b-411d84f27f5e
# ╠═c850568f-bdfd-44d4-a540-a57ad6097697
# ╠═5c2be37a-a9c6-497c-8a6b-9cc032ef0dc2
# ╟─985ffaa1-51b3-4a30-bca8-ea7832a0b533
# ╟─ae75b271-52eb-4a39-be1f-087b554a39d8
# ╟─61371f4d-7620-4374-b57e-cde9835a239d
# ╟─509a546d-dc46-4d5e-b7d0-546c6b54f50b
# ╟─b9226004-1a54-4f23-93d7-a5a1ed8d1186
# ╟─fbed8119-2358-4fd3-bb20-9adaa72d0efc
# ╟─827bd762-0e7e-49fc-83f5-02c97de288a8
# ╟─c5438a58-b383-41b9-83fd-2a15e5ecddfe
# ╟─15a7058c-ae8a-4391-bf3c-15e08f80f1c4
# ╟─0f18f6a6-28e7-49e5-97b0-7b3ea51d0081
# ╟─1f333bfe-636b-4e46-8af3-87358101e50e
# ╟─3f8fce94-672b-4577-ac73-7b48b4623c31
# ╟─06260e78-788b-415d-a4b2-75c86459dcfe
# ╟─55be505d-a4c2-4ce0-ad6a-f573554a53d6
# ╟─7524d9d1-f26e-4da4-9648-12eecba6f50d
# ╟─10843ef5-27c1-44cf-98d5-89f5835530c0
# ╟─5002a185-00ab-46e4-af43-ad66f1c1ff2f
# ╟─1094f745-0ddc-41a2-b89d-bda3d7b0aab5
# ╟─ca1ec9a5-442d-4984-af22-02387fc25b19
# ╟─69afdbfb-21b4-425f-9f97-fb212863b697
# ╠═0b8c9887-26be-418d-bea8-d4b3375e9159
# ╟─2c661ef6-d69d-4662-8964-6e67743605f5
# ╟─13aee84d-fa7a-477d-ada5-1101e4799f8c
# ╠═dac5eb99-e1c2-4384-b130-683aa9a1ceda
# ╠═3d839ffd-307d-4a16-ba1c-7d7d8f6b3ebc
# ╟─c6ced6eb-c26a-4d1a-8b63-ddf625254110
# ╟─543ef7f0-d099-4bd3-bf7b-9ca32ffd3dca
# ╠═ab15244c-fdbb-4107-8a5f-530ec21c39fd
# ╟─c62bcc4b-f9ae-4793-b2dc-362989fb341a
# ╠═1f6e9810-6b89-42d5-94de-6fc2df985d87
# ╟─643371d4-645c-490c-b855-d013f4e0def6
# ╠═15a605f5-092e-4907-9e74-d1dfeccd75c7
# ╠═bcb87b6b-ffcf-4992-964a-96def1130af5
# ╠═19297ff7-f519-4e05-8c33-c503ded6b1dc
# ╟─76e0db05-3546-4725-ae93-21398252fed9
# ╟─2882cd84-8fa7-4493-927e-6ac956824207
# ╟─14258a49-8ffe-413f-b102-31c1169bd2cb
# ╟─e642c1b7-72d1-4288-83a4-fdb810174bd0
# ╟─225334ac-fccd-42fa-ab3e-c90e3c688085
# ╠═18d2f0fe-7410-4d4d-9e50-e115e8629810
# ╠═f19f0795-ab67-412b-a360-990fd3b7e2a1
# ╟─9bcb8cd9-1d93-4674-846b-db407676ba69
# ╟─944ad34c-5c8c-4b74-947e-7c8e92d42d46
# ╟─fbf50303-a8af-4095-81cb-d77b18138140
# ╠═c129d45a-ce8e-4549-86f3-3fc0c85c0bdb
# ╠═9898f29c-72d7-48a1-b008-bd3ccbb50e27
# ╠═1b625394-c5a2-421f-905c-f2eee489e2af
# ╠═c3eadcea-178d-4f59-84df-c6c420dd85c9
# ╟─68ecb770-9c51-4c36-8c88-d8b817d0e1c6
# ╟─5498491e-e37e-4f20-a1db-8c64ba5be6b5
# ╟─0ce69919-a13d-4195-8853-ef02bf73a099
# ╟─cacbdb1e-8059-4cd7-8d1e-312fe1390d8e
# ╟─c605c1e1-1b0d-4df6-a97b-f4ff4838b1e2
# ╟─4098fa47-0278-47fd-b9be-564b25aa5c8c
# ╟─3b70d863-9c25-4a7e-8fca-632fc9d152d5
# ╠═4d29f33e-354d-4eee-92fd-094c622b106b
# ╠═65f064db-81e1-4c70-890c-5f1f9ec98a13
# ╟─657b61ae-cbe1-4d9c-b2c8-90b65686e59e
# ╟─0a27e691-9fd5-42ee-852b-04f0536c34e9
# ╟─d7892ac4-a4df-4ced-8b22-a4ec7a0f87ed
# ╟─2424367d-f14c-41bf-af3e-c8a0d1003ac3
# ╠═d82ea975-762f-43ca-975e-6f1b7d9e9a99
# ╠═841d9207-27fc-4c45-8faa-12a5dc2e4ea2
# ╠═8ba8b7d0-b28b-4cd7-a23d-bbfcf479a9c4
# ╠═4da274de-c657-4708-bfca-068adfda4d58
# ╟─91f097d0-02c3-4870-8de8-fd453ceb716b
# ╟─0060ed4e-92ba-4f08-aecf-cf949e2c8d03
# ╟─c1b97921-ba59-4527-b66b-13915205f8a1
# ╟─12652c8d-2474-4feb-bd58-06687271cead
# ╟─f035bc33-0f78-4be5-953c-b91d8346032a
# ╟─a1062514-b408-4bba-acf3-4056a46032ab
# ╟─056b9b5a-cc46-44f1-a333-d377ebadc2d6
# ╠═9296bc08-6e85-40a9-9f55-414cb9dfcaed
# ╟─d877caf1-a8d6-479e-ad9b-f8d18f5ea86e
# ╠═d285cd41-836b-4af0-882b-117cdc001665
# ╠═caf5f34f-1e04-445a-bc2a-7b8d7dee8198
# ╟─5d668a71-11e3-4fad-b9ce-7aabdc19b453
# ╟─abf771d4-1cb4-44ea-81ef-d32e46153ed7
# ╠═9f02c85e-27f8-4866-a6c7-30c6ac0f0ce6
# ╠═9e2cbc18-a09e-43fb-b12d-c09836c27db1
# ╟─2f859928-266e-4a16-b4c1-9e8685f5f8a1
# ╠═2eb66416-d7ed-4d34-b042-733e795e8de9
# ╠═b8e3df32-5ca5-41fe-af33-6924a34bffb4
# ╟─210e3207-fc9b-4d65-aada-f0f9569549fd
# ╠═1e6d3a0d-d928-4107-b08a-c467796360f1
# ╠═e74e343c-9cfb-48ea-8260-a9f08a8d6024
# ╟─1544180d-41f8-49e8-af6f-2d75dda72196
# ╟─2533e11c-5613-4830-8401-796fb3bab04a
# ╟─d78c39c7-48f9-4de4-90f2-b7c04ced4d03
# ╟─f1c48f61-9305-49e7-989c-8cc4154cbf2e
# ╟─9ed12e4a-0fbf-4f8e-8254-f4f7254f8adc
# ╟─6fc937e1-3395-4ec1-8f18-e813b7da6af2
# ╟─fe92ff9f-488f-45fc-a581-5eadaa2bb37c
# ╟─63987c5c-b85e-431c-9e37-73285382c0a0
# ╟─2d1986a2-fbab-46b1-b3f8-951604f99bc4
# ╟─c5d16e83-e0cc-4ceb-8aa3-dfe9ce39c6ad
# ╟─ca00736b-52dc-4c5a-ae67-58fb86f14519
# ╟─e32b1789-2056-4d40-bd7d-f9a46a54e610
# ╠═7dbc3e7e-9ba8-4c97-8abf-fb2a2775c6ff
# ╠═c02c7a47-c102-4f17-8228-7db375c04315
# ╟─21c534c9-f9bb-485c-90cd-866f52fc9c3e
# ╠═848cfd94-150e-4875-b457-78a005c86dd1
# ╠═2d7c2b73-324f-4cb9-920c-ac0991b854fe
# ╟─a1a51029-ea9c-4ca0-9d95-f3e9402c197e
# ╟─25c7137c-31e5-45f6-91f6-731f57119299
# ╠═aae9039f-4dfb-4462-9348-ae28ec9b08af
# ╠═88c43dae-879e-4b97-8094-8a6803c5d243
# ╠═5051806f-7a8d-426d-a567-3d174051eebc
# ╠═4e4ef8e6-f37d-4f71-be63-2a79d8036edb
# ╟─d0544dc6-789e-47ba-b662-17642b7c53c2
# ╠═c029b1e6-4de7-43d1-9e55-9be6a2cb5948
# ╟─3aab1ff6-cf1a-4f6f-93ba-e97fabf59279
# ╟─5938176f-abbe-421e-a8a8-ea704ff32877
# ╟─d7a069a5-7a3d-49e7-b1f1-da55e654f01b
# ╠═2d932348-d976-4fa9-92ff-226dbfbb04f3
# ╟─9844033c-8e82-42fd-9493-e088e6e7d231
# ╠═08050e0f-80d1-456c-a706-039f049ca276
# ╠═e94e8ff4-7c87-415e-8b30-f896926a7649
# ╟─b950a293-0bea-4479-ae32-1d2b17d4110d
# ╠═5d3c3678-6625-401e-baf8-1b87c851cbdb
# ╠═3fe0b6d2-e542-4de1-a12c-823f038e79d8
# ╟─1fc141eb-a899-4d84-9fbd-4824ee14801b
# ╠═f06873c1-842a-4f6a-800d-4e7cf99030fd
# ╠═e82714ef-3279-46fa-87b1-de902ec1d189
# ╟─56a84682-8bd9-4e51-898e-62fb2bfbc71b
# ╠═83b39758-547a-4b9d-a457-a80227c56a3f
# ╟─01783bcb-6daf-4255-854b-2283915a2127
# ╠═3d8874eb-42cb-455b-bda9-f082d6113c08
# ╠═dbbd90dc-faef-4e86-8d35-51f6a4c30095
# ╠═132480b4-9de2-407b-9270-2d3d43788658
# ╟─55cf4db4-4c65-4587-980e-4c491a3411ef
# ╠═7945529e-552b-440d-a6eb-1a6279aed529
# ╠═91dd0757-433d-4d37-b716-8b7eb220154a
# ╟─1db5ef92-de02-40dd-a410-aeca6766d11a
# ╠═35fe8ba9-a3b2-44a8-bbd0-961cdcab899c
# ╟─5a977b55-ef1d-434f-80e6-98d8873ec2c7
# ╟─1844f1e9-89e8-482b-8fee-1cd5831fd962
# ╠═3cf946a5-fb79-4a0e-a1bd-c262d3296e18
# ╟─91513206-0ecf-42d3-844b-1467b2c62f05
# ╠═2d7c1a72-a84d-4bb8-9158-f988c1b72fa0
# ╠═8db64885-444b-476a-85cd-22b1860598bb
# ╠═1c6dc0a4-8038-47b0-aa91-9043addd1c80
# ╠═14b1f39f-6581-46bd-b35c-5e91e28c35bb
# ╟─12bfabb5-5a63-4e9b-9cbc-e7e056a58d41
# ╟─1697aba4-1a58-4e98-b5e4-b0265ab48611
# ╟─1b074b0b-d45e-4c24-a78c-55c24c4c0257
# ╟─c57d54ba-7b96-457e-ab56-9a64c2762412
# ╟─05b2ce70-7932-4aa1-8bf6-ebaeec470121
# ╟─9c203aed-15a7-4698-afef-da508aa4724b
# ╟─03d7f9aa-4bac-40cd-b777-1e2628722fa7
# ╟─701bbae9-290e-42fd-aae7-24684998909a
# ╟─be4b596b-c8a8-4206-8e1f-0b4d02827ef7
# ╟─fb4724fe-9b88-4fdd-ab5b-a1a246221543
# ╟─2eae80be-4077-4e2d-b635-c3706f08f44e
# ╠═f0ed79f0-6888-4725-858a-f81c5e925a7e
# ╟─4fbf2b32-78d2-4905-bb71-e8f8ca23127e
# ╠═b0b52407-afa1-49bd-8ded-bbb36796e4ff
# ╠═527d5581-9fbd-411d-89b1-c08e2fadc821
# ╠═962d9d09-306e-45b2-b422-cf5a8d952acb
# ╟─4869a84c-8f76-4f98-b887-8db03d46cbe9
# ╟─6a2a517b-bf79-4982-8ba3-f93d4ec530a0
# ╟─ab3bf29f-61a4-4ce2-8968-8d6196a7c347
# ╠═79d16e33-ec23-46e8-8467-02d0c0a14002
# ╠═0539da64-0437-40f0-a6e5-c6056333d1a4
# ╠═dd753b67-0337-48b8-8741-8087357fa456
# ╠═363597e2-7e18-4244-9492-feb944926c6b
# ╠═f0697eb5-dcbc-48c8-b80d-bbed2c449da3
# ╟─5ee2534f-11e7-4938-a1d1-a0d989155ab5
# ╟─e6d4f4fe-116a-4d0c-83cc-66871f241d7a
# ╟─798966e4-3d90-494e-b405-b576c261bb3e
# ╟─62d1cf20-31cf-4955-926a-e6c3a2af7182
# ╠═e65501d9-2ad1-4c3b-94b1-f632a5bd4c1a
# ╟─27c8e91a-0a4a-4f70-bc09-03b77b100ad8
# ╠═815e2ba3-43d2-440b-a12e-cf957b128e56
# ╠═5c31f04b-e5d8-48a0-9a61-2447f9bb0744
# ╟─b5c956fc-2caf-4fcd-be8d-9f8f8433af0e
# ╠═419839ac-3351-4808-9cf9-4c58a619f57e
# ╠═4b0f75bc-360f-42ca-9499-c52e23d36dbf
# ╟─2b8fba14-24b0-41fc-acfe-380e02cb8f16
# ╟─099c9c9b-b8bd-497b-ad35-28596eb73276
# ╟─43ce636b-1164-49e9-9cca-be39f1e5c1b0
# ╟─f898871d-5503-4cff-a904-62432eb9b6c8
# ╟─a1593bc8-4a47-4817-8a92-6ed91df6f2df
# ╠═484898e1-64ee-49cb-8563-82a6ba0f1daf
# ╠═4aa9e0b9-e1d2-42aa-9f88-309ccbf7988e
# ╟─4558cd48-2567-41d6-8f69-f8dce36aca99
# ╟─367e8d68-f7cb-4d95-bc67-175749da0ff3
# ╟─e98fb352-9139-4894-9229-8e1999236353
# ╟─51748cf7-8667-4734-abdf-2550c0ea214c
# ╟─68d89eae-f667-4cda-a954-c4f42f845cb6
# ╟─42b252e5-9773-460d-8e1c-8e9361e1f3f9
# ╟─5b43c672-4857-4530-9d41-1814dd928bef
# ╠═730391f2-3c6e-4dfe-9c4a-80bffb0909dd
# ╠═4d943dfc-655a-47c5-81d9-965975b662fd
# ╟─17a00eb7-5da9-48e1-8d1f-ede91dfc466d
# ╟─4dee6671-fdd6-473b-a8d2-81709f2e3aa0
# ╟─1d23f304-aba6-4387-8bcc-c1ff5da0d8c0
# ╟─952e8e54-6512-4376-8ed5-8de7654812cd
# ╟─51cdb98a-9ce2-4df8-a33f-16d34e16239d
# ╟─3277cfae-5431-4a6f-8c88-fbf3867d1f7d
# ╟─a55586f5-7220-4d09-8735-039d3e22c4c4
# ╟─1fecc455-854e-47fe-869e-319da3b945c6
# ╟─9dbda9c2-72d9-4d29-b49f-1f0968444cb1
# ╠═5d49eaef-b5bf-4e05-b381-14bca8e31e7e
# ╠═c4f85d53-1d6f-4497-99fc-ee0a2735e676
# ╠═50975d33-780a-48a2-aa29-426d2acb910f
# ╟─d6afcaf7-376b-4604-8dca-73471ecab538
# ╟─b310cba2-6036-4ee7-b1fc-b65fcaa5ca63
# ╠═623deb06-4adb-47bc-80b4-7be424ae8da4
# ╠═30559609-6ba1-47e7-8d46-7f2814cffb2b
# ╠═871c4161-8084-4659-b8de-32408e0f3017
# ╠═89c33bf4-0aeb-4d8e-a6a5-d533d471e54e
# ╠═35259389-a563-4437-aa2f-81ca6242b5dd
# ╠═6c0a6dd8-2ac9-4d27-a2ba-c33e74ab530a
# ╟─b9f882d2-93c9-4b7b-9e74-fbd5ace09e9b
# ╟─1ab45f50-7a64-4252-8c44-6a12a5d0824e
# ╟─724779b1-fed7-4e58-a725-487de3a3521f
# ╠═662b2839-4e29-4061-ac95-1ce001700206
# ╠═57798fec-cd44-40be-9483-c019659b9624
# ╠═f112f4be-e4e4-4f5e-b0c6-83428f73f813
# ╠═622bf9b1-c6f0-409e-aab3-56761f773e94
# ╟─df8f16c9-a586-42d8-912d-cb0ef3499e71
# ╟─efc88768-1f8b-4f44-8349-87afb12b0284
# ╠═19ff26df-5d20-4d79-9b34-37c266d3569d
# ╠═2cdb7a8f-d8ff-4b33-943b-8e15c453948b
# ╠═de112d26-abe1-4396-bcfd-53be2aaa3d73
# ╠═62caeb28-a98e-454e-8b94-2e714329f1cd
# ╟─ce2a5f6b-e53d-41e4-84af-308de0a26b2a
# ╠═8e2f7061-f96d-4436-ad8d-84b686e81211
# ╠═cdbac6e4-6620-4072-9a79-bd22a47feb0d
# ╠═061a5568-dd55-44e4-8290-e7c9ba7e85b6
# ╟─0ad2fe18-b2d3-4ca5-8957-f52197057725
# ╠═8c0ed420-910a-41c0-8fd4-8d441f21081a
# ╠═6b47fb8f-c080-4bfb-b788-804deefb9954
# ╟─f2a5f6b9-f8f1-450f-98cd-e2f18aeeb217
# ╠═9a134e64-47e3-4c38-8306-a83a4ddc073f
# ╠═6c9078c4-a934-43be-91f9-cbbbfcca8534
# ╠═1c3a1a2e-b51e-4857-92d0-1d08d2c1a296
# ╠═6cf9fe30-e0e1-441c-bf96-a96d4f62eea8
# ╟─1ef7ad74-1e52-4893-909f-21903d55c77f
# ╟─65dc8c65-c16f-4395-a904-c846916266e8
# ╠═7a91ef38-baa5-4870-ad57-0d77907c41a5
# ╠═905b72c8-d545-4d33-8856-4171b1d2f6c6
# ╠═7904870a-f969-4630-aa2d-32d0b0054fd8
# ╟─115d86aa-db35-4aeb-a7f9-974118ceacdb
# ╟─b1d4786d-5809-462b-8cab-f4d4c1a09ea5
# ╟─8e5c5e4c-b94d-4d20-8a3b-24533e4fd8e9
# ╟─812d2bbb-13cf-4056-a30b-64ffaa554e0f
# ╟─af34e362-2092-4f45-a23f-aa09a5a99fff
# ╟─3851833d-3e2b-4803-bff9-cd1a959b3c46
# ╟─82b9f472-ec05-4e32-8ad1-51aeb286fd5b
# ╠═0584a11c-eb0f-410f-9e0c-b6e27b68ddb7
# ╠═7d160f92-fd52-4d7c-9227-c3eeafd30cd9
# ╟─24a01e28-afe7-4327-8d44-6291b3917ef8
# ╠═bbc3c985-8f9d-4ca6-8bd0-48152e837283
# ╠═2aed1f66-ef9a-4139-991f-132fa8a2500e
# ╟─ab090fb6-8365-4a87-9d4f-3670936c731e
# ╠═f134f226-f45a-4300-82cf-66c1ac7ad619
# ╠═0bc0246c-3132-4eb4-96c0-6336cd8b46ee
# ╟─211ecb9e-50f1-407a-bf39-dcf2fcb6adab
# ╟─e384a41e-1123-4e83-b444-e907a2e2353a
# ╠═6c74aa80-60af-4ac3-b58e-c12e2558846d
# ╠═4f58395e-0dc4-4944-9693-cc5e2ef90b87
# ╠═d256e109-af22-4b0d-b528-fea876c36458
# ╠═1c42967c-eec1-4ca0-a877-6d3788db412f
# ╟─1538242f-f8c8-4221-99e4-e7541f865784
# ╠═24367a0a-9e23-48c1-ad2d-092777ccae1a
# ╟─da8e6401-c0a6-4565-ae6d-e9c6282783df
# ╟─49d2e54f-8c1f-46ed-b845-cfd1e221d77c
# ╠═281c9a7c-c752-4159-8cb0-4cef356e9d51
# ╠═98ba2c6d-a426-40ec-9326-9b0d4223a9a5
# ╟─69efb33b-4dce-4d96-af31-70f73ea309cf
# ╟─737a541f-aa19-4884-97fa-c9254ef40243
# ╠═fe9977b3-9566-4f67-8e34-bfd7c4a0a775
# ╟─90951fb2-fd42-4575-bc27-21397a7af21b
# ╠═9547072f-1591-4954-adda-a7a1cdf5b072
# ╟─cb9afc62-6555-48fa-80d8-8a4777fb5473
# ╠═6c6150b3-7f86-4082-bc41-8cd6ff94845f
# ╠═2830e9d9-3a2f-4781-92f0-44549293372a
# ╟─e20b3668-ed1a-4058-9341-ef23bfa340f1
# ╟─ef88fefa-202d-4220-a596-a75c93ce56c4
# ╠═6a13d38b-1bdf-4d6f-8043-5461a51cc3b8
# ╟─835f18c3-2446-46d6-b579-6fa8999245ed
# ╠═d93a6a58-183f-4b38-ab6f-fd1c91a98686
# ╟─a943461d-26a5-4a46-bb32-c838cca5c125
# ╟─b86cbb9a-e550-4f3f-86e3-2afaefe3a10f
# ╠═6daf4ed6-75cb-43a6-a5a0-d4c3d93d79db
# ╠═0e7de41a-d1c0-484f-82df-a93152670971
# ╟─a7e4a1ae-9a9f-4d57-8110-fe4d8dee89e2
# ╠═9f66e8fb-8404-4186-8579-0c59769a265e
# ╠═e6c2c272-75f4-4737-a090-72b5fc2c0886
# ╟─50a52952-de36-4a23-8cda-8158bb5dbed7
# ╠═ae221acc-e41e-429e-b367-758f5816731d
# ╠═db562624-e4e3-47fe-b25d-3ccb399c46c3
# ╟─590d5f9b-67a8-4c5d-bf4b-3486ea28be41
# ╠═9778e871-61a6-4acd-b3da-618e23299763
# ╟─190925c4-6868-49c0-a3e6-bed32db44891
# ╠═33ffe0d4-5ea6-431f-96c9-e198dc654312
# ╠═a3b26185-75f9-4b86-824b-99a7854e3ef4
# ╟─4cba7ab6-3e0e-4e9d-a155-890d475f1a3c
# ╟─84471bad-d52e-4581-a158-f79b342f0515
# ╟─8b17bdcf-be14-448d-bb98-295a5c5d4941
# ╟─00c17d59-173a-46e0-bce1-6e04f3a0ef8e
# ╟─66e4fbaf-bcc0-48cc-a744-bb9e5ada7a6b
# ╠═7922cb72-991f-4e56-8dd1-ad1886b1b7e2
# ╠═6f8a7113-7598-4747-8227-5b60ed186cff
# ╟─1447db31-2cb3-4a52-b03d-6ef3e278a154
# ╠═7302c056-e6fa-42f7-849a-61f3b966d1c3
# ╠═cf1f0b49-c225-438f-b362-2ed250acaf01
# ╠═368c850a-eaf6-42c8-b125-56ac1b735237
# ╠═c2a21f58-5dbc-4c87-aab1-80d6e1c3c20a
# ╟─29f9abee-59a6-4f51-a16b-0a6cd0f0614c
# ╟─5f034a1b-82ca-46c8-b13a-1f7705904a25
# ╟─46ac9414-f63a-453b-a92e-bd6e029546b0
# ╟─11fb22a2-9757-4f0d-b859-1916fb826220
