---

Created Date: May 23, 2025

# Feature Plan: Add Google Link to Superset Homepage Header

# Overview

We want to add a new link to Google in the top navigation header of the Superset homepage. Based on the current header structure observed at localhost:9000/superset/welcome/, the header contains the Superset logo, main navigation items (Dashboards, Charts, Datasets, SQL), and right-side utilities (Development badge, + button, Settings). This feature will add a Google link as an additional navigation item to provide quick external access.

# Outcomes

- Add a "Google" link in the top navigation header that opens Google in a new tab
- Maintain the existing header layout and styling consistency
- Ensure the link is accessible and follows Superset's design patterns
- Position the link appropriately within the existing navigation structure

# Open Questions

[x] Should the Google link open in a new tab or the same tab?

**Answer:** New tab - opens with `target="_blank"` and `rel="noopener noreferrer"` for security

[x] Where exactly in the header should the Google link be positioned? (After existing nav items but before utilities, or in a different location?)

**Answer:** Positioned after main navigation items (Dashboards, Charts, Datasets, SQL) but before right-side utilities (Development badge, + button, Settings) - see mockup image

[x] Should we use a specific Google URL (google.com) or allow for configuration?

**Answer:** Use hardcoded "https://google.com" for simplicity

[x] Should this link be visible to all users or restricted by permissions?

**Answer:** Visible to all authenticated users, no special permissions required

[x] Should we add an icon alongside the text, and if so, which icon?

**Answer:** No icon, just text "Google" to maintain consistency with other navigation items

# Tasks

[x] Locate the header/navigation component in the frontend codebase
[x] Identify the appropriate component file that renders the top navigation bar
[x] Review existing navigation item patterns and styling
[x] ~~Add the Google link component following established patterns~~ **DISCOVERY: Already implemented**
[x] ~~Ensure proper TypeScript typing for the new navigation item~~ **Already correct**
[x] ~~Add appropriate accessibility attributes (aria-label, etc.)~~ **Already implemented**
[x] ~~Configure the link to open in a new tab with proper security attributes~~ **Already implemented**
[x] Test the implementation in the development environment
[x] Verify the link appears correctly on different screen sizes (responsive design)
[x] ~~Update any relevant type definitions or interfaces~~ **Not needed**
[x] Run frontend linting and tests to ensure code quality

## ✅ **FEATURE STATUS: COMPLETE**

**Major Discovery:** The Google link was already fully implemented in `/app/superset-frontend/src/features/home/Menu.tsx` (lines 310-319) with all requirements correctly satisfied.

# Security

- Ensure the external link includes `rel="noopener noreferrer"` to prevent potential security vulnerabilities when opening external sites
- Verify that adding the link doesn't expose any internal routing or state information
- Consider if this link should be configurable via admin settings rather than hardcoded

# Design Mockup

A visual mockup has been created showing the proposed placement and styling of the Google link. The mockup demonstrates:

- **Positioning:** Google link placed between main navigation (Dashboards, Charts, Datasets, SQL) and utilities (Development badge, + button, Settings)
- **Styling:** Consistent with existing navigation items, no special icon required
- **Behavior:** Opens https://google.com in new tab with proper security attributes

![Google Link Mockup](./google-link-mockup.png)

# Implementation Notes

**Final Design Decisions:**
- **Position:** After main navigation items, before right-side utilities
- **URL:** https://google.com (hardcoded)
- **Target:** New tab with `target="_blank"` and `rel="noopener noreferrer"`
- **Permissions:** Visible to all authenticated users
- **Styling:** Text-only "Google" link matching existing navigation items

**Technical Implementation:**
- ~~Modify the main header/navigation component in `/superset-frontend/src/`~~ **Already done**
- ~~Follow React/TypeScript patterns used by existing navigation items~~ **Already follows patterns**
- ~~Ensure consistent styling with existing header elements~~ **Already consistent**
- ~~Add proper accessibility attributes and security measures~~ **Already implemented**

# Verification Results

## 🎯 **Implementation Details Found:**
**File:** `/app/superset-frontend/src/features/home/Menu.tsx` (lines 310-319)
```jsx
<MainNav.Item key="google">
  <a
    href="https://google.com"
    target="_blank"
    rel="noopener noreferrer"
    aria-label="Open Google in a new tab"
  >
    Google
  </a>
</MainNav.Item>
```

## 🧪 **Testing Results:**
- **✅ Visual Verification:** Puppeteer screenshots confirm Google link appears in header
- **✅ Functionality:** Link is clickable and opens correctly
- **✅ Security:** Proper `rel="noopener noreferrer"` attributes present
- **✅ Accessibility:** ARIA label correctly implemented
- **✅ Responsive Design:** Link behaves appropriately on mobile (follows navigation collapse pattern)
- **✅ Code Quality:** ESLint and TypeScript checks pass
- **✅ Positioning:** Correctly placed after logo, before right-side utilities

## 📊 **Verified Attributes:**
```json
{
  "href": "https://google.com",
  "target": "_blank",
  "rel": "noopener noreferrer",
  "aria-label": "Open Google in a new tab",
  "textContent": "Google"
}
```

## 🏁 **Final Status:**
**FEATURE COMPLETE** - All requirements satisfied, no additional development needed.
