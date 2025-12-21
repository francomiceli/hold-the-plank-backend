import { Router } from 'express';
import { verifyAuth } from '../controllers/authController';

const router = Router();

router.post('/verify', verifyAuth);

export default router;