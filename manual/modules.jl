### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ 77214aa0-9347-4b1c-a46d-e1c63a72e00f
md"""
# [Modules](@id modules)
"""

# ╔═╡ 6b831527-021c-41d2-af0d-a29961cfa708
md"""
Modules in Julia help organize code into coherent units. They are delimited syntactically inside `module NameOfModule ... end`, and have the following features:
"""

# ╔═╡ c32f79b3-362d-40ba-97b5-294a84a4b1a9
md"""
1. Modules are separate namespaces, each introducing a new global scope. This is useful, because it allows the same name to be used for different functions or global variables without conflict, as long as they are in separate modules.
2. Modules have facilities for detailed namespace management: each defines a set of names it `export`s, and can import names from other modules with `using` and `import` (we explain these below).
3. Modules can be precompiled for faster loading, and contain code for runtime initialization.
"""

# ╔═╡ e9b9e13c-afe6-45f8-a4a9-d1b46dc01e91
md"""
Typically, in larger Julia packages you will see module code organized into files, eg
"""

# ╔═╡ 825decbe-2e95-427e-a06f-a4c7ea7ec523
md"""
```julia
module SomeModule

# export, using, import statements are usually here; we discuss these below

include(\"file1.jl\")
include(\"file2.jl\")

end
```
"""

# ╔═╡ b120f61e-a381-4ee5-9096-3ad6d23c6bf8
md"""
Files and file names are mostly unrelated to modules; modules are associated only with module expressions. One can have multiple files per module, and multiple modules per file. `include` behaves as if the contents of the source file were evaluated in its place. In this chapter, we use short and simplified examples, so we won't use `include`.
"""

# ╔═╡ 0a93d3a3-440e-46b3-8919-60f9328f7cc1
md"""
The recommended style is not to indent the body of the module, since that would typically lead to whole files being indented. Also, it is common to use `UpperCamelCase` for module names (just like types), and use the plural form if applicable, especially if the module contains a similarly named identifier, to avoid name clashes. For example,
"""

# ╔═╡ 9c1f165b-29f7-43c0-9c49-06769df76f78
md"""
```julia
module FastThings

struct FastThing
    ...
end

end
```
"""

# ╔═╡ fa9f4ba3-92de-4932-be80-2e99cd6356cc
md"""
## [Namespace management](@id namespace-management)
"""

# ╔═╡ fcb8385b-7aa9-472e-a3f0-7108d6d4dbe4
md"""
Namespace management refers to the facilities the language offers for making names in a module available in other modules. We discuss the related concepts and functionality below in detail.
"""

# ╔═╡ 95d7f4f4-d69c-4e80-b3a4-273d7704acea
md"""
### Qualified names
"""

# ╔═╡ cb4e0302-01d2-4c60-b406-4214ccc56861
md"""
Names for functions, variables and types in the global scope like `sin`, `ARGS`, and `UnitRange` always belong to a module, called the *parent module*, which can be found interactively with [`parentmodule`](@ref), for example
"""

# ╔═╡ ff4b3edc-0bfd-4440-8a0c-82791ba06236
parentmodule(UnitRange)

# ╔═╡ 00e34d94-86b2-4181-bf18-6e70513f3efa
md"""
One can also refer to these names outside their parent module by prefixing them with their module, eg `Base.UnitRange`. This is called a *qualified name*. The parent module may be accessible using a chain of submodules like `Base.Math.sin`, where `Base.Math` is called the *module path*. Due to syntactic ambiguities, qualifying a name that contains only symbols, such as an operator, requires inserting a colon, e.g. `Base.:+`. A small number of operators additionally require parentheses, e.g. `Base.:(==)`.
"""

# ╔═╡ 1a7fd14c-0b3f-488a-b09a-8d714383ef1d
md"""
If a name is qualified, then it is always *accessible*, and in case of a function, it can also have methods added to it by using the qualified name as the function name.
"""

# ╔═╡ d4e80b7e-b73c-4cb6-9d3e-25f630f6d608
md"""
Within a module, a variable name can be “reserved” without assigning to it by declaring it as `global x`. This prevents name conflicts for globals initialized after load time. The syntax `M.x = y` does not work to assign a global in another module; global assignment is always module-local.
"""

# ╔═╡ e273a568-823d-42f8-92ee-0675d1db2936
md"""
### Export lists
"""

# ╔═╡ 07ef7ff0-a660-4e95-873b-ca7016b53b19
md"""
Names (referring to functions, types, global variables, and constants) can be added to the *export list* of a module with `export`. Typically, they are at or near the top of the module definition so that readers of the source code can find them easily, as in
"""

# ╔═╡ 55d1c547-991b-4c14-95d8-065ef2877574
md"""
```julia
module NiceStuff

export nice, DOG

struct Dog end      # singleton type, not exported

const DOG = Dog()   # named instance, exported

nice(x) = \"nice $x\" # function, exported

end
```
"""

# ╔═╡ 84634de6-fefb-4818-96a9-80953accc951
md"""
but this is just a style suggestion — a module can have multiple `export` statements in arbitrary locations.
"""

# ╔═╡ 7956bb90-11eb-437c-9df8-11292c38ab42
md"""
It is common to export names which form part of the API (application programming interface). In the above code, the export list suggests that users should use `nice` and `DOG`. However, since qualified names always make identifiers accessible, this is just an option for organizing APIs: unlike other languages, Julia has no facilities for truly hiding module internals.
"""

# ╔═╡ 802c4578-3cc1-4cf1-bc3c-fcf2bba958e1
md"""
Also, some modules don't export names at all. This is usually done if they use common words, such as `derivative`, in their API, which could easily clash with the export lists of other modules. We will see how to manage name clashes below.
"""

# ╔═╡ 5377a785-0671-4f51-aa26-cf517d00e082
md"""
### Standalone `using` and `import`
"""

# ╔═╡ c2b4c7f7-7917-4dad-8107-a3b04c40e891
md"""
Possibly the most common way of loading a module is `using ModuleName`. This [loads](@ref code-loading) the code associated with `ModuleName`, and brings
"""

# ╔═╡ 4a42428c-3345-4dcb-993a-dddd5dd3cfa1
md"""
1. the module name
2. and the elements of the export list into the surrounding global namespace.
"""

# ╔═╡ 12ed701c-61a7-4ddc-9cbe-1d10c704f4ea
md"""
Technically, the statement `using ModuleName` means that a module called `ModuleName` will be available for resolving names as needed. When a global variable is encountered that has no definition in the current module, the system will search for it among variables exported by `ModuleName` and use it if it is found there. This means that all uses of that global within the current module will resolve to the definition of that variable in `ModuleName`.
"""

# ╔═╡ f60b6a64-7918-4e02-b654-d5db5f1cfe41
md"""
To continue with our example,
"""

# ╔═╡ 9f282c9f-98f1-4228-a24e-28e35da85ff1
md"""
```julia
using NiceStuff
```
"""

# ╔═╡ f67ceebc-1a4e-408e-be24-c60a17762c4b
md"""
would load the above code, making `NiceStuff` (the module name), `DOG` and `nice` available. `Dog` is not on the export list, but it can be accessed if the name is qualified with the module path (which here is just the module name) as `NiceStuff.Dog`.
"""

# ╔═╡ b419af3c-3de2-498f-aa1b-939a1e94b776
md"""
Importantly, **`using ModuleName` is the only form for which export lists matter at all**.
"""

# ╔═╡ 19c2a10d-ba67-409f-af5a-47c261e9b409
md"""
In contrast,
"""

# ╔═╡ 8454ba62-3016-48c2-9ddd-c0bd2cc1c806
md"""
```julia
import NiceStuff
```
"""

# ╔═╡ ee94e9e8-b081-4add-a1d4-f34f536fc7af
md"""
brings *only* the module name into scope. Users would need to use `NiceStuff.DOG`, `NiceStuff.Dog`, and `NiceStuff.nice` to access its contents. Usually, `import ModuleName` is used in contexts when the user wants to keep the namespace clean. As we will see in the next section `import NiceStuff` is equivalent to `using NiceStuff: NiceStuff`.
"""

# ╔═╡ d2bb710a-36d6-4cc9-8544-49a782026a31
md"""
You can combine multiple `using` and `import` statements of the same kind in a comma-separated expression, e.g.
"""

# ╔═╡ 0641b550-807f-4ae3-8d27-9bcba8de3115
md"""
```julia
using LinearAlgebra, Statistics
```
"""

# ╔═╡ 9aeabfc6-c501-42fa-b79d-7dee41ffb84e
md"""
### `using` and `import` with specific identifiers, and adding methods
"""

# ╔═╡ df2beeaa-c0d4-483a-96c7-87f16051f4a2
md"""
When `using ModuleName:` or `import ModuleName:` is followed by a comma-separated list of names, the module is loaded, but *only those specific names are brought into the namespace* by the statement. For example,
"""

# ╔═╡ d04c83b0-ff52-402a-ab90-39cf8d978499
md"""
```julia
using NiceStuff: nice, DOG
```
"""

# ╔═╡ e885481d-6714-4b1a-a78a-4a04913f8edd
md"""
will import the names `nice` and `DOG`.
"""

# ╔═╡ 5a07e667-b940-419e-80be-b09528f5447f
md"""
Importantly, the module name `NiceStuff` will *not* be in the namespace. If you want to make it accessible, you have to list it explicitly, as
"""

# ╔═╡ eb6fd374-ce65-40e0-8994-118be44e45fd
md"""
```julia
using NiceStuff: nice, DOG, NiceStuff
```
"""

# ╔═╡ 3df56dec-0dff-4f6d-a0fb-919eb1cdcae8
md"""
Julia has two forms for seemingly the same thing because only `import ModuleName: f` allows adding methods to `f` *without a module path*. That is to say, the following example will give an error:
"""

# ╔═╡ c2a2c8c5-5fef-44c9-8dc2-93f4c6e24f7f
md"""
```julia
using NiceStuff: nice
struct Cat end
nice(::Cat) = \"nice 😸\"
```
"""

# ╔═╡ 74e69a41-1d0e-4c92-a55c-a31bcaf0e14b
md"""
This error prevents accidentally adding methods to functions in other modules that you only intended to use.
"""

# ╔═╡ c270ce6c-c3ed-42a7-bfbc-9df6c5d0a988
md"""
There are two ways to deal with this. You can always qualify function names with a module path:
"""

# ╔═╡ c1b6d6e2-014a-4497-a954-72418e444054
md"""
```julia
using NiceStuff
struct Cat end
NiceStuff.nice(::Cat) = \"nice 😸\"
```
"""

# ╔═╡ b8ccae8a-789d-4658-bc45-6d1cc42c0124
md"""
Alternatively, you can `import` the specific function name:
"""

# ╔═╡ 15a51fd8-b14a-4c42-941f-8fbdbf9435d6
md"""
```julia
import NiceStuff: nice
struct Cat end
nice(::Cat) = \"nice 😸\"
```
"""

# ╔═╡ 653bada4-9294-4f16-a557-0b1096837a44
md"""
Which one you choose is a matter of style. The first form makes it clear that you are adding a method to a function in another module (remember, that the imports and the method defintion may be in separate files), while the second one is shorter, which is especially convenient if you are defining multiple methods.
"""

# ╔═╡ 8bea2062-a27d-4f78-97cd-10c7dc232ee7
md"""
Once a variable is made visible via `using` or `import`, a module may not create its own variable with the same name. Imported variables are read-only; assigning to a global variable always affects a variable owned by the current module, or else raises an error.
"""

# ╔═╡ 5be3a721-9c85-4b76-b5a7-ca0a822e68f4
md"""
### Renaming with `as`
"""

# ╔═╡ 61ee5e09-8b4c-41ea-9673-8575f5fe5ed4
md"""
An identifier brought into scope by `import` or `using` can be renamed with the keyword `as`. This is useful for working around name conflicts as well as for shortening names. For example, `Base` exports the function name `read`, but the CSV.jl package also provides `CSV.read`. If we are going to invoke CSV reading many times, it would be convenient to drop the `CSV.` qualifier. But then it is ambiguous whether we are referring to `Base.read` or `CSV.read`:
"""

# ╔═╡ 1904a1d7-5520-4ca0-89f5-542ffeabf16f
md"""
```julia
julia> read;

julia> import CSV: read
WARNING: ignoring conflicting import of CSV.read into Main
```
"""

# ╔═╡ 36556bda-3474-43ba-9677-f5455d028639
md"""
Renaming provides a solution:
"""

# ╔═╡ 79fea417-51ac-47d5-a7e2-4c474e0f9381
md"""
```julia
julia> import CSV: read as rd
```
"""

# ╔═╡ 0c1ea366-7203-48d4-8378-1963a5042c84
md"""
Imported packages themselves can also be renamed:
"""

# ╔═╡ 5b64abaf-61b8-47ca-b51c-c89d2b912cf5
md"""
```julia
import BenchmarkTools as BT
```
"""

# ╔═╡ 90463b42-ca17-4807-b202-0ad56951bb89
md"""
`as` works with `using` only when a single identifier is brought into scope. For example `using CSV: read as rd` works, but `using CSV as C` does not, since it operates on all of the exported names in `CSV`.
"""

# ╔═╡ 042a9ec3-eda4-49a8-9d83-338d88492130
md"""
### Mixing multiple `using` and `import` statements
"""

# ╔═╡ a274e2ed-0f7d-41c1-9bfc-a29cfd71d7d9
md"""
When multiple `using` or `import` statements of any of the forms above are used, their effect is combined in the order they appear. For example,
"""

# ╔═╡ 804e42bc-b92c-4ffe-8777-fea3c574eda3
md"""
```julia
using NiceStuff         # exported names and the module name
import NiceStuff: nice  # allows adding methods to unqualified functions
```
"""

# ╔═╡ 1b40935a-2ffa-4ae2-ab15-f51e20ed2fe8
md"""
would bring all the exported names of `NiceStuff` and the module name itself into scope, and also allow adding methods to `nice` without prefixing it with a module name.
"""

# ╔═╡ 41594361-129a-41ed-8fc1-2fc2fa407274
md"""
### Handling name conflicts
"""

# ╔═╡ 41bd5c6f-8b68-47f1-a9b0-ac4041e6bb1d
md"""
Consider the situation where two (or more) packages export the same name, as in
"""

# ╔═╡ 0976d7fd-332b-4e44-850d-1fe4cdda3cb9
md"""
```julia
module A
export f
f() = 1
end

module B
export f
f() = 2
end
```
"""

# ╔═╡ cd4e515b-87be-4734-9d78-c71eb10d193d
md"""
The statement `using A, B` works, but when you try to call `f`, you get a warning
"""

# ╔═╡ f03b97d2-5979-4f77-880c-c8b0860b49ae
md"""
```julia
WARNING: both B and A export \"f\"; uses of it in module Main must be qualified
ERROR: LoadError: UndefVarError: f not defined
```
"""

# ╔═╡ c8b8dd7d-742b-4443-a8bb-11dceae54668
md"""
Here, Julia cannot decide which `f` you are referring to, so you have to make a choice. The following solutions are commonly used:
"""

# ╔═╡ 25588fb6-208a-458e-99e5-0c758efc0d02
md"""
1. Simply proceed with qualified names like `A.f` and `B.f`. This makes the context clear to the reader of your code, especially if `f` just happens to coincide but has different meaning in various packages. For example, `degree` has various uses in mathematics, the natural sciences, and in everyday life, and these meanings should be kept separate.
2. Use the `as` keyword above to rename one or both identifiers, eg

    ```julia
    using A: f as f
    using B: f as g
    ```

    would make `B.f` available as `g`. Here, we are assuming that you did not use `using A` before, which would have brought `f` into the namespace.
3. When the names in question *do* share a meaning, it is common for one module to import it from another, or have a lightweight “base” package with the sole function of defining an interface like this, which can be used by other packages. It is conventional to have such package names end in `...Base` (which has nothing to do with Julia's `Base` module).
"""

# ╔═╡ 12b4cadd-ff5b-4828-94f7-96e625d73220
md"""
### Default top-level definitions and bare modules
"""

# ╔═╡ aabac7ed-d205-49f6-b020-f6b6a1cb48ee
md"""
Modules automatically contain `using Core`, `using Base`, and definitions of the [`eval`](@ref) and [`include`](@ref) functions, which evaluate expressions/files within the global scope of that module.
"""

# ╔═╡ 238832aa-4402-4d5d-a876-3c03c243ce34
md"""
If these default definitions are not wanted, modules can be defined using the keyword [`baremodule`](@ref) instead (note: `Core` is still imported). In terms of `baremodule`, a standard `module` looks like this:
"""

# ╔═╡ a16fbca0-ec2c-4c21-8594-ebc5779d31de
md"""
```
baremodule Mod

using Base

eval(x) = Core.eval(Mod, x)
include(p) = Base.include(Mod, p)

...

end
```
"""

# ╔═╡ 7ba4d6ef-a09e-4769-adee-4303fa70c20f
md"""
### Standard modules
"""

# ╔═╡ c00b6c6d-02f6-42c9-b870-98377c87ed3d
md"""
There are three important standard modules:
"""

# ╔═╡ 72f78c99-8325-4d70-9c20-b840a2b63a3b
md"""
  * [`Core`](@ref) contains all functionality \"built into\" the language.
  * [`Base`](@ref) contains basic functionality that is useful in almost all cases.
  * [`Main`](@ref) is the top-level module and the current module, when Julia is started.
"""

# ╔═╡ 05579a30-c2d1-4914-8e24-aeeb9a8e84a6
md"""
!!! note \"Standard library modules\"
    By default Julia ships with some standard library modules. These behave like regular Julia packages except that you don't need to install them explicitly. For example, if you wanted to perform some unit testing, you could load the `Test` standard library as follows:

    ```julia
    using Test
    ```
"""

# ╔═╡ 7a09add5-3d01-45cf-9cc4-cff6293fe9ff
md"""
## Submodules and relative paths
"""

# ╔═╡ c3346ddf-d8fa-44e7-b2b8-c318ca44c26c
md"""
Modules can contain *submodules*, nesting the same syntax `module ... end`. They can be used to introduce separate namespaces, which can be helpful for organizing complex codebases. Note that each `module` introduces its own [scope](@ref scope-of-variables), so submodules do not automatically “inherit” names from their parent.
"""

# ╔═╡ 34d839d7-d7ec-417c-a60a-91b05d337bab
md"""
It is recommended that submodules refer to other modules within the enclosing parent module (including the latter) using *relative module qualifiers* in `using` and `import` statements. A relative module qualifier starts with a period (`.`), which corresponds to the current module, and each successive `.` leads to the parent of the current module. This should be followed by modules if necessary, and eventually the actual name to access, all separated by `.`s.
"""

# ╔═╡ 8f01f8cd-6a4d-49ed-abbc-a229ecb2d271
md"""
Consider the following example, where the submodule `SubA` defines a function, which is then extended in its “sibling” module:
"""

# ╔═╡ 0e8115e8-3059-4756-8bec-54fc13e290be
md"""
```julia
module ParentModule

module SubA
export add_D  # exported interface
const D = 3
add_D(x) = x + D
end

using .SubA  # brings `add_D` into the namespace

export add_D # export it from ParentModule too

module SubB
import ..SubA: add_D # relative path for a “sibling” module
struct Infinity end
add_D(x::Infinity) = x
end

end
```
"""

# ╔═╡ a5beb075-5a95-4153-a083-3817a95585fe
md"""
You may see code in packages, which, in a similar situation, uses
"""

# ╔═╡ 15e883bf-12a6-4bc5-ae95-388b309dfbd3
md"""
```julia
import ParentModule.SubA: add_D
```
"""

# ╔═╡ 7beb25b2-00b3-4076-8c5e-5cf5874a40c7
md"""
However, this operates through [code loading](@ref code-loading), and thus only works if `ParentModule` is in a package. It is better to use relative paths.
"""

# ╔═╡ 32d1c157-e101-46f4-8da1-b554d29e26af
md"""
Note that the order of definitions also matters if you are evaluating values. Consider
"""

# ╔═╡ 0c30c075-5032-45ba-9c09-90ac82fe51db
md"""
```julia
module TestPackage

export x, y

x = 0

module Sub
using ..TestPackage
z = y # ERROR: UndefVarError: y not defined
end

y = 1

end
```
"""

# ╔═╡ 1e985bdf-4ff5-4e18-bd3b-ee812bad436a
md"""
where `Sub` is trying to use `TestPackage.y` before it was defined, so it does not have a value.
"""

# ╔═╡ dad2a623-b648-40e0-b47f-0e3e44b95a68
md"""
For similar reasons, you cannot use a cyclic ordering:
"""

# ╔═╡ 5210911e-11b6-4be4-a8b7-cd4a2f96cde2
md"""
```julia
module A

module B
using ..C # ERROR: UndefVarError: C not defined
end

module C
using ..B
end

end
```
"""

# ╔═╡ 6e829ed6-43a9-400b-9181-f86084575c5c
md"""
### Module initialization and precompilation
"""

# ╔═╡ 2930fe02-3bca-4d04-94e3-97abf6bdedfa
md"""
Large modules can take several seconds to load because executing all of the statements in a module often involves compiling a large amount of code. Julia creates precompiled caches of the module to reduce this time.
"""

# ╔═╡ 02f8c389-0daf-40bc-b3fe-c0f3bb64f2b5
md"""
The incremental precompiled module file are created and used automatically when using `import` or `using` to load a module.  This will cause it to be automatically compiled the first time it is imported. Alternatively, you can manually call [`Base.compilecache(modulename)`](@ref). The resulting cache files will be stored in `DEPOT_PATH[1]/compiled/`. Subsequently, the module is automatically recompiled upon `using` or `import` whenever any of its dependencies change; dependencies are modules it imports, the Julia build, files it includes, or explicit dependencies declared by [`include_dependency(path)`](@ref) in the module file(s).
"""

# ╔═╡ f7e9561e-d79c-471f-92c9-d6caf503b413
md"""
For file dependencies, a change is determined by examining whether the modification time (`mtime`) of each file loaded by `include` or added explicitly by `include_dependency` is unchanged, or equal to the modification time truncated to the nearest second (to accommodate systems that can't copy mtime with sub-second accuracy). It also takes into account whether the path to the file chosen by the search logic in `require` matches the path that had created the precompile file. It also takes into account the set of dependencies already loaded into the current process and won't recompile those modules, even if their files change or disappear, in order to avoid creating incompatibilities between the running system and the precompile cache.
"""

# ╔═╡ 6183821d-9caa-4f42-8539-cce9f1490f88
md"""
If you know that a module is *not* safe to precompile your module (for example, for one of the reasons described below), you should put `__precompile__(false)` in the module file (typically placed at the top). This will cause `Base.compilecache` to throw an error, and will cause `using` / `import` to load it directly into the current process and skip the precompile and caching. This also thereby prevents the module from being imported by any other precompiled module.
"""

# ╔═╡ 03239fd5-77b3-4819-b02d-a6c4126620a4
md"""
You may need to be aware of certain behaviors inherent in the creation of incremental shared libraries which may require care when writing your module. For example, external state is not preserved. To accommodate this, explicitly separate any initialization steps that must occur at *runtime* from steps that can occur at *compile time*. For this purpose, Julia allows you to define an `__init__()` function in your module that executes any initialization steps that must occur at runtime. This function will not be called during compilation (`--output-*`). Effectively, you can assume it will be run exactly once in the lifetime of the code. You may, of course, call it manually if necessary, but the default is to assume this function deals with computing state for the local machine, which does not need to be – or even should not be – captured in the compiled image. It will be called after the module is loaded into a process, including if it is being loaded into an incremental compile (`--output-incremental=yes`), but not if it is being loaded into a full-compilation process.
"""

# ╔═╡ 4cb3f1bc-d7fe-4eab-b814-7e7c50930691
md"""
In particular, if you define a `function __init__()` in a module, then Julia will call `__init__()` immediately *after* the module is loaded (e.g., by `import`, `using`, or `require`) at runtime for the *first* time (i.e., `__init__` is only called once, and only after all statements in the module have been executed). Because it is called after the module is fully imported, any submodules or other imported modules have their `__init__` functions called *before* the `__init__` of the enclosing module.
"""

# ╔═╡ 7b94f6f7-8ce2-48f6-9f16-061e5c8fd7a6
md"""
Two typical uses of `__init__` are calling runtime initialization functions of external C libraries and initializing global constants that involve pointers returned by external libraries.  For example, suppose that we are calling a C library `libfoo` that requires us to call a `foo_init()` initialization function at runtime. Suppose that we also want to define a global constant `foo_data_ptr` that holds the return value of a `void *foo_data()` function defined by `libfoo` – this constant must be initialized at runtime (not at compile time) because the pointer address will change from run to run.  You could accomplish this by defining the following `__init__` function in your module:
"""

# ╔═╡ 2d12e4b0-117a-4c7b-8f8f-c5857ed297f9
md"""
```julia
const foo_data_ptr = Ref{Ptr{Cvoid}}(0)
function __init__()
    ccall((:foo_init, :libfoo), Cvoid, ())
    foo_data_ptr[] = ccall((:foo_data, :libfoo), Ptr{Cvoid}, ())
    nothing
end
```
"""

# ╔═╡ c82910ba-3671-414e-a19e-d959eb8d900f
md"""
Notice that it is perfectly possible to define a global inside a function like `__init__`; this is one of the advantages of using a dynamic language. But by making it a constant at global scope, we can ensure that the type is known to the compiler and allow it to generate better optimized code. Obviously, any other globals in your module that depends on `foo_data_ptr` would also have to be initialized in `__init__`.
"""

# ╔═╡ 5b1a0573-2560-437d-a5aa-0140bd4cbf80
md"""
Constants involving most Julia objects that are not produced by [`ccall`](@ref) do not need to be placed in `__init__`: their definitions can be precompiled and loaded from the cached module image. This includes complicated heap-allocated objects like arrays. However, any routine that returns a raw pointer value must be called at runtime for precompilation to work ([`Ptr`](@ref) objects will turn into null pointers unless they are hidden inside an [`isbits`](@ref) object). This includes the return values of the Julia functions [`@cfunction`](@ref) and [`pointer`](@ref).
"""

# ╔═╡ c606dce9-7f62-49e0-a30d-ac98e097643f
md"""
Dictionary and set types, or in general anything that depends on the output of a `hash(key)` method, are a trickier case.  In the common case where the keys are numbers, strings, symbols, ranges, `Expr`, or compositions of these types (via arrays, tuples, sets, pairs, etc.) they are safe to precompile.  However, for a few other key types, such as `Function` or `DataType` and generic user-defined types where you haven't defined a `hash` method, the fallback `hash` method depends on the memory address of the object (via its `objectid`) and hence may change from run to run. If you have one of these key types, or if you aren't sure, to be safe you can initialize this dictionary from within your `__init__` function. Alternatively, you can use the [`IdDict`](@ref) dictionary type, which is specially handled by precompilation so that it is safe to initialize at compile-time.
"""

# ╔═╡ 63a2f6af-ba8c-4753-a8f9-0d5e8833e9b8
md"""
When using precompilation, it is important to keep a clear sense of the distinction between the compilation phase and the execution phase. In this mode, it will often be much more clearly apparent that Julia is a compiler which allows execution of arbitrary Julia code, not a standalone interpreter that also generates compiled code.
"""

# ╔═╡ cc3c7f0d-28b1-41b2-8bad-7fd803e59e6f
md"""
Other known potential failure scenarios include:
"""

# ╔═╡ 273427c7-9022-4b37-8e85-b35d6b0b500e
md"""
1. Global counters (for example, for attempting to uniquely identify objects). Consider the following code snippet:

    ```julia
    mutable struct UniquedById
        myid::Int
        let counter = 0
            UniquedById() = new(counter += 1)
        end
    end
    ```

    while the intent of this code was to give every instance a unique id, the counter value is recorded at the end of compilation. All subsequent usages of this incrementally compiled module will start from that same counter value.

    Note that `objectid` (which works by hashing the memory pointer) has similar issues (see notes on `Dict` usage below).

    One alternative is to use a macro to capture [`@__MODULE__`](@ref) and store it alone with the current `counter` value, however, it may be better to redesign the code to not depend on this global state.
2. Associative collections (such as `Dict` and `Set`) need to be re-hashed in `__init__`. (In the future, a mechanism may be provided to register an initializer function.)
3. Depending on compile-time side-effects persisting through load-time. Example include: modifying arrays or other variables in other Julia modules; maintaining handles to open files or devices; storing pointers to other system resources (including memory);
4. Creating accidental \"copies\" of global state from another module, by referencing it directly instead of via its lookup path. For example, (in global scope):

    ```julia
    #mystdout = Base.stdout #= will not work correctly, since this will copy Base.stdout into this module =#
    # instead use accessor functions:
    getstdout() = Base.stdout #= best option =#
    # or move the assignment into the runtime:
    __init__() = global mystdout = Base.stdout #= also works =#
    ```
"""

# ╔═╡ 0a1bd0b5-e504-41b6-9698-bad864a4b05c
md"""
Several additional restrictions are placed on the operations that can be done while precompiling code to help the user avoid other wrong-behavior situations:
"""

# ╔═╡ 19e91645-5ad0-47ed-82fb-37c069633e7a
md"""
1. Calling [`eval`](@ref) to cause a side-effect in another module. This will also cause a warning to be emitted when the incremental precompile flag is set.
2. `global const` statements from local scope after `__init__()` has been started (see issue #12010 for plans to add an error for this)
3. Replacing a module is a runtime error while doing an incremental precompile.
"""

# ╔═╡ 97e677f6-6d02-4efc-9217-33fd07171616
md"""
A few other points to be aware of:
"""

# ╔═╡ 3d934c99-13ea-4703-aa05-2ad5bbdc13f6
md"""
1. No code reload / cache invalidation is performed after changes are made to the source files themselves, (including by `Pkg.update`), and no cleanup is done after `Pkg.rm`
2. The memory sharing behavior of a reshaped array is disregarded by precompilation (each view gets its own copy)
3. Expecting the filesystem to be unchanged between compile-time and runtime e.g. [`@__FILE__`](@ref)/`source_path()` to find resources at runtime, or the BinDeps `@checked_lib` macro. Sometimes this is unavoidable. However, when possible, it can be good practice to copy resources into the module at compile-time so they won't need to be found at runtime.
4. `WeakRef` objects and finalizers are not currently handled properly by the serializer (this will be fixed in an upcoming release).
5. It is usually best to avoid capturing references to instances of internal metadata objects such as `Method`, `MethodInstance`, `MethodTable`, `TypeMapLevel`, `TypeMapEntry` and fields of those objects, as this can confuse the serializer and may not lead to the outcome you desire. It is not necessarily an error to do this, but you simply need to be prepared that the system will try to copy some of these and to create a single unique instance of others.
"""

# ╔═╡ 70df11a2-95ba-491b-8ed5-7b338665981f
md"""
It is sometimes helpful during module development to turn off incremental precompilation. The command line flag `--compiled-modules={yes|no}` enables you to toggle module precompilation on and off. When Julia is started with `--compiled-modules=no` the serialized modules in the compile cache are ignored when loading modules and module dependencies. `Base.compilecache` can still be called manually. The state of this command line flag is passed to `Pkg.build` to disable automatic precompilation triggering when installing, updating, and explicitly building packages.
"""

# ╔═╡ Cell order:
# ╟─77214aa0-9347-4b1c-a46d-e1c63a72e00f
# ╟─6b831527-021c-41d2-af0d-a29961cfa708
# ╟─c32f79b3-362d-40ba-97b5-294a84a4b1a9
# ╟─e9b9e13c-afe6-45f8-a4a9-d1b46dc01e91
# ╟─825decbe-2e95-427e-a06f-a4c7ea7ec523
# ╟─b120f61e-a381-4ee5-9096-3ad6d23c6bf8
# ╟─0a93d3a3-440e-46b3-8919-60f9328f7cc1
# ╟─9c1f165b-29f7-43c0-9c49-06769df76f78
# ╟─fa9f4ba3-92de-4932-be80-2e99cd6356cc
# ╟─fcb8385b-7aa9-472e-a3f0-7108d6d4dbe4
# ╟─95d7f4f4-d69c-4e80-b3a4-273d7704acea
# ╟─cb4e0302-01d2-4c60-b406-4214ccc56861
# ╠═ff4b3edc-0bfd-4440-8a0c-82791ba06236
# ╟─00e34d94-86b2-4181-bf18-6e70513f3efa
# ╟─1a7fd14c-0b3f-488a-b09a-8d714383ef1d
# ╟─d4e80b7e-b73c-4cb6-9d3e-25f630f6d608
# ╟─e273a568-823d-42f8-92ee-0675d1db2936
# ╟─07ef7ff0-a660-4e95-873b-ca7016b53b19
# ╟─55d1c547-991b-4c14-95d8-065ef2877574
# ╟─84634de6-fefb-4818-96a9-80953accc951
# ╟─7956bb90-11eb-437c-9df8-11292c38ab42
# ╟─802c4578-3cc1-4cf1-bc3c-fcf2bba958e1
# ╟─5377a785-0671-4f51-aa26-cf517d00e082
# ╟─c2b4c7f7-7917-4dad-8107-a3b04c40e891
# ╟─4a42428c-3345-4dcb-993a-dddd5dd3cfa1
# ╟─12ed701c-61a7-4ddc-9cbe-1d10c704f4ea
# ╟─f60b6a64-7918-4e02-b654-d5db5f1cfe41
# ╟─9f282c9f-98f1-4228-a24e-28e35da85ff1
# ╟─f67ceebc-1a4e-408e-be24-c60a17762c4b
# ╟─b419af3c-3de2-498f-aa1b-939a1e94b776
# ╟─19c2a10d-ba67-409f-af5a-47c261e9b409
# ╟─8454ba62-3016-48c2-9ddd-c0bd2cc1c806
# ╟─ee94e9e8-b081-4add-a1d4-f34f536fc7af
# ╟─d2bb710a-36d6-4cc9-8544-49a782026a31
# ╟─0641b550-807f-4ae3-8d27-9bcba8de3115
# ╟─9aeabfc6-c501-42fa-b79d-7dee41ffb84e
# ╟─df2beeaa-c0d4-483a-96c7-87f16051f4a2
# ╟─d04c83b0-ff52-402a-ab90-39cf8d978499
# ╟─e885481d-6714-4b1a-a78a-4a04913f8edd
# ╟─5a07e667-b940-419e-80be-b09528f5447f
# ╟─eb6fd374-ce65-40e0-8994-118be44e45fd
# ╟─3df56dec-0dff-4f6d-a0fb-919eb1cdcae8
# ╟─c2a2c8c5-5fef-44c9-8dc2-93f4c6e24f7f
# ╟─74e69a41-1d0e-4c92-a55c-a31bcaf0e14b
# ╟─c270ce6c-c3ed-42a7-bfbc-9df6c5d0a988
# ╟─c1b6d6e2-014a-4497-a954-72418e444054
# ╟─b8ccae8a-789d-4658-bc45-6d1cc42c0124
# ╟─15a51fd8-b14a-4c42-941f-8fbdbf9435d6
# ╟─653bada4-9294-4f16-a557-0b1096837a44
# ╟─8bea2062-a27d-4f78-97cd-10c7dc232ee7
# ╟─5be3a721-9c85-4b76-b5a7-ca0a822e68f4
# ╟─61ee5e09-8b4c-41ea-9673-8575f5fe5ed4
# ╟─1904a1d7-5520-4ca0-89f5-542ffeabf16f
# ╟─36556bda-3474-43ba-9677-f5455d028639
# ╟─79fea417-51ac-47d5-a7e2-4c474e0f9381
# ╟─0c1ea366-7203-48d4-8378-1963a5042c84
# ╟─5b64abaf-61b8-47ca-b51c-c89d2b912cf5
# ╟─90463b42-ca17-4807-b202-0ad56951bb89
# ╟─042a9ec3-eda4-49a8-9d83-338d88492130
# ╟─a274e2ed-0f7d-41c1-9bfc-a29cfd71d7d9
# ╟─804e42bc-b92c-4ffe-8777-fea3c574eda3
# ╟─1b40935a-2ffa-4ae2-ab15-f51e20ed2fe8
# ╟─41594361-129a-41ed-8fc1-2fc2fa407274
# ╟─41bd5c6f-8b68-47f1-a9b0-ac4041e6bb1d
# ╟─0976d7fd-332b-4e44-850d-1fe4cdda3cb9
# ╟─cd4e515b-87be-4734-9d78-c71eb10d193d
# ╟─f03b97d2-5979-4f77-880c-c8b0860b49ae
# ╟─c8b8dd7d-742b-4443-a8bb-11dceae54668
# ╟─25588fb6-208a-458e-99e5-0c758efc0d02
# ╟─12b4cadd-ff5b-4828-94f7-96e625d73220
# ╟─aabac7ed-d205-49f6-b020-f6b6a1cb48ee
# ╟─238832aa-4402-4d5d-a876-3c03c243ce34
# ╟─a16fbca0-ec2c-4c21-8594-ebc5779d31de
# ╟─7ba4d6ef-a09e-4769-adee-4303fa70c20f
# ╟─c00b6c6d-02f6-42c9-b870-98377c87ed3d
# ╟─72f78c99-8325-4d70-9c20-b840a2b63a3b
# ╟─05579a30-c2d1-4914-8e24-aeeb9a8e84a6
# ╟─7a09add5-3d01-45cf-9cc4-cff6293fe9ff
# ╟─c3346ddf-d8fa-44e7-b2b8-c318ca44c26c
# ╟─34d839d7-d7ec-417c-a60a-91b05d337bab
# ╟─8f01f8cd-6a4d-49ed-abbc-a229ecb2d271
# ╟─0e8115e8-3059-4756-8bec-54fc13e290be
# ╟─a5beb075-5a95-4153-a083-3817a95585fe
# ╟─15e883bf-12a6-4bc5-ae95-388b309dfbd3
# ╟─7beb25b2-00b3-4076-8c5e-5cf5874a40c7
# ╟─32d1c157-e101-46f4-8da1-b554d29e26af
# ╟─0c30c075-5032-45ba-9c09-90ac82fe51db
# ╟─1e985bdf-4ff5-4e18-bd3b-ee812bad436a
# ╟─dad2a623-b648-40e0-b47f-0e3e44b95a68
# ╟─5210911e-11b6-4be4-a8b7-cd4a2f96cde2
# ╟─6e829ed6-43a9-400b-9181-f86084575c5c
# ╟─2930fe02-3bca-4d04-94e3-97abf6bdedfa
# ╟─02f8c389-0daf-40bc-b3fe-c0f3bb64f2b5
# ╟─f7e9561e-d79c-471f-92c9-d6caf503b413
# ╟─6183821d-9caa-4f42-8539-cce9f1490f88
# ╟─03239fd5-77b3-4819-b02d-a6c4126620a4
# ╟─4cb3f1bc-d7fe-4eab-b814-7e7c50930691
# ╟─7b94f6f7-8ce2-48f6-9f16-061e5c8fd7a6
# ╟─2d12e4b0-117a-4c7b-8f8f-c5857ed297f9
# ╟─c82910ba-3671-414e-a19e-d959eb8d900f
# ╟─5b1a0573-2560-437d-a5aa-0140bd4cbf80
# ╟─c606dce9-7f62-49e0-a30d-ac98e097643f
# ╟─63a2f6af-ba8c-4753-a8f9-0d5e8833e9b8
# ╟─cc3c7f0d-28b1-41b2-8bad-7fd803e59e6f
# ╟─273427c7-9022-4b37-8e85-b35d6b0b500e
# ╟─0a1bd0b5-e504-41b6-9698-bad864a4b05c
# ╟─19e91645-5ad0-47ed-82fb-37c069633e7a
# ╟─97e677f6-6d02-4efc-9217-33fd07171616
# ╟─3d934c99-13ea-4703-aa05-2ad5bbdc13f6
# ╟─70df11a2-95ba-491b-8ed5-7b338665981f
