# Ennoia Platform Reviewer Framework (`APP_REVIEWER.md`)

This document serves as the official quality assurance gate, design system bible, and product review checklist for the **Ennoia** social roleplaying platform. Any developer, designer, or AI agent making modifications to this codebase must run their work against this framework before proposing commits or deploying builds.

---

## 1. Product Vision & Core Lore Principles

### The Vision
Ennoia is a sovereign, self-governed digital estate built for immersive text-based roleplay. It is designed to replace hostile social media groups and scattered Discord servers with a structured, elegant digital home for writers. It focuses on character discovery, collaborative writing, narrative continuity, and streamlined moderation.

### Brand & Lore Guidelines
*   **The Sigil & Aesthetics:** The design grammar is built on "Prussian Elegance"—matte prussian blues, soft ivory whites, subtle gold/teal accents, and frosted glass layers (sigma X/Y between 6.0 and 12.0). Visual elements must breathe with generous whitespace.
*   **Terminology Consistency:**
    *   *Player:* The out-of-character (OOC) participant.
    *   *Character:* The in-character (IC) persona.
    *   *Admittance Claim:* The onboarding application.
    *   *Community Roster:* The registry of approved character chronicles.
    *   *Frequencies:* Dedicated narrative zones or channels (e.g. Aethelgard, Elysium, Vanguard).
    *   *Resonance:* The metric of alignment and narrative cohesion between posts.
*   **Anti-Generic Rule:** Avoid standard corporate, flat web, or high-contrast neon grids. The interface must feel like an *experience artefact*—premium, calm, academic, and immersive.

---

## 2. Interface (UI/UX) Standards

### Mobile-First Design
*   **Breakpoints:** Mobile (< 600dp) | Tablet (600–899dp) | Desktop (900dp+).
*   **Responsive Scaling:** Layouts must use `LayoutBuilder` or `ResponsiveLayout` helpers. Never hardcode absolute pixel layouts or call `MediaQuery.of(context).size` directly for calculations.
*   **Touch Targets:** Interactive elements must maintain a minimum hit target of 48x48dp.
*   **Tap Feedback:** Touch elements must be wrapped in `SpringTapWrapper` with underdamped configurations (damping ratio $\zeta \approx 0.85$, $c=24$ for $k=200$, $m=1$) for an organic, tactile spring-back feel.

### Typography Hierarchy
*   **Headlines & Faction Headers:** *Cormorant Garamond* (light weights, wide letter-spacing, elegant caps).
*   **Body Prose & Chat:** *Jost* or *Outfit* (highly legible, comfortable line heights at 1.5).
*   **Metadata & Stats:** *JetBrains Mono* (monospaced clarity for timestamps, faction tallies, and grading scores).

---

## 3. Technical & Performance Gateways

### Performance Constraints
*   **Glassmorphism Performance:** Gaussian blurs are expensive. Keep blurs constrained within `[6.0, 12.0]` sigma ranges. Never nest multiple glass containers with active filters.
*   **Asset Management:** Use network-cached image decoders. Avoid loading massive, uncompressed user profile images. Set cache parameters (`width: 200`, `fit: cover`) to avoid GPU memory leaks.
*   **Offline-First Cache:** The roster and claims data must be cached locally (using `rosterCacheServiceProvider` / HydratedState). UI loading states should resolve instantly from cache while a background refresh runs silently.

### Security, Privacy, and Data Governance
*   **Authentication Hooks:** Deep link auth hashes must align cleanly with Supabase callbacks.
*   **Data Partitioning:**
    *   *Public Data:* Character name, alias, faction, faceclaim, and character introduction.
    *   *Moderator Only:* Applicant email, timezone, experience, rules verification, and internal review audit scores.
    *   *Public visibility controls:* Let players toggle visibility of OOC fields like pronouns, timezone, and writing genres.
*   **Input Sanitization:** Textareas for writing samples and bios must be sanitized to strip HTML or script tags prior to database insertion.

---

## 4. Onboarding, Application & Admittance Rules

### The Onboarding Flow
1.  **Login Entry:** Login screen must clearly display the invitation: *"New to Ennoia? Begin your admittance claim."* distinct from login options.
2.  **Submission Wizard:** Split the application into distinct Player Info and Character Details steps.
3.  **Submission Instructions:** The success state must explicitly state that:
    *   Admittance claim was received.
    *   The application is in the admin review queue.
    *   No logins are permitted until approval.
    *   Status can be checked by logging in to check the prompt status.

### Roster Image Handling
*   Approved characters must display their submitted faceclaim image on the Roster screen.
*   If no image is submitted, or if the URL fails to load, the screen **must** render the custom vector-painted abstract `EnnoiaProfilePlaceholder` sigil.
*   **Never** use a generic or random human face fallback.

---

## 5. AI Grading & Review Pipeline

### System Prompt & Grounding Rules
*   **Grounding:** AI evaluations must be dynamically constructed based on the applicant's name, faction, and writing style.
*   **Quality Audits:**
    *   *Literacy Gate (Stage 1.1):* Verify the writing sample is $\ge 50$ characters.
    *   *Detachment Gate (Stage 1.2):* Audit for first-person pronouns (I, me, my, mine, we, us, our). Flag violations immediately.
    *   *Symmetry Check:* Ensure the writing sample's style matches the selected faction motifs.
*   **Anti-Repetition Controls:** Prompts must require the LLM to write custom critiques naming character details. Fallback scripts must analyze word counts and detachment states to generate distinct warning flags rather than copying static templates.
*   **Authority Boundary:** AI recommendations are *diagnostic assistants*. Final approval power rests solely with human administrators.

---

## 6. Development Gate Checklist

Prior to submitting code or requesting build pipeline execution, verify the following:

- [ ] **Cross-Platform Check:** Widget layouts verified on both mobile width (<600dp) and desktop grid (>900dp).
- [ ] **Aesthetic Compliance:** Cormorant Garamond / Jost fonts implemented; default system serifs omitted.
- [ ] **Spring Animations:** SpringTapWrapper applied to new button paths.
- [ ] **Database Compatibility:** Custom fields written to sheet proxy without breaking sheet column bounds.
- [ ] **AI Consistency:** No hardcoded mock diagnostics strings used in the review pipeline.
- [ ] **Test Coverage:** Run UI unit tests on any modified GlassCard configurations.
- [ ] **AST Graph Integrity:** Recompile/update the AST code graph using `graphify update .`.

---

## 7. Review Prompts for AI Coding Assistants

When auditing a feature, ask these questions:
1.  *Does this design feel elegant and light-ethereal, or does it look like a generic corporate dashboard?*
2.  *Will the Gaussian blur in this GlassCard drop frames on a mid-range mobile device?*
3.  *What happens if the user's internet is slow? Does this widget load cached state immediately?*
4.  *Have we protected the player's personal OOC information from the public community roster?*
5.  *Is the AI critique for this application distinct, or will the next applicant see the exact same wording?*
