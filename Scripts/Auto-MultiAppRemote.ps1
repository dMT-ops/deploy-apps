# Auto-MultiAppRemote.ps1 - COM DROPBOX
# Execute com: irm "https://github.com/dMT-ops/deploy-apps/raw/main/Scripts/Auto-MultiAppRemote.ps1" | iex

# CONFIGURAÇÕES GLOBAIS
$GitHubBase = "https://github.com/dMT-ops/deploy-apps/raw/main"
$ProgramasDir = "C:\Programas"
$LogFile = "C:\MultiAppRemote.log"

# CATÁLOGO DE APLICATIVOS COM LINKS DO DROPBOX
$AppCatalog = @{
    "2xClient" = @{
        Name = "2X Client"
        SetupFile = "2xclient-x64.msi"
        DesktopName = "Instalar 2X Client.exe"
        DropboxUrl = "https://www.dropbox.com/scl/fi/e0yayjuv8anrhkcduh4eb/2xclient-x64.msi?rlkey=oh8p4z0q51bwsm4q0brvufqj3&st=f8b4niaz&raw=1"
    }
    "Java" = @{
        Name = "Java Runtime 8"
        SetupFile = "4-jre-8u231-windows-x64.exe"
        DesktopName = "Instalar Java.exe"
        DropboxUrl = "https://www.dropbox.com/scl/fi/s380dkxmblogegvapaq7a/4-jre-8u231-windows-x64.exe?rlkey=g6t99dtkh0vd6kz1frzpppsic&st=tw2yl4al&raw=1"
    }
    "Chrome" = @{
        Name = "Google Chrome"
        SetupFile = "5-ChromeSetup.exe"
        DesktopName = "Instalar Chrome.exe"
        DropboxUrl = "https://www.dropbox.com/scl/fi/1ic9uzlqx0b31o8v8x0u9/5-ChromeSetup.exe?rlkey=mqyfv5kufwlm8bj50l7qxd4nt&st=14hp98p8&raw=1"
    }
    "7Zip" = @{
        Name = "7-Zip"
        SetupFile = "7z2401-x64.exe"
        DesktopName = "Instalar 7-Zip.exe"
        DropboxUrl = "https://www.dropbox.com/scl/fi/bkcdam1nl6qdq9wq8ig2d/7z2401-x64.exe?rlkey=njlfxjg4uerqkrl0h1pcu63w4&st=e6hb0j7b&raw=1"
    }
    "AnyDesk" = @{
        Name = "AnyDesk"
        SetupFile = "AnyDesk_Diagonal.exe"
        DesktopName = "Instalar AnyDesk.exe"
        DropboxUrl = "https://www.dropbox.com/scl/fi/zsfr0hc885dl5n3csi15f/AnyDesk_Diagonal.exe?rlkey=tqer40sv7yk3z06hgzrw6mm88&st=1tgzxpk4&raw=1"
    }
    "EPSKit" = @{
        Name = "EPS Kit"
        SetupFile = "epskit_x64.exe"
        DesktopName = "Instalar EPS Kit.exe"
        DropboxUrl = "https://www.dropbox.com/scl/fi/8c9wnhb6vw3w35fx59ut4/epskit_x64.exe?rlkey=2o60nack9ulp6w7wx7egk5v97&st=sli34265&raw=1"
    }
    "FortiClient" = @{
        Name = "FortiClient VPN"
        SetupFile = "FortiClientVPN.exe"
        DesktopName = "Instalar FortiClient.exe"
        DropboxUrl = "https://www.dropbox.com/scl/fi/ntr5321fzoaxvt626sade/FortiClientVPN.exe?rlkey=qqqxhmcsqnsdaidnqpxrtddgm&st=d2wwjse3&raw=1"
    }
    "FoxitPDF" = @{
        Name = "Foxit PDF Reader"
        SetupFile = "FoxitPDFReader20241_L10N_Setup_Prom.exe"
        DesktopName = "Instalar Foxit PDF.exe"
        DropboxUrl = "https://www.dropbox.com/scl/fi/40hmpbmvxfk5wya95r31g/FoxitPDFReader20241_L10N_Setup_Prom.exe?rlkey=qi9188j0s33x4q3cla2asmkb3&st=k3s0k1uw&raw=1"
    }
    "NDDPrint" = @{
        Name = "NDD Print Agent"
        SetupFile = "nddPrintAgentSetup-x64_5.19.6.exe"
        DesktopName = "Instalar NDD Print.exe"
        DropboxUrl = "https://www.dropbox.com/scl/fi/12enj5qu61fnz09ri4fi7/nddPrintAgentSetup-x64_5.19.6.exe?rlkey=2yswe4295cuyoklpyhdx1t0jw&st=qcvlkfud&raw=1"
    }
    "Office" = @{
        Name = "Microsoft Office"
        SetupFile = "OfficeSetup.exe"
        DesktopName = "Instalar Office.exe"
        DropboxUrl = "https://www.dropbox.com/scl/fi/c8h5p2w8esubv2oagjxpd/OfficeSetup.exe?rlkey=zhennnelxp1wy9ij1ijiwh57u&st=bl2td3yo&raw=1"
    }
}

# FUNÇÃO DE LOG
function Write-Log {
    param([string]$Message)
    $timestamp = Get-Date -Format 'yyyy-MM-dd HH:mm:ss'
    "$timestamp - $Message" | Out-File $LogFile -Append
    Write-Host "$timestamp - $Message" -ForegroundColor Gray
}

# FUNÇÃO PARA EXIBIR MENU DE APLICATIVOS
function Show-AppMenu {
    Clear-Host
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host "    DEPLOY-APPS - INSTALADOR REMOTO" -ForegroundColor Cyan
    Write-Host "          FONTE: DROPBOX" -ForegroundColor Cyan
    Write-Host "===============================================" -ForegroundColor Cyan
    Write-Host ""
    Write-Host "APLICATIVOS DISPONIVEIS:" -ForegroundColor Yellow
    Write-Host ""
    
    $i = 1
    $appKeys = @()
    
    foreach ($appKey in $AppCatalog.Keys) {
        $app = $AppCatalog[$appKey]
        Write-Host "   $i. $($app.Name)" -ForegroundColor White
        $appKeys += $appKey
        $i++
    }
    
    Write-Host ""
    Write-Host "   A. TODOS os aplicativos" -ForegroundColor Green
    Write-Host ""
    
    return $appKeys
}

# FUNÇÃO PARA SELECIONAR APLICATIVOS
function Select-Applications {
    $appKeys = Show-AppMenu
    
    while ($true) {
        $choice = Read-Host "`nSelecione os aplicativos (ex: 1, 1-3, A para todos)"
        
        if ($choice -eq 'A' -or $choice -eq 'a') {
            Write-Log "Usuario selecionou: TODOS os aplicativos"
            return $AppCatalog.Keys
        }
        
        # Processar seleção múltipla
        $selectedApps = @()
        $selections = $choice -split ',' | ForEach-Object { $_.Trim() }
        
        foreach ($sel in $selections) {
            if ($sel -match '^(\d+)-(\d+)$') {
                # Range (ex: 1-3)
                $start = [int]$matches[1]
                $end = [int]$matches[2]
                for ($i = $start; $i -le $end; $i++) {
                    if ($i -ge 1 -and $i -le $appKeys.Count) {
                        $selectedApps += $appKeys[$i-1]
                    }
                }
            } elseif ($sel -match '^\d+$') {
                # Número único
                $index = [int]$sel
                if ($index -ge 1 -and $index -le $appKeys.Count) {
                    $selectedApps += $appKeys[$index-1]
                }
            }
        }
        
        $selectedApps = $selectedApps | Select-Object -Unique
        
        if ($selectedApps.Count -gt 0) {
            Write-Host "`nAPLICATIVOS SELECIONADOS:" -ForegroundColor Green
            foreach ($appKey in $selectedApps) {
                Write-Host "   • $($AppCatalog[$appKey].Name)" -ForegroundColor White
            }
            
            $confirm = Read-Host "`nConfirmar selecao? (S/N)"
            if ($confirm -match '^[Ss]$') {
                Write-Log "Aplicativos selecionados: $($selectedApps -join ', ')"
                return $selectedApps
            }
        } else {
            Write-Host "Selecao invalida. Tente novamente." -ForegroundColor Red
        }
    }
}

# FUNÇÃO PARA BAIXAR APLICATIVOS DO DROPBOX
function Download-Applications {
    param([array]$SelectedApps)
    
    Write-Host "Baixando aplicativos do Dropbox..." -ForegroundColor Yellow
    Write-Log "Iniciando download de $($SelectedApps.Count) aplicativos do Dropbox"
    
    $downloadResults = @{}
    $successCount = 0
    
    foreach ($appKey in $SelectedApps) {
        $app = $AppCatalog[$appKey]
        $localPath = "$ProgramasDir\$($app.SetupFile)"
        
        Write-Host "   $($app.Name)..." -NoNewline -ForegroundColor Gray
        
        if ($app.DropboxUrl) {
            try {
                Write-Log "Tentando download de: $($app.DropboxUrl)"
                
                # Usar WebClient para melhor compatibilidade
                $webClient = New-Object System.Net.WebClient
                $webClient.DownloadFile($app.DropboxUrl, $localPath)
                
                if (Test-Path $localPath) {
                    Write-Host " CONCLUIDO" -ForegroundColor Green
                    Write-Log "Download concluido: $($app.Name)"
                    $downloadResults[$appKey] = $true
                    $successCount++
                } else {
                    Write-Host " ERRO" -ForegroundColor Red
                    Write-Log "ERRO: Arquivo nao foi baixado - $($app.Name)"
                    $downloadResults[$appKey] = $false
                }
            } catch {
                Write-Host " ERRO" -ForegroundColor Red
                Write-Host "      Erro: $($_.Exception.Message)" -ForegroundColor Red
                Write-Log "ERRO no download: $($app.Name)"
                $downloadResults[$appKey] = $false
            }
        } else {
            Write-Host " SEM LINK" -ForegroundColor Yellow
            Write-Log "AVISO: $($app.Name) nao tem link do Dropbox configurado"
            $downloadResults[$appKey] = $false
        }
    }
    
    Write-Host ""
    Write-Host "Download concluido: $successCount/$($SelectedApps.Count) aplicativos baixados" -ForegroundColor $(if ($successCount -eq $SelectedApps.Count) { "Green" } else { "Yellow" })
    
    return $downloadResults
}

# FUNÇÃO PARA OBTER DESKTOP DO USUÁRIO
function Get-RemoteUserDesktop {
    param([string]$ComputerName)
    
    try {
        $loggedInUser = Get-WmiObject -Class Win32_ComputerSystem -ComputerName $ComputerName -ErrorAction SilentlyContinue | Select-Object -ExpandProperty UserName
        
        if ($loggedInUser) {
            $userName = $loggedInUser.Split('\')[-1]
            $userDesktopPath = "\\$ComputerName\C$\Users\$userName\Desktop"
            
            if (Test-Path $userDesktopPath) {
                Write-Log "Desktop do usuario encontrado: $userDesktopPath"
                return $userDesktopPath
            }
        }
        
        $usersPath = "\\$ComputerName\C$\Users"
        if (Test-Path $usersPath) {
            $userFolders = Get-ChildItem $usersPath -Directory -ErrorAction SilentlyContinue | Where-Object { 
                $_.Name -notin @('Public', 'Default', 'All Users', 'Administrator') -and
                (Test-Path "$usersPath\$($_.Name)\Desktop" -ErrorAction SilentlyContinue)
            }
            
            foreach ($userFolder in $userFolders) {
                $desktopPath = "$usersPath\$($userFolder.Name)\Desktop"
                if (Test-Path $desktopPath) {
                    Write-Log "Desktop encontrado para usuario: $($userFolder.Name)"
                    return $desktopPath
                }
            }
        }
        
        return $null
    } catch {
        Write-Log "ERRO ao buscar Desktop em $ComputerName"
        return $null
    }
}

# FUNÇÃO PARA TRANSFERIR APLICATIVOS PARA MÁQUINAS REMOTAS
function Transfer-AppsToRemote {
    param([string]$ComputerName, [array]$SelectedApps, [hashtable]$DownloadResults)
    
    try {
        Write-Log "Iniciando transferencia para: $ComputerName"
        
        # Criar pasta Programas na máquina remota
        $remoteProgramasDir = "\\$ComputerName\C$\Programas"
        Write-Host "      Criando pasta Programas..." -NoNewline -ForegroundColor Gray
        
        try {
            New-Item -Path $remoteProgramasDir -ItemType Directory -Force -ErrorAction Stop | Out-Null
            Write-Host " CONCLUIDO" -ForegroundColor Green
        } catch {
            Write-Host " ERRO" -ForegroundColor Red
            Write-Log "ERRO: Nao foi possivel criar pasta Programas em $ComputerName"
            return $false
        }
        
        # Copiar aplicativos para Programas
        $programasCopied = 0
        foreach ($appKey in $SelectedApps) {
            if (-not $DownloadResults[$appKey]) { continue }
            
            $app = $AppCatalog[$appKey]
            $sourcePath = "$ProgramasDir\$($app.SetupFile)"
            $destPath = "$remoteProgramasDir\$($app.SetupFile)"
            
            try {
                Copy-Item $sourcePath $destPath -Force -ErrorAction Stop
                $programasCopied++
            } catch {
                Write-Log "AVISO: Nao foi possivel copiar $($app.Name) para Programas em $ComputerName"
            }
        }
        
        # Copiar para Desktop do usuário
        Write-Host "      Copiando para Area de Trabalho..." -NoNewline -ForegroundColor Gray
        $desktopCopied = 0
        $userDesktopPath = Get-RemoteUserDesktop -ComputerName $ComputerName
        
        if ($userDesktopPath -and (Test-Path $userDesktopPath)) {
            foreach ($appKey in $SelectedApps) {
                if (-not $DownloadResults[$appKey]) { continue }
                
                $app = $AppCatalog[$appKey]
                $sourcePath = "$ProgramasDir\$($app.SetupFile)"
                $destPath = "$userDesktopPath\$($app.DesktopName)"
                
                try {
                    Copy-Item $sourcePath $destPath -Force -ErrorAction SilentlyContinue
                    if (Test-Path $destPath) {
                        $desktopCopied++
                    }
                } catch {
                    # Ignora erros individuais de cópia
                }
            }
        }
        
        # Fallback para Desktop público
        if ($desktopCopied -eq 0) {
            $publicDesktop = "\\$ComputerName\C$\Users\Public\Desktop"
            if (Test-Path $publicDesktop) {
                foreach ($appKey in $SelectedApps) {
                    if (-not $DownloadResults[$appKey]) { continue }
                    
                    $app = $AppCatalog[$appKey]
                    $sourcePath = "$ProgramasDir\$($app.SetupFile)"
                    $destPath = "$publicDesktop\$($app.DesktopName)"
                    
                    try {
                        Copy-Item $sourcePath $destPath -Force -ErrorAction SilentlyContinue
                        if (Test-Path $destPath) {
                            $desktopCopied++
                        }
                    } catch {
                        # Ignora erros individuais de cópia
                    }
                }
            }
        }
        
        if ($desktopCopied -gt 0) {
            Write-Host " CONCLUIDO ($desktopCopied apps)" -ForegroundColor Green
        } else {
            Write-Host " APENAS PROGRAMAS" -ForegroundColor Yellow
        }
        
        # Considerar sucesso se pelo menos um arquivo foi copiado para Programas
        if ($programasCopied -gt 0) {
            Write-Log "SUCESSO: $programasCopied apps transferidos para $ComputerName"
            return $true
        } else {
            Write-Log "FALHA: Nenhum app transferido para $ComputerName"
            return $false
        }
        
    } catch {
        Write-Host " ERRO" -ForegroundColor Red
        Write-Log "ERRO na transferencia para $ComputerName"
        return $false
    }
}

# FUNÇÃO MELHORADA PARA TESTAR CONEXÃO COM MÁQUINAS
function Test-MachinesConnection {
    param([array]$Computers)
    
    Write-Host "Verificando maquinas online..." -ForegroundColor Yellow
    Write-Log "Iniciando teste de conexao com $($Computers.Count) maquinas"
    
    $onlineComputers = @()
    $offlineComputers = @()
    
    $i = 0
    foreach ($computer in $Computers) {
        $computer = $computer.Trim()
        if (-not $computer) { continue }
        
        $i++
        Write-Host "   [$i/$($Computers.Count)] $computer... " -NoNewline -ForegroundColor Gray
        
        $isOnline = $false
        
        # MÉTODO 1: Test-Connection (ping)
        if (Test-Connection -ComputerName $computer -Count 1 -Quiet -ErrorAction SilentlyContinue) {
            $isOnline = $true
        }
        # MÉTODO 2: Test-WSMan (WinRM - mais confiável)
        elseif (Test-WSMan -ComputerName $computer -ErrorAction SilentlyContinue) {
            $isOnline = $true
        }
        # MÉTODO 3: Test-Path (compartilhamento administrativo)
        elseif (Test-Path "\\$computer\C$\" -ErrorAction SilentlyContinue) {
            $isOnline = $true
        }
        # MÉTODO 4: Resolução DNS + porta 445
        else {
            try {
                $ip = [System.Net.Dns]::GetHostAddresses($computer) | Select-Object -First 1
                if ($ip) {
                    # Tenta conexão TCP na porta 445 (compartilhamento de arquivos)
                    $tcpClient = New-Object System.Net.Sockets.TcpClient
                    if ($tcpClient.ConnectAsync($ip, 445).Wait(1000)) {
                        $isOnline = $true
                        $tcpClient.Close()
                    }
                }
            } catch {
                # Continua offline
            }
        }
        
        if ($isOnline) {
            Write-Host "ONLINE" -ForegroundColor Green
            $onlineComputers += $computer
            Write-Log "ONLINE: $computer"
        } else {
            Write-Host "OFFLINE" -ForegroundColor Red
            $offlineComputers += $computer
            Write-Log "OFFLINE: $computer"
        }
    }
    
    Write-Host ""
    Write-Host "Resultado do scan:" -ForegroundColor Cyan
    Write-Host "   Online: $($onlineComputers.Count)" -ForegroundColor Green
    Write-Host "   Offline: $($offlineComputers.Count)" -ForegroundColor Red
    Write-Host ""
    
    return $onlineComputers
}

# FUNÇÃO PRINCIPAL
function Main {
    try {
        # CRIAR PASTA BASE
        Write-Host "Preparando ambiente local..." -ForegroundColor Yellow
        Write-Log "Iniciando script DEPLOY-APPS com Dropbox"
        New-Item -Path $ProgramasDir -ItemType Directory -Force -ErrorAction Stop | Out-Null
        Write-Host "   Pasta criada: $ProgramasDir" -ForegroundColor Green

        # SELECIONAR APLICATIVOS
        $selectedApps = Select-Applications
        
        # BAIXAR APLICATIVOS DO DROPBOX
        Write-Host ""
        $downloadResults = Download-Applications -SelectedApps $selectedApps
        
        # VERIFICAR SE HOUVE SUCESSO NOS DOWNLOADS
        $successfulDownloads = ($downloadResults.GetEnumerator() | Where-Object { $_.Value }).Count
        if ($successfulDownloads -eq 0) {
            Write-Host "Nenhum aplicativo foi baixado com sucesso. Abortando." -ForegroundColor Red
            return
        }

        # CARREGAR MÁQUINAS DO GITHUB
        Write-Host ""
        Write-Host "Carregando lista de maquinas do GitHub..." -ForegroundColor Yellow
        try {
            $allComputers = (Invoke-WebRequest "$GitHubBase/Config/maquinas.txt").Content -split "`n" | Where-Object { $_ -and $_.Trim() }
            Write-Host "   $($allComputers.Count) maquinas encontradas no GitHub" -ForegroundColor Green
            Write-Log "Lista de maquinas carregada do GitHub: $($allComputers.Count) maquinas"
        } catch {
            Write-Host "   Erro ao carregar lista de maquinas do GitHub: $($_.Exception.Message)" -ForegroundColor Red
            throw
        }

        # TESTAR CONEXÃO COM MÁQUINAS (MELHORADA)
        $onlineComputers = Test-MachinesConnection -Computers $allComputers
        
        if ($onlineComputers.Count -eq 0) {
            Write-Host "Nenhuma maquina online encontrada. Abortando." -ForegroundColor Red
            return
        }

        # CONFIRMAR INÍCIO DA TRANSFERÊNCIA
        Write-Host ""
        Write-Host "PRONTO PARA INICIAR TRANSFERENCIA!" -ForegroundColor Cyan
        Write-Host "   Aplicativos: $successfulDownloads selecionados" -ForegroundColor White
        Write-Host "   Maquinas: $($onlineComputers.Count) online" -ForegroundColor White
        Write-Host "   Fonte: Dropbox" -ForegroundColor Blue
        Write-Host "   Repositorio: GitHub" -ForegroundColor Magenta
        Write-Host ""
        Write-Host "Os aplicativos serao copiados para:" -ForegroundColor Yellow
        Write-Host "   C:\Programas\ (pasta na maquina remota)" -ForegroundColor Gray
        Write-Host "   Area de Trabalho (como 'Instalar [NomeApp].exe')" -ForegroundColor Gray
        Write-Host "   Usuario deve executar manualmente" -ForegroundColor Cyan
        Write-Host ""
        
        $confirm = Read-Host "Iniciar transferencia? (S/N)"
        if ($confirm -notmatch '^[Ss]$') {
            Write-Host "Transferencia cancelada pelo usuario" -ForegroundColor Yellow
            return
        }

        # INICIAR TRANSFERÊNCIA
        Write-Host ""
        Write-Host "INICIANDO TRANSFERENCIA REMOTA..." -ForegroundColor Cyan
        Write-Log "Iniciando transferencia para $($onlineComputers.Count) maquinas online"
        
        $successCount = 0
        $errorCount = 0
        
        $i = 0
        foreach ($computer in $onlineComputers) {
            $i++
            Write-Host ""
            Write-Host "[$i/$($onlineComputers.Count)] $computer" -ForegroundColor Yellow
            
            $transferResult = Transfer-AppsToRemote -ComputerName $computer -SelectedApps $selectedApps -DownloadResults $downloadResults
            
            if ($transferResult) {
                Write-Host "   TRANSFERENCIA CONCLUIDA" -ForegroundColor Green
                $successCount++
            } else {
                Write-Host "   FALHA NA TRANSFERENCIA" -ForegroundColor Red
                $errorCount++
            }
        }

        # RESUMO FINAL
        Write-Host ""
        Write-Host "===============================================" -ForegroundColor Cyan
        Write-Host "           RESUMO FINAL - DEPLOY-APPS" -ForegroundColor Cyan
        Write-Host "===============================================" -ForegroundColor Cyan
        
        Write-Host "APLICATIVOS TRANSFERIDOS:" -ForegroundColor Yellow
        foreach ($appKey in $selectedApps) {
            if ($downloadResults[$appKey]) {
                $app = $AppCatalog[$appKey]
                Write-Host "   $($app.Name)" -ForegroundColor Green
            }
        }
        
        Write-Host ""
        Write-Host "TRANSFERENCIA REMOTA:" -ForegroundColor Yellow
        Write-Host "   Sucesso: $successCount" -ForegroundColor Green
        Write-Host "   Falhas: $errorCount" -ForegroundColor Red
        Write-Host "   Offline: $($allComputers.Count - $onlineComputers.Count)" -ForegroundColor Gray
        Write-Host "   Total de maquinas: $($allComputers.Count)" -ForegroundColor White
        Write-Host "   Fonte dos Apps: Dropbox" -ForegroundColor Blue
        Write-Host "   Configuracao: GitHub" -ForegroundColor Magenta

        Write-Host ""
        Write-Host "PROXIMOS PASSOS:" -ForegroundColor Cyan
        Write-Host "   1. Os instaladores estao na Area de Trabalho das maquinas" -ForegroundColor White
        Write-Host "   2. Usuarios devem executar os arquivos 'Instalar [NomeApp].exe'" -ForegroundColor White
        Write-Host "   3. A instalacao e silenciosa e automatica" -ForegroundColor White
        Write-Host ""
        Write-Host "Log detalhado: $LogFile" -ForegroundColor Gray

    } catch {
        Write-Host ""
        Write-Host "ERRO CRITICO: $($_.Exception.Message)" -ForegroundColor Red
        Write-Log "ERRO CRITICO: $($_.Exception.Message)"
    }
}

# EXECUTAR SCRIPT PRINCIPAL
Main

Write-Host ""
Write-Host "Pressione Enter para finalizar..." -ForegroundColor Yellow
Read-Host
