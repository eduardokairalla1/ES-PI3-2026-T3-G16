# --- SETUP MESCLAINVEST PARA WINDOWS ---
# Execute com: .\setup-windows.ps1 (na raiz do projeto)
#
# Este script:
#   1. Verifica ferramentas necessarias (Node, Flutter, Java 21+, Chrome/Edge)
#   2. Instala dependencias (npm install, flutter pub get, firebase-tools)
#   3. Configura o .env do frontend para emuladores
#   4. (Opcional) Inicia o ambiente completo (emuladores + Flutter)

# ============================================================
# FASE 0: PREPARACAO DO SISTEMA
# ============================================================
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal([Security.Principal.WindowsIdentity]::GetCurrent())
$isAdmin = $currentPrincipal.IsInRole([Security.Principal.WindowsBuiltInRole]::Administrator)

if (-not $isAdmin) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor "Yellow"
    Write-Host "  AVISO: SEM PRIVILEGIOS DE ADMIN      " -ForegroundColor "Yellow"
    Write-Host "========================================" -ForegroundColor "Yellow"
    Write-Host "O script tentara instalar as ferramentas apenas para o seu USUARIO local." -ForegroundColor Gray
    Write-Host "Isso geralmente funciona, mas se encontrar erros de permissao, tente rodar" -ForegroundColor Gray
    Write-Host "como Administrador." -ForegroundColor Gray
    Write-Host ""
    
    $elevate = Read-Host "Deseja tentar relancar como Administrador para uma instalacao completa? (S/N)"
    if ($elevate -eq "S" -or $elevate -eq "s") {
        $elevateArgs = "-NoExit -ExecutionPolicy Bypass -File `"$PSCommandPath`""
        try {
            Start-Process powershell -ArgumentList $elevateArgs -Verb RunAs -ErrorAction Stop
            exit
        } catch {
            Write-Host "[AVISO] Nao foi possivel elevar. Continuando como usuario normal..." -ForegroundColor "Yellow"
        }
    }
}

# CONFIGURACAO INICIAL
# ============================================================
# Cores padrao para mensagens

$cSuccess = "Green"
$cWarning = "Yellow"
$cError   = "Red"
$cInfo    = "Cyan"
$cStep    = "White"

# Detectar raiz do projeto
$baseDir = $PSScriptRoot
if (-Not $baseDir) { $baseDir = (Get-Location).Path }
Set-Location $baseDir

# Pastas do projeto
$backendDir   = Join-Path $baseDir "backend"
$functionsDir = Join-Path $backendDir "functions"
$frontendDir  = Join-Path $baseDir "frontend\app"
$firebaseToolsNpx = "firebase-tools@15.17.0"
$projectId = "mesclainvest-eda16"
$flutterWebPort = 3000
$portsToKill = @($flutterWebPort, 4000, 4400, 4500, 5000, 5001, 8080, 8085, 9099, 9150, 9199)
$requiredBackendPorts = @(8080, 5001, 9099, 9199)

# Pub cache em caminho sem espaço — Flutter native asset hooks (objective_c etc)
# quebram quando o caminho contém espaço (ex.: "C:\Users\Pedro Medeiros\...").
$pubCacheDir = "C:\.pub-cache"
if (-not (Test-Path $pubCacheDir)) {
    New-Item -ItemType Directory -Path $pubCacheDir -Force | Out-Null
}
$env:PUB_CACHE = $pubCacheDir
[Environment]::SetEnvironmentVariable("PUB_CACHE", $pubCacheDir, "User")

Write-Host ""
Write-Host "========================================" -ForegroundColor $cInfo
Write-Host "   SETUP MESCLAINVEST - WINDOWS         " -ForegroundColor $cInfo
Write-Host "========================================" -ForegroundColor $cInfo
Write-Host "Pasta: $baseDir" -ForegroundColor Gray
Write-Host ""

# ============================================================
# FUNCOES AUXILIARES
# ============================================================

function Stop-LocalhostProcesses {
    param([int[]]$Ports)

    Write-Host "[Setup] Liberando portas localhost usadas pelo projeto..." -ForegroundColor $cStep

    $killed = @{}

    foreach ($port in $Ports) {
        try {
            $connections = Get-NetTCPConnection -LocalPort $port -ErrorAction SilentlyContinue |
                Where-Object {
                    $_.State -eq "Listen" -and
                    ($_.LocalAddress -eq "127.0.0.1" -or $_.LocalAddress -eq "::1" -or $_.LocalAddress -eq "0.0.0.0" -or $_.LocalAddress -eq "::")
                }

            foreach ($conn in $connections) {
                $pidToKill = [int]$conn.OwningProcess
                if ($pidToKill -le 0 -or $pidToKill -eq $PID -or $killed.ContainsKey($pidToKill)) {
                    continue
                }

                $proc = Get-Process -Id $pidToKill -ErrorAction SilentlyContinue
                if ($null -eq $proc) {
                    continue
                }

                Write-Host "       Encerrando localhost:$port -> PID $pidToKill ($($proc.ProcessName))" -ForegroundColor Gray
                Stop-Process -Id $pidToKill -Force -ErrorAction SilentlyContinue
                $killed[$pidToKill] = $true
            }
        } catch {
            Write-Host "       [AVISO] Nao foi possivel verificar a porta ${port}: $_" -ForegroundColor $cWarning
        }
    }

    if ($killed.Count -eq 0) {
        Write-Host "[OK] Nenhuma porta localhost do projeto precisava ser liberada" -ForegroundColor $cSuccess
    } else {
        Start-Sleep -Seconds 2
        Write-Host "[OK] Portas localhost liberadas" -ForegroundColor $cSuccess
    }

    # Limpar ADB se existir (as vezes trava o Flutter)
    if (Get-Process adb -ErrorAction SilentlyContinue) {
        Write-Host "       Encerrando processo ADB..." -ForegroundColor Gray
        Stop-Process -Name adb -Force -ErrorAction SilentlyContinue
    }

    # Chrome existente "captura" a chamada do Flutter (--bwsi/--user-data-dir
    # são ignorados) e a porta de remote-debugging nunca abre, causando
    # "Failed to launch browser after 3 tries".
    if (Get-Process chrome -ErrorAction SilentlyContinue) {
        Write-Host "       Encerrando instancias do Chrome (evita conflito com flutter run -d chrome)..." -ForegroundColor Gray
        Stop-Process -Name chrome -Force -ErrorAction SilentlyContinue
    }

    # Limpar dirs temp do flutter_tools (acumulam e às vezes corrompem)
    Get-ChildItem $env:TEMP -Filter "flutter_tools*" -Directory -ErrorAction SilentlyContinue |
        Remove-Item -Recurse -Force -ErrorAction SilentlyContinue
}

function Invoke-WithRetry {
    param(
        [scriptblock]$Script,
        [string]$Name,
        [int]$MaxRetries = 3
    )

    $retryCount = 0
    $success = $false

    while (-not $success -and $retryCount -lt $MaxRetries) {
        if ($retryCount -gt 0) {
            Write-Host "[Retry] Tentando novamente $Name (Tentativa $($retryCount + 1)/$MaxRetries)..." -ForegroundColor $cWarning
            Start-Sleep -Seconds 2
        }

        &$Script
        if ($LASTEXITCODE -eq 0) {
            $success = $true
        } else {
            $retryCount++
        }
    }

    if (-not $success) {
        Write-Host "[ERRO] $Name falhou apos $MaxRetries tentativas." -ForegroundColor $cError
        return $false
    }
    return $true
}

function Test-LocalPort {
    param([int]$Port)

    try {
        $tcp = New-Object System.Net.Sockets.TcpClient
        $tcp.Connect("127.0.0.1", $Port)
        $tcp.Close()
        return $true
    } catch {
        return $false
    }
}

function Wait-LocalPorts {
    param(
        [int[]]$Ports,
        [int]$TimeoutSeconds = 120
    )

    $elapsed = 0
    while ($elapsed -lt $TimeoutSeconds) {
        $closedPorts = @()

        foreach ($port in $Ports) {
            if (-not (Test-LocalPort -Port $port)) {
                $closedPorts += $port
            }
        }

        if ($closedPorts.Count -eq 0) {
            return $true
        }

        Write-Host "." -NoNewline
        Start-Sleep -Seconds 3
        $elapsed += 3
    }

    return $false
}

function Refresh-Environment {
    Write-Host "[Step] Atualizando variaveis de ambiente da sessao (PATH)..." -ForegroundColor Gray
    
    # Reload Path from Registry
    # Machine path (usually readable even without admin)
    $machinePath = [System.Environment]::GetEnvironmentVariable("Path", "Machine")
    # User path (always readable/writable by current user)
    $userPath = [System.Environment]::GetEnvironmentVariable("Path", "User")
    
    # Merge and update current session
    if ($null -eq $machinePath) { $machinePath = "" }
    if ($null -eq $userPath) { $userPath = "" }
    
    $env:PATH = "$machinePath;$userPath"
    
    # Forçar refresh de comandos conhecidos
    Get-Command flutter, node, npm, git, firebase -ErrorAction SilentlyContinue | Out-Null
}

function Ensure-BackendFirebaseRc {
    $firebaseRcPath = Join-Path $backendDir ".firebaserc"
    $firebaseRc = @"
{
  "projects": {
    "default": "$projectId"
  }
}
"@

    if (-not (Test-Path $firebaseRcPath)) {
        Set-Content $firebaseRcPath $firebaseRc -Encoding UTF8
        Write-Host "[OK] backend/.firebaserc criado para $projectId" -ForegroundColor $cSuccess
        return
    }

    $current = Get-Content $firebaseRcPath -Raw
    if ($current -notmatch $projectId) {
        Set-Content $firebaseRcPath $firebaseRc -Encoding UTF8
        Write-Host "[OK] backend/.firebaserc atualizado para $projectId" -ForegroundColor $cSuccess
    } else {
        Write-Host "[OK] backend/.firebaserc configurado" -ForegroundColor $cSuccess
    }
}

function Ensure-FlutterFirebaseOptions {
    $optionsPath = Join-Path $frontendDir "lib\firebase_options.dart"
    $optionsDir = Split-Path $optionsPath -Parent

    if (-not (Test-Path $optionsDir)) {
        New-Item -ItemType Directory -Path $optionsDir -Force | Out-Null
    }

    $mustWrite = $true
    if (Test-Path $optionsPath) {
        $existing = Get-Content $optionsPath -Raw
        $mustWrite = (
            $existing -notmatch "projectId:\s*'$projectId'" -or
            $existing -match "apiKey:\s*''" -or
            $existing -match "appId:\s*''"
        )
    }

    if (-not $mustWrite) {
        Write-Host "[OK] firebase_options.dart configurado" -ForegroundColor $cSuccess
        return
    }

    $optionsContent = @"
import 'package:firebase_core/firebase_core.dart';

/// Firebase options for local development with Firebase emulators.
///
/// The app uses emulators through `.env`, but Firebase still needs a non-empty
/// project/app configuration before emulator hosts are wired.
class DefaultFirebaseOptions {
  static const FirebaseOptions currentPlatform = FirebaseOptions(
    apiKey: 'emulator-api-key',
    appId: '1:854885921307:web:fd5a65eb5d67678de97ebe',
    messagingSenderId: '854885921307',
    projectId: '$projectId',
    authDomain: '$projectId.firebaseapp.com',
    storageBucket: '$projectId.appspot.com',
  );
}
"@

    Set-Content $optionsPath $optionsContent -Encoding UTF8
    Write-Host "[OK] firebase_options.dart criado/configurado para emuladores" -ForegroundColor $cSuccess
}

# ============================================================
# FASE 1: VERIFICACAO DE FERRAMENTAS
# ============================================================
Write-Host "--- FASE 1: Verificando ferramentas ---" -ForegroundColor $cWarning

$toolsInstalled = $false

function Install-WithWinget {
    param([string]$PackageId, [string]$Name)
    
    if (-not (Get-Command winget -ErrorAction SilentlyContinue)) {
        Write-Host "[ERRO] winget nao encontrado. Nao e possivel instalar $Name automaticamente." -ForegroundColor $cError
        return $false
    }

    $scope = if ($isAdmin) { "machine" } else { "user" }
    Write-Host "[Step] Instalando $Name via winget (escopo: $scope)..." -ForegroundColor $cInfo
    
    $baseArgs = @("install", "--id", $PackageId, "--source", "winget", "--accept-package-agreements", "--accept-source-agreements", "--scope", $scope)
    
    # Tentar instalacao silenciosa
    $silentArgs = $baseArgs + "--silent"
    winget @silentArgs
    
    if ($LASTEXITCODE -ne 0) {
        # Fallback: tentar sem o --silent se falhar
        Write-Host "       Instalacao silenciosa falhou, tentando modo interativo..." -ForegroundColor Gray
        winget @baseArgs
    }

    return ($LASTEXITCODE -eq 0)
}

# --- Git ---
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
    Write-Host "[AVISO] Git nao encontrado." -ForegroundColor $cWarning
    $choice = Read-Host "Deseja instalar o Git agora? (S/N)"
    if ($choice -eq "S" -or $choice -eq "s") {
        if (Install-WithWinget -PackageId "Git.Git" -Name "Git") { $toolsInstalled = $true }
    } else {
        Write-Host "[ERRO] Git e necessario." -ForegroundColor $cError; exit 1
    }
} else { Write-Host "[OK] Git detectado" -ForegroundColor $cSuccess }

# --- Node.js ---
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "[AVISO] Node.js nao encontrado." -ForegroundColor $cWarning
    $choice = Read-Host "Deseja instalar o Node.js LTS agora? (S/N)"
    if ($choice -eq "S" -or $choice -eq "s") {
        if (Install-WithWinget -PackageId "OpenJS.NodeJS.LTS" -Name "Node.js") { $toolsInstalled = $true }
    } else {
        Write-Host "[ERRO] Node.js e necessario." -ForegroundColor $cError; exit 1
    }
} else { 
    Write-Host "[OK] Node.js $(node -v)" -ForegroundColor $cSuccess 
}

# --- Flutter ---
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    # Tentar refresh rapido antes de desistir (pode ter sido instalado em outra aba)
    Refresh-Environment
    if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
        Write-Host "[AVISO] Flutter SDK nao encontrado." -ForegroundColor $cWarning
        $choice = Read-Host "Deseja instalar o Flutter SDK agora? (S/N)"
        if ($choice -eq "S" -or $choice -eq "s") {
            if (Install-WithWinget -PackageId "Flutter.Flutter" -Name "Flutter") { $toolsInstalled = $true }
        } else {
            Write-Host "[ERRO] Flutter e necessario." -ForegroundColor $cError; exit 1
        }
    } else { Write-Host "[OK] Flutter detectado apos refresh" -ForegroundColor $cSuccess }
} else { Write-Host "[OK] Flutter detectado" -ForegroundColor $cSuccess }

if ($toolsInstalled) {
    Refresh-Environment
    Write-Host "[OK] Ambiente atualizado. Continuando execucao..." -ForegroundColor $cSuccess
}

# --- Busca ativa pelo Flutter se ainda nao esta no PATH ---
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "[Step] Buscando Flutter no disco..." -ForegroundColor $cInfo
    $flutterSearchPaths = @(
        "$env:LOCALAPPDATA\FlutterSDK\bin",
        "$env:LOCALAPPDATA\flutter\bin",
        "$env:USERPROFILE\flutter\bin",
        "$env:USERPROFILE\.flutter\bin",
        "C:\flutter\bin",
        "C:\src\flutter\bin",
        "$env:ProgramFiles\Flutter\bin",
        "${env:ProgramFiles(x86)}\Flutter\bin"
    )
    # Tambem procurar em qualquer subpasta de LocalAppData
    $localAppDataFlutter = Get-ChildItem -Path $env:LOCALAPPDATA -Filter "flutter.bat" -Recurse -Depth 3 -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($localAppDataFlutter) {
        $flutterSearchPaths = @($localAppDataFlutter.DirectoryName) + $flutterSearchPaths
    }
    # Procurar tambem em ProgramData e ProgramFiles
    $progFilesFlutter = Get-ChildItem -Path "$env:ProgramFiles" -Filter "flutter.bat" -Recurse -Depth 3 -ErrorAction SilentlyContinue | Select-Object -First 1
    if ($progFilesFlutter) {
        $flutterSearchPaths = @($progFilesFlutter.DirectoryName) + $flutterSearchPaths
    }

    foreach ($searchPath in $flutterSearchPaths) {
        if (Test-Path (Join-Path $searchPath "flutter.bat")) {
            Write-Host "[OK] Flutter encontrado em: $searchPath" -ForegroundColor $cSuccess
            $env:PATH = "$searchPath;$env:PATH"
            break
        }
    }

    if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
        Write-Host "[ERRO] Flutter instalado mas nao encontrado no PATH." -ForegroundColor $cError
        Write-Host "       Feche o terminal, abra um novo e rode o script novamente." -ForegroundColor Gray
        exit 1
    }
}

# Salvar caminho do Flutter para uso na Fase 3
$flutterBin = (Get-Command flutter -ErrorAction SilentlyContinue).Source
if ($flutterBin) {
    $flutterDir = Split-Path $flutterBin -Parent
}

# --- Configuracao FORCADA do Flutter ---
if (Get-Command flutter -ErrorAction SilentlyContinue) {
    Write-Host "[Flutter] Aplicando configuracoes de plataforma..." -ForegroundColor $cInfo
    flutter config --enable-web | Out-Null
    
    # Aceitar licenças automaticamente (na forca!)
    Write-Host "[Flutter] Aceitando licenças Android (se houver SDK)..." -ForegroundColor Gray
    try {
        $yesArray = @("y") * 20
        $yesArray | flutter doctor --android-licenses | Out-Null
    } catch {}
}

# --- Chrome (Opcional, mas recomendado para Flutter Web) ---
$chromeExists = (Test-Path "C:\Program Files\Google\Chrome\Application\chrome.exe") -or
                (Test-Path "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe")
if (-not $chromeExists) {
    Write-Host "[AVISO] Google Chrome nao encontrado. E o recomendado para o MesclaInvest (Web)." -ForegroundColor $cWarning
    $choice = Read-Host "Deseja instalar o Google Chrome agora? (S/N)"
    if ($choice -eq "S" -or $choice -eq "s") {
        if (Install-WithWinget -PackageId "Google.Chrome" -Name "Google Chrome") {
            $chromeExists = $true
            $flutterDevice = "chrome"
        }
    }
}

if ($chromeExists) {
    Write-Host "[OK] Chrome detectado" -ForegroundColor $cSuccess
}

# Default = web-server: o launcher do Flutter para Chrome/Edge sofre com
# Defender + path TEMP em short-name (PEDROM~1) + zombies de chrome de runs
# anteriores, levando >35s para bindar o remote-debug port — Flutter desiste
# em "Failed to launch browser after 3 tries". web-server é à prova de bala:
# Flutter só sobe um HTTP server e nós abrimos a URL no browser padrao.
$flutterDevice = "web-server"

# --- Java (precisa ser 21+ para Firebase Emulators) ---
$javaOk = $false
$jdkLocalDir = Join-Path $baseDir ".tools\jdk-21"

function Test-JavaVersion {
    param([string]$JavaCmd)
    try {
        $output = & $JavaCmd -version 2>&1 | Out-String
        if ($output -match '"(\d+)\.(\d+)') {
            $major = [int]$Matches[1]
            $minor = [int]$Matches[2]
            if ($major -eq 1) { return $minor } else { return $major }
        }
    } catch { }
    return 0
}

if (Test-Path (Join-Path $jdkLocalDir "bin\java.exe")) {
    $env:JAVA_HOME = $jdkLocalDir
    $env:PATH = "$jdkLocalDir\bin;$env:PATH"
    $localVer = Test-JavaVersion -JavaCmd (Join-Path $jdkLocalDir "bin\java.exe")
    if ($localVer -ge 21) {
        Write-Host "[OK] JDK $localVer local (.tools/jdk-21)" -ForegroundColor $cSuccess
        $javaOk = $true
    }
}

if (-not $javaOk -and (Get-Command java -ErrorAction SilentlyContinue)) {
    $sysVer = Test-JavaVersion -JavaCmd "java"
    if ($sysVer -ge 21) {
        Write-Host "[OK] Java $sysVer do sistema" -ForegroundColor $cSuccess
        $javaOk = $true
    } else {
        Write-Host "[AVISO] Java $sysVer detectado, mas emuladores precisam de 21+." -ForegroundColor $cWarning
    }
}

if (-not $javaOk) {
    Write-Host "[Step] Baixando JDK 21 (Adoptium) localmente..." -ForegroundColor $cInfo
    $arch = if ([Environment]::Is64BitOperatingSystem) { "x64" } else { "x32" }
    $adoptiumApi = "https://api.adoptium.net/v3/assets/latest/21/hotspot?architecture=$arch&image_type=jdk&os=windows&vendor=eclipse"
    try {
        $response = Invoke-RestMethod -Uri $adoptiumApi -ErrorAction Stop
        $asset = $response | Where-Object { $_.binary.package.name -like "*.zip" } | Select-Object -First 1
        if ($asset) {
            $downloadUrl = $asset.binary.package.link
            $fileName = $asset.binary.package.name
            $toolsDir = Join-Path $baseDir ".tools"
            if (-not (Test-Path $toolsDir)) { New-Item -ItemType Directory -Path $toolsDir -Force | Out-Null }
            $zipPath = Join-Path $toolsDir $fileName
            $ProgressPreference = 'SilentlyContinue'
            Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath -ErrorAction Stop
            $ProgressPreference = 'Continue'
            $extractDir = Join-Path $toolsDir "jdk-extract-temp"
            if (Test-Path $extractDir) { Remove-Item $extractDir -Recurse -Force }
            Expand-Archive -Path $zipPath -DestinationPath $extractDir -Force
            $jdkExtracted = Get-ChildItem -Path $extractDir -Directory | Select-Object -First 1
            if ($jdkExtracted) {
                if (Test-Path $jdkLocalDir) { Remove-Item $jdkLocalDir -Recurse -Force }
                Move-Item -Path $jdkExtracted.FullName -Destination $jdkLocalDir -Force
                Remove-Item $extractDir -Recurse -Force -ErrorAction SilentlyContinue
                Remove-Item $zipPath -Force -ErrorAction SilentlyContinue
                $env:JAVA_HOME = $jdkLocalDir
                $env:PATH = "$jdkLocalDir\bin;$env:PATH"
                $installedVer = Test-JavaVersion -JavaCmd (Join-Path $jdkLocalDir "bin\java.exe")
                if ($installedVer -ge 21) {
                    Write-Host "[OK] JDK $installedVer instalado em .tools/jdk-21" -ForegroundColor $cSuccess
                    $javaOk = $true
                    $gitignorePath = Join-Path $baseDir ".gitignore"
                    if (Test-Path $gitignorePath) {
                        $gitignoreContent = Get-Content $gitignorePath -Raw
                        if ($gitignoreContent -notmatch '\.tools') {
                            Add-Content $gitignorePath "`n.tools/"
                        }
                    }
                }
            }
        }
    } catch {
        Write-Host "[AVISO] Falha ao baixar JDK: $_" -ForegroundColor $cWarning
    }
}

Write-Host ""

# ============================================================
# FASE 2: INSTALACAO DE DEPENDENCIAS
# ============================================================
Write-Host "--- FASE 2: Instalando dependencias ---" -ForegroundColor $cWarning

# --- Backend ---
if (-not (Test-Path $backendDir)) {
    Write-Host "[ERRO] Pasta 'backend' nao encontrada em $baseDir" -ForegroundColor $cError
    exit 1
}

Ensure-BackendFirebaseRc

Set-Location $backendDir
Write-Host "[Backend] npm install..." -ForegroundColor $cStep
$backendOk = Invoke-WithRetry -Name "npm install (backend)" -Script { npm install }
if (-not $backendOk) {
    Set-Location $baseDir
    exit 1
}
Write-Host "[OK] Backend dependencias instaladas" -ForegroundColor $cSuccess

# --- Firebase Tools (via npx, sem alterar package.json) ---
Write-Host "[Backend] Verificando firebase-tools via npx..." -ForegroundColor $cStep
$fbVer = npx --yes $firebaseToolsNpx --version
if ($LASTEXITCODE -eq 0 -and $fbVer) {
    Write-Host "[OK] firebase-tools $fbVer (via npx)" -ForegroundColor $cSuccess
} else {
    Write-Host "[ERRO] firebase-tools nao respondeu via npx." -ForegroundColor $cError
    Write-Host "       Tente manualmente: npx --yes $firebaseToolsNpx --version" -ForegroundColor Gray
    Set-Location $baseDir
    exit 1
}

# --- Functions ---
if (Test-Path $functionsDir) {
    Set-Location $functionsDir
    Write-Host "[Functions] npm install..." -ForegroundColor $cStep
    $functionsOk = Invoke-WithRetry -Name "npm install (functions)" -Script { npm install }
    
    if ($functionsOk) {
        Write-Host "[Functions] Compilando TypeScript (npm run build)..." -ForegroundColor $cStep
        npm run build
        if ($LASTEXITCODE -ne 0) {
            Write-Host "[AVISO] Compilacao do TypeScript falhou. Verifique erros acima." -ForegroundColor $cWarning
        } else {
            Write-Host "[OK] Functions compiladas" -ForegroundColor $cSuccess
        }
    }
} else {
    Write-Host "[AVISO] Pasta 'functions' nao encontrada em $backendDir" -ForegroundColor $cWarning
}

Set-Location $baseDir

if (Test-Path $frontendDir) {
    Set-Location $frontendDir
    
    if (Get-Command flutter -ErrorAction SilentlyContinue) {
        Write-Host "[Frontend] flutter pub get..." -ForegroundColor $cStep
        $frontendOk = Invoke-WithRetry -Name "flutter pub get" -Script { flutter pub get }
        
        if (-not $frontendOk) {
            Write-Host "[AVISO] flutter pub get falhou apos tentativas." -ForegroundColor $cWarning
        } else {
            Write-Host "[OK] Frontend dependencias instaladas" -ForegroundColor $cSuccess
        }
    } else {
        Write-Host "[ERRO] Flutter nao disponivel. Nao foi possivel instalar dependencias do frontend." -ForegroundColor $cError
    }

    # Configurar .env para emuladores
    if ((-not (Test-Path ".env")) -and (Test-Path ".env.example")) {
        Copy-Item ".env.example" ".env"
        Write-Host "[OK] .env criado a partir do .env.example" -ForegroundColor $cSuccess
    }

    # Garantir que o .env aponta para emuladores
    if (Test-Path ".env") {
        $envContent = Get-Content ".env" -Raw
        if ($envContent -match "USE_EMULATOR=false") {
            $envContent = $envContent -replace "USE_EMULATOR=false", "USE_EMULATOR=true"
            Set-Content ".env" $envContent -NoNewline
            Write-Host "[OK] .env configurado: USE_EMULATOR=true" -ForegroundColor $cSuccess
        } elseif ($envContent -match "USE_EMULATOR=true") {
            Write-Host "[OK] .env ja configurado para emuladores" -ForegroundColor $cSuccess
        }
    }

    Ensure-FlutterFirebaseOptions

    # --- NOVO: Ocultar banner do emulador no Web ---
    $webIndex = Join-Path (Join-Path $baseDir "frontend\app") "web\index.html"
    if (Test-Path $webIndex) {
        $html = Get-Content $webIndex -Raw
        if ($html -notmatch 'firebase-emulator-warning') {
            $cssBanner = "`n  <style>`n    .firebase-emulator-warning { display: none !important; }`n  </style>`n"
            $html = $html -replace '</head>', "${cssBanner}</head>"
            Set-Content $webIndex $html -NoNewline
            Write-Host "[OK] Banner do emulador ocultado em web/index.html" -ForegroundColor $cSuccess
        } else {
            Write-Host "[OK] Banner do emulador ja esta configurado para ser oculto" -ForegroundColor $cSuccess
        }
    }

    Set-Location $baseDir
} else {
    Write-Host "[AVISO] Pasta 'frontend\app' nao encontrada" -ForegroundColor $cWarning
}

Write-Host ""
Write-Host "========================================" -ForegroundColor $cSuccess
Write-Host "   SETUP CONCLUIDO!                     " -ForegroundColor $cSuccess
Write-Host "========================================" -ForegroundColor $cSuccess
Write-Host ""

# ============================================================
# FASE 3: INICIALIZACAO DO AMBIENTE (OPCIONAL)
# ============================================================
if (-not $javaOk) {
    Write-Host "[AVISO] Java 21+ nao detectado. Os emuladores Firebase NAO vao funcionar." -ForegroundColor $cWarning
    Write-Host "        Instale o JDK 21+ e rode o script novamente." -ForegroundColor Gray
    Write-Host ""
    Write-Host "Para iniciar manualmente (apos instalar Java 21+):" -ForegroundColor $cStep
    Write-Host "  Backend:  cd backend; npx --yes $firebaseToolsNpx emulators:start --project $projectId --only auth,functions,firestore,storage" -ForegroundColor Gray
    Write-Host "  Frontend: cd frontend\app; flutter run -d $flutterDevice --web-port $flutterWebPort" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Boa sorte com o MesclaInvest!" -ForegroundColor $cInfo
    exit 0
}

$startAll = Read-Host "Deseja iniciar o ambiente completo agora? (S/N)"
if ($startAll -ne "S" -and $startAll -ne "s") {
    Write-Host "" 
    Write-Host "Para iniciar manualmente:" -ForegroundColor $cStep
    Write-Host "  Backend:  cd backend; npx --yes $firebaseToolsNpx emulators:start --project $projectId --only auth,functions,firestore,storage" -ForegroundColor Gray
    Write-Host "  Frontend: cd frontend\app; flutter run -d $flutterDevice --web-port $flutterWebPort" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Boa sorte com o MesclaInvest!" -ForegroundColor $cInfo
    exit 0
}

Write-Host ""
Write-Host "--- FASE 3: Iniciando ambiente ---" -ForegroundColor $cWarning

# Limpar localhost antes de subir backend/frontend
Stop-LocalhostProcesses -Ports $portsToKill

# Iniciar backend/Firebase Emulators em nova janela
Write-Host "[1/4] Abrindo Backend (Firebase Emulators)..." -ForegroundColor $cStep

    $javaSetup = ""
    if (Test-Path (Join-Path $jdkLocalDir "bin\java.exe")) {
        $javaSetup = "`$env:JAVA_HOME='$jdkLocalDir'; `$env:PATH='$jdkLocalDir\bin;' + `$env:PATH;"
    }

    $backendCommand = "$javaSetup Set-Location '$backendDir'; npx --yes $firebaseToolsNpx emulators:start --project $projectId --only auth,functions,firestore,storage"
    $emulatorCmd = "powershell -NoExit -Command `"$backendCommand`""
    Start-Process cmd -ArgumentList "/c start `"MesclaInvest Backend`" $emulatorCmd"

# Aguardar portas principais dos emuladores
Write-Host "Aguardando emuladores ficarem prontos..." -ForegroundColor Gray
$ready = Wait-LocalPorts -Ports $requiredBackendPorts -TimeoutSeconds 120

Write-Host ""

if (-not $ready) {
    Write-Host "[ERRO] Timeout aguardando emuladores. Verifique a janela do Firebase." -ForegroundColor $cError
    Write-Host "        Se a janela nao abriu, inicie manualmente:" -ForegroundColor Gray
    Write-Host "        cd backend; npx --yes $firebaseToolsNpx emulators:start --project $projectId --only auth,functions,firestore,storage" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Portas esperadas: $($requiredBackendPorts -join ', ')" -ForegroundColor Gray
    Set-Location $baseDir
    exit 1
} else {
    Write-Host "[OK] Emuladores ativos!" -ForegroundColor $cSuccess

    # ============================================================
    # SEED AUTOMATICO DO BANCO DE DADOS
    # ============================================================
    Write-Host ""
    Write-Host "[2/4] Populando banco de dados com dados de teste..." -ForegroundColor $cStep

    # Os scripts de seed ficam em functions/scripts/ mas o tsconfig
    # principal so compila src/. Precisamos compilar separadamente.
    $seedOutDir = Join-Path $functionsDir "lib\scripts"
    $seedStartupsJs    = Join-Path $seedOutDir "seed-startups.js"
    $seedUsersJs       = Join-Path $seedOutDir "seed-users.js"
    $seedInvestmentsJs = Join-Path $seedOutDir "seed-investments.js"
    $seedOrderbookJs   = Join-Path $seedOutDir "seed-orderbook.js"

    # Criar tsconfig temporario para compilar os scripts de seed.
    # tsc emite .js mesmo com erros de tipo (noEmitOnError=false por padrao),
    # entao verificamos a existencia do arquivo apos compilar — alguns seeds
    # tem warnings de tipo pre-existentes que nao impedem o runtime.
    $seedTsConfig = Join-Path $functionsDir "tsconfig.seed.json"
    $seedTsConfigContent = @"
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
"@
    Set-Content $seedTsConfig $seedTsConfigContent -Encoding UTF8

    # Compilar seeds (output redirecionado: emit funciona mesmo com erros)
    Write-Host "       Compilando scripts de seed..." -ForegroundColor Gray
    Set-Location $functionsDir
    npx tsc --project tsconfig.seed.json 2>&1 | Out-Null
    Set-Location $baseDir

    # Limpar tsconfig temporario
    Remove-Item $seedTsConfig -Force -ErrorAction SilentlyContinue

    # Configurar variaveis de ambiente para emuladores
    $env:GCLOUD_PROJECT              = $projectId
    $env:FIREBASE_CONFIG             = "{`"projectId`":`"$projectId`",`"storageBucket`":`"$projectId.appspot.com`"}"
    $env:FIRESTORE_EMULATOR_HOST     = "localhost:8080"
    $env:FIREBASE_AUTH_EMULATOR_HOST = "localhost:9099"

    function Invoke-SeedScript {
        param(
            [string]$JsPath,
            [string]$Label,
            [string]$SuccessSummary
        )

        if (-not (Test-Path $JsPath)) {
            Write-Host "[AVISO] Arquivo $((Split-Path $JsPath -Leaf)) nao gerado" -ForegroundColor $cWarning
            return $false
        }

        Write-Host "       Populando $Label..." -ForegroundColor Gray
        try {
            $output = node $JsPath 2>&1 | Out-String
            if ($LASTEXITCODE -eq 0) {
                Write-Host "[OK] $Label populados com sucesso!" -ForegroundColor $cSuccess
                $created = ([regex]::Matches($output, '✓')).Count
                if ($created -gt 0 -and $SuccessSummary) {
                    Write-Host "       $created $SuccessSummary" -ForegroundColor Gray
                }
                return $true
            }
            Write-Host "[AVISO] Seed de $Label retornou erro (pode ja estar populado)" -ForegroundColor $cWarning
            $output -split "`n" | Where-Object { $_ -match 'Error|error' } | Select-Object -First 3 | ForEach-Object {
                Write-Host "       $_" -ForegroundColor Gray
            }
            return $false
        } catch {
            Write-Host "[AVISO] Falha no seed de ${Label}: $_" -ForegroundColor $cWarning
            return $false
        }
    }

    # --- Seed Startups (sempre roda) ---
    [void](Invoke-SeedScript -JsPath $seedStartupsJs -Label "startups" -SuccessSummary "startups criadas no Firestore")

    # --- Seed Users (cria 30 alunos demo com saldo R$ 10.000) ---
    [void](Invoke-SeedScript -JsPath $seedUsersJs -Label "usuarios demo" -SuccessSummary "usuarios criados no Auth + Firestore")

    # --- Seed Investments (precisa de pelo menos um usuario; seed-users garante isso) ---
    [void](Invoke-SeedScript -JsPath $seedInvestmentsJs -Label "investimentos" -SuccessSummary "investimentos registrados")

    # --- Seed Orderbook (popula livro de ofertas + 1 trade fechado por startup) ---
    # Precisa rodar APOS seed-startups (le startups do Firestore) e APOS seed-users
    # (referencia UIDs seed-user-01..30 como autores das ordens). E idempotente
    # via campo seed_tag — re-execucao apenas pula startups ja populadas.
    [void](Invoke-SeedScript -JsPath $seedOrderbookJs -Label "ordens do balcao" -SuccessSummary "ordens criadas no balcao")

    # Limpar variaveis de ambiente
    Remove-Item Env:GCLOUD_PROJECT              -ErrorAction SilentlyContinue
    Remove-Item Env:FIREBASE_CONFIG             -ErrorAction SilentlyContinue
    Remove-Item Env:FIRESTORE_EMULATOR_HOST     -ErrorAction SilentlyContinue
    Remove-Item Env:FIREBASE_AUTH_EMULATOR_HOST -ErrorAction SilentlyContinue

    Write-Host ""
    Write-Host "       Login dos usuarios demo:" -ForegroundColor $cInfo
    Write-Host "         Emails: aluno01@mescla.test ... aluno30@mescla.test" -ForegroundColor Gray
    Write-Host "         Senha:  Mescla@2026" -ForegroundColor Gray

    # Iniciar Flutter (web-server: só sobe HTTP server, sem automacao de
    # browser — evita o bug do Chrome --bwsi que falha em 35s nesse sistema)
    Write-Host ""
    Write-Host "[3/4] Iniciando Flutter ($flutterDevice)..." -ForegroundColor $cStep
    $flutterPathSetup = "`$env:PUB_CACHE='$pubCacheDir';"
    if ($flutterDir) {
        $flutterPathSetup += " `$env:PATH='$flutterDir;' + `$env:PATH;"
    }
    $flutterCmd = "powershell -NoExit -Command `"$flutterPathSetup Set-Location '$frontendDir'; flutter run -d $flutterDevice --web-port $flutterWebPort`""
    Start-Process cmd -ArgumentList "/c start `"Flutter App`" $flutterCmd"

    # Esperar o Flutter compilar e o web-server ficar listening
    Write-Host "       Aguardando Flutter compilar e subir o servidor..." -ForegroundColor Gray
    $flutterReadyDeadline = (Get-Date).AddSeconds(90)
    while ((Get-Date) -lt $flutterReadyDeadline) {
        if (Test-LocalPort -Port $flutterWebPort) { break }
        Start-Sleep -Seconds 2
    }

    # Abrir tudo no navegador padrao
    Write-Host "[4/4] Abrindo Flutter app e Firebase UI no navegador..." -ForegroundColor $cStep
    Start-Process "http://localhost:$flutterWebPort"
    Start-Sleep -Seconds 1
    Start-Process "http://localhost:4000"
}

Write-Host ""
Write-Host "========================================" -ForegroundColor $cInfo
Write-Host "   MesclaInvest rodando!                " -ForegroundColor $cInfo
Write-Host "========================================" -ForegroundColor $cInfo
Write-Host ""
Write-Host "Servicos:" -ForegroundColor $cStep
Write-Host "  Firebase UI:     http://localhost:4000" -ForegroundColor Gray
Write-Host "  Auth Emulator:   http://localhost:9099" -ForegroundColor Gray
Write-Host "  Firestore:       http://localhost:8080" -ForegroundColor Gray
Write-Host "  Functions:       http://localhost:5001" -ForegroundColor Gray
Write-Host "  Storage:         http://localhost:9199" -ForegroundColor Gray
Write-Host ""
Write-Host "Boa sorte com o MesclaInvest!" -ForegroundColor $cInfo