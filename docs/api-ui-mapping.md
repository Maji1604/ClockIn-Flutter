# API → UI Mapping & Implementation Plan

This document maps UI elements to backend endpoints and DB side-effects, and provides a practical, step-by-step implementation plan for the admin onboarding + dashboard flows. It intentionally excludes email verification flows per request.

## Quick summary
- Goal: provide a smooth post-registration experience for a newly created company admin, and implement the Dashboard + core admin workflows (invites, departments, teams, time tracking, settings). 
- Deliverables in this doc:
  - Concise API → UI mapping for each primary flow (request/response/DB writes)
  - PM-style implementation plan with milestones, tasks, acceptance criteria and test cases

---

## 1. Company registration (post-registration immediate view)

UI:
- Full-screen Welcome modal showing:
  - "Welcome to <Company Name>" title
  - Summary card: Company name, slug, admin email, onboarding progress (e.g. 1 of 5)
  - Primary CTA: "Go to dashboard"; Secondary CTA: "Invite teammates"; Tertiary: "Finish profile / change password"

API:
- POST /api/companies/register

Request example:
```json
{
  "company_name":"Acme Testing Co.",
  "admin_first_name":"Alice",
  "admin_last_name":"Admin",
  "admin_email":"alice@example.com",
  "admin_password":"Password123!",
  "timezone":"UTC",
  "create_sample_data": true
}
```

Success response (simplified):
```json
{
  "success": true,
  "data": {
    "company": { "id":"...", "name":"Acme", "slug":"acme", "company_code":"ACME" },
    "user": { "id":"...", "email":"alice@example.com", "is_active":1 },
    "token":"v4.public....",
    "onboarding": { "next_steps":["invite_teammates","create_dept"] }
  }
}
```

DB side-effects:
- INSERT `companies`
- INSERT `users` (admin)
- INSERT `memberships` (admin → company)
- INSERT default `departments` (optional)
- INSERT default `teams` (optional)

Notes:
- Client stores returned token and user; navigates into authenticated flow.
- Use `slug` for company-specific API parameters (lowercase). Avoid sending uppercase company_code.

---

## 2. Login (email + password; company optional)

UI:
- Login page with fields: email, password, company ID (optional). If multiple memberships returned, show company selection UI.

API:
- POST /api/auth/login

Request examples:
- Email-only
```json
{ "email":"alice@example.com", "password":"Password123!" }
```
- Company-specific
```json
{ "email":"alice@example.com", "password":"Password123!", "company_identifier":"acme" }
```

Success (single membership):
```json
{ "success": true, "data": { "user": {...}, "token": "v4.public...." } }
```

Success (multiple memberships):
```json
{ "success": true, "data": { "user": {...}, "memberships": [{"company":{...}, "role":"admin"}, ...] } }
```

Error (no membership):
```json
{ "success": false, "error": { "code":"NO_COMPANY", "message":"Account not associated with any company." } }
```

DB side-effects: none (reads user + membership)

UI behavior:
- If `token` returned: persist token & user, navigate to Dashboard (or Password change flow if required).
- If `memberships` returned: show `CompanySelectionPage` and re-call login with selected `company_identifier`.
- If NO_COMPANY (403): show clear CTA: "Request membership" or "Contact admin".

---

## 3. Invite teammates

UI:
- Invite modal/form: emails (comma-separated or CSV upload), role dropdown, department select, team select, message, Send button.
- Pending invites list with status, resend, cancel actions.

API:
- POST /api/invitations

Request example:
```json
{ "emails":["bob@example.com","carol@example.com"], "role":"employee", "department_id":"...", "team_id":"..." }
```

Success:
```json
{ "success": true, "data": { "invitations": [ {"id":"...","email":"bob@example.com","token":"...","expires_at":"..." } ] } }
```

DB side-effects:
- INSERT `invitations` rows (token, inviter_id, company_id, role, expires_at)
- Email jobs queued (background)

Accept invite flow (brief):
- If invitee _already has account_: after login, POST or server-side linking creates `memberships` (user->company)
- If invitee _new_: sign-up form with token -> create `users`, create `memberships`, mark `invitations.accepted_at`

---

## 4. Departments & Teams

UI:
- Departments page (list, add button). Add dept modal: name, code, manager.
- Teams page/drawer: create team with department assignment and description.

APIs:
- POST /api/departments
- POST /api/teams
- PATCH /api/memberships/:id (assign department/team)

DB:
- INSERT `departments`
- INSERT `teams`
- UPDATE/INSERT `memberships` when assigning users

---

## 5. Time tracking

UI:
- Global Start/Stop timer, Timesheet page, session details.

APIs:
- POST /api/time/sessions (start)
- PATCH /api/time/sessions/:id (stop)
- GET /api/time/sessions?company_id=&start=&end= (timesheet)

DB:
- INSERT `time_sessions` with started_at
- UPDATE `time_sessions` with stopped_at; compute duration as needed

---

## 6. Company settings

UI:
- Settings > Company identity: show slug (+copy), editable company_code (if needed), timezone, language, work hours

API:
- PATCH /api/companies/:id/settings

DB:
- UPDATE `companies` row or `company_settings` record

---

## 7. Dashboard summary (recommended single endpoint)

UI:
- KPI cards, recent users, recent sessions, onboarding progress, quick actions

Recommended API:
- GET /api/companies/:id/summary
Response should include: counts (users, clocked_in_now, pending_invites), recent users (N), recent sessions (N), onboarding progress

---

# Implementation plan (PM-style)

Goal: Implement the core admin onboarding + dashboard flows with high quality UX and tests. No email verification flow is required right now.

Milestone 0 — Prep (1 day)
- Tasks:
  - Ensure shared domain entities (LoginRequest/Response) are wired for optional companySlug
  - Add/verify `LoginRequestModel.toJson()` sends company_identifier only when present and normalized to lowercase (done)
  - Create skeleton `DashboardPage` route and core app navigation (if not present)
- Deliverables: Code compiles, routes registered

Milestone 1 — Basic Post-registration + Welcome modal (2 days)
- Tasks:
  - Implement `WelcomeModal` component (modal shown after POST /api/companies/register)
  - Wire the registration flow to show modal with data from response (company, slug, user)
  - CTA: Go to Dashboard (navigates to DashboardPage), Invite Teammates (open Invite modal)
- Acceptance criteria:
  - After successful registration, token persisted and Welcome modal visible with correct data
  - Unit test: registration flow shows modal and stores token

Milestone 2 — Dashboard skeleton + Summary API (3 days)
- Tasks:
  - Add `DashboardPage` scaffold: left nav, top bar, main content region
  - Implement `DashboardSummaryUseCase` and UI to fetch GET /api/companies/:id/summary
  - Show basic KPI tiles (user count, clocked_in_now, pending_invites) and recent users list
- Acceptance:
  - Dashboard fetches summary and shows accurate values
  - Unit tests for summary parsing and widgets

Milestone 3 — Invites & Users UX (3 days)
- Tasks:
  - Invite modal & pending invites list (POST /api/invitations, GET /api/invitations)
  - Users list page (GET /api/users?company_id=)
  - Admin actions: resend/cancel invite, deactivate user (PATCH /api/memberships/:id)
- Acceptance:
  - Invites can be created and show in pending list
  - Users list reflects new memberships within 5s of acceptance (poll or websocket)
  - Tests: unit tests for invite use-case; integration test mocking API responses

Milestone 4 — Departments & Teams (2 days)
- Tasks:
  - Departments CRUD UI and API wiring
  - Teams CRUD UI and API wiring
  - Assign users to department/team (bulk patch)
- Acceptance:
  - Departments created and visible in selection dropdowns
  - Teams created and assignable

Milestone 5 — Time tracking (3 days)
- Tasks:
  - Implement global Start/Stop timer component calling POST/PATCH time sessions
  - Timesheet page reading GET /api/time/sessions
  - Small chart for last 7 days (optional simple sparkline)
- Acceptance:
  - Start/Stop persists sessions and timesheet shows created sessions
  - Tests for session creation logic

Milestone 6 — Settings & polish (2 days)
- Tasks:
  - Company settings page: update company_code, timezone, slug copy action
  - InputFormatter to lowercase company slug field on Login page
  - SnackBar display for server errors (NO_COMPANY, 409, 422) — UI-level messages
- Acceptance:
  - Settings saved and reflected in the summary
  - Login company field lowercases input and client uses slug
  - Snackbar shows server responses for errors

Milestone 7 — Tests, accessibility, and docs (2 days)
- Tasks:
  - Unit tests covering AuthBloc login paths: token returned, memberships returned, 403 fallback
  - Integration tests for registration → dashboard sequence (mock remote datasource)
  - Accessibility checks (labels, contrast)
  - Add `docs/api-ui-mapping.md` (this file) and `docs/onboarding-checklist.md`
- Acceptance:
  - Tests pass locally; docs added

Total estimate: ~15 working days (can be parallelized across contributors). Adjust per team and priorities.

---

# Acceptance criteria (overall)
- Registration returns token and user; client persists token & navigates to Welcome/Dashboard
- Dashboard shows KPIs from summary endpoint, no visible crashes
- Admin can invite users; pending invites list shows new invites
- Departments & teams can be created and assigned
- Time sessions can be started and stopped and appear in timesheet
- Login handles token, multiple memberships and NO_COMPANY gracefully
- Errors from server are surfaced to user as SnackBar/dialog with actionable CTAs where applicable

---

# Suggested first implementation sprint (2‑week plan)
Week 1 (Days 1–5): Milestones 0, 1, 2
Week 2 (Days 6–10): Milestones 3, 4
Week 3 (Days 11–14): Milestones 5, 6
Week 4 (Days 15): Buffer for tests, docs, and review

---

# If you want me to continue
I can now do one of the following immediately:
- Create the `docs/onboarding-checklist.md` with JSON payload examples and sample UI mockups (forms + props)
- Scaffold `DashboardPage` and wire the `DashboardSummaryUseCase` to call GET /api/companies/:id/summary (I will add UI skeleton and a mock response so it can be validated quickly)
- Implement the Invite modal and POST /api/invitations use-case (frontend wiring + tests)

Tell me which next step you'd like me to take and I'll implement it (I can start by scaffolding the Dashboard skeleton and wiring the summary API).