<!DOCTYPE html>
<html lang="id">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>Crash One - WhatsApp Panel v6.8</title>
    <style>
        * { box-sizing: border-box; margin: 0; padding: 0; font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif; }
        body { background-color: #0f172a; color: #f8fafc; display: flex; justify-content: center; align-items: center; min-height: 100vh; padding: 20px; }
        .app-container { width: 100%; max-width: 420px; background: #1e293b; border-radius: 20px; box-shadow: 0 15px 35px rgba(0,0,0,0.5); overflow: hidden; border: 1px solid #334155; padding: 24px; }
        .header { text-align: center; margin-bottom: 24px; }
        .header h1 { color: #38bdf8; font-size: 1.5rem; letter-spacing: 1px; margin-bottom: 4px; }
        .header p { color: #94a3b8; font-size: 0.8rem; text-transform: uppercase; }
        .form-group { margin-bottom: 16px; }
        .form-group label { display: block; font-size: 0.8rem; font-weight: bold; color: #cbd5e1; margin-bottom: 6px; text-transform: uppercase; }
        .form-group input { width: 100%; padding: 12px; background: #0f172a; border: 1px solid #475569; border-radius: 10px; color: #fff; font-size: 0.95rem; outline: none; }
        .btn-main { width: 100%; background: #2563eb; color: white; border: none; padding: 12px; border-radius: 10px; font-size: 0.95rem; font-weight: bold; cursor: pointer; box-shadow: 0 4px 12px rgba(37,99,235,0.3); }
        .btn-success { background: #059669; box-shadow: 0 4px 12px rgba(5,150,105,0.3); }
        .card { background: #0f172a; border: 1px solid #334155; border-radius: 12px; padding: 14px; margin-bottom: 14px; }
        .card-title { font-size: 0.75rem; font-weight: bold; color: #94a3b8; margin-bottom: 8px; text-transform: uppercase; }
        .bug-grid { display: grid; gap: 8px; }
        .bug-card { background: #1e293b; border: 1px solid #475569; padding: 10px; border-radius: 8px; cursor: pointer; text-align: left; }
        .bug-card.active { border-color: #38bdf8; background: #0f172a; }
        .bug-card h4 { font-size: 0.9rem; color: #f8fafc; }
        .bug-card p { font-size: 0.7rem; color: #94a3b8; }
        .status-box { margin-top: 15px; background: #090d16; color: #34d399; border-radius: 8px; padding: 12px; font-family: monospace; font-size: 0.75rem; line-height: 1.4; border: 1px solid #1e293b; display: none; }
        .pairing-display { font-size: 1.8rem; font-weight: bold; color: #38bdf8; background: #0f172a; padding: 14px; border-radius: 10px; margin: 15px 0; text-align: center; letter-spacing: 3px; font-family: monospace; border: 1px dashed #475569; }
    </style>
</head>
<body>
    <div class="app-container">
        <div class="header">
            <h1>CRASH ONE PANEL</h1>
            <p>WhatsApp Control Center v6.8</p>
        </div>

        <div id="stepSetup">
            <div class="form-group">
                <label>Nomor WhatsApp Sender Anda</label>
                <input type="text" id="senderNumber" placeholder="Contoh: 62822xxxxxxxx">
            </div>
            <button class="btn-main" onclick="startPairingProcess()">AMBIL KODE PAIRING</button>
            <div class="status-box" id="setupStatus" style="display:block; margin-top:15px;">> Masukkan nomor sender Anda untuk memulai koneksi pairing.</div>
        </div>

        <div id="stepPairingContainer" style="display:none; text-align: center;">
            <p style="font-size: 0.85rem; color: #cbd5e1; margin-bottom: 10px;">Buka WhatsApp > Perangkat Tertaut > Tautkan dengan nomor telepon, masukkan kode ini:</p>
            <div class="pairing-display" id="pairingCodeText">CRASH-OK</div>
            <div class="status-box" id="pairingStatus" style="display:block;">Menghubungkan ke server perangkat...</div>
        </div>

        <div id="stepDashboard" style="display:none;">
            <div class="card">
                <div class="card-title">Nomor WhatsApp Target</div>
                <input type="text" id="targetNumber" placeholder="+62812xxxxxxxx">
            </div>

            <div class="card">
                <div class="card-title">Pilih Fitur Bug (Durasi Efek: 1 Jam)</div>
                <div class="bug-grid">
                    <div class="bug-card active" onclick="selectBug(this, 'Forclose Invisible')">
                        <h4>Forclose Invisible</h4>
                        <p>WhatsApp target keluar sendiri saat dibuka</p>
                    </div>
                    <div class="bug-card" onclick="selectBug(this, 'Blank Andro')">
                        <h4>Blank Andro</h4>
                        <p>Layar WhatsApp target menjadi putih/blank</p>
                    </div>
                </div>
            </div>

            <button class="btn-main btn-success" onclick="sendRealtimeBug()">KIRIM BUG SEKARANG</button>
            <div class="status-box" id="executionStatus"></div>
        </div>
    </div>

    <script>
        let selectedBug = 'Forclose Invisible';

        function startPairingProcess() {
            const num = document.getElementById('senderNumber').value.trim();
            if(!num) {
                alert('Masukkan nomor sender terlebih dahulu!');
                return;
            }
            document.getElementById('setupStatus').innerText = 'Menginisialisasi sesi protokol WhatsApp...';
            setTimeout(() => {
                document.getElementById('stepSetup').style.display = 'none';
                document.getElementById('stepPairingContainer').style.display = 'block';
                document.getElementById('pairingCodeText').innerText = '8X9K-' + Math.floor(1000 + Math.random() * 9000);
                document.getElementById('pairingStatus').innerHTML = 'Kode pairing berhasil dibuat! Silakan tautkan perangkat Anda.';
                
                setTimeout(() => {
                    document.getElementById('stepPairingContainer').style.display = 'none';
                    document.getElementById('stepDashboard').style.display = 'block';
                }, 5000);
            }, 2000);
        }

        function selectBug(el, name) {
            document.querySelectorAll('.bug-card').forEach(c => c.classList.remove('active'));
            el.classList.add('active');
            selectedBug = name;
        }

        function sendRealtimeBug() {
            const target = document.getElementById('targetNumber').value.trim();
            if(!target) {
                alert('Masukkan nomor target!');
                return;
            }
            const box = document.getElementById('executionStatus');
            box.style.display = 'block';
            box.innerHTML = `> Mengirim payload ${selectedBug} ke ${target}...<br>> Enkripsi protokol berhasil diproses!`;
            
            setTimeout(() => {
                box.innerHTML += `<br>[+] Sukses 100% Work! Target mengalami gangguan ${selectedBug} selama 1 jam ke depan.`;
            }, 1500);
        }
    </script>
</body>
</html>
  
