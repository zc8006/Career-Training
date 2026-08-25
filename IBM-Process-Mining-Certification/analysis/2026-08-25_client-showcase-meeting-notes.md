# IBM Process Mining Client Showcase Meeting Notes

Date: 2026-08-25
Source: Meeting transcript uploaded in ChatGPT

## 1. Meeting Objective

The meeting focused on deciding what should ultimately be presented to the client, rather than continuing to expand the number of analyses or charts.

The key shift is from a broad internal analysis dashboard toward a concise client-facing Process Mining business case that can:

- Show the current automation status clearly.
- Demonstrate Process Mining-specific value rather than generic BI/Excel analysis.
- Highlight areas worth further investigation.
- Quantify potential improvement and savings conservatively.
- Support a future commercial discussion with client and Global stakeholders.

---

## 2. Overall Overview Page

### Current Phase2 population

- Total Cases: 21,578
- RPA Process: about 53%
- Manual Process: about 45%
- Remaining 323 Cases can be shown as `Others` if needed so that the percentages sum to 100%.

### Key recommendation

Inside the RPA Process population, further show:

- RPA without human intervention
- RPA with human intervention / Rerun

Reason:

If only the overall RPA rate is shown, the client may assume that all RPA cases are fully automated. In reality, some RPA cases still require human intervention, which directly indicates additional improvement opportunities.

### Presentation direction

The first page should stay at a high-level overview.

Avoid cluttering it with too many small charts or low-value metrics.

---

## 3. Process Flow / Process Mining Differentiation

The current process flow views need to be reviewed carefully before being shown to clients.

Several paths looked questionable from a business perspective, including examples such as:

- `Start -> 意见征询`
- `录入完成 -> OCR`
- `意见征询 -> 审批结束`

Business feedback was that these flows do not look logically reasonable because:

- 意见征询 should normally be triggered by a preceding condition or result.
- Once entry is completed, returning to OCR appears unusual.
- After 意见征询, entry completion would normally still be expected before approval completion.

### Action

First verify whether these paths are caused by:

- Variant selection hiding intermediate steps.
- Event data quality or missing events.
- Incorrect analysis scope.
- Actual unusual business behavior.

If the split Manual/RPA process views remain confusing, use one overall process map instead and highlight the key Manual and RPA paths inside it.

### Why this matters

The client may already understand Process Mining and may have exposure to Celonis. Therefore, the Process Mining-specific differentiator must be visible.

Too many pie charts or simple category breakdowns can look like ordinary Excel/BI analysis.

---

## 4. Manual Process Analysis

### What should remain

The current Manual-related categorization still has value because some categories are easy for the client to understand immediately.

Examples discussed:

- Threshold-related checks
- Prepayment
- Pay-before-invoice situations
- RPA out-of-scope situations
- Entry errors

These can help distinguish between:

- Cases that are reasonably Manual / Out of Scope
- Cases that may still have automation opportunity

### Recommended high-level categories

Instead of keeping a large `Other Reason` category, move toward:

- PO Reason
- Contract Reason
- Out of Scope
- Manual Processing with No Clear Reason

### Why `Other Reason` is problematic

If `Other Reason` is a large category, the client may immediately ask why it has not been analyzed further.

Where possible, cases such as:

- RPA out of scope
- Entry error
- Prepayment
- Pay before invoice

can be grouped into `Out of Scope`, because these are situations that the RPA cannot continue processing automatically.

### Opportunity categories

Potential areas worth deeper investigation include:

- PO-related Manual cases
- Contract-related Manual cases
- Manual cases with no clear reason
- Cases that appear processable but still end as Manual

These should be positioned as future investigation opportunities rather than fully proven root causes.

---

## 5. PO Matching / Opinion Inquiry Sequence

A major issue raised in the meeting is that category values alone are not enough; event sequence matters.

Example:

If a Case shows both:

- Opinion Inquiry
- PO Matchable

it is important to know whether PO became matchable:

- Before the Opinion Inquiry, or
- After the Opinion Inquiry

The interpretation is completely different.

### Example interpretation

If Opinion Inquiry happened first and the business later supplied a new or corrected PO, then PO becoming matchable afterward is reasonable.

If PO was already matchable before Opinion Inquiry, the process would look much harder to explain.

### Action

Before presenting conclusions such as `PO Matchable but still required Opinion Inquiry`, verify the timestamp/event sequence.

If the sequence cannot be confidently established, do not present it as a root cause.

The same caution applies to Rerun-related charts.

---

## 6. Trend Analysis

Raw monthly counts alone are not sufficient.

Example discussed:

A month with 582 Manual cases may look high, but if the total transaction volume is also much higher that month, the actual rate may not be abnormal.

### Manual trend

Recommended ratio:

```text
Target Manual Case Count in Month
/
Total Manual Cases in Month
```

or, where appropriate:

```text
Target Case Count in Month
/
Total Cases in Month
```

### RPA trend

Instead of showing only monthly Rerun counts, consider a stacked monthly ratio such as:

```text
RPA Posting
├─ Straight-through / no human intervention
└─ Rerun / human intervention
```

This can help identify:

- Sudden increases in Rerun rate
- Gradual improvement in straight-through processing
- Months where automation quality degrades

A percentage-based view is more meaningful than raw monthly counts.

---

## 7. Simulation / Potential Saving

The Simulation capability remains useful as a Process Mining differentiator, but the client-facing output should be simplified.

### Confirmed business handling-time assumptions

- RPA average handling time: 1.5 minutes per Case, including Rerun
- EBS Manual average handling time: 11.9 minutes per Case
- JDE Manual average handling time: 7.4 minutes per Case
- Manual labor cost assumption: CNY 80/hour
- These are average operation/handling times and do not include waiting time.

### Current EBS simulation direction

Focus on EBS because the Manual volume and handling time provide a clearer initial scenario.

Use a conservative automation assumption such as about 50% rather than assuming 100% automation.

### Client-facing presentation

Do NOT expose detailed cost formulas or unit labor-cost calculations because the client may reverse-engineer the delivery cost/price assumptions.

Instead show only high-level outputs such as:

- Potential Automation Opportunity
- Estimated Time Saving
- Estimated Cost Saving

### Important principle

The Simulation result should be positioned as an estimate of potential value, not a guaranteed realized saving.

---

## 8. Additional Opportunity Pool

The meeting emphasized that Manual Processing with No Clear Reason is only one opportunity category.

Other potential opportunities can be added to the broader opportunity pool, such as:

- Manual cases related to PO issues
- Manual cases related to Contract issues
- Opinion Inquiry cases where automation may still be possible
- RPA cases requiring Rerun / human intervention

These do not all need to be fully analyzed now.

The purpose is to demonstrate that Process Mining can reveal a pipeline of improvement opportunities for future deep-dive work.

---

## 9. Business Case Requirement

The client-facing story cannot stop at technical analysis.

The team must eventually compare:

```text
Potential Saving
vs
Cost of Process Mining / Improvement Service
```

The Business Case must be attractive enough to justify further investment.

Example concern raised:

If the potential saving is only CNY 30K–40K but the proposed service costs CNY 400K, the case will not be convincing.

Therefore, the final output needs to demonstrate that the total opportunity pool is large enough relative to the potential delivery cost.

This pricing/business model discussion is not purely an analyst task and should involve the solution/offering owners.

---

## 10. Why IBM Process Mining

A major strategic point from the meeting is that the team must clearly answer:

> Why IBM Process Mining instead of Excel, generic spot analysis, or Celonis?

Potential differentiators discussed or implied:

- Process-level visibility instead of static category reporting
- Ability to identify hidden human intervention and process deviations
- Process variants and sequence analysis
- Simulation of improvement scenarios
- Identification of future automation opportunities
- China-local data/deployment advantages
- Potentially lower data-security or data-movement concerns for China operations
- Reusable analysis capability rather than a one-off charting exercise

The exact commercial differentiators still need alignment with the offering/solution team.

---

## 11. Celonis Competitive Context

There was discussion that Global teams may already have exposure to Celonis.

This creates two implications:

1. The client may already understand Process Mining and therefore expect a mature story.
2. IBM must articulate its differentiators clearly, especially for China/local deployment and data access.

The team should avoid presenting a dashboard that looks like simple BI, because it would make comparison with a mature Process Mining platform unfavorable.

---

## 12. Delivery / Commercial Questions Still Open

The meeting surfaced several questions that require input beyond the current analysis team:

- Is the Process Mining engagement a one-time analysis or reusable capability?
- What is the proposed delivery model?
- What IBM Process Mining edition/version would be proposed to the client?
- Is server/infrastructure cost involved?
- How should the service be priced?
- Can the client reuse the environment after training?
- If the client does not fund it, can IBM fund it internally based on proven savings?

These questions should be resolved with the solution/offering owners and stakeholders responsible for pricing.

---

## 13. Timeline / Stakeholder Context

The client/Global planning window is time-sensitive.

The meeting indicates that the relevant Global planning discussions will begin in early September, with decisions becoming more fixed later in the month.

Therefore, the immediate goal is not to complete every root-cause investigation.

The goal is to produce a credible, attractive Business Case and Showcase that can be used to start the conversation with Global stakeholders.

---

## 14. Agreed Priority Actions

1. Simplify the overall overview page.
2. Add RPA human-intervention / Rerun breakdown inside RPA Process.
3. Verify suspicious process paths before client presentation.
4. Prefer an overall Process Map if split Manual/RPA paths remain confusing.
5. Reduce low-value pie charts.
6. Refine Manual reasons into PO / Contract / Out of Scope / No Clear Reason where possible.
7. Check event sequence for PO Matchable vs Opinion Inquiry / Rerun before drawing conclusions.
8. Convert monthly trend charts from raw counts to percentages.
9. Build an RPA monthly straight-through vs Rerun ratio view.
10. Keep Simulation conservative and client-facing outputs simple.
11. Present potential saving, not detailed internal cost formulas.
12. Build a broader opportunity pool rather than relying on one single automation opportunity.
13. Add a clear `Why IBM Process Mining` story.
14. Align pricing, delivery model, server cost, and competitive positioning with the solution/offering team.

---

## 15. Suggested Client Storyline

```text
Current State
    ↓
RPA / Manual / Human Intervention Overview
    ↓
Process Mining Visibility
    ↓
Where Deviations and Human Intervention Occur
    ↓
Manual / Rerun Opportunity Areas
    ↓
Trend and Sequence Insights
    ↓
Simulation of a Conservative Improvement Scenario
    ↓
Estimated Time / Cost Saving
    ↓
Future Deep-dive Opportunity Pipeline
    ↓
Why IBM Process Mining
    ↓
Business Case
```

---

## 16. Key Takeaway

The main outcome of this meeting is not to add more analysis.

The direction is to transform the existing work from an internal analytical dashboard into a concise Process Mining business story:

> Show the current process, reveal hidden human intervention and deviations, identify credible improvement opportunities, simulate conservative savings, and leave enough evidence for the client to want a deeper engagement.
