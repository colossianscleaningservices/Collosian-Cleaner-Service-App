# Duplication Review: Reusable Elements & Widgets

This document lists duplicated UI elements and patterns that can be consolidated into shared widgets for consistency and maintainability.

---

## 1. **Job detail: label–value row and chip (high impact)**

**Location:**  
- `lib/app/modules/client/job/client_job_detail_view.dart`  
- `lib/app/modules/cleaner/job/cleaner_job_detail_view.dart`

**Duplication:**  
- `_row(String label, String value, ColorScheme scheme)` – identical in both files (label in fixed-width 130px, value in Expanded, 14px text, 8px bottom padding).  
- `_chip(String label, Color bg, Color fg)` – identical (padding 10/6, radiusSmall, CommonText.medium 13px).

**Recommendation:**  
Extract to shared widgets, e.g. under `lib/app/widget/common/`:

- **LabelValueRow** – `label`, `value`, optional `labelWidth` (default 130), optional `ColorScheme` (or use `context.colorScheme`).  
- **InfoChip** – `label`, `backgroundColor`, `foregroundColor` (or scheme-based variants).

Use in both client and cleaner job detail views.

---

## 2. **Job detail: cleaner card (high impact)**

**Location:**  
- `lib/app/modules/client/job/client_job_detail_view.dart` → `_CleanerCard`  
- `lib/app/modules/cleaner/job/cleaner_job_detail_view.dart` → `_CleanerCard`

**Duplication:**  
Same implementation: AppCard with Row (48×48 avatar/initial, 12px gap, name + status column, “Share” TextButton). Only the controller type differs (ClientDashboardController vs CleanerDashboardController) for `setTab`; the card UI is identical.

**Recommendation:**  
Move to a single shared widget, e.g. `lib/app/widget/common/cleaner_card.dart` (or under `lib/app/widget/`), taking `ClientJobCleaner`, `onShare`, and `ColorScheme`. Both job detail views import and use it. If needed, pass a callback for “My Jobs” instead of resolving the controller inside the widget.

---

## 3. **Section title – leave as-is**

**Location:**  
Repeated in many modules: `CommonText.semiBold('…', size: 16, color: scheme.onSurface)` (e.g. job details, create_job, contact_us, earnings, calendar views).

**Decision:**  
Leave section titles as inline `CommonText.semiBold(…)`; do not extract a shared SectionTitle widget.

---

## 4. **Section card (AppCard + title + content) (medium impact)**

**Location:**  
- `create_job_view.dart` – multiple AppCards with `CommonText.semiBold(…, size: 16)` then form fields with `spacing: 14`.  
- `client_job_detail_view.dart` / `cleaner_job_detail_view.dart` – AppCard + section title + `SizedBox(height: 12)` + list of `_row`/chips.  
- `contact_us_view.dart`, `cleaner_earnings_view.dart`, and others – same pattern: AppCard, title, spacing, body.

**Recommendation:**  
Optional **SectionCard** (or keep as a convention):  
- Child: Column with optional `title`, then `spacing`, then `children`.  
- Padding: e.g. `paddingSymmetric(horizontal: 18, vertical: 16)` or a constant.  
- Reduces repeated “AppCard + title + SizedBox + content” and keeps padding and spacing consistent.

---

## 5. **Calendar empty state card (high impact)**

**Location:**  
- `lib/app/modules/client/dashboard/view/client_calendar_view.dart` → `_EmptyStateCard`  
- `lib/app/modules/cleaner/dashboard/view/cleaner_calendar_view.dart` → `_EmptyStateCard`

**Duplication:**  
Same concept: “No jobs this month.” + “Your assigned jobs will appear here.” + “My Jobs” button.  
- Client: uses Material `Card` + `context.colorScheme.onPrimary`.  
- Cleaner: uses `AppCard` + `.paddingAll(14)` + `.marginSymmetric(horizontal: 24)`.

**Recommendation:**  
One shared widget, e.g. **CalendarEmptyCard** in `lib/app/widget/` or dashboard shared widgets:

- Parameters: `message` (or two lines), `buttonLabel`, `onPressed`, optional `ColorScheme`.  
- Use one card style (e.g. AppCard) and same padding so both calendars look the same. Pass a callback for “My Jobs” so the widget doesn’t depend on client vs cleaner controller.

---

## 6. **Empty states and NoDataView (medium impact)**

**Location:**  
- `NoDataView` already exists in `lib/app/widget/layout/no_data_view.dart` (icon, title, subtitle, optional action).  
- Several modules use custom empty UIs instead of or in addition to NoDataView:

  - **support_document_view.dart** – `_EmptyState` that wraps `NoDataView` (good).  
  - **cleaner_references_view.dart** – `_EmptyState` with its own Container, icon, two text lines (no NoDataView).  
  - **training_and_resources_view.dart** – `_EmptyState` with custom layout.  
  - **cleaner_payout_computation_view.dart** – `_EmptyWorkEntries`.  
  - **notification_view.dart** – `_EmptyNotifications`.

**Recommendation:**  
- Prefer **NoDataView** for list-empty cases: pass `title`, `subtitle`, `icon`, `actionLabel`, `onAction`.  
- Where the layout is “icon + title + subtitle + optional button”, refactor to use NoDataView with the same padding/centering so empty states look consistent.  
- Keep specialized empty widgets only when the layout or content is clearly different (e.g. calendar empty card above).

---

## 7. **Avatar – common widget (implemented)**

**Location:**  
- `lib/app/widget/common/avatar.dart` → **AppAvatar**

**Spec:**  
- **Size:** 48×48 (fixed).  
- **Corner radius:** 16.  
- **API:** `imageUrl` (optional), `initial` (optional), `name` (optional; used for initial when no image/initial).  
- Shows network image when `imageUrl` is set; otherwise shows first letter of `name` or `initial`, or `?`, on `primaryContainer` with 18px semiBold primary text.

**Usage:**  
Use **AppAvatar** wherever a 48×48 avatar/initial is needed (e.g. cleaner cards in client and cleaner job detail views). Profile headers and other sizes (e.g. 56×56) keep their own layout; use AppAvatar only for the common 48×48 case.

---

## 8. **Contact / info row with icon (low–medium impact)**

**Location:**  
- `contact_us_view.dart` – `_InfoRow(icon, label, value, scheme, onTap?)`: Row with icon 20px, 12px gap, Column(label 12px, value 14px).  
- Job detail views use `_row(label, value)` without icon.  
- Other modules have similar “label + value” or “icon + label + value” rows.

**Recommendation:**  
- If you introduce a shared **LabelValueRow** (see §1), consider an optional **leading** widget (e.g. Icon) so one widget can cover both “label + value” and “icon + label + value”.  
- Or add a separate **InfoRow** (icon + label + value, optional onTap) in `lib/app/widget/common/` and use it from contact_us and any other “contact info” blocks.

---

## 9. **Repeated padding and spacing constants**

**Observation:**  
- `UiConstants.defaultPadding`, `UiConstants.padding`, `UiConstants.gap`, `EdgeInsets.all(14)`, `EdgeInsets.all(16)`, `horizontal: 18, vertical: 16`, `marginSymmetric(horizontal: 24)` appear in many places.  
- Section cards use similar but not identical padding (e.g. 18/16 vs 24/16).

**Recommendation:**  
- Prefer `UiConstants` for new code (e.g. `defaultPadding`, `padding`, `gap`).  
- If you add **SectionCard**, use one or two named constants for section card padding so all section cards share the same inset.

---

## 10. **Summary: suggested new shared widgets**

| Widget            | Purpose                         | Status / location              |
|-------------------|----------------------------------|---------------------------------|
| **AppAvatar**     | 48×48 avatar, 16px radius       | ✅ `widget/common/avatar.dart`  |
| **LabelValueRow** | Label + value (job detail, etc.)| ✅ `widget/common/label_value_row.dart` |
| **InfoChip**      | Status/tag chip                 | ✅ `widget/common/info_chip.dart` |
| SectionTitle      | —                               | Leave as-is (do not extract)   |
| **CleanerCard**   | Job cleaner row (avatar, name, Share) | ✅ `widget/common/cleaner_card.dart` |
| **CalendarEmptyCard** | “No jobs this month” + action | ✅ `widget/layout/calendar_empty_card.dart` |
| (Optional) SectionCard | AppCard + title + spacing + body | `widget/layout/` or `widget/`   |
| (Optional) InfoRow    | Icon + label + value (+ onTap)  | `widget/common/`                |

---

## Implementation order (suggested)

1. **AppAvatar** – ✅ done (48×48, 16px radius; used in job detail cleaner cards).  
2. **LabelValueRow** and **InfoChip** – ✅ done; used in both client and cleaner job detail views.  
3. **CleanerCard** – ✅ done; single implementation in `widget/common/cleaner_card.dart`, used in both job details.  
4. **CalendarEmptyCard** – ✅ done; single implementation in `widget/layout/calendar_empty_card.dart`, used in both client and cleaner calendar views.  
5. **Empty states** – migrate custom empty UIs to **NoDataView** where the layout matches (optional).  
6. **SectionCard** and **InfoRow** – add if you want to standardise more screens (optional).  
( **Section title** – leave as-is; do not extract. )

Duplicated private `_row`, `_chip`, `_CleanerCard`, and `_EmptyStateCard` have been removed from the job detail and calendar views.
