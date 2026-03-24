# Widows & Orphans — Pilot Onboarding Package

**v0.1.0-pilot**

Welcome, and thank you for being among the first to use Widows & Orphans. This guide was written for you — the Care Pastor, the benevolence team lead, the person who picks up the phone when someone in your congregation is hurting. We built this platform because we believe that asking for help should never cost someone their dignity.

This document will walk you through everything you need to get started.

---

## Care Pastor Quick Start

### Setting Up Your Organization

1. **Create your organization** — When you first log in to the Partner Portal (the web dashboard), you'll be asked to register your church or ministry. Enter your organization name and select your type (Church, Ministry, Nonprofit, or Community Group).

2. **Set your location zone** — This is a general area label (e.g., "North Austin" or "Downtown Portland"). We never collect precise GPS coordinates. The zone helps match needs with nearby helpers.

3. **Your role** — As the person who set up the org, you'll have the **Org Admin** role. This means you can see the need queue, assign helpers, view reports, and manage your team.

### Inviting Helpers

1. From the Partner Portal dashboard, navigate to **Helpers** in the sidebar.
2. Tap **Invite Helper** and enter their email address.
3. They'll receive an invitation to create an account with the **Helper** role, already linked to your organization.
4. You can invite as many helpers as you'd like. We recommend starting with 3–5 trusted volunteers for the pilot.

### Processing Your First Need

Here's what happens when someone in your congregation submits a need:

1. **A need appears in your queue.** Open the Partner Portal and navigate to the **Queue** screen. New needs appear at the top.

2. **Review the need.** Tap the need to see its details: category (Food, Transport, Household, Medical, Family, Prayer, Emergency, or Other), urgency level, location zone, and an optional description. If the requester chose to remain anonymous, you will not see their name.

3. **Assign a helper.** Select one of your registered helpers from the dropdown and tap **Approve & Match**. The need's status changes to **Matched**, and the helper is notified.

4. **The helper claims and fulfills.** Your helper sees the matched need in their app, claims it, and coordinates fulfillment. When they're done, they tap **Mark Fulfilled**.

5. **The requester confirms.** The person who asked for help sees a gentle confirmation screen — "Your need has been honored." The loop is closed.

That's the entire flow. Submit → Review → Match → Fulfill → Close.

### Understanding the Dashboard

Your Partner Portal dashboard shows:

- **Queue** — All needs from your organization, filterable by status
- **Reports** — Summary statistics: how many needs were submitted, fulfilled, and the average time to fulfillment
- **Helpers** — Your team roster and their fulfillment counts (visible only to you, never published as a leaderboard)
- **Settings** — Organization details, CSV export, and sponsor tag management

---

## Requester Dignity Guide

The people using this app to ask for help are already in a vulnerable moment. How we talk about the app matters as much as what the app does.

### Language to Use

- **"Submit your need"** — not "submit a request" or "ask for help"
- **"Your need will be honored"** — this is the confirmation they see when their need is fulfilled
- **"You can keep your identity private"** — they have full control over anonymity
- **"Someone from your community will help"** — it's local, it's personal, it's their neighbors

### Language to Avoid

Please avoid these words when talking about the app to your congregation:

- **"Charity"** — This implies a power imbalance. We're building mutual aid, not charity.
- **"Handout"** — No one is receiving a handout. They're receiving care.
- **"Poor"** — Financial status is not an identity. Someone has a need right now — that's all.
- **"Beg" or "begging"** — Never. Submitting a need is an act of courage, not desperation.
- **"Recipient" or "beneficiary"** — Use "requester" or simply "the person who asked."

### Privacy Assurances You Can Share

When someone asks, "Is this safe?", here's what you can tell them:

- "Only the Care Pastor and your assigned helper can see your need. No one else."
- "If you choose to be anonymous, even your helper won't know your name."
- "We never collect your precise location — only a general zone like 'North Side.'"
- "We never sell data. We never run ads. We never will."
- "Your description is encrypted in transit and never sent to error-tracking tools."

---

## Helper Training Guide

### Seeing Available Needs

When a Care Pastor assigns you to a need, it appears in your **Available Needs** list in the mobile app. You'll see:

- **Category** — What kind of help is needed (Food, Transport, Household, etc.)
- **Urgency** — Low, Medium, High, or Critical
- **Location Zone** — A general area (never a precise address)
- **Description** — If the requester chose to share one

### Claiming a Need

1. Tap the need to view its details.
2. Tap **Claim This Need** to let the team know you're on it.
3. Your status changes to **In Progress**.

**Claim limits:** You may hold up to **3 active needs** at a time. This keeps the system fair and prevents any one helper from being overwhelmed. Once you fulfill a need, the slot opens up.

### Marking Fulfillment

When you've provided the help:

1. Open the need in your app.
2. Tap **Mark Fulfilled**.
3. Optionally, add a brief note about what was provided (e.g., "Delivered groceries on Tuesday").

The requester will see a confirmation, and the need is closed.

### What You Can and Cannot See

- **If the need is anonymous:** You will see the category, urgency, zone, and description — but **not** the requester's name, email, or any identifying information. This is by design. Please respect it.
- **If the need is not anonymous:** You may see the requester's first name to help coordinate. Treat this information as confidential.
- **You will never see:** Other helpers' activities, fulfillment leaderboards, or aggregate statistics. Your work is between you and the person you're helping.

---

## Privacy Commitments

We take privacy seriously — not as a legal checkbox, but as a moral commitment to the people who trust this platform with their most vulnerable moments.

### Data We Collect and Why

| Data | Why We Collect It |
|------|-------------------|
| Email address | Account creation and login only |
| Role (Requester, Helper, Org Admin, etc.) | To control what you can see and do |
| Organization affiliation | To route needs to the right community |
| Location zone (general area) | To match needs with nearby helpers |
| Need category and urgency | To prioritize and route care |
| Description (optional) | To help helpers understand the need |
| Fulfillment timestamps | To measure how quickly we're helping |

### Data We Never Collect

- **Precise GPS coordinates** — We use general zones, never your exact location
- **Social media profiles** — We don't ask for or link to any social accounts
- **Financial details** — We never ask for income, bank accounts, or credit scores
- **Browsing history** — We don't track what you do outside the app
- **Device contacts** — We never access your phone's contact list

### Who Can See What

| Role | What They Can See |
|------|-------------------|
| **Requester** | Only their own needs and status updates |
| **Helper** | Only needs they've been assigned to (no browse-all feed) |
| **Org Admin / Care Pastor** | Their organization's need queue, helpers, and reports |
| **Moderator** | Flagged needs and escalations across the platform |
| **Sponsor Admin** | Aggregate statistics only — never individual identities |

### Data Retention

For the pilot period, data retention policies will be defined together with our pilot partner. We are committed to:

- Never retaining data longer than necessary
- Providing data deletion on request
- Being transparent about any changes to retention policy

### Error Monitoring (Sentry)

We use Sentry to track technical errors so we can fix bugs quickly. Our Sentry configuration:

- **Never logs** requester descriptions, location zones, names, or emails
- **Never sends** personally identifiable information
- **Only captures** technical error details (stack traces, HTTP status codes)
- PII is stripped automatically before any data leaves your device or our server

---

## Support Contact

We're here to help you help others.

- **Email:** support@logosgs.com
- **Response time:** Within 24 hours during the pilot period

If something feels wrong — a bug, a concern about privacy, or just confusion about how something works — please reach out. There are no silly questions. The fact that you're doing this work matters, and we want to make sure the tool serves you well.

---

*Thank you for caring for your community. We're honored to build this alongside you.*

**Copyright (c) 2024 LOGOS Governance Systems, Inc. All rights reserved.**
