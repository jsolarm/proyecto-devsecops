pipeline {
    agent any

    options {
        timeout(time: 60, unit: 'MINUTES')
        buildDiscarder(logRotator(numToKeepStr: '10'))
    }

    environment {
        // Ajuste estas rutas a su equipo
        PYTHON   = 'C:\\Users\\Docencia\\AppData\\Local\\Python\\bin\\python.exe'
        ODC_DATA = 'C:\\tools\\odc-data'
        ZAP_DIR  = 'C:\\Program Files\\ZAP\\Zed Attack Proxy'
        APP_URL  = 'http://localhost:8080/hello?name=test'
        // Evita que Jenkins elimine la aplicacion desplegada
        JENKINS_NODE_COOKIE = 'dontKillMe'
    }

    stages {
        stage('Build') {
            steps {
                bat '''
                    "%PYTHON%" -m venv venv || exit /b 1
                    venv\\Scripts\\python.exe -m pip install ^
                        --disable-pip-version-check ^
                        -r requirements.txt pytest || exit /b 1
                '''
            }
        }

        stage('Test') {
            steps {
                bat '''
                    venv\\Scripts\\python.exe -m pytest -v ^
                        --junitxml=reports\\junit.xml
                '''
            }
            post {
                always {
                    junit allowEmptyResults: true,
                          testResults: 'reports/junit.xml'
                }
            }
        }

        stage('Analyze') {
            steps {
                script {
                    def scannerHome = tool 'SonarScanner'
                    def scanner = "${scannerHome}\\bin\\sonar-scanner.bat"
                    withSonarQubeEnv('SonarQube') {
                        bat "\"${scanner}\" || exit /b 1"
                    }
                }
            }
        }

        stage('Security Test - Dependency-Check') {
    steps {
        script {
            // Unificamos todo en una sola cadena limpia sin arreglos complejos
            // Nota: Para simplificar, generamos únicamente el reporte XML que Jenkins necesita leer
            def odcArgs = '--scan "venv/Lib/site-packages" --format XML --data "C:/tools/odc-data" --autoUpdate'
            
            dependencyCheck additionalArguments: odcArgs,
                            odcInstallation: 'Dependency-Check'
        }
        dependencyCheckPublisher pattern: '**/dependency-check-report.xml'
    }
}

        stage('Deploy') {
            steps {
                bat '''
                    powershell -NoProfile -ExecutionPolicy Bypass ^
                        -File scripts\\start_app.ps1 || exit /b 1
                '''
            }
        }

        stage('Security Test - ZAP') {
            steps {
                timeout(time: 20, unit: 'MINUTES') {
                    bat '''
                        if not exist C:\\zap-home mkdir C:\\zap-home
                        cd /d "%ZAP_DIR%"
                        call zap.bat -cmd -port 8090 -dir C:\\zap-home ^
                            -quickurl "%APP_URL%" ^
                            -quickout "%WORKSPACE%\\zap-report.html" ^
                            -quickprogress || exit /b 1
                    '''
                }
            }
        }
    }

    post {
        always {
            bat '''
                powershell -NoProfile -ExecutionPolicy Bypass ^
                    -File scripts\\stop_app.ps1
            '''
            archiveArtifacts allowEmptyArchive: true,
                artifacts: 'dependency-check-report.*, zap-report.html, *.log'
        }
    }
}
