/*
_____________________________________________________________________________

                       Word Functions Header v2.6
_____________________________________________________________________________

 2004 Shengalts Aleksander (Shengalts@mail.ru)

 Copy "WordFunc.nsh" to NSIS include directory
 Usually "C:\Program Files\NSIS\Include"

 Usage in script:
 1. !include "WordFunc.nsh"
 2. !insertmacro WordFunction
 3. [Section|Function]
      ${WordFunction} "Param1" "Param2" "..." $var
    [SectionEnd|FunctionEnd]


 WordFunction=[WordFind|WordFind2X|WordFind3X|WordReplace|WordAdd|WordInsert|
               StrFilter|ClbSet|ClbGet]

 un.WordFunction=[un.WordFind|un.WordFind2X|un.WordFind3X|un.WordReplace|
                  un.WordAdd|un.WordInsert|un.StrFilter|un.ClbSet|un.ClbGet]


______________________________________________________________________________

                            WordFind v2.0
______________________________________________________________________________

2004 Shengalts Aleksander (Shengalts@mail.ru)


Multi-features string function.


Word is text between delimiter, start and end of a string.

Strings:
"[word+1][delimiter][word+2][delimiter][word+3]..."
"[delimiter][word+1][delimiter][word+2][delimiter]..."
"[delimiter][delimiter][word+1][delimiter][delimiter][delimiter]..."
"...[word-3][delimiter][word-2][delimiter][word-1]"
"...[delimiter][word-2][delimiter][word-1][delimiter]"
"...[delimiter][delimiter][word-1][delimiter][delimiter][delimiter]"

Syntax: 

${WordFind} "[string]" "[delimiter]" "[E][options]" $var

"[string]"         ;[string]
                   ;  input string
"[delimiter]"      ;[delimiter]
                   ;  one or several symbols
"[E][options]"     ;[options]
                   ;  +number   : word number from start
                   ;  -number   : word number from end
                   ;  +number}  : delimiter number from start
                   ;              all space after this
                   ;              delimiter to output
                   ;  +number{  : delimiter number from start
                   ;              all space before this
                   ;              delimiter to output
                   ;  +number}} : word number from start
                   ;              all space after this word
                   ;              to output
                   ;  +number{{ : word number from start
                   ;              all space before this word
                   ;              to output
                   ;  +number{} : word number from start
                   ;              all space before and after
                   ;              this word (word exclude)
                   ;  +number*} : word number from start
                   ;              all space after this
                   ;              word to output with word
                   ;  +number{* : word number from start
                   ;              all space before this
                   ;              word to output with word
                   ;  #         : sum of words to output
                   ;  *         : sum of delimiters to output
                   ;  /word     : number of word to output
                   ;
                   ;[E]
                   ;  with errorlevel output
                   ;  IfErrors:
                   ;     $var=1  delimiter not found
                   ;     $var=2  no such word number
                   ;     $var=3  syntax error (Use: +1,-1},#,*,/word,...)
                   ;[]
                   ;  no errorlevel output (default)
                   ;  If some errors found then (result=input string)
                   ;
$var               ;output (result)

Note:
+number faster then -number
Accepted numbers 1,01,001,...


Example (Find word by number):
Section
	${WordFind} "C:\io.sys C:\Program Files C:\WINDOWS" " C:\" "-02" $R0
	; $R0 now contain: "Program Files"
SectionEnd

Example (Delimiter exclude):
Section
	${WordFind} "C:\io.sys C:\logo.sys C:\WINDOWS" "sys" "-2}" $R0
	; $R0 now contain: " C:\logo.sys C:\WINDOWS"
SectionEnd

Example (Sum of words):
Section
	${WordFind} "C:\io.sys C:\logo.sys C:\WINDOWS" " C:\" "#" $R0
	; $R0 now contain: "3"
SectionEnd

Example (Sum of delimiters):
Section
	${WordFind} "C:\io.sys C:\logo.sys C:\WINDOWS" "sys" "*" $R0
	; $R0 now contain: "2"
SectionEnd

Example (Find word number):
Section
	${WordFind} "C:\io.sys C:\Program Files C:\WINDOWS" " " "/Files" $R0
	; $R0 now contain: "3"
SectionEnd

Example ( }} ):
Section
	${WordFind} "C:\io.sys C:\logo.sys C:\WINDOWS" " " "+2}}" $R0
	; $R0 now contain: " C:\WINDOWS"
SectionEnd

Example ( {} ):
Section
	${WordFind} "C:\io.sys C:\logo.sys C:\WINDOWS" " " "+2{}" $R0
	; $R0 now contain: "C:\io.sys C:\WINDOWS"
SectionEnd

Example ( *} ):
Section
	${WordFind} "C:\io.sys C:\logo.sys C:\WINDOWS" " " "+2*}" $R0
	; $R0 now contain: "C:\logo.sys C:\WINDOWS"
SectionEnd

Example (Get parent directory):
Section
	StrCpy $R0 "C:\Program Files\NSIS\NSIS.chm"
;	           "C:\Program Files\NSIS\Include\"
;	           "C:\\Program Files\\NSIS\\NSIS.chm"

	${WordFind} "$R0" "\" "-2{*" $R0
	; $R0 now contain: "C:\Program Files\NSIS"
	;                  "C:\\Program Files\\NSIS"
SectionEnd

Example (Coordinates):
Section
	${WordFind} "C:\io.sys C:\logo.sys C:\WINDOWS" ":\lo" "E+1{" $R0
	; $R0 now contain: "C:\io.sys C"
	IfErrors end

	StrLen $0 $R0             ; $0 = Start position of word (11)
	StrLen $1 ':\lo'          ; $1 = Word leght (4)
	; StrCpy $R0 $R1 $1 $0    ; $R0 = :\lo

	end:
SectionEnd

Example (With errorlevel output):
Section
	${WordFind} "[string]" "[delimiter]" "E[options]" $R0

	IfErrors 0 end
	StrCmp $R0 1 0 +2       ; errorlevel 1?
	MessageBox MB_OK 'delimiter not found' IDOK end
	StrCmp $R0 2 0 +2       ; errorlevel 2?
	MessageBox MB_OK 'no such word number' IDOK end
	StrCmp $R0 3 0 +2       ; errorlevel 3?
	MessageBox MB_OK 'syntax error'

	end:
SectionEnd

Example (Without errorlevel output):
Section
	${WordFind} "C:\io.sys C:\logo.sys" "_" "+1" $R0

	; $R0 now contain: "C:\io.sys C:\logo.sys" (error: delimiter "_" not found)
SectionEnd

Example (If found):
Section
	${WordFind} "C:\io.sys C:\logo.sys" ":\lo" "E+1{" $R0

	IfErrors notfound found
	found:
	MessageBox MB_OK 'Found' IDOK end
	notfound:
	MessageBox MB_OK 'Not found'

	end:
SectionEnd

Example (If found 2):
Section
	${WordFind} "C:\io.sys C:\logo.sys" ":\lo" "+1{" $R0

	StrCmp $R0 "C:\io.sys C:\logo.sys" notfound found        ; error?
	found:
	MessageBox MB_OK 'Found' IDOK end
	notfound:
	MessageBox MB_OK 'Not found'

	end:
SectionEnd

Example (To accept one word in string if delimiter not found):
Section
	StrCpy $0 'OneWord'
	StrCpy $1 1

	loop:
	${WordFind} "$0" " " "E+$1" $R0
	IfErrors 0 code
	StrCmp $1$R0 11 0 error
	StrCpy $R0 $0
	goto end

	code:
	; ...
	IntOp $1 $1 + 1
	goto loop

	error:
	StrCpy $1 ''
	StrCpy $R0 ''

	end:
	; $R0 now contain: "OneWord"
SectionEnd


______________________________________________________________________________

                            WordFind2X v2.1
______________________________________________________________________________

2005 Shengalts Aleksander (Shengalts@mail.ru)


Find word between two delimiters.


Strings:
"[delimiter1][word+1][delimiter2][delimiter1][word+2][delimiter2]..."
"[text][delimiter1][text][delimiter1][word+1][delimiter2][text]..."
"...[delimiter1][word-2][delimiter2][delimiter1][word-1][delimiter2]"
"...[text][delimiter1][text][delimiter1][word-1][delimiter2][text]"

Syntax:

${WordFind2X} "[string]" "[delimiter1]" "[delimiter2]" "[E][options]" $var

"[string]"         ;[string]
                   ;  input string
"[delimiter1]"     ;[delimiter1]
                   ;  first delimiter
"[delimiter2]"     ;[delimiter2]
                   ;  second delimiter
"[E][options]"     ;[options]
                   ;  +number   : word number from start
                   ;  -number   : word number from end
                   ;  +number}} : word number from start all space
                   ;              after this word to output
                   ;  +number{{ : word number from end all space
                   ;              before this word to output
                   ;  +number{} : word number from start
                   ;              all space before and after
                   ;              this word (word exclude)
                   ;  +number*} : word number from start
                   ;              all space after this
                   ;              word to output with word
                   ;  +number{* : word number from start
                   ;              all space before this
                   ;              word to output with word
                   ;  #         : sum of words to output
                   ;  /word     : number of word to output
                   ;
                   ;[E]
                   ;  with errorlevel output
                   ;  IfErrors:
                   ;     $var=1  no words found
                   ;     $var=2  no such word number
                   ;     $var=3  syntax error (Use: +1,-1,#)
                   ;[]
                   ;  no errorlevel output (default)
                   ;  If some errors found then (result=input string)
                   ;
$var               ;output (result)


Example (1):
Section
	${WordFind2X} "[C:\io.sys];[C:\logo.sys];[C:\WINDOWS]" "[C:\" "];" "+2" $R0
	; $R0 now contain: "logo.sys"
SectionEnd

Example (2):
Section
	${WordFind2X} "C:\WINDOWS C:\io.sys C:\logo.sys" "\" "." "-1" $R0
	; $R0 now contain: "logo"
SectionEnd

Example (3):
Section
	${WordFind2X} "C:\WINDOWS C:\io.sys C:\logo.sys" "\" "." "-1{{" $R0
	; $R0 now contain: "C:\WINDOWS C:\io.sys C:"
SectionEnd

Example (4):
Section
	${WordFind2X} "C:\WINDOWS C:\io.sys C:\logo.sys" "\" "." "-1{}" $R0
	; $R0 now contain: "C:\WINDOWS C:\io.sys C:sys"
SectionEnd

Example (5):
Section
	${WordFind2X} "C:\WINDOWS C:\io.sys C:\logo.sys" "\" "." "-1{*" $R0
	; $R0 now contain: "C:\WINDOWS C:\io.sys C:\logo."
SectionEnd

Example (6):
Section
	${WordFind2X} "C:\WINDOWS C:\io.sys C:\logo.sys" "\" "." "/logo" $R0
	; $R0 now contain: "2"
SectionEnd

Example (With errorlevel output):
Section
	${WordFind2X} "[io.sys];[C:\logo.sys]" "\" "];" "E+1" $R0
	; $R0 now contain: "1" ("\...];" not found)

	IfErrors 0 noerrors
	MessageBox MB_OK 'Errorlevel=$R0' IDOK end

	noerrors:
	MessageBox MB_OK 'No errors'

	end:
SectionEnd



______________________________________________________________________________

                            WordFind3X v1.0
______________________________________________________________________________

2005 Shengalts Aleksander (Shengalts@mail.ru)

Thanks Afrow UK (Based on his idea of Function "StrSortLR" 2003-06-18)


Find word, that contain string, between two delimiters.


Syntax:

${WordFind3X} "[string]" "[delimiter1]" "[center]" "[delimiter2]" "[E][options]" $var

"[string]"         ;[string]
                   ;  input string
"[delimiter1]"     ;[delimiter1]
                   ;  first delimiter
"[center]"         ;[center]
                   ;  center string
"[delimiter2]"     ;[delimiter2]
                   ;  second delimiter
"[E][options]"     ;[options]
                   ;  +number   : word number from start
                   ;  -number   : word number from end
                   ;  +number}} : word number from start all space
                   ;              after this word to output
                   ;  +number{{ : word number from end all space
                   ;              before this word to output
                   ;  +number{} : word number from start
                   ;              all space before and after
                   ;              this word (word exclude)
                   ;  +number*} : word number from start
                   ;              all space after this
                   ;              word to output with word
                   ;  +number{* : word number from start
                   ;              all space before this
                   ;              word to output with word
                   ;  #         : sum of words to output
                   ;  /word     : number of word to output
                   ;
                   ;[E]
                   ;  with errorlevel output
                   ;  IfErrors:
                   ;     $var=1  no words found
                   ;     $var=2  no such word number
                   ;     $var=3  syntax error (Use: +1,-1,#)
                   ;[]
                   ;  no errorlevel output (default)
                   ;  If some errors found then (result=input string)
                   ;
$var               ;output (result)


Example (1):
Section
	${WordFind3X} "[1.AAB];[2.BAA];[3.BBB];" "[" "AA" "];" "+1" $R0
	; $R0 now contain: "1.AAB"
SectionEnd

Example (2):
Section
	${WordFind3X} "[1.AAB];[2.BAA];[3.BBB];" "[" "AA" "];" "-1" $R0
	; $R0 now contain: "2.BAA"
SectionEnd

Example (3):
Section
	${WordFind3X} "[1.AAB];[2.BAA];[3.BBB];" "[" "AA" "];" "-1{{" $R0
	; $R0 now contain: "[1.AAB];"
SectionEnd

Example (4):
Section
	${WordFind3X} "[1.AAB];[2.BAA];[3.BBB];" "[" "AA" "];" "-1{}" $R0
	; $R0 now contain: "[1.AAB];[3.BBB];"
SectionEnd

Example (5):
Section
	${WordFind3X} "[1.AAB];[2.BAA];[3.BBB];" "[" "AA" "];" "-1{*" $R0
	; $R0 now contain: "[1.AAB];[2.BAA];"
SectionEnd

Example (6):
Section
	${WordFind3X} "[1.AAB];[2.BAA];[3.BBB];" "[" "AA" "];" "/2.BAA" $R0
	; $R0 now contain: "2"
SectionEnd

Example (With errorlevel output):
Section
	${WordFind3X} "[1.AAB];[2.BAA];[3.BBB];" "[" "XX" "];" "E+1" $R0
	; $R0 now contain: "1" ("[...XX...];" not found)

	IfErrors 0 noerrors
	MessageBox MB_OK 'Errorlevel=$R0' IDOK end

	noerrors:
	MessageBox MB_OK 'No errors'

	end:
SectionEnd


______________________________________________________________________________

                         WordReplace v2.0 (replace or delete)
______________________________________________________________________________

2004 Shengalts Aleksander (Shengalts@mail.ru)


Replace or delete word from string.


Syntax:

${WordReplace} "[string]" "[word1]" "[word2]" "[E][options]" $var

"[string]"         ;[string]
                   ;  input string
"[word1]"          ;[word1]
                   ;  word to replace or delete
"[word2]"          ;[word2]
                   ;  replace with (if empty delete)
"[E][options]"     ;[options]
                   ;  +number  : word number from start
                   ;  -number  : word number from end
                   ;  +number* : word number from start multiple-replace
                   ;  -number* : word number from end multiple-replace
                   ;  +        : replace or delete all founded
                   ;  +*       : multiple-replace all founded
                   ;  {}       : if exists replace or delete all delimiters
                   ;               from edges (no errorlevel output)
                   ;  {}*      : if exists multiple-replace all delimiters
                   ;               from edges (no errorlevel output)
                   ;
                   ;[E]
                   ;  with errorlevel output
                   ;  IfErrors:
                   ;     $var=1  word to replace or delete not found
                   ;     $var=2  no such word number
                   ;     $var=3  syntax error (Use: +1,-1,+1*,-1*,+,+*,{},{}*)
                   ;[]
                   ;  no errorlevel output (default)
                   ;  If some errors found then (result=input string)
                   ;
$var               ;output (result)


Example (replace):
Section
	${WordReplace} "C:\io.sys C:\logo.sys C:\WINDOWS" "SYS" "bmp" "+2" $R0
	; $R0 now contain: "C:\io.sys C:\logo.bmp C:\WINDOWS"
SectionEnd

Example (delete):
Section
	${WordReplace} "C:\io.sys C:\logo.sys C:\WINDOWS" "SYS" "" "+" $R0
	; $R0 now contain: "C:\io. C:\logo. C:\WINDOWS"
SectionEnd

Example (multiple-replace 1):
Section
	${WordReplace} "C:\io.sys      C:\logo.sys   C:\WINDOWS" " " " " "+1*" $R0
	; +1* or +2* or +3* or +4* or +5* or +6*
	; $R0 now contain: "C:\io.sys C:\logo.sys   C:\WINDOWS"
SectionEnd

Example (multiple-replace 2):
Section
	${WordReplace} "C:\io.sys C:\logo.sysSYSsys C:\WINDOWS" "sys" "bmp" "+*" $R0
	; $R0 now contain: "C:\io.bmp C:\logo.bmp C:\WINDOWS"
SectionEnd

Example (multiple-replace 3):
Section
	${WordReplace} "sysSYSsysC:\io.sys C:\logo.sys C:\WINDOWSsysSYSsys" "sys" "|" "{}*" $R0
	; $R0 now contain: "|C:\io.sys C:\logo.sys C:\WINDOWS|"
SectionEnd

Example (With errorlevel output):
Section
	${WordReplace} "C:\io.sys C:\logo.sys" "sys" "bmp" "E+3" $R0
	; $R0 now contain: "2" (no such word number "+3")

	IfErrors 0 noerrors
	MessageBox MB_OK 'Errorlevel=$R0' IDOK end

	noerrors:
	MessageBox MB_OK 'No errors'

	end:
SectionEnd


______________________________________________________________________________

                         WordAdd v1.8 (add or delete)
______________________________________________________________________________

2004 Shengalts Aleksander (Shengalts@mail.ru)


Add words to string1 from string2 if not exist or delete words if exist.


Syntax:

${WordAdd} "[string1]" "[delimiter]" "[E][+-string2]" $var

"[string1]"          ;[string1]
                     ;  string for addition or removing
"[delimiter]"        ;[delimiter]
                     ;  one or several symbols
"[E][+-string2]"     ;[+-string2]
                     ;  +string2 : words to add
                     ;  -string2 : words to delete
                     ;
                     ;[E]
                     ;  with errorlevel output
                     ;  IfErrors:
                     ;     $var=1  delimiter is empty
                     ;     $var=3  syntax error (use: +text,-text)
                     ;[]
                     ;  no errorlevel output (default)
                     ;  If some errors found then (result=input string)
                     ;
$var                 ;output (result)


Example (add):
Section
	${WordAdd} "C:\io.sys C:\WINDOWS" " " "+C:\WINDOWS C:\config.sys" $R0
	; $R0 now contain: "C:\io.sys C:\WINDOWS C:\config.sys"
SectionEnd

Example (delete):
Section
	${WordAdd} "C:\io.sys C:\logo.sys C:\WINDOWS" " " "-C:\WINDOWS C:\config.sys C:\IO.SYS" $R0
	; $R0 now contain: "C:\logo.sys"
SectionEnd

Example (add to one):
Section
	${WordAdd} "C:\io.sys" " " "+C:\WINDOWS C:\config.sys C:\IO.SYS" $R0
	; $R0 now contain: "C:\io.sys C:\WINDOWS C:\config.sys"
SectionEnd

Example (delete one):
Section
	${WordAdd} "C:\io.sys C:\logo.sys C:\WINDOWS" " " "-C:\WINDOWS" $R0
	; $R0 now contain: "C:\io.sys C:\logo.sys"
SectionEnd

Example (No new words found):
Section
	${WordAdd} "C:\io.sys C:\logo.sys" " " "+C:\logo.sys" $R0
	StrCmp $R0 "C:\io.sys C:\logo.sys" 0 +2
	MessageBox MB_OK "No new words found to add"
SectionEnd

Example (No words deleted):
Section
	${WordAdd} "C:\io.sys C:\logo.sys" " " "-C:\config.sys" $R0
	StrCmp $R0 "C:\io.sys C:\logo.sys" 0 +2
	MessageBox MB_OK "No words found to delete"
SectionEnd

Example (With errorlevel output):
Section
	${WordAdd} "C:\io.sys C:\logo.sys" "" "E-C:\logo.sys" $R0
	; $R0 now contain: "1" (delimiter is empty "")

	IfErrors 0 noerrors
	MessageBox MB_OK 'Errorlevel=$R0' IDOK end

	noerrors:
	MessageBox MB_OK 'No errors'

	end:
SectionEnd


______________________________________________________________________________

                         WordInsert v1.3
______________________________________________________________________________

2004 Shengalts Aleksander (Shengalts@mail.ru)


Insert word in string.


Syntax:

${WordInsert} "[string]" "[delimiter]" "[word]" "[E][+-number]" $var

"[string]"          ;[string]
                    ;  input string
"[delimiter]"       ;[delimiter]
                    ;  one or several symbols
"[word]"            ;[word]
                    ;  word to insert
"[E][+-number]"     ;[+-number]
                    ;  +number  : word number from start
                    ;  -number  : word number from end
                    ;
                    ;[E]
                    ;  with errorlevel output
                    ;  IfErrors:
                    ;     $var=1  delimiter is empty
                    ;     $var=2  wrong word number
                    ;     $var=3  syntax error (Use: +1,-1)
                    ;[]
                    ;  no errorlevel output (default)
                    ;  If some errors found then (result=input string)
                    ;
$var                ;output (result)


Example (1):
Section
	${WordInsert} "C:\io.sys C:\WINDOWS" " " "C:\logo.sys" "-2" $R0
	; $R0 now contain: "C:\io.sys C:\logo.sys C:\WINDOWS"
SectionEnd

Example (2):
Section
	${WordInsert} "C:\io.sys" " " "C:\WINDOWS" "+2" $R0
	; $R0 now contain: "C:\io.sys C:\WINDOWS"
SectionEnd

Example (3):
Section
	${WordInsert} "" " " "C:\WINDOWS" "+1" $R0
	; $R0 now contain: "C:\WINDOWS "
SectionEnd

Example (With errorlevel output):
Section
	${WordInsert} "C:\io.sys C:\logo.sys" " " "C:\logo.sys" "E+4" $R0
	; $R0 now contain: "2" (wrong word number "+4")

	IfErrors 0 noerrors
	MessageBox MB_OK 'Errorlevel=$R0' IDOK end

	noerrors:
	MessageBox MB_OK 'No errors'

	end:
SectionEnd


____________________________________________________________________________

                           StrFilter v1.1
____________________________________________________________________________

2004 Shengalts Aleksander (Shengalts@mail.ru)

Thanks sunjammer (Function "StrUpper" 2003-01-02)


Features:
1) To convert string to uppercase or lowercase.
2) To set symbol filter.


Syntax:

${StrFilter} "[string]" "[options]" "[symbols1]" "[symbols2]" $var

"[string]"       ;[string]
                 ;  input string
                 ;
"[options]"      ;[+|-][1|2|3|12|23|31][eng|rus]
                 ;  +   : covert string to uppercase
                 ;  -   : covert string to lowercase
                 ;  1   : only Digits
                 ;  2   : only Letters
                 ;  3   : only Special
                 ;  12  : only Digits  + Letters
                 ;  23  : only Letters + Special
                 ;  31  : only Special + Digits
                 ;  eng : English symbols (default)
                 ;  rus : Russian symbols
                 ;
"[symbols1]"     ;[symbols1]
                 ;  symbols include (not changeable)
                 ;
"[symbols2]"     ;[symbols2]
                 ;  symbols exclude
                 ;
$var             ;output (result)

Note:
IfErrors -> $var=""  syntax error (use: 1,23,...)
Same symbol to include & to exclude = to exclude


Example (UpperCase):
Section
	${StrFilter} "123abc 456DEF 7890|%$" "+" "" "" $R0
	; $R0 now contain: "123ABC 456DEF 7890|%$"
SectionEnd

Example (LowerCase):
Section
	${StrFilter} "123abc 456DEF 7890|%$" "-" "ef" "" $R0
	; $R0 now contain: "123abc 456dEF 7890|%$"
SectionEnd

Example (Filter1):
Section
	${StrFilter} "123abc 456DEF 7890|%$" "2" "|%" "" $R0
	; $R0 now contain: "abcDEF|%"       ;only Letters + |%
SectionEnd

Example (Filter2):
Section
	${StrFilter} "123abc 456DEF 7890|%$" "13" "af" "4590" $R0
	; $R0 now contain: "123a 6F 78|%$"  ;only Digits + Special + af - 4590
SectionEnd

Example (Filter3):
Section
	${StrFilter} "123abc 456DEF 7890|%$" "+12" "b" "def" $R0
	; $R0 now contain: "123AbC4567890"  ;only Digits + Letters + b - def
SectionEnd

Example (Filter4):
Section
	${StrFilter} "123abc¿¡¬ 456DEF„‰Â 7890|%$" "+12rus" "‰" "„Â" $R0
	; $R0 now contain: "123¿¡¬456‰7890"  ;only Digits + Letters + ‰ - „Â
SectionEnd

Example (English + Russian Letters):
Section
	${StrFilter} "123abc¿¡¬ 456DEF„‰Â 7890|%$" "2rus" "" "" $R0
	; $R0 now contain: "¿¡¬„‰Â"        ;only Russian Letters
	${StrFilter} "123abc¿¡¬ 456DEF„‰Â 7890|%$" "2" "$R0" "" $R0
	; $R0 now contain: "abc¿¡¬DEF„‰Â"  ;only English + Russian Letters
SectionEnd

Example (Word Capitalize):
Section
	Push "_01-PERPETUOUS_DREAMER__-__THE_SOUND_OF_GOODBYE_(ORIG._MIX).MP3_"
	Call Capitalize
	Pop $R0
	; $R0 now contain: "_01-Perpetuous_Dreamer__-__The_Sound_Of_Goodbye_(Orig._Mix).mp3_"

	${WordReplace} "$R0" "_" " " "+*" $R0
	; $R0 now contain: " 01-Perpetuous Dreamer - The Sound Of Goodbye (Orig. Mix).mp3 "

	${WordReplace} "$R0" " " "" "{}" $R0
	; $R0 now contain: "01-Perpetuous Dreamer - The Sound Of Goodbye (Orig. Mix).mp3"
SectionEnd

Function Capitalize
	Exch $R0
	Push $0
	Push $1
	Push $2

	${StrFilter} '$R0' '-eng' '' '' $R0
	${StrFilter} '$R0' '-rus' '' '' $R0

	StrCpy $0 0

	loop:
	IntOp $0 $0 + 1
	StrCpy $1 $R0 1 $0
	StrCmp $1 '' end
	StrCmp $1 ' ' +5
	StrCmp $1 '_' +4
	StrCmp $1 '-' +3
	StrCmp $1 '(' +2
	StrCmp $1 '[' 0 loop
	IntOp $0 $0 + 1
	StrCpy $1 $R0 1 $0
	StrCmp $1 '' end

	${StrFilter} '$1' '+eng' '' '' $1
	${StrFilter} '$1' '+rus' '' '' $1

	StrCpy $2 $R0 $0
	IntOp $0 $0 + 1
	StrCpy $R0 $R0 '' $0
	IntOp $0 $0 - 2
	StrCpy $R0 '$2$1$R0'
	goto loop

	end:
	Pop $2
	Pop $1
	Pop $0
	Exch $R0
FunctionEnd


____________________________________________________________________________

                                CopyToClipboard
____________________________________________________________________________

Written by Afrow UK 2004-02-17


Copy string to Windows Clipboard


Syntax:

${ClbSet} "[string]"


Example:
Section
	${ClbSet} "hello"
	; Clipboard now contain: "hello"
SectionEnd


____________________________________________________________________________

                                CopyFromClipboard
____________________________________________________________________________

Written by Afrow UK 2004-02-17


Copy string from Windows Clipboard


Syntax:

${ClbGet} $var


Example:
Section
	${ClbGet} $R0
	; $R0 now contain: "[Windows clipboard]"
SectionEnd

*/


;_____________________________________________________________________________
;
;                                   Macros
;_____________________________________________________________________________
;
!define _UNWORD1
!define _UNWORD2

!macro WordFindCall _STRING _DELIMITER _OPTION _RESULT
	Push `${_STRING}`
	Push `${_DELIMITER}`
	Push `${_OPTION}`
	Call WordFind
	Pop ${_RESULT}
!macroend

!macro WordFind2XCall _STRING _DELIMITER1 _DELIMITER2 _NUMBER _RESULT
	Push `${_STRING}`
	Push `${_DELIMITER1}`
	Push `${_DELIMITER2}`
	Push `${_NUMBER}`
	Call WordFind2X
	Pop ${_RESULT}
!macroend

!macro WordFind3XCall _STRING _DELIMITER1 _CENTER _DELIMITER2 _NUMBER _RESULT
	Push `${_STRING}`
	Push `${_DELIMITER1}`
	Push `${_CENTER}`
	Push `${_DELIMITER2}`
	Push `${_NUMBER}`
	Call WordFind3X
	Pop ${_RESULT}
!macroend

!macro WordReplaceCall _STRING _WORD1 _WORD2 _NUMBER _RESULT
	Push `${_STRING}`
	Push `${_WORD1}`
	Push `${_WORD2}`
	Push `${_NUMBER}`
	Call WordReplace
	Pop ${_RESULT}
!macroend

!macro WordAddCall _STRING1 _DELIMITER _STRING2 _RESULT
	Push `${_STRING1}`
	Push `${_DELIMITER}`
	Push `${_STRING2}`
	Call WordAdd
	Pop ${_RESULT}
!macroend

!macro WordInsertCall _STRING _DELIMITER _WORD _NUMBER _RESULT
	Push `${_STRING}`
	Push `${_DELIMITER}`
	Push `${_WORD}`
	Push `${_NUMBER}`
	Call WordInsert
	Pop ${_RESULT}
!macroend

!macro StrFilterCall _STRING _FILTER _INCLUDE _EXCLUDE _RESULT
	Push `${_STRING}`
	Push `${_FILTER}`
	Push `${_INCLUDE}`
	Push `${_EXCLUDE}`
	Call StrFilter
	Pop ${_RESULT}
!macroend

!macro ClbSetCall _STRING
	Push `${_STRING}`
	Call CopyToClipboard
!macroend

!macro ClbGetCall _RESULT
	Call CopyFromClipboard
	Pop ${_RESULT}
!macroend

!macro WordFind
	!ifndef ${_UNWORD1}WordFind
		!define ${_UNWORD1}WordFind `!insertmacro ${_UNWORD1}WordFindCall`

		Function ${_UNWORD1}WordFind
			Exch $1
			Exch
			Exch $0
			Exch
			Exch 2
			Exch $R0
			Exch 2
			Push $2
			Push $3
			Push $4
			Push $5
			Push $6
			Push $7
			Push $8
			Push $9
			Push $R1
			ClearErrors

			StrCpy $9 ''
			StrCpy $2 $1 1
			StrCpy $1 $1 '' 1
			StrCmp $2 'E' 0 +3
			StrCpy $9 E
			goto -4

			StrCpy $3 ''
			StrCmp $2 '+' +6
			StrCmp $2 '-' +5
			StrCmp $2 '/' restart
			StrCmp $2 '#' restart
			StrCmp $2 '*' restart
			goto error3

			StrCpy $4 $1 1 -1
			StrCmp $4 '*' +4
			StrCmp $4 '}' +3
			StrCmp $4 '{' +2
			goto +4
			StrCpy $1 $1 -1
			StrCpy $3 '$4$3'
			goto -7
			StrCmp $3 '*' error3
			StrCmp $3 '**' error3
			StrCmp $3 '}{' error3
			IntOp $1 $1 + 0
			StrCmp $1 0 error2

			restart:
			StrCmp $R0 '' error1
			StrCpy $4 0
			StrCpy $5 0
			StrCpy $6 0
			StrLen $7 $0
			goto loop

			preloop:
			IntOp $6 $6 + 1

			loop:
			StrCpy $8 $R0 $7 $6
			StrCmp $8$5 0 error1
			StrCmp $8 '' +2
			StrCmp $8 $0 +5 preloop
			StrCmp $3 '{' minus
			StrCmp $3 '}' minus
			StrCmp $2 '*' minus
			StrCmp $5 $6 minus +5
			StrCmp $3 '{' +4
			StrCmp $3 '}' +3
			StrCmp $2 '*' +2
			StrCmp $5 $6 nextword
			IntOp $4 $4 + 1
			StrCmp $2$4 +$1 plus
			StrCmp $2 '/' 0 nextword
			IntOp $8 $6 - $5
			StrCpy $8 $R0 $8 $5
			StrCmp $1 $8 0 nextword
			StrCpy $R1 $4
			goto end
			nextword:
			IntOp $6 $6 + $7
			StrCpy $5 $6
			goto loop

			minus:
			StrCmp $2 '-' 0 sum
			StrCpy $2 '+'
			IntOp $1 $4 - $1
			IntOp $1 $1 + 1
			IntCmp $1 0 error2 error2 restart
			sum:
			StrCmp $2 '#' 0 sumdelim
			StrCpy $R1 $4
			goto end
			sumdelim:
			StrCmp $2 '*' 0 error2
			StrCpy $R1 $4
			goto end

			plus:
			StrCmp $3 '' 0 +4
			IntOp $6 $6 - $5
			StrCpy $R1 $R0 $6 $5
			goto end
			StrCmp $3 '{' 0 +3
			StrCpy $R1 $R0 $6
			goto end
			StrCmp $3 '}' 0 +4
			IntOp $6 $6 + $7
			StrCpy $R1 $R0 '' $6
			goto end
			StrCmp $3 '{*' +2
			StrCmp $3 '*{' 0 +3
			StrCpy $R1 $R0 $6
			goto end
			StrCmp $3 '*}' +2
			StrCmp $3 '}*' 0 +3
			StrCpy $R1 $R0 '' $5
			goto end
			StrCmp $3 '}}' 0 +3
			StrCpy $R1 $R0 '' $6
			goto end
			StrCmp $3 '{{' 0 +3
			StrCpy $R1 $R0 $5
			goto end
			StrCmp $3 '{}' 0 error3
			StrLen $3 $R0
			StrCmp $3 $6 0 +3
			StrCpy $0 ''
			goto +2
			IntOp $6 $6 + $7
			StrCpy $8 $R0 '' $6
			StrCmp $4$8 1 +6
			StrCmp $4 1 +2 +7
			IntOp $6 $6 + $7
			StrCpy $3 $R0 $7 $6
			StrCmp $3 '' +2
			StrCmp $3 $0 -3 +3
			StrCpy $R1 ''
			goto end
			StrCmp $5 0 0 +3
			StrCpy $0 ''
			goto +2
			IntOp $5 $5 - $7
			StrCpy $3 $R0 $5
			StrCpy $R1 '$3$0$8'
			goto end

			error3:
			StrCpy $R1 3
			goto error
			error2:
			StrCpy $R1 2
			goto error
			error1:
			StrCpy $R1 1
			error:
			StrCmp $9 'E' 0 +3
			SetErrors

			end:
			StrCpy $R0 $R1

			Pop $R1
			Pop $9
			Pop $8
			Pop $7
			Pop $6
			Pop $5
			Pop $4
			Pop $3
			Pop $2
			Pop $1
			Pop $0
			Exch $R0
		FunctionEnd


		!ifndef _UNWORD2
			!undef _UNWORD1
			!define _UNWORD1
		!endif
	!endif
!macroend

!macro WordFind2X
	!ifndef ${_UNWORD1}WordFind2X
		!define ${_UNWORD1}WordFind2X `!insertmacro ${_UNWORD1}WordFind2XCall`

		Function ${_UNWORD1}WordFind2X
			Exch $2
			Exch
			Exch $1
			Exch
			Exch 2
			Exch $0
			Exch 2
			Exch 3
			Exch $R0
			Exch 3
			Push $3
			Push $4
			Push $5
			Push $6
			Push $7
			Push $8
			Push $9
			Push $R1
			Push $R2
			ClearErrors

			StrCpy $R2 ''
			StrCpy $3 $2 1
			StrCpy $2 $2 '' 1
			StrCmp $3 'E' 0 +3
			StrCpy $R2 E
			goto -4

			StrCmp $3 '+' +5
			StrCmp $3 '-' +4
			StrCmp $3 '#' restart
			StrCmp $3 '/' restart
			goto error3

			StrCpy $4 $2 2 -2
			StrCmp $4 '{{' +9
			StrCmp $4 '}}' +8
			StrCmp $4 '{*' +7
			StrCmp $4 '*{' +6
			StrCmp $4 '*}' +5
			StrCmp $4 '}*' +4
			StrCmp $4 '{}' +3
			StrCpy $4 ''
			goto +2
			StrCpy $2 $2 -2
			IntOp $2 $2 + 0
			StrCmp $2 0 error2

			restart:
			StrCmp $R0 '' error1
			StrCpy $5 -1
			StrCpy $6 0
			StrCpy $7 ''
			StrLen $8 $0
			StrLen $9 $1

			loop:
			IntOp $5 $5 + 1

			delim1:
			StrCpy $R1 $R0 $8 $5
			StrCmp $R1$6 0 error1
			StrCmp $R1 '' minus
			StrCmp $R1 $0 +2
			StrCmp $7 '' loop delim2
			StrCmp $0 $1 0 +2
			StrCmp $7 '' 0 delim2
			IntOp $7 $5 + $8
			StrCpy $5 $7
			goto delim1

			delim2:
			StrCpy $R1 $R0 $9 $5
			StrCmp $R1 $1 0 loop
			IntOp $6 $6 + 1
			StrCmp $3$6 '+$2' plus
			StrCmp $3 '/' 0 nextword
			IntOp $R1 $5 - $7
			StrCpy $R1 $R0 $R1 $7
			StrCmp $R1 $2 0 +3
			StrCpy $R1 $6
			goto end
			nextword:
			IntOp $5 $5 + $9
			StrCpy $7 ''
			goto delim1

			minus:
			StrCmp $3 '-' 0 sum
			StrCpy $3 +
			IntOp $2 $6 - $2
			IntOp $2 $2 + 1
			IntCmp $2 0 error2 error2 restart
			sum:
			StrCmp $3 '#' 0 error2
			StrCpy $R1 $6
			goto end

			plus:
			StrCmp $4 '' 0 +4
			IntOp $R1 $5 - $7
			StrCpy $R1 $R0 $R1 $7
			goto end
			IntOp $5 $5 + $9
			IntOp $7 $7 - $8
			StrCmp $4 '{*' +2
			StrCmp $4 '*{' 0 +3
			StrCpy $R1 $R0 $5
			goto end
			StrCmp $4 '*}' +2
			StrCmp $4 '}*' 0 +3
			StrCpy $R1 $R0 '' $7
			goto end
			StrCmp $4 '}}' 0 +3
			StrCpy $R1 $R0 '' $5
			goto end
			StrCmp $4 '{{' 0 +3
			StrCpy $R1 $R0 $7
			goto end
			StrCmp $4 '{}' 0 error3
			StrCpy $5 $R0 '' $5
			StrCpy $7 $R0 $7
			StrCpy $R1 '$7$5'
			goto end

			error3:
			StrCpy $R1 3
			goto error
			error2:
			StrCpy $R1 2
			goto error
			error1:
			StrCpy $R1 1
			error:
			StrCmp $R2 'E' 0 +3
			SetErrors

			end:
			StrCpy $R0 $R1

			Pop $R2
			Pop $R1
			Pop $9
			Pop $8
			Pop $7
			Pop $6
			Pop $5
			Pop $4
			Pop $3
			Pop $2
			Pop $1
			Pop $0
			Exch $R0
		FunctionEnd

		!undef _UNWORD1
		!define _UNWORD1
	!endif
!macroend

!macro WordFind3X
	!ifndef ${_UNWORD1}WordFind3X
		!define ${_UNWORD1}WordFind3X `!insertmacro ${_UNWORD1}WordFind3XCall`

		Function ${_UNWORD1}WordFind3X
			Exch $3
			Exch
			Exch $2
			Exch
			Exch 2
			Exch $1
			Exch 2
			Exch 3
			Exch $0
			Exch 3
			Exch 4
			Exch $R0
			Exch 4
			Push $4
			Push $5
			Push $6
			Push $7
			Push $8
			Push $9
			Push $R1
			Push $R2
			Push $R3
			Push $R4
			Push $R5
			ClearErrors

			StrCpy $R5 ''
			StrCpy $4 $3 1
			StrCpy $3 $3 '' 1
			StrCmp $4 'E' 0 +3
			StrCpy $R5 E
			goto -4

			StrCmp $4 '+' +5
			StrCmp $4 '-' +4
			StrCmp $4 '#' restart
			StrCmp $4 '/' restart
			goto error3

			StrCpy $5 $3 2 -2
			StrCmp $5 '{{' +9
			StrCmp $5 '}}' +8
			StrCmp $5 '{*' +7
			StrCmp $5 '*{' +6
			StrCmp $5 '*}' +5
			StrCmp $5 '}*' +4
			StrCmp $5 '{}' +3
			StrCpy $5 ''
			goto +2
			StrCpy $3 $3 -2
			IntOp $3 $3 + 0
			StrCmp $3 0 error2

			restart:
			StrCmp $R0 '' error1
			StrCpy $6 -1
			StrCpy $7 0
			StrCpy $8 ''
			StrCpy $9 ''
			StrLen $R1 $0
			StrLen $R2 $1
			StrLen $R3 $2

			loop:
			IntOp $6 $6 + 1

			delim1:
			StrCpy $R4 $R0 $R1 $6
			StrCmp $R4$7 0 error1
			StrCmp $R4 '' minus
			StrCmp $R4 $0 +2
			StrCmp $8 '' loop center
			StrCmp $0 $1 +2
			StrCmp $0 $2 0 +2
			StrCmp $8 '' 0 center
			IntOp $8 $6 + $R1
			StrCpy $6 $8
			goto delim1

			center:
			StrCmp $9 '' 0 delim2
			StrCpy $R4 $R0 $R2 $6
			StrCmp $R4 $1 0 loop
			IntOp $9 $6 + $R2
			StrCpy $6 $9
			goto delim1

			delim2:
			StrCpy $R4 $R0 $R3 $6
			StrCmp $R4 $2 0 loop
			IntOp $7 $7 + 1
			StrCmp $4$7 '+$3' plus
			StrCmp $4 '/' 0 nextword
			IntOp $R4 $6 - $8
			StrCpy $R4 $R0 $R4 $8
			StrCmp $R4 $3 0 +3
			StrCpy $R4 $7
			goto end
			nextword:
			IntOp $6 $6 + $R3
			StrCpy $8 ''
			StrCpy $9 ''
			goto delim1

			minus:
			StrCmp $4 '-' 0 sum
			StrCpy $4 +
			IntOp $3 $7 - $3
			IntOp $3 $3 + 1
			IntCmp $3 0 error2 error2 restart
			sum:
			StrCmp $4 '#' 0 error2
			StrCpy $R4 $7
			goto end

			plus:
			StrCmp $5 '' 0 +4
			IntOp $R4 $6 - $8
			StrCpy $R4 $R0 $R4 $8
			goto end
			IntOp $6 $6 + $R3
			IntOp $8 $8 - $R1
			StrCmp $5 '{*' +2
			StrCmp $5 '*{' 0 +3
			StrCpy $R4 $R0 $6
			goto end
			StrCmp $5 '*}' +2
			StrCmp $5 '}*' 0 +3
			StrCpy $R4 $R0 '' $8
			goto end
			StrCmp $5 '}}' 0 +3
			StrCpy $R4 $R0 '' $6
			goto end
			StrCmp $5 '{{' 0 +3
			StrCpy $R4 $R0 $8
			goto end
			StrCmp $5 '{}' 0 error3
			StrCpy $6 $R0 '' $6
			StrCpy $8 $R0 $8
			StrCpy $R4 '$8$6'
			goto end

			error3:
			StrCpy $R4 3
			goto error
			error2:
			StrCpy $R4 2
			goto error
			error1:
			StrCpy $R4 1
			error:
			StrCmp $R5 'E' 0 +3
			SetErrors

			end:
			StrCpy $R0 $R4
			Pop $R5
			Pop $R4
			Pop $R3
			Pop $R2
			Pop $R1
			Pop $9
			Pop $8
			Pop $7
			Pop $6
			Pop $5
			Pop $4
			Pop $3
			Pop $2
			Pop $1
			Pop $0
			Exch $R0
		FunctionEnd

		!undef _UNWORD1
		!define _UNWORD1
	!endif
!macroend

!macro WordReplace
	!ifndef ${_UNWORD1}WordReplace
		!define ${_UNWORD1}WordReplace `!insertmacro ${_UNWORD1}WordReplaceCall`

		Function ${_UNWORD1}WordReplace
			Exch $2
			Exch
			Exch $1
			Exch
			Exch 2
			Exch $0
			Exch 2
			Exch 3
			Exch $R0
			Exch 3
			Push $3
			Push $4
			Push $5
			Push $6
			Push $7
			Push $8
			Push $9
			Push $R1
			ClearErrors

			StrCpy $R1 $R0
			StrCpy $9 ''
			StrCpy $3 $2 1
			StrCmp $3 'E' 0 +4
			StrCpy $9 E
			StrCpy $2 $2 '' 1
			goto -4

			StrLen $7 $0

			StrCpy $4 $2 3
			StrCpy $5 $2 2
			StrCmp $4 '{}*' +3
			StrCmp $5 '{}' +2
			goto errorchk
			StrCmp $7 0 end
			StrCpy $5 ''
			StrCpy $6 ''
			StrCpy $3 $R0 $7
			StrCmp $3 $0 0 +4
			StrCpy $R0 $R0 '' $7
			StrCpy $5 '$1$5'
			goto -4
			StrCpy $3 $R0 '' -$7
			StrCmp $3 $0 0 +4
			StrCpy $R0 $R0 -$7
			StrCpy $6 '$6$1'
			goto -4
			StrCmp $4 '{}*' 0 +5
			StrCmp $5 '' +2
			StrCpy $5 $1
			StrCmp $6 '' +2
			StrCpy $6 $1
			StrCpy $R0 '$5$R0$6'
			goto end

			errorchk:
			StrCpy $3 $2 1
			StrCpy $2 $2 '' 1
			StrCmp $3 '+' +2
			StrCmp $3 '-' 0 error3
			StrCmp $R0 '' error1
			StrCmp $7 0 error1

			StrCpy $4 $2 1 -1
			StrCpy $5 $2 1
			IntOp $2 $2 + 0
			StrCmp $2 0 0 one
			StrCmp $5 0 error2
			StrCpy $3 ''

			all:
			StrCpy $5 0
			StrCpy $2 $R0 $7 $5
			StrCmp $2$3 '' error1
			StrCmp $2 '' +4
			StrCmp $2 $0 +5
			IntOp $5 $5 + 1
			goto -5
			StrCpy $R0 '$3$R0'
			goto end
			StrCpy $2 $R0 $5
			IntOp $5 $5 + $7
			StrCmp $4 '*' 0 +3
			StrCpy $6 $R0 $7 $5
			StrCmp $6 $0 -3
			StrCpy $R0 $R0 '' $5
			StrCpy $3 '$3$2$1'
			goto all

			one:
			StrCpy $5 0
			StrCpy $8 0
			goto loop

			preloop:
			IntOp $5 $5 + 1

			loop:
			StrCpy $6 $R0 $7 $5
			StrCmp $6$8 0 error1
			StrCmp $6 '' minus
			StrCmp $6 $0 0 preloop
			IntOp $8 $8 + 1
			StrCmp $3$8 +$2 found
			IntOp $5 $5 + $7
			goto loop

			minus:
			StrCmp $3 '-' 0 error2
			StrCpy $3 +
			IntOp $2 $8 - $2
			IntOp $2 $2 + 1
			IntCmp $2 0 error2 error2 one

			found:
			StrCpy $3 $R0 $5
			StrCmp $4 '*' 0 +5
			StrCpy $6 $3 '' -$7
			StrCmp $6 $0 0 +3
			StrCpy $3 $3 -$7
			goto -3
			IntOp $5 $5 + $7
			StrCmp $4 '*' 0 +3
			StrCpy $6 $R0 $7 $5
			StrCmp $6 $0 -3
			StrCpy $R0 $R0 '' $5
			StrCpy $R0 '$3$1$R0'
			goto end

			error3:
			StrCpy $R0 3
			goto error
			error2:
			StrCpy $R0 2
			goto error
			error1:
			StrCpy $R0 1
			error:
			StrCmp $9 'E' +3
			StrCpy $R0 $R1
			goto +2
			SetErrors

			end:
			Pop $R1
			Pop $9
			Pop $8
			Pop $7
			Pop $6
			Pop $5
			Pop $4
			Pop $3
			Pop $2
			Pop $1
			Pop $0
			Exch $R0
		FunctionEnd

		!undef _UNWORD1
		!define _UNWORD1
	!endif
!macroend

!macro WordAdd
	!ifndef ${_UNWORD1}WordAdd
		!insertmacro WordFind

		!define ${_UNWORD1}WordAdd `!insertmacro ${_UNWORD1}WordAddCall`

		Function ${_UNWORD1}WordAdd
			Exch $1
			Exch
			Exch $0
			Exch
			Exch 2
			Exch $R0
			Exch 2
			Push $2
			Push $3
			Push $4
			Push $5
			Push $6
			Push $7
			Push $R1
			ClearErrors

			StrCpy $7 ''
			StrCpy $2 $1 1
			StrCmp $2 'E' 0 +4
			StrCpy $7 E
			StrCpy $1 $1 '' 1
			goto -4

			StrCpy $5 0
			StrCpy $R1 $R0
			StrCpy $2 $1 '' 1
			StrCpy $1 $1 1
			StrCmp $1 '+' +2
			StrCmp $1 '-' 0 error3

			StrCmp $0 '' error1
			StrCmp $2 '' end
			StrCmp $R0 '' 0 +5
			StrCmp $1 '-' end
			StrCmp $1 '+' 0 +3
			StrCpy $R0 $2
			goto end

			loop:
			IntOp $5 $5 + 1
			Push `$2`
			Push `$0`
			Push `E+$5`
			Call ${_UNWORD1}WordFind
			Pop $3
			IfErrors 0 /word
			StrCmp $3 2 +4
			StrCmp $3$5 11 0 +3
			StrCpy $3 $2
			goto /word
			StrCmp $1 '-' end preend

			/word:
			Push `$R0`
			Push `$0`
			Push `E/$3`
			Call ${_UNWORD1}WordFind
			Pop $4
			IfErrors +2
			StrCmp $1 '-' delete loop
			StrCmp $1$4 '-1' +2
			StrCmp $1 '-' loop +4
			StrCmp $R0 $3 0 loop
			StrCpy $R0 ''
			goto end
			StrCmp $1$4 '+1' 0 +2
			StrCmp $R0 $3 loop
			StrCmp $R0 $R1 +3
			StrCpy $R1 '$R1$0$3'
			goto loop
			StrLen $6 $0
			StrCpy $6 $R0 '' -$6
			StrCmp $6 $0 0 -4
			StrCpy $R1 '$R1$3'
			goto loop

			delete:
			Push `$R0`
			Push `$0`
			Push `E+$4{}`
			Call ${_UNWORD1}WordFind
			Pop $R0
			goto /word

			error3:
			StrCpy $R1 3
			goto error
			error1:
			StrCpy $R1 1
			error:
			StrCmp $7 'E' 0 end
			SetErrors

			preend:
			StrCpy $R0 $R1

			end:
			Pop $R1
			Pop $7
			Pop $6
			Pop $5
			Pop $4
			Pop $3
			Pop $2
			Pop $1
			Pop $0
			Exch $R0
		FunctionEnd

		!undef _UNWORD1
		!define _UNWORD1
	!endif
!macroend

!macro WordInsert
	!ifndef ${_UNWORD1}WordInsert
		!insertmacro WordFind

		!define ${_UNWORD1}WordInsert `!insertmacro ${_UNWORD1}WordInsertCall`

		Function ${_UNWORD1}WordInsert
			Exch $2
			Exch
			Exch $1
			Exch
			Exch 2
			Exch $0
			Exch 2
			Exch 3
			Exch $R0
			Exch 3
			Push $3
			Push $4
			Push $5
			Push $6
			Push $7
			Push $8
			Push $9
			Push $R1
			ClearErrors

			StrCpy $5 ''
			StrCpy $6 $0
			StrCpy $7 }

			StrCpy $9 ''
			StrCpy $R1 $R0
			StrCpy $3 $2 1
			StrCpy $2 $2 '' 1
			StrCmp $3 'E' 0 +3
			StrCpy $9 'E'
			goto -4

			StrCmp $3 '+' +2
			StrCmp $3 '-' 0 error3
			IntOp $2 $2 + 0
			StrCmp $2 0 error2
			StrCmp $0 '' error1

			StrCmp $2 1 0 two
			GetLabelAddress $8 oneback
			StrCmp $3 '+' call
			StrCpy $7 {
			goto call
			oneback:
			IfErrors 0 +2
			StrCpy $4 $R0
			StrCmp $3 '+' 0 +3
			StrCpy $R0 '$1$0$4'
			goto end
			StrCpy $R0 '$4$0$1'
			goto end

			two:
			IntOp $2 $2 - 1
			GetLabelAddress $8 twoback
			StrCmp $3 '+' 0 call
			StrCpy $7 {
			goto call
			twoback:
			IfErrors 0 tree
			StrCmp $2$4 11 0 error2
			StrCmp $3 '+' 0 +3
			StrCpy $R0 '$R0$0$1'
			goto end
			StrCpy $R0 '$1$0$R0'
			goto end

			tree:
			StrCpy $7 }
			StrCpy $5 $4
			IntOp $2 $2 + 1
			GetLabelAddress $8 treeback
			StrCmp $3 '+' call
			StrCpy $7 {
			goto call
			treeback:
			IfErrors 0 +3
			StrCpy $4 ''
			StrCpy $6 ''
			StrCmp $3 '+' 0 +3
			StrCpy $R0 '$5$0$1$6$4'
			goto end
			StrCpy $R0 '$4$6$1$0$5'
			goto end

			call:			
			Push '$R0'
			Push '$0'
			Push 'E$3$2*$7'
			Call ${_UNWORD1}WordFind
			Pop $4
			goto $8

			error3:
			StrCpy $R0 3
			goto error
			error2:
			StrCpy $R0 2
			goto error
			error1:
			StrCpy $R0 1
			error:
			StrCmp $9 'E' +3
			StrCpy $R0 $R1
			goto +2
			SetErrors

			end:
			Pop $R1
			Pop $9
			Pop $8
			Pop $7
			Pop $6
			Pop $5
			Pop $4
			Pop $3
			Pop $2
			Pop $1
			Pop $0
			Exch $R0
		FunctionEnd

		!undef _UNWORD1
		!define _UNWORD1
	!endif
!macroend

!macro StrFilter
	!ifndef ${_UNWORD1}StrFilter
		!define ${_UNWORD1}StrFilter `!insertmacro ${_UNWORD1}StrFilterCall`

		Function ${_UNWORD1}StrFilter
			Exch $2
			Exch
			Exch $1
			Exch
			Exch 2
			Exch $0
			Exch 2
			Exch 3
			Exch $R0
			Exch 3
			Push $3
			Push $4
			Push $5
			Push $6
			Push $7
			Push $R1
			Push $R2
			Push $R3
			Push $R4
			Push $R5
			Push $R6
			Push $R7
			Push $R8

			StrCpy $R2 $0 '' -3
			StrCmp $R2 eng eng
			StrCmp $R2 rus rus
			eng:
			StrCpy $4 65
			StrCpy $5 90
			StrCpy $6 97
			StrCpy $7 122
			goto langend
			rus:
			StrCpy $4 192
			StrCpy $5 223
			StrCpy $6 224
			StrCpy $7 255
			goto langend
			;...

			langend:
			StrCpy $R7 ''
			StrCpy $R8 ''

			StrCmp $2 '' 0 begin

			restart1:
			StrCpy $2 ''
			StrCpy $3 $0 1
			StrCmp $3 '+' +2
			StrCmp $3 '-' 0 +3
			StrCpy $0 $0 '' 1
			goto +2
			StrCpy $3 ''

			IntOp $0 $0 + 0
			StrCmp $0 0 +5
			StrCpy $R7 $0 1 0
			StrCpy $R8 $0 1 1
			StrCpy $R2 $0 1 2
			StrCmp $R2 '' filter error

			restart2:
			StrCmp $3 '' end
			StrCpy $R7 ''
			StrCpy $R8 '+-'
			goto begin

			filter:
			StrCmp $R7 '1' +3
			StrCmp $R7 '2' +2
			StrCmp $R7 '3' 0 error

			StrCmp $R8 '' begin
			StrCmp $R7$R8 '23' +2
			StrCmp $R7$R8 '32' 0 +3
			StrCpy $R7 -1
			goto begin
			StrCmp $R7$R8 '13' +2
			StrCmp $R7$R8 '31' 0 +3
			StrCpy $R7 -2
			goto begin
			StrCmp $R7$R8 '12' +2
			StrCmp $R7$R8 '21' 0 error
			StrCpy $R7 -3

			begin:
			StrCpy $R6 0
			StrCpy $R1 ''

			loop:
			StrCpy $R2 $R0 1 $R6
			StrCmp $R2 '' restartchk

			StrCmp $2 '' +7
			StrCpy $R4 0
			StrCpy $R5 $2 1 $R4
			StrCmp $R5 '' addsymbol
			StrCmp $R5 $R2 skipsymbol
			IntOp $R4 $R4 + 1
			goto -4

			StrCmp $1 '' +7
			StrCpy $R4 0
			StrCpy $R5 $1 1 $R4
			StrCmp $R5 '' +4
			StrCmp $R5 $R2 addsymbol
			IntOp $R4 $R4 + 1
			goto -4

			StrCmp $R7 '1' +2
			StrCmp $R7 '-1' 0 +4
			StrCpy $R4 48
			StrCpy $R5 57
			goto loop2
			StrCmp $R8 '+-' 0 +2
			StrCmp $3 '+' 0 +4
			StrCpy $R4 $4
			StrCpy $R5 $5
			goto loop2
			StrCpy $R4 $6
			StrCpy $R5 $7

			loop2:
			IntFmt $R3 '%c' $R4
			StrCmp $R2 $R3 found
			StrCmp $R4 $R5 notfound
			IntOp $R4 $R4 + 1
			goto loop2

			found:
			StrCmp $R8 '+-' setcase
			StrCmp $R7 '3' skipsymbol
			StrCmp $R7 '-3' addsymbol
			StrCmp $R8 '' addsymbol skipsymbol

			notfound:
			StrCmp $R8 '+-' addsymbol
			StrCmp $R7 '3' 0 +2
			StrCmp $R5 57 addsymbol +3
			StrCmp $R7 '-3' 0 +5
			StrCmp $R5 57 skipsymbol
			StrCpy $R4 48
			StrCpy $R5 57
			goto loop2
			StrCmp $R8 '' skipsymbol addsymbol

			setcase:
			StrCpy $R2 $R3
			addsymbol:
			StrCpy $R1 $R1$R2
			skipsymbol:
			IntOp $R6 $R6 + 1
			goto loop

			error:
			SetErrors
			StrCpy $R0 ''
			goto end

			restartchk:
			StrCpy $R0 $R1
			StrCmp $2 '' 0 restart1
			StrCmp $R8 '+-' 0 restart2

			end:
			Pop $R8
			Pop $R7
			Pop $R6
			Pop $R5
			Pop $R4
			Pop $R3
			Pop $R2
			Pop $R1
			Pop $7
			Pop $6
			Pop $5
			Pop $4
			Pop $3
			Pop $2
			Pop $1
			Pop $0
			Exch $R0
		FunctionEnd

		!undef _UNWORD1
		!define _UNWORD1
	!endif
!macroend

!macro ClbSet
	!ifndef ${_UNWORD1}ClbSet
		!define ${_UNWORD1}ClbSet `!insertmacro ${_UNWORD1}ClbSetCall`

		Function ${_UNWORD1}CopyToClipboard
			Exch $0
			Push $1
			Push $2
			System::Call 'user32::OpenClipboard(i 0)'
			System::Call 'user32::EmptyClipboard()'
			StrLen $1 $0
			IntOp $1 $1 + 1
			System::Call 'kernel32::GlobalAlloc(i 2, i r1) i.r1'
			System::Call 'kernel32::GlobalLock(i r1) i.r2'
			System::Call 'kernel32::lstrcpyA(i r2, t r0)'
			System::Call 'kernel32::GlobalUnlock(i r1)'
			System::Call 'user32::SetClipboardData(i 1, i r1)'
			System::Call 'user32::CloseClipboard()'
			Pop $2
			Pop $1
			Pop $0
		FunctionEnd

		!undef _UNWORD1
		!define _UNWORD1
	!endif
!macroend

!macro ClbGet
	!ifndef ${_UNWORD1}ClbGet
		!define ${_UNWORD1}ClbGet `!insertmacro ${_UNWORD1}ClbGetCall`

		Function ${_UNWORD1}CopyFromClipboard
			Push $0
			System::Call 'user32::OpenClipboard(i 0)'
			System::Call 'user32::GetClipboardData(i 1) t .r0'
			System::Call 'user32::CloseClipboard()'
			Exch $0
		FunctionEnd

		!undef _UNWORD1
		!define _UNWORD1
	!endif
!macroend

!macro un.WordFindCall _STRING _DELIMITER _OPTION _RESULT
	Push `${_STRING}`
	Push `${_DELIMITER}`
	Push `${_OPTION}`
	Call un.WordFind
	Pop ${_RESULT}
!macroend

!macro un.WordFind2XCall _STRING _DELIMITER1 _DELIMITER2 _NUMBER _RESULT
	Push `${_STRING}`
	Push `${_DELIMITER1}`
	Push `${_DELIMITER2}`
	Push `${_NUMBER}`
	Call un.WordFind2X
	Pop ${_RESULT}
!macroend

!macro un.WordFind3XCall _STRING _DELIMITER1 _CENTER _DELIMITER2 _NUMBER _RESULT
	Push `${_STRING}`
	Push `${_DELIMITER1}`
	Push `${_CENTER}`
	Push `${_DELIMITER2}`
	Push `${_NUMBER}`
	Call un.WordFind3X
	Pop ${_RESULT}
!macroend

!macro un.WordReplaceCall _STRING _WORD1 _WORD2 _NUMBER _RESULT
	Push `${_STRING}`
	Push `${_WORD1}`
	Push `${_WORD2}`
	Push `${_NUMBER}`
	Call un.WordReplace
	Pop ${_RESULT}
!macroend

!macro un.WordAddCall _STRING1 _DELIMITER _STRING2 _RESULT
	Push `${_STRING1}`
	Push `${_DELIMITER}`
	Push `${_STRING2}`
	Call un.WordAdd
	Pop ${_RESULT}
!macroend

!macro un.WordInsertCall _STRING _DELIMITER _WORD _NUMBER _RESULT
	Push `${_STRING}`
	Push `${_DELIMITER}`
	Push `${_WORD}`
	Push `${_NUMBER}`
	Call un.WordInsert
	Pop ${_RESULT}
!macroend

!macro un.StrFilterCall _STRING _FILTER _INCLUDE _EXCLUDE _RESULT
	Push `${_STRING}`
	Push `${_FILTER}`
	Push `${_INCLUDE}`
	Push `${_EXCLUDE}`
	Call un.StrFilter
	Pop ${_RESULT}
!macroend

!macro un.ClbSetCall _STRING
	Push `${_STRING}`
	Call un.CopyToClipboard
!macroend

!macro un.ClbGetCall _RESULT
	Call un.CopyFromClipboard
	Pop ${_RESULT}
!macroend

!macro un.WordFind
	!ifndef un.WordFind
		!undef _UNWORD1
		!define _UNWORD1 `un.`

		!undef _UNWORD2
		!insertmacro WordFind
		!define _UNWORD2
	!endif
!macroend

!macro un.WordFind2X
	!ifndef un.WordFind2X
		!undef _UNWORD1
		!define _UNWORD1 `un.`

		!insertmacro WordFind2X
	!endif
!macroend

!macro un.WordFind3X
	!ifndef un.WordFind3X
		!undef _UNWORD1
		!define _UNWORD1 `un.`

		!insertmacro WordFind3X
	!endif
!macroend

!macro un.WordReplace
	!ifndef un.WordReplace
		!undef _UNWORD1
		!define _UNWORD1 `un.`

		!insertmacro WordReplace
	!endif
!macroend

!macro un.WordAdd
	!ifndef un.WordAdd
		!undef _UNWORD1
		!define _UNWORD1 `un.`

		!insertmacro WordAdd
	!endif
!macroend

!macro un.WordInsert
	!ifndef un.WordInsert
		!undef _UNWORD1
		!define _UNWORD1 `un.`

		!insertmacro WordInsert
	!endif
!macroend

!macro un.StrFilter
	!ifndef un.StrFilter
		!undef _UNWORD1
		!define _UNWORD1 `un.`

		!insertmacro StrFilter
	!endif
!macroend

!macro un.ClbSet
	!ifndef un.ClbSet
		!undef _UNWORD1
		!define _UNWORD1 `un.`

		!insertmacro ClbSet
	!endif
!macroend

!macro un.ClbGet
	!ifndef un.ClbGet
		!undef _UNWORD1
		!define _UNWORD1 `un.`

		!insertmacro ClbGet
	!endif
!macroend
