const express = require('express');
const puppeteer = require('puppeteer');

const app = express();
const PORT = 3000;

// Middleware zum Parsen von JSON-Anfragen
app.use(express.json());

// Array zur Verfolgung der aktiven Benutzersitzungen
const activeSessions = {};

// Festlegen der festen URL
const WEBSITE_URL = "http://example.com";

// Route zum Starten einer neuen Sitzung
app.post('/start-session', async (req, res) => {
  try {
    // Erstelle eine neue Browserinstanz mit Puppeteer
    const browser = await puppeteer.launch();
    const page = await browser.newPage();

    // Öffne die festgelegte Website-URL
    await page.goto(WEBSITE_URL);

    // Generiere eine zufällige Sitzungs-ID
    const sessionId = Math.random().toString(36).substring(7);

    // Speichere die Sitzungsdaten für den Benutzer
    activeSessions[sessionId] = { browser, page };

    // Sende die Sitzungs-ID als Antwort zurück
    res.status(200).json({ sessionId });
  } catch (error) {
    console.error('Fehler beim Starten der Sitzung:', error);
    res.status(500).send('Interner Serverfehler');
  }
});

// Route zum Anzeigen der Website für eine bestimmte Sitzung
app.get('/view/:sessionId', async (req, res) => {
  const sessionId = req.params.sessionId;
  try {
    // Hole die Seite für die angegebene Sitzung und generiere einen Screenshot
    const screenshot = await activeSessions[sessionId].page.screenshot();

    // Sende den Screenshot als Antwort zurück
    res.set('Content-Type', 'image/png');
    res.status(200).send(screenshot);
  } catch (error) {
    console.error('Fehler beim Anzeigen der Website:', error);
    res.status(500).send('Interner Serverfehler');
  }
});

// Starte den Server
app.listen(PORT, () => {
  console.log(`Server läuft auf Port ${PORT}`);
});
