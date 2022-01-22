#	Casual encoding script
#	http://tasvideos.org/EncodingGuide/PublicationManual.html

SetFilterMTMode("DEFAULT_MT_MODE", MT_MULTI_INSTANCE)
#AddAutoloadDir("MAINSCRIPTDIR/programs/plugins")
Import(ScriptDir() + "programs/functions.avsi")

threads = 8
AviSource("movie.avi")

trimFrame = 654321	# intended length of video in frames 

#	Resizer (for hd upscaling and multisegment import)
resizer = "Point"
#	force Lanczos for 3D footage with increased internal resolution 
# resizer = "Lanczos"


#	Multisegment import (upscales hires segments straight to HD when needed)
#	requires normally importing a sample whose attributes it will use for all segments
ms = false			# enable multisegment import
ms_base = "movie_"	# common string for all segment names
ms_start = 0		# number of the first segment
ms_end = 15			# number of the last segment
ms_format = "%1.0f"	# string format: http://avisynth.nl/index.php/Internal_functions#String

ms_audio = false		# use separate audio file for video
ms_audiotrack = "PSXjin.wav"	# path to audio file

######################
# AUTOMATED SETTINGS #
######################

ConvertToRGB32()

#	Add 1 scanline if height is uneven (ntsc sms, pal c64)
last.height % 2 > 0 ? StackVertical(last, Crop(0, Height-1, 0, 0)) : 0

fullHD = true

height = fullHD ? 1080 : 720
width = height * last.width / last.height
width = width % 2 == 1 ? width + 1 : width

#	Rescaling
eval(resizer+"Resize(width, height)")

#	If ms enabled, we use parameters of "resized" to apply to all segments
last = ms ? last.AppendSegment(ms_base, ms_start, ms_end, ms_format, resizer).ConvertToRGB32() : last
last = ms_audio ? AudioDub(last, WavSource(ms_audiotrack)) : last

Trim(0, trimFrame)

#	Youtube can't hanble fps above 60
last.FrameRate > 60 ? ChangeFPS(60) : 0

ConvertToYV12(chromaresample=resizer, matrix="Rec709")

Prefetch(threads)
