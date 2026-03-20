# FMJ Radio Backend 📻

A robust, type-safe TypeScript backend built with Express and Prisma 7, designed specifically to power the FMJ Radio Flutter mobile application.

## 🚀 Key Features

- **Standardized API Contract**: All responses follow the `{ success: true, data: ..., meta: ... }` format, perfectly matched with the Flutter `ApiService`.
- **Real-World Data**: Integrated with the Radio Browser API for access to 40,000+ live stations.
- **Prisma 7 Architecture**: Uses modern Driver Adapters (`@prisma/adapter-pg`) for optimized database connections.
- **Type-Safe Models**: Shared interfaces between Backend and Flutter models to ensure data integrity.
- **Dev-Friendly Auth**: Includes a built-in Authentication bypass for rapid mobile development.
- **Remote Configuration**: Manage app themes, logos, and announcements via the database without app updates.

## 🛠 Tech Stack

- **Runtime**: Node.js (ESM)
- **Language**: TypeScript
- **Framework**: Express.js
- **ORM**: Prisma 7 (PostgreSQL)
- **Validation**: Zod
- **Auth**: JWT + BcryptJS

## 🚦 Getting Started

### 1. Prerequisites
- Node.js (v18+)
- A PostgreSQL Database (Local or Cloud)

### 2. Environment Setup
Create a `.env` file in the `backend/` directory:
```env
PORT=3000
DATABASE_URL="postgres://user:password@localhost:5432/fmj_radio?sslmode=require"
JWT_SECRET="your_super_secret_key"
```

### 3. Installation & Database Sync
```bash
npm install
npx prisma generate
npx prisma migrate dev --name init
```

### 4. Seeding Real Stations
Populate your database with the top 30 global radio stations, default app config, and announcements:
```bash
npx prisma db seed
```

### 5. Start Development
```bash
npm run dev
```

## 📖 API Documentation (v1)

### Stations
- `GET /v1/stations` - Paginated list of all stations.
- `GET /v1/stations/featured` - Get curated featured stations.
- `GET /v1/stations/:id` - Detailed station info with streams.
- `GET /v1/stations/:id/similar` - Get stations in the same category.

### Discovery
- `GET /v1/categories` - List all station categories with counts.
- `GET /v1/countries` - List available countries.
- `GET /v1/languages` - List available languages.
- `GET /v1/search?q=query` - Search stations by name, tag, or description.

### User & Interaction
- `POST /v1/auth/register` - Create a new account.
- `POST /v1/auth/login` - Get a JWT token.
- `GET /v1/favorites` - Get user's saved stations (Requires Token).
- `POST /v1/favorites/:stationId` - Toggle favorite status.

### System
- `GET /v1/app-config` - Fetch branding, colors, and social links.
- `GET /v1/announcements` - Fetch active banner messages.
- `GET /health` - Server status check.

## 🛠 Development Notes

### Auth Bypass
To unblock Flutter development, the `authMiddleware` is currently configured to use a `dev-user-id` if no Bearer token is provided. This allows you to test Favorites without being logged in. To enable strict security, remove the bypass in `src/middleware/authMiddleware.ts`.

### Adding Real Stations
The seed script (`prisma/seed.ts`) uses the `radio-browser.info` API. You can modify this script to fetch stations from specific countries or genres by changing the API query parameters.

### Response Format
Every response is wrapped in a `successResponse` or `errorResponse` utility.
```json
{
  "success": true,
  "data": [],
  "meta": {
    "total": 100,
    "page": 1,
    "limit": 20
  }
}
```
