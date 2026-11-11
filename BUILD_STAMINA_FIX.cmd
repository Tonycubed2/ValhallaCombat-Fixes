@echo off
setlocal
cd /d "%~dp0"
where cmake >nul 2>nul
if errorlevel 1 (
  echo Run this from the VS 2022 x64 Native Tools Command Prompt with CMake installed.
  exit /b 1
)
if not defined CommonLibSSEPath_NG (
  echo Set CommonLibSSEPath_NG to your existing complete CommonLibSSE-NG source folder.
  exit /b 1
)
if not defined VCPKG_ROOT (
  echo Set VCPKG_ROOT to your existing vcpkg folder.
  exit /b 1
)
if not defined CompiledPluginsPath set "CompiledPluginsPath=%CD%\stamina-fix-package"
cmake --preset vs2022-windows -B build-stamina-fix -DCOPY_OUTPUT=OFF
if errorlevel 1 exit /b 1
cmake --build build-stamina-fix --config Release --target ValhallaCombat --clean-first
if errorlevel 1 exit /b 1
if not exist "build-stamina-fix\src\Release\ValhallaCombat.dll" (
  echo Expected DLL not found. Check the build output before packaging.
  exit /b 1
)
if not exist "build-stamina-fix\src\Release\ValhallaCombat.pdb" (
  echo Expected PDB not found. Do not distribute a mismatched old PDB.
  exit /b 1
)
if not exist "stamina-fix-package\Data\SKSE\Plugins" mkdir "stamina-fix-package\Data\SKSE\Plugins"
copy /y "build-stamina-fix\src\Release\ValhallaCombat.dll" "stamina-fix-package\Data\SKSE\Plugins\valhallaCombat.dll" >nul
if errorlevel 1 exit /b 1
copy /y "build-stamina-fix\src\Release\ValhallaCombat.pdb" "stamina-fix-package\Data\SKSE\Plugins\valhallaCombat.pdb" >nul
if errorlevel 1 exit /b 1
powershell -NoProfile -Command "$ErrorActionPreference='Stop'; Get-FileHash -Algorithm SHA256 -LiteralPath 'stamina-fix-package\Data\SKSE\Plugins\valhallaCombat.dll' | Format-List | Out-File -Encoding ascii 'stamina-fix-package\DLL_SHA256.txt'; Compress-Archive -Path 'stamina-fix-package\Data' -DestinationPath 'ValhallaCombat_StaminaFix_DLL.zip' -Force"
if errorlevel 1 exit /b 1
echo Built and packaged: ValhallaCombat_StaminaFix_DLL.zip
echo Log marker: AVOWNER_RTTI_FIX_20261006
echo Install the package as an MO2 override and verify the winning DLL.
endlocal
