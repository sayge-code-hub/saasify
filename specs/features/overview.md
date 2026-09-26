# Feature: Overview dashboard

## Status

`done` (UI mocked)

## Summary

Post-login analytics landing page inspired by ticket-system dashboards: status and priority breakdown cards, plus a ranked “Ticket by application” load board. White · black · orange palette. Counts derived from mock tickets / tags.

## Layout

| Region | Content |
|--------|---------|
| Toolbar | “Ticket system” title + timestamp + refresh |
| Top row | Ticket by status (donut + legend with %) · Ticket by priority (horizontal bars) |
| Bottom | Ticket by application — insight strip + ranked product-area rows (active volume bar, open/pending/done chips) |

Compact widths stack the top cards vertically.

## Acceptance criteria

- [x] Shows status and priority distribution from mock tickets
- [x] Application load ranked from ticket tags (not an empty half-table)
- [x] CTA into Ticketing module (`Open ticketing`)
- [x] Orange / black / white palette (no multi-hue pie charts)
