 1 backend/
    2 ├── src/
    3 │   ├── controllers/    # Handles Request/Response
    4 │   ├── routes/         # API Route definitions
    5 │   ├── services/       # Business Logic (The "Brain")
    6 │   ├── models/         # Interfaces & Database Schemas
    7 │   ├── middleware/     # Auth, Error Handling
    8 │   ├── app.ts          # Express App configuration
    9 │   └── server.ts       # Server entry point (starts the app)
   10 ├── .env                # Environment variables
   11 ├── tsconfig.json       # TypeScript configuration
   12 └── package.json        # Scripts & dependencies
