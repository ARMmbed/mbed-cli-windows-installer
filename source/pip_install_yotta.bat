:: Set python\scripts variable because the environment hasnt been updated since python install.
set YOTTA_PATH=;%1;%1\gcc\bin;%1\python;%1\python\Scripts;%1\cmake\bin;
setx YOTTA_PATH %YOTTA_PATH%
set PATH=%PATH%;%YOTTA_PATH%
::pip install -U pip
pip install -U yotta
echo %PATH%
::PAUSE
