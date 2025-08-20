const express = require('express');
const app = express();
const port = process.env.PORT || 3000;
const host = '0.0.0.0';

// very fast liveness check ALB/ECS
app.get('/healthz', (req, res) => {
  res.status(200).send('OK');
});

app.get('/', (req, res) => res.send('Threat Modelling Tool is live!'));

app.listen(port, host, () => {
  console.log(`Listening on http://${host}:${port}`);
});
