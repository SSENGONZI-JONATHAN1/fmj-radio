import express, {} from 'express';
import cors from 'cors';
import morgan from 'morgan';
import dotenv from 'dotenv';
dotenv.config();
const app = express();
// Middleware
app.use(cors());
app.use(morgan('dev'));
app.use(express.json());
// Test Route
app.get('/v1/health', (req, res) => {
    res.json({ status: 'ok', message: 'TypeScript Radio Backend is Live!' });
});
export default app;
//# sourceMappingURL=app.js.map