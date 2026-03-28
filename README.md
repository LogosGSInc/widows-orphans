# Widows & Orphans

A community care platform connecting those in need with those who can help. Anonymous, ephemeral, and privacy-first.

## Tech Stack

- **Frontend**: React 18 + TypeScript + Vite + TailwindCSS
- **Backend**: PocketBase (self-hosted)
- **Maps**: Leaflet.js + OpenStreetMap
- **Deployment**: Vercel (static SPA)
- **PWA**: Installable with offline support

## Features

- Anonymous alias system (no login, no email, no phone)
- Post needs within your community (auto-expire after 24 hours)
- Fulfill needs through ephemeral chat (auto-expire after 1 hour)
- Interactive map showing nearby needs within 10-mile radius
- Category-based need classification (Food, Shelter, Transportation, Clothing, Medical, Other)
- Stripe donate button (external link)

## Local Development

### Prerequisites

- Node.js 18+
- [PocketBase](https://pocketbase.io/docs/) binary

### Setup

1. Clone the repository:
   ```bash
   git clone https://github.com/LogosGSInc/widows-orphans.git
   cd widows-orphans
   ```

2. Install dependencies:
   ```bash
   npm install
   ```

3. Copy environment file:
   ```bash
   cp .env.example .env
   ```

4. Start PocketBase:
   ```bash
   ./pocketbase serve
   ```
   Then import the schema from `pocketbase/pb_schema.json` via the PocketBase admin UI (Settings > Import collections).

5. Start the dev server:
   ```bash
   npm run dev
   ```

6. Open http://localhost:5173 in your browser.

## PocketBase Setup

PocketBase runs as a separate binary on the server. It is not included in this repository.

1. Download PocketBase from https://pocketbase.io/docs/
2. Start it: `./pocketbase serve`
3. Open the admin UI at http://localhost:8090/_/
4. Import the collection schema from `pocketbase/pb_schema.json`
5. Optionally set up a cron job to clean up expired records

### Collections

| Collection | Purpose |
|-----------|---------|
| `aliases` | Anonymous user identities |
| `needs` | Posted community needs (24h TTL) |
| `chats` | Ephemeral chat sessions (1h TTL) |
| `messages` | Chat messages (expire with chat) |

## Vercel Deployment

1. Connect the repository to Vercel
2. Set environment variables:
   - `VITE_PB_URL` — URL of your PocketBase instance
   - `VITE_STRIPE_DONATE_URL` — Stripe Payment Link URL
3. Deploy — the `vercel.json` handles SPA routing automatically

## Environment Variables

| Variable | Description | Default |
|----------|-------------|---------|
| `VITE_PB_URL` | PocketBase server URL | `http://localhost:8090` |
| `VITE_STRIPE_DONATE_URL` | Stripe donate link | `https://donate.stripe.com/PLACEHOLDER` |

## Design

- **Navy**: `#0A1628` (primary)
- **White**: `#FFFFFF` (text, cards)
- **Chrome**: `#C0C7D4` (borders, secondary)
- Mobile-first, clean monochrome aesthetic
- System font stack

## License

Private — LOGOS Global Services Inc.
