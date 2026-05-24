#!/usr/bin/env bash
# run-dev.sh — Inicia o backend (Firebase Emulators) e o frontend (Flutter Web)
# Execute: bash run-dev.sh  (na raiz do projeto)

set -euo pipefail

C_SUCCESS="\033[0;32m"
C_WARNING="\033[1;33m"
C_ERROR="\033[0;31m"
C_INFO="\033[0;36m"
C_STEP="\033[1;37m"
C_GRAY="\033[0;37m"
C_RESET="\033[0m"

ok()   { echo -e "${C_SUCCESS}[OK] $*${C_RESET}"; }
warn() { echo -e "${C_WARNING}[AVISO] $*${C_RESET}"; }
err()  { echo -e "${C_ERROR}[ERRO] $*${C_RESET}"; }
step() { echo -e "${C_STEP}$*${C_RESET}"; }
gray() { echo -e "${C_GRAY}       $*${C_RESET}"; }

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$SCRIPT_DIR"
BACKEND_DIR="$BASE_DIR/backend"
FRONTEND_DIR="$BASE_DIR/frontend/app"
PROJECT_ID="mesclainvest-eda16"
FLUTTER_WEB_PORT=3000

# Garantir Flutter no PATH
if ! command -v flutter &>/dev/null; then
    for candidate in "$HOME/flutter/bin" "/home/alekkzsx/flutter/bin" "/opt/flutter/bin" "/snap/bin"; do
        if [ -x "$candidate/flutter" ]; then
            export PATH="$candidate:$PATH"
            break
        fi
    done
fi

if ! command -v flutter &>/dev/null; then
    err "Flutter nao encontrado. Adicione ao PATH: export PATH=\"\$HOME/flutter/bin:\$PATH\""
    exit 1
fi

echo ""
echo -e "${C_INFO}========================================${C_RESET}"
echo -e "${C_INFO}   MesclaInvest — Iniciando Dev         ${C_RESET}"
echo -e "${C_INFO}========================================${C_RESET}"
echo ""

# ─── Liberar portas ─────────────────────────────────────────────────────────
step "[0] Liberando portas..."
for port in $FLUTTER_WEB_PORT 4000 5001 8080 9099 9199; do
    pids=$(lsof -ti tcp:"$port" 2>/dev/null || true)
    if [ -n "$pids" ]; then
        echo "$pids" | xargs -r kill -9 2>/dev/null || true
        gray "Porta $port liberada"
    fi
done
ok "Portas liberadas"

# ─── Backend ─────────────────────────────────────────────────────────────────
step "[1] Iniciando Firebase Emulators..."

FIREBASE_CMD="npx --yes firebase-tools@15.17.0"
if command -v firebase &>/dev/null; then FIREBASE_CMD="firebase"; fi

BACKEND_LOG="$BASE_DIR/backend-emulator.log"
EMULATOR_CMD="cd '$BACKEND_DIR' && $FIREBASE_CMD emulators:start --project $PROJECT_ID --only auth,functions,firestore,storage"

# Detectar terminal grafico disponivel
if command -v gnome-terminal &>/dev/null; then
    gnome-terminal --title="MesclaInvest Backend" -- bash -c "$EMULATOR_CMD; exec bash" &
elif command -v xterm &>/dev/null; then
    xterm -title "MesclaInvest Backend" -e bash -c "$EMULATOR_CMD; exec bash" &
elif command -v konsole &>/dev/null; then
    konsole --title "MesclaInvest Backend" -e bash -c "$EMULATOR_CMD; exec bash" &
elif command -v xfce4-terminal &>/dev/null; then
    xfce4-terminal --title="MesclaInvest Backend" -e "bash -c \"$EMULATOR_CMD; exec bash\"" &
else
    gray "Nenhum terminal grafico encontrado. Rodando backend em background..."
    gray "Log: $BACKEND_LOG"
    bash -c "$EMULATOR_CMD" > "$BACKEND_LOG" 2>&1 &
fi

# Aguardar emuladores
gray "Aguardando emuladores (8080, 5001, 9099, 9199)..."
ELAPSED=0
TIMEOUT=120
READY=false
while [ "$ELAPSED" -lt "$TIMEOUT" ]; do
    ALL_UP=true
    for port in 8080 5001 9099 9199; do
        if ! (echo >/dev/tcp/localhost/$port) 2>/dev/null; then
            ALL_UP=false; break
        fi
    done
    if $ALL_UP; then READY=true; break; fi
    printf "."
    sleep 3
    ELAPSED=$((ELAPSED + 3))
done
echo ""

if $READY; then
    ok "Emuladores prontos!"
else
    warn "Timeout aguardando emuladores. Verifique a janela do backend."
fi

# ─── Frontend ────────────────────────────────────────────────────────────────
step "[2] Iniciando Flutter Web (porta $FLUTTER_WEB_PORT)..."
gray "Target: web-server --release"
gray "A compilacao leva ~30-60s na primeira vez..."

FLUTTER_LOG="$BASE_DIR/flutter-app.log"
FLUTTER_CMD_LINE="cd '$FRONTEND_DIR' && flutter run -d web-server --web-port $FLUTTER_WEB_PORT --release"

if command -v gnome-terminal &>/dev/null; then
    gnome-terminal --title="MesclaInvest Flutter Web" -- bash -c "export PATH=\"$HOME/flutter/bin:\$PATH\"; $FLUTTER_CMD_LINE; exec bash" &
elif command -v xterm &>/dev/null; then
    xterm -title "MesclaInvest Flutter Web" -e bash -c "export PATH=\"$HOME/flutter/bin:\$PATH\"; $FLUTTER_CMD_LINE; exec bash" &
elif command -v konsole &>/dev/null; then
    konsole --title "MesclaInvest Flutter Web" -e bash -c "export PATH=\"$HOME/flutter/bin:\$PATH\"; $FLUTTER_CMD_LINE; exec bash" &
elif command -v xfce4-terminal &>/dev/null; then
    xfce4-terminal --title="MesclaInvest Flutter Web" -e "bash -c \"export PATH='$HOME/flutter/bin:\$PATH'; $FLUTTER_CMD_LINE; exec bash\"" &
else
    gray "Iniciando Flutter em background. Log: $FLUTTER_LOG"
    bash -c "export PATH=\"$HOME/flutter/bin:\$PATH\"; $FLUTTER_CMD_LINE" > "$FLUTTER_LOG" 2>&1 &
fi

# Aguardar Flutter subir
gray "Aguardando Flutter compilar..."
ELAPSED=0
while [ "$ELAPSED" -lt 120 ]; do
    if (echo >/dev/tcp/localhost/$FLUTTER_WEB_PORT) 2>/dev/null; then
        break
    fi
    printf "."
    sleep 2
    ELAPSED=$((ELAPSED + 2))
done
echo ""

# Abrir no navegador
ok "Flutter Web pronto!"
step "[3] Abrindo no navegador..."
xdg-open "http://localhost:$FLUTTER_WEB_PORT" 2>/dev/null || true
sleep 1
xdg-open "http://localhost:4000" 2>/dev/null || true

echo ""
echo -e "${C_INFO}========================================${C_RESET}"
echo -e "${C_INFO}   MesclaInvest rodando!                ${C_RESET}"
echo -e "${C_INFO}========================================${C_RESET}"
echo ""
echo -e "${C_STEP}Servicos:${C_RESET}"
echo -e "${C_GRAY}  Flutter App:    http://localhost:$FLUTTER_WEB_PORT${C_RESET}"
echo -e "${C_GRAY}  Firebase UI:    http://localhost:4000${C_RESET}"
echo -e "${C_GRAY}  Firestore:      http://localhost:8080${C_RESET}"
echo -e "${C_GRAY}  Auth:           http://localhost:9099${C_RESET}"
echo -e "${C_GRAY}  Functions:      http://localhost:5001${C_RESET}"
echo -e "${C_GRAY}  Storage:        http://localhost:9199${C_RESET}"
echo ""
echo -e "${C_STEP}Usuarios demo:${C_RESET}"
echo -e "${C_GRAY}  Emails: aluno001@mescla.test ... aluno150@mescla.test${C_RESET}"
echo -e "${C_GRAY}  Senha:  Mescla@2026${C_RESET}"
echo ""
echo -e "${C_SUCCESS}Boa sorte com o MesclaInvest!${C_RESET}"
