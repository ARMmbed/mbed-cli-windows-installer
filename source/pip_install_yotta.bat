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
set YOTTA_PATH=;%1;%1\gcc\bin;%1\python;%1\python\Scripts;%1\cmake\bin;%1\git-scm\bin;%1\mercurial\bin;
setx YOTTA_PATH %YOTTA_PATH%
set PATH=%YOTTA_PATH%;%PATH%
::pip install -U pip
%1\python\pip.exe install -U yotta
echo %PATH%
::PAUSE
