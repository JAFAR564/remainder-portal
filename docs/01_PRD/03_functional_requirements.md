# PRD §1.4 — Functional Requirements

> **Part of:** Module 1: Product Requirement Document
> **Navigation:** Up from `02_user_stories.md` | Next to `04_ui_ux_vision.md`

---

### FR-1: Authentication & Access Control

- Magic link authentication (passwordless) via email, resolving to deep link on mobile (Universal Links / App Links)
- Two roles: `player` and `admin`; route-guarded via Riverpod `AsyncNotifier`
- Admin views are never rendered client-side until token validation completes

### FR-2: Community Roster (Public View)

- Real-time searchable + sortable character table, sourced from Google Sheets
- Mobile: swipeable glass cards per character, presented as floating, luminescent glass cards with soft gold outlines and subtle iridescent overlays
- Desktop: expanded sortable data table with column filters
- Character card fields: Name, Faction, Status, Faceclaim (image), Title, Joined Date

### FR-3: Admittance Pipeline (Admin View)

- Mobile-optimized answer sheet reader (scrollable, sectioned)
- AI recommendation panel: tiered card showing DeepSeek structural score + Groq tone score
- Inline faceclaim status badge (`Available` / `Claimed` / `Reserved`)
- Action bar: `Approve` (green shimmer) / `Decline` (muted red) / `Hold` (amber)
- Auto-writes result to Google Sheets `Admittance Log` tab on action

### FR-4: Chronicles & World State (Public View)

- Vertical storybook timeline, entries sorted by narrative date
- Each Chronicle entry: AI-generated summary by Gemini 1.5 Pro + manual admin annotations
- Entry cards have an ambient glow effect on hover/press
- "Grounded in lore" badge on entries verified against the cached lore context RAG corpus

### FR-5: Character Profile Management

- Admin-editable character stat blocks (rich text, numeric fields, image upload)
- Version history of stat changes (stored in Sheets or Supabase)
- Public-facing display: read-only glass card with subtle animated stat bars

### FR-6: AI Grading Dashboard

- Displays per-application reasoning chain from DeepSeek
- Shows Groq keyword/tone flags with confidence percentages
- Exportable PDF summary per application
