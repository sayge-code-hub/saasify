# Feature: Overview dashboard

## Status

`done` (UI mocked)

## Summary

Post-login landing page using a Maglo-inspired dashboard layout: black workspace banner, pulse metrics, active ticket table, and a right-hand attention panel with quick actions. White · black · orange palette. Counts and lists come from mock tickets.

## Layout

| Region | Content |
|--------|---------|
| Main | Workspace banner, pulse / resolved meta, active ticket rows, orange “View all tickets” link, summary totals |
| Right panel | Spotlight customer/ticket, light-orange “Browse queue”, queue fields, orange “Open ticketing”, Preview / Open |

Compact widths stack the right panel below the main column.

## Acceptance criteria

- [x] Shows open / pending / in-progress counts from mock tickets
- [x] Lists active tickets with links to detail
- [x] CTA into Ticketing module (`Open ticketing`)
- [x] Three-region shell chrome (sidebar + header + main/right) uses brand palette
