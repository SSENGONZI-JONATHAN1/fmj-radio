import express, { type Application, type Request, type Response} from 'express';
import cors from 'cors';
import morgan from 'morgan';
import dotenv from 'dotenv';
import stationRoutes from './routes/StationRoutes.js';

dotenv.config();

const app : Application = express();

// Middleware
app.use(cors());
app.use(morgan('dev'));
app.use(express.json());

// Routes
app.use('/v1/stations', stationRoutes);

// Test Route
app.get('/v1/health', (req: Request, res: Response) => {
  res.json({ status: 'ok', message: 'TypeScript Radio Backend is Live!'});
})


export default app;
