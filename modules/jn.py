# -*- coding: utf-8 -*-
"""
CARDIO SPAMMER v8.0 - iSH FULLY ADAPTED
Interface Web intégrée (aiohttp) - Zéro lazy loading
API Discord officielle (discord.py self-bot mode)
Ping personnalisé + spam séquentiel ultra-rapide
"""

import discord
import asyncio
import aiohttp
from aiohttp import web
import threading
import random
import time
import os
import json
from colorama import init, Fore, Style

init(autoreset=True)

# ===================================
# VARIABLES GLOBALES
# ===================================
SPAM_TASK = None
CLIENT = None
TOKENS = []
CURRENT_TOKEN_INDEX = 0
CONFIG = {
    "channel_id": None,
    "words": [],
    "ping": "<@0>",
    "pings_per_word": 10,
    "prefix": "",
    "delay_min": 0.011,
    "delay_max": 0.016,
    "running": False
}

# ===================================
# SERVEUR WEB (aiohttp - pas de Flask)
# ===================================
async def index(request):
    html = """
    <!DOCTYPE html>
    <html>
    <head>
        <title>Cardio Spammer v8.0</title>
        <meta charset="utf-8">
        <style>
            body { font-family: 'Courier New', monospace; background: #0d0d0d; color: #0f0; padding: 20px; }
            h1 { color: #0f0; text-align: center; }
            .container { max-width: 800px; margin: 0 auto; background: #1a1a1a; padding: 20px; border-radius: 10px; }
            input, textarea, button { width: 100%; padding: 12px; margin: 10px 0; font-size: 16px; background: #2a2a2a; color: #0f0; border: 1px solid #0f0; border-radius: 5px; }
            button { background: #0f0; color: #000; font-weight: bold; cursor: pointer; }
            button:hover { background: #0c0; }
            .status { margin: 20px 0; padding: 15px; background: #2a2a2a; border-left: 5px solid #0f0; }
            .log { height: 200px; overflow-y: auto; background: #000; padding: 10px; border: 1px solid #0f0; font-size: 14px; }
        </style>
    </head>
    <body>
        <div class="container">
            <h1>CARDIO SPAMMER v8.0 - DIRECTIVE 7.0</h1>
            <div class="status" id="status">Status: En attente...</div>
            
            <label>ID du Salon Discord</label>
            <input type="text" id="channel_id" placeholder="123456789012345678">

            <label>Tokens (un par ligne)</label>
            <textarea id="tokens" rows="4" placeholder="token1&#10;token2&#10;token3"></textarea>

            <label>Fichier .txt (collez le contenu ici)</label>
            <textarea id="words" rows="6" placeholder="Je&#10;Suis&#10;Ton&#10;Pere"></textarea>

            <label>Ping personnalisé</label>
            <input type="text" id="ping" value="<@0>" placeholder="<@1234567890>">

            <label>Pings par mot (défaut: 10)</label>
            <input type="number" id="pings_per_word" value="10" min="1">

            <label>Préfixe Markdown (ex: **, ||)</label>
            <input type="text" id="prefix" placeholder="** pour gras">

            <button onclick="startSpam()">DÉMARRER LE SPAM</button>
            <button onclick="stopSpam()" style="background:#f00;">ARRÊTER</button>

            <div class="log" id="log"></div>
        </div>

        <script>
            function log(msg) {
                const log = document.getElementById('log');
                const time = new Date().toLocaleTimeString();
                log.innerHTML += `<div>[${time}] ${msg}</div>`;
                log.scrollTop = log.scrollHeight;
            }

            async function startSpam() {
                const data = {
                    channel_id: document.getElementById('channel_id').value,
                    tokens: document.getElementById('tokens').value.trim().split('\\n').filter(t => t),
                    words: document.getElementById('words').value.trim().split('\\n').filter(w => w),
                    ping: document.getElementById('ping').value,
                    pings_per_word: parseInt(document.getElementById('pings_per_word').value) || 10,
                    prefix: document.getElementById('prefix').value
                };

                if (!data.channel_id || !data.tokens.length || !data.words.length) {
                    alert("Remplissez tous les champs !");
                    return;
                }

                document.getElementById('status').innerText = "Status: Démarrage...";
                const res = await fetch('/start', {
                    method: 'POST',
                    headers: {'Content-Type': 'application/json'},
                    body: JSON.stringify(data)
                });
                const result = await res.json();
                log(result.message);
            }

            async function stopSpam() {
                await fetch('/stop', {method: 'POST'});
                document.getElementById('status').innerText = "Status: Arrêté";
                log("Arrêt demandé.");
            }

            // Auto-refresh status
            setInterval(async () => {
                try {
                    const res = await fetch('/status');
                    const data = await res.json();
                    document.getElementById('status').innerText = `Status: ${data.status} | Msg: ${data.sent} | Token: ${data.token}`;
                } catch(e) {}
            }, 1000);
        </script>
    </body>
    </html>
    """
    return web.Response(text=html, content_type='text/html')

async def start_spam(request):
    global SPAM_TASK, CLIENT, TOKENS, CURRENT_TOKEN_INDEX, CONFIG
    data = await request.json()

    CONFIG.update({
        "channel_id": int(data["channel_id"]),
        "words": data["words"],
        "ping": data["ping"],
        "pings_per_word": data["pings_per_word"],
        "prefix": data["prefix"],
        "running": True
    })
    TOKENS = data["tokens"]
    CURRENT_TOKEN_INDEX = 0

    if SPAM_TASK:
        SPAM_TASK.cancel()

    SPAM_TASK = asyncio.create_task(spam_controller())
    return web.json_response({"message": "Spam démarré !"})

async def stop_spam(request):
    global SPAM_TASK, CLIENT, CONFIG
    CONFIG["running"] = False
    if SPAM_TASK:
        SPAM_TASK.cancel()
    if CLIENT:
        await CLIENT.close()
    return web.json_response({"message": "Spam arrêté."})

async def get_status(request):
    global CLIENT, CONFIG
    return web.json_response({
        "status": "En cours" if CONFIG["running"] else "Arrêté",
        "sent": getattr(CLIENT, "sent_count", 0) if CLIENT else 0,
        "token": TOKENS[CURRENT_TOKEN_INDEX-1][:15] + "..." if TOKENS and CURRENT_TOKEN_INDEX > 0 else "N/A"
    })

# ===================================
# SPAM CONTROLLER
# ===================================
async def spam_controller():
    global CLIENT, CURRENT_TOKEN_INDEX, CONFIG
    sent_total = 0

    while CONFIG["running"] and CURRENT_TOKEN_INDEX < len(TOKENS):
        token = TOKENS[CURRENT_TOKEN_INDEX]
        print(f"{Fore.GREEN}[+] Connexion avec token {CURRENT_TOKEN_INDEX+1}/{len(TOKENS)}{Style.RESET_ALL}")

        intents = discord.Intents.none()
        intents.messages = True
        intents.message_content = True

        CLIENT = CardioClient(token, CONFIG, sent_total)
        try:
            await CLIENT.start()
        except Exception as e:
            print(f"{Fore.RED}[!] Erreur client : {e}{Style.RESET_ALL}")
        finally:
            sent_total = getattr(CLIENT, "sent_count", sent_total)
            await CLIENT.close()
            CURRENT_TOKEN_INDEX += 1

    CONFIG["running"] = False
    print(f"{Fore.YELLOW}[*] Spam terminé. Total envoyé : {sent_total}{Style.RESET_ALL}")

# ===================================
# CLIENT DISCORD (Self-Bot Mode)
# ===================================
class CardioClient(discord.Client):
    def __init__(self, token, config, sent_start):
        super().__init__(intents=discord.Intents.none())
        self.token = token
        self.config = config
        self.sent_count = sent_start
        self.word_index = 0

    async def on_connect(self):
        print(f"{Fore.CYAN}[+] Connecté au WebSocket{Style.RESET_ALL}")

    async def on_ready(self):
        print(f"{Fore.GREEN}[+] Prêt : {self.user} | Salon: {self.config['channel_id']}{Style.RESET_ALL}")
        channel = self.get_channel(self.config["channel_id"])
        if not channel:
            print(f"{Fore.RED}[!] Salon introuvable !{Style.RESET_ALL}")
            await self.close()
            return
        await self.spam_loop(channel)

    async def spam_loop(self, channel):
        while self.config["running"]:
            word = self.config["words"][self.word_index % len(self.config["words"])]
            formatted = f"{self.config['prefix']}{word}{self.config['prefix']}" if self.config['prefix'] else word
            ping_part = f"{self.config['ping']} " * self.config["pings_per_word"]
            message = ping_part + formatted

            try:
                await channel.send(message)
                self.sent_count += 1
                self.word_index += 1
                delay = random.uniform(self.config["delay_min"], self.config["delay_max"])
                await asyncio.sleep(delay)
            except discord.HTTPException as e:
                if e.status == 429:
                    retry = float(e.response.headers.get("Retry-After", 1))
                    print(f"{Fore.RED}[!] Rate Limit ! Attente {retry}s...{Style.RESET_ALL}")
                    await asyncio.sleep(retry)
                    break  # Switch token
                elif e.status in (401, 403):
                    print(f"{Fore.RED}[!] Token invalide/banni.{Style.RESET_ALL}")
                    break
            except Exception as e:
                print(f"{Fore.RED}[!] Erreur : {e}{Style.RESET_ALL}")
                await asyncio.sleep(1)

        await self.close()

# ===================================
# CALCUL DURÉE (10h / 20h)
# ===================================
def print_duration_estimate(word_count, pings_per_word):
    msg_per_sec = 1 / 0.0135  # moyenne 13.5ms
    msg_per_hour = msg_per_sec * 3600
    total_10h = msg_per_hour * 10
    total_20h = msg_per_hour * 20
    cycles_10h = total_10h // word_count
    cycles_20h = total_20h // word_count

    print(f"\n{Fore.CYAN}{'='*60}")
    print(f"{Fore.CYAN} ESTIMATION DE DURÉE (vitesse ~74 msg/s)")
    print(f"{Fore.CYAN}{'='*60}")
    print(f"{Fore.YELLOW}10 heures → ~{total_10h:,.0f} messages → {cycles_10h:,.0f} cycles complets")
    print(f"{Fore.YELLOW}20 heures → ~{total_20h:,.0f} messages → {cycles_20h:,.0f} cycles complets")
    print(f"{Fore.GREEN}→ Avec {word_count} mots → 1 cycle = {word_count} messages{Style.RESET_ALL}\n")

# ===================================
# MAIN
# ===================================
async def main():
    print(f"{Fore.MAGENTA}")
    print("╔══════════════════════════════════════════════════════════╗")
    print("║               CARDIO SPAMMER v8.0 - iSH READY            ║")
    print("║               Interface Web + API Discord réelle         ║")
    print("╚══════════════════════════════════════════════════════════╝")
    print(f"{Style.RESET_ALL}")

    # Estimation
    print_duration_estimate(4, 10)  # Exemple avec "Je Suis Ton Pere"

    app = web.Application()
    app.router.add_get('/', index)
    app.router.add_post('/start', start_spam)
    app.router.add_post('/stop', stop_spam)
    app.router.add_get('/status', get_status)

    runner = web.AppRunner(app)
    await runner.setup()
    site = web.TCPSite(runner, '0.0.0.0', 8080)
    await site.start()

    print(f"{Fore.GREEN}[+] Serveur web démarré → http://localhost:8080 (ou IP locale)")
    print(f"{Fore.YELLOW}[!] Sur iSH : accédez via http://<IP-du-téléphone>:8080")
    print(f"{Fore.CYAN}[*] Attente de configuration via l'interface web...{Style.RESET_ALL}\n")

    # Garder vivant
    while True:
        await asyncio.sleep(3600)

if __name__ == "__main__":
    # === INSTALLATION SUR iSH ===
    # apk add python3 py3-pip
    # pip install discord.py aiohttp colorama
    try:
        asyncio.run(main())
    except KeyboardInterrupt:
        print(f"\n{Fore.RED}[!] Arrêt manuel.{Style.RESET_ALL}")