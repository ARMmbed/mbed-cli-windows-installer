:: Copyright (c) 2015 ARM Limited. All rights reserved.
::
:: SPDX-License-Identifier: Apache-2.0
::
:: Licensed under the Apache License, Version 2.0 (the License); you may
:: not use this file except in compliance with the License.
:: You may obtain a copy of the License at
::
:: http://www.apache.org/licenses/LICENSE-2.0
::
:: Unless required by applicable law or agreed to in writing, software
:: distributed under the License is distributed on an AS IS BASIS, WITHOUT
:: WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
:: See the License for the specific language governing permissions and
:: limitations under the License.
::
:: Set python\scripts variable because the environment hasnt been updated since python install.
set YOTTA_PATH=;%1;%1\gcc\bin;%1\python;%1\python\Tools\Scripts;%1\python\Scripts;%1\cmake\bin;%1\git-scm\bin;%1\mercurial\bin;
setx YOTTA_PATH %YOTTA_PATH%
set PATH=%YOTTA_PATH%;%PATH%
setx YOTTA_INSTALL_LOCATION %1

:: install virtual environment
pip install virtualenv 

:: create virtual environment in \yotta\workspace to sandbox yottta from system.
cd %1
virtualenv workspace
cmd /K "%1\workspace\Scripts\activate & pip install -U pip & pip install -U yotta & exit"
::PAUSE
