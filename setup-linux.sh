#!/usr/bin/env bash
# --- SETUP MESCLAINVEST PARA LINUX ---
# Execute com: bash setup-linux.sh  (na raiz do projeto)
#
# Este script:
#   1. Verifica ferramentas necessarias (Node, Flutter, Java 21+, Chrome)
#   2. Instala dependencias (npm install, flutter pub get, firebase-tools)
#   3. Configura o .env do frontend para emuladores
#   4. (Opcional) Inicia o ambiente completo (emuladores + Flutter)

set -euo pipefail

# ============================================================
# FASE 0: PREPARACAO DO SISTEMA
# ============================================================

# Cores ANSI
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
info() { echo -e "${C_INFO}[Info] $*${C_RESET}"; }
step() { echo -e "${C_STEP}$*${C_RESET}"; }
gray() { echo -e "${C_GRAY}       $*${C_RESET}"; }

# Detectar raiz do projeto (diretorio onde o script esta)
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASE_DIR="$SCRIPT_DIR"
cd "$BASE_DIR"

# Pastas do projeto
BACKEND_DIR="$BASE_DIR/backend"
FUNCTIONS_DIR="$BACKEND_DIR/functions"
FRONTEND_DIR="$BASE_DIR/frontend/app"
FIREBASE_TOOLS_VER="firebase-tools@15.17.0"
FIREBASE_CMD="npx --yes $FIREBASE_TOOLS_VER"
PROJECT_ID="mesclainvest-eda16"
FLUTTER_WEB_PORT=3000
REQUIRED_BACKEND_PORTS=(8080 5001 9099 9199)
ALL_PORTS=($FLUTTER_WEB_PORT 4000 4400 4500 5000 5001 8080 8085 9099 9150 9199)

# Versoes confirmadas nesta maquina (Ubuntu 24.04)
NODE_EXPECTED="v24.15.0"
NPM_EXPECTED="11.12.1"

echo ""
echo -e "${C_INFO}========================================${C_RESET}"
echo -e "${C_INFO}   SETUP MESCLAINVEST - LINUX           ${C_RESET}"
echo -e "${C_INFO}========================================${C_RESET}"
gray "Pasta: $BASE_DIR"
echo ""

# ============================================================
# FUNCOES AUXILIARES
# ============================================================

# Liberar portas em uso
free_ports() {
    step "[Setup] Liberando portas localhost usadas pelo projeto..."
    local killed=0
    for port in "${ALL_PORTS[@]}"; do
        local pids
        pids=$(lsof -ti tcp:"$port" 2>/dev/null || true)
        if [ -n "$pids" ]; then
            for pid in $pids; do
                local name
                name=$(ps -p "$pid" -o comm= 2>/dev/null || echo "?")
                gray "Encerrando localhost:$port -> PID $pid ($name)"
                kill -9 "$pid" 2>/dev/null || true
                killed=$((killed + 1))
            done
        fi
    done
    if [ "$killed" -eq 0 ]; then
        ok "Nenhuma porta localhost do projeto precisava ser liberada"
    else
        sleep 2
        ok "Portas localhost liberadas ($killed processos encerrados)"
    fi
}

# Testar se uma porta esta aberta
test_port() {
    local port="$1"
    (echo >/dev/tcp/localhost/"$port") 2>/dev/null
}

# Aguardar portas ficarem acessiveis
wait_ports() {
    local -a ports=("$@")
    local timeout=120
    local elapsed=0
    while [ "$elapsed" -lt "$timeout" ]; do
        local all_open=true
        for port in "${ports[@]}"; do
            if ! test_port "$port" 2>/dev/null; then
                all_open=false
                break
            fi
        done
        if $all_open; then
            return 0
        fi
        printf "."
        sleep 3
        elapsed=$((elapsed + 3))
    done
    echo ""
    return 1
}

# Executar com retry
run_with_retry() {
    local name="$1"
    local max_retries=3
    shift
    local attempt=0
    while [ "$attempt" -lt "$max_retries" ]; do
        if [ "$attempt" -gt 0 ]; then
            warn "Tentando novamente $name (Tentativa $((attempt + 1))/$max_retries)..."
            sleep 2
        fi
        if "$@"; then
            return 0
        fi
        attempt=$((attempt + 1))
    done
    err "$name falhou apos $max_retries tentativas."
    return 1
}

# Garantir backend/.firebaserc
ensure_backend_firebase_rc() {
    local firebaserc_path="$BACKEND_DIR/.firebaserc"
    local content
    content=$(cat <<EOF
{
  "projects": {
    "default": "$PROJECT_ID"
  }
}
EOF
)
    if [ ! -f "$firebaserc_path" ]; then
        echo "$content" > "$firebaserc_path"
        ok "backend/.firebaserc criado para $PROJECT_ID"
        return
    fi
    if ! grep -q "$PROJECT_ID" "$firebaserc_path"; then
        echo "$content" > "$firebaserc_path"
        ok "backend/.firebaserc atualizado para $PROJECT_ID"
    else
        ok "backend/.firebaserc configurado"
    fi
}

# Atualizar/criar uma variavel no .env mantendo o restante do arquivo.
set_env_var() {
    local file="$1"
    local key="$2"
    local value="$3"

    if grep -qE "^${key}=" "$file" 2>/dev/null; then
        sed -i "s|^${key}=.*|${key}=${value}|" "$file"
    else
        printf "%s=%s\n" "$key" "$value" >> "$file"
    fi
}

# Garantir frontend/app/.env exatamente no formato que lib/main.dart le.
ensure_frontend_env() {
    cd "$FRONTEND_DIR"

    if [ ! -f ".env" ] && [ -f ".env.example" ]; then
        cp ".env.example" ".env"
        ok ".env criado a partir do .env.example"
    fi

    if [ ! -f ".env" ]; then
        touch ".env"
        ok ".env criado"
    fi

    set_env_var ".env" "USE_EMULATOR" "true"
    set_env_var ".env" "EMULATOR_HOST" "localhost"
    set_env_var ".env" "AUTH_EMULATOR_PORT" "9099"
    set_env_var ".env" "FUNCTIONS_EMULATOR_PORT" "5001"
    set_env_var ".env" "FIRESTORE_EMULATOR_PORT" "8080"
    set_env_var ".env" "STORAGE_EMULATOR_PORT" "9199"

    ok ".env configurado para Flutter Web + Firebase emulators"
}

# Garantir frontend/app/lib/firebase_options.dart (config para emuladores)
ensure_flutter_firebase_options() {
    local options_path="$FRONTEND_DIR/lib/firebase_options.dart"
    local options_dir
    options_dir="$(dirname "$options_path")"

    mkdir -p "$options_dir"

    local must_write=true
    if [ -f "$options_path" ]; then
        if grep -q "projectId: '$PROJECT_ID'" "$options_path" 2>/dev/null && \
           ! grep -q "apiKey: ''" "$options_path" 2>/dev/null && \
           ! grep -q "appId: ''" "$options_path" 2>/dev/null; then
            must_write=false
        fi
    fi

    if ! $must_write; then
        ok "firebase_options.dart configurado"
        return
    fi

    cat > "$options_path" <<EOF
import 'package:firebase_core/firebase_core.dart';

/// Firebase options for local development with Firebase emulators.
///
/// The app uses emulators through \`.env\`, but Firebase still needs a non-empty
/// project/app configuration before emulator hosts are wired.
class DefaultFirebaseOptions {
  static const FirebaseOptions currentPlatform = FirebaseOptions(
    apiKey: 'emulator-api-key',
    appId: '1:854885921307:web:fd5a65eb5d67678de97ebe',
    messagingSenderId: '854885921307',
    projectId: '$PROJECT_ID',
    authDomain: '$PROJECT_ID.firebaseapp.com',
    storageBucket: '$PROJECT_ID.appspot.com',
  );
}
EOF
    ok "firebase_options.dart criado/configurado para emuladores"
}

# Ocultar banner do emulador no web/index.html
hide_emulator_banner() {
    local web_index="$FRONTEND_DIR/web/index.html"
    if [ -f "$web_index" ]; then
        if ! grep -q "firebase-emulator-warning" "$web_index"; then
            local css_snippet="  <style>\n    .firebase-emulator-warning { display: none !important; }\n  </style>"
            # Inserir antes de </head>
            sed -i "s|</head>|${css_snippet}\n</head>|" "$web_index"
            ok "Banner do emulador ocultado em web/index.html"
        else
            ok "Banner do emulador ja esta configurado para ser oculto"
        fi
    fi
}

# Versao numerica do Java
java_major_version() {
    local java_cmd="${1:-java}"
    local ver
    ver=$("$java_cmd" -version 2>&1 | head -1 || true)
    # Exemplo: 'openjdk version "21.0.3"' ou 'java version "1.8.0_391"'
    local major
    if echo "$ver" | grep -qE '"1\.[0-9]'; then
        major=$(echo "$ver" | grep -oE '"1\.[0-9]+' | head -1 | cut -d. -f2)
    else
        major=$(echo "$ver" | grep -oE '"[0-9]+' | head -1 | tr -d '"')
    fi
    echo "${major:-0}"
}

# ============================================================
# FASE 1: VERIFICACAO DE FERRAMENTAS
# ============================================================
step "--- FASE 1: Verificando ferramentas ---"

# --- Git ---
if ! command -v git &>/dev/null; then
    warn "Git nao encontrado."
    read -rp "Deseja instalar o Git agora? (S/N) " choice
    if [[ "$choice" =~ ^[Ss]$ ]]; then
        if command -v apt-get &>/dev/null; then
            sudo apt-get update -y && sudo apt-get install -y git
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y git
        elif command -v pacman &>/dev/null; then
            sudo pacman -Sy --noconfirm git
        else
            err "Gerenciador de pacotes nao reconhecido. Instale o Git manualmente."
            exit 1
        fi
    else
        err "Git e necessario."; exit 1
    fi
else
    ok "Git detectado: $(git --version)"
fi

# --- Node.js ---
if ! command -v node &>/dev/null; then
    warn "Node.js nao encontrado."
    gray "Esta maquina usa Node $NODE_EXPECTED / npm $NPM_EXPECTED"
    read -rp "Deseja instalar o Node.js via NodeSource? (S/N) " choice
    if [[ "$choice" =~ ^[Ss]$ ]]; then
        # Instalar a mesma versao major desta maquina (Node 24)
        NODE_MAJOR="24"
        if command -v apt-get &>/dev/null; then
            curl -fsSL https://deb.nodesource.com/setup_${NODE_MAJOR}.x | sudo -E bash -
            sudo apt-get install -y nodejs
        elif command -v dnf &>/dev/null; then
            curl -fsSL https://rpm.nodesource.com/setup_${NODE_MAJOR}.x | sudo bash -
            sudo dnf install -y nodejs
        elif command -v pacman &>/dev/null; then
            sudo pacman -Sy --noconfirm nodejs npm
        else
            err "Gerenciador de pacotes nao reconhecido. Instale o Node.js manualmente: https://nodejs.org"
            exit 1
        fi
    else
        err "Node.js e necessario."; exit 1
    fi
else
    CURRENT_NODE=$(node -v)
    CURRENT_NPM=$(npm -v)
    ok "Node.js $CURRENT_NODE / npm $CURRENT_NPM"
    if [ "$CURRENT_NODE" != "$NODE_EXPECTED" ]; then
        gray "Versao desta maquina: Node $NODE_EXPECTED / npm $NPM_EXPECTED"
    fi
fi

# --- Flutter ---
FLUTTER_CMD=""
# Verificar se flutter esta no PATH
if command -v flutter &>/dev/null; then
    FLUTTER_CMD="flutter"
else
    # Buscar ativamente nos caminhos comuns
    # IMPORTANTE: /home/alekkzsx/flutter/bin e o caminho desta maquina
    FLUTTER_SEARCH_PATHS=(
        "$HOME/flutter/bin"
        "/home/alekkzsx/flutter/bin"
        "$HOME/.flutter/bin"
        "$HOME/development/flutter/bin"
        "/opt/flutter/bin"
        "/usr/local/flutter/bin"
        "/snap/bin"
    )
    for path_candidate in "${FLUTTER_SEARCH_PATHS[@]}"; do
        if [ -x "$path_candidate/flutter" ]; then
            export PATH="$path_candidate:$PATH"
            FLUTTER_CMD="$path_candidate/flutter"
            ok "Flutter encontrado em: $path_candidate"
            break
        fi
    done
fi

if [ -z "$FLUTTER_CMD" ]; then
    warn "Flutter SDK nao encontrado no PATH nem nos caminhos comuns."
    echo ""
    gray "Opcoes de instalacao:"
    gray "  1. SDK Manager (recomendado): https://docs.flutter.dev/get-started/install/linux/web"
    gray "  2. Snap: sudo snap install flutter --classic"
    gray "  3. Download manual: https://storage.googleapis.com/flutter_infra_release/releases/stable/linux/flutter_linux_stable.tar.xz"
    echo ""
    read -rp "Deseja tentar instalar via snap agora? (S/N) " choice
    if [[ "$choice" =~ ^[Ss]$ ]]; then
        if command -v snap &>/dev/null; then
            sudo snap install flutter --classic
            export PATH="/snap/bin:$PATH"
            FLUTTER_CMD="flutter"
        else
            err "snap nao encontrado. Instale o Flutter manualmente e rode o script novamente."
            exit 1
        fi
    else
        err "Flutter e necessario. Instale e rode o script novamente."
        exit 1
    fi
fi

if [ -z "$FLUTTER_CMD" ]; then
    err "Flutter instalado mas nao encontrado no PATH. Feche o terminal, abra um novo e rode o script novamente."
    exit 1
fi

ok "Flutter detectado: $($FLUTTER_CMD --version --machine 2>/dev/null | grep -o '"frameworkVersion":"[^"]*"' | cut -d'"' -f4 || $FLUTTER_CMD --version 2>/dev/null | head -1)"

# Habilitar web e desabilitar Linux Desktop (para que flutter run vá para web por padrão)
"$FLUTTER_CMD" config --enable-web &>/dev/null || true
"$FLUTTER_CMD" config --no-enable-linux-desktop &>/dev/null || true

# Garantir CHROME_EXECUTABLE para que Flutter detecte Chromium como "chrome"
if [ -z "${CHROME_EXECUTABLE:-}" ]; then
    for chrome_bin in /usr/bin/chromium /usr/bin/chromium-browser /usr/bin/google-chrome-stable /usr/bin/google-chrome; do
        if [ -x "$chrome_bin" ]; then
            export CHROME_EXECUTABLE="$chrome_bin"
            ok "CHROME_EXECUTABLE=$CHROME_EXECUTABLE"
            break
        fi
    done
fi

# Persistir CHROME_EXECUTABLE no .bashrc se ainda nao estiver la
BASHRC="$HOME/.bashrc"
if [ -f "$BASHRC" ] && [ -n "${CHROME_EXECUTABLE:-}" ] && ! grep -q "CHROME_EXECUTABLE" "$BASHRC"; then
    echo "" >> "$BASHRC"
    echo "# Flutter Web — aponta para Chromium" >> "$BASHRC"
    echo "export CHROME_EXECUTABLE=$CHROME_EXECUTABLE" >> "$BASHRC"
    ok "CHROME_EXECUTABLE salvo em ~/.bashrc"
fi

# --- Dependencias utilitarias para Flutter Web/setup ---
if command -v apt-get &>/dev/null; then
    FLUTTER_BUILD_DEPS=(curl wget tar xz-utils lsof)
    MISSING_DEPS=()
    for dep in "${FLUTTER_BUILD_DEPS[@]}"; do
        if ! dpkg -s "$dep" &>/dev/null 2>&1; then
            MISSING_DEPS+=("$dep")
        fi
    done
    if [ "${#MISSING_DEPS[@]}" -gt 0 ]; then
        warn "Dependencias utilitarias ausentes: ${MISSING_DEPS[*]}"
        read -rp "Deseja instalar agora via apt? (S/N) " choice
        if [[ "$choice" =~ ^[Ss]$ ]]; then
            sudo apt-get install -y "${MISSING_DEPS[@]}"
            ok "Dependencias utilitarias instaladas: ${MISSING_DEPS[*]}"
        else
            warn "Sem essas dependencias algumas etapas automaticas podem falhar."
            gray "  Instale manualmente: sudo apt install ${MISSING_DEPS[*]}"
        fi
    else
        ok "Dependencias utilitarias OK"
    fi
fi

# --- Chrome (recomendado para Flutter Web) ---
CHROME_EXISTS=false
if command -v google-chrome &>/dev/null || command -v google-chrome-stable &>/dev/null || \
   command -v chromium-browser &>/dev/null || command -v chromium &>/dev/null; then
    CHROME_EXISTS=true
    ok "Chromium/Chrome detectado"
else
    warn "Google Chrome/Chromium nao encontrado. E o recomendado para Flutter Web."
    read -rp "Deseja instalar o Chromium agora? (S/N) " choice
    if [[ "$choice" =~ ^[Ss]$ ]]; then
        if command -v apt-get &>/dev/null; then
            sudo apt-get install -y chromium-browser || sudo apt-get install -y chromium
        elif command -v dnf &>/dev/null; then
            sudo dnf install -y chromium
        elif command -v pacman &>/dev/null; then
            sudo pacman -Sy --noconfirm chromium
        elif command -v snap &>/dev/null; then
            sudo snap install chromium
        fi
        CHROME_EXISTS=true
    fi
fi

# Usar web-server em vez de chrome para evitar conflitos de porta de debug
FLUTTER_DEVICE="web-server"

# --- Java 21+ (necessario para Firebase Emulators) ---
JAVA_OK=false
JDK_LOCAL_DIR="$BASE_DIR/.tools/jdk-21"

if [ -x "$JDK_LOCAL_DIR/bin/java" ]; then
    local_ver=$(java_major_version "$JDK_LOCAL_DIR/bin/java")
    if [ "$local_ver" -ge 21 ]; then
        export JAVA_HOME="$JDK_LOCAL_DIR"
        export PATH="$JDK_LOCAL_DIR/bin:$PATH"
        ok "JDK $local_ver local (.tools/jdk-21)"
        JAVA_OK=true
    fi
fi

if ! $JAVA_OK && command -v java &>/dev/null; then
    sys_ver=$(java_major_version "java")
    if [ "$sys_ver" -ge 21 ]; then
        ok "Java $sys_ver do sistema"
        JAVA_OK=true
    else
        warn "Java $sys_ver detectado, mas emuladores precisam de 21+."
    fi
fi

if ! $JAVA_OK; then
    step "[Step] Tentando baixar JDK 21 (Adoptium) localmente em .tools/jdk-21..."
    ARCH=$(uname -m)
    case "$ARCH" in
        x86_64)  ADOPT_ARCH="x64" ;;
        aarch64) ADOPT_ARCH="aarch64" ;;
        *)       ADOPT_ARCH="x64" ;;
    esac
    ADOPTIUM_URL="https://api.adoptium.net/v3/assets/latest/21/hotspot?architecture=${ADOPT_ARCH}&image_type=jdk&os=linux&vendor=eclipse"
    TOOLS_DIR="$BASE_DIR/.tools"
    mkdir -p "$TOOLS_DIR"

    # Obter URL de download do JDK via API do Adoptium
    if command -v curl &>/dev/null; then
        DOWNLOAD_URL=$(curl -s "$ADOPTIUM_URL" | grep -o '"link":"[^"]*\.tar\.gz"' | head -1 | cut -d'"' -f4)
        FILE_NAME=$(curl -s "$ADOPTIUM_URL" | grep -o '"name":"[^"]*\.tar\.gz"' | head -1 | cut -d'"' -f4)
    elif command -v wget &>/dev/null; then
        RESPONSE=$(wget -qO- "$ADOPTIUM_URL")
        DOWNLOAD_URL=$(echo "$RESPONSE" | grep -o '"link":"[^"]*\.tar\.gz"' | head -1 | cut -d'"' -f4)
        FILE_NAME=$(echo "$RESPONSE" | grep -o '"name":"[^"]*\.tar\.gz"' | head -1 | cut -d'"' -f4)
    fi

    if [ -n "${DOWNLOAD_URL:-}" ] && [ -n "${FILE_NAME:-}" ]; then
        TAR_PATH="$TOOLS_DIR/$FILE_NAME"
        gray "Baixando JDK 21 de Adoptium..."
        if command -v curl &>/dev/null; then
            curl -L --progress-bar "$DOWNLOAD_URL" -o "$TAR_PATH"
        else
            wget --progress=bar "$DOWNLOAD_URL" -O "$TAR_PATH"
        fi
        EXTRACT_DIR="$TOOLS_DIR/jdk-extract-temp"
        rm -rf "$EXTRACT_DIR"
        mkdir -p "$EXTRACT_DIR"
        tar -xf "$TAR_PATH" -C "$EXTRACT_DIR"
        rm -f "$TAR_PATH"
        JDK_EXTRACTED=$(find "$EXTRACT_DIR" -maxdepth 1 -type d | grep -v "^$EXTRACT_DIR$" | head -1)
        if [ -n "$JDK_EXTRACTED" ]; then
            rm -rf "$JDK_LOCAL_DIR"
            mv "$JDK_EXTRACTED" "$JDK_LOCAL_DIR"
            rm -rf "$EXTRACT_DIR"
            export JAVA_HOME="$JDK_LOCAL_DIR"
            export PATH="$JDK_LOCAL_DIR/bin:$PATH"
            installed_ver=$(java_major_version "$JDK_LOCAL_DIR/bin/java")
            if [ "$installed_ver" -ge 21 ]; then
                ok "JDK $installed_ver instalado em .tools/jdk-21"
                JAVA_OK=true
                # Adicionar .tools/ ao .gitignore se necessario
                GITIGNORE_PATH="$BASE_DIR/.gitignore"
                if [ -f "$GITIGNORE_PATH" ] && ! grep -q "\.tools" "$GITIGNORE_PATH"; then
                    echo -e "\n.tools/" >> "$GITIGNORE_PATH"
                fi
            fi
        fi
    else
        warn "Nao foi possivel obter URL de download do JDK 21 via API Adoptium."
        warn "Instale o JDK 21+ manualmente:"
        gray "  Ubuntu/Debian: sudo apt install openjdk-21-jdk"
        gray "  Fedora/RHEL:   sudo dnf install java-21-openjdk"
        gray "  Arch:          sudo pacman -S jdk21-openjdk"
        gray "  Download:      https://adoptium.net/temurin/releases/?version=21"
    fi
fi

if ! $JAVA_OK && command -v apt-get &>/dev/null; then
    warn "Tentando instalar via apt: openjdk-21-jdk..."
    read -rp "Deseja instalar o OpenJDK 21 via apt agora? (S/N) " choice
    if [[ "$choice" =~ ^[Ss]$ ]]; then
        sudo apt-get update -y && sudo apt-get install -y openjdk-21-jdk
        sys_ver=$(java_major_version "java")
        if [ "$sys_ver" -ge 21 ]; then
            ok "Java $sys_ver instalado com sucesso"
            JAVA_OK=true
        fi
    fi
fi

echo ""

# ============================================================
# FASE 2: INSTALACAO DE DEPENDENCIAS
# ============================================================
step "--- FASE 2: Instalando dependencias ---"

# --- Backend ---
if [ ! -d "$BACKEND_DIR" ]; then
    err "Pasta 'backend' nao encontrada em $BASE_DIR"
    exit 1
fi

ensure_backend_firebase_rc

cd "$BACKEND_DIR"
step "[Backend] npm install..."
run_with_retry "npm install (backend)" npm install
ok "Backend dependencias instaladas"

# --- Firebase Tools ---
step "[Backend] Verificando firebase-tools..."
FB_VER=""
FB_CMD_RESOLVED=""

# 1. Tentar versao local/global sem baixar
if FB_VER=$(npx --no-install firebase-tools --version 2>/dev/null) && [ -n "$FB_VER" ]; then
    FB_CMD_RESOLVED="npx firebase-tools"
fi

# 2. Tentar comando global 'firebase'
if [ -z "$FB_VER" ] && command -v firebase &>/dev/null; then
    if FB_VER=$(firebase --version 2>/dev/null) && [ -n "$FB_VER" ]; then
        FB_CMD_RESOLVED="firebase"
    fi
fi

# 3. Tentar via npx com versao pinada
if [ -z "$FB_VER" ]; then
    warn "firebase-tools nao detectado local/globalmente. Tentando via npx..."
    if FB_VER=$(npx --yes "$FIREBASE_TOOLS_VER" --version 2>/dev/null) && [ -n "$FB_VER" ]; then
        FB_CMD_RESOLVED="npx --yes $FIREBASE_TOOLS_VER"
    fi
fi

# 4. Instalar localmente no backend como fallback
if [ -z "$FB_VER" ]; then
    warn "Instalando firebase-tools localmente no backend..."
    npm install --save-dev firebase-tools
    if FB_VER=$(npx --no-install firebase-tools --version 2>/dev/null) && [ -n "$FB_VER" ]; then
        FB_CMD_RESOLVED="npx firebase-tools"
    fi
fi

if [ -n "$FB_VER" ]; then
    FIREBASE_CMD="$FB_CMD_RESOLVED"
    ok "firebase-tools $FB_VER pronto para uso via '$FIREBASE_CMD'"
else
    err "firebase-tools nao respondeu de nenhuma forma."
    gray "Instale manualmente: npm install -g firebase-tools"
    cd "$BASE_DIR"
    exit 1
fi

# --- Functions ---
if [ -d "$FUNCTIONS_DIR" ]; then
    cd "$FUNCTIONS_DIR"
    step "[Functions] npm install..."
    if run_with_retry "npm install (functions)" npm install; then
        step "[Functions] Compilando TypeScript (npm run build)..."
        if npm run build; then
            ok "Functions compiladas"
        else
            warn "Compilacao do TypeScript falhou. Verifique erros acima."
        fi
    fi
    cd "$BASE_DIR"
else
    warn "Pasta 'functions' nao encontrada em $BACKEND_DIR"
fi

cd "$BASE_DIR"

# --- Frontend ---
if [ -d "$FRONTEND_DIR" ]; then
    cd "$FRONTEND_DIR"

    step "[Frontend] flutter pub get..."
    if run_with_retry "flutter pub get" "$FLUTTER_CMD" pub get; then
        ok "Frontend dependencias instaladas"
    else
        warn "flutter pub get falhou apos tentativas."
    fi

    # Configurar .env para emuladores usando as chaves lidas pelo Flutter.
    ensure_frontend_env

    ensure_flutter_firebase_options
    hide_emulator_banner

    cd "$BASE_DIR"
else
    warn "Pasta 'frontend/app' nao encontrada"
fi

echo ""
echo -e "${C_SUCCESS}========================================${C_RESET}"
echo -e "${C_SUCCESS}   SETUP CONCLUIDO!                     ${C_RESET}"
echo -e "${C_SUCCESS}========================================${C_RESET}"
echo ""

# ============================================================
# FASE 3: INICIALIZACAO DO AMBIENTE (OPCIONAL)
# ============================================================
if ! $JAVA_OK; then
    warn "Java 21+ nao detectado. Os emuladores Firebase NAO vao funcionar."
    gray "Instale o JDK 21+ e rode o script novamente."
    echo ""
    step "Para iniciar manualmente (apos instalar Java 21+):"
    gray "  Backend:  cd backend && $FIREBASE_CMD emulators:start --project $PROJECT_ID --only auth,functions,firestore,storage"
    gray "  Frontend: cd frontend/app && $FLUTTER_CMD run -d $FLUTTER_DEVICE --web-port $FLUTTER_WEB_PORT"
    echo ""
    echo -e "${C_INFO}Boa sorte com o MesclaInvest!${C_RESET}"
    exit 0
fi

echo ""
read -rp "Deseja iniciar o ambiente completo agora? (S/N) " start_all
if [[ ! "$start_all" =~ ^[Ss]$ ]]; then
    echo ""
    step "Para iniciar manualmente:"
    gray "  Backend:  cd backend && $FIREBASE_CMD emulators:start --project $PROJECT_ID --only auth,functions,firestore,storage"
    gray "  Frontend: cd frontend/app && $FLUTTER_CMD run -d $FLUTTER_DEVICE --web-port $FLUTTER_WEB_PORT"
    echo ""
    echo -e "${C_INFO}Boa sorte com o MesclaInvest!${C_RESET}"
    exit 0
fi

echo ""
step "--- FASE 3: Iniciando ambiente ---"

# Liberar portas antes de subir os servicos
free_ports

# ─── [1/4] Iniciar Firebase Emulators em terminal separado ──────────────────
step "[1/4] Iniciando Firebase Emulators (backend)..."

# Determinar como abrir um terminal
if command -v gnome-terminal &>/dev/null; then
    TERM_CMD="gnome-terminal"
elif command -v xterm &>/dev/null; then
    TERM_CMD="xterm"
elif command -v konsole &>/dev/null; then
    TERM_CMD="konsole"
elif command -v xfce4-terminal &>/dev/null; then
    TERM_CMD="xfce4-terminal"
elif command -v tilix &>/dev/null; then
    TERM_CMD="tilix"
else
    TERM_CMD=""
fi

JAVA_ENV_EXPORT=""
if [ -n "${JAVA_HOME:-}" ]; then
    JAVA_ENV_EXPORT="export JAVA_HOME='$JAVA_HOME'; export PATH='$JAVA_HOME/bin:\$PATH';"
fi

EMULATOR_COMMAND="cd '$BACKEND_DIR' && $JAVA_ENV_EXPORT $FIREBASE_CMD emulators:start --project $PROJECT_ID --only auth,functions,firestore,storage"

if [ -n "$TERM_CMD" ]; then
    case "$TERM_CMD" in
        gnome-terminal)
            gnome-terminal --title="MesclaInvest Backend" -- bash -c "$EMULATOR_COMMAND; exec bash" &
            ;;
        xterm)
            xterm -title "MesclaInvest Backend" -e bash -c "$EMULATOR_COMMAND; exec bash" &
            ;;
        konsole)
            konsole --title "MesclaInvest Backend" -e bash -c "$EMULATOR_COMMAND; exec bash" &
            ;;
        xfce4-terminal)
            xfce4-terminal --title="MesclaInvest Backend" -e "bash -c \"$EMULATOR_COMMAND; exec bash\"" &
            ;;
        tilix)
            tilix -e "bash -c \"$EMULATOR_COMMAND; exec bash\"" &
            ;;
    esac
    gray "Backend iniciado em nova janela de terminal"
else
    # Sem terminal grafico: iniciar em background com log
    BACKEND_LOG="$BASE_DIR/backend-emulator.log"
    gray "Nenhum emulador de terminal grafico detectado. Iniciando backend em background..."
    gray "Log disponivel em: $BACKEND_LOG"
    bash -c "$EMULATOR_COMMAND" > "$BACKEND_LOG" 2>&1 &
    BACKEND_PID=$!
    gray "Backend PID: $BACKEND_PID"
fi

# ─── Aguardar emuladores ficarem prontos ────────────────────────────────────
gray "Aguardando emuladores ficarem prontos (porta 8080, 5001, 9099, 9199)..."
if wait_ports "${REQUIRED_BACKEND_PORTS[@]}"; then
    echo ""
    ok "Emuladores ativos!"
else
    echo ""
    err "Timeout aguardando emuladores. Verifique a janela do Firebase ou o log em backend-emulator.log"
    gray "Se a janela nao abriu, inicie manualmente:"
    gray "  cd backend && $FIREBASE_CMD emulators:start --project $PROJECT_ID --only auth,functions,firestore,storage"
    echo ""
    warn "Continuando com seed e frontend de qualquer forma (podem falhar sem emuladores)..."
fi

# ─── [2/4] Seed do banco de dados ───────────────────────────────────────────
echo ""
step "[2/4] Populando banco de dados com dados de teste..."

# Criar tsconfig temporario para compilar os scripts de seed
SEED_TSCONFIG="$FUNCTIONS_DIR/tsconfig.seed.json"
cat > "$SEED_TSCONFIG" <<'TSCONFIG_EOF'
{
  "compilerOptions": {
    "module": "NodeNext",
    "esModuleInterop": true,
    "moduleResolution": "nodenext",
    "noImplicitReturns": true,
    "rootDir": ".",
    "outDir": "lib",
    "sourceMap": true,
    "strict": true,
    "target": "es2022",
    "skipLibCheck": true,
    "noEmitOnError": false
  },
  "include": [
    "scripts/**/*.ts",
    "src/**/*.ts"
  ]
}
TSCONFIG_EOF

gray "Compilando scripts de seed..."
cd "$FUNCTIONS_DIR"
npx tsc --project tsconfig.seed.json 2>&1 || true
cd "$BASE_DIR"
rm -f "$SEED_TSCONFIG"

# Configurar variaveis de ambiente para seeds
export GCLOUD_PROJECT="$PROJECT_ID"
export FIREBASE_CONFIG="{\"projectId\":\"$PROJECT_ID\",\"storageBucket\":\"$PROJECT_ID.appspot.com\"}"
export FIRESTORE_EMULATOR_HOST="localhost:8080"
export FIREBASE_AUTH_EMULATOR_HOST="localhost:9099"

run_seed() {
    local js_path="$1"
    local label="$2"
    local summary="${3:-}"

    local js_file
    js_file="$(basename "$js_path")"

    if [ ! -f "$js_path" ]; then
        warn "Arquivo $js_file nao gerado"
        return 1
    fi

    gray "Populando $label..."
    if output=$(node "$js_path" 2>&1); then
        ok "$label populados com sucesso!"
        local count
        count=$(echo "$output" | grep -c "✓" 2>/dev/null || echo "0")
        if [ "$count" -gt 0 ] && [ -n "$summary" ]; then
            gray "$count $summary"
        fi
        return 0
    else
        warn "Seed de $label retornou erro (pode ja estar populado)"
        echo "$output" | grep -i "error" | head -3 | while IFS= read -r line; do
            gray "$line"
        done
        return 1
    fi
}

SEED_OUT="$FUNCTIONS_DIR/lib/scripts"

run_seed "$SEED_OUT/seed-startups.js"    "startups"         "startups criadas no Firestore"
run_seed "$SEED_OUT/seed-users.js"       "usuarios demo"    "usuarios criados no Auth + Firestore"
run_seed "$SEED_OUT/seed-investments.js" "investimentos"    "investimentos registrados"
run_seed "$SEED_OUT/seed-orderbook.js"   "ordens do balcao" "ordens criadas no balcao"

# Limpar variaveis de ambiente do seed
unset GCLOUD_PROJECT FIREBASE_CONFIG FIRESTORE_EMULATOR_HOST FIREBASE_AUTH_EMULATOR_HOST

echo ""
echo -e "${C_INFO}       Login dos usuarios demo:${C_RESET}"
gray "  Emails: aluno001@mescla.test ... aluno150@mescla.test"
gray "  Senha:  Mescla@2026"

# ─── [3/4] Iniciar Flutter ──────────────────────────────────────────────────
echo ""
step "[3/4] Iniciando Flutter ($FLUTTER_DEVICE)..."

FLUTTER_COMMAND="cd '$FRONTEND_DIR' && $FLUTTER_CMD run -d $FLUTTER_DEVICE --web-port $FLUTTER_WEB_PORT"

if [ -n "$TERM_CMD" ]; then
    case "$TERM_CMD" in
        gnome-terminal)
            gnome-terminal --title="MesclaInvest Flutter App" -- bash -c "$FLUTTER_COMMAND; exec bash" &
            ;;
        xterm)
            xterm -title "MesclaInvest Flutter App" -e bash -c "$FLUTTER_COMMAND; exec bash" &
            ;;
        konsole)
            konsole --title "MesclaInvest Flutter App" -e bash -c "$FLUTTER_COMMAND; exec bash" &
            ;;
        xfce4-terminal)
            xfce4-terminal --title="MesclaInvest Flutter App" -e "bash -c \"$FLUTTER_COMMAND; exec bash\"" &
            ;;
        tilix)
            tilix -e "bash -c \"$FLUTTER_COMMAND; exec bash\"" &
            ;;
    esac
    gray "Flutter iniciado em nova janela de terminal"
else
    FLUTTER_LOG="$BASE_DIR/flutter-app.log"
    gray "Iniciando Flutter em background. Log: $FLUTTER_LOG"
    bash -c "$FLUTTER_COMMAND" > "$FLUTTER_LOG" 2>&1 &
    FLUTTER_PID=$!
    gray "Flutter PID: $FLUTTER_PID"
fi

# Aguardar o Flutter subir o web-server
gray "Aguardando Flutter compilar e subir o servidor (porta $FLUTTER_WEB_PORT)..."
DEADLINE=90
ELAPSED=0
while [ "$ELAPSED" -lt "$DEADLINE" ]; do
    if test_port "$FLUTTER_WEB_PORT" 2>/dev/null; then
        break
    fi
    sleep 2
    ELAPSED=$((ELAPSED + 2))
    printf "."
done
echo ""

# ─── [4/4] Abrir no navegador ───────────────────────────────────────────────
step "[4/4] Abrindo Flutter app e Firebase UI no navegador..."

open_browser() {
    local url="$1"
    if command -v xdg-open &>/dev/null; then
        xdg-open "$url" &
    elif command -v google-chrome &>/dev/null; then
        google-chrome "$url" &
    elif command -v google-chrome-stable &>/dev/null; then
        google-chrome-stable "$url" &
    elif command -v chromium-browser &>/dev/null; then
        chromium-browser "$url" &
    elif command -v chromium &>/dev/null; then
        chromium "$url" &
    elif command -v firefox &>/dev/null; then
        firefox "$url" &
    fi
}

open_browser "http://localhost:$FLUTTER_WEB_PORT"
sleep 1
open_browser "http://localhost:4000"

echo ""
echo -e "${C_INFO}========================================${C_RESET}"
echo -e "${C_INFO}   MesclaInvest rodando!                ${C_RESET}"
echo -e "${C_INFO}========================================${C_RESET}"
echo ""
step "Servicos:"
gray "  Flutter App:     http://localhost:$FLUTTER_WEB_PORT"
gray "  Firebase UI:     http://localhost:4000"
gray "  Auth Emulator:   http://localhost:9099"
gray "  Firestore:       http://localhost:8080"
gray "  Functions:       http://localhost:5001"
gray "  Storage:         http://localhost:9199"
echo ""
echo -e "${C_INFO}Boa sorte com o MesclaInvest!${C_RESET}"
