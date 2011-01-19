@echo off 
set OutDebugFile=output\knockout-latest.debug.js
set OutMinFile=output\knockout-latest.js
set AllFiles=
for /f "eol=] skip=1 delims=' " %%i in (source-references.js) do set Filename=%%i& call :Concatenate 

goto :Combine
:Concatenate 
    if /i "%AllFiles%"=="" ( 
        set AllFiles=..\%Filename:/=\%
    ) else ( 
        set AllFiles=%AllFiles% ..\%Filename:/=\%
    ) 
goto :EOF 

:Combine
copy /y version-header.js %OutDebugFile%
echo (function(window,undefined){ >> %OutDebugFile%
type %AllFiles%                   >> %OutDebugFile%
echo })(window);                  >> %OutDebugFile%

@rem Now call Google Closure Compiler to produce a minified version
copy /y version-header.js %OutMinFile%
tools\curl -d output_info=compiled_code -d output_format=text -d compilation_level=ADVANCED_OPTIMIZATIONS --data-urlencode js_code@%OutDebugFile% "http://closure-compiler.appspot.com/compile" >> %OutMinFile%
