const express = require('express');
const path = require('path');

const app = express();
const PORT = 80;

app.use(express.static(path.join(__dirname, 'public')));

// Servidor configurado con cabeceras ruidosas e informativas
// Nmap las detectará en la fase de reconocimiento
app.use((req, res, next) => {
    res.setHeader('X-Powered-By', 'Express/4.18.2 (Ubuntu v20.04)');
    res.setHeader('Server', 'NeonCorp Secure Server v1.0.3-beta');
    res.setHeader('Last-Modified', new Date().toUTCString());
    res.setHeader('X-Developer-Comment', 'TODO: remove anon FTP login on port 21 before release.');
    next();
});

// Endpoint oculto pero predecible (Vulnerabilidad de directorio expuesto)
app.get('/admin', (req, res) => {
    res.send(`
        <html>
            <head><title>NeonCorp Admin</title></head>
            <body style="background:#0a0a0a; color:#0f0; font-family:monospace; padding:2rem;">
                <h1>⚠️ ACCESO RESTRINGIDO ⚠️</h1>
                <p>Las credenciales de acceso se encuentran temporalmente subidas en el servidor FTP público.</p>
                <p>Servicio Telnet (Puerto 23) habilitado temporalmente para mantenimiento.</p>
            </body>
        </html>
    `);
});

app.listen(PORT, '0.0.0.0', () => {
    console.log(`[+] Vulnerable Web App running on port ${PORT}`);
});
