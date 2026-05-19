# Minimal reproducibility script for Example 1 and Example EC.1.
#
# Run from the root of SOSSubmodularity_Revision-main with:
#     julia --project=. scripts/run_example1_and_ec1.jl
#
# Expected output:
#     Example 1, t=2: PASS (infeasible)
#     Example 1, t=3: PASS (feasible)
#     Example EC.1, t=2: PASS (infeasible)
#     Example EC.1, t=3: PASS (feasible)
#
# This script intentionally does not rely on hand-written coefficient constraints.
# It constructs the same SDP coefficient-matching constraints programmatically,
# which avoids transcription errors and keeps the explicit SDP synchronized with
# the polynomial in Example 1.

using JuMP
using SumOfSquares
using DynamicPolynomials
using SCS

const FEASIBLE_STATUSES = Set([MOI.OPTIMAL, MOI.ALMOST_OPTIMAL])
const INFEASIBLE_STATUSES = Set([MOI.INFEASIBLE, MOI.ALMOST_INFEASIBLE])

# -----------------------------------------------------------------------------
# Shared polynomial data for Example 1
# -----------------------------------------------------------------------------

# Bit-mask representation of the multilinear extension F.
# Variable x_i is represented by bit (i-1).
function example1_terms()
    return Dict{UInt64, Float64}(
        UInt64(0b11111) =>  3.0,  # x1*x2*x3*x4*x5
        UInt64(0b00111) => -4.0,  # x1*x2*x3
        UInt64(0b01011) => -9.0,  # x1*x2*x4
        UInt64(0b11011) => -12.0, # x1*x2*x4*x5
        UInt64(0b10111) => -4.0,  # x1*x2*x3*x5
        UInt64(0b01111) => -4.0,  # x1*x2*x3*x4
        UInt64(0)       =>  2.0,
    )
end

function example1_polynomial(x)
    return 3*x[1]*x[2]*x[3]*x[4]*x[5] -
           4*x[3]*x[1]*x[2] -
           9*x[4]*x[1]*x[2] -
           12*x[1]*x[2]*x[4]*x[5] -
           4*x[1]*x[2]*x[3]*x[5] -
           4*x[1]*x[2]*x[3]*x[4] + 2
end

bit(i::Int) = UInt64(1) << (i - 1)
hasvar(mask::UInt64, i::Int) = (mask & bit(i)) != 0
removevars(mask::UInt64, i::Int, j::Int) = mask & ~bit(i) & ~bit(j)

function all_subsets_mask(vars::Vector{Int})
    masks = UInt64[0]
    for v in vars
        append!(masks, [m | bit(v) for m in copy(masks)])
    end
    return masks
end

function monomial_basis_masks(vars::Vector{Int}, t::Int)
    return sort([m for m in all_subsets_mask(vars) if count_ones(m) <= t])
end

# Coefficients of -d^2F/(dx_i dx_j) after normal form modulo x_k^2=x_k.
function negative_second_derivative_coeffs(i::Int, j::Int)
    coeffs = Dict{UInt64, Float64}()
    for (mask, c) in example1_terms()
        if hasvar(mask, i) && hasvar(mask, j)
            reduced = removevars(mask, i, j)
            coeffs[reduced] = get(coeffs, reduced, 0.0) - c
        end
    end
    return coeffs
end

function status_is_feasible(status)
    return status in FEASIBLE_STATUSES
end

function status_is_infeasible(status)
    return status in INFEASIBLE_STATUSES
end

function print_check(label::String, status, expected::Symbol)
    ok = expected == :feasible ? status_is_feasible(status) : status_is_infeasible(status)
    println(label, ": ", ok ? "PASS" : "FAIL", " (status = ", status, ")")
    return ok
end

# -----------------------------------------------------------------------------
# Example 1: SumOfSquares.jl formulation of Definition 6
# -----------------------------------------------------------------------------

function boolean_domain_for_pair(x, vars::Vector{Int})
    # Build {x_k in {0,1}: k in vars}.  The pair variables i,j are deliberately
    # omitted, matching I_2[x_{-i,j}] in Definition 6.
    expr = :( $(x[vars[1]]) * (1 - $(x[vars[1]])) == 0 )
    for idx in vars[2:end]
        expr = :($expr && $(x[idx]) * (1 - $(x[idx])) == 0)
    end
    return eval(:(@set $expr))
end

function check_example1_sos(t::Int; silent::Bool=true)
    n = 5
    @polyvar x[1:n]
    F = example1_polynomial(x)

    model = SOSModel(SCS.Optimizer)
    if silent
        set_silent(model)
    end

    for i in 1:n-1, j in i+1:n
        vars = [k for k in 1:n if k != i && k != j]
        domain = boolean_domain_for_pair(x, vars)
        p = -differentiate(differentiate(F, x[i]), x[j])
        @constraint(model, p >= 0, domain = domain, maxdegree = 2t)
    end

    optimize!(model)
    return termination_status(model)
end

# -----------------------------------------------------------------------------
# Example EC.1: explicit SDP coefficient matching for the same conditions
# -----------------------------------------------------------------------------

function add_pair_sdp_constraints!(model::Model, i::Int, j::Int, t::Int)
    vars = [k for k in 1:5 if k != i && k != j]
    z = monomial_basis_masks(vars, t)
    all_masks = sort(all_subsets_mask(vars))
    N = length(z)

    Q = @variable(model, [1:m, 1:m], PSD)

    # Coefficients of z'Qz after reducing x_k^2 to x_k.
    coeff_expr = Dict{UInt64, AffExpr}()
    for m in all_masks
        coeff_expr[m] = AffExpr(0.0)
    end
    for a in 1:N, b in a:N
        m = z[a] | z[b]
        if a == b
            add_to_expression!(coeff_expr[m], Q[a, b])
        else
            add_to_expression!(coeff_expr[m], 2.0, Q[a, b])
        end
    end

    target = negative_second_derivative_coeffs(i, j)
    for m in all_masks
        @constraint(model, coeff_expr[m] == get(target, m, 0.0))
    end

    return Q
end

function check_example_ec1_explicit_sdp(t::Int; silent::Bool=true)
    model = Model(SCS.Optimizer)
    if silent
        set_silent(model)
    end
    @objective(model, Min, 0)

    for i in 1:4, j in i+1:5
        add_pair_sdp_constraints!(model, i, j, t)
    end

    optimize!(model)
    return termination_status(model)
end

function main()
    ok = true

    st = check_example1_sos(2)
    ok &= print_check("Example 1, t=2", st, :infeasible)

    st = check_example1_sos(3)
    ok &= print_check("Example 1, t=3", st, :feasible)

    st = check_example_ec1_explicit_sdp(2)
    ok &= print_check("Example EC.1, t=2", st, :infeasible)

    st = check_example_ec1_explicit_sdp(3)
    ok &= print_check("Example EC.1, t=3", st, :feasible)

    if !ok
        error("One or more checks did not return the expected feasibility status.")
    end
end

main()
