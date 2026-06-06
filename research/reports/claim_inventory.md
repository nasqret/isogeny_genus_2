# Initial Computational Claim Inventory

## Scope

The first source pass identified 34 computation families. This inventory is
deliberately provisional until a second line-by-line audit confirms that every
computational assertion, including claims outsourced to cited literature, is
represented by an atomic ledger item.

## Major clusters

| Cluster | Claim IDs | Preferred engines |
|---|---|---|
| General complementary-curve algorithm | C001-C007 | SageMath + Magma |
| Critical quartic construction | C008-C011 | SageMath + Magma |
| Degree-3 example and complementary map | C012-C020 | SageMath + Magma |
| Degree-4 example and arithmetic | C021-C025 | SageMath + Magma |
| Degree-5 example over a number field | C026-C030 | Magma + SageMath |
| Degree-2 family | C031 | SageMath |
| `j`-invariant and twist identities | C032-C033 | SageMath |
| Article-wide coverage | C034 | Python + manual audit |

## Highest-risk claims

- **C006-C007:** The paper describes a divisor-class and interpolation
  algorithm whose implementation is substantially more involved than checking
  a displayed equation.
- **C011:** The quartic self-fiber product requires normalization and a
  birational genus-one model, not only a plane equation.
- **C017:** The paper says that further parameter triples were sampled but
  does not state the sample. The reconstruction must define a transparent
  replacement sample and distinguish it from the authors' unpublished sample.
- **C023-C024:** Database labels and Mordell-Weil structure require current,
  independently checked provenance.
- **C029:** "No nonsingular point over the base field" needs a mathematical
  obstruction certificate; a bounded search is insufficient.
- **C030:** The degree-5 computation includes field extension,
  parametrization, desingularization, and invariant comparison.

## Upstream coverage

The authors' companion repository provides Magma scripts for degree 3,
the degree-3 map, and degree 5. These are tracked as upstream references only.
Independent SageMath implementations and stricter Magma assertions will be
added before any claim is marked verified.
