# Feature: Ticketing dashboard (analytics)

## Status

`done` (UI mocked)

## Summary

Landing view for the Ticketing module (`/ticketing`): status and priority breakdown cards. White · black · orange palette. Counts derived from mock tickets.

## Layout

| Region | Content |
|--------|---------|
| Toolbar | “Ticket system” title + timestamp + refresh |
| Row | Ticket by status (donut + legend) · Ticket by priority (horizontal bars) |

## Acceptance criteria

- [x] Shows status and priority distribution from mock tickets
- [x] Routed as Ticketing › Dashboard (not a top-level Overview module)
