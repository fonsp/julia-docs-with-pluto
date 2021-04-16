### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ 3817692e-a74c-46c3-bb0f-e2428a14b624
md"""
# [Code Loading](@id code-loading)
"""

# ╔═╡ e85daaed-52d9-4c29-bdea-11dc9672b212
md"""
!!! note
    This chapter covers the technical details of package loading. To install packages, use [`Pkg`](@ref Pkg), Julia's built-in package manager, to add packages to your active environment. To use packages already in your active environment, write `import X` or `using X`, as described in the [Modules documentation](@ref modules).
"""

# ╔═╡ 3521fbc4-e4e4-4a36-8243-fdffdf85ae68
md"""
## Definitions
"""

# ╔═╡ 4adddfb6-8080-4e26-aae6-d0314c38ef75
md"""
Julia has two mechanisms for loading code:
"""

# ╔═╡ cbad33a1-be3e-4457-b191-f409c6e5b082
md"""
1. **Code inclusion:** e.g. `include(\"source.jl\")`. Inclusion allows you to split a single program across multiple source files. The expression `include(\"source.jl\")` causes the contents of the file `source.jl` to be evaluated in the global scope of the module where the `include` call occurs. If `include(\"source.jl\")` is called multiple times, `source.jl` is evaluated multiple times. The included path, `source.jl`, is interpreted relative to the file where the `include` call occurs. This makes it simple to relocate a subtree of source files. In the REPL, included paths are interpreted relative to the current working directory, [`pwd()`](@ref).
2. **Package loading:** e.g. `import X` or `using X`. The import mechanism allows you to load a package—i.e. an independent, reusable collection of Julia code, wrapped in a module—and makes the resulting module available by the name `X` inside of the importing module. If the same `X` package is imported multiple times in the same Julia session, it is only loaded the first time—on subsequent imports, the importing module gets a reference to the same module. Note though, that `import X` can load different packages in different contexts: `X` can refer to one package named `X` in the main project but potentially to different packages also named `X` in each dependency. More on this below.
"""

# ╔═╡ 1c2a0ecc-836b-4ae5-9b51-3a2a31b3ad53
md"""
Code inclusion is quite straightforward and simple: it evaluates the given source file in the context of the caller. Package loading is built on top of code inclusion and serves a [different purpose](@ref modules). The rest of this chapter focuses on the behavior and mechanics of package loading.
"""

# ╔═╡ d4a5d581-651b-480a-a8a8-c7a1b173a195
md"""
A *package* is a source tree with a standard layout providing functionality that can be reused by other Julia projects. A package is loaded by `import X` or  `using X` statements. These statements also make the module named `X`—which results from loading the package code—available within the module where the import statement occurs. The meaning of `X` in `import X` is context-dependent: which `X` package is loaded depends on what code the statement occurs in. Thus, handling of `import X` happens in two stages: first, it determines **what** package is defined to be `X` in this context; second, it determines **where** that particular `X` package is found.
"""

# ╔═╡ 5218e266-e55e-4de8-aa09-0621eb120342
md"""
These questions are answered by searching through the project environments listed in [`LOAD_PATH`](@ref) for project files (`Project.toml` or `JuliaProject.toml`), manifest files (`Manifest.toml` or `JuliaManifest.toml`), or folders of source files.
"""

# ╔═╡ 78f03c0a-5856-4813-bfef-e074c9e81598
md"""
## Federation of packages
"""

# ╔═╡ 51b865d1-27ed-499b-a7a0-d75640328bf2
md"""
Most of the time, a package is uniquely identifiable simply from its name. However, sometimes a project might encounter a situation where it needs to use two different packages that share the same name. While you might be able fix this by renaming one of the packages, being forced to do so can be highly disruptive in a large, shared code base. Instead, Julia's code loading mechanism allows the same package name to refer to different packages in different components of an application.
"""

# ╔═╡ 11d7f9e0-b945-471e-a167-1b82e33197f0
md"""
Julia supports federated package management, which means that multiple independent parties can maintain both public and private packages and registries of packages, and that projects can depend on a mix of public and private packages from different registries. Packages from various registries are installed and managed using a common set of tools and workflows. The `Pkg` package manager that ships with Julia lets you install and manage your projects' dependencies. It assists in creating and manipulating project files (which describe what other projects that your project depends on), and manifest files (which snapshot exact versions of your project's complete dependency graph).
"""

# ╔═╡ 38ab2cce-9fdd-46a8-b622-02d5a32091df
md"""
One consequence of federation is that there cannot be a central authority for package naming. Different entities may use the same name to refer to unrelated packages. This possibility is unavoidable since these entities do not coordinate and may not even know about each other. Because of the lack of a central naming authority, a single project may end up depending on different packages that have the same name. Julia's package loading mechanism does not require package names to be globally unique, even within the dependency graph of a single project. Instead, packages are identified by [universally unique identifiers](https://en.wikipedia.org/wiki/Universally_unique_identifier) (UUIDs), which get assigned when each package is created. Usually you won't have to work directly with these somewhat cumbersome 128-bit identifiers since `Pkg` will take care of generating and tracking them for you. However, these UUIDs provide the definitive answer to the question of *\"what package does `X` refer to?\"*
"""

# ╔═╡ 9368d434-d32e-49c4-92c8-4934f2430b18
md"""
Since the decentralized naming problem is somewhat abstract, it may help to walk through a concrete scenario to understand the issue. Suppose you're developing an application called `App`, which uses two packages: `Pub` and  `Priv`. `Priv` is a private package that you created, whereas `Pub` is a public package that you use but don't control. When you created `Priv`, there was no public package by the name `Priv`. Subsequently, however, an unrelated package also named `Priv` has been published and become popular. In fact, the `Pub` package has started to use it. Therefore, when you next upgrade `Pub` to get the latest bug fixes and features, `App` will end up depending on two different packages named `Priv`—through no action of yours other than upgrading. `App` has a direct dependency on your private `Priv` package, and an indirect dependency, through `Pub`, on the new public `Priv` package. Since these two `Priv` packages are different but are both required for `App` to continue working correctly, the expression `import Priv` must refer to different `Priv` packages depending on whether it occurs in `App`'s code or in `Pub`'s code. To handle this, Julia's package loading mechanism distinguishes the two `Priv` packages by their UUID and picks the correct one based on its context (the module that called `import`). How this distinction works is determined by environments, as explained in the following sections.
"""

# ╔═╡ bffca062-8fd7-492d-8066-6f14d0f67eea
md"""
## Environments
"""

# ╔═╡ 67704d8d-ffd2-47ba-b697-bca12d933b59
md"""
An *environment* determines what `import X` and `using X` mean in various code contexts and what files these statements cause to be loaded. Julia understands two kinds of environments:
"""

# ╔═╡ ad0c4d10-c9d3-476e-9b23-d2df1b797d93
md"""
1. **A project environment** is a directory with a project file and an optional manifest file, and forms an *explicit environment*. The project file determines what the names and identities of the direct dependencies of a project are. The manifest file, if present, gives a complete dependency graph, including all direct and indirect dependencies, exact versions of each dependency, and sufficient information to locate and load the correct version.
2. **A package directory** is a directory containing the source trees of a set of packages as subdirectories, and forms an *implicit environment*. If `X` is a subdirectory of a package directory and `X/src/X.jl` exists, then the package `X` is available in the package directory environment and `X/src/X.jl` is the source file by which it is loaded.
"""

# ╔═╡ bc7d080d-a544-4ed7-bd00-276a08275f46
md"""
These can be intermixed to create **a stacked environment**: an ordered set of project environments and package directories, overlaid to make a single composite environment. The precedence and visibility rules then combine to determine which packages are available and where they get loaded from. Julia's load path forms a stacked environment, for example.
"""

# ╔═╡ f10f3eea-836b-468a-8e6e-3f27ad50b4d8
md"""
These environment each serve a different purpose:
"""

# ╔═╡ 03231d1c-0854-4acb-a8a1-8a03197ed99c
md"""
  * Project environments provide **reproducibility**. By checking a project environment into version control—e.g. a git repository—along with the rest of the project's source code, you can reproduce the exact state of the project and all of its dependencies. The manifest file, in particular, captures the exact version of every dependency, identified by a cryptographic hash of its source tree, which makes it possible for `Pkg` to retrieve the correct versions and be sure that you are running the exact code that was recorded for all dependencies.
  * Package directories provide **convenience** when a full carefully-tracked project environment is unnecessary. They are useful when you want to put a set of packages somewhere and be able to directly use them, without needing to create a project environment for them.
  * Stacked environments allow for **adding** tools to the primary environment. You can push an environment of development tools onto the end of the stack to make them available from the REPL and scripts, but not from inside packages.
"""

# ╔═╡ 0e47fd97-21cf-4418-af50-af01ade2acae
md"""
At a high-level, each environment conceptually defines three maps: roots, graph and paths. When resolving the meaning of `import X`, the roots and graph maps are used to determine the identity of `X`, while the paths map is used to locate the source code of `X`. The specific roles of the three maps are:
"""

# ╔═╡ de2df062-b3c3-4310-bbd7-9da8e1bda8ec
md"""
  * **roots:** `name::Symbol` ⟶ `uuid::UUID`

    An environment's roots map assigns package names to UUIDs for all the top-level dependencies that the environment makes available to the main project (i.e. the ones that can be loaded in `Main`). When Julia encounters `import X` in the main project, it looks up the identity of `X` as `roots[:X]`.
  * **graph:** `context::UUID` ⟶ `name::Symbol` ⟶ `uuid::UUID`

    An environment's graph is a multilevel map which assigns, for each `context` UUID, a map from names to UUIDs, similar to the roots map but specific to that `context`. When Julia sees `import X` in the code of the package whose UUID is `context`, it looks up the identity of `X` as `graph[context][:X]`. In particular, this means that `import X` can refer to different packages depending on `context`.
  * **paths:** `uuid::UUID` × `name::Symbol` ⟶ `path::String`

    The paths map assigns to each package UUID-name pair, the location of that package's entry-point source file. After the identity of `X` in `import X` has been resolved to a UUID via roots or graph (depending on whether it is loaded from the main project or a dependency), Julia determines what file to load to acquire `X` by looking up `paths[uuid,:X]` in the environment. Including this file should define a module named `X`. Once this package is loaded, any subsequent import resolving to the same `uuid` will create a new binding to the already-loaded package module.
"""

# ╔═╡ 354ada3b-60ce-4d8f-bcb4-9a514d30d5bd
md"""
Each kind of environment defines these three maps differently, as detailed in the following sections.
"""

# ╔═╡ 3fe0ccd7-0f08-41b3-b1b8-84e7fc83a8d3
md"""
!!! note
    For ease of understanding, the examples throughout this chapter show full data structures for roots, graph and paths. However, Julia's package loading code does not explicitly create these. Instead, it lazily computes only as much of each structure as it needs to load a given package.
"""

# ╔═╡ 2565ca06-1a8c-436f-95f7-dcc8581295ab
md"""
### Project environments
"""

# ╔═╡ 08ba74fd-f380-4ccd-8c31-e572839d5094
md"""
A project environment is determined by a directory containing a project file called `Project.toml`, and optionally a manifest file called `Manifest.toml`. These files may also be called `JuliaProject.toml` and `JuliaManifest.toml`, in which case `Project.toml` and `Manifest.toml` are ignored. This allows for coexistence with other tools that might consider files called `Project.toml` and `Manifest.toml` significant. For pure Julia projects, however, the names `Project.toml` and `Manifest.toml` are preferred.
"""

# ╔═╡ 28b8383c-cde1-4817-afa9-a3ca07e16531
md"""
The roots, graph and paths maps of a project environment are defined as follows:
"""

# ╔═╡ 27734319-262f-46a5-b4c3-230334562b48
md"""
**The roots map** of the environment is determined by the contents of the project file, specifically, its top-level `name` and `uuid` entries and its `[deps]` section (all optional). Consider the following example project file for the hypothetical application, `App`, as described earlier:
"""

# ╔═╡ 4ae83c7c-e4c5-4e70-9df4-f087bfd49c4f
md"""
```toml
name = \"App\"
uuid = \"8f986787-14fe-4607-ba5d-fbff2944afa9\"

[deps]
Priv = \"ba13f791-ae1d-465a-978b-69c3ad90f72b\"
Pub  = \"c07ecb7d-0dc9-4db7-8803-fadaaeaf08e1\"
```
"""

# ╔═╡ 72e290d9-0316-4e66-8daa-7d38da6f5d0b
md"""
This project file implies the following roots map, if it was represented by a Julia dictionary:
"""

# ╔═╡ 2c5cccdf-9b96-42c3-9ca6-38c3ea4dc9db
md"""
```julia
roots = Dict(
    :App  => UUID(\"8f986787-14fe-4607-ba5d-fbff2944afa9\"),
    :Priv => UUID(\"ba13f791-ae1d-465a-978b-69c3ad90f72b\"),
    :Pub  => UUID(\"c07ecb7d-0dc9-4db7-8803-fadaaeaf08e1\"),
)
```
"""

# ╔═╡ 5e78dfa6-9344-4fbe-b1ea-2e0fa81a5241
md"""
Given this roots map, in `App`'s code the statement `import Priv` will cause Julia to look up `roots[:Priv]`, which yields `ba13f791-ae1d-465a-978b-69c3ad90f72b`, the UUID of the `Priv` package that is to be loaded in that context. This UUID identifies which `Priv` package to load and use when the main application evaluates `import Priv`.
"""

# ╔═╡ c1f28e73-b361-413d-a0ea-652a23d25bd0
md"""
**The dependency graph** of a project environment is determined by the contents of the manifest file, if present. If there is no manifest file, graph is empty. A manifest file contains a stanza for each of a project's direct or indirect dependencies. For each dependency, the file lists the package's UUID and a source tree hash or an explicit path to the source code. Consider the following example manifest file for `App`:
"""

# ╔═╡ 062fc659-8184-4904-be2e-cccea8e62d80
md"""
```toml
[[Priv]] # the private one
deps = [\"Pub\", \"Zebra\"]
uuid = \"ba13f791-ae1d-465a-978b-69c3ad90f72b\"
path = \"deps/Priv\"

[[Priv]] # the public one
uuid = \"2d15fe94-a1f7-436c-a4d8-07a9a496e01c\"
git-tree-sha1 = \"1bf63d3be994fe83456a03b874b409cfd59a6373\"
version = \"0.1.5\"

[[Pub]]
uuid = \"c07ecb7d-0dc9-4db7-8803-fadaaeaf08e1\"
git-tree-sha1 = \"9ebd50e2b0dd1e110e842df3b433cb5869b0dd38\"
version = \"2.1.4\"

  [Pub.deps]
  Priv = \"2d15fe94-a1f7-436c-a4d8-07a9a496e01c\"
  Zebra = \"f7a24cb4-21fc-4002-ac70-f0e3a0dd3f62\"

[[Zebra]]
uuid = \"f7a24cb4-21fc-4002-ac70-f0e3a0dd3f62\"
git-tree-sha1 = \"e808e36a5d7173974b90a15a353b564f3494092f\"
version = \"3.4.2\"
```
"""

# ╔═╡ a29d19dd-4f21-4f01-96b5-bdad64249791
md"""
This manifest file describes a possible complete dependency graph for the `App` project:
"""

# ╔═╡ a0ada700-7800-4e3b-b19f-4f5991d81709
md"""
  * There are two different packages named `Priv` that the application uses. It uses a private package, which is a root dependency, and a public one, which is an indirect dependency through `Pub`. These are differentiated by their distinct UUIDs, and they have different deps:

      * The private `Priv` depends on the `Pub` and `Zebra` packages.
      * The public `Priv` has no dependencies.
  * The application also depends on the `Pub` package, which in turn depends on the public `Priv` and the same `Zebra` package that the private `Priv` package depends on.
"""

# ╔═╡ 1b82f1fd-58ef-48f7-851f-0ad518897e68
md"""
This dependency graph represented as a dictionary, looks like this:
"""

# ╔═╡ 1bbb9228-42a7-434f-b404-aa79c302e95b
md"""
```julia
graph = Dict(
    # Priv – the private one:
    UUID(\"ba13f791-ae1d-465a-978b-69c3ad90f72b\") => Dict(
        :Pub   => UUID(\"c07ecb7d-0dc9-4db7-8803-fadaaeaf08e1\"),
        :Zebra => UUID(\"f7a24cb4-21fc-4002-ac70-f0e3a0dd3f62\"),
    ),
    # Priv – the public one:
    UUID(\"2d15fe94-a1f7-436c-a4d8-07a9a496e01c\") => Dict(),
    # Pub:
    UUID(\"c07ecb7d-0dc9-4db7-8803-fadaaeaf08e1\") => Dict(
        :Priv  => UUID(\"2d15fe94-a1f7-436c-a4d8-07a9a496e01c\"),
        :Zebra => UUID(\"f7a24cb4-21fc-4002-ac70-f0e3a0dd3f62\"),
    ),
    # Zebra:
    UUID(\"f7a24cb4-21fc-4002-ac70-f0e3a0dd3f62\") => Dict(),
)
```
"""

# ╔═╡ bc848b07-7421-4458-8be3-a5c50f370fa6
md"""
Given this dependency `graph`, when Julia sees `import Priv` in the `Pub` package—which has UUID `c07ecb7d-0dc9-4db7-8803-fadaaeaf08e1`—it looks up:
"""

# ╔═╡ a81e8657-110e-4bd0-b76b-5062c30aeb06
md"""
```julia
graph[UUID(\"c07ecb7d-0dc9-4db7-8803-fadaaeaf08e1\")][:Priv]
```
"""

# ╔═╡ b633c515-f457-45af-8302-64c9cd2307dc
md"""
and gets `2d15fe94-a1f7-436c-a4d8-07a9a496e01c`, which indicates that in the context of the `Pub` package, `import Priv` refers to the public `Priv` package, rather than the private one which the app depends on directly. This is how the name `Priv` can refer to different packages in the main project than it does in one of its package's dependencies, which allows for duplicate names in the package ecosystem.
"""

# ╔═╡ f2fc36ce-9451-4f04-b67a-2c9438463555
md"""
What happens if `import Zebra` is evaluated in the main `App` code base? Since `Zebra` does not appear in the project file, the import will fail even though `Zebra` *does* appear in the manifest file. Moreover, if `import Zebra` occurs in the public `Priv` package—the one with UUID `2d15fe94-a1f7-436c-a4d8-07a9a496e01c`—then that would also fail since that `Priv` package has no declared dependencies in the manifest file and therefore cannot load any packages. The `Zebra` package can only be loaded by packages for which it appear as an explicit dependency in the manifest file: the  `Pub` package and one of the `Priv` packages.
"""

# ╔═╡ 5b5d99e2-4a2c-41f9-bfc7-d91a4ea39044
md"""
**The paths map** of a project environment is extracted from the manifest file. The path of a package `uuid` named `X` is determined by these rules (in order):
"""

# ╔═╡ dfeaa2a6-905f-4c42-b123-627ceea9e528
md"""
1. If the project file in the directory matches `uuid` and name `X`, then either:
"""

# ╔═╡ e07ee0a9-f6bb-435b-9a17-ced590113605
md"""
  * It has a toplevel `path` entry, then `uuid` will be mapped to that path, interpreted relative to the directory containing the project file.
  * Otherwise, `uuid` is mapped to  `src/X.jl` relative to the directory containing the project file.
"""

# ╔═╡ 692bbe09-8218-4cd4-819c-a3bfa994cfb5
md"""
2. If the above is not the case and the project file has a corresponding manifest file and the manifest contains a stanza matching `uuid` then:
"""

# ╔═╡ fadbd272-e60c-4971-86bd-dd0cce1090d0
md"""
  * If it has a `path` entry, use that path (relative to the directory containing the manifest file).
  * If it has a `git-tree-sha1` entry, compute a deterministic hash function of `uuid` and `git-tree-sha1`—call it `slug`—and look for a directory named `packages/X/$slug` in each directory in the Julia `DEPOT_PATH` global array. Use the first such directory that exists.
"""

# ╔═╡ 46440980-637d-44db-998b-afa8a336abe6
md"""
If any of these result in success, the path to the source code entry point will be either that result, the relative path from that result plus `src/X.jl`; otherwise, there is no path mapping for `uuid`. When loading `X`, if no source code path is found, the lookup will fail, and the user may be prompted to install the appropriate package version or to take other corrective action (e.g. declaring `X` as a dependency).
"""

# ╔═╡ 1bf24508-1d6f-4746-9f9b-944f62e0ec60
md"""
In the example manifest file above, to find the path of the first `Priv` package—the one with UUID `ba13f791-ae1d-465a-978b-69c3ad90f72b`—Julia looks for its stanza in the manifest file, sees that it has a `path` entry, looks at `deps/Priv` relative to the `App` project directory—let's suppose the `App` code lives in `/home/me/projects/App`—sees that `/home/me/projects/App/deps/Priv` exists and therefore loads `Priv` from there.
"""

# ╔═╡ ba47aa5a-59c1-4599-a878-b2f36f2d6c13
md"""
If, on the other hand, Julia was loading the *other* `Priv` package—the one with UUID `2d15fe94-a1f7-436c-a4d8-07a9a496e01c`—it finds its stanza in the manifest, see that it does *not* have a `path` entry, but that it does have a `git-tree-sha1` entry. It then computes the `slug` for this UUID/SHA-1 pair, which is `HDkrT` (the exact details of this computation aren't important, but it is consistent and deterministic). This means that the path to this `Priv` package will be `packages/Priv/HDkrT/src/Priv.jl` in one of the package depots. Suppose the contents of `DEPOT_PATH` is `[\"/home/me/.julia\", \"/usr/local/julia\"]`, then Julia will look at the following paths to see if they exist:
"""

# ╔═╡ 3417b0aa-1908-495d-8b77-c57024f50603
md"""
1. `/home/me/.julia/packages/Priv/HDkrT`
2. `/usr/local/julia/packages/Priv/HDkrT`
"""

# ╔═╡ 751d5c58-f7ce-44ab-a1ee-345f88b03edc
md"""
Julia uses the first of these that exists to try to load the public `Priv` package from the file `packages/Priv/HDKrT/src/Priv.jl` in the depot where it was found.
"""

# ╔═╡ d5284a87-3c22-4aa2-9cac-9372c9bc0dfa
md"""
Here is a representation of a possible paths map for our example `App` project environment, as provided in the Manifest given above for the dependency graph, after searching the local file system:
"""

# ╔═╡ 1976f8a2-5269-42fa-a1e9-cf021973f71a
md"""
```julia
paths = Dict(
    # Priv – the private one:
    (UUID(\"ba13f791-ae1d-465a-978b-69c3ad90f72b\"), :Priv) =>
        # relative entry-point inside `App` repo:
        \"/home/me/projects/App/deps/Priv/src/Priv.jl\",
    # Priv – the public one:
    (UUID(\"2d15fe94-a1f7-436c-a4d8-07a9a496e01c\"), :Priv) =>
        # package installed in the system depot:
        \"/usr/local/julia/packages/Priv/HDkr/src/Priv.jl\",
    # Pub:
    (UUID(\"c07ecb7d-0dc9-4db7-8803-fadaaeaf08e1\"), :Pub) =>
        # package installed in the user depot:
        \"/home/me/.julia/packages/Pub/oKpw/src/Pub.jl\",
    # Zebra:
    (UUID(\"f7a24cb4-21fc-4002-ac70-f0e3a0dd3f62\"), :Zebra) =>
        # package installed in the system depot:
        \"/usr/local/julia/packages/Zebra/me9k/src/Zebra.jl\",
)
```
"""

# ╔═╡ 139179de-bca6-468f-8d46-fda978cb3a10
md"""
This example map includes three different kinds of package locations (the first and third are part of the default load path):
"""

# ╔═╡ f1d85c52-53de-49ad-b74b-e3fc3a9e1f81
md"""
1. The private `Priv` package is \"[vendored](https://stackoverflow.com/a/35109534)\" inside the `App` repository.
2. The public `Priv` and `Zebra` packages are in the system depot, where packages installed and managed by the system administrator live. These are available to all users on the system.
3. The `Pub` package is in the user depot, where packages installed by the user live. These are only available to the user who installed them.
"""

# ╔═╡ a142a0b6-5af9-4bdd-9129-24c5e6b9bd35
md"""
### Package directories
"""

# ╔═╡ a4ec05d2-9a2e-498a-8cc6-6db23b891de9
md"""
Package directories provide a simpler kind of environment without the ability to handle name collisions. In a package directory, the set of top-level packages is the set of subdirectories that \"look like\" packages. A package `X` exists in a package directory if the directory contains one of the following \"entry point\" files:
"""

# ╔═╡ 46cb1050-ac20-4d58-8256-560203a47495
md"""
  * `X.jl`
  * `X/src/X.jl`
  * `X.jl/src/X.jl`
"""

# ╔═╡ 996cedb7-b1c8-49cc-93ff-0542737d5c95
md"""
Which dependencies a package in a package directory can import depends on whether the package contains a project file:
"""

# ╔═╡ 7fe27698-9289-4ebc-9281-78a2a65e7b8e
md"""
  * If it has a project file, it can only import those packages which are identified in the `[deps]` section of the project file.
  * If it does not have a project file, it can import any top-level package—i.e. the same packages that can be loaded in `Main` or the REPL.
"""

# ╔═╡ b4e519c3-2fd9-4172-ad91-43f64e5576cf
md"""
**The roots map** is determined by examining the contents of the package directory to generate a list of all packages that exist. Additionally, a UUID will be assigned to each entry as follows: For a given package found inside the folder `X`...
"""

# ╔═╡ 687b67d0-27e3-4e6d-a046-2ceae297119b
md"""
1. If `X/Project.toml` exists and has a `uuid` entry, then `uuid` is that value.
2. If `X/Project.toml` exists and but does *not* have a top-level UUID entry, `uuid` is a dummy UUID generated by hashing the canonical (real) path to `X/Project.toml`.
3. Otherwise (if `Project.toml` does not exist), then `uuid` is the all-zero [nil UUID](https://en.wikipedia.org/wiki/Universally_unique_identifier#Nil_UUID).
"""

# ╔═╡ a0e2a5c7-38af-4fa2-ad88-56cdb9c67f74
md"""
**The dependency graph** of a project directory is determined by the presence and contents of project files in the subdirectory of each package. The rules are:
"""

# ╔═╡ 084b2d24-88e2-4cfa-b962-1106b7cf6f79
md"""
  * If a package subdirectory has no project file, then it is omitted from graph and import statements in its code are treated as top-level, the same as the main project and REPL.
  * If a package subdirectory has a project file, then the graph entry for its UUID is the `[deps]` map of the project file, which is considered to be empty if the section is absent.
"""

# ╔═╡ ff6f5d54-4d49-43b5-98bf-404dd7446443
md"""
As an example, suppose a package directory has the following structure and content:
"""

# ╔═╡ a8bc10cb-5390-4131-8cf6-f0a0f8a9cf50
md"""
```
Aardvark/
    src/Aardvark.jl:
        import Bobcat
        import Cobra

Bobcat/
    Project.toml:
        [deps]
        Cobra = \"4725e24d-f727-424b-bca0-c4307a3456fa\"
        Dingo = \"7a7925be-828c-4418-bbeb-bac8dfc843bc\"

    src/Bobcat.jl:
        import Cobra
        import Dingo

Cobra/
    Project.toml:
        uuid = \"4725e24d-f727-424b-bca0-c4307a3456fa\"
        [deps]
        Dingo = \"7a7925be-828c-4418-bbeb-bac8dfc843bc\"

    src/Cobra.jl:
        import Dingo

Dingo/
    Project.toml:
        uuid = \"7a7925be-828c-4418-bbeb-bac8dfc843bc\"

    src/Dingo.jl:
        # no imports
```
"""

# ╔═╡ e52913e8-29e4-45a2-b137-989ca51004e3
md"""
Here is a corresponding roots structure, represented as a dictionary:
"""

# ╔═╡ 67dfd0b1-d0f3-4954-9985-7a50ea280501
md"""
```julia
roots = Dict(
    :Aardvark => UUID(\"00000000-0000-0000-0000-000000000000\"), # no project file, nil UUID
    :Bobcat   => UUID(\"85ad11c7-31f6-5d08-84db-0a4914d4cadf\"), # dummy UUID based on path
    :Cobra    => UUID(\"4725e24d-f727-424b-bca0-c4307a3456fa\"), # UUID from project file
    :Dingo    => UUID(\"7a7925be-828c-4418-bbeb-bac8dfc843bc\"), # UUID from project file
)
```
"""

# ╔═╡ 673d41bb-c947-4b95-ae40-348d2c8eab5c
md"""
Here is the corresponding graph structure, represented as a dictionary:
"""

# ╔═╡ 1d450102-65ca-400a-8e01-47cdb43db2cf
md"""
```julia
graph = Dict(
    # Bobcat:
    UUID(\"85ad11c7-31f6-5d08-84db-0a4914d4cadf\") => Dict(
        :Cobra => UUID(\"4725e24d-f727-424b-bca0-c4307a3456fa\"),
        :Dingo => UUID(\"7a7925be-828c-4418-bbeb-bac8dfc843bc\"),
    ),
    # Cobra:
    UUID(\"4725e24d-f727-424b-bca0-c4307a3456fa\") => Dict(
        :Dingo => UUID(\"7a7925be-828c-4418-bbeb-bac8dfc843bc\"),
    ),
    # Dingo:
    UUID(\"7a7925be-828c-4418-bbeb-bac8dfc843bc\") => Dict(),
)
```
"""

# ╔═╡ 6f6cb2f4-7e66-4939-a229-97a4debb4df7
md"""
A few general rules to note:
"""

# ╔═╡ 196d880e-033a-46c4-913c-1f07a63c4ce3
md"""
1. A package without a project file can depend on any top-level dependency, and since every package in a package directory is available at the top-level, it can import all packages in the environment.
2. A package with a project file cannot depend on one without a project file since packages with project files can only load packages in `graph` and packages without project files do not appear in `graph`.
3. A package with a project file but no explicit UUID can only be depended on by packages without project files since dummy UUIDs assigned to these packages are strictly internal.
"""

# ╔═╡ 4c8342f6-2a83-4770-9eb3-67d66849008f
md"""
Observe the following specific instances of these rules in our example:
"""

# ╔═╡ 3a2017ae-de4e-4b50-804b-3f4874809df9
md"""
  * `Aardvark` can import on any of `Bobcat`, `Cobra` or `Dingo`; it does import `Bobcat` and `Cobra`.
  * `Bobcat` can and does import both `Cobra` and `Dingo`, which both have project files with UUIDs and are declared as dependencies in `Bobcat`'s `[deps]` section.
  * `Bobcat` cannot depend on `Aardvark` since `Aardvark` does not have a project file.
  * `Cobra` can and does import `Dingo`, which has a project file and UUID, and is declared as a dependency in `Cobra`'s  `[deps]` section.
  * `Cobra` cannot depend on `Aardvark` or `Bobcat` since neither have real UUIDs.
  * `Dingo` cannot import anything because it has a project file without a `[deps]` section.
"""

# ╔═╡ 392b2017-b3d2-4b20-8b8e-c35728bfa9b5
md"""
**The paths map** in a package directory is simple: it maps subdirectory names to their corresponding entry-point paths. In other words, if the path to our example project directory is `/home/me/animals` then the `paths` map could be represented by this dictionary:
"""

# ╔═╡ 56a804fe-ebcd-43af-b8d1-cd46e1574197
md"""
```julia
paths = Dict(
    (UUID(\"00000000-0000-0000-0000-000000000000\"), :Aardvark) =>
        \"/home/me/AnimalPackages/Aardvark/src/Aardvark.jl\",
    (UUID(\"85ad11c7-31f6-5d08-84db-0a4914d4cadf\"), :Bobcat) =>
        \"/home/me/AnimalPackages/Bobcat/src/Bobcat.jl\",
    (UUID(\"4725e24d-f727-424b-bca0-c4307a3456fa\"), :Cobra) =>
        \"/home/me/AnimalPackages/Cobra/src/Cobra.jl\",
    (UUID(\"7a7925be-828c-4418-bbeb-bac8dfc843bc\"), :Dingo) =>
        \"/home/me/AnimalPackages/Dingo/src/Dingo.jl\",
)
```
"""

# ╔═╡ 6866f1a0-8df2-47ec-a34d-5e1bcb0c847a
md"""
Since all packages in a package directory environment are, by definition, subdirectories with the expected entry-point files, their `paths` map entries always have this form.
"""

# ╔═╡ 6aeab8c4-4cdf-4540-8210-d8f7a6ab0117
md"""
### Environment stacks
"""

# ╔═╡ 5485d8ac-c657-4f30-87ef-14da6afd15de
md"""
The third and final kind of environment is one that combines other environments by overlaying several of them, making the packages in each available in a single composite environment. These composite environments are called *environment stacks*. The Julia `LOAD_PATH` global defines an environment stack—the environment in which the Julia process operates. If you want your Julia process to have access only to the packages in one project or package directory, make it the only entry in `LOAD_PATH`. It is often quite useful, however, to have access to some of your favorite tools—standard libraries, profilers, debuggers, personal utilities, etc.—even if they are not dependencies of the project you're working on. By adding an environment containing these tools to the load path, you immediately have access to them in top-level code without needing to add them to your project.
"""

# ╔═╡ a5a14614-aff2-4c26-a4d4-0a6cbaf6bb1f
md"""
The mechanism for combining the roots, graph and paths data structures of the components of an environment stack is simple: they are merged as dictionaries, favoring earlier entries over later ones in the case of key collisions. In other words, if we have `stack = [env₁, env₂, …]` then we have:
"""

# ╔═╡ f44ca399-e0fe-4302-9ce0-fec4689357c5
md"""
```julia
roots = reduce(merge, reverse([roots₁, roots₂, …]))
graph = reduce(merge, reverse([graph₁, graph₂, …]))
paths = reduce(merge, reverse([paths₁, paths₂, …]))
```
"""

# ╔═╡ d8bdf5a3-bd8b-4023-b01b-04631a3ce039
md"""
The subscripted `rootsᵢ`, `graphᵢ` and `pathsᵢ` variables correspond to the subscripted environments, `envᵢ`, contained in `stack`. The `reverse` is present because `merge` favors the last argument rather than first when there are collisions between keys in its argument dictionaries. There are a couple of noteworthy features of this design:
"""

# ╔═╡ a50a2d0c-63b6-43e5-bd5c-101422c9a145
md"""
1. The *primary environment*—i.e. the first environment in a stack—is faithfully embedded in a stacked environment. The full dependency graph of the first environment in a stack is guaranteed to be included intact in the stacked environment including the same versions of all dependencies.
2. Packages in non-primary environments can end up using incompatible versions of their dependencies even if their own environments are entirely compatible. This can happen when one of their dependencies is shadowed by a version in an earlier environment in the stack (either by graph or path, or both).
"""

# ╔═╡ 21a7542a-96a9-4488-88cf-3ba2cae26189
md"""
Since the primary environment is typically the environment of a project you're working on, while environments later in the stack contain additional tools, this is the right trade-off: it's better to break your development tools but keep the project working. When such incompatibilities occur, you'll typically want to upgrade your dev tools to versions that are compatible with the main project.
"""

# ╔═╡ 289ed47f-7f61-44ff-9fd5-393e7c250fd2
md"""
## Conclusion
"""

# ╔═╡ ca768992-db2e-4e25-902e-208a1531a85e
md"""
Federated package management and precise software reproducibility are difficult but worthy goals in a package system. In combination, these goals lead to a more complex package loading mechanism than most dynamic languages have, but it also yields scalability and reproducibility that is more commonly associated with static languages. Typically, Julia users should be able to use the built-in package manager to manage their projects without needing a precise understanding of these interactions. A call to `Pkg.add(\"X\")` will add to the appropriate project and manifest files, selected via `Pkg.activate(\"Y\")`, so that a future call to `import X` will load `X` without further thought.
"""

# ╔═╡ Cell order:
# ╟─3817692e-a74c-46c3-bb0f-e2428a14b624
# ╟─e85daaed-52d9-4c29-bdea-11dc9672b212
# ╟─3521fbc4-e4e4-4a36-8243-fdffdf85ae68
# ╟─4adddfb6-8080-4e26-aae6-d0314c38ef75
# ╟─cbad33a1-be3e-4457-b191-f409c6e5b082
# ╟─1c2a0ecc-836b-4ae5-9b51-3a2a31b3ad53
# ╟─d4a5d581-651b-480a-a8a8-c7a1b173a195
# ╟─5218e266-e55e-4de8-aa09-0621eb120342
# ╟─78f03c0a-5856-4813-bfef-e074c9e81598
# ╟─51b865d1-27ed-499b-a7a0-d75640328bf2
# ╟─11d7f9e0-b945-471e-a167-1b82e33197f0
# ╟─38ab2cce-9fdd-46a8-b622-02d5a32091df
# ╟─9368d434-d32e-49c4-92c8-4934f2430b18
# ╟─bffca062-8fd7-492d-8066-6f14d0f67eea
# ╟─67704d8d-ffd2-47ba-b697-bca12d933b59
# ╟─ad0c4d10-c9d3-476e-9b23-d2df1b797d93
# ╟─bc7d080d-a544-4ed7-bd00-276a08275f46
# ╟─f10f3eea-836b-468a-8e6e-3f27ad50b4d8
# ╟─03231d1c-0854-4acb-a8a1-8a03197ed99c
# ╟─0e47fd97-21cf-4418-af50-af01ade2acae
# ╟─de2df062-b3c3-4310-bbd7-9da8e1bda8ec
# ╟─354ada3b-60ce-4d8f-bcb4-9a514d30d5bd
# ╟─3fe0ccd7-0f08-41b3-b1b8-84e7fc83a8d3
# ╟─2565ca06-1a8c-436f-95f7-dcc8581295ab
# ╟─08ba74fd-f380-4ccd-8c31-e572839d5094
# ╟─28b8383c-cde1-4817-afa9-a3ca07e16531
# ╟─27734319-262f-46a5-b4c3-230334562b48
# ╟─4ae83c7c-e4c5-4e70-9df4-f087bfd49c4f
# ╟─72e290d9-0316-4e66-8daa-7d38da6f5d0b
# ╟─2c5cccdf-9b96-42c3-9ca6-38c3ea4dc9db
# ╟─5e78dfa6-9344-4fbe-b1ea-2e0fa81a5241
# ╟─c1f28e73-b361-413d-a0ea-652a23d25bd0
# ╟─062fc659-8184-4904-be2e-cccea8e62d80
# ╟─a29d19dd-4f21-4f01-96b5-bdad64249791
# ╟─a0ada700-7800-4e3b-b19f-4f5991d81709
# ╟─1b82f1fd-58ef-48f7-851f-0ad518897e68
# ╟─1bbb9228-42a7-434f-b404-aa79c302e95b
# ╟─bc848b07-7421-4458-8be3-a5c50f370fa6
# ╟─a81e8657-110e-4bd0-b76b-5062c30aeb06
# ╟─b633c515-f457-45af-8302-64c9cd2307dc
# ╟─f2fc36ce-9451-4f04-b67a-2c9438463555
# ╟─5b5d99e2-4a2c-41f9-bfc7-d91a4ea39044
# ╟─dfeaa2a6-905f-4c42-b123-627ceea9e528
# ╟─e07ee0a9-f6bb-435b-9a17-ced590113605
# ╟─692bbe09-8218-4cd4-819c-a3bfa994cfb5
# ╟─fadbd272-e60c-4971-86bd-dd0cce1090d0
# ╟─46440980-637d-44db-998b-afa8a336abe6
# ╟─1bf24508-1d6f-4746-9f9b-944f62e0ec60
# ╟─ba47aa5a-59c1-4599-a878-b2f36f2d6c13
# ╟─3417b0aa-1908-495d-8b77-c57024f50603
# ╟─751d5c58-f7ce-44ab-a1ee-345f88b03edc
# ╟─d5284a87-3c22-4aa2-9cac-9372c9bc0dfa
# ╟─1976f8a2-5269-42fa-a1e9-cf021973f71a
# ╟─139179de-bca6-468f-8d46-fda978cb3a10
# ╟─f1d85c52-53de-49ad-b74b-e3fc3a9e1f81
# ╟─a142a0b6-5af9-4bdd-9129-24c5e6b9bd35
# ╟─a4ec05d2-9a2e-498a-8cc6-6db23b891de9
# ╟─46cb1050-ac20-4d58-8256-560203a47495
# ╟─996cedb7-b1c8-49cc-93ff-0542737d5c95
# ╟─7fe27698-9289-4ebc-9281-78a2a65e7b8e
# ╟─b4e519c3-2fd9-4172-ad91-43f64e5576cf
# ╟─687b67d0-27e3-4e6d-a046-2ceae297119b
# ╟─a0e2a5c7-38af-4fa2-ad88-56cdb9c67f74
# ╟─084b2d24-88e2-4cfa-b962-1106b7cf6f79
# ╟─ff6f5d54-4d49-43b5-98bf-404dd7446443
# ╟─a8bc10cb-5390-4131-8cf6-f0a0f8a9cf50
# ╟─e52913e8-29e4-45a2-b137-989ca51004e3
# ╟─67dfd0b1-d0f3-4954-9985-7a50ea280501
# ╟─673d41bb-c947-4b95-ae40-348d2c8eab5c
# ╟─1d450102-65ca-400a-8e01-47cdb43db2cf
# ╟─6f6cb2f4-7e66-4939-a229-97a4debb4df7
# ╟─196d880e-033a-46c4-913c-1f07a63c4ce3
# ╟─4c8342f6-2a83-4770-9eb3-67d66849008f
# ╟─3a2017ae-de4e-4b50-804b-3f4874809df9
# ╟─392b2017-b3d2-4b20-8b8e-c35728bfa9b5
# ╟─56a804fe-ebcd-43af-b8d1-cd46e1574197
# ╟─6866f1a0-8df2-47ec-a34d-5e1bcb0c847a
# ╟─6aeab8c4-4cdf-4540-8210-d8f7a6ab0117
# ╟─5485d8ac-c657-4f30-87ef-14da6afd15de
# ╟─a5a14614-aff2-4c26-a4d4-0a6cbaf6bb1f
# ╟─f44ca399-e0fe-4302-9ce0-fec4689357c5
# ╟─d8bdf5a3-bd8b-4023-b01b-04631a3ce039
# ╟─a50a2d0c-63b6-43e5-bd5c-101422c9a145
# ╟─21a7542a-96a9-4488-88cf-3ba2cae26189
# ╟─289ed47f-7f61-44ff-9fd5-393e7c250fd2
# ╟─ca768992-db2e-4e25-902e-208a1531a85e
