require('dotenv').config();

const express = require('express');
const appleAuthRouter = require('./apple_auth');

const app = express();
app.use(express.json());
app.use(appleAuthRouter);

const PORT = process.env.PORT || 3000;
app.listen(PORT, () => console.log(`Server running on port ${PORT}`));
