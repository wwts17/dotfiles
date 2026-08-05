---
name: probabilistic-thinking
description: Evaluate high-uncertainty decisions using base rates, expected values, and Bayesian updates. Activate when making architectural choices under incomplete information or evaluating production risks.
---

# Probabilistic Decision Analysis

Evaluate decisions and risks quantitatively under condition of partial observability and uncertainty.

## Execution Framework

1. **Establish Base Rates (Priors):** Determine historical likelihood of failure modes or outcomes based on industry/system data.
2. **Calculate Expected Values:**
   $$\text{Expected Value (EV)} = \sum (\text{Probability}_i \times \text{Outcome Value}_i)$$
3. **Apply Bayesian Updating:** Adjust probability estimates as new empirical evidence or diagnostic logs arrive.
4. **Mitigate Asymmetric Risks:** Identify low-probability, high-consequence failure scenarios (fat-tail risks) and build circuit breakers.

## Deliverable Format

- **Probability Matrix & Base Rates**
- **Expected Value Comparison**
- **Risk Mitigation & Circuit Breakers**
