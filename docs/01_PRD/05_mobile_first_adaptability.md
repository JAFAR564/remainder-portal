# PRD §1.6 — Mobile-First Adaptability

> **Part of:** Module 1: Product Requirement Document
> **Navigation:** Up from `04_ui_ux_vision.md`

---

## Breakpoint Philosophy

| Breakpoint | Width Range | Layout Mode |
|---|---|---|
| **Mobile S** | 320px–599px | Single-column; swipeable cards; bottom nav |
| **Mobile L / Tablet** | 600px–899px | Two-column card grid; side drawer |
| **Desktop** | 900px+ | Rail nav; expanded data tables; multi-panel layout |

---

## Pivot Patterns

### Roster View — Mobile vs. Desktop

- **Mobile:** `PageView` / `ListView` of swipeable `GlassCard` character widgets; swipe-right to view full profile, swipe-left for quick admin actions
- **Desktop:** `DataTable2` (package: `data_table_2`) with sortable columns, inline expansion, faceclaim thumbnails in cells

### Admittance Pipeline — Mobile vs. Desktop

- **Mobile:** `DraggableScrollableSheet` answer sheet viewer; AI recommendation panel as a bottom sheet; action buttons fixed at viewport bottom
- **Desktop:** Three-panel layout — applicant list (left) | answer sheet (center) | AI grading panel + action bar (right)
