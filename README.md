# Cross-species projection of teleost growth-trait GWAS loci onto the striped catfish genome

**Backbone:** *Pangasianodon hypophthalmus*, GCF_027358585.1 (fPanHyp1.pri) — 30 assembled chromosomes,
764.4 Mb, 29,542 annotated genes (29,486 on chromosomes; 23,205 protein-coding).

**Deliverables:** `catfish_growth_synteny_app.html` (interactive browser, v16 payload), `projected_locus_catalogue_v6.csv`
(coordinate-corrected + hotspot-dedup flagged, supersedes v3/v4/v5), `projections_anchor_v2.csv`,
`neighbourhood_genes_v2.csv`, `catfish_hotspots_v5.csv` (strict max-diameter clustering, supersedes v2/v3/v4),
`blast_validation_v3.csv`, `conservation_class_review_flags_v2.csv`, `locus_registry_v3.csv`,
`native_locus_catalogue_v2.csv`, `assembly_manifest_v3.csv`, and the FASTA catalogue
(`growth_marker_cds_v2.fna`, `growth_marker_proteins_v2.faa`, `growth_marker_windows.fna`,
`sequence_catalogue_v2.csv`) from the locus-projection pipeline (§1–12); plus, from the independent
supplemental gene-catalog pipeline (§13), `consolidated_gene_catalog.csv`, `resolved_gene_catalog.csv`,
`gene_resolution_review_flags.csv`, and `gene_resolution_validation.png`.

This is the **v5 methodology document**. It supersedes v4 by adding an independent supplemental
growth-gene catalog and its own map/detail view in the app — see §13. Locus-level positions, anchor
resolution, orthology, conservation-class labels, and hotspot membership are unchanged from v4; only the
new §13 catalog/pipeline and the app payload version reflect this addition.

---

## 1. Locus registry

The two supplied workbooks together contributed **117 loci** (study-level and SNP-level rows). A targeted
literature screen added **34** further growth-trait GWAS/QTL loci, giving a registry of **151 loci across
50 teleost species** (`locus_registry_v3.csv`). The screen queried OpenAlex for growth-trait association
studies in fish, screened on title/abstract for a genome-wide association or QTL design, a growth trait,
and a teleost species, then excluded **79** records that did not qualify — including two rows the second
workbook itself flagged as out of scope (a disease-resistance QTL study and a heritability-only
genomic-prediction study with no SNPs) — logged with reasons in `literature_screening_exclusions_v2.csv`
and `literature_screening_log.csv`. A taxonomic synonym was corrected in the second workbook
(*Pelteobagrus fulvidraco* → *Tachysurus fulvidraco*, its current valid name).

Every registry row is tiered by how directly it can be anchored to a genome:

| Tier | Meaning | n |
|---|---|---|
| A1 | Reported coordinates, and the paper's reference assembly is the one annotated here | 3 |
| A2 | Reported coordinates, but on a different assembly than the annotated one | 4 |
| B | No usable coordinates; anchored through published candidate genes | 102 |
| N | Reported directly in *P. hypophthalmus* — resolved against the backbone itself, no cross-species projection | 7 |
| U | Neither coordinates nor recoverable gene symbols, or no annotated genome and no proxy | 35 |

The tier distribution is the central constraint on the whole analysis: **the great majority of published
teleost growth-GWAS hits are anchorable only through their candidate genes**, because papers report
positions on assemblies that are frequently superseded, renamed, or never deposited. Tier U rows are
retained with their reason logged (`tier_assignment_log.csv`) but cannot be projected. Tier **N** (7 loci)
covers rows reported directly in the backbone species — these need no cross-species evidence at all, and
are flagged distinctly everywhere downstream (registry, catalogue, app) rather than folded into tier B.

Two species could not be usefully anchored despite being catalogued: *Pseudobagrus ussuriensis* has no
annotated genome and no reported candidate gene, and one *Leiocassis longirostris* row has an unconfirmed
source DOI; both are tier U by design rather than forced through a proxy genome with no anchoring payoff.

## 2. Genomes

One analysis assembly was chosen per species, preferring an annotated chromosome-level RefSeq assembly.
**34 source-species assemblies** were used, plus the catfish backbone and zebrafish GCF_000002035.6 as a
nomenclature hub. For **17 of 50 manifest species with no annotated genome of their own**, an annotated
congener was substituted as a proxy at the user's instruction; the proxy is recorded per locus
(`proxy_species`) and its neighbourhood is the proxy's, not the study species'. This added
**GCF_019097595.1** (*Hemibagrus wyckioides*, chromosome-level, own RefSeq annotation) for a six-gene
candidate locus (ttc39b/lrp1/gng3/aspp2/mgp/rusc2). A metadata bug was also fixed during the coordinate
audit: the catfish backbone's own row in the manifest had recorded the wrong assembly name string; it now
reads the correct `fPanHyp1.pri` pulled directly from the NCBI fetch URL. Full details in
`assembly_manifest_v3.csv`.

## 3. Anchor resolution

**391 candidate-gene anchors** were extracted from the tier A1/A2/B rows of the registry. **314 (80%)
resolved** to a gene in the source assembly by a multi-stage cascade (recorded per anchor in
`anchor_resolution_v2.csv`):

| Stage | Method | n |
|---|---|---|
| 1 | Verbatim symbol or RefSeq synonym in the source annotation | 177 |
| 2 | Teleost duplicate-suffix tolerance (`gene` → `genea`/`geneb`/`gene1`) | 67 |
| 3 | Zebrafish nomenclature hub (ZFIN symbol/synonym), canonical symbol re-looked-up in the source species | 9 |
| 4 | Catfish annotation as alias authority + reciprocal protein homology back to the source species | 54 |
| — | Suffix-stripped fallback | 1 |
| — | Manual legacy-alias mapping (`GH`→`gh1`, ×3; `aspp2`→`tp53bp2a`, ×1) | 4 |
| — | Coordinate anchor, gene resolution not required | 2 |

The 77 unresolved anchors are legacy or mammal-style aliases that no fish annotation carries, family-level
labels, and a few strings that were never gene symbols; all are logged. The manual-alias rows are retained
because the user's instruction was to prefer an automated authority over agent judgement wherever one
exists, and are flagged individually in `anchor_resolution_v2.csv`.

Two coordinate anchors (tier A1) were placed directly after translating the paper's chromosome label to
the assembly's own linkage-group naming. The four tier-A2 loci were *not* coordinate-transferred — their
positions refer to assemblies that are not the one annotated here, and lift-over between unaligned fish
assemblies is not reliable — so they enter the analysis through their candidate genes only.

The seven tier-N (native) loci were resolved directly against the catfish backbone annotation (own
gene-symbol lookup, no source-species step, no orthology transfer) and are catalogued separately in
`native_locus_catalogue_v2.csv`.

## 4. Synteny neighbourhoods and orthology

For each non-native anchor, up to **10 protein-coding genes either side** on the same scaffold were taken
as the local synteny window: **6,563 neighbourhood genes** (`neighbourhood_genes_v2.csv`, `rank` column
gives position relative to the anchor, `rank==0` is the anchor gene itself). Orthology to catfish was
established by **DIAMOND reciprocal best hits** on the longest protein per gene, run in both directions for
every source assembly against the backbone. **4,672 of 6,563 (71%)** neighbourhood genes have a catfish RBH
ortholog. Reciprocal fractions behave as expected phylogenetically — highest for congeneric ictalurids,
markedly lower for salmonids and cyprinids whose genome duplications break one-to-one reciprocity
(`orthology_summary_v2.csv`).

Symbol matching alone could not have supplied this layer: a large share of neighbourhood genes in
non-model teleost annotations carry only `LOC…` identifiers.

## 5. Projection and scoring

For each anchor the projected position is derived from where its neighbours' catfish orthologs land:

1. the **modal catfish chromosome** among the ortholog hits defines the projected chromosome;
2. hits on that chromosome are **gap-clustered** (5 Mb) and the largest cluster is the supporting set,
   which rejects anchors whose "support" is scattered across a chromosome;
3. the **projected interval** is the span of the supporting cluster, and the **projected point** is the
   anchor's own catfish ortholog where one exists, otherwise interpolated from the supporting cluster.

Step 3 above states the *intended* design. A coordinate-accuracy audit (§11) found that the shipped v1–v4
catalogues did not actually implement it faithfully in every case — a subsequent correction step recomputed
the projected point and interval from scratch, always preferring the anchor's own resolved ortholog over
neighbourhood consensus. **`projected_locus_catalogue_v5.csv` is the corrected result and is the version
consumed by the app and by every number below.**

Two statistics are reported per anchor:

- **collinearity** — the longest monotonically ordered run of supporting orthologs in source gene order,
  computed in both orientations, divided by the supporting count.
- **p_coloc** — binomial tail probability of seeing at least this many of the window's orthologs inside a
  10 Mb interval if they were placed uniformly across the genome.

**Conservation classes:** *strong* = p_coloc < 1e-6, ≥5 supporting orthologs, collinearity ≥ 0.5;
*moderate* = p_coloc < 1e-3, ≥3 orthologs; *weak* = colocalises but below those bars; *native* = reported
directly in *P. hypophthalmus*, no cross-species statistics apply. These labels are computed from the
support statistics (collinearity, p_coloc, ortholog count), which the coordinate correction did not change
— so class membership counts are the same as in v2, but a small number of loci have had their aggregate
BLAST-containment support re-evaluated under the corrected coordinates and flagged for manual review rather
than silently reclassified (§7, §11).

**315 cross-species anchors scored: 211 strong, 87 moderate, 16 weak, 1 unsupported**
(`projections_anchor_v2.csv`).

Anchors were aggregated to locus level per catfish chromosome (gap-clustered at 5 Mb), giving
**273 locus×region projections for 96 loci from 39 species and 73 studies**, spread over all 30 catfish
chromosomes (region-level class breakdown: 177 strong, 76 moderate, 12 weak, 7 native, 1 unsupported). Each
row carries the full GWAS provenance from the source publication — trait, marker, p-value, threshold,
effect/PVE, sample size, genotyping platform, population, age/stage, reported chromosome and position, the
paper's reference genome, DOI and year — alongside the projection and its support statistics
(`projected_locus_catalogue_v5.csv`, which retains the pre-correction values in
`proj_point_v1_correction`/`region_start_x_v1_correction`/`region_end_x_v1_correction` for audit purposes).

## 6. Cross-species convergence

**v3 clustering fix.** The v4 clustering (single-linkage/gap-chaining at a 2 Mb neighbor-to-neighbor
threshold) had a real defect: chaining only checks adjacent points, so a sequence of points each ≤2 Mb from
its neighbor could be merged into one cluster spanning far more than 2 Mb overall — in the worst case, 26 of
120 v4 clusters spanned more than 30% of their chromosome, one reaching 84% (21.1 Mb on a 25.3 Mb
chromosome). A second, compounding defect: when one locus's GWAS paper listed several candidate genes that
each independently projected to the same chromosome at different positions, every one of those rows counted
as a separate "vote" toward convergence, inflating the apparent number of independently agreeing studies.

Both are fixed in `catfish_hotspots_v5.csv`: (1) each locus is first collapsed to its single
best-supported row per chromosome (16 of 273 rows were redundant same-locus/same-chromosome duplicates,
flagged `hotspot_dedup_status` in `projected_locus_catalogue_v6.csv` and `hd` in the app payload — retained,
not deleted); (2) clustering now uses complete-linkage hierarchical clustering with a hard 2 Mb
**maximum-diameter** cut, which guarantees every member of a cluster is within 2 Mb of *every other* member,
not just its nearest neighbor. Result: **134 clusters, 18 supported by ≥3 species**, maximum span 2.0 Mb
(down from 22.8 Mb), median non-singleton span 0.87 Mb (down from 2.62 Mb), and zero clusters spanning >30%
of a chromosome (down from 26). The app's hotspot-detail panel margin was also tightened from ±2 Mb to
±200 kb, since the old margin — sized for the loose v4 clusters — risked pulling correctly-separated
neighboring clusters back into view once clusters themselves became tight.

The new largest cluster by species count, **H049 on chr18** (1.46–3.41 Mb, 9 loci, 7 species, 8 studies),
is anchored predominantly on *igf1* — a canonical growth-axis gene — independently in *Tachysurus
fulvidraco*, *Micropterus salmoides* (2 studies), *Cyprinus carpio*, *Cynoglossus semilaevis*, and the
catfish's own native *igf1* GWAS hit, plus *IGF1*/*KISS2*/*NUP107* calls from *Dicentrarchus labrax* and
*Oreochromis niloticus* nearby. This is a more biologically coherent flagship example than the previous
(now-defunct) H072/chr24 cluster, which the strict rule splits into six much tighter sub-clusters (largest:
7 loci/4 species over 1.0 Mb). These clusters are the most defensible candidate regions in the whole
analysis, because they require independent studies in different species to agree on a tightly-bounded
catfish location — not a chain of loosely-related points spanning much of a chromosome.

## 7. Sequence catalogue and BLAST cross-check

For every resolved anchor and native locus, the longest protein and its CDS were extracted from the
relevant assembly: **318 CDS and 318 protein sequences** (`sequence_catalogue_v2.csv`,
`growth_marker_cds_v2.fna`, `growth_marker_proteins_v2.faa`). 40-kb genomic windows were fetched from NCBI
for the coordinate anchors. All were searched against the catfish genome (`blastn -task dc-megablast` for
nucleotide, `tblastn` for protein) — the independent test of the projections, since these searches use
sequence similarity only and never touch gene order:

| Query set | Best hit on the projected chromosome | Best hit inside the projected interval (±2 Mb) |
|---|---|---|
| CDS (n=309) | **80.9%** | **74.8%*** |
| Protein (n=313) | 71.6% | 66.1%* |

*Interval-containment percentages were computed against the pre-correction (v1–v4) intervals. Re-run
against the corrected (`v5`) intervals in `blast_validation_v3.csv`, containment among matched probe rows
improved from 434/614 (70.7%) to 469/614 (76.4%) — i.e. the independent BLAST evidence agrees with the
corrected regions *more* often than with the uncorrected ones, which is itself supporting evidence for the
correction (§11).

Protein searches agree less often, as expected — translated searches recover conserved domains from
paralogues elsewhere in the genome. Per-locus concordance is in `blast_validation_v3.csv` and is surfaced in
the app. A small number of loci changed BLAST-support status under the corrected coordinates; rather than
auto-reclassify their conservation_class, these are listed in `conservation_class_review_flags_v2.csv` for
manual review (33 rows, mostly *moderate*-class loci that now show positive containment support, a few
*strong*-class loci that no longer do, and native loci for which the containment check does not
straightforwardly apply).

**The genomic-window layer remains a negative result** for the same reasons as before (each window
produces hundreds of HSPs spread over multi-megabase spans at teleost divergences) and is excluded from
projection, retained only as documentation.

**Flagged discrepancy — C001/C002 (*rrp44*/*dis3*, tier A2, catfish-bridge candidate).** The named candidate
gene itself BLASTs to chr26, while the independent coordinate-window synteny anchor (7 flanking genes,
perfect collinearity) robustly supports chr21. Inspection traced the cause: the candidate gene lies outside
the actual flanking window that was extracted for the coordinate-based projection, so the two evidence
lines are, in practice, evidence about two different genomic locations sharing one locus label. Both are
retained and shown in the app rather than silently reconciled — treat the chr21 coordinate-anchor call as
the better-supported one for this locus, and the chr26 candidate-gene BLAST hit as a caveat, not a
confirmation.

## 8. Interactive browser

`catfish_growth_synteny_app.html` is a single self-contained file (~0.86 MB, no network access required):

- **Genome map** — all 30 catfish chromosomes with every projection as a tick coloured by conservation
  class (including the *native* class); ≥3-species clusters shaded. Click any tick or cluster.
- **Locus detail** — the synteny link diagram for the selected anchor (source gene order on the upper
  track, catfish chromosome below, one link per orthologous neighbour), a switcher for loci with several
  anchors, the full GWAS provenance card, and the complete neighbourhood gene table with catfish orthologs.
  Native loci show the provenance card with no synteny diagram, since no cross-species projection applies.
- **Cluster view** — stacked per-species synteny panels for one convergence region, so conserved order
  reads directly as near-parallel links.
- **Locus catalogue** — sortable, filterable table with CSV export of the current filter.
- Filters: conservation class, source species, trait category, minimum supporting orthologs, and free-text
  search over genes, species, markers, chromosomes and DOIs.

Current totals in the app: 96 loci / 273 regions, 315 cross-species anchors, 7 native loci, 134 hotspot
clusters (18 supported by ≥3 species), 39 species, 73 studies — coordinates reflect the v5/v6 correction
(§11) and hotspot membership reflects the strict max-diameter clustering fix (§6). Structural validation
before shipping: JS parses cleanly, all HTML tags balanced, all 273 loci pass region-containment
(`region_start ≤ proj_point ≤ region_end`), all 134 hotspots pass member-containment with every member within
2 Mb of every other member (not just its nearest neighbor), and no coordinate exceeds its chromosome's
assembled length.

## 9. Limitations

**These are positional hypotheses, not catfish QTLs.** A conserved neighbourhood locates the orthologous
segment; it transfers neither the causal variant, nor its effect size, nor its allele frequency. Nothing
here has been tested in catfish — including the 7 native loci, whose *reported* position is in the
backbone species itself but whose causal variant has not been independently confirmed here.

**Candidate-gene anchoring inherits the source paper's biology.** A projection is only as good as the
paper's gene assignment — usually the nearest gene to a lead SNP, which is often not the causal gene.
Where a paper's candidate list is long, several anchors from one locus can project to different
chromosomes; all are reported rather than silently reconciled. The C001/C002 case in §7 is the clearest
example: treat any locus with multiple anchors as multiple independent claims, not one triangulated call.

**Family-level and legacy-alias labels are weak anchors.** Bare family names resolve to one arbitrary
paralogue; the four manual legacy-alias resolutions (`GH`→`gh1`, `aspp2`→`tp53bp2a`) rely on domain
knowledge rather than an automated authority and should be checked before relying on any single locus.

**Proxy genomes.** For 17 of 50 manifest species the neighbourhood is a congener's. Gene order is generally
conserved within a genus, but a proxy cannot capture species-specific rearrangement.

**Duplicated genomes are treated conservatively.** Reciprocal best hits under-report orthologs in
salmonids and cyprinids, so their projections have lower support counts than their true conservation
warrants — absence of a strong class for these species is not evidence against conservation.

**No lift-over between unaligned assemblies** was attempted, so tier-A2 loci with reported coordinates on
superseded or different assemblies contribute only through their candidate genes.

**Trait heterogeneity is not modelled.** "Growth" spans body weight, length, condition factor, fillet
yield and growth rate, measured at different ages under different husbandry. Loci are grouped by trait
category for filtering but not meta-analysed; a cluster containing several traits should not be read as a
single pleiotropic locus.

**60 of 273 regions (22%) have their projected point resolved via the flanking-window fallback method**
rather than the anchor gene's own ortholog (§11), because the anchor itself had no resolvable ortholog on
the assigned chromosome; these carry a `anchor_own_resolved=False` flag in `projected_locus_catalogue_v5.csv`
and should be treated as lower-confidence coordinates than the other 213. A further 4 loci had internally
conflicting multi-gene anchors that could not be reconciled (`anchor_conflict_unresolved`) and also fall
back to the flanking-window estimate.

**Two rows remain undeployable by design**, not by oversight: *Pseudobagrus ussuriensis* (no genome, no
candidate gene) and the *Leiocassis longirostris* row with an unconfirmed source DOI. Both are tier U and
excluded from every downstream count in this document.

## 10. Reproducibility

Pipeline scripts: `download_genomes.py`, `prep_annotations2.py` (annotation parsing with synonyms),
`prep_orthology.py` (proteome extraction + DIAMOND RBH), `prep_zebrafish.py` (nomenclature hub).
Tools: NCBI Datasets API, DIAMOND 2.x `blastp` (default sensitivity, `--evalue 1e-5 --max-target-seqs 1`,
best hit taken in each direction and kept only if reciprocal), BLAST+ 2.x
(`dc-megablast`, `tblastn`), pandas/scipy/matplotlib. All coordinates are 1-based inclusive on the stated
assembly. This document (v4) supersedes v3 by adding the strict hotspot-clustering fix (§6); v3 supersedes v2
(single-workbook-integration) by folding in the coordinate-accuracy audit and correction described in §11.

## 11. Coordinate-accuracy audit and correction (v2 fix)

An audit was run to cross-validate every catfish-side coordinate in the pipeline against the authoritative
NCBI RefSeq feature table for the backbone assembly (29,542 genes, matching the count stated in §0).
It surfaced a real defect, in two stages.

**First-pass finding.** A first correction attempt recomputed each locus's projected point as the median of
*all* same-chromosome neighbourhood-window points (the anchor gene at rank 0, plus every flanking gene),
with a fixed-radius outlier filter applied uniformly across that whole set. Validating this correction
against the locus's own confirmed anchor gene exposed a deeper problem: **the filter could, and in a
material number of cases did, discard the anchor gene's own resolved position as the "outlier"** whenever a
tighter cluster of flanking-gene orthologs — which are individually noisier calls than the anchor's own
ortholog, being more exposed to paralogy and mis-assignment — happened to outnumber it.

Concrete example: locus W006 (*MRAP2* anchor, Atlantic salmon growth GWAS). The confirmed catfish ortholog
of *MRAP2* is *mrap2a* at chr1:4,809,318 (NC_069710.1); two flanking genes very close to it (*tsnare1*,
*si:ch211*) resolve at 4.44–4.74 Mb, consistent with a real conserved block. But four other flanking genes
in the same window (*ascc3*, *bves*, *popdc3*, *LOC113534038*) resolve 11+ Mb away at 16.10–16.60 Mb on the
same chromosome — a second, unrelated cluster, most likely reflecting incorrect ortholog assignment for
those specific genes. Because that second cluster had more members (4 vs 3), the flawed method kept it and
discarded *mrap2a*'s own position, producing a projected point ~11.3 Mb from the correct location.

**Corrected rule (implemented in `projected_locus_catalogue_v5.csv`).**

1. For each locus-anchor row, resolve the anchor gene's(s') own rank-0 position(s) in the neighbourhood
   table, restricted to the row's assigned chromosome. This position is never treated as a droppable
   outlier.
2. Single anchor gene with one resolved position → that is `proj_point` directly.
3. Multiple anchor components (e.g. `tg;tgfbr2`) → single-linkage cluster their resolved positions (2 Mb
   threshold); take the median of the largest cluster. If all components are mutually isolated (no
   majority cluster), flag `anchor_conflict_unresolved` and fall back to step 4.
4. If no anchor-own position resolves on the assigned chromosome, fall back to the flanking-window-median
   method, explicitly flagged `anchor_own_resolved=False` (lower confidence).
5. Region bounds = min/max of same-chromosome flanking-window points within 3 Mb of the chosen point,
   always widened to contain the point; rows with fewer than 2 points in that window get a symmetric
   ±25 kb pad rather than a zero-width region.
6. Direct catfish-native GWAS rows (candidate-gene loci such as *ghrb*, *igf1*, *igfbp3*, etc.) were
   already taken directly from the authoritative NCBI feature table and are unaffected by this correction.

**Validation.**
- 273/273 loci: `region_start_x ≤ proj_point ≤ region_end_x` (100%), and within the assigned chromosome's
  assembled length.
- 209/273 loci (77%) resolved via the anchor's own ortholog directly (`anchor_own_resolved=True`, high
  confidence); 60/273 (22%) via the flanking-window fallback (flagged lower confidence); 4/273 flagged
  `anchor_conflict_unresolved`.
- Independent BLAST containment (§7) improved from 434/614 (70.7%) to 469/614 (76.4%) matched probe rows
  under the correction — i.e. sequence-alignment evidence, which never touches gene order, agrees with the
  corrected regions more often than with the uncorrected ones.
- 183/273 loci (67%) changed materially versus the flawed first-pass correction; median shift ~40 kb,
  several shifts exceeded 10 Mb for the loci where the first-pass bug was most severe.
- A related bug was also found and fixed in the hotspot-bound rebuild: a `locus_id` with candidate-anchor
  rows on two different chromosomes was being matched to an arbitrary row instead of the chromosome-matched
  one, corrupting a subset of hotspot bounds. After filtering strictly by chromosome, all 120/120 hotspots
  (`catfish_hotspots_v4.csv`) pass member-containment.

The pre-correction values are retained in `projected_locus_catalogue_v5.csv` as
`proj_point_v1_correction`/`region_start_x_v1_correction`/`region_end_x_v1_correction` for audit purposes,
and the full write-up (with the worked W006 example and a before/after figure) is in
`methodology_correction_v2.md` and `locus_W006_correction_v2.png`.


## 12. Hotspot-clustering audit and correction (v4 fix)

Following a user review of the app, cluster ("hotspot") boundaries were audited for plausibility and found
to be systematically too wide — several spanned most of a chromosome, which is not a credible width for a
"conserved locus." Two root causes were identified and fixed; both are described in detail in §6. In brief:

1. **Chaining.** The v4 clustering method merged any two chromosome-neighbor points within 2 Mb of each
   other, with no check on the resulting cluster's overall width. A sequence of pairwise-close points could
   therefore chain into a cluster tens of megabases wide. Fixed by switching to complete-linkage
   hierarchical clustering with a 2 Mb **maximum-diameter** cut, which bounds every pairwise distance
   within a cluster, not just adjacent ones.
2. **Duplicate votes from one locus.** A single GWAS locus with several candidate genes could contribute
   multiple rows to the same chromosome, each counted as independent convergence evidence. Fixed by
   collapsing each locus to its single best-supported row per chromosome before clustering (16 of 273 rows
   affected).

**Validation:** maximum cluster span dropped from 22.8 Mb to 2.0 Mb (hard cap, verified by construction and
by a direct post-hoc check of every cluster in the app payload); clusters spanning more than 30% of their
chromosome dropped from 26 to zero; cluster count changed from 120 to 134 (splitting, not merging, is the
expected direction of this fix); clusters supported by ≥3 species dropped from 23 to 18, reflecting that
some of the previous "high-species-count" clusters owed their count to chaining together points that
should have been separate. The new top cluster by species count (H049, chr18, *igf1*-anchored across 7
species) is reported in §6 as the new flagship convergence example, replacing the previous H072/chr24
example which the strict rule splits into six tighter sub-clusters. All 134 hotspots pass member
containment and the 2 Mb diameter cap in the shipped app payload (verified by parsing the embedded data and
checking every cluster directly, not merely by construction).

Files: `catfish_hotspots_v5.csv` (supersedes v4), `projected_locus_catalogue_v6.csv` (adds
`hotspot_dedup_status` audit column, supersedes v5), `hotspot_clustering_fix_comparison.png` (before/after
span-distribution figure), `catfish_growth_synteny_app.html` (v9 payload).


## 13. Supplemental growth-gene catalog and map (v5 addition)

Independent of the locus-projection pipeline above (§1–12), the user supplied two further Excel catalogs
of teleost growth-related genes — one Pangasius-specific, one spanning teleosts broadly — both keyed to
zebrafish Ensembl/ZFIN gene identifiers and each carrying pathway/trait annotation, evidence-strength
tiering, source species, reported locus, proposed effect on growth, and reference/DOI/PMID provenance.
This section maps every cataloged gene onto the catfish genome and adds a dedicated "Supplemental map" tab
to the app, entirely independent of the GWAS-locus projection machinery in §1–7 (no synteny-window,
orthology-RBH, or clustering logic is shared between the two).

**13.1 Catalog consolidation.** Both workbooks (plus their variant/reference support sheets) were loaded
and source-tagged. Every gene row in the Pangasius-specific workbook was found to be an exact duplicate of
a row already present in the all-teleost master workbook, so the two were deduplicated to **355 unique
genes** (`consolidated_gene_catalog.csv`), each flagged for Pangasius-catalog presence and for carrying a
verified marker-variant. Evidence-strength values were bucketed into three classes for coloring: **A**
(direct/verified marker or QTL support), **B** (candidate gene, indirect support), **C** (pathway-core /
homology inference) — 126 / 74 / 155 genes respectively.

**13.2 Ortholog resolution.** Each of the 355 zebrafish-referenced genes was resolved to a catfish genomic
position by a two-stage cascade:

1. **Direct symbol match** against the catfish authoritative gene table (already built for §3) — 319/355
   genes (90%).
2. **BLAST fallback** for the remainder: the zebrafish RefSeq protein was fetched (via Ensembl xref →
   NCBI Gene → efetch) and searched (`blastp`) against a catfish RefSeq protein database built for this
   analysis; the hit's protein accession was resolved directly to a catfish gene symbol, chromosome, and
   coordinates via the NCBI Datasets protein-accession endpoint. For 4 genes with no zebrafish ortholog at
   all (confirmed by a zebrafish-restricted NCBI Gene search returning nothing, and a broader cross-species
   search confirming the symbol exists only in other species), a reference protein from the nearest
   available species (tilapia or human) was used instead. 35/355 genes (10%) were resolved this way.

**354/355 genes (99.7%) resolved.** The single unresolved gene, `gnrh3`, has no zebrafish ortholog and no
usable cross-species BLAST hit above threshold; it is listed but excluded from the map. Zebrafish
whole-genome-duplication paralog pairs that collapse onto one catfish locus (11 pairs) are flagged with
their partner (`shared_locus_with`) rather than merged or dropped.

**13.3 Validation.** All 354 resolved positions pass containment within their assigned chromosome's
assembled length. The 35 BLAST-resolved positions were independently cross-checked against a
GFF-derived catfish gene table (built independently of the NCBI Datasets endpoint used for resolution):
**0/35 mismatches**. As a biological-plausibility cross-check against the unrelated locus-projection
pipeline, 87/354 mapped genes (25%) physically overlap an existing cross-species GWAS convergence cluster
from §6 — read as circumstantial corroboration between the two independent analyses, not as evidence for
either individually. 12 genes are individually flagged as low/medium confidence with a specific reason
(paralog ambiguity or low BLAST identity) in `gene_resolution_review_flags.csv`; a three-panel validation
figure (resolution-method breakdown, evidence-class composition, hotspot-overlap cross-check) is saved as
`gene_resolution_validation.png`.

**13.4 App — "Supplemental map" tab.** A new tab was added to `catfish_growth_synteny_app.html` (v10
payload), independent of the existing Genome map / Locus catalogue / Cross-species clusters tabs:

- A chromosome ideogram plotting all 354 mapped genes, colored by evidence class (A/B/C), with
  Pangasius-catalog entries rendered as larger filled markers to distinguish them from general-teleost
  entries.
- Its own filter bar: evidence-class chips, a pathway/gene-family dropdown (12 groups), a
  "Pangasius-specific only" toggle, and free-text search over gene symbol, pathway, trait, and DOI —
  independent of the §8 locus filters.
- A sortable table of the filtered genes with CSV export.
- A gene detail panel (mirroring the §8 locus-detail panel's layout) showing gene name, pathway/trait,
  evidence type, source species, reported locus, proposed growth effect, reference/DOI/PMID links,
  resolution method/confidence, paralog-collapse flags, and — when applicable — the overlapping §6 GWAS
  convergence cluster.

Structural validation before shipping: the embedded JS was extracted and syntax-checked (`node --check`);
a headless DOM (jsdom) functional test confirmed the new tab renders all 354 gene markers, every filter
(pathway, evidence class, Pangasius-only, search, reset) correctly narrows/restores the shown count,
clicking a gene opens the correct detail panel, and the CSV-export button is wired; the existing Genome
map, Locus catalogue, and Cross-species clusters tabs were re-tested and confirmed unaffected by the
`render()` changes needed to add the new tab.

The ideogram also supports **click-and-drag range selection**: dragging across a chromosome track
selects a genomic interval on that chromosome (drawn as a persistent highlight band), which additionally
restricts the gene table below to genes overlapping the selection; a "Clear range selection" control
reappears only while a range is active and restores the full filtered list. With no drag performed (or a
drag below a small pixel-movement threshold, treated as a plain click so it does not interfere with
clicking a gene marker), the table shows all genes passing the other filters, matching prior behavior.
This was verified headlessly by simulating `mousedown`/`mousemove`/`mouseup` sequences at known SVG pixel
coordinates: the resulting filtered set matched the expected gene list for the dragged interval exactly,
the live drag-preview rectangle appeared and resized during the drag and was removed on release, the
persistent highlight rendered on re-render, "Clear range selection" restored all genes, and a
near-zero-movement click correctly left the range unset.

**Gene-name labels on the ideogram.** Selecting a specific Pathway/gene-family filter additionally draws
each gene's symbol directly beside its marker (row height increases from 25px to 36px in this mode to
make room). Labels are laid out per chromosome row by a deterministic greedy packer: genes on the row are
sorted by genomic position, alternately assigned to one of two vertical tiers (above/below the gene-track
bar), and packed left-to-right within each tier with a minimum pixel gap based on each label's estimated
text width — pushing a label right only when it would otherwise collide with the previous label in the
same tier, never moving the underlying gene marker itself. A thin leader line connects each label back to
its marker so displaced labels remain traceable. With no pathway filter active, no labels are drawn and
row height reverts to normal, matching prior behavior. Verified headlessly: real data's single densest
pathway/chromosome combination (6 genes on chr1 for the Myostatin/TGF-beta/BMP pathway) rendered all 6
labels with zero same-tier overlaps; a synthetic worst-case of 25 genes packed into a 300kb window (far
denser than anything in the actual catalog) still produced zero within-tier overlaps and stayed within
the track's horizontal bounds; clicking a label opens the same gene-detail panel as clicking its marker;
and the feature composes correctly with the drag-select range (§ above) and does not regress the other
tabs.

**Growth-gene projection on the Genome map tab.** The Genome map tab (§1–12's own view) gained a
"project growth genes (from Supplemental map)" toggle, off by default. When enabled, every §13-catalog
gene with a resolved catfish chromosome position (354/355) is drawn as a small inverted-triangle marker
sitting immediately above the chromosome track at its exact genomic position — deliberately distinct from
the existing GWAS-locus tick marks and hotspot-cluster bands, which retain their original encodings. Each
triangle is shaded in grayscale by the same evidence-strength class used throughout §13 (A dark gray, B
medium gray, C light gray; a matching legend and toggle-linked swatch appear beside the checkbox), and
where multiple genes fall close enough to overlap on screen, class-A triangles are always drawn last (on
top) so the highest-evidence marker at a position is never hidden underneath a lower one. Hovering a
triangle shows the identical tooltip used for that gene on the Supplemental map (symbol, source-genome
coordinates, catfish ortholog, evidence class, pathway); clicking one populates the shared right-hand
detail panel with the same content `suppGeneDetail()` renders on the Supplemental map tab itself, and the
selection now persists across tab switches rather than being cleared — the panel's dispatch logic was
flattened so a selected gene, hotspot cluster, or GWAS locus is drawn from one shared priority order
(gene > hotspot > locus) regardless of which tab is active, and selecting any one of the three explicitly
clears the other two so the panel never shows stale information from an earlier selection made on a
different tab. Verified headlessly: the toggle draws exactly the 354 genes with resolved catfish
coordinates (and zero when off), every triangle's fill color matches its gene's evidence class, clicking a
triangle sets the detail panel to that gene and survives a tab switch, clicking a GWAS tick or a hotspot
band correctly clears the gene selection and restores the corresponding locus/cluster detail, and the
existing Supplemental map interactions (table-row clicks, pathway-label mode, drag-select) are unaffected
by the shared-selector refactor.

**Limitation specific to this section:** unlike the locus-projection pipeline (§1–7), gene positions here
carry no synteny-window or gap-clustering support statistic of their own — a gene's catfish position is
only as reliable as its symbol match or BLAST identity, and the evidence-strength class (A/B/C) reflects
the *source catalog's* judgement of the gene-trait link, not confidence in the catfish coordinate itself.
The §6 hotspot-overlap figure (13.3) is a plausibility cross-check, not a validation of either pipeline.
