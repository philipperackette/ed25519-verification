# Schoof's Algorithm Explained

*A pedagogical walkthrough: what each computation does, why the algorithm works, and why it is exponentially faster than exhaustive counting. Abstract definitions are followed immediately by concrete examples on a small curve, so that every mathematical object is anchored to something you can verify by hand.*

---

## Running example

Throughout this document, every abstract concept is illustrated on the following small curve:

```
E : Y² = X³ + 1    over F_7
```

This curve has coefficients `a = 0`, `b = 1`, and the prime field has `p = 7` elements. The group structure and Frobenius action are small enough to verify by hand, while exhibiting all the features that make Schoof's algorithm work.

---

## 1. Notation and conventions

**Prime field.**
Let `p` be a prime number. The **finite field** with `p` elements is denoted **F_p**. Concretely, F_p = {0, 1, 2, ..., p-1} with addition and multiplication performed modulo p.

**Elliptic curve.**
We consider a curve in short Weierstrass form over F_p:

```
E : Y² = X³ + aX + b
```

where the discriminant `Δ = -16(4a³ + 27b²)` is nonzero modulo p. The **affine points** are the pairs `(x, y)` satisfying this equation. To these we adjoin the **point at infinity** O, which is the identity element of the group law.

> **Example.** For `Y² = X³ + 1` over F_7 (so `a = 0`, `b = 1`):
> `Δ = -16(0 + 27) = -16 · 27 ≡ 6 · 6 = 36 ≡ 1 (mod 7)`.
> Since 1 ≠ 0, the curve is non-singular. ✓

**Algebraic closure.**
The symbol `F̄_p` denotes the algebraic closure of `F_p`. Every nonconstant polynomial with coefficients in F_p splits completely over F̄_p. It contains every finite extension:

```
F̄_p = ⋃_{n≥1} F_{p^n}
```

**Rational points.**
If `K` is any field containing the coefficients of E, then `E(K)` denotes the set of points whose coordinates lie in K, together with O. The most important cases are:
- `E(F_p)`: the **F_p-rational points**, with coordinates in the base field.
- `E(F̄_p)`: all points over all extensions of F_p.

A point may have coordinates lying in F_{p^k} for some k > 1, belonging to E(F̄_p) but not to E(F_p). The quantity we want to compute is `#E(F_p)`.

> **Example.** We enumerate E(F_7) for `Y² = X³ + 1` by testing each x ∈ {0, …, 6}:
>
> | x | x³+1 mod 7 | Square mod 7? | Points |
> |---|---|---|---|
> | 0 | 1 | Yes (1²=1, 6²=1) | (0,1), (0,6) |
> | 1 | 2 | Yes (3²=9≡2, 4²=16≡2) | (1,3), (1,4) |
> | 2 | 9≡2 | Yes | (2,3), (2,4) |
> | 3 | 28≡0 | Yes (0²=0) | (3,0) |
> | 4 | 65≡2 | Yes | (4,3), (4,4) |
> | 5 | 126≡0 | Yes | (5,0) |
> | 6 | 217≡0 | Yes | (6,0) |
>
> Together with O: **#E(F_7) = 12**. (11 affine points + O.)

**Scalar multiplication.**
For a point P on the curve and an integer m, `[m]P` means the sum of P with itself m times. In particular, `[0]P = O`. The inverse of `(x, y)` on a Weierstrass curve is `(x, -y)`.

**Torsion points.**
A point P is a **torsion point** if `[m]P = O` for some positive integer m. For a prime `l ≠ p`, the **l-torsion subgroup** is:

```
E[l] = { P ∈ E(F̄_p) : [l]P = O }
```

This subgroup is isomorphic to `(Z/lZ)²` and has exactly `l²` elements. Most of these lie in extension fields of F_p.

> **Example.** For l = 2 on our curve. The 2-torsion points have y = 0 (since [2]P = O iff P = -P iff -y = y iff 2y = 0, and since char ≠ 2 this means y = 0). From the table, the affine 2-torsion points in E(F_7) are (3,0), (5,0), (6,0). With O, we get E[2] ∩ E(F_7) = {O, (3,0), (5,0), (6,0)}: exactly 2² = 4 elements. The full group E[2] lies in E(F_7) for this specific curve. ✓

**Frobenius endomorphism.**
The map

```
φ : E(F̄_p) → E(F̄_p)
    (x, y)  ↦  (x^p, y^p)
```

is an **endomorphism** of the elliptic curve: it respects the group law, meaning φ(P + Q) = φ(P) + φ(P). By **Fermat's little theorem**, `a^p ≡ a (mod p)` for every `a ∈ F_p`. Therefore φ fixes every F_p-rational point — and moves every point whose coordinates lie strictly in an extension field.

> **Example.** On our curve over F_7:
> - φ(0, 1) = (0^7, 1^7) = (0, 1). Fixed, as expected for a rational point. ✓
> - φ(3, 0) = (3^7, 0^7) = (3, 0). Fixed. ✓
> - For a point (α, β) ∈ E(F_{7³}) \ E(F_7), we have α^7 ≠ α, so φ moves it to a different point.

---

## 2. The point-counting problem

The integer `t` defined by

```
#E(F_p) = p + 1 - t
```

is called the **trace of Frobenius**. **Hasse's theorem** guarantees:

```
|t| ≤ 2√p
```

Point counting is equivalent to computing t. The Hasse bound tells us that t lives in a short interval: once we know t modulo M for some `M > 4√p`, there is exactly one integer in `[−2√p, 2√p]` consistent with our congruence, so t is determined.

> **Example.** For our curve: `t = 7 + 1 - 12 = -4`.
> Hasse bound: `|t| = 4 ≤ 2√7 ≈ 5.29`. ✓
>
> The bound tells us t is one of eleven integers: {−5, −4, …, 5}.
> We need M > 4√7 ≈ 10.6 to uniquely recover t from congruences.
> The product `M = 2 × 3 × 5 = 30 > 10.6` suffices.

---

## 3. Why exhaustive counting is hopeless

The naive method loops over every x ∈ F_p, computes `f(x) = x³ + ax + b`, tests whether f(x) is a quadratic residue, and counts. This costs roughly p Legendre symbol computations.

For the Ed25519 prime `p = 2^255 - 19 ≈ 5.8 × 10^76`, this means roughly 10^77 field operations. At 10^18 operations per second on optimized hardware, this would take about 10^51 years — many orders of magnitude longer than the age of the universe.

Schoof's algorithm brings the cost down to polynomial in `log p`. For Ed25519, the complete verification runs on commodity hardware in tens of hours.

---

## 4. The Frobenius endomorphism and the Frobenius identity

The central algebraic fact is:

**Theorem.** *For an elliptic curve E over F_p with trace of Frobenius t, the Frobenius endomorphism satisfies:*

```
φ² − [t]φ + [p] = 0     in End(E)
```

*Applied to any point P ∈ E(F̄_p):*

```
φ²(P) + [p]P = [t]φ(P)
```

This is the **characteristic polynomial of Frobenius**. It is the algebraic engine of Schoof's algorithm: it encodes the unknown integer t as an equation between three operations on curve points.

> **Geometric intuition.** The l-torsion group E[l] ≅ (Z/lZ)² is a 2-dimensional module over Z/lZ. The Frobenius φ acts on it as a linear map. By the Cayley-Hamilton theorem, any linear map on a 2-dimensional space satisfies its own characteristic polynomial. The characteristic polynomial of φ|_{E[l]} is `X² − tX + p`, and the theorem asserts that φ satisfies this polynomial — that is, `φ²(P) − [t]φ(P) + [p]P = O` for every P ∈ E[l].

> **Verification on a 2-torsion point.** Take P = (3, 0) ∈ E(F_7), which has order 2 (so [2]P = O).
>
> - φ(P) = (3^7, 0^7) = (3, 0) = P (Frobenius fixes F_7-rational points).
> - φ²(P) = P.
> - [p]P = [7]P. Since [2]P = O, we have [6]P = O, so [7]P = [6]P + P = P.
> - LHS: φ²(P) + [p]P = P + P = [2]P = O.
> - RHS: [t]φ(P) = [−4]P. Since [2]P = O, [4]P = O, [−4]P = O.
> - LHS = RHS = O. ✓

---

## 5. Strategy: computing t modulo small primes

Instead of finding t directly, Schoof computes `t mod l` for each of a set of small primes l, then applies the **Chinese Remainder Theorem (CRT)**.

**Proposition.** *If M = l₁ × l₂ × ⋯ × lₖ > 4√p, then there is at most one integer t with `|t| ≤ 2√p` in any residue class modulo M.*

*Proof.* If t₁ ≡ t₂ (mod M) and |t₁ − t₂| < M, then t₁ = t₂. Since |t₁ − t₂| ≤ 4√p < M, this applies. ∎

> **CRT example.** For our curve (p=7, t=−4):
>
> - t mod 2 = 0
> - t mod 3 = 2 (since −4 ≡ 2 mod 3)
> - t mod 5 = 1 (since −4 ≡ 1 mod 5)
>
> M = 2 × 3 × 5 = 30 > 4√7 ≈ 10.6. ✓
>
> **Reconstruction:** We seek an even T with T ≡ 2 (mod 3) and T ≡ 1 (mod 5), with T ∈ [0, 30).
> The even numbers ≡ 2 (mod 3) in [0, 30) are: 2, 8, 14, 20, 26.
> Of these, 26 ≡ 1 (mod 5). So T = 26.
> The representative in [−15, 15) is 26 − 30 = **−4**. ✓
>
> For Ed25519 (`p ≈ 2^255`), M must exceed 4√p ≈ 2^128, requiring the product of all primes from 2 to 103 — exactly the 27 primes processed in the 54-hour verification run.

---

## 6. Why the l-torsion is the right arena

**Lemma.** *If P ∈ E[l] and m ≡ n (mod l), then [m]P = [n]P.*

*Proof.* [m]P − [n]P = [m − n]P = [lk]P = [k]([l]P) = [k]O = O. ∎

Therefore, on E[l], the Frobenius identity reduces to:

```
φ²(P) + [q]P = [τ]φ(P)     for all P ∈ E[l]
```

where `q = p mod l` (a small number) and `τ = t mod l` (the unknown). The huge integers p and t have been replaced by residues smaller than l.

> **Example.** For l = 3 on our curve: q = 7 mod 3 = 1, τ = (−4) mod 3 = 2.
> The identity becomes: φ²(P) + [1]P = [2]φ(P) for all P ∈ E[3].
>
> Check on P = (0, 1) ∈ E[3]:
> - φ(P) = (0, 1) = P (rational point, fixed by Frobenius).
> - φ²(P) = P.
> - LHS: P + [1]P = [2]P.
> - RHS: [2]φ(P) = [2]P.
> - LHS = RHS. ✓
>
> We compute [2](0,1) using the doubling formula. With a=0: λ = (3x²+a)/(2y) = 0, so x' = 0, y' = 0 − 1 = −1 ≡ 6. Thus [2](0,1) = (0,6) = −(0,1). ✓

---

## 7. Division polynomials

**Definition.** The **l-th division polynomial** ψ_l is a univariate polynomial in x (with coefficients expressed in terms of a and b) whose roots in F̄_p are exactly the **x-coordinates of the nonzero l-torsion points**.

Its degree is:

```
deg(ψ_l) = (l² − 1) / 2
```

The first four are (for f = x³+ax+b, denoting y² = f):

```
ψ₁ = 1
ψ₂ = 2y    (treated as 1 in the monic convention, with y² = f)
ψ₃ = 3x⁴ + 6ax² + 12bx − a²
ψ₄ = 4y · (x⁶ + 5ax⁴ + 20bx³ − 5a²x² − 4abx − 8b² − a³)
```

Higher division polynomials are computed via the recurrence:

```
ψ_{2m+1} = ψ_{m+2} ψ_m³ − ψ_{m−1} ψ_{m+1}³    (m even)
ψ_{2m+1} = ψ_{m+2} ψ_m³ · f² − ψ_{m−1} ψ_{m+1}³   (m odd, absorbing y factors)
ψ_{2m}   = ψ_m · (ψ_{m+2} ψ_{m−1}² − ψ_{m−2} ψ_{m+1}²)
```

(The exact form depends on conventions for handling even indices, which involve y-factors. In `ed25519_verify.cpp`, all division polynomials are expressed purely as polynomials in x by substituting y² = f whenever it appears.)

> **Example: ψ₃ for Y² = X³ + 1 over F_7 (a=0, b=1).**
>
> ```
> ψ₃ = 3x⁴ + 6·0·x² + 12·1·x − 0² = 3x⁴ + 12x
> ```
>
> Reduced mod 7 (since 12 ≡ 5):
>
> ```
> ψ₃ ≡ 3x⁴ + 5x = x(3x³ + 5)    over F_7
> ```
>
> **Degree:** 4 = (3² − 1)/2. ✓
>
> **Roots of x(3x³+5):**
>
> - Root x = 0: straightforward.
> - Roots of 3x³+5 = 0, i.e., x³ ≡ −5/3 ≡ 2·5 = 10 ≡ 3 (mod 7).
>   Testing x = 1, …, 6: the cubes mod 7 are {1, 2³=1, 3³=6, 4³=1, 5³=6, 6³=6} = {1, 6}.
>   The value 3 is not a cube in F_7, so **3x³+5 = 0 has no root in F_7**.
>   Its three roots lie in the extension field F_{7³}.
>
> **Interpretation:**
> - The root x = 0 in F_7 corresponds to the two 3-torsion points (0,1) and (0,6) that lie in E(F_7).
> - The three roots in F_{7³} correspond to the remaining 6 nonzero 3-torsion points in E(F_{7³}) \ E(F_7).
> - Total: 4 distinct x-values × 2 points each = 8 nonzero 3-torsion points, plus O: 9 = 3² elements in E[3]. ✓
>
> **Verification that (0,1) has order 3:** We computed [2](0,1) = (0,6) = −(0,1). Therefore [3](0,1) = [2](0,1) + (0,1) = (0,6) + (0,1). Since (0,6) = −(0,1), this sum equals O. ✓

---

## 8. The polynomial quotient ring

The decisive conceptual step is to replace the explicit (and mostly inaccessible) torsion points by a symbolic, universal representative.

**The ring F_p[X] / (ψ_l).**
The polynomial ring `F_p[X]` consists of all polynomials with coefficients in F_p. The **quotient ring** `F_p[X] / (ψ_l)` is the ring of polynomials reduced modulo ψ_l:

> Every polynomial f(X) is replaced by its remainder r(X) upon division by ψ_l. Two polynomials are identified if they have the same remainder. Arithmetic (addition, multiplication) is ordinary polynomial arithmetic, followed by reduction mod ψ_l.

The elements of `F_p[X]/(ψ_l)` can be represented as polynomials of degree < deg(ψ_l) = (l²−1)/2. In this ring, `ψ_l(X) = 0` by definition: the formal variable X satisfies the relation imposed by ψ_l.

**What this means.** Since the roots of ψ_l are exactly the x-coordinates of nonzero l-torsion points, X "is" such an x-coordinate — a generic one, subject only to the algebraic relation ψ_l(X) = 0. We can do arithmetic with X without knowing which specific torsion point we are working with.

**Classical analogy.** The complex numbers C can be constructed as `R[X]/(X²+1)`: real polynomials reduced modulo X²+1. In this ring, X satisfies X²+1=0, so X²=−1: X plays the role of i. Every complex number a+bi corresponds to the polynomial a+bX. The construction F_p[X]/(ψ_l) is the exact same idea, with ψ_l in place of X²+1 and the l-torsion x-coordinate in place of i.

> **Example.** In `R₃ = F_7[X] / (ψ₃)` where `ψ₃ = 3X⁴ + 5X`:
>
> The imposed relation is `3X⁴ + 5X ≡ 0`, giving `X⁴ ≡ 3X` (multiplying by 3⁻¹ = 5 mod 7, since 3·5=15≡1, and −5·5 = −25 ≡ 3 mod 7).
>
> This allows us to reduce any polynomial of degree ≥ 4:
>
> | Power | Reduction | Result |
> |---|---|---|
> | X⁴ | ≡ 3X | 3X |
> | X⁵ = X·X⁴ | ≡ X·3X | 3X² |
> | X⁶ = X·X⁵ | ≡ X·3X² | 3X³ |
> | X⁷ = X·X⁶ | ≡ X·3X³ = 3X⁴ ≡ 3·3X | 9X ≡ 2X |
>
> So **X^7 ≡ 2X in R₃**.
>
> **Meaning.** The Frobenius maps the x-coordinate of a 3-torsion point α to α^7. In R₃, this becomes X^7 ≡ 2X. So for the generic nonzero 3-torsion point with x-coordinate X, the Frobenius image has x-coordinate 2X.
>
> This single polynomial expression simultaneously captures the Frobenius action on all four distinct nonzero 3-torsion x-coordinates, without our needing to know any of them explicitly.
>
> **Sanity check:** For the rational torsion point (0,1), the x-coordinate is 0. The Frobenius gives 0^7=0, and 2·0=0. ✓ For a root α of 3x³+5=0 in F_{7³}, the computation X^7 ≡ 2X in the ring implies α^7 = 2α, which can be verified directly but requires working in F_{7³}.

Similarly:

```
X^{49} = (X^7)^7 ≡ (2X)^7 = 2^7 · X^7 ≡ 2^7 · 2X = 2^8 X
         ≡ 2^8 mod 7 · X = 4X        (since 2^3=8≡1 mod 7, so 2^8=2^(3·2+2)=4)
```

So **X^{49} ≡ 4X in R₃**, representing the x-coordinate of φ²(P).

---

## 9. The special case l = 2

For l = 2, the division polynomial approach is replaced by a simpler criterion. The 2-torsion points have y = 0, so the affine 2-torsion x-coordinates are exactly the roots of `f(x) = x³ + ax + b` in F_p.

**Criterion:** t ≡ 0 (mod 2) iff `gcd(f(x), x^p − x)` has positive degree over F_p.

The polynomial `x^p − x` vanishes on every element of F_p (by Fermat). So the gcd detects whether f and x^p−x share a common root in F_p — i.e., whether E has a rational 2-torsion point, which happens iff 2 | #E iff t ≡ 0 (mod 2).

> **Example.** For `Y² = X³ + 1` over F_7: we compute `x^7 mod (x³+1)`.
>
> Since `x³ ≡ −1` in `F_7[x]/(x³+1)`:
> - x⁴ = x·x³ ≡ −x
> - x⁶ = (x³)² ≡ 1
> - x⁷ = x·x⁶ ≡ x
>
> So `x^7 − x ≡ 0 mod (x³+1)`, meaning `x³+1 | x^7−x`.
>
> Therefore `gcd(x³+1, x^7−x) = x³+1`, degree 3 > 0. Conclusion: **t ≡ 0 (mod 2)**. ✓
>
> The roots of x³+1 in F_7 are exactly the x-coordinates of rational 2-torsion points. Indeed:
> 3³+1=28≡0, 5³+1=126≡0, 6³+1=217≡0 (mod 7). These are x=3,5,6, corresponding to (3,0),(5,0),(6,0). ✓
>
> For comparison: if #E were odd, f(x) would have no root in F_p, gcd would be 1, and t ≡ 1 (mod 2).

---

## 10. Step by step: what the algorithm computes

For each odd prime l, working in the ring `R_l = F_p[X]/(ψ_l)`:

**Step 1 — Build ψ_l.**
The division polynomial ψ_l is computed from the recurrence, starting from ψ₁, ψ₂, ψ₃, ψ₄. Its degree is (l²−1)/2. For l=103 (the last prime used for Ed25519), this degree is 5304.

**Step 2 — Compute X^p mod ψ_l.**
By **fast polynomial exponentiation** (repeated squaring in R_l): compute X, X², X⁴, X^8, …, X^{2^k}, combining them to get X^p. Each squaring takes a polynomial multiplication in R_l followed by reduction mod ψ_l.

This gives a polynomial of degree < (l²−1)/2 representing the **x-coordinate of φ(P)**.

**Step 3 — Compute X^{p²} mod ψ_l.**
Apply the same procedure to X^p to get (X^p)^p, or equivalently compute `(X^p mod ψ_l)^p mod ψ_l` using the polynomial X^p from Step 2 as the base.

This gives the **x-coordinate of φ²(P)**.

**Step 4 — Compute q = p mod l.**
A small integer in {0, 1, …, l−1}. The scalar multiplication [p] on E[l] is replaced by [q].

**Step 5 — Compute the x-coordinate of [q]P in R_l.**
Using the division polynomial formula for x([q]P) expressed as a ratio of polynomials in ψ_{q±1} and ψ_q.

**Step 6 — Compute the x-coordinate of φ²(P) + [q]P in R_l.**
Using the Weierstrass group addition formula, expressed entirely as polynomial operations in R_l.

**Step 7 — Compute the y-factors.**
The y-coordinate of φ(P) = (x^p, y^p) satisfies:

```
y^p = y · (y²)^{(p−1)/2} = y · f(x)^{(p−1)/2}
```

The **y-factor** `f(X)^{(p−1)/2} mod ψ_l` is computed by fast exponentiation in R_l. It encodes the sign change (if any) that the Frobenius introduces in the y-coordinate.

Similarly, `f(X)^{(p²−1)/2} mod ψ_l` gives the y-factor of φ²(P).

**Step 8 — Test τ = 0.**
Compare the x-coordinate of φ²(P) with the x-coordinate of [q]P (they are equal iff the points differ only by a sign). Then compare y-factors to determine whether φ²(P) = −[q]P (giving τ = 0) or φ²(P) = +[q]P (giving a different τ). The x-test alone cannot distinguish these two cases.

**Step 9 — Test τ = 1, 2, …, (l−1)/2.**
For each candidate, compute the x-coordinate of [τ]φ(P) in R_l and compare with the x-coordinate of φ²(P) + [q]P. An equality of polynomials in R_l means the x-coordinates match for all nonzero l-torsion points simultaneously.

**Step 10 — Resolve the sign.**
An x-match proves `φ²(P) + [q]P = ε · [τ]φ(P)` with ε = ±1 unknown. Compare the y-factors of both sides. If they agree: t ≡ +τ (mod l). If they disagree (one is the negative of the other): t ≡ −τ (mod l).

**Step 11 — CRT update.**
Combine the new congruence t ≡ τ_l (mod l) with the accumulated product using CRT, then multiply M by l.

---

## 11. The y-factor: why x alone is not enough

On a Weierstrass curve, the points `(x, y)` and `(x, −y)` share the same x-coordinate. Consequently, an x-coordinate equality in R_l proves only:

```
φ²(P) + [q]P = ε · [τ]φ(P)    with ε = ±1 unknown
```

If ε = +1, then t ≡ τ (mod l). If ε = −1, then t ≡ −τ (mod l). These two values can differ significantly (e.g., for l=31 and τ=15: +15 vs −15 ≡ 16 mod 31).

The sign is resolved by comparing **y-factors**. Under Frobenius:

```
y^p = y · f(x)^{(p−1)/2}
```

The exponent (p−1)/2 is the exponent used in Euler's criterion for quadratic residuosity. For any concrete x ∈ F_p, the factor `f(x)^{(p−1)/2}` is either +1 (if f(x) is a nonzero square) or −1 (if f(x) is a non-square). In the ring R_l, `f(X)^{(p−1)/2}` is a polynomial that evaluates to ±1 at each root of ψ_l, simultaneously encoding the sign of y^p for all l-torsion x-coordinates.

The sign test compares the y-numerators of `φ²(P) + [q]P` and `[τ]φ(P)` after normalizing denominators. Equality selects ε = +1; opposite numerators select ε = −1.

> **Concrete example.** Take x = 0 in E(F_7), with (0,1) of order 3.
>
> f(0) = 0³+1 = 1. f(0)^{(7−1)/2} = 1^3 = 1. So y^7 = y · 1 = y. Frobenius does not flip the sign for y=1.
>
> For a 3-torsion point with x-coordinate α satisfying 3α³+5=0 (i.e., α³ = 3 in F_{7³}):
> f(α) = α³+1 = 3+1 = 4. f(α)^{(7−1)/2} = 4^3 = 64 ≡ 1 (mod 7). So y^7 = y again.
>
> The y-factor is +1 for all 3-torsion points of this curve, so φ does not flip the y-sign. This is consistent with the sign selection in the algorithm that finds t ≡ +2 (= −1 ≡ 2 mod 3, or τ=1 with ε=−1, giving t ≡ −1 ≡ 2 mod 3).

---

## 12. The special case τ = 0: a subtle correctness issue

If τ = 0, the Frobenius identity becomes:

```
φ²(P) = −[q]P    for all P ∈ E[l]
```

The points φ²(P) and −[q]P = [q]P (a point and its inverse share the same x-coordinate) have the **same x-coordinate** as [q]P. But so does +[q]P. An x-coordinate-only test cannot distinguish:

- **Case A:** φ²(P) = −[q]P, corresponding to τ = 0, i.e., t ≡ 0 (mod l).
- **Case B:** φ²(P) = +[q]P, corresponding to τ = 2q mod l, i.e., t ≡ 2q (mod l).

Both cases pass the x-coordinate test. An implementation that stops after the x-test and concludes "τ = 0" will be **incorrect whenever Case B actually holds**. This leads to a wrong accumulated trace and ultimately a wrong group order — a silent error.

**The correct procedure** for τ = 0 is:

1. Check whether `x(φ²(P)) = x([q]P)` in R_l (the x-match).
2. If yes, compute the y-factor of φ²(P) (from `f(X)^{(p²−1)/2} mod ψ_l` evaluated at X^p) and compare with the y-factor of [q]P vs −[q]P.
3. If the y-factors match `−[q]P`: conclude τ = 0.
4. If the y-factors match `+[q]P`: conclude τ = 2q mod l (not zero).

This is the correction documented as FIX-5 in `MATH_CORRECTIONS.md`. The bug went undetected in the first version because it affects only certain primes l for which p mod l and the actual trace happen to satisfy the coincidence `x(φ²(P)) = x([q]P)`.

---

## 13. CRT accumulation: reconstruction of t

After processing enough primes l with product M > 4√p, the algorithm holds a value t_acc ∈ [0, M) satisfying `t ≡ t_acc (mod M)`.

Since `|t| ≤ 2√p < M/2`, the unique representative of t_acc in the interval `(−M/2, M/2]` is:

```
t = t_acc         if t_acc ≤ M/2
t = t_acc − M     if t_acc > M/2
```

The group order follows immediately:

```
#E(F_p) = p + 1 − t
```

> **Complete example for p=7, Y²=X³+1:**
>
> After processing l=2 (t≡0), l=3 (t≡2), l=5 (t≡1):
> - M = 30, t_acc = 26.
> - M/2 = 15. Since 26 > 15: t = 26 − 30 = −4.
> - #E = 7 + 1 − (−4) = **12**. ✓
>
> For Ed25519 (`p ≈ 2^255`), after processing 27 primes (l = 2, 3, 5, …, 103):
> - M ≈ 2^135, t_acc encodes the trace.
> - t = −221938542218978828286815502327069187962.
> - #E = p + 1 − t = 57896044618658097711785492504343953926856930875039260848015607506283634007912 = 8 · l. ✓

---

## 14. Why Schoof is so much faster

The efficiency gain comes from a complete change of viewpoint.

| Method | Cost | Feasible for Ed25519? |
|---|---|---|
| Exhaustive counting | O(p) field operations | No (∼ 10^77 ops) |
| Schoof (as implemented) | O(L⁵ (log p)²) with L = largest prime | Yes (hours) |
| SEA (optimized variant) | O((log p)^4) | Yes (seconds) |

The cost per prime l is dominated by the polynomial exponentiation X^p mod ψ_l, performed in a ring of degree deg(ψ_l) = (l²−1)/2. For l ≈ 100, this means polynomials of degree ≈ 5000 with 255-bit coefficients, each multiplication taking time O(l⁴). The total cost over all primes up to L grows roughly as L⁵ (log p)².

For Ed25519, L = 103 and log₂ p = 255. The practical observation is that the cost is dominated by the last few primes:

| Prime l | deg(ψ_l) | Cumulative run time |
|---|---|---|
| 2 | — | < 0.1 s |
| 7 | 24 | 0.3 s |
| 31 | 480 | 156 s |
| 67 | 2244 | 13322 s (∼ 3.7 h) |
| 89 | 3960 | 89929 s (∼ 25 h) |
| 97 | 4704 | 161954 s (∼ 45 h) |
| 101 | 5100 | 176826 s (∼ 49 h) |
| 103 | 5304 | 193829 s (∼ 54 h) |

The last prime (l=103) alone accounts for roughly a quarter of the total runtime. Each additional prime carries a higher cost because its division polynomial is larger.

**The fundamental insight** is that the algorithm works entirely locally: each prime l is processed independently, using only arithmetic in F_p[X]/(ψ_l). The global structure of the curve group — which is what we want to determine — is only assembled at the very end, via CRT. This local-to-global structure is what makes polynomial-time complexity possible.

---

## 15. Summary table

| Computation | Mathematical meaning |
|---|---|
| ψ_l ∈ F_p[X] | Polynomial whose roots (in F̄_p) are x-coords of nonzero l-torsion points |
| R_l = F_p[X]/(ψ_l) | Ring where X acts as the generic nonzero l-torsion x-coordinate |
| X^p mod ψ_l | x-coordinate of φ(P): Frobenius applied once |
| X^{p²} mod ψ_l | x-coordinate of φ²(P): Frobenius applied twice |
| q = p mod l | Small representative: [p] = [q] on E[l] |
| f(X)^{(p−1)/2} mod ψ_l | y-factor of φ(P): encodes y^p = y · (this factor) |
| f(X)^{(p²−1)/2} mod ψ_l | y-factor of φ²(P) |
| τ=0 test with y-check | Confirms t ≡ 0 (mod l); x-only is insufficient |
| x-match for τ ∈ {1,…,(l−1)/2} | Finds |t| mod l up to sign ambiguity |
| y sign check | Distinguishes t ≡ +τ from t ≡ −τ (mod l) |
| CRT accumulation | Reconstructs the global trace t from all t mod l |

---

## 16. Conclusion

Schoof's algorithm rests on three interlocking ideas:

**1. The Frobenius identity** `φ²(P) + [p]P = [t]φ(P)` transforms point counting into the problem of finding the integer τ = t mod l satisfying a polynomial identity on the l-torsion group.

**2. Division polynomials and the quotient ring** `F_p[X]/(ψ_l)` encode the generic l-torsion x-coordinate as a formal variable X, allowing the entire Frobenius identity to be tested symbolically in a single polynomial computation — without enumerating any explicit torsion points in extension fields.

**3. The Chinese Remainder Theorem** assembles the local answers, one per prime l, into the global trace t. The Hasse bound ensures that the assembled value is unique once the product of primes is large enough.

These three ideas are independent yet reinforce each other. The Frobenius identity gives the right question. The quotient ring gives the right computational arena. The CRT gives the right reconstruction strategy.

Together they reduce an astronomically large computation — exhaustive counting over F_p — to a finite sequence of polynomial arithmetic operations in quotient rings, each of bounded size. This is why the algorithm works, and why it is exponentially more efficient than any approach based on explicit point enumeration.

---

*For a broader treatment of applied elliptic curve cryptography — including threshold signature schemes, operational security on Tails OS, and Python implementations of k-of-n vault protocols — see [Quorum Cryptography on Tails OS](https://www.amazon.fr/dp/B0GLGC8GWP) by Philippe Rackette.*
