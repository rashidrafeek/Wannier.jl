# # Real-space Wannier functions of graphene

#=
```@meta
CurrentModule = Wannier
```
=#

#=
In this tutorial, we will disentangle the WFs of 2D graphene, and visualize
their shapes in real space.

!!! note

    Different from previous tutorials, the `amn/mmn/eig/unk` files in this tutorial
    are generated by the [`DFTK.jl`](https://github.com/JuliaMolSim/DFTK.jl/) package.
    Refer to the [`WannierDatasets/datasets/graphene/generator`](https://github.com/qiaojunfeng/WannierDatasets/tree/main/datasets/graphene/generator)
    folder for more information.
=#

# ## Preparation
# Load the package
using Wannier
using Wannier.Datasets

#=
## Model construction
=#
model = load_dataset("graphene")

#=
## Disentanglement and maximal localization

The [`disentangle`](@ref) function disentangles and maximally localizes the spread
functional, and returns the gauge matrices `U`,
=#
U = disentangle(model);

# The initial spread is
omega(model)

# The final spread is
omega(model, U)

#=
## Write real space WFs

Now assign the `U` back to the `model`,
=#
model.U .= U;

#=
The [`write_realspace_wf`](@ref) function reads the `UNK` files,
compute the real space WFs in a `n_supercells`-sized super cell,
and write them to `xsf` files,
=#
write_realspace_wf("wjl", model; unkdir=dataset"graphene", n_supercells=3, format=:xsf)

#=
Now, open the `wjl_00001.xsf`, etc. files with a 3D
visualizer, e.g., `vesta`, to have a look at the WFs!

!!! note

    To save storage, we use a very coarse kpoint grid and
    reduced sampling of the real space grid, thus the resolution
    are bad, rerun the calculation with a finer kpoint grid and
    visualize them again.
=#

using JSServe  # hide
Page(; exportable=true, offline=true)  # hide
#=
We also provide a simple plotting package
[`WannierPlots.jl`](https://github.com/qiaojunfeng/WannierPlots.jl)
for quick Visualization of band structure, real space WFs, etc.

First, load the plotting packages
=#
using WGLMakie
set_theme!(; resolution=(800, 800))
using WannierPlots
#=
!!! tip

    Here we want to show the WFs in this web page, so we first load `WGLMakie`.
    When you use the `WannierPlots` package in REPL, you can first load `GLMakie`,
    then the WFs will be shown in a standalone window.
=#
# Read the 1st WF
xsf = read_xsf("wjl_00001.xsf");
# Visualize with `WannierPlots.jl`,
pos = map(xsf.atom_positions) do pos  # to fractional coordinates
    inv(xsf.primvec) * pos
end
atom_numbers = parse.(Int, xsf.atoms)  # to integer atomic numbers
plot_wf(xsf.rgrid, xsf.W, xsf.primvec, pos, atom_numbers)

#=
## Compute WF centers in realspace

There are some other functions that might be useful for evaluating operators
in real space, e.g., computing WF centers.

First we need to read the `UNK` files, and construct the real space WFs
in a `3 * 3 * 1`-sized super cell (i.e., `model.kgrid`),
=#
rgrid, W = read_realspace_wf(model, model.kgrid)
#=
The real space WFs `W`, are defined on the grid `rgrid`.

To compute WF centers, invoke
=#
center(rgrid, W)
# columns are the WF centers in Cartesian coordinates.

# Compare with WF center computed in reciprocal space,
center(model)

#=
and yes, they are different, the z coordinate is wrongly computed
in the real space because the WFs are truncated along z (you can
see this by a 3D visualizer). If we translate the `rgrid` by
half of the `c` axis along z, then the WFs are complete, and the
real space WF centers are much closer to the reciprocal space results.

!!! note

    Because we are using a coarsely sampled real space grid in
    the `UNK` files, the WF centers can be improved by
    rerun the calculation with a more refined real space grid.
=#

#=
That's all about real space!
=#