# MECE Decomposition

Split a problem into sub-dimensions that are Mutually Exclusive and Collectively Exhaustive — no overlap, nothing missing.

## Steps

1. State the problem in one sentence with a clear boundary.
2. Pick one axis of division (lifecycle, layer, stakeholder, data flow — one axis, not several at once).
3. Split along that axis; check that no two parts overlap and that together they cover the whole.
4. Recurse into a part only if it is still too big to act on.

## Output

- Axis: [the single axis chosen, and why]
- Parts: [A / B / C — each independent, together complete]
- Check: [overlaps or gaps the review caught, and how they were fixed]
