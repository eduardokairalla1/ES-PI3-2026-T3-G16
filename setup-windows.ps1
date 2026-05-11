# --- SETUP MESCLAINVEST PARA WINDOWS ---
# Execute com: .\setup-windows.ps1 (na raiz do projeto)
#
# Este script:
#   1. Verifica ferramentas necessarias (Node, Flutter, Java 21+, Chrome/Edge)
#   2. Instala dependencias (npm install, flutter pub get, firebase-tools)
#   3. Configura o .env do frontend para emuladores
#   4. (Opcional) Inicia o ambiente completo (emuladores + Flutter)

# ============================================================
# CONFIGURACAO INICIAL
# ============================================================
#Comando copiar: Set-ExecutionPolicy -ExecutionPolicy RemoteSigned -Scope CurrentUser
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

Write-Host ""
Write-Host "========================================" -ForegroundColor $cInfo
Write-Host "   SETUP MESCLAINVEST - WINDOWS         " -ForegroundColor $cInfo
Write-Host "========================================" -ForegroundColor $cInfo
Write-Host "Pasta: $baseDir" -ForegroundColor Gray
Write-Host ""

# ============================================================
# FASE 1: VERIFICACAO DE FERRAMENTAS
# ============================================================
Write-Host "--- FASE 1: Verificando ferramentas ---" -ForegroundColor $cWarning

# --- Node.js ---
if (-not (Get-Command node -ErrorAction SilentlyContinue)) {
    Write-Host "[ERRO] Node.js nao encontrado." -ForegroundColor $cError
    Write-Host "       Baixe em: https://nodejs.org/" -ForegroundColor Gray
    Write-Host "       Depois de instalar, feche e reabra o terminal." -ForegroundColor Gray
    exit 1
}
$nodeVer = node -v
Write-Host "[OK] Node.js $nodeVer" -ForegroundColor $cSuccess

# --- npm ---
if (-not (Get-Command npm -ErrorAction SilentlyContinue)) {
    Write-Host "[ERRO] npm nao encontrado (deveria vir com o Node.js)." -ForegroundColor $cError
    Write-Host "       Reinstale o Node.js: https://nodejs.org/" -ForegroundColor Gray
    exit 1
}
Write-Host "[OK] npm $(npm -v)" -ForegroundColor $cSuccess

# --- Flutter ---
if (-not (Get-Command flutter -ErrorAction SilentlyContinue)) {
    Write-Host "[ERRO] Flutter nao encontrado." -ForegroundColor $cError
    Write-Host "       Baixe em: https://docs.flutter.dev/get-started/install" -ForegroundColor Gray
    Write-Host "       Adicione ao PATH e reabra o terminal." -ForegroundColor Gray
    exit 1
}
Write-Host "[OK] Flutter detectado" -ForegroundColor $cSuccess

# --- Java (precisa ser 21+ para Firebase Emulators) ---
$javaOk = $false
$jdkLocalDir = Join-Path $baseDir ".tools\jdk-21"

# Funcao auxiliar para verificar versao do Java
function Test-JavaVersion {
    param([string]$JavaCmd)
    try {
        $output = & $JavaCmd -version 2>&1 | Out-String
        # Formato moderno: "21.0.2" / Formato legado: "1.8.0_xxx" (versao real = 8)
        if ($output -match '"(\d+)\.(\d+)') {
            $major = [int]$Matches[1]
            $minor = [int]$Matches[2]
            # Formato legado "1.x" -> versao real eh o minor
            if ($major -eq 1) { return $minor } else { return $major }
        }
    } catch { }
    return 0
}

# 1) Checar se ja temos JDK local instalado pelo setup
if (Test-Path (Join-Path $jdkLocalDir "bin\java.exe")) {
    $env:JAVA_HOME = $jdkLocalDir
    $env:PATH = "$jdkLocalDir\bin;$env:PATH"
    $localVer = Test-JavaVersion -JavaCmd (Join-Path $jdkLocalDir "bin\java.exe")
    if ($localVer -ge 21) {
        Write-Host "[OK] JDK $localVer local detectado (.tools/jdk-21)" -ForegroundColor $cSuccess
        $javaOk = $true
    }
}

# 2) Checar Java do sistema
if (-not $javaOk -and (Get-Command java -ErrorAction SilentlyContinue)) {
    $sysVer = Test-JavaVersion -JavaCmd "java"
    if ($sysVer -ge 21) {
        Write-Host "[OK] Java $sysVer do sistema detectado (>= 21)" -ForegroundColor $cSuccess
        $javaOk = $true
    } else {
        Write-Host "[AVISO] Java $sysVer detectado no sistema, mas emuladores precisam de 21+." -ForegroundColor $cWarning
    }
}

# 3) Se nao tem Java 21+, baixar automaticamente
if (-not $javaOk) {
    Write-Host ""
    Write-Host "========================================" -ForegroundColor $cWarning
    Write-Host "  INSTALACAO AUTOMATICA DO JDK 21       " -ForegroundColor $cWarning
    Write-Host "========================================" -ForegroundColor $cWarning
    Write-Host ""
    Write-Host "Firebase Emulators precisam de Java 21+." -ForegroundColor $cStep
    Write-Host "Vou baixar o Eclipse Temurin JDK 21 (Adoptium) automaticamente." -ForegroundColor $cStep
    Write-Host "O JDK sera instalado localmente em: $jdkLocalDir" -ForegroundColor Gray
    Write-Host ""

    # Detectar arquitetura
    $arch = if ([Environment]::Is64BitOperatingSystem) { "x64" } else { "x32" }

    # URL da API Adoptium para pegar o ultimo JDK 21 LTS
    $adoptiumApi = "https://api.adoptium.net/v3/assets/latest/21/hotspot?architecture=$arch&image_type=jdk&os=windows&vendor=eclipse"

    Write-Host "[1/4] Consultando Adoptium API para JDK 21 ($arch)..." -ForegroundColor $cStep
    try {
        $response = Invoke-RestMethod -Uri $adoptiumApi -ErrorAction Stop
        $asset = $response | Where-Object { $_.binary.package.name -like "*.zip" } | Select-Object -First 1

        if (-not $asset) {
            Write-Host "[ERRO] Nao foi possivel encontrar JDK 21 para download." -ForegroundColor $cError
            Write-Host "       Baixe manualmente em: https://adoptium.net/" -ForegroundColor Gray
        } else {
            $downloadUrl = $asset.binary.package.link
            $fileName = $asset.binary.package.name
            $fileSize = [math]::Round($asset.binary.package.size / 1MB, 1)
            $jdkVersion = $asset.version.semver

            Write-Host "[OK] Encontrado: Eclipse Temurin $jdkVersion" -ForegroundColor $cSuccess
            Write-Host "     Tamanho: ${fileSize} MB" -ForegroundColor Gray

            # Criar pasta .tools
            $toolsDir = Join-Path $baseDir ".tools"
            if (-not (Test-Path $toolsDir)) {
                New-Item -ItemType Directory -Path $toolsDir -Force | Out-Null
            }

            $zipPath = Join-Path $toolsDir $fileName

            # Download
            Write-Host "[2/4] Baixando JDK 21 (pode demorar ~2min)..." -ForegroundColor $cStep
            $ProgressPreference = 'SilentlyContinue'  # Acelera o download
            Invoke-WebRequest -Uri $downloadUrl -OutFile $zipPath -ErrorAction Stop
            $ProgressPreference = 'Continue'
            Write-Host "[OK] Download concluido: $fileName" -ForegroundColor $cSuccess

            # Extrair
            Write-Host "[3/4] Extraindo JDK 21..." -ForegroundColor $cStep
            $extractDir = Join-Path $toolsDir "jdk-extract-temp"
            if (Test-Path $extractDir) { Remove-Item $extractDir -Recurse -Force }
            Expand-Archive -Path $zipPath -DestinationPath $extractDir -Force

            # Encontrar a pasta raiz do JDK dentro do ZIP
            $jdkExtracted = Get-ChildItem -Path $extractDir -Directory | Select-Object -First 1

            if (-not $jdkExtracted) {
                Write-Host "[ERRO] Falha ao extrair JDK. Conteudo inesperado no ZIP." -ForegroundColor $cError
            } else {
                # Mover para o destino final
                if (Test-Path $jdkLocalDir) { Remove-Item $jdkLocalDir -Recurse -Force }
                Move-Item -Path $jdkExtracted.FullName -Destination $jdkLocalDir -Force

                # Limpar temporarios
                Remove-Item $extractDir -Recurse -Force -ErrorAction SilentlyContinue
                Remove-Item $zipPath -Force -ErrorAction SilentlyContinue

                # Configurar JAVA_HOME e PATH para esta sessao
                $env:JAVA_HOME = $jdkLocalDir
                $env:PATH = "$jdkLocalDir\bin;$env:PATH"

                Write-Host "[4/4] Verificando instalacao..." -ForegroundColor $cStep
                $installedVer = Test-JavaVersion -JavaCmd (Join-Path $jdkLocalDir "bin\java.exe")

                if ($installedVer -ge 21) {
                    Write-Host ""
                    Write-Host "[OK] JDK $installedVer instalado com sucesso!" -ForegroundColor $cSuccess
                    Write-Host "     JAVA_HOME = $jdkLocalDir" -ForegroundColor Gray
                    Write-Host ""
                    $javaOk = $true

                    # Adicionar .tools ao .gitignore se nao estiver la
                    $gitignorePath = Join-Path $baseDir ".gitignore"
                    if (Test-Path $gitignorePath) {
                        $gitignoreContent = Get-Content $gitignorePath -Raw
                        if ($gitignoreContent -notmatch '\.tools') {
                            Add-Content $gitignorePath "`n# JDK local instalado pelo setup`n.tools/"
                            Write-Host "[OK] .tools/ adicionado ao .gitignore" -ForegroundColor $cSuccess
                        }
                    }
                } else {
                    Write-Host "[ERRO] Instalacao falhou. Java nao responde corretamente." -ForegroundColor $cError
                }
            }
        }
    } catch {
        Write-Host "[ERRO] Falha no download do JDK: $_" -ForegroundColor $cError
        Write-Host "       Verifique sua conexao com a internet." -ForegroundColor Gray
        Write-Host "       Ou baixe manualmente em: https://adoptium.net/" -ForegroundColor Gray
    }
}

# --- Chrome / Edge ---
$chromeExists = (Test-Path "C:\Program Files\Google\Chrome\Application\chrome.exe") -or
                (Test-Path "C:\Program Files (x86)\Google\Chrome\Application\chrome.exe")
if ($chromeExists) {
    Write-Host "[OK] Chrome detectado" -ForegroundColor $cSuccess
    $flutterDevice = "chrome"
} else {
    Write-Host "[OK] Chrome nao encontrado, usaremos Edge" -ForegroundColor $cWarning
    $flutterDevice = "edge"
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

Set-Location $backendDir
Write-Host "[Backend] npm install..." -ForegroundColor $cStep
npm install
if ($LASTEXITCODE -ne 0) {
    Write-Host "[ERRO] Falha ao instalar dependencias do backend." -ForegroundColor $cError
    Set-Location $baseDir
    exit 1
}
Write-Host "[OK] Backend dependencias instaladas" -ForegroundColor $cSuccess

# --- Firebase Tools (instalacao local no backend) ---
Write-Host "[Backend] Instalando firebase-tools localmente..." -ForegroundColor $cStep
npm install --save-dev firebase-tools
if ($LASTEXITCODE -ne 0) {
    Write-Host "[AVISO] Falha ao instalar firebase-tools localmente. Tentando via npx..." -ForegroundColor $cWarning
} else {
    Write-Host "[OK] firebase-tools instalado localmente" -ForegroundColor $cSuccess
}

# Verificar se firebase-tools funciona
$fbVer = npx firebase-tools --version 2>$null
if ($LASTEXITCODE -eq 0 -and $fbVer) {
    Write-Host "[OK] firebase-tools $fbVer (via npx)" -ForegroundColor $cSuccess
} else {
    Write-Host "[AVISO] firebase-tools nao respondeu. Baixando via npx..." -ForegroundColor $cWarning
    npx -y firebase-tools --version
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERRO] Nao foi possivel instalar firebase-tools." -ForegroundColor $cError
        Write-Host "       Tente manualmente: npm install -g firebase-tools" -ForegroundColor Gray
    }
}

# --- Functions ---
if (Test-Path $functionsDir) {
    Set-Location $functionsDir
    Write-Host "[Functions] npm install..." -ForegroundColor $cStep
    npm install
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[ERRO] Falha ao instalar dependencias do functions." -ForegroundColor $cError
        Set-Location $baseDir
        exit 1
    }

    Write-Host "[Functions] Compilando TypeScript (npm run build)..." -ForegroundColor $cStep
    npm run build
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[AVISO] Compilacao do TypeScript falhou. Verifique erros acima." -ForegroundColor $cWarning
    } else {
        Write-Host "[OK] Functions compiladas" -ForegroundColor $cSuccess
    }
} else {
    Write-Host "[AVISO] Pasta 'functions' nao encontrada em $backendDir" -ForegroundColor $cWarning
}

Set-Location $baseDir

# --- Frontend ---
if (Test-Path $frontendDir) {
    Set-Location $frontendDir
    Write-Host "[Frontend] flutter pub get..." -ForegroundColor $cStep
    flutter pub get
    if ($LASTEXITCODE -ne 0) {
        Write-Host "[AVISO] flutter pub get falhou. Verifique erros acima." -ForegroundColor $cWarning
    } else {
        Write-Host "[OK] Frontend dependencias instaladas" -ForegroundColor $cSuccess
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
    Write-Host "  Backend:  cd backend; npx firebase-tools emulators:start" -ForegroundColor Gray
    Write-Host "  Frontend: cd frontend\app; flutter run -d $flutterDevice" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Boa sorte com o MesclaInvest!" -ForegroundColor $cInfo
    exit 0
}

$startAll = Read-Host "Deseja iniciar o ambiente completo agora? (S/N)"
if ($startAll -ne "S" -and $startAll -ne "s") {
    Write-Host "" 
    Write-Host "Para iniciar manualmente:" -ForegroundColor $cStep
    Write-Host "  Backend:  cd backend; npx firebase-tools emulators:start" -ForegroundColor Gray
    Write-Host "  Frontend: cd frontend\app; flutter run -d $flutterDevice" -ForegroundColor Gray
    Write-Host ""
    Write-Host "Boa sorte com o MesclaInvest!" -ForegroundColor $cInfo
    exit 0
}

Write-Host ""
Write-Host "--- FASE 3: Iniciando ambiente ---" -ForegroundColor $cWarning

# Iniciar Firebase Emulators em nova janela
Write-Host "[1/3] Abrindo Firebase Emulators..." -ForegroundColor $cStep
$emulatorCmd = "powershell -NoExit -Command `"Set-Location '$backendDir'; npx firebase-tools emulators:start`""
Start-Process cmd -ArgumentList "/c start `"Firebase Emulators`" $emulatorCmd"

# Aguardar porta 8080 (Firestore)
Write-Host "Aguardando emuladores ficarem prontos..." -ForegroundColor Gray
$maxWait = 120
$elapsed = 0
$ready = $false

while ($elapsed -lt $maxWait) {
    try {
        $tcp = New-Object System.Net.Sockets.TcpClient
        $tcp.Connect("localhost", 8080)
        $tcp.Close()
        $ready = $true
        break
    } catch { }
    Write-Host "." -NoNewline
    Start-Sleep -Seconds 3
    $elapsed += 3
}

Write-Host ""

if (-not $ready) {
    Write-Host "[AVISO] Timeout (${maxWait}s). Verifique a janela do Firebase." -ForegroundColor $cWarning
    Write-Host "        Se a janela nao abriu, inicie manualmente:" -ForegroundColor Gray
    Write-Host "        cd backend; npx firebase-tools emulators:start" -ForegroundColor Gray
} else {
    Write-Host "[OK] Emuladores ativos!" -ForegroundColor $cSuccess

    # ============================================================
    # SEED AUTOMATICO DO BANCO DE DADOS
    # ============================================================
    Write-Host ""
    Write-Host "[2/4] Populando banco de dados com dados de teste..." -ForegroundColor $cStep

    # Os scripts de seed ficam em functions/scripts/ mas o tsconfig
    # principal so compila src/. Precisamos compilar separadamente.
    $seedStartupsTs = Join-Path $functionsDir "scripts\seed-startups.ts"
    $seedInvestmentsTs = Join-Path $functionsDir "scripts\seed-investments.ts"
    $seedOutDir = Join-Path $functionsDir "lib\scripts"

    # Criar tsconfig temporario para compilar os scripts de seed
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
    "skipLibCheck": true
  },
  "include": [
    "scripts/**/*.ts",
    "src/**/*.ts"
  ]
}
"@
    Set-Content $seedTsConfig $seedTsConfigContent -Encoding UTF8

    # Compilar seeds
    Write-Host "       Compilando scripts de seed..." -ForegroundColor Gray
    Set-Location $functionsDir
    npx tsc --project tsconfig.seed.json 2>$null
    $seedCompileOk = $LASTEXITCODE -eq 0
    Set-Location $baseDir

    # Limpar tsconfig temporario
    Remove-Item $seedTsConfig -Force -ErrorAction SilentlyContinue

    if (-not $seedCompileOk) {
        Write-Host "[AVISO] Compilacao dos seeds falhou. Tentando metodo alternativo..." -ForegroundColor $cWarning
        # Fallback: compilar cada arquivo individualmente
        Set-Location $functionsDir
        npx tsc --esModuleInterop --module NodeNext --moduleResolution nodenext --target es2022 --outDir lib --rootDir . --skipLibCheck scripts/seed-startups.ts 2>$null
        $seedCompileOk = $LASTEXITCODE -eq 0
        Set-Location $baseDir
    }

    if ($seedCompileOk) {
        $seedStartupsJs = Join-Path $seedOutDir "seed-startups.js"
        $seedInvestmentsJs = Join-Path $seedOutDir "seed-investments.js"

        # Configurar variavel de ambiente para emuladores
        $env:FIRESTORE_EMULATOR_HOST = "localhost:8080"
        $env:FIREBASE_AUTH_EMULATOR_HOST = "localhost:9099"

        # --- Seed Startups (sempre roda) ---
        if (Test-Path $seedStartupsJs) {
            Write-Host "       Populando startups..." -ForegroundColor Gray
            try {
                $seedOutput = node $seedStartupsJs 2>&1 | Out-String
                if ($LASTEXITCODE -eq 0) {
                    Write-Host "[OK] Startups populadas com sucesso!" -ForegroundColor $cSuccess
                    # Mostrar resumo
                    $created = ([regex]::Matches($seedOutput, '✓')).Count
                    if ($created -gt 0) {
                        Write-Host "       $created startups criadas no Firestore" -ForegroundColor Gray
                    }
                } else {
                    Write-Host "[AVISO] Seed de startups retornou erro (pode ja estar populado)" -ForegroundColor $cWarning
                }
            } catch {
                Write-Host "[AVISO] Falha no seed de startups: $_" -ForegroundColor $cWarning
            }
        } else {
            Write-Host "[AVISO] Arquivo seed-startups.js nao gerado" -ForegroundColor $cWarning
        }

        # --- Seed Investments (precisa de usuario registrado) ---
        if (Test-Path $seedInvestmentsJs) {
            Write-Host ""
            Write-Host "       NOTA: O seed de investments precisa de um usuario" -ForegroundColor Gray
            Write-Host "       registrado no Auth Emulator. Para popular investments:" -ForegroundColor Gray
            Write-Host "       1. Abra o app e crie uma conta" -ForegroundColor Gray
            Write-Host "       2. Rode: cd backend\functions; node lib\scripts\seed-investments.js" -ForegroundColor Gray
        }

        # Limpar variaveis de ambiente
        Remove-Item Env:FIRESTORE_EMULATOR_HOST -ErrorAction SilentlyContinue
        Remove-Item Env:FIREBASE_AUTH_EMULATOR_HOST -ErrorAction SilentlyContinue
    } else {
        Write-Host "[AVISO] Nao foi possivel compilar os scripts de seed." -ForegroundColor $cWarning
        Write-Host "        Verifique erros de TypeScript em functions/scripts/" -ForegroundColor Gray
    }

    # Abrir Firebase UI
    Write-Host ""
    Write-Host "[3/4] Abrindo Firebase UI no navegador..." -ForegroundColor $cStep
    Start-Process "http://localhost:4000"

    # Iniciar Flutter em nova janela
    Write-Host "[4/4] Iniciando Flutter ($flutterDevice)..." -ForegroundColor $cStep
    $flutterCmd = "powershell -NoExit -Command `"Set-Location '$frontendDir'; flutter run -d $flutterDevice`""
    Start-Process cmd -ArgumentList "/c start `"Flutter App`" $flutterCmd"
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