:: feos, 2013-2018
:: Cheers to Guga, Velitha, nanogyth, Aktan, Dacicus, TheCoreyBurton, and Zinfidel
:: This global batch is a part of "TAS Encoding Package":
:: http://tasvideos.org/EncodingGuide/PublicationManual.html
:: Allows to select encode to make
:: Accepts command line arguments

@echo off
setlocal EnableExtensions
setlocal EnableDelayedExpansion

if [%1]==[/?] goto syntax_cmd

:: Restore AVS defaults ::
".\programs\replacetext" "encode.avs" "fullHD = true" "fullHD = false"

echo -----------------------
echo  Hybrid Encoding Batch
echo -----------------------
echo.
echo Type /? for command-line arguments.
echo.

: ENCODE_OPTIONS
set EncodeChoice=
set param_2=%2
if [%param_2%]==[] goto get_encode_option
set EncodeChoice=%param_2:~0,1%
goto process_encode_option

: get_encode_option
echo.
echo Which HD resolution do you want?
echo.
echo Press 1 for 720p.
echo Press 2 for 1080p.
echo.
set /p EncodeChoice=

: process_encode_option
if "%EncodeChoice%"=="1" goto Encode
if "%EncodeChoice%"=="2" goto full_HD

echo.
echo You better choose something real!
goto get_encode_option

: full_HD
".\programs\replacetext" "encode.avs" "fullHD = false" "fullHD = true"
goto Encode

: Encode

title Processing HD
echo.
echo ----------
echo  Encoding 
echo ----------
echo.
:: Audio ::
echo Encoding audio...
".\programs\ffmpeg" -y -hide_banner -v error -stats -i encode.avs -vn -af atrim=start_sample=7107 -c:a libfdk_aac -b:a 224K ".\temp\audio.mp4"

:: Video ::
echo Encoding video...
".\programs\x264_x64" --qp 12 -b 0 --keyint 500 --output ".\temp\video.mkv" encode.avs

:: Muxing ::
".\programs\mkvmerge" -o ".\output\encode.mkv" --compression -1:none ".\temp\video.mkv" ".\temp\audio.mp4"

: SD

goto Defaults

: Defaults
".\programs\replacetext" "encode.avs" "fullhd = true" "fullhd = false"
goto end

:syntax_cmd
echo.
echo Command-line arguments: %0 ^<enc_opt^>
echo   ^<enc_opt^>   Encode option?     1-3
echo                 1 = 720p
echo                 2 = 1080p
echo.

: end
title ALL DONE!
if "!cmdcmdline!" neq "!cmdcmdline:%~f0=!" (
	pause
)
endlocal
