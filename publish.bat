setlocal

set PUBLISH_HOME=V:\checkout\perl\modules\publish
set SOURCE_DIR=V:\checkout\perl\modules\Class-Maker
set RELEASE_DIR=%SOURCE_DIR%\PUBLISHED

rmdir /Q /S %RELEASE_DIR%

publish.pl --homedir %PUBLISH_HOME% --project Class-Maker --targetdir %RELEASE_DIR% --sourcedir %SOURCE_DIR%

tree %TMP_PUBLISH%

del "pod2*"
