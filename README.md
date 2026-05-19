Contains the code for the paper Sum of Squares Submodularity. Default solver used is SCS to allow for running on Binder. To use MOSEK, connect your licence and set DEFAULT_SOLVER to Mosek. 

## Example 1 and Example EC.1

The notebooks below reproduce the feasibility statements in Example 1 and Example EC.1.

- `Example1/Example1.ipynb`: checks t-sos-submodularity of F using the SumOfSquares.jl formulation. It verifies that `t=2` is infeasible and `t=3` is feasible.
- `ExampleEC1/ExampleEC1.ipynb`: checks t-sos-submodularity of F using the explicit SDP formulation. It verifies that `t=2` is infeasible and `t=3` is feasible.

Both notebooks can be run in Binder using **Kernel → Restart & Run All**


## Launch notebooks

- [ExampleEC1 on Binder](https://mybinder.org/v2/gh/SOSSubmodularity/SOSSubmodularity_Revision/HEAD?filepath=ExampleEC1/ExampleEC1.ipynb)
- [Remark3 on Binder](https://mybinder.org/v2/gh/SOSSubmodularity/SOSSubmodularity_Revision/HEAD?filepath=Remark3/Remark3.ipynb)
- [Section41 on Binder](https://mybinder.org/v2/gh/SOSSubmodularity/SOSSubmodularity_Revision/HEAD?filepath=Section41/Section41.ipynb)
- [Section42 on Binder](https://mybinder.org/v2/gh/SOSSubmodularity/SOSSubmodularity_Revision/HEAD?filepath=Section42/Section42.ipynb)
- [Section43 on Binder](https://mybinder.org/v2/gh/SOSSubmodularity/SOSSubmodularity_Revision/HEAD?filepath=Section43/Section43.ipynb)
