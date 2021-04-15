### A Pluto.jl notebook ###
# v0.14.2

using Markdown
using InteractiveUtils

# ╔═╡ 03d93210-9e19-11eb-304a-35b6b14a75c4
md"""
# [Types](@id man-types)
"""

# ╔═╡ 03d93268-9e19-11eb-20ca-75fbadfc14da
md"""
Type systems have traditionally fallen into two quite different camps: static type systems, where every program expression must have a type computable before the execution of the program, and dynamic type systems, where nothing is known about types until run time, when the actual values manipulated by the program are available. Object orientation allows some flexibility in statically typed languages by letting code be written without the precise types of values being known at compile time. The ability to write code that can operate on different types is called polymorphism. All code in classic dynamically typed languages is polymorphic: only by explicitly checking types, or when objects fail to support operations at run-time, are the types of any values ever restricted.
"""

# ╔═╡ 03d932a6-9e19-11eb-1c65-6581e5d4c7fe
md"""
Julia's type system is dynamic, but gains some of the advantages of static type systems by making it possible to indicate that certain values are of specific types. This can be of great assistance in generating efficient code, but even more significantly, it allows method dispatch on the types of function arguments to be deeply integrated with the language. Method dispatch is explored in detail in [Methods](@ref), but is rooted in the type system presented here.
"""

# ╔═╡ 03d932ba-9e19-11eb-2178-2d033f756982
md"""
The default behavior in Julia when types are omitted is to allow values to be of any type. Thus, one can write many useful Julia functions without ever explicitly using types. When additional expressiveness is needed, however, it is easy to gradually introduce explicit type annotations into previously "untyped" code. Adding annotations serves three primary purposes: to take advantage of Julia's powerful multiple-dispatch mechanism,  to improve human readability, and to catch programmer errors.
"""

# ╔═╡ 03d932ec-9e19-11eb-352d-2f5918caf88b
md"""
Describing Julia in the lingo of [type systems](https://en.wikipedia.org/wiki/Type_system), it is: dynamic, nominative and parametric. Generic types can be parameterized, and the hierarchical relationships between types are [explicitly declared](https://en.wikipedia.org/wiki/Nominal_type_system), rather than [implied by compatible structure](https://en.wikipedia.org/wiki/Structural_type_system). One particularly distinctive feature of Julia's type system is that concrete types may not subtype each other: all concrete types are final and may only have abstract types as their supertypes. While this might at first seem unduly restrictive, it has many beneficial consequences with surprisingly few drawbacks. It turns out that being able to inherit behavior is much more important than being able to inherit structure, and inheriting both causes significant difficulties in traditional object-oriented languages. Other high-level aspects of Julia's type system that should be mentioned up front are:
"""

# ╔═╡ 03d934ae-9e19-11eb-3921-45d2b37afc14
md"""
  * There is no division between object and non-object values: all values in Julia are true objects having a type that belongs to a single, fully connected type graph, all nodes of which are equally first-class as types.
  * There is no meaningful concept of a "compile-time type": the only type a value has is its actual type when the program is running. This is called a "run-time type" in object-oriented languages where the combination of static compilation with polymorphism makes this distinction significant.
  * Only values, not variables, have types – variables are simply names bound to values, although for simplicity we may say "type of a variable" as shorthand for "type of the value to which a variable refers".
  * Both abstract and concrete types can be parameterized by other types. They can also be parameterized by symbols, by values of any type for which [`isbits`](@ref) returns true (essentially, things like numbers and bools that are stored like C types or `struct`s with no pointers to other objects), and also by tuples thereof. Type parameters may be omitted when they do not need to be referenced or restricted.
"""

# ╔═╡ 03d934c2-9e19-11eb-0a68-35828ac768a4
md"""
Julia's type system is designed to be powerful and expressive, yet clear, intuitive and unobtrusive. Many Julia programmers may never feel the need to write code that explicitly uses types. Some kinds of programming, however, become clearer, simpler, faster and more robust with declared types.
"""

# ╔═╡ 03d934fe-9e19-11eb-3e3d-fd96c3bb64f7
md"""
## Type Declarations
"""

# ╔═╡ 03d9351c-9e19-11eb-39e3-63155f5b088e
md"""
The `::` operator can be used to attach type annotations to expressions and variables in programs. There are two primary reasons to do this:
"""

# ╔═╡ 03d9362a-9e19-11eb-080b-2b725eed9794
md"""
1. As an assertion to help confirm that your program works the way you expect,
2. To provide extra type information to the compiler, which can then improve performance in some cases
"""

# ╔═╡ 03d93652-9e19-11eb-204e-d3c385339699
md"""
When appended to an expression computing a value, the `::` operator is read as "is an instance of". It can be used anywhere to assert that the value of the expression on the left is an instance of the type on the right. When the type on the right is concrete, the value on the left must have that type as its implementation – recall that all concrete types are final, so no implementation is a subtype of any other. When the type is abstract, it suffices for the value to be implemented by a concrete type that is a subtype of the abstract type. If the type assertion is not true, an exception is thrown, otherwise, the left-hand value is returned:
"""

# ╔═╡ 03d93d50-9e19-11eb-39b5-575cb09b2958
(1+2)::AbstractFloat

# ╔═╡ 03d93d5a-9e19-11eb-2cbb-b770cabfb6a4
(1+2)::Int

# ╔═╡ 03d93d76-9e19-11eb-3f6d-8f984c654999
md"""
This allows a type assertion to be attached to any expression in-place.
"""

# ╔═╡ 03d93db4-9e19-11eb-11e7-7feb149795a5
md"""
When appended to a variable on the left-hand side of an assignment, or as part of a `local` declaration, the `::` operator means something a bit different: it declares the variable to always have the specified type, like a type declaration in a statically-typed language such as C. Every value assigned to the variable will be converted to the declared type using [`convert`](@ref):
"""

# ╔═╡ 03d9428c-9e19-11eb-16d7-c750a1980e77
function foo()
           x::Int8 = 100
           x
       end

# ╔═╡ 03d94296-9e19-11eb-26f6-7d8c427fe054
x = foo()

# ╔═╡ 03d94296-9e19-11eb-2356-490152f41655
typeof(x)

# ╔═╡ 03d942dc-9e19-11eb-1e14-9b7f8bc62174
md"""
This feature is useful for avoiding performance "gotchas" that could occur if one of the assignments to a variable changed its type unexpectedly.
"""

# ╔═╡ 03d942fa-9e19-11eb-112e-29891ede328f
md"""
This "declaration" behavior only occurs in specific contexts:
"""

# ╔═╡ 03d94340-9e19-11eb-100b-9bb7f66aab2d
md"""
```julia
local x::Int8  # in a local declaration
x::Int8 = 10   # as the left-hand side of an assignment
```
"""

# ╔═╡ 03d9435e-9e19-11eb-13e2-ed0f00d9c514
md"""
and applies to the whole current scope, even before the declaration. Currently, type declarations cannot be used in global scope, e.g. in the REPL, since Julia does not yet have constant-type globals.
"""

# ╔═╡ 03d94372-9e19-11eb-21cf-e9b7b971088a
md"""
Declarations can also be attached to function definitions:
"""

# ╔═╡ 03d94388-9e19-11eb-2f51-c383c65385b2
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

# ╔═╡ 03d943a4-9e19-11eb-1df4-ef230ee7819f
md"""
Returning from this function behaves just like an assignment to a variable with a declared type: the value is always converted to `Float64`.
"""

# ╔═╡ 03d943cc-9e19-11eb-0efe-d98a9ae4fe8e
md"""
## [Abstract Types](@id man-abstract-types)
"""

# ╔═╡ 03d943e8-9e19-11eb-04af-118857efb70a
md"""
Abstract types cannot be instantiated, and serve only as nodes in the type graph, thereby describing sets of related concrete types: those concrete types which are their descendants. We begin with abstract types even though they have no instantiation because they are the backbone of the type system: they form the conceptual hierarchy which makes Julia's type system more than just a collection of object implementations.
"""

# ╔═╡ 03d9449e-9e19-11eb-0e6a-25fc43113843
md"""
Recall that in [Integers and Floating-Point Numbers](@ref), we introduced a variety of concrete types of numeric values: [`Int8`](@ref), [`UInt8`](@ref), [`Int16`](@ref), [`UInt16`](@ref), [`Int32`](@ref), [`UInt32`](@ref), [`Int64`](@ref), [`UInt64`](@ref), [`Int128`](@ref), [`UInt128`](@ref), [`Float16`](@ref), [`Float32`](@ref), and [`Float64`](@ref). Although they have different representation sizes, `Int8`, `Int16`, `Int32`, `Int64` and `Int128` all have in common that they are signed integer types. Likewise `UInt8`, `UInt16`, `UInt32`, `UInt64` and `UInt128` are all unsigned integer types, while `Float16`, `Float32` and `Float64` are distinct in being floating-point types rather than integers. It is common for a piece of code to make sense, for example, only if its arguments are some kind of integer, but not really depend on what particular *kind* of integer. For example, the greatest common denominator algorithm works for all kinds of integers, but will not work for floating-point numbers. Abstract types allow the construction of a hierarchy of types, providing a context into which concrete types can fit. This allows you, for example, to easily program to any type that is an integer, without restricting an algorithm to a specific type of integer.
"""

# ╔═╡ 03d944be-9e19-11eb-34ef-954ed18861d6
md"""
Abstract types are declared using the [`abstract type`](@ref) keyword. The general syntaxes for declaring an abstract type are:
"""

# ╔═╡ 03d945de-9e19-11eb-24b3-35facf269cef
abstract type «

# ╔═╡ 03d94610-9e19-11eb-36ca-af669d7d3769
md"""
The `abstract type` keyword introduces a new abstract type, whose name is given by `«name»`. This name can be optionally followed by [`<:`](@ref) and an already-existing type, indicating that the newly declared abstract type is a subtype of this "parent" type.
"""

# ╔═╡ 03d94638-9e19-11eb-06bf-291df3b3eaef
md"""
When no supertype is given, the default supertype is `Any` – a predefined abstract type that all objects are instances of and all types are subtypes of. In type theory, `Any` is commonly called "top" because it is at the apex of the type graph. Julia also has a predefined abstract "bottom" type, at the nadir of the type graph, which is written as `Union{}`. It is the exact opposite of `Any`: no object is an instance of `Union{}` and all types are supertypes of `Union{}`.
"""

# ╔═╡ 03d9464c-9e19-11eb-2af8-156a6ce9b1fe
md"""
Let's consider some of the abstract types that make up Julia's numerical hierarchy:
"""

# ╔═╡ 03d9466a-9e19-11eb-0da1-8f047be7c3c3
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

# ╔═╡ 03d946b8-9e19-11eb-3b37-c9e119efe1d1
md"""
The [`Number`](@ref) type is a direct child type of `Any`, and [`Real`](@ref) is its child. In turn, `Real` has two children (it has more, but only two are shown here; we'll get to the others later): [`Integer`](@ref) and [`AbstractFloat`](@ref), separating the world into representations of integers and representations of real numbers. Representations of real numbers include, of course, floating-point types, but also include other types, such as rationals. Hence, `AbstractFloat` is a proper subtype of `Real`, including only floating-point representations of real numbers. Integers are further subdivided into [`Signed`](@ref) and [`Unsigned`](@ref) varieties.
"""

# ╔═╡ 03d946d8-9e19-11eb-1627-790818a85d08
md"""
The `<:` operator in general means "is a subtype of", and, used in declarations like this, declares the right-hand type to be an immediate supertype of the newly declared type. It can also be used in expressions as a subtype operator which returns `true` when its left operand is a subtype of its right operand:
"""

# ╔═╡ 03d948cc-9e19-11eb-10c6-3579f9b1ef0c
Integer <: Number

# ╔═╡ 03d948cc-9e19-11eb-216b-95d38957ea9e
Integer <: AbstractFloat

# ╔═╡ 03d948e0-9e19-11eb-3888-a34b58c39385
md"""
An important use of abstract types is to provide default implementations for concrete types. To give a simple example, consider:
"""

# ╔═╡ 03d94908-9e19-11eb-1442-95aebe334b4c
md"""
```julia
function myplus(x,y)
    x+y
end
```
"""

# ╔═╡ 03d94930-9e19-11eb-3615-d9aa1d43a9b0
md"""
The first thing to note is that the above argument declarations are equivalent to `x::Any` and `y::Any`. When this function is invoked, say as `myplus(2,5)`, the dispatcher chooses the most specific method named `myplus` that matches the given arguments. (See [Methods](@ref) for more information on multiple dispatch.)
"""

# ╔═╡ 03d9494e-9e19-11eb-30ea-d3720290bd01
md"""
Assuming no method more specific than the above is found, Julia next internally defines and compiles a method called `myplus` specifically for two `Int` arguments based on the generic function given above, i.e., it implicitly defines and compiles:
"""

# ╔═╡ 03d94962-9e19-11eb-20e4-81a0ccb6c593
md"""
```julia
function myplus(x::Int,y::Int)
    x+y
end
```
"""

# ╔═╡ 03d94976-9e19-11eb-12f4-6575b837598e
md"""
and finally, it invokes this specific method.
"""

# ╔═╡ 03d94994-9e19-11eb-3d95-db79bf3ee6a0
md"""
Thus, abstract types allow programmers to write generic functions that can later be used as the default method by many combinations of concrete types. Thanks to multiple dispatch, the programmer has full control over whether the default or more specific method is used.
"""

# ╔═╡ 03d949b2-9e19-11eb-33b1-2bb0f969460f
md"""
An important point to note is that there is no loss in performance if the programmer relies on a function whose arguments are abstract types, because it is recompiled for each tuple of argument concrete types with which it is invoked. (There may be a performance issue, however, in the case of function arguments that are containers of abstract types; see [Performance Tips](@ref man-performance-abstract-container).)
"""

# ╔═╡ 03d949c6-9e19-11eb-3985-fb7b66dba040
md"""
## Primitive Types
"""

# ╔═╡ 03d94a90-9e19-11eb-38cc-55db5c7502b4
md"""
!!! warning
    It is almost always preferable to wrap an existing primitive type in a new composite type than to define your own primitive type.

    This functionality exists to allow Julia to bootstrap the standard primitive types that LLVM supports. Once they are defined, there is very little reason to define more.
"""

# ╔═╡ 03d94aa2-9e19-11eb-1bdd-abca3cd4322a
md"""
A primitive type is a concrete type whose data consists of plain old bits. Classic examples of primitive types are integers and floating-point values. Unlike most languages, Julia lets you declare your own primitive types, rather than providing only a fixed set of built-in ones. In fact, the standard primitive types are all defined in the language itself:
"""

# ╔═╡ 03d94aca-9e19-11eb-2962-b7b0e9c4873e
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

# ╔═╡ 03d94ade-9e19-11eb-0660-7598f04f133d
md"""
The general syntaxes for declaring a primitive type are:
"""

# ╔═╡ 03d94b88-9e19-11eb-23c4-9ba617a2a8d3
primitive type «

# ╔═╡ 03d94bba-9e19-11eb-15ac-f54812b5130a
md"""
The number of bits indicates how much storage the type requires and the name gives the new type a name. A primitive type can optionally be declared to be a subtype of some supertype. If a supertype is omitted, then the type defaults to having `Any` as its immediate supertype. The declaration of [`Bool`](@ref) above therefore means that a boolean value takes eight bits to store, and has [`Integer`](@ref) as its immediate supertype. Currently, only sizes that are multiples of 8 bits are supported and you are likely to experience LLVM bugs with sizes other than those used above. Therefore, boolean values, although they really need just a single bit, cannot be declared to be any smaller than eight bits.
"""

# ╔═╡ 03d94c58-9e19-11eb-2123-dd998db5eba8
md"""
The types [`Bool`](@ref), [`Int8`](@ref) and [`UInt8`](@ref) all have identical representations: they are eight-bit chunks of memory. Since Julia's type system is nominative, however, they are not interchangeable despite having identical structure. A fundamental difference between them is that they have different supertypes: [`Bool`](@ref)'s direct supertype is [`Integer`](@ref), [`Int8`](@ref)'s is [`Signed`](@ref), and [`UInt8`](@ref)'s is [`Unsigned`](@ref). All other differences between [`Bool`](@ref), [`Int8`](@ref), and [`UInt8`](@ref) are matters of behavior – the way functions are defined to act when given objects of these types as arguments. This is why a nominative type system is necessary: if structure determined type, which in turn dictates behavior, then it would be impossible to make [`Bool`](@ref) behave any differently than [`Int8`](@ref) or [`UInt8`](@ref).
"""

# ╔═╡ 03d94c64-9e19-11eb-1157-a5bdd4c606a5
md"""
## Composite Types
"""

# ╔═╡ 03d94c8a-9e19-11eb-359b-9f84e78ed61e
md"""
[Composite types](https://en.wikipedia.org/wiki/Composite_data_type) are called records, structs, or objects in various languages. A composite type is a collection of named fields, an instance of which can be treated as a single value. In many languages, composite types are the only kind of user-definable type, and they are by far the most commonly used user-defined type in Julia as well.
"""

# ╔═╡ 03d94cbe-9e19-11eb-00c1-cb338e4c697a
md"""
In mainstream object oriented languages, such as C++, Java, Python and Ruby, composite types also have named functions associated with them, and the combination is called an "object". In purer object-oriented languages, such as Ruby or Smalltalk, all values are objects whether they are composites or not. In less pure object oriented languages, including C++ and Java, some values, such as integers and floating-point values, are not objects, while instances of user-defined composite types are true objects with associated methods. In Julia, all values are objects, but functions are not bundled with the objects they operate on. This is necessary since Julia chooses which method of a function to use by multiple dispatch, meaning that the types of *all* of a function's arguments are considered when selecting a method, rather than just the first one (see [Methods](@ref) for more information on methods and dispatch). Thus, it would be inappropriate for functions to "belong" to only their first argument. Organizing methods into function objects rather than having named bags of methods "inside" each object ends up being a highly beneficial aspect of the language design.
"""

# ╔═╡ 03d94cdc-9e19-11eb-3165-5f69aaf16c0c
md"""
Composite types are introduced with the [`struct`](@ref) keyword followed by a block of field names, optionally annotated with types using the `::` operator:
"""

# ╔═╡ 03d94fac-9e19-11eb-124d-37aa197e618a
struct Foo
           bar
           baz::Int
           qux::Float64
       end

# ╔═╡ 03d94fcc-9e19-11eb-3c84-e9137db21f11
md"""
Fields with no type annotation default to `Any`, and can accordingly hold any type of value.
"""

# ╔═╡ 03d94fe8-9e19-11eb-2634-e7c6b3750406
md"""
New objects of type `Foo` are created by applying the `Foo` type object like a function to values for its fields:
"""

# ╔═╡ 03d95358-9e19-11eb-27bb-75db79576764
foo = Foo("Hello, world.", 23, 1.5)

# ╔═╡ 03d95358-9e19-11eb-0a9c-35dcc386e370
typeof(foo)

# ╔═╡ 03d9539e-9e19-11eb-186c-29575b375165
md"""
When a type is applied like a function it is called a *constructor*. Two constructors are generated automatically (these are called *default constructors*). One accepts any arguments and calls [`convert`](@ref) to convert them to the types of the fields, and the other accepts arguments that match the field types exactly. The reason both of these are generated is that this makes it easier to add new definitions without inadvertently replacing a default constructor.
"""

# ╔═╡ 03d953b2-9e19-11eb-1030-272fcb6032b2
md"""
Since the `bar` field is unconstrained in type, any value will do. However, the value for `baz` must be convertible to `Int`:
"""

# ╔═╡ 03d9554c-9e19-11eb-156b-6d97184d7d4e
Foo((), 23.5, 1)

# ╔═╡ 03d95560-9e19-11eb-0330-4b7ea77753a2
md"""
You may find a list of field names using the [`fieldnames`](@ref) function.
"""

# ╔═╡ 03d9563c-9e19-11eb-2441-7dac38a708a2
fieldnames(Foo)

# ╔═╡ 03d9565a-9e19-11eb-0965-33c4e6b8f3ca
md"""
You can access the field values of a composite object using the traditional `foo.bar` notation:
"""

# ╔═╡ 03d95812-9e19-11eb-2718-15939b2b88f0
foo.bar

# ╔═╡ 03d9581c-9e19-11eb-33da-6bda30e6575e
foo.baz

# ╔═╡ 03d95844-9e19-11eb-2ee0-459297e307cb
foo.qux

# ╔═╡ 03d95862-9e19-11eb-2b32-17a747d80182
md"""
Composite objects declared with `struct` are *immutable*; they cannot be modified after construction. This may seem odd at first, but it has several advantages:
"""

# ╔═╡ 03d958da-9e19-11eb-252d-4522eca921ab
md"""
  * It can be more efficient. Some structs can be packed efficiently into arrays, and in some cases the compiler is able to avoid allocating immutable objects entirely.
  * It is not possible to violate the invariants provided by the type's constructors.
  * Code using immutable objects can be easier to reason about.
"""

# ╔═╡ 03d958ee-9e19-11eb-10dc-c12f5b3a672d
md"""
An immutable object might contain mutable objects, such as arrays, as fields. Those contained objects will remain mutable; only the fields of the immutable object itself cannot be changed to point to different objects.
"""

# ╔═╡ 03d9590c-9e19-11eb-0558-c5feeff3b1ac
md"""
Where required, mutable composite objects can be declared with the keyword [`mutable struct`](@ref), to be discussed in the next section.
"""

# ╔═╡ 03d95920-9e19-11eb-32de-7fefb85e061f
md"""
If all the fields of an immutable structure are indistinguishable (`===`) then two immutable values containing those fields are also indistinguishable:
"""

# ╔═╡ 03d95d26-9e19-11eb-10c3-796abaf3d9c2
struct X
           a::Int
           b::Float64
       end

# ╔═╡ 03d95d30-9e19-11eb-1203-9fe7410dabbb
X(1, 2) === X(1, 2)

# ╔═╡ 03d95d62-9e19-11eb-2e1c-439ae5fbc5b1
md"""
There is much more to say about how instances of composite types are created, but that discussion depends on both [Parametric Types](@ref) and on [Methods](@ref), and is sufficiently important to be addressed in its own section: [Constructors](@ref man-constructors).
"""

# ╔═╡ 03d95d78-9e19-11eb-1481-2d4a3c8362c4
md"""
## Mutable Composite Types
"""

# ╔═╡ 03d95d94-9e19-11eb-183e-4da897c7008d
md"""
If a composite type is declared with `mutable struct` instead of `struct`, then instances of it can be modified:
"""

# ╔═╡ 03d9667a-9e19-11eb-2424-9b2d04136b1f
mutable struct Bar
           baz
           qux::Float64
       end

# ╔═╡ 03d96686-9e19-11eb-234f-072d005b24ff
bar = Bar("Hello", 1.5);

# ╔═╡ 03d96690-9e19-11eb-0988-3d1641b3a67a
bar.qux = 2.0

# ╔═╡ 03d96690-9e19-11eb-05c8-8f7a076bdb81
bar.baz = 1//2

# ╔═╡ 03d966ec-9e19-11eb-2d12-4f1cacd812e6
md"""
In order to support mutation, such objects are generally allocated on the heap, and have stable memory addresses. A mutable object is like a little container that might hold different values over time, and so can only be reliably identified with its address. In contrast, an instance of an immutable type is associated with specific field values –- the field values alone tell you everything about the object. In deciding whether to make a type mutable, ask whether two instances with the same field values would be considered identical, or if they might need to change independently over time. If they would be considered identical, the type should probably be immutable.
"""

# ╔═╡ 03d966fe-9e19-11eb-2687-7b8f028123f8
md"""
To recap, two essential properties define immutability in Julia:
"""

# ╔═╡ 03d968c0-9e19-11eb-3672-5d9df7955e99
md"""
  * It is not permitted to modify the value of an immutable type.

      * For bits types this means that the bit pattern of a value once set will never change and that value is the identity of a bits type.
      * For composite  types, this means that the identity of the values of its fields will never change. When the fields are bits types, that means their bits will never change, for fields whose values are mutable types like arrays, that means the fields will always refer to the same mutable value even though that mutable value's content may itself be modified.
  * An object with an immutable type may be copied freely by the compiler since its immutability makes it impossible to programmatically distinguish between the original object and a copy.

      * In particular, this means that small enough immutable values like integers and floats are typically passed to functions in registers (or stack allocated).
      * Mutable values, on the other hand are heap-allocated and passed to functions as pointers to heap-allocated values except in cases where the compiler is sure that there's no way to tell that this is not what is happening.
"""

# ╔═╡ 03d968fc-9e19-11eb-1019-8192b90f2de6
md"""
## [Declared Types](@id man-declared-types)
"""

# ╔═╡ 03d96918-9e19-11eb-3378-e5a233928adf
md"""
The three kinds of types (abstract, primitive, composite) discussed in the previous sections are actually all closely related. They share the same key properties:
"""

# ╔═╡ 03d96992-9e19-11eb-09fb-bb3f960f05c0
md"""
  * They are explicitly declared.
  * They have names.
  * They have explicitly declared supertypes.
  * They may have parameters.
"""

# ╔═╡ 03d969b0-9e19-11eb-278a-e37ed24b57b1
md"""
Because of these shared properties, these types are internally represented as instances of the same concept, `DataType`, which is the type of any of these types:
"""

# ╔═╡ 03d96ba4-9e19-11eb-0e80-132b8e19c39a
typeof(Real)

# ╔═╡ 03d96ba4-9e19-11eb-39b4-91ff0de8f4b7
typeof(Int)

# ╔═╡ 03d96bcc-9e19-11eb-17bc-45bdd1b6d79f
md"""
A `DataType` may be abstract or concrete. If it is concrete, it has a specified size, storage layout, and (optionally) field names. Thus a primitive type is a `DataType` with nonzero size, but no field names. A composite type is a `DataType` that has field names or is empty (zero size).
"""

# ╔═╡ 03d96be8-9e19-11eb-3b62-ffe8375d5e19
md"""
Every concrete value in the system is an instance of some `DataType`.
"""

# ╔═╡ 03d96c1a-9e19-11eb-1719-a72b3639e71f
md"""
## Type Unions
"""

# ╔═╡ 03d96c3a-9e19-11eb-025d-0fd901dbec56
md"""
A type union is a special abstract type which includes as objects all instances of any of its argument types, constructed using the special [`Union`](@ref) keyword:
"""

# ╔═╡ 03d97068-9e19-11eb-14dd-67341fd6e2e9
IntOrString = Union{Int,AbstractString}

# ╔═╡ 03d97072-9e19-11eb-109c-8b0792323334
1 :: IntOrString

# ╔═╡ 03d97092-9e19-11eb-2ca3-33c16d26314e
"Hello!" :: IntOrString

# ╔═╡ 03d97092-9e19-11eb-2e56-c706b642212b
1.0 :: IntOrString

# ╔═╡ 03d970c4-9e19-11eb-2ddf-b116dba2327f
md"""
The compilers for many languages have an internal union construct for reasoning about types; Julia simply exposes it to the programmer. The Julia compiler is able to generate efficient code in the presence of `Union` types with a small number of types [^1], by generating specialized code in separate branches for each possible type.
"""

# ╔═╡ 03d97124-9e19-11eb-3e11-b998234fcc1a
md"""
A particularly useful case of a `Union` type is `Union{T, Nothing}`, where `T` can be any type and [`Nothing`](@ref) is the singleton type whose only instance is the object [`nothing`](@ref). This pattern is the Julia equivalent of [`Nullable`, `Option` or `Maybe`](https://en.wikipedia.org/wiki/Nullable_type) types in other languages. Declaring a function argument or a field as `Union{T, Nothing}` allows setting it either to a value of type `T`, or to `nothing` to indicate that there is no value. See [this FAQ entry](@ref faq-nothing) for more information.
"""

# ╔═╡ 03d97130-9e19-11eb-3ec2-2faf95aeee48
md"""
## Parametric Types
"""

# ╔═╡ 03d97156-9e19-11eb-0c1a-db84de374472
md"""
An important and powerful feature of Julia's type system is that it is parametric: types can take parameters, so that type declarations actually introduce a whole family of new types – one for each possible combination of parameter values. There are many languages that support some version of [generic programming](https://en.wikipedia.org/wiki/Generic_programming), wherein data structures and algorithms to manipulate them may be specified without specifying the exact types involved. For example, some form of generic programming exists in ML, Haskell, Ada, Eiffel, C++, Java, C#, F#, and Scala, just to name a few. Some of these languages support true parametric polymorphism (e.g. ML, Haskell, Scala), while others support ad-hoc, template-based styles of generic programming (e.g. C++, Java). With so many different varieties of generic programming and parametric types in various languages, we won't even attempt to compare Julia's parametric types to other languages, but will instead focus on explaining Julia's system in its own right. We will note, however, that because Julia is a dynamically typed language and doesn't need to make all type decisions at compile time, many traditional difficulties encountered in static parametric type systems can be relatively easily handled.
"""

# ╔═╡ 03d97176-9e19-11eb-2e1b-1f149a6b7b84
md"""
All declared types (the `DataType` variety) can be parameterized, with the same syntax in each case. We will discuss them in the following order: first, parametric composite types, then parametric abstract types, and finally parametric primitive types.
"""

# ╔═╡ 03d971bc-9e19-11eb-0089-2128a5ecf087
md"""
### [Parametric Composite Types](@id man-parametric-composite-types)
"""

# ╔═╡ 03d971d0-9e19-11eb-1e54-f904057bce0d
md"""
Type parameters are introduced immediately after the type name, surrounded by curly braces:
"""

# ╔═╡ 03d97450-9e19-11eb-21a6-097fba6517f0
struct Point{T}
           x::T
           y::T
       end

# ╔═╡ 03d974aa-9e19-11eb-0b64-41c10e13e640
md"""
This declaration defines a new parametric type, `Point{T}`, holding two "coordinates" of type `T`. What, one may ask, is `T`? Well, that's precisely the point of parametric types: it can be any type at all (or a value of any bits type, actually, although here it's clearly used as a type). `Point{Float64}` is a concrete type equivalent to the type defined by replacing `T` in the definition of `Point` with [`Float64`](@ref). Thus, this single declaration actually declares an unlimited number of types: `Point{Float64}`, `Point{AbstractString}`, `Point{Int64}`, etc. Each of these is now a usable concrete type:
"""

# ╔═╡ 03d976bc-9e19-11eb-1644-fb75c3e6b6d2
Point{Float64}

# ╔═╡ 03d976d0-9e19-11eb-136f-c35a3da0b27b
Point{AbstractString}

# ╔═╡ 03d97702-9e19-11eb-103e-3d22af9b235b
md"""
The type `Point{Float64}` is a point whose coordinates are 64-bit floating-point values, while the type `Point{AbstractString}` is a "point" whose "coordinates" are string objects (see [Strings](@ref)).
"""

# ╔═╡ 03d97734-9e19-11eb-2e08-e788e87858f3
md"""
`Point` itself is also a valid type object, containing all instances `Point{Float64}`, `Point{AbstractString}`, etc. as subtypes:
"""

# ╔═╡ 03d97aca-9e19-11eb-07e4-bd80a200d241
Point{Float64} <: Point

# ╔═╡ 03d97aca-9e19-11eb-2154-a51731b00c11
Point{AbstractString} <: Point

# ╔═╡ 03d97af4-9e19-11eb-1aad-bba7bd4d4f37
md"""
Other types, of course, are not subtypes of it:
"""

# ╔═╡ 03d97d74-9e19-11eb-3c6b-0949b65b88b9
Float64 <: Point

# ╔═╡ 03d97d74-9e19-11eb-2dae-114a9a69904a
AbstractString <: Point

# ╔═╡ 03d97d9a-9e19-11eb-2ce7-b5797a69a9e4
md"""
Concrete `Point` types with different values of `T` are never subtypes of each other:
"""

# ╔═╡ 03d9800a-9e19-11eb-3bec-eb8fb534b6c8
Point{Float64} <: Point{Int64}

# ╔═╡ 03d98026-9e19-11eb-1173-ffd376e90ac7
Point{Float64} <: Point{Real}

# ╔═╡ 03d980a8-9e19-11eb-21ab-a335065b08fe
md"""
!!! warning
    This last point is *very* important: even though `Float64 <: Real` we **DO NOT** have `Point{Float64} <: Point{Real}`.
"""

# ╔═╡ 03d980ee-9e19-11eb-145b-e54f2e60905b
md"""
In other words, in the parlance of type theory, Julia's type parameters are *invariant*, rather than being [covariant (or even contravariant)](https://en.wikipedia.org/wiki/Covariance_and_contravariance_%28computer_science%29). This is for practical reasons: while any instance of `Point{Float64}` may conceptually be like an instance of `Point{Real}` as well, the two types have different representations in memory:
"""

# ╔═╡ 03d98172-9e19-11eb-3c89-f5e9333fdde4
md"""
  * An instance of `Point{Float64}` can be represented compactly and efficiently as an immediate pair of 64-bit values;
  * An instance of `Point{Real}` must be able to hold any pair of instances of [`Real`](@ref). Since objects that are instances of `Real` can be of arbitrary size and structure, in practice an instance of `Point{Real}` must be represented as a pair of pointers to individually allocated `Real` objects.
"""

# ╔═╡ 03d981b6-9e19-11eb-160a-8bb6afff3f4a
md"""
The efficiency gained by being able to store `Point{Float64}` objects with immediate values is magnified enormously in the case of arrays: an `Array{Float64}` can be stored as a contiguous memory block of 64-bit floating-point values, whereas an `Array{Real}` must be an array of pointers to individually allocated [`Real`](@ref) objects – which may well be [boxed](https://en.wikipedia.org/wiki/Object_type_%28object-oriented_programming%29#Boxing) 64-bit floating-point values, but also might be arbitrarily large, complex objects, which are declared to be implementations of the `Real` abstract type.
"""

# ╔═╡ 03d981ca-9e19-11eb-2ed1-575e34cb6c04
md"""
Since `Point{Float64}` is not a subtype of `Point{Real}`, the following method can't be applied to arguments of type `Point{Float64}`:
"""

# ╔═╡ 03d981f2-9e19-11eb-3056-afa6dce3fc87
md"""
```julia
function norm(p::Point{Real})
    sqrt(p.x^2 + p.y^2)
end
```
"""

# ╔═╡ 03d9821a-9e19-11eb-25af-71bd6af6577a
md"""
A correct way to define a method that accepts all arguments of type `Point{T}` where `T` is a subtype of [`Real`](@ref) is:
"""

# ╔═╡ 03d98224-9e19-11eb-1490-874e082c5221
md"""
```julia
function norm(p::Point{<:Real})
    sqrt(p.x^2 + p.y^2)
end
```
"""

# ╔═╡ 03d98242-9e19-11eb-1218-f52ba7d15e43
md"""
(Equivalently, one could define `function norm(p::Point{T} where T<:Real)` or `function norm(p::Point{T}) where T<:Real`; see [UnionAll Types](@ref).)
"""

# ╔═╡ 03d98260-9e19-11eb-11c2-b34c54d1cc49
md"""
More examples will be discussed later in [Methods](@ref).
"""

# ╔═╡ 03d98276-9e19-11eb-3a8a-5b0a381cc695
md"""
How does one construct a `Point` object? It is possible to define custom constructors for composite types, which will be discussed in detail in [Constructors](@ref man-constructors), but in the absence of any special constructor declarations, there are two default ways of creating new composite objects, one in which the type parameters are explicitly given and the other in which they are implied by the arguments to the object constructor.
"""

# ╔═╡ 03d982a8-9e19-11eb-1292-a55080770ab8
md"""
Since the type `Point{Float64}` is a concrete type equivalent to `Point` declared with [`Float64`](@ref) in place of `T`, it can be applied as a constructor accordingly:
"""

# ╔═╡ 03d98546-9e19-11eb-00be-fddda6fbaa65
p = Point{Float64}(1.0, 2.0)

# ╔═╡ 03d9854e-9e19-11eb-20d5-6d5fa90a799b
typeof(p)

# ╔═╡ 03d98558-9e19-11eb-0a25-b1701245eee8
md"""
For the default constructor, exactly one argument must be supplied for each field:
"""

# ╔═╡ 03d98792-9e19-11eb-1afc-67f649882d68
Point{Float64}(1.0)

# ╔═╡ 03d9879c-9e19-11eb-1807-8feec5dfa315
Point{Float64}(1.0,2.0,3.0)

# ╔═╡ 03d987ba-9e19-11eb-3ba4-719b38431e05
md"""
Only one default constructor is generated for parametric types, since overriding it is not possible. This constructor accepts any arguments and converts them to the field types.
"""

# ╔═╡ 03d987d8-9e19-11eb-3c97-4b7a5468029a
md"""
In many cases, it is redundant to provide the type of `Point` object one wants to construct, since the types of arguments to the constructor call already implicitly provide type information. For that reason, you can also apply `Point` itself as a constructor, provided that the implied value of the parameter type `T` is unambiguous:
"""

# ╔═╡ 03d98bac-9e19-11eb-25e4-e5b3b0cd1db5
p1 = Point(1.0,2.0)

# ╔═╡ 03d98bc0-9e19-11eb-129d-77b1cfe5bfd4
typeof(p1)

# ╔═╡ 03d98bc0-9e19-11eb-2a1a-01d4ae710fce
p2 = Point(1,2)

# ╔═╡ 03d98bd4-9e19-11eb-2c30-db51dc75d0af
typeof(p2)

# ╔═╡ 03d98bfc-9e19-11eb-128b-39f2a5a8f997
md"""
In the case of `Point`, the type of `T` is unambiguously implied if and only if the two arguments to `Point` have the same type. When this isn't the case, the constructor will fail with a [`MethodError`](@ref):
"""

# ╔═╡ 03d98d14-9e19-11eb-33ab-49de284915c1
Point(1,2.5)

# ╔═╡ 03d98d28-9e19-11eb-2318-137330cf86a2
md"""
Constructor methods to appropriately handle such mixed cases can be defined, but that will not be discussed until later on in [Constructors](@ref man-constructors).
"""

# ╔═╡ 03d98d3c-9e19-11eb-2024-e10f061268c9
md"""
### Parametric Abstract Types
"""

# ╔═╡ 03d98d5a-9e19-11eb-3afe-8fee0d0ba882
md"""
Parametric abstract type declarations declare a collection of abstract types, in much the same way:
"""

# ╔═╡ 03d98e86-9e19-11eb-256b-ffc60acce5fd
abstract type Pointy{T} end

# ╔═╡ 03d98ea4-9e19-11eb-2af2-2389221fe0b4
md"""
With this declaration, `Pointy{T}` is a distinct abstract type for each type or integer value of `T`. As with parametric composite types, each such instance is a subtype of `Pointy`:
"""

# ╔═╡ 03d990a2-9e19-11eb-0227-47e8fce1d9e1
Pointy{Int64} <: Pointy

# ╔═╡ 03d990a2-9e19-11eb-31db-9560a0a9d916
Pointy{1} <: Pointy

# ╔═╡ 03d990ca-9e19-11eb-3c26-459aa4703ef0
md"""
Parametric abstract types are invariant, much as parametric composite types are:
"""

# ╔═╡ 03d992c8-9e19-11eb-0088-6f689a73364c
Pointy{Float64} <: Pointy{Real}

# ╔═╡ 03d992c8-9e19-11eb-1941-71657535cd25
Pointy{Real} <: Pointy{Float64}

# ╔═╡ 03d992fa-9e19-11eb-2d58-c5319f96f208
md"""
The notation `Pointy{<:Real}` can be used to express the Julia analogue of a *covariant* type, while `Pointy{>:Int}` the analogue of a *contravariant* type, but technically these represent *sets* of types (see [UnionAll Types](@ref)).
"""

# ╔═╡ 03d995ac-9e19-11eb-1e20-27df4bb9fe02
Pointy{Float64} <: Pointy{<:Real}

# ╔═╡ 03d995ac-9e19-11eb-0b67-35838d45d75a
Pointy{Real} <: Pointy{>:Int}

# ╔═╡ 03d995ca-9e19-11eb-2276-5348f842e538
md"""
Much as plain old abstract types serve to create a useful hierarchy of types over concrete types, parametric abstract types serve the same purpose with respect to parametric composite types. We could, for example, have declared `Point{T}` to be a subtype of `Pointy{T}` as follows:
"""

# ╔═╡ 03d99840-9e19-11eb-372a-cb57fc05e8eb
struct Point{T} <: Pointy{T}
           x::T
           y::T
       end

# ╔═╡ 03d99868-9e19-11eb-228b-c7dc6affabc7
md"""
Given such a declaration, for each choice of `T`, we have `Point{T}` as a subtype of `Pointy{T}`:
"""

# ╔═╡ 03d99b6a-9e19-11eb-0bc0-cbc7c3af964f
Point{Float64} <: Pointy{Float64}

# ╔═╡ 03d99b6a-9e19-11eb-126d-bba0c437dc75
Point{Real} <: Pointy{Real}

# ╔═╡ 03d99b74-9e19-11eb-2efc-1bd7c1e18396
Point{AbstractString} <: Pointy{AbstractString}

# ╔═╡ 03d99b88-9e19-11eb-1df7-f1e5b45ad0ce
md"""
This relationship is also invariant:
"""

# ╔═╡ 03d99dce-9e19-11eb-087f-dfdfbab5c97e
Point{Float64} <: Pointy{Real}

# ╔═╡ 03d99dd6-9e19-11eb-1b63-b3f8881d0ee9
Point{Float64} <: Pointy{<:Real}

# ╔═╡ 03d99df4-9e19-11eb-35f8-db8c5f745447
md"""
What purpose do parametric abstract types like `Pointy` serve? Consider if we create a point-like implementation that only requires a single coordinate because the point is on the diagonal line *x = y*:
"""

# ╔═╡ 03d99fe8-9e19-11eb-3de7-11e2ccd70a07
struct DiagPoint{T} <: Pointy{T}
           x::T
       end

# ╔═╡ 03d9a01a-9e19-11eb-1d9e-f992c22cd583
md"""
Now both `Point{Float64}` and `DiagPoint{Float64}` are implementations of the `Pointy{Float64}` abstraction, and similarly for every other possible choice of type `T`. This allows programming to a common interface shared by all `Pointy` objects, implemented for both `Point` and `DiagPoint`. This cannot be fully demonstrated, however, until we have introduced methods and dispatch in the next section, [Methods](@ref).
"""

# ╔═╡ 03d9a02c-9e19-11eb-36fc-7fdb54eacfa1
md"""
There are situations where it may not make sense for type parameters to range freely over all possible types. In such situations, one can constrain the range of `T` like so:
"""

# ╔═╡ 03d9a1aa-9e19-11eb-1529-8fe8926ff245
abstract type Pointy{T<:Real} end

# ╔═╡ 03d9a1f0-9e19-11eb-21ff-e54a36734e8e
md"""
With such a declaration, it is acceptable to use any type that is a subtype of [`Real`](@ref) in place of `T`, but not types that are not subtypes of `Real`:
"""

# ╔═╡ 03d9a448-9e19-11eb-0ca5-63f6e516f556
Pointy{Float64}

# ╔═╡ 03d9a448-9e19-11eb-260c-c591f69f64a4
Pointy{Real}

# ╔═╡ 03d9a452-9e19-11eb-2823-dd987502d91d
Pointy{AbstractString}

# ╔═╡ 03d9a466-9e19-11eb-2817-676753463862
Pointy{1}

# ╔═╡ 03d9a470-9e19-11eb-088f-25bb99be8364
md"""
Type parameters for parametric composite types can be restricted in the same manner:
"""

# ╔═╡ 03d9a48e-9e19-11eb-1c8e-e9317d8e56fd
md"""
```julia
struct Point{T<:Real} <: Pointy{T}
    x::T
    y::T
end
```
"""

# ╔═╡ 03d9a4ac-9e19-11eb-0bda-cb6825410386
md"""
To give a real-world example of how all this parametric type machinery can be useful, here is the actual definition of Julia's [`Rational`](@ref) immutable type (except that we omit the constructor here for simplicity), representing an exact ratio of integers:
"""

# ╔═╡ 03d9a4c0-9e19-11eb-3054-5faa1a4ec4f7
md"""
```julia
struct Rational{T<:Integer} <: Real
    num::T
    den::T
end
```
"""

# ╔═╡ 03d9a4e8-9e19-11eb-14f6-ff9676a57160
md"""
It only makes sense to take ratios of integer values, so the parameter type `T` is restricted to being a subtype of [`Integer`](@ref), and a ratio of integers represents a value on the real number line, so any [`Rational`](@ref) is an instance of the [`Real`](@ref) abstraction.
"""

# ╔═╡ 03d9a4fc-9e19-11eb-2cc3-e94edd9dcc15
md"""
### Tuple Types
"""

# ╔═╡ 03d9a524-9e19-11eb-2ba4-cd3e0bbd0522
md"""
Tuples are an abstraction of the arguments of a function – without the function itself. The salient aspects of a function's arguments are their order and their types. Therefore a tuple type is similar to a parameterized immutable type where each parameter is the type of one field. For example, a 2-element tuple type resembles the following immutable type:
"""

# ╔═╡ 03d9a536-9e19-11eb-1b50-8318fc35d4bd
md"""
```julia
struct Tuple2{A,B}
    a::A
    b::B
end
```
"""

# ╔═╡ 03d9a54c-9e19-11eb-25cd-2b15a3aa1665
md"""
However, there are three key differences:
"""

# ╔═╡ 03d9a5ec-9e19-11eb-25cc-c95076bfe5a1
md"""
  * Tuple types may have any number of parameters.
  * Tuple types are *covariant* in their parameters: `Tuple{Int}` is a subtype of `Tuple{Any}`. Therefore `Tuple{Any}` is considered an abstract type, and tuple types are only concrete if their parameters are.
  * Tuples do not have field names; fields are only accessed by index.
"""

# ╔═╡ 03d9a5f6-9e19-11eb-2c0a-1d6ce0f501ff
md"""
Tuple values are written with parentheses and commas. When a tuple is constructed, an appropriate tuple type is generated on demand:
"""

# ╔═╡ 03d9a826-9e19-11eb-3965-7594b550db83
typeof((1,"foo",2.5))

# ╔═╡ 03d9a830-9e19-11eb-2c3c-b3bb8a2b6ad4
md"""
Note the implications of covariance:
"""

# ╔═╡ 03d9abde-9e19-11eb-1221-ed51e0dc512f
Tuple{Int,AbstractString} <: Tuple{Real,Any}

# ╔═╡ 03d9abde-9e19-11eb-3325-19627b3b2308
Tuple{Int,AbstractString} <: Tuple{Real,Real}

# ╔═╡ 03d9abde-9e19-11eb-108f-23e171d916dc
Tuple{Int,AbstractString} <: Tuple{Real,}

# ╔═╡ 03d9abf0-9e19-11eb-38de-41ca4fd3920a
md"""
Intuitively, this corresponds to the type of a function's arguments being a subtype of the function's signature (when the signature matches).
"""

# ╔═╡ 03d9ac0c-9e19-11eb-1182-c529ba9d95d4
md"""
### Vararg Tuple Types
"""

# ╔═╡ 03d9ac2c-9e19-11eb-08a1-d7c291fb92da
md"""
The last parameter of a tuple type can be the special type [`Vararg`](@ref), which denotes any number of trailing elements:
"""

# ╔═╡ 03d9b474-9e19-11eb-30ae-9b1a53c66d6f
mytupletype = Tuple{AbstractString,Vararg{Int}}

# ╔═╡ 03d9b474-9e19-11eb-3f26-250eea819c8e
isa(("1",), mytupletype)

# ╔═╡ 03d9b4a6-9e19-11eb-3e3b-09660008ef48
isa(("1",1), mytupletype)

# ╔═╡ 03d9b4ba-9e19-11eb-3aed-f7e970b11056
isa(("1",1,2), mytupletype)

# ╔═╡ 03d9b4ba-9e19-11eb-1280-756a151b9e64
isa(("1",1,2,3.0), mytupletype)

# ╔═╡ 03d9b4e2-9e19-11eb-2883-05c709080d64
md"""
Notice that `Vararg{T}` corresponds to zero or more elements of type `T`. Vararg tuple types are used to represent the arguments accepted by varargs methods (see [Varargs Functions](@ref)).
"""

# ╔═╡ 03d9b546-9e19-11eb-1738-1b2116e77367
md"""
The type `Vararg{T,N}` corresponds to exactly `N` elements of type `T`.  `NTuple{N,T}` is a convenient alias for `Tuple{Vararg{T,N}}`, i.e. a tuple type containing exactly `N` elements of type `T`.
"""

# ╔═╡ 03d9b55a-9e19-11eb-160a-a599b3e85f4b
md"""
### Named Tuple Types
"""

# ╔═╡ 03d9b56e-9e19-11eb-0f40-cdee101d0bbc
md"""
Named tuples are instances of the [`NamedTuple`](@ref) type, which has two parameters: a tuple of symbols giving the field names, and a tuple type giving the field types.
"""

# ╔═╡ 03d9b870-9e19-11eb-0fe8-1563ad9f8dfe
typeof((a=1,b="hello"))

# ╔═╡ 03d9b8ac-9e19-11eb-12f0-e101c61cd883
md"""
The [`@NamedTuple`](@ref) macro provides a more convenient `struct`-like syntax for declaring `NamedTuple` types via `key::Type` declarations, where an omitted `::Type` corresponds to `::Any`.
"""

# ╔═╡ 03d9bca8-9e19-11eb-3c69-15f90f30287f
@NamedTuple{a::Int, b::String}

# ╔═╡ 03d9bca8-9e19-11eb-3044-6dca59491402
@NamedTuple begin
           a::Int
           b::String
       end

# ╔═╡ 03d9bcd0-9e19-11eb-3811-ed503fa1989d
md"""
A `NamedTuple` type can be used as a constructor, accepting a single tuple argument. The constructed `NamedTuple` type can be either a concrete type, with both parameters specified, or a type that specifies only field names:
"""

# ╔═╡ 03d9c252-9e19-11eb-22b4-c75234269862
@NamedTuple{a::Float32,b::String}((1,""))

# ╔═╡ 03d9c252-9e19-11eb-1e9a-517418b6b085
NamedTuple{(:a, :b)}((1,""))

# ╔═╡ 03d9c266-9e19-11eb-0fe2-1324de6bcf0c
md"""
If field types are specified, the arguments are converted. Otherwise the types of the arguments are used directly.
"""

# ╔═╡ 03d9c28e-9e19-11eb-1572-5dcb01a9374b
md"""
### Parametric Primitive Types
"""

# ╔═╡ 03d9c2a2-9e19-11eb-21eb-358997d50b49
md"""
Primitive types can also be declared parametrically. For example, pointers are represented as primitive types which would be declared in Julia like this:
"""

# ╔═╡ 03d9c2b6-9e19-11eb-0209-053cfa819330
md"""
```julia
# 32-bit system:
primitive type Ptr{T} 32 end

# 64-bit system:
primitive type Ptr{T} 64 end
```
"""

# ╔═╡ 03d9c2e8-9e19-11eb-04cc-6786a9026f7f
md"""
The slightly odd feature of these declarations as compared to typical parametric composite types, is that the type parameter `T` is not used in the definition of the type itself – it is just an abstract tag, essentially defining an entire family of types with identical structure, differentiated only by their type parameter. Thus, `Ptr{Float64}` and `Ptr{Int64}` are distinct types, even though they have identical representations. And of course, all specific pointer types are subtypes of the umbrella [`Ptr`](@ref) type:
"""

# ╔═╡ 03d9c52a-9e19-11eb-357e-f5e213dc9403
Ptr{Float64} <: Ptr

# ╔═╡ 03d9c540-9e19-11eb-2e88-9720a9f8f123
Ptr{Int64} <: Ptr

# ╔═╡ 03d9c55e-9e19-11eb-03f4-f54d1230a538
md"""
## UnionAll Types
"""

# ╔═╡ 03d9c590-9e19-11eb-0acb-6fbaa02390db
md"""
We have said that a parametric type like `Ptr` acts as a supertype of all its instances (`Ptr{Int64}` etc.). How does this work? `Ptr` itself cannot be a normal data type, since without knowing the type of the referenced data the type clearly cannot be used for memory operations. The answer is that `Ptr` (or other parametric types like `Array`) is a different kind of type called a [`UnionAll`](@ref) type. Such a type expresses the *iterated union* of types for all values of some parameter.
"""

# ╔═╡ 03d9c5c2-9e19-11eb-0d18-25c338cba835
md"""
`UnionAll` types are usually written using the keyword `where`. For example `Ptr` could be more accurately written as `Ptr{T} where T`, meaning all values whose type is `Ptr{T}` for some value of `T`. In this context, the parameter `T` is also often called a "type variable" since it is like a variable that ranges over types. Each `where` introduces a single type variable, so these expressions are nested for types with multiple parameters, for example `Array{T,N} where N where T`.
"""

# ╔═╡ 03d9c5f4-9e19-11eb-310e-dfb64182dfe9
md"""
The type application syntax `A{B,C}` requires `A` to be a `UnionAll` type, and first substitutes `B` for the outermost type variable in `A`. The result is expected to be another `UnionAll` type, into which `C` is then substituted. So `A{B,C}` is equivalent to `A{B}{C}`. This explains why it is possible to partially instantiate a type, as in `Array{Float64}`: the first parameter value has been fixed, but the second still ranges over all possible values. Using explicit `where` syntax, any subset of parameters can be fixed. For example, the type of all 1-dimensional arrays can be written as `Array{T,1} where T`.
"""

# ╔═╡ 03d9c62e-9e19-11eb-3871-5166c139a8fd
md"""
Type variables can be restricted with subtype relations. `Array{T} where T<:Integer` refers to all arrays whose element type is some kind of [`Integer`](@ref). The syntax `Array{<:Integer}` is a convenient shorthand for `Array{T} where T<:Integer`. Type variables can have both lower and upper bounds. `Array{T} where Int<:T<:Number` refers to all arrays of [`Number`](@ref)s that are able to contain `Int`s (since `T` must be at least as big as `Int`). The syntax `where T>:Int` also works to specify only the lower bound of a type variable, and `Array{>:Int}` is equivalent to `Array{T} where T>:Int`.
"""

# ╔═╡ 03d9c658-9e19-11eb-3023-11e69f4bfacb
md"""
Since `where` expressions nest, type variable bounds can refer to outer type variables. For example `Tuple{T,Array{S}} where S<:AbstractArray{T} where T<:Real` refers to 2-tuples whose first element is some [`Real`](@ref), and whose second element is an `Array` of any kind of array whose element type contains the type of the first tuple element.
"""

# ╔═╡ 03d9c66c-9e19-11eb-2906-2747bb614887
md"""
The `where` keyword itself can be nested inside a more complex declaration. For example, consider the two types created by the following declarations:
"""

# ╔═╡ 03d9cb6e-9e19-11eb-14ec-51511a5ec5cf
const T1 = Array{Array{T,1} where T, 1}

# ╔═╡ 03d9cb9c-9e19-11eb-290c-b7cd7a40a12d
const T2 = Array{Array{T, 1}, 1} where T

# ╔═╡ 03d9cbc6-9e19-11eb-0bc8-99a99282637b
md"""
Type `T1` defines a 1-dimensional array of 1-dimensional arrays; each of the inner arrays consists of objects of the same type, but this type may vary from one inner array to the next. On the other hand, type `T2` defines a 1-dimensional array of 1-dimensional arrays all of whose inner arrays must have the same type.  Note that `T2` is an abstract type, e.g., `Array{Array{Int,1},1} <: T2`, whereas `T1` is a concrete type. As a consequence, `T1` can be constructed with a zero-argument constructor `a=T1()` but `T2` cannot.
"""

# ╔═╡ 03d9cbe4-9e19-11eb-1bc2-d3288cca5841
md"""
There is a convenient syntax for naming such types, similar to the short form of function definition syntax:
"""

# ╔═╡ 03d9cbf8-9e19-11eb-1d1f-993a21e8f391
md"""
```julia
Vector{T} = Array{T, 1}
```
"""

# ╔═╡ 03d9cc2a-9e19-11eb-2f31-897222b54046
md"""
This is equivalent to `const Vector = Array{T,1} where T`. Writing `Vector{Float64}` is equivalent to writing `Array{Float64,1}`, and the umbrella type `Vector` has as instances all `Array` objects where the second parameter – the number of array dimensions – is 1, regardless of what the element type is. In languages where parametric types must always be specified in full, this is not especially helpful, but in Julia, this allows one to write just `Vector` for the abstract type including all one-dimensional dense arrays of any element type.
"""

# ╔═╡ 03d9cc3e-9e19-11eb-366d-494d218c0eec
md"""
## [Singleton types](@id man-singleton-types)
"""

# ╔═╡ 03d9cc52-9e19-11eb-3214-5d4c5a26383a
md"""
Immutable composite types with no fields are called *singletons*. Formally, if
"""

# ╔═╡ 03d9ccd6-9e19-11eb-08c0-33f6a534c5e4
md"""
1. `T` is an immutable composite type (i.e. defined with `struct`),
2. `a isa T && b isa T` implies `a === b`,
"""

# ╔═╡ 03d9cd04-9e19-11eb-3ae9-374f28f8e5fc
md"""
then `T` is a singleton type.[^2] [`Base.issingletontype`](@ref) can be used to check if a type is a singleton type. [Abstract types](@ref man-abstract-types) cannot be singleton types by construction.
"""

# ╔═╡ 03d9cd10-9e19-11eb-0a91-c70c5b6c8fbc
md"""
From the definition, it follows that there can be only one instance of such types:
"""

# ╔═╡ 03d9cff4-9e19-11eb-0ce4-fd9872997ea1
struct NoFields
       end

# ╔═╡ 03d9cffe-9e19-11eb-0552-c55431bbe2e3
NoFields() === NoFields()

# ╔═╡ 03d9d006-9e19-11eb-3ac1-41dbd2da2d83
Base.issingletontype(NoFields)

# ╔═╡ 03d9d026-9e19-11eb-287d-91b45d460a07
md"""
The [`===`](@ref) function confirms that the constructed instances of `NoFields` are actually one and the same.
"""

# ╔═╡ 03d9d044-9e19-11eb-3c4a-81dcca2566f8
md"""
Parametric types can be singleton types when the above condition holds. For example,
"""

# ╔═╡ 03d9d68e-9e19-11eb-1154-8f71a5a6f719
struct NoFieldsParam{T}
       end

# ╔═╡ 03d9d68e-9e19-11eb-08ea-838f937340df
Base.issingletontype(NoFieldsParam) # can't be a singleton type ...

# ╔═╡ 03d9d698-9e19-11eb-32b0-4737663476b1
NoFieldsParam{Int}() isa NoFieldsParam # ... because it has ...

# ╔═╡ 03d9d698-9e19-11eb-1295-e79c2ceccc14
NoFieldsParam{Bool}() isa NoFieldsParam # ... multiple instances

# ╔═╡ 03d9d6a2-9e19-11eb-00e2-01ca633a2805
Base.issingletontype(NoFieldsParam{Int}) # parametrized, it is a singleton

# ╔═╡ 03d9d6aa-9e19-11eb-058f-bb725b7609d1
NoFieldsParam{Int}() === NoFieldsParam{Int}()

# ╔═╡ 03d9d6ca-9e19-11eb-0a33-77067cce87c1
md"""
## [`Type{T}` type selectors](@id man-typet-type)
"""

# ╔═╡ 03d9d706-9e19-11eb-2a72-d5fe1fba3829
md"""
For each type `T`, `Type{T}` is an abstract parametric type whose only instance is the object `T`. Until we discuss [Parametric Methods](@ref) and [conversions](@ref conversion-and-promotion), it is difficult to explain the utility of this construct, but in short, it allows one to specialize function behavior on specific types as *values*. This is useful for writing methods (especially parametric ones) whose behavior depends on a type that is given as an explicit argument rather than implied by the type of one of its arguments.
"""

# ╔═╡ 03d9d724-9e19-11eb-3fca-9966c1d62c01
md"""
Since the definition is a little difficult to parse, let's look at some examples:
"""

# ╔═╡ 03d9daf8-9e19-11eb-2586-4dff74bd80a0
isa(Float64, Type{Float64})

# ╔═╡ 03d9db02-9e19-11eb-2162-77974f333d87
isa(Real, Type{Float64})

# ╔═╡ 03d9db02-9e19-11eb-355d-b1cd123a5402
isa(Real, Type{Real})

# ╔═╡ 03d9db14-9e19-11eb-3081-4de832a3a877
isa(Float64, Type{Real})

# ╔═╡ 03d9db3e-9e19-11eb-06ee-8fc96e23d4ed
md"""
In other words, [`isa(A, Type{B})`](@ref) is true if and only if `A` and `B` are the same object and that object is a type.
"""

# ╔═╡ 03d9db52-9e19-11eb-133a-dd71ceb4ce5e
md"""
In particular, since parametric types are [invariant](@ref man-parametric-composite-types), we have
"""

# ╔═╡ 03d9dfbe-9e19-11eb-0d17-1baae82e3f53
struct TypeParamExample{T}
           x::T
       end

# ╔═╡ 03d9dfd0-9e19-11eb-2184-9548f42b8764
TypeParamExample isa Type{TypeParamExample}

# ╔═╡ 03d9dfd0-9e19-11eb-1ebd-810c8f660b42
TypeParamExample{Int} isa Type{TypeParamExample}

# ╔═╡ 03d9dfda-9e19-11eb-20ec-6bfa2e1aa93b
TypeParamExample{Int} isa Type{TypeParamExample{Int}}

# ╔═╡ 03d9dff8-9e19-11eb-2c9b-39b5671c2725
md"""
Without the parameter, `Type` is simply an abstract type which has all type objects as its instances:
"""

# ╔═╡ 03d9e246-9e19-11eb-1822-fd209cf644f5
isa(Type{Float64}, Type)

# ╔═╡ 03d9e246-9e19-11eb-1fbd-19b18aca1486
isa(Float64, Type)

# ╔═╡ 03d9e250-9e19-11eb-2366-a36f6d80bf49
isa(Real, Type)

# ╔═╡ 03d9e264-9e19-11eb-39f1-e991dbdd4588
md"""
Any object that is not a type is not an instance of `Type`:
"""

# ╔═╡ 03d9e456-9e19-11eb-3932-1fb37cceffe3
isa(1, Type)

# ╔═╡ 03d9e456-9e19-11eb-2097-e7fe9b08704e
isa("foo", Type)

# ╔═╡ 03d9e488-9e19-11eb-1f39-2961bed26b30
md"""
While `Type` is part of Julia's type hierarchy like any other abstract parametric type, it is not commonly used outside method signatures except in some special cases. Another important use case for `Type` is sharpening field types which would otherwise be captured less precisely, e.g. as [`DataType`](@ref man-declared-types) in the example below where the default constuctor could lead to performance problems in code relying on the precise wrapped type (similarly to [abstract type parameters](@ref man-performance-abstract-container)).
"""

# ╔═╡ 03d9ea02-9e19-11eb-3381-79b1b855f2b2
struct WrapType{T}
       value::T
       end

# ╔═╡ 03d9ea0c-9e19-11eb-0744-75f713836a8b
WrapType(Float64) # default constructor, note DataType

# ╔═╡ 03d9ea28-9e19-11eb-0c9f-5105db0bca17
WrapType(::Type{T}) where T = WrapType{Type{T}}(T)

# ╔═╡ 03d9ea28-9e19-11eb-3370-959b7881c4a2
WrapType(Float64) # sharpened constructor, note more precise Type{Float64}

# ╔═╡ 03d9ea3e-9e19-11eb-3f65-a19c0da27a28
md"""
## Type Aliases
"""

# ╔═╡ 03d9ea66-9e19-11eb-36c2-9bfe3bad42b9
md"""
Sometimes it is convenient to introduce a new name for an already expressible type. This can be done with a simple assignment statement. For example, `UInt` is aliased to either [`UInt32`](@ref) or [`UInt64`](@ref) as is appropriate for the size of pointers on the system:
"""

# ╔═╡ 03d9eb9c-9e19-11eb-3557-8dd7c44ac675
# 32-bit system:

# ╔═╡ 03d9eb9c-9e19-11eb-25a0-775ff798c425
UInt

# ╔═╡ 03d9eba6-9e19-11eb-33d7-d36fee28e994
UInt

# ╔═╡ 03d9ebba-9e19-11eb-10cc-2184366ffeb4
md"""
This is accomplished via the following code in `base/boot.jl`:
"""

# ╔═╡ 03d9ebd8-9e19-11eb-20f5-2d96e0091143
md"""
```julia
if Int === Int64
    const UInt = UInt64
else
    const UInt = UInt32
end
```
"""

# ╔═╡ 03d9ebf6-9e19-11eb-0929-cb1384688459
md"""
Of course, this depends on what `Int` is aliased to – but that is predefined to be the correct type – either [`Int32`](@ref) or [`Int64`](@ref).
"""

# ╔═╡ 03d9ec1e-9e19-11eb-1701-37ccaa16c6f2
md"""
(Note that unlike `Int`, `Float` does not exist as a type alias for a specific sized [`AbstractFloat`](@ref). Unlike with integer registers, where the size of `Int` reflects the size of a native pointer on that machine, the floating point register sizes are specified by the IEEE-754 standard.)
"""

# ╔═╡ 03d9ec34-9e19-11eb-347f-7179bf164eab
md"""
## Operations on Types
"""

# ╔═╡ 03d9ec50-9e19-11eb-02a3-1d8983f02211
md"""
Since types in Julia are themselves objects, ordinary functions can operate on them. Some functions that are particularly useful for working with or exploring types have already been introduced, such as the `<:` operator, which indicates whether its left hand operand is a subtype of its right hand operand.
"""

# ╔═╡ 03d9ec6e-9e19-11eb-16ff-1d92b723464e
md"""
The [`isa`](@ref) function tests if an object is of a given type and returns true or false:
"""

# ╔═╡ 03d9ee2e-9e19-11eb-31a3-3dcd393870c4
isa(1, Int)

# ╔═╡ 03d9ee44-9e19-11eb-3f6e-1fce1a5dd523
isa(1, AbstractFloat)

# ╔═╡ 03d9ee60-9e19-11eb-1278-d986eb594580
md"""
The [`typeof`](@ref) function, already used throughout the manual in examples, returns the type of its argument. Since, as noted above, types are objects, they also have types, and we can ask what their types are:
"""

# ╔═╡ 03d9f056-9e19-11eb-00af-538dc9bde0df
typeof(Rational{Int})

# ╔═╡ 03d9f060-9e19-11eb-3916-b3f2a04982ee
typeof(Union{Real,String})

# ╔═╡ 03d9f088-9e19-11eb-20d8-1f56de343119
md"""
What if we repeat the process? What is the type of a type of a type? As it happens, types are all composite values and thus all have a type of `DataType`:
"""

# ╔═╡ 03d9f196-9e19-11eb-1f94-0f40c31cabca
typeof(DataType)

# ╔═╡ 03d9f1a2-9e19-11eb-00e4-11a65638bc68
typeof(Union)

# ╔═╡ 03d9f1b4-9e19-11eb-1fc5-d9336636241e
md"""
`DataType` is its own type.
"""

# ╔═╡ 03d9f1dc-9e19-11eb-3ebd-c70592d0a8a4
md"""
Another operation that applies to some types is [`supertype`](@ref), which reveals a type's supertype. Only declared types (`DataType`) have unambiguous supertypes:
"""

# ╔═╡ 03d9f40c-9e19-11eb-2026-83717228f926
supertype(Float64)

# ╔═╡ 03d9f416-9e19-11eb-35ea-3998adc23a45
supertype(Number)

# ╔═╡ 03d9f416-9e19-11eb-15a2-4397281ef30b
supertype(AbstractString)

# ╔═╡ 03d9f42a-9e19-11eb-0494-5b8d4e5d5938
supertype(Any)

# ╔═╡ 03d9f448-9e19-11eb-38dc-0b353845d61c
md"""
If you apply [`supertype`](@ref) to other type objects (or non-type objects), a [`MethodError`](@ref) is raised:
"""

# ╔═╡ 03d9f560-9e19-11eb-2846-b59393d05080
supertype(Union{Float64,Int64})

# ╔═╡ 03d9f574-9e19-11eb-1636-83838b55d0e5
md"""
## [Custom pretty-printing](@id man-custom-pretty-printing)
"""

# ╔═╡ 03d9f59c-9e19-11eb-0af3-f5ebe05c3283
md"""
Often, one wants to customize how instances of a type are displayed.  This is accomplished by overloading the [`show`](@ref) function.  For example, suppose we define a type to represent complex numbers in polar form:
"""

# ╔═╡ 03d9fb5a-9e19-11eb-3c70-ffcf63c78c3b
struct Polar{T<:Real} <: Number
           r::T
           Θ::T
       end

# ╔═╡ 03d9fb5a-9e19-11eb-0b56-2f84ba4f7b99
Polar(r::Real,Θ::Real) = Polar(promote(r,Θ)...)

# ╔═╡ 03d9fba0-9e19-11eb-0a9f-734174c885e6
md"""
Here, we've added a custom constructor function so that it can take arguments of different [`Real`](@ref) types and promote them to a common type (see [Constructors](@ref man-constructors) and [Conversion and Promotion](@ref conversion-and-promotion)). (Of course, we would have to define lots of other methods, too, to make it act like a [`Number`](@ref), e.g. `+`, `*`, `one`, `zero`, promotion rules and so on.) By default, instances of this type display rather simply, with information about the type name and the field values, as e.g. `Polar{Float64}(3.0,4.0)`.
"""

# ╔═╡ 03d9fbd2-9e19-11eb-0f1a-573e35834971
md"""
If we want it to display instead as `3.0 * exp(4.0im)`, we would define the following method to print the object to a given output object `io` (representing a file, terminal, buffer, etcetera; see [Networking and Streams](@ref)):
"""

# ╔═╡ 03d9ffce-9e19-11eb-19b2-f7ae04983241
Base.show(io::IO, z::Polar) = print(io, z.r, " * exp(", z.Θ, "im)")

# ╔═╡ 03da0000-9e19-11eb-07da-83b9e5118b64
md"""
More fine-grained control over display of `Polar` objects is possible. In particular, sometimes one wants both a verbose multi-line printing format, used for displaying a single object in the REPL and other interactive environments, and also a more compact single-line format used for [`print`](@ref) or for displaying the object as part of another object (e.g. in an array). Although by default the `show(io, z)` function is called in both cases, you can define a *different* multi-line format for displaying an object by overloading a three-argument form of `show` that takes the `text/plain` MIME type as its second argument (see [Multimedia I/O](@ref)), for example:
"""

# ╔═╡ 03da049c-9e19-11eb-19a5-5fea1677451e
Base.show(io::IO, ::MIME"text/plain", z::Polar{T}) where{T} =
           print(io, "Polar{$T} complex number:\n   ", z)

# ╔═╡ 03da04bc-9e19-11eb-0fb5-0bacc8cc2ef3
md"""
(Note that `print(..., z)` here will call the 2-argument `show(io, z)` method.) This results in:
"""

# ╔═╡ 03da0834-9e19-11eb-3b55-e730627a90d8
Polar(3, 4.0)

# ╔═╡ 03da0834-9e19-11eb-39d3-0994ccd03217
[Polar(3, 4.0), Polar(4.0,5.3)]

# ╔═╡ 03da0884-9e19-11eb-15cf-c7c5da9ae40a
md"""
where the single-line `show(io, z)` form is still used for an array of `Polar` values.   Technically, the REPL calls `display(z)` to display the result of executing a line, which defaults to `show(stdout, MIME("text/plain"), z)`, which in turn defaults to `show(stdout, z)`, but you should *not* define new [`display`](@ref) methods unless you are defining a new multimedia display handler (see [Multimedia I/O](@ref)).
"""

# ╔═╡ 03da08b6-9e19-11eb-1c33-a1d90a104b8e
md"""
Moreover, you can also define `show` methods for other MIME types in order to enable richer display (HTML, images, etcetera) of objects in environments that support this (e.g. IJulia).   For example, we can define formatted HTML display of `Polar` objects, with superscripts and italics, via:
"""

# ╔═╡ 03da0f0a-9e19-11eb-15fc-a9546498cc5d
Base.show(io::IO, ::MIME"text/html", z::Polar{T}) where {T} =
           println(io, "<code>Polar{$T}</code> complex number: ",
                   z.r, " <i>e</i><sup>", z.Θ, " <i>i</i></sup>")

# ╔═╡ 03da0f26-9e19-11eb-0aa5-010eb80368f1
md"""
A `Polar` object will then display automatically using HTML in an environment that supports HTML display, but you can call `show` manually to get HTML output if you want:
"""

# ╔═╡ 03da1176-9e19-11eb-0afb-373c63c45934
show(stdout, "text/html", Polar(3.0,4.0))

# ╔═╡ 03da1202-9e19-11eb-2bc8-cfd5b22001f5
<p

# ╔═╡ 03da1234-9e19-11eb-0e58-07b9d5f0f10f
md"""
As a rule of thumb, the single-line `show` method should print a valid Julia expression for creating the shown object.  When this `show` method contains infix operators, such as the multiplication operator (`*`) in our single-line `show` method for `Polar` above, it may not parse correctly when printed as part of another object.  To see this, consider the expression object (see [Program representation](@ref)) which takes the square of a specific instance of our `Polar` type:
"""

# ╔═╡ 03da155e-9e19-11eb-0ab0-2f7ae2e4d0bd
a = Polar(3, 4.0)

# ╔═╡ 03da1572-9e19-11eb-2a86-492f8afff30a
print(:($a^2))

# ╔═╡ 03da15ae-9e19-11eb-2449-1f2bc8e064a9
md"""
Because the operator `^` has higher precedence than `*` (see [Operator Precedence and Associativity](@ref)), this output does not faithfully represent the expression `a ^ 2` which should be equal to `(3.0 * exp(4.0im)) ^ 2`.  To solve this issue, we must make a custom method for `Base.show_unquoted(io::IO, z::Polar, indent::Int, precedence::Int)`, which is called internally by the expression object when printing:
"""

# ╔═╡ 03da1eb4-9e19-11eb-1bab-bdbdc6bed96f
function Base.show_unquoted(io::IO, z::Polar, ::Int, precedence::Int)
           if Base.operator_precedence(:*) <= precedence
               print(io, "(")
               show(io, z)
               print(io, ")")
           else
               show(io, z)
           end
       end

# ╔═╡ 03da1ebe-9e19-11eb-3d85-0194fed105c1
:($a^2)

# ╔═╡ 03da1ee6-9e19-11eb-3afd-e3655c245a31
md"""
The method defined above adds parentheses around the call to `show` when the precedence of the calling operator is higher than or equal to the precedence of multiplication.  This check allows expressions which parse correctly without the parentheses (such as `:($a + 2)` and `:($a == 2)`) to omit them when printing:
"""

# ╔═╡ 03da2198-9e19-11eb-0e19-7f4bffff0b45
:($a + 2)

# ╔═╡ 03da2198-9e19-11eb-32ba-f391e5cec204
:($a == 2)

# ╔═╡ 03da21c0-9e19-11eb-1660-0bf820f4b6a5
md"""
In some cases, it is useful to adjust the behavior of `show` methods depending on the context. This can be achieved via the [`IOContext`](@ref) type, which allows passing contextual properties together with a wrapped IO stream. For example, we can build a shorter representation in our `show` method when the `:compact` property is set to `true`, falling back to the long representation if the property is `false` or absent:
"""

# ╔═╡ 03da299a-9e19-11eb-01c0-3559198cd9a1
function Base.show(io::IO, z::Polar)
           if get(io, :compact, false)
               print(io, z.r, "ℯ", z.Θ, "im")
           else
               print(io, z.r, " * exp(", z.Θ, "im)")
           end
       end

# ╔═╡ 03da29c2-9e19-11eb-1e92-25c3593a2c4d
md"""
This new compact representation will be used when the passed IO stream is an `IOContext` object with the `:compact` property set. In particular, this is the case when printing arrays with multiple columns (where horizontal space is limited):
"""

# ╔═╡ 03da2f30-9e19-11eb-2d42-f95d48de95ac
show(IOContext(stdout, :compact=>true), Polar(3, 4.0))

# ╔═╡ 03da2f3a-9e19-11eb-36a6-a53bb5aa1241
[Polar(3, 4.0) Polar(4.0,5.3)]

# ╔═╡ 03da2f62-9e19-11eb-39c4-cf39287c3e26
md"""
See the [`IOContext`](@ref) documentation for a list of common properties which can be used to adjust printing.
"""

# ╔═╡ 03da2f6c-9e19-11eb-0eaf-e5b6a1a38009
md"""
## "Value types"
"""

# ╔═╡ 03da2f9e-9e19-11eb-1dd9-a39c9e987458
md"""
In Julia, you can't dispatch on a *value* such as `true` or `false`. However, you can dispatch on parametric types, and Julia allows you to include "plain bits" values (Types, Symbols, Integers, floating-point numbers, tuples, etc.) as type parameters.  A common example is the dimensionality parameter in `Array{T,N}`, where `T` is a type (e.g., [`Float64`](@ref)) but `N` is just an `Int`.
"""

# ╔═╡ 03da2fc6-9e19-11eb-0b66-0bcebf205622
md"""
You can create your own custom types that take values as parameters, and use them to control dispatch of custom types. By way of illustration of this idea, let's introduce a parametric type, `Val{x}`, and a constructor `Val(x) = Val{x}()`, which serves as a customary way to exploit this technique for cases where you don't need a more elaborate hierarchy.
"""

# ╔═╡ 03da2fe4-9e19-11eb-04f5-55b98093eb79
md"""
[`Val`](@ref) is defined as:
"""

# ╔═╡ 03da3246-9e19-11eb-3709-a57b12be45ca
struct Val{x}
       end

# ╔═╡ 03da3246-9e19-11eb-27ff-ed8e4fcafc73
Val(x) = Val{x}()

# ╔═╡ 03da3278-9e19-11eb-1327-3915d6976bcd
md"""
There is no more to the implementation of `Val` than this.  Some functions in Julia's standard library accept `Val` instances as arguments, and you can also use it to write your own functions.  For example:
"""

# ╔═╡ 03da387c-9e19-11eb-2d2e-6946ac1e9e2b
firstlast(::Val{true}) = "First"

# ╔═╡ 03da387c-9e19-11eb-1385-61b71e9a3509
firstlast(::Val{false}) = "Last"

# ╔═╡ 03da3886-9e19-11eb-39ee-e3b5a58e9550
firstlast(Val(true))

# ╔═╡ 03da3886-9e19-11eb-250e-8d67980494dc
firstlast(Val(false))

# ╔═╡ 03da38b8-9e19-11eb-07a4-8bb13257b7da
md"""
For consistency across Julia, the call site should always pass a `Val` *instance* rather than using a *type*, i.e., use `foo(Val(:bar))` rather than `foo(Val{:bar})`.
"""

# ╔═╡ 03da38ea-9e19-11eb-3098-e11fa9da9c70
md"""
It's worth noting that it's extremely easy to mis-use parametric "value" types, including `Val`; in unfavorable cases, you can easily end up making the performance of your code much *worse*.  In particular, you would never want to write actual code as illustrated above.  For more information about the proper (and improper) uses of `Val`, please read [the more extensive discussion in the performance tips](@ref man-performance-value-type).
"""

# ╔═╡ 03da394e-9e19-11eb-0e5c-cb1b9d539699
md"""
[^1]: "Small" is defined by the `MAX_UNION_SPLITTING` constant, which is currently set to 4.
"""

# ╔═╡ 03da3980-9e19-11eb-3a6a-97233439e72e
md"""
[^2]: A few popular languages have singleton types, including Haskell, Scala and Ruby.
"""

# ╔═╡ Cell order:
# ╟─03d93210-9e19-11eb-304a-35b6b14a75c4
# ╟─03d93268-9e19-11eb-20ca-75fbadfc14da
# ╟─03d932a6-9e19-11eb-1c65-6581e5d4c7fe
# ╟─03d932ba-9e19-11eb-2178-2d033f756982
# ╟─03d932ec-9e19-11eb-352d-2f5918caf88b
# ╟─03d934ae-9e19-11eb-3921-45d2b37afc14
# ╟─03d934c2-9e19-11eb-0a68-35828ac768a4
# ╟─03d934fe-9e19-11eb-3e3d-fd96c3bb64f7
# ╟─03d9351c-9e19-11eb-39e3-63155f5b088e
# ╟─03d9362a-9e19-11eb-080b-2b725eed9794
# ╟─03d93652-9e19-11eb-204e-d3c385339699
# ╠═03d93d50-9e19-11eb-39b5-575cb09b2958
# ╠═03d93d5a-9e19-11eb-2cbb-b770cabfb6a4
# ╟─03d93d76-9e19-11eb-3f6d-8f984c654999
# ╟─03d93db4-9e19-11eb-11e7-7feb149795a5
# ╠═03d9428c-9e19-11eb-16d7-c750a1980e77
# ╠═03d94296-9e19-11eb-26f6-7d8c427fe054
# ╠═03d94296-9e19-11eb-2356-490152f41655
# ╟─03d942dc-9e19-11eb-1e14-9b7f8bc62174
# ╟─03d942fa-9e19-11eb-112e-29891ede328f
# ╟─03d94340-9e19-11eb-100b-9bb7f66aab2d
# ╟─03d9435e-9e19-11eb-13e2-ed0f00d9c514
# ╟─03d94372-9e19-11eb-21cf-e9b7b971088a
# ╟─03d94388-9e19-11eb-2f51-c383c65385b2
# ╟─03d943a4-9e19-11eb-1df4-ef230ee7819f
# ╟─03d943cc-9e19-11eb-0efe-d98a9ae4fe8e
# ╟─03d943e8-9e19-11eb-04af-118857efb70a
# ╟─03d9449e-9e19-11eb-0e6a-25fc43113843
# ╟─03d944be-9e19-11eb-34ef-954ed18861d6
# ╠═03d945de-9e19-11eb-24b3-35facf269cef
# ╟─03d94610-9e19-11eb-36ca-af669d7d3769
# ╟─03d94638-9e19-11eb-06bf-291df3b3eaef
# ╟─03d9464c-9e19-11eb-2af8-156a6ce9b1fe
# ╟─03d9466a-9e19-11eb-0da1-8f047be7c3c3
# ╟─03d946b8-9e19-11eb-3b37-c9e119efe1d1
# ╟─03d946d8-9e19-11eb-1627-790818a85d08
# ╠═03d948cc-9e19-11eb-10c6-3579f9b1ef0c
# ╠═03d948cc-9e19-11eb-216b-95d38957ea9e
# ╟─03d948e0-9e19-11eb-3888-a34b58c39385
# ╟─03d94908-9e19-11eb-1442-95aebe334b4c
# ╟─03d94930-9e19-11eb-3615-d9aa1d43a9b0
# ╟─03d9494e-9e19-11eb-30ea-d3720290bd01
# ╟─03d94962-9e19-11eb-20e4-81a0ccb6c593
# ╟─03d94976-9e19-11eb-12f4-6575b837598e
# ╟─03d94994-9e19-11eb-3d95-db79bf3ee6a0
# ╟─03d949b2-9e19-11eb-33b1-2bb0f969460f
# ╟─03d949c6-9e19-11eb-3985-fb7b66dba040
# ╟─03d94a90-9e19-11eb-38cc-55db5c7502b4
# ╟─03d94aa2-9e19-11eb-1bdd-abca3cd4322a
# ╟─03d94aca-9e19-11eb-2962-b7b0e9c4873e
# ╟─03d94ade-9e19-11eb-0660-7598f04f133d
# ╠═03d94b88-9e19-11eb-23c4-9ba617a2a8d3
# ╟─03d94bba-9e19-11eb-15ac-f54812b5130a
# ╟─03d94c58-9e19-11eb-2123-dd998db5eba8
# ╟─03d94c64-9e19-11eb-1157-a5bdd4c606a5
# ╟─03d94c8a-9e19-11eb-359b-9f84e78ed61e
# ╟─03d94cbe-9e19-11eb-00c1-cb338e4c697a
# ╟─03d94cdc-9e19-11eb-3165-5f69aaf16c0c
# ╠═03d94fac-9e19-11eb-124d-37aa197e618a
# ╟─03d94fcc-9e19-11eb-3c84-e9137db21f11
# ╟─03d94fe8-9e19-11eb-2634-e7c6b3750406
# ╠═03d95358-9e19-11eb-27bb-75db79576764
# ╠═03d95358-9e19-11eb-0a9c-35dcc386e370
# ╟─03d9539e-9e19-11eb-186c-29575b375165
# ╟─03d953b2-9e19-11eb-1030-272fcb6032b2
# ╠═03d9554c-9e19-11eb-156b-6d97184d7d4e
# ╟─03d95560-9e19-11eb-0330-4b7ea77753a2
# ╠═03d9563c-9e19-11eb-2441-7dac38a708a2
# ╟─03d9565a-9e19-11eb-0965-33c4e6b8f3ca
# ╠═03d95812-9e19-11eb-2718-15939b2b88f0
# ╠═03d9581c-9e19-11eb-33da-6bda30e6575e
# ╠═03d95844-9e19-11eb-2ee0-459297e307cb
# ╟─03d95862-9e19-11eb-2b32-17a747d80182
# ╟─03d958da-9e19-11eb-252d-4522eca921ab
# ╟─03d958ee-9e19-11eb-10dc-c12f5b3a672d
# ╟─03d9590c-9e19-11eb-0558-c5feeff3b1ac
# ╟─03d95920-9e19-11eb-32de-7fefb85e061f
# ╠═03d95d26-9e19-11eb-10c3-796abaf3d9c2
# ╠═03d95d30-9e19-11eb-1203-9fe7410dabbb
# ╟─03d95d62-9e19-11eb-2e1c-439ae5fbc5b1
# ╟─03d95d78-9e19-11eb-1481-2d4a3c8362c4
# ╟─03d95d94-9e19-11eb-183e-4da897c7008d
# ╠═03d9667a-9e19-11eb-2424-9b2d04136b1f
# ╠═03d96686-9e19-11eb-234f-072d005b24ff
# ╠═03d96690-9e19-11eb-0988-3d1641b3a67a
# ╠═03d96690-9e19-11eb-05c8-8f7a076bdb81
# ╟─03d966ec-9e19-11eb-2d12-4f1cacd812e6
# ╟─03d966fe-9e19-11eb-2687-7b8f028123f8
# ╟─03d968c0-9e19-11eb-3672-5d9df7955e99
# ╟─03d968fc-9e19-11eb-1019-8192b90f2de6
# ╟─03d96918-9e19-11eb-3378-e5a233928adf
# ╟─03d96992-9e19-11eb-09fb-bb3f960f05c0
# ╟─03d969b0-9e19-11eb-278a-e37ed24b57b1
# ╠═03d96ba4-9e19-11eb-0e80-132b8e19c39a
# ╠═03d96ba4-9e19-11eb-39b4-91ff0de8f4b7
# ╟─03d96bcc-9e19-11eb-17bc-45bdd1b6d79f
# ╟─03d96be8-9e19-11eb-3b62-ffe8375d5e19
# ╟─03d96c1a-9e19-11eb-1719-a72b3639e71f
# ╟─03d96c3a-9e19-11eb-025d-0fd901dbec56
# ╠═03d97068-9e19-11eb-14dd-67341fd6e2e9
# ╠═03d97072-9e19-11eb-109c-8b0792323334
# ╠═03d97092-9e19-11eb-2ca3-33c16d26314e
# ╠═03d97092-9e19-11eb-2e56-c706b642212b
# ╟─03d970c4-9e19-11eb-2ddf-b116dba2327f
# ╟─03d97124-9e19-11eb-3e11-b998234fcc1a
# ╟─03d97130-9e19-11eb-3ec2-2faf95aeee48
# ╟─03d97156-9e19-11eb-0c1a-db84de374472
# ╟─03d97176-9e19-11eb-2e1b-1f149a6b7b84
# ╟─03d971bc-9e19-11eb-0089-2128a5ecf087
# ╟─03d971d0-9e19-11eb-1e54-f904057bce0d
# ╠═03d97450-9e19-11eb-21a6-097fba6517f0
# ╟─03d974aa-9e19-11eb-0b64-41c10e13e640
# ╠═03d976bc-9e19-11eb-1644-fb75c3e6b6d2
# ╠═03d976d0-9e19-11eb-136f-c35a3da0b27b
# ╟─03d97702-9e19-11eb-103e-3d22af9b235b
# ╟─03d97734-9e19-11eb-2e08-e788e87858f3
# ╠═03d97aca-9e19-11eb-07e4-bd80a200d241
# ╠═03d97aca-9e19-11eb-2154-a51731b00c11
# ╟─03d97af4-9e19-11eb-1aad-bba7bd4d4f37
# ╠═03d97d74-9e19-11eb-3c6b-0949b65b88b9
# ╠═03d97d74-9e19-11eb-2dae-114a9a69904a
# ╟─03d97d9a-9e19-11eb-2ce7-b5797a69a9e4
# ╠═03d9800a-9e19-11eb-3bec-eb8fb534b6c8
# ╠═03d98026-9e19-11eb-1173-ffd376e90ac7
# ╟─03d980a8-9e19-11eb-21ab-a335065b08fe
# ╟─03d980ee-9e19-11eb-145b-e54f2e60905b
# ╟─03d98172-9e19-11eb-3c89-f5e9333fdde4
# ╟─03d981b6-9e19-11eb-160a-8bb6afff3f4a
# ╟─03d981ca-9e19-11eb-2ed1-575e34cb6c04
# ╟─03d981f2-9e19-11eb-3056-afa6dce3fc87
# ╟─03d9821a-9e19-11eb-25af-71bd6af6577a
# ╟─03d98224-9e19-11eb-1490-874e082c5221
# ╟─03d98242-9e19-11eb-1218-f52ba7d15e43
# ╟─03d98260-9e19-11eb-11c2-b34c54d1cc49
# ╟─03d98276-9e19-11eb-3a8a-5b0a381cc695
# ╟─03d982a8-9e19-11eb-1292-a55080770ab8
# ╠═03d98546-9e19-11eb-00be-fddda6fbaa65
# ╠═03d9854e-9e19-11eb-20d5-6d5fa90a799b
# ╟─03d98558-9e19-11eb-0a25-b1701245eee8
# ╠═03d98792-9e19-11eb-1afc-67f649882d68
# ╠═03d9879c-9e19-11eb-1807-8feec5dfa315
# ╟─03d987ba-9e19-11eb-3ba4-719b38431e05
# ╟─03d987d8-9e19-11eb-3c97-4b7a5468029a
# ╠═03d98bac-9e19-11eb-25e4-e5b3b0cd1db5
# ╠═03d98bc0-9e19-11eb-129d-77b1cfe5bfd4
# ╠═03d98bc0-9e19-11eb-2a1a-01d4ae710fce
# ╠═03d98bd4-9e19-11eb-2c30-db51dc75d0af
# ╟─03d98bfc-9e19-11eb-128b-39f2a5a8f997
# ╠═03d98d14-9e19-11eb-33ab-49de284915c1
# ╟─03d98d28-9e19-11eb-2318-137330cf86a2
# ╟─03d98d3c-9e19-11eb-2024-e10f061268c9
# ╟─03d98d5a-9e19-11eb-3afe-8fee0d0ba882
# ╠═03d98e86-9e19-11eb-256b-ffc60acce5fd
# ╟─03d98ea4-9e19-11eb-2af2-2389221fe0b4
# ╠═03d990a2-9e19-11eb-0227-47e8fce1d9e1
# ╠═03d990a2-9e19-11eb-31db-9560a0a9d916
# ╟─03d990ca-9e19-11eb-3c26-459aa4703ef0
# ╠═03d992c8-9e19-11eb-0088-6f689a73364c
# ╠═03d992c8-9e19-11eb-1941-71657535cd25
# ╟─03d992fa-9e19-11eb-2d58-c5319f96f208
# ╠═03d995ac-9e19-11eb-1e20-27df4bb9fe02
# ╠═03d995ac-9e19-11eb-0b67-35838d45d75a
# ╟─03d995ca-9e19-11eb-2276-5348f842e538
# ╠═03d99840-9e19-11eb-372a-cb57fc05e8eb
# ╟─03d99868-9e19-11eb-228b-c7dc6affabc7
# ╠═03d99b6a-9e19-11eb-0bc0-cbc7c3af964f
# ╠═03d99b6a-9e19-11eb-126d-bba0c437dc75
# ╠═03d99b74-9e19-11eb-2efc-1bd7c1e18396
# ╟─03d99b88-9e19-11eb-1df7-f1e5b45ad0ce
# ╠═03d99dce-9e19-11eb-087f-dfdfbab5c97e
# ╠═03d99dd6-9e19-11eb-1b63-b3f8881d0ee9
# ╟─03d99df4-9e19-11eb-35f8-db8c5f745447
# ╠═03d99fe8-9e19-11eb-3de7-11e2ccd70a07
# ╟─03d9a01a-9e19-11eb-1d9e-f992c22cd583
# ╟─03d9a02c-9e19-11eb-36fc-7fdb54eacfa1
# ╠═03d9a1aa-9e19-11eb-1529-8fe8926ff245
# ╟─03d9a1f0-9e19-11eb-21ff-e54a36734e8e
# ╠═03d9a448-9e19-11eb-0ca5-63f6e516f556
# ╠═03d9a448-9e19-11eb-260c-c591f69f64a4
# ╠═03d9a452-9e19-11eb-2823-dd987502d91d
# ╠═03d9a466-9e19-11eb-2817-676753463862
# ╟─03d9a470-9e19-11eb-088f-25bb99be8364
# ╟─03d9a48e-9e19-11eb-1c8e-e9317d8e56fd
# ╟─03d9a4ac-9e19-11eb-0bda-cb6825410386
# ╟─03d9a4c0-9e19-11eb-3054-5faa1a4ec4f7
# ╟─03d9a4e8-9e19-11eb-14f6-ff9676a57160
# ╟─03d9a4fc-9e19-11eb-2cc3-e94edd9dcc15
# ╟─03d9a524-9e19-11eb-2ba4-cd3e0bbd0522
# ╟─03d9a536-9e19-11eb-1b50-8318fc35d4bd
# ╟─03d9a54c-9e19-11eb-25cd-2b15a3aa1665
# ╟─03d9a5ec-9e19-11eb-25cc-c95076bfe5a1
# ╟─03d9a5f6-9e19-11eb-2c0a-1d6ce0f501ff
# ╠═03d9a826-9e19-11eb-3965-7594b550db83
# ╟─03d9a830-9e19-11eb-2c3c-b3bb8a2b6ad4
# ╠═03d9abde-9e19-11eb-1221-ed51e0dc512f
# ╠═03d9abde-9e19-11eb-3325-19627b3b2308
# ╠═03d9abde-9e19-11eb-108f-23e171d916dc
# ╟─03d9abf0-9e19-11eb-38de-41ca4fd3920a
# ╟─03d9ac0c-9e19-11eb-1182-c529ba9d95d4
# ╟─03d9ac2c-9e19-11eb-08a1-d7c291fb92da
# ╠═03d9b474-9e19-11eb-30ae-9b1a53c66d6f
# ╠═03d9b474-9e19-11eb-3f26-250eea819c8e
# ╠═03d9b4a6-9e19-11eb-3e3b-09660008ef48
# ╠═03d9b4ba-9e19-11eb-3aed-f7e970b11056
# ╠═03d9b4ba-9e19-11eb-1280-756a151b9e64
# ╟─03d9b4e2-9e19-11eb-2883-05c709080d64
# ╟─03d9b546-9e19-11eb-1738-1b2116e77367
# ╟─03d9b55a-9e19-11eb-160a-a599b3e85f4b
# ╟─03d9b56e-9e19-11eb-0f40-cdee101d0bbc
# ╠═03d9b870-9e19-11eb-0fe8-1563ad9f8dfe
# ╟─03d9b8ac-9e19-11eb-12f0-e101c61cd883
# ╠═03d9bca8-9e19-11eb-3c69-15f90f30287f
# ╠═03d9bca8-9e19-11eb-3044-6dca59491402
# ╟─03d9bcd0-9e19-11eb-3811-ed503fa1989d
# ╠═03d9c252-9e19-11eb-22b4-c75234269862
# ╠═03d9c252-9e19-11eb-1e9a-517418b6b085
# ╟─03d9c266-9e19-11eb-0fe2-1324de6bcf0c
# ╟─03d9c28e-9e19-11eb-1572-5dcb01a9374b
# ╟─03d9c2a2-9e19-11eb-21eb-358997d50b49
# ╟─03d9c2b6-9e19-11eb-0209-053cfa819330
# ╟─03d9c2e8-9e19-11eb-04cc-6786a9026f7f
# ╠═03d9c52a-9e19-11eb-357e-f5e213dc9403
# ╠═03d9c540-9e19-11eb-2e88-9720a9f8f123
# ╟─03d9c55e-9e19-11eb-03f4-f54d1230a538
# ╟─03d9c590-9e19-11eb-0acb-6fbaa02390db
# ╟─03d9c5c2-9e19-11eb-0d18-25c338cba835
# ╟─03d9c5f4-9e19-11eb-310e-dfb64182dfe9
# ╟─03d9c62e-9e19-11eb-3871-5166c139a8fd
# ╟─03d9c658-9e19-11eb-3023-11e69f4bfacb
# ╟─03d9c66c-9e19-11eb-2906-2747bb614887
# ╠═03d9cb6e-9e19-11eb-14ec-51511a5ec5cf
# ╠═03d9cb9c-9e19-11eb-290c-b7cd7a40a12d
# ╟─03d9cbc6-9e19-11eb-0bc8-99a99282637b
# ╟─03d9cbe4-9e19-11eb-1bc2-d3288cca5841
# ╟─03d9cbf8-9e19-11eb-1d1f-993a21e8f391
# ╟─03d9cc2a-9e19-11eb-2f31-897222b54046
# ╟─03d9cc3e-9e19-11eb-366d-494d218c0eec
# ╟─03d9cc52-9e19-11eb-3214-5d4c5a26383a
# ╟─03d9ccd6-9e19-11eb-08c0-33f6a534c5e4
# ╟─03d9cd04-9e19-11eb-3ae9-374f28f8e5fc
# ╟─03d9cd10-9e19-11eb-0a91-c70c5b6c8fbc
# ╠═03d9cff4-9e19-11eb-0ce4-fd9872997ea1
# ╠═03d9cffe-9e19-11eb-0552-c55431bbe2e3
# ╠═03d9d006-9e19-11eb-3ac1-41dbd2da2d83
# ╟─03d9d026-9e19-11eb-287d-91b45d460a07
# ╟─03d9d044-9e19-11eb-3c4a-81dcca2566f8
# ╠═03d9d68e-9e19-11eb-1154-8f71a5a6f719
# ╠═03d9d68e-9e19-11eb-08ea-838f937340df
# ╠═03d9d698-9e19-11eb-32b0-4737663476b1
# ╠═03d9d698-9e19-11eb-1295-e79c2ceccc14
# ╠═03d9d6a2-9e19-11eb-00e2-01ca633a2805
# ╠═03d9d6aa-9e19-11eb-058f-bb725b7609d1
# ╟─03d9d6ca-9e19-11eb-0a33-77067cce87c1
# ╟─03d9d706-9e19-11eb-2a72-d5fe1fba3829
# ╟─03d9d724-9e19-11eb-3fca-9966c1d62c01
# ╠═03d9daf8-9e19-11eb-2586-4dff74bd80a0
# ╠═03d9db02-9e19-11eb-2162-77974f333d87
# ╠═03d9db02-9e19-11eb-355d-b1cd123a5402
# ╠═03d9db14-9e19-11eb-3081-4de832a3a877
# ╟─03d9db3e-9e19-11eb-06ee-8fc96e23d4ed
# ╟─03d9db52-9e19-11eb-133a-dd71ceb4ce5e
# ╠═03d9dfbe-9e19-11eb-0d17-1baae82e3f53
# ╠═03d9dfd0-9e19-11eb-2184-9548f42b8764
# ╠═03d9dfd0-9e19-11eb-1ebd-810c8f660b42
# ╠═03d9dfda-9e19-11eb-20ec-6bfa2e1aa93b
# ╟─03d9dff8-9e19-11eb-2c9b-39b5671c2725
# ╠═03d9e246-9e19-11eb-1822-fd209cf644f5
# ╠═03d9e246-9e19-11eb-1fbd-19b18aca1486
# ╠═03d9e250-9e19-11eb-2366-a36f6d80bf49
# ╟─03d9e264-9e19-11eb-39f1-e991dbdd4588
# ╠═03d9e456-9e19-11eb-3932-1fb37cceffe3
# ╠═03d9e456-9e19-11eb-2097-e7fe9b08704e
# ╟─03d9e488-9e19-11eb-1f39-2961bed26b30
# ╠═03d9ea02-9e19-11eb-3381-79b1b855f2b2
# ╠═03d9ea0c-9e19-11eb-0744-75f713836a8b
# ╠═03d9ea28-9e19-11eb-0c9f-5105db0bca17
# ╠═03d9ea28-9e19-11eb-3370-959b7881c4a2
# ╟─03d9ea3e-9e19-11eb-3f65-a19c0da27a28
# ╟─03d9ea66-9e19-11eb-36c2-9bfe3bad42b9
# ╠═03d9eb9c-9e19-11eb-3557-8dd7c44ac675
# ╠═03d9eb9c-9e19-11eb-25a0-775ff798c425
# ╠═03d9eba6-9e19-11eb-33d7-d36fee28e994
# ╟─03d9ebba-9e19-11eb-10cc-2184366ffeb4
# ╟─03d9ebd8-9e19-11eb-20f5-2d96e0091143
# ╟─03d9ebf6-9e19-11eb-0929-cb1384688459
# ╟─03d9ec1e-9e19-11eb-1701-37ccaa16c6f2
# ╟─03d9ec34-9e19-11eb-347f-7179bf164eab
# ╟─03d9ec50-9e19-11eb-02a3-1d8983f02211
# ╟─03d9ec6e-9e19-11eb-16ff-1d92b723464e
# ╠═03d9ee2e-9e19-11eb-31a3-3dcd393870c4
# ╠═03d9ee44-9e19-11eb-3f6e-1fce1a5dd523
# ╟─03d9ee60-9e19-11eb-1278-d986eb594580
# ╠═03d9f056-9e19-11eb-00af-538dc9bde0df
# ╠═03d9f060-9e19-11eb-3916-b3f2a04982ee
# ╟─03d9f088-9e19-11eb-20d8-1f56de343119
# ╠═03d9f196-9e19-11eb-1f94-0f40c31cabca
# ╠═03d9f1a2-9e19-11eb-00e4-11a65638bc68
# ╟─03d9f1b4-9e19-11eb-1fc5-d9336636241e
# ╟─03d9f1dc-9e19-11eb-3ebd-c70592d0a8a4
# ╠═03d9f40c-9e19-11eb-2026-83717228f926
# ╠═03d9f416-9e19-11eb-35ea-3998adc23a45
# ╠═03d9f416-9e19-11eb-15a2-4397281ef30b
# ╠═03d9f42a-9e19-11eb-0494-5b8d4e5d5938
# ╟─03d9f448-9e19-11eb-38dc-0b353845d61c
# ╠═03d9f560-9e19-11eb-2846-b59393d05080
# ╟─03d9f574-9e19-11eb-1636-83838b55d0e5
# ╟─03d9f59c-9e19-11eb-0af3-f5ebe05c3283
# ╠═03d9fb5a-9e19-11eb-3c70-ffcf63c78c3b
# ╠═03d9fb5a-9e19-11eb-0b56-2f84ba4f7b99
# ╟─03d9fba0-9e19-11eb-0a9f-734174c885e6
# ╟─03d9fbd2-9e19-11eb-0f1a-573e35834971
# ╠═03d9ffce-9e19-11eb-19b2-f7ae04983241
# ╟─03da0000-9e19-11eb-07da-83b9e5118b64
# ╠═03da049c-9e19-11eb-19a5-5fea1677451e
# ╟─03da04bc-9e19-11eb-0fb5-0bacc8cc2ef3
# ╠═03da0834-9e19-11eb-3b55-e730627a90d8
# ╠═03da0834-9e19-11eb-39d3-0994ccd03217
# ╟─03da0884-9e19-11eb-15cf-c7c5da9ae40a
# ╟─03da08b6-9e19-11eb-1c33-a1d90a104b8e
# ╠═03da0f0a-9e19-11eb-15fc-a9546498cc5d
# ╟─03da0f26-9e19-11eb-0aa5-010eb80368f1
# ╠═03da1176-9e19-11eb-0afb-373c63c45934
# ╠═03da1202-9e19-11eb-2bc8-cfd5b22001f5
# ╟─03da1234-9e19-11eb-0e58-07b9d5f0f10f
# ╠═03da155e-9e19-11eb-0ab0-2f7ae2e4d0bd
# ╠═03da1572-9e19-11eb-2a86-492f8afff30a
# ╟─03da15ae-9e19-11eb-2449-1f2bc8e064a9
# ╠═03da1eb4-9e19-11eb-1bab-bdbdc6bed96f
# ╠═03da1ebe-9e19-11eb-3d85-0194fed105c1
# ╟─03da1ee6-9e19-11eb-3afd-e3655c245a31
# ╠═03da2198-9e19-11eb-0e19-7f4bffff0b45
# ╠═03da2198-9e19-11eb-32ba-f391e5cec204
# ╟─03da21c0-9e19-11eb-1660-0bf820f4b6a5
# ╠═03da299a-9e19-11eb-01c0-3559198cd9a1
# ╟─03da29c2-9e19-11eb-1e92-25c3593a2c4d
# ╠═03da2f30-9e19-11eb-2d42-f95d48de95ac
# ╠═03da2f3a-9e19-11eb-36a6-a53bb5aa1241
# ╟─03da2f62-9e19-11eb-39c4-cf39287c3e26
# ╟─03da2f6c-9e19-11eb-0eaf-e5b6a1a38009
# ╟─03da2f9e-9e19-11eb-1dd9-a39c9e987458
# ╟─03da2fc6-9e19-11eb-0b66-0bcebf205622
# ╟─03da2fe4-9e19-11eb-04f5-55b98093eb79
# ╠═03da3246-9e19-11eb-3709-a57b12be45ca
# ╠═03da3246-9e19-11eb-27ff-ed8e4fcafc73
# ╟─03da3278-9e19-11eb-1327-3915d6976bcd
# ╠═03da387c-9e19-11eb-2d2e-6946ac1e9e2b
# ╠═03da387c-9e19-11eb-1385-61b71e9a3509
# ╠═03da3886-9e19-11eb-39ee-e3b5a58e9550
# ╠═03da3886-9e19-11eb-250e-8d67980494dc
# ╟─03da38b8-9e19-11eb-07a4-8bb13257b7da
# ╟─03da38ea-9e19-11eb-3098-e11fa9da9c70
# ╟─03da394e-9e19-11eb-0e5c-cb1b9d539699
# ╟─03da3980-9e19-11eb-3a6a-97233439e72e
