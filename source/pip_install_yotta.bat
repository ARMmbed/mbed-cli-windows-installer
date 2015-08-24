:: Set python\scripts variable because the environment hasnt been updated since python install.
set PATH=%PATH%;%YOTTA_PATH%
echo %PATH%
pip install -U pip
pip install -U yotta
echo %PATH%
PAUSE
