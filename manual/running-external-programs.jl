### A Pluto.jl notebook ###
# v0.14.1

using Markdown
using InteractiveUtils

# ╔═╡ cd5bf081-3fdf-4944-8000-111a64cdfaff
md"""
# Running External Programs
"""

# ╔═╡ e05fa7b6-652f-48c1-8122-593f70d02380
md"""
Julia borrows backtick notation for commands from the shell, Perl, and Ruby. However, in Julia, writing
"""

# ╔═╡ 04b47b06-14b9-408b-b67e-8f6b3f90e8a8
`echo hello`

# ╔═╡ 897ae0b1-ad70-415d-b021-a5b6b6eae0e9
md"""
differs in several aspects from the behavior in various shells, Perl, or Ruby:
"""

# ╔═╡ 7c5278b7-9b46-4a89-aed1-faaacc8ce2b4
md"""
  * Instead of immediately running the command, backticks create a [`Cmd`](@ref) object to represent the command. You can use this object to connect the command to others via pipes, [`run`](@ref) it, and [`read`](@ref) or [`write`](@ref) to it.
  * When the command is run, Julia does not capture its output unless you specifically arrange for it to. Instead, the output of the command by default goes to [`stdout`](@ref) as it would using `libc`'s `system` call.
  * The command is never run with a shell. Instead, Julia parses the command syntax directly, appropriately interpolating variables and splitting on words as the shell would, respecting shell quoting syntax. The command is run as `julia`'s immediate child process, using `fork` and `exec` calls.
"""

# ╔═╡ e033856f-a9d4-42d0-b141-e2fe2873d46a
md"""
!!! note
    The following assumes a Posix environment as on Linux or MacOS. On Windows, many similar commands, such as `echo` and `dir`, are not external programs and instead are built into the shell `cmd.exe` itself. One option to run these commands is to invoke `cmd.exe`, for example `cmd /C echo hello`. Alternatively Julia can be run inside a Posix environment such as Cygwin.
"""

# ╔═╡ 3a4eba6d-8b65-411c-b3e8-26e6fe462081
md"""
Here's a simple example of running an external program:
"""

# ╔═╡ c3bf556e-b38d-43be-8eb4-5b66d29128fb
mycommand = `echo hello`

# ╔═╡ 4e5558e6-72e6-4ab6-927b-10eda7c1ee84
typeof(mycommand)

# ╔═╡ daa9ad4c-301f-42f7-a350-7e4e28c685dc
run(mycommand);

# ╔═╡ 40d90efa-998d-44c1-ae4a-66910c4f05a2
md"""
The `hello` is the output of the `echo` command, sent to [`stdout`](@ref). The run method itself returns `nothing`, and throws an [`ErrorException`](@ref) if the external command fails to run successfully.
"""

# ╔═╡ 7f159417-6b4e-4524-8c6a-2f8f06d37c6d
md"""
If you want to read the output of the external command, [`read`](@ref) or [`readchomp`](@ref) can be used instead:
"""

# ╔═╡ f48e727b-2d2b-418b-8c53-8158775de747
read(`echo hello`, String)

# ╔═╡ dc65d82b-8dfc-40cd-a0c8-86e021dbabe3
readchomp(`echo hello`)

# ╔═╡ d59c34e3-b8cb-495c-97cb-090e7dc43767
md"""
More generally, you can use [`open`](@ref) to read from or write to an external command.
"""

# ╔═╡ ddfeda98-76b4-44dc-be60-76019e36d4d5
open(`less`, "w", stdout) do io
     for i = 1:3
         println(io, i)
     end
 end

# ╔═╡ 8de3c9b9-460b-43a2-a6a0-4b3261ecfcdd
md"""
The program name and the individual arguments in a command can be accessed and iterated over as if the command were an array of strings:
"""

# ╔═╡ 36d44809-2b6e-4089-a43f-180e8d6d2174
collect(`echo "foo bar"`)

# ╔═╡ 4350791b-d3de-4a30-a542-f33ae7f04951
`echo "foo bar"`[2]

# ╔═╡ f058cfba-7035-488f-955e-38f9ff2f4525
md"""
## [Interpolation](@id command-interpolation)
"""

# ╔═╡ 9cded3e0-d050-4ac5-bfea-502ac6394f29
md"""
Suppose you want to do something a bit more complicated and use the name of a file in the variable `file` as an argument to a command. You can use `$` for interpolation much as you would in a string literal (see [Strings](@ref)):
"""

# ╔═╡ b0a8c7d4-1a0b-419e-9c8f-b4fb93d81adf
file = "/etc/passwd"

# ╔═╡ 769319d0-8d7e-41a9-ae03-facd09e5981e
`sort $file`

# ╔═╡ 40a0244d-1a1c-48ad-b137-54fd5b6f6453
md"""
A common pitfall when running external programs via a shell is that if a file name contains characters that are special to the shell, they may cause undesirable behavior. Suppose, for example, rather than `/etc/passwd`, we wanted to sort the contents of the file `/Volumes/External HD/data.csv`. Let's try it:
"""

# ╔═╡ f4313820-5e60-4d31-ab57-12cc68671d27
file = "/Volumes/External HD/data.csv"

# ╔═╡ 2d467d6e-e524-4dc9-b94a-73a6babdb4c5
`sort $file`

# ╔═╡ a9a2ddf4-e5d7-49c7-8b50-ba8f48c4df01
md"""
How did the file name get quoted? Julia knows that `file` is meant to be interpolated as a single argument, so it quotes the word for you. Actually, that is not quite accurate: the value of `file` is never interpreted by a shell, so there's no need for actual quoting; the quotes are inserted only for presentation to the user. This will even work if you interpolate a value as part of a shell word:
"""

# ╔═╡ 7ff1f4bd-ce6e-4d13-a3d9-8085a7f2c1fd
path = "/Volumes/External HD"

# ╔═╡ d608c35c-6722-47b7-be4f-f841b3be04e6
name = "data"

# ╔═╡ f1cc5b16-9fa6-4c8a-bed9-72660c64c913
ext = "csv"

# ╔═╡ 7fe5fec0-d7ea-47fa-a4f2-0aa46d9eecad
`sort $path/$name.$ext`

# ╔═╡ ac31d08a-3fab-4b4d-b1fd-7822c25b5317
md"""
As you can see, the space in the `path` variable is appropriately escaped. But what if you *want* to interpolate multiple words? In that case, just use an array (or any other iterable container):
"""

# ╔═╡ f84c23a0-ca51-41f1-bfa8-41e7c7be8c1f
files = ["/etc/passwd","/Volumes/External HD/data.csv"]

# ╔═╡ 9b2d45fe-c8d5-42a1-8dc6-f0a6a43c17cb
`grep foo $files`

# ╔═╡ 36b62328-71f0-492d-9572-1dfa04039d64
md"""
If you interpolate an array as part of a shell word, Julia emulates the shell's `{a,b,c}` argument generation:
"""

# ╔═╡ 99c61953-4b9a-4fe5-99d3-91ceda03a53c
names = ["foo","bar","baz"]

# ╔═╡ 984ed935-f4b6-43fa-8750-268f4039bf85
`grep xylophone $names.txt`

# ╔═╡ f74b9161-f979-4c06-804e-64d44bbb72c9
md"""
Moreover, if you interpolate multiple arrays into the same word, the shell's Cartesian product generation behavior is emulated:
"""

# ╔═╡ b580904e-e52e-420b-8cca-a4f1dcbe1857
names = ["foo","bar","baz"]

# ╔═╡ f9d23d0f-90fd-489b-96ab-769410c45926
exts = ["aux","log"]

# ╔═╡ a6bf64ca-5c2f-41c5-870b-cea554936c10
`rm -f $names.$exts`

# ╔═╡ 9191340a-a99d-4b55-87bb-4069b6c51783
md"""
Since you can interpolate literal arrays, you can use this generative functionality without needing to create temporary array objects first:
"""

# ╔═╡ aee4d58e-3e6a-4932-8cc4-21656651a5b8
`rm -rf $["foo","bar","baz","qux"].$["aux","log","pdf"]`

# ╔═╡ c21f4269-779d-4b71-afb4-5ac2bb98eddb
md"""
## Quoting
"""

# ╔═╡ 6ae1e804-9525-42fa-8af5-dc883322566e
md"""
Inevitably, one wants to write commands that aren't quite so simple, and it becomes necessary to use quotes. Here's a simple example of a Perl one-liner at a shell prompt:
"""

# ╔═╡ 5e071df5-1a82-443d-a79b-c1be735aee52
md"""
```
sh$ perl -le '$|=1; for (0..3) { print }'
0
1
2
3
```
"""

# ╔═╡ 1b2f641e-6468-4498-8d2e-9a62d61cc50b
md"""
The Perl expression needs to be in single quotes for two reasons: so that spaces don't break the expression into multiple shell words, and so that uses of Perl variables like `$|` (yes, that's the name of a variable in Perl), don't cause interpolation. In other instances, you may want to use double quotes so that interpolation *does* occur:
"""

# ╔═╡ b9b6ec45-d91e-4edf-9c32-cdfb3fbdbc67
md"""
```
sh$ first=\"A\"
sh$ second=\"B\"
sh$ perl -le '$|=1; print for @ARGV' \"1: $first\" \"2: $second\"
1: A
2: B
```
"""

# ╔═╡ 493de3a6-47cb-4e92-ab6d-ca6657d48520
md"""
In general, the Julia backtick syntax is carefully designed so that you can just cut-and-paste shell commands as is into backticks and they will work: the escaping, quoting, and interpolation behaviors are the same as the shell's. The only difference is that the interpolation is integrated and aware of Julia's notion of what is a single string value, and what is a container for multiple values. Let's try the above two examples in Julia:
"""

# ╔═╡ 2b8df0dd-2ae6-4252-a698-75edfdab8898
A = `perl -le '$|=1; for (0..3) { print }'`

# ╔═╡ 5440c88e-55ff-4261-96f3-c161b0c0b980
run(A);

# ╔═╡ cf4af3e8-1ee7-4c9a-8411-7e031e7a9f64
first = "A"; second = "B";

# ╔═╡ aba13167-1d76-40a7-a0d5-8b329000de79
B = `perl -le 'print for @ARGV' "1: $first" "2: $second"`

# ╔═╡ ac43f255-602f-4fdf-aa15-6a656de90190
run(B);

# ╔═╡ d8e218d3-ef15-449b-a6fd-39f50eb09577
md"""
The results are identical, and Julia's interpolation behavior mimics the shell's with some improvements due to the fact that Julia supports first-class iterable objects while most shells use strings split on spaces for this, which introduces ambiguities. When trying to port shell commands to Julia, try cut and pasting first. Since Julia shows commands to you before running them, you can easily and safely just examine its interpretation without doing any damage.
"""

# ╔═╡ 8fbd6b29-9055-4a95-8924-029b114373a3
md"""
## Pipelines
"""

# ╔═╡ a2fadff0-63e6-48cc-8e20-9a5403b18424
md"""
Shell metacharacters, such as `|`, `&`, and `>`, need to be quoted (or escaped) inside of Julia's backticks:
"""

# ╔═╡ 6e6d3d3a-ef82-4b41-bf81-a6ab04585b54
run(`echo hello '|' sort`);

# ╔═╡ 8b784880-36c3-4af9-8477-9f2be1160ca8
run(`echo hello \| sort`);

# ╔═╡ bd7a92e6-c991-490b-b74d-1978f63d8e28
md"""
This expression invokes the `echo` command with three words as arguments: `hello`, `|`, and `sort`. The result is that a single line is printed: `hello | sort`. How, then, does one construct a pipeline? Instead of using `'|'` inside of backticks, one uses [`pipeline`](@ref):
"""

# ╔═╡ c55cfc1d-8ac5-431d-815b-e799dfd573a7
run(pipeline(`echo hello`, `sort`));

# ╔═╡ 9e8d6d5a-9ad7-423a-9811-28c79f62087f
md"""
This pipes the output of the `echo` command to the `sort` command. Of course, this isn't terribly interesting since there's only one line to sort, but we can certainly do much more interesting things:
"""

# ╔═╡ f87be98a-ae1c-441a-8f75-9d50d3406c65
run(pipeline(`cut -d: -f3 /etc/passwd`, `sort -n`, `tail -n5`))

# ╔═╡ 51e6b685-586d-44c0-934b-d076e3b1f868
md"""
This prints the highest five user IDs on a UNIX system. The `cut`, `sort` and `tail` commands are all spawned as immediate children of the current `julia` process, with no intervening shell process. Julia itself does the work to setup pipes and connect file descriptors that is normally done by the shell. Since Julia does this itself, it retains better control and can do some things that shells cannot.
"""

# ╔═╡ 7fad13a2-4f93-4425-af0f-36433f429ef8
md"""
Julia can run multiple commands in parallel:
"""

# ╔═╡ 6e5785cb-323d-465d-8053-40c500ae61ea
run(`echo hello` & `echo world`);

# ╔═╡ 43c921e6-9735-430d-8bef-1848abccf248
md"""
The order of the output here is non-deterministic because the two `echo` processes are started nearly simultaneously, and race to make the first write to the [`stdout`](@ref) descriptor they share with each other and the `julia` parent process. Julia lets you pipe the output from both of these processes to another program:
"""

# ╔═╡ c086fddd-174c-4efd-92e5-59cf8cc1b8ea
run(pipeline(`echo world` & `echo hello`, `sort`));

# ╔═╡ 39e2905f-218f-4950-a67f-82026284e340
md"""
In terms of UNIX plumbing, what's happening here is that a single UNIX pipe object is created and written to by both `echo` processes, and the other end of the pipe is read from by the `sort` command.
"""

# ╔═╡ 705c91da-fbfd-4d5b-9cdd-faed1a8b66a0
md"""
IO redirection can be accomplished by passing keyword arguments `stdin`, `stdout`, and `stderr` to the `pipeline` function:
"""

# ╔═╡ d44b7d30-55d1-40eb-b045-1f7c056892f1
md"""
```julia
pipeline(`do_work`, stdout=pipeline(`sort`, \"out.txt\"), stderr=\"errs.txt\")
```
"""

# ╔═╡ 83a74b40-5f0e-4068-bf4d-d0e270967617
md"""
### Avoiding Deadlock in Pipelines
"""

# ╔═╡ 2b05a7a4-465b-4caf-b908-a5e0b0f17217
md"""
When reading and writing to both ends of a pipeline from a single process, it is important to avoid forcing the kernel to buffer all of the data.
"""

# ╔═╡ cb150bdb-a3f1-482d-b2ac-b570637e4773
md"""
For example, when reading all of the output from a command, call `read(out, String)`, not `wait(process)`, since the former will actively consume all of the data written by the process, whereas the latter will attempt to store the data in the kernel's buffers while waiting for a reader to be connected.
"""

# ╔═╡ 27011e51-2639-43bb-8040-6a022260cfa5
md"""
Another common solution is to separate the reader and writer of the pipeline into separate [`Task`](@ref)s:
"""

# ╔═╡ eec0aa51-8b31-48ad-8c90-c35dbfff5f40
md"""
```julia
writer = @async write(process, \"data\")
reader = @async do_compute(read(process, String))
wait(writer)
fetch(reader)
```
"""

# ╔═╡ 47aea00b-a630-4334-8960-49527d028b01
md"""
### Complex Example
"""

# ╔═╡ 181ddee7-df9f-4420-9de4-9b9417361b54
md"""
The combination of a high-level programming language, a first-class command abstraction, and automatic setup of pipes between processes is a powerful one. To give some sense of the complex pipelines that can be created easily, here are some more sophisticated examples, with apologies for the excessive use of Perl one-liners:
"""

# ╔═╡ 48774181-d816-43aa-92c4-ec6103c9b870
prefixer(prefix, sleep) = `perl -nle '$|=1; print "'$prefix' ", $_; sleep '$sleep';'`;

# ╔═╡ d5955b9a-3445-4c7b-84b0-1e2b1c1c9ee8
run(pipeline(`perl -le '$|=1; for(0..5){ print; sleep 1 }'`, prefixer("A",2) & prefixer("B",2)));

# ╔═╡ d06516f7-0904-4a7c-901e-7d0409f98186
md"""
This is a classic example of a single producer feeding two concurrent consumers: one `perl` process generates lines with the numbers 0 through 5 on them, while two parallel processes consume that output, one prefixing lines with the letter \"A\", the other with the letter \"B\". Which consumer gets the first line is non-deterministic, but once that race has been won, the lines are consumed alternately by one process and then the other. (Setting `$|=1` in Perl causes each print statement to flush the [`stdout`](@ref) handle, which is necessary for this example to work. Otherwise all the output is buffered and printed to the pipe at once, to be read by just one consumer process.)
"""

# ╔═╡ baba8989-0dfb-48b2-a825-f7eef32cd530
md"""
Here is an even more complex multi-stage producer-consumer example:
"""

# ╔═╡ fe726adb-88c2-4262-9f14-e28f357844ab
run(pipeline(`perl -le '$|=1; for(0..5){ print; sleep 1 }'`,
     prefixer("X",3) & prefixer("Y",3) & prefixer("Z",3),
     prefixer("A",2) & prefixer("B",2)));

# ╔═╡ 6877506e-aac2-40e5-82cc-cfd8f354af23
md"""
This example is similar to the previous one, except there are two stages of consumers, and the stages have different latency so they use a different number of parallel workers, to maintain saturated throughput.
"""

# ╔═╡ ad531582-23cc-4839-9189-6ee5a398c169
md"""
We strongly encourage you to try all these examples to see how they work.
"""

# ╔═╡ Cell order:
# ╟─cd5bf081-3fdf-4944-8000-111a64cdfaff
# ╟─e05fa7b6-652f-48c1-8122-593f70d02380
# ╠═04b47b06-14b9-408b-b67e-8f6b3f90e8a8
# ╟─897ae0b1-ad70-415d-b021-a5b6b6eae0e9
# ╟─7c5278b7-9b46-4a89-aed1-faaacc8ce2b4
# ╟─e033856f-a9d4-42d0-b141-e2fe2873d46a
# ╟─3a4eba6d-8b65-411c-b3e8-26e6fe462081
# ╠═c3bf556e-b38d-43be-8eb4-5b66d29128fb
# ╠═4e5558e6-72e6-4ab6-927b-10eda7c1ee84
# ╠═daa9ad4c-301f-42f7-a350-7e4e28c685dc
# ╟─40d90efa-998d-44c1-ae4a-66910c4f05a2
# ╟─7f159417-6b4e-4524-8c6a-2f8f06d37c6d
# ╠═f48e727b-2d2b-418b-8c53-8158775de747
# ╠═dc65d82b-8dfc-40cd-a0c8-86e021dbabe3
# ╟─d59c34e3-b8cb-495c-97cb-090e7dc43767
# ╠═ddfeda98-76b4-44dc-be60-76019e36d4d5
# ╟─8de3c9b9-460b-43a2-a6a0-4b3261ecfcdd
# ╠═36d44809-2b6e-4089-a43f-180e8d6d2174
# ╠═4350791b-d3de-4a30-a542-f33ae7f04951
# ╟─f058cfba-7035-488f-955e-38f9ff2f4525
# ╟─9cded3e0-d050-4ac5-bfea-502ac6394f29
# ╠═b0a8c7d4-1a0b-419e-9c8f-b4fb93d81adf
# ╠═769319d0-8d7e-41a9-ae03-facd09e5981e
# ╟─40a0244d-1a1c-48ad-b137-54fd5b6f6453
# ╠═f4313820-5e60-4d31-ab57-12cc68671d27
# ╠═2d467d6e-e524-4dc9-b94a-73a6babdb4c5
# ╟─a9a2ddf4-e5d7-49c7-8b50-ba8f48c4df01
# ╠═7ff1f4bd-ce6e-4d13-a3d9-8085a7f2c1fd
# ╠═d608c35c-6722-47b7-be4f-f841b3be04e6
# ╠═f1cc5b16-9fa6-4c8a-bed9-72660c64c913
# ╠═7fe5fec0-d7ea-47fa-a4f2-0aa46d9eecad
# ╟─ac31d08a-3fab-4b4d-b1fd-7822c25b5317
# ╠═f84c23a0-ca51-41f1-bfa8-41e7c7be8c1f
# ╠═9b2d45fe-c8d5-42a1-8dc6-f0a6a43c17cb
# ╟─36b62328-71f0-492d-9572-1dfa04039d64
# ╠═99c61953-4b9a-4fe5-99d3-91ceda03a53c
# ╠═984ed935-f4b6-43fa-8750-268f4039bf85
# ╟─f74b9161-f979-4c06-804e-64d44bbb72c9
# ╠═b580904e-e52e-420b-8cca-a4f1dcbe1857
# ╠═f9d23d0f-90fd-489b-96ab-769410c45926
# ╠═a6bf64ca-5c2f-41c5-870b-cea554936c10
# ╟─9191340a-a99d-4b55-87bb-4069b6c51783
# ╠═aee4d58e-3e6a-4932-8cc4-21656651a5b8
# ╟─c21f4269-779d-4b71-afb4-5ac2bb98eddb
# ╟─6ae1e804-9525-42fa-8af5-dc883322566e
# ╟─5e071df5-1a82-443d-a79b-c1be735aee52
# ╟─1b2f641e-6468-4498-8d2e-9a62d61cc50b
# ╟─b9b6ec45-d91e-4edf-9c32-cdfb3fbdbc67
# ╟─493de3a6-47cb-4e92-ab6d-ca6657d48520
# ╠═2b8df0dd-2ae6-4252-a698-75edfdab8898
# ╠═5440c88e-55ff-4261-96f3-c161b0c0b980
# ╠═cf4af3e8-1ee7-4c9a-8411-7e031e7a9f64
# ╠═aba13167-1d76-40a7-a0d5-8b329000de79
# ╠═ac43f255-602f-4fdf-aa15-6a656de90190
# ╟─d8e218d3-ef15-449b-a6fd-39f50eb09577
# ╟─8fbd6b29-9055-4a95-8924-029b114373a3
# ╟─a2fadff0-63e6-48cc-8e20-9a5403b18424
# ╠═6e6d3d3a-ef82-4b41-bf81-a6ab04585b54
# ╠═8b784880-36c3-4af9-8477-9f2be1160ca8
# ╟─bd7a92e6-c991-490b-b74d-1978f63d8e28
# ╠═c55cfc1d-8ac5-431d-815b-e799dfd573a7
# ╟─9e8d6d5a-9ad7-423a-9811-28c79f62087f
# ╠═f87be98a-ae1c-441a-8f75-9d50d3406c65
# ╟─51e6b685-586d-44c0-934b-d076e3b1f868
# ╟─7fad13a2-4f93-4425-af0f-36433f429ef8
# ╠═6e5785cb-323d-465d-8053-40c500ae61ea
# ╟─43c921e6-9735-430d-8bef-1848abccf248
# ╠═c086fddd-174c-4efd-92e5-59cf8cc1b8ea
# ╟─39e2905f-218f-4950-a67f-82026284e340
# ╟─705c91da-fbfd-4d5b-9cdd-faed1a8b66a0
# ╟─d44b7d30-55d1-40eb-b045-1f7c056892f1
# ╟─83a74b40-5f0e-4068-bf4d-d0e270967617
# ╟─2b05a7a4-465b-4caf-b908-a5e0b0f17217
# ╟─cb150bdb-a3f1-482d-b2ac-b570637e4773
# ╟─27011e51-2639-43bb-8040-6a022260cfa5
# ╟─eec0aa51-8b31-48ad-8c90-c35dbfff5f40
# ╟─47aea00b-a630-4334-8960-49527d028b01
# ╟─181ddee7-df9f-4420-9de4-9b9417361b54
# ╠═48774181-d816-43aa-92c4-ec6103c9b870
# ╠═d5955b9a-3445-4c7b-84b0-1e2b1c1c9ee8
# ╟─d06516f7-0904-4a7c-901e-7d0409f98186
# ╟─baba8989-0dfb-48b2-a825-f7eef32cd530
# ╠═fe726adb-88c2-4262-9f14-e28f357844ab
# ╟─6877506e-aac2-40e5-82cc-cfd8f354af23
# ╟─ad531582-23cc-4839-9189-6ee5a398c169
