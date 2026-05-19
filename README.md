Contains the code for the paper Sum of Squares Submodularity. Default solver used is SCS. To use MOSEK, connect your lisence and set DEFAULT_SOLVER to Mosek. 

## Reproducing Example 1 and Example EC.1

From the repository root, run:

```bash
julia --project=. -e 'using Pkg; Pkg.instantiate()'
julia --project=. scripts/run_example1_and_ec1.jl
```

Expected result:

- Example 1 with `t=2`: infeasible
- Example 1 with `t=3`: feasible
- Example EC.1 with `t=2`: infeasible
- Example EC.1 with `t=3`: feasible

Depending on numerical tolerances, the solver status may be `INFEASIBLE` or `ALMOST_INFEASIBLE` for the infeasible cases, and `OPTIMAL` or `ALMOST_OPTIMAL` for the feasible cases.


## Launch notebooks

- [ExampleEC1 on Binder](https://mybinder.org/v2/gh/SOSSubmodularity/SOSSubmodularity_Revision/HEAD?filepath=ExampleEC1/ExampleEC1.ipynb)
- [Remark3 on Binder](https://mybinder.org/v2/gh/SOSSubmodularity/SOSSubmodularity_Revision/HEAD?filepath=Remark3/Remark3.ipynb)
- [Section41 on Binder](https://mybinder.org/v2/gh/SOSSubmodularity/SOSSubmodularity_Revision/HEAD?filepath=Section41/Section41.ipynb)
- [Section42 on Binder](https://mybinder.org/v2/gh/SOSSubmodularity/SOSSubmodularity_Revision/HEAD?filepath=Section42/Section42.ipynb)
- [Section43 on Binder](https://mybinder.org/v2/gh/SOSSubmodularity/SOSSubmodularity_Revision/HEAD?filepath=Section43/Section43.ipynb)
