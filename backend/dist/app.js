import express, {} from 'express';
import cors from 'cors';
import morgan from 'morgan';
import { env } from './config/env.js';
import { errorHandler } from './middleware/errorHandler.js';
import { optionalAuth } from './middleware/optionalAuth.js';
import stationRoutes from './routes/StationRoutes.js';
import categoryRoutes from './routes/CategoryRoutes.js';
import searchRoutes from './routes/SearchRoutes.js';
import countryRoutes from './routes/CountryRoutes.js';
import languageRoutes from './routes/LanguageRoutes.js';
import analyticsRoutes from './routes/AnalyticsRoutes.js';
import lyricsRoutes from './routes/LyricsRoutes.js';
import authRoutes from './routes/AuthRoutes.js';
import favoriteRoutes from './routes/FavoriteRoutes.js';
import appConfigRoutes from './routes/AppConfigRoutes.js';
import announcementRoutes from './routes/AnnouncementRoutes.js';
const app = express();
// Middleware
app.use(cors());
app.use(morgan('dev'));
app.use(express.json());
app.use(optionalAuth); // Globally apply optional auth for isFavorite logic
// Routes
const apiRouter = express.Router();
apiRouter.use('/stations', stationRoutes);
apiRouter.use('/categories', categoryRoutes);
apiRouter.use('/search', searchRoutes);
apiRouter.use('/countries', countryRoutes);
apiRouter.use('/languages', languageRoutes);
apiRouter.use('/analytics', analyticsRoutes);
apiRouter.use('/lyrics', lyricsRoutes);
apiRouter.use('/auth', authRoutes);
apiRouter.use('/favorites', favoriteRoutes);
apiRouter.use('/app-config', appConfigRoutes);
apiRouter.use('/announcements', announcementRoutes);
app.use('/v1', apiRouter);
// Test Route
app.get('/health', (req, res) => {
    res.json({ success: true, message: 'TypeScript Radio Backend is Live!' });
});
// Error Handling
app.use(errorHandler);
export default app;
//# sourceMappingURL=app.js.map