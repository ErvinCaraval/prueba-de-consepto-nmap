const express = require('express');
const path = require('path');

const app = express();
const PORT = 80;

app.use(express.static(path.join(__dirname, 'public')));

// Eliminada inyección manual desde Node.js para prevenir bloqueos de supervisor
// API Route que simula comprobar caché
app.get('/api/status', (req, res) => {
    res.json({
        system: 'ONLINE',
        cache: 'REDIS (PORT: 6379)',
        session: 'MEMCACHED (PORT: 11211)'
    });
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`[+] WebApp running on port ${PORT}`);
});
